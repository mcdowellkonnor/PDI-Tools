/*
	- Developed by: Konnor McDowell
*/

@isTest(seeAllData=true)
public with sharing class ProductCountTest {
    static testMethod void testProductPurchased(){
    	sObject s_order = [SELECT id FROM ECS__eCommSource_Order__c LIMIT 1];
    	sObject s_customer = [SELECT id FROM Contact LIMIT 1];
    	sObject product = [SELECT id FROM ECS__Product__c LIMIT 1];
    	decimal dec = 10.0;
    	ECS__Products_Purchased__c product_to_in = new ECS__Products_Purchased__c(ECS__External_Purchased_Product_ID__c = '1111', ECS__Contact__c = (id)s_customer.get('id'), ECS__Order__c = (id)s_order.get('id'), ECS__Product__c = (id)product.get('id'), ECS__Quantity_Purchased__c = dec);
    	
    	test.startTest();
    	insert product_to_in;
    	test.stopTest();
    }
}