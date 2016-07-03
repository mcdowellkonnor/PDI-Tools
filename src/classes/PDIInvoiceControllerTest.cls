@isTest(seeAllData=true)
public with sharing class PDIInvoiceControllerTest {
	testMethod static void testController(){
		ECS__eCommSource_Order__c test_order = [SELECT id FROM ECS__eCommSource_Order__c LIMIT 1];
		id order_id = (id)test_order.id;
		
		PageReference pageref = Page.PDIInvoice;
    	Test.setCurrentPage(pageref);
    	ApexPages.currentPage().getParameters().put('id', order_id);
		
		PDIInvoiceController controller = new PDIInvoiceController();
		Test.startTest();
		controller.getOrder();
		controller.getProductsPurchased();
		Test.stopTest();
	} 
}