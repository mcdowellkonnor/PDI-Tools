global with sharing class ProductCount {
	@future
    public static void countProducts(List<id> product_ids){
    	boolean execute = false;
    	try {
    		PDI_Tools__Tools__c settings = [SELECT PDI_Tools__Do_Product_Counting__c FROM PDI_Tools__Tools__c LIMIT 1];
    		execute = settings.PDI_Tools__Do_Product_Counting__c;
    	} catch (System.QueryException e){
    		execute = false;
    	}
    	
    	if (execute || Test.isRunningTest()){
	    	try {
		    	
		    	List<sObject> products = [SELECT Id, ECS__Order__c, PDI_Tools__Purchased_in_Order__c, ECS__Quantity_Purchased__c FROM ECS__Products_Purchased__c WHERE id in: product_ids];
		    	Set<id> order_ids = new Set<id>();
		    	List<id> product_id = new List<id>();
		    	
		    	for (sObject o : products){
		    		if (!order_ids.contains((id)o.get('ECS__Order__c'))){
		    			order_ids.add((id)o.get('ECS__Order__c'));
		    		}
		    		
		    		product_id.add((id)o.get('Id'));
		    	}
		     	
		    	String query = 'SELECT ECS__Order__c, PDI_Tools__Purchased_in_Order__c, ECS__Quantity_Purchased__c FROM ECS__Products_Purchased__c WHERE ECS__Order__c in: order_ids' +
		    	' AND id NOT IN: product_id'; 
		    	List<sObject> relative_products = Database.query(query);
		    	
		    	query = 'SELECT PDI_Tools__Purchased_in_Order__c, Id FROM ECS__eCommSource_Order__c WHERE id IN: order_ids'; 
		    	List<sObject> orders = Database.query(query);
		    	
		    	System.debug('PRODUCT_ID ' + product_id);
		     	System.debug('ORDER_IDS ' + order_ids);
		     	System.debug('PRODUCTS ' + products);
		     	System.debug(relative_products + ' RELATIVE PRODUCTS');
		     	System.debug('ORDERS ' + orders);
		    	
		    	List<sObject> to_update = new List<sObject>();
		    	for (sObject o : orders){
		    		List<sObject> products_to_modify = new List<sObject>();
		    		double quantity = 0;
		    		for (sObject x : products){
		    			if (((String)x.get('ECS__Order__c')).equalsIgnoreCase((String)o.get('id'))){
		    				products_to_modify.add(x);
		    				System.debug('Adding ' + x + ' to ' + products_to_modify + ' QUANTITY FROM ' + quantity);
		    				if (x.get('ECS__Quantity_Purchased__c') != null){
		    				quantity += Double.valueOf(x.get('ECS__Quantity_Purchased__c'));
		    				}
		    				System.debug('QUANTITY TO: ' + quantity);
		    			}
		    		}
		    		
		    		for (sObject x : relative_products){
		    			if (((String)x.get('ECS__Order__c')).equalsIgnoreCase((String)o.get('id'))){
		    				products_to_modify.add(x);
		    				System.debug('Adding (relative) ' + x + ' to ' + products_to_modify + ' QUANTITY FROM ' + quantity);
		    				if (x.get('ECS__Quantity_Purchased__c') != null){
		    				quantity += Double.valueOf(x.get('ECS__Quantity_Purchased__c'));
		    				}
		    				System.debug('QUANTITY TO: ' + quantity);
		    			}
		    		}
		    		
		    		for(sObject x : products_to_modify){
		    			System.debug('Putting ' + quantity + ' into ' + x);
		    			x.put('PDI_Tools__Purchased_in_Order__c', String.valueOf(quantity));
		    		}
		    		
		    		o.put('PDI_Tools__Purchased_in_Order__c', String.valueOf(quantity));
		    		
		    		to_update.addAll(products_to_modify);
		    		to_update.add(o);
		    	}
		    	
		    	System.debug('Updating ' + to_update);
		    	update to_update;
	    	} catch (Exception e){
	    		
	    	}
    	}
    }
}