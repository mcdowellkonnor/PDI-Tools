/*
	- Developed by: Konnor McDowell
*/
trigger ProductCount on ECS__Products_Purchased__c (after insert) {
	boolean execute = false;
	try {
		PDI_Tools__Tools__c settings = [SELECT PDI_Tools__Do_Product_Counting__c FROM PDI_Tools__Tools__c LIMIT 1];
		execute = settings.PDI_Tools__Do_Product_Counting__c;
	} catch (System.QueryException e){
		execute = false;
	}

	if (execute || Test.isRunningTest()){
		try {
			List<List<id>> list_of_products = new List<List<id>>();
			List<id> products = new List<id>();
			
			Integer tick = 0;
			for (ECS__Products_Purchased__c o : Trigger.new){
				tick++;
				products.add((id)o.id);
				System.debug('Adding ' + o + ' to ' + products);
				
				if (tick >= 20){
					System.debug('Making new list');
					list_of_products.add(products);
					products = new List<id>();
					tick = 0;
				}
			}
			
			if (tick != 0){
				list_of_products.add(products);
			}
			
			System.debug('List to start queuing: ' + list_of_products);
			for (List<id> o : list_of_products){
				System.debug('Enqueueing ' + o);
				System.enqueueJob(new PDI_Tools.QueueProductCount(o));
			}
		} catch (Exception e){}
	}
}