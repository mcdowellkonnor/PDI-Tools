public with sharing class QueueProductCount implements Queueable {
	
	public List<id> products = new List<id>();
	
    public QueueProductCount(List<id> product_purchased){
    	products = product_purchased;
    }
    
    public void execute(QueueableContext context) {
    	try {
    	PDI_Tools.ProductCount.countProducts(products);
    	} catch (Exception e){
    		
    	}
    }
}