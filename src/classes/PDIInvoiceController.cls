/*
	Developed by: Konnor McDowell
	mcdowellkonnor@gmail.com
*/

public with sharing class PDIInvoiceController {
    public ECS__eCommSource_Order__c this_order {get;set;}
    public String logo_url {get;set;}
    public String discount_amount {get;set;}
    public String shipping_total {get;set;}
    public String tax_total {get;set;}
    public String total_amount {get;set;}
    public String tracking_number {get;set;}
    public String local_status {get;set;}
    public String bill_company {get;set;}
   	public String bill_address_line_2 {get;set;}
   	public String bill_phone_number {get;set;}
   	public String ship_company {get;set;}
   	public String ship_address_line_2 {get;set;}
   	public String ship_phone_number {get;set;}
    
    public List<ECS__Products_Purchased__c> products_purchased {get;set;}
    public id order_id {
    	get{
    		return (id)ApexPages.currentPage().getParameters().get('id');
    	}
    	set;
    }
    
    public PDI_Tools__Tools__c settings = [SELECT PDI_Tools__Local_Status_Field__c FROM PDI_Tools__Tools__c LIMIT 1];
    
    public PDIInvoiceController(){
    	this.this_order = getOrder();
    	this.products_purchased = getProductsPurchased();
    	this.logo_url = getLogoUrl();
    	
    	if (this_order.ECS__Discount_Amount__c == null){
    		this.discount_amount = '0.00';
    	} else {
    		this.discount_amount = String.valueOf(this_order.ECS__Discount_Amount__c);
    	}
    	this.discount_amount = confirmDiscountAmount();
    	
    	if (this_order.ECS__Shipping_Total__c == null){
    		this.shipping_total = '0.00';
    	} else {
    		this.shipping_total = round(this_order.ECS__Shipping_Total__c);
    	}
    	
    	if (this_order.ECS__Tax_Total__c == null){
    		this.tax_total = '0.00';
    	} else {
    		this.tax_total = round(this_order.ECS__Tax_Total__c);
    	}
    	
    	if (this_order.ECS__Total_Order_Amount__c == null){
    		this.total_amount = '0.00';
    	} else {
    		this.total_amount = round(this_order.ECS__Total_Order_Amount__c);	
    	}
    	
    	this.tracking_number = getTrackingNumber();
    	this.local_status = getLocalStatus();
    	
    	this.bill_company = getBillCompany();
    	this.bill_address_line_2 = getBillLine2();
    	this.bill_phone_number = getBillPhone();
    	
    	this.ship_company = getShipCompany();
    	this.ship_address_line_2 = getShipLine2();
    	this.ship_phone_number = getShipPhone();
    }
    
    public ECS__eCommSource_Order__c getOrder(){
    	String local_status = (String)settings.PDI_Tools__Local_Status_Field__c;
    	String query = 'SELECT Id, ECS__Order_Time__c, ECS__External_Order_ID__c, ECS__Billing_Address__c, ECS__Bill_To_Name__c, ECS__Billing_Address__r.ECS__Address_Line_1__c, ECS__Billing_Address__r.ECS__Address_Line_2__c, ' + 
    	'ECS__Billing_Address__r.ECS__City__c, ECS__Billing_Address__r.ECS__State_Province_Region__c, ECS__Account__r.Name, ECS__Billing_Address__r.ECS__Zip_Postal_Code__c, ' +
    	'ECS__Billing_Address__r.ECS__Country__c, ECS__Ship_To_Name__c, ECS__Shipping_Address_Line_1__c, ECS__Shipping_Address_Line_2__c, ' +
    	'ECS__Shipping_Address_City__c, ECS__Shipping_Address_State__c, ECS__Shipping_Address_Zip_Code__c, ECS__Shipping_Address_Country__c, ' +
    	'ECS__Purchase_Order_Number__c, ECS__Terms__c, ECS__Payment_Type__c, ECS__Discount_Amount__c, ECS__Shipping_Total__c, ECS__Tax_Total__c, ' +
    	'ECS__Total_Order_Amount__c, ECS__Account__r.PDI_Tools__Image_Icon_URL__c, ECS__Order_Status__c, ' + local_status + ', ' +
    	'ECS__Shipping_Detail__r.ECS__Tracking_Number__c, ECS__Billing_Address__r.ECS__Phone_Number__c, ' + 
    	'ECS__Billing_Address__r.ECS__Company__c, ECS__Shipping_Address_Company__c, ' + 
    	'ECS__Ship_To_Phone__c FROM ECS__eCommSource_Order__c WHERE id =: order_id';
    	ECS__eCommSource_Order__c s_order = Database.query(query);
    	return s_order;
    }
    
    public String round(Decimal decimal_to_round){
    	Decimal rounded = decimal_to_round.setScale(2);
    	return String.valueOf(rounded);
    }
    
    public List<ECS__Products_Purchased__c> getProductsPurchased(){
    	id order_id = (id)ApexPages.currentPage().getParameters().get('id');
    	List<ECS__Products_Purchased__c> products = [SELECT ECS__Product__c, ECS__Quantity_Purchased__c, ECS__Product__r.Name, 
    	ECS__Product_Title__c, ECS__Purchase_Price__c, ECS__Purchase_Total__c FROM ECS__Products_Purchased__c WHERE ECS__Order__c =: order_id];
    	return products;
    }
    
    public String getLogoUrl(){
    	if (this_order.ECS__Account__r.PDI_Tools__Image_Icon_URL__c == '' || this_order.ECS__Account__r.PDI_Tools__Image_Icon_URL__c == null){
    		return 'https://7eb5ab3889eb5e092cf9af2eabc400d6e67ffa9c.googledrive.com/host/0B161Z0-Au_K4OWJUYmt3M1RqaG8/PDI1.jpg'; 
    	} else {
    		return (String)this_order.ECS__Account__r.PDI_Tools__Image_Icon_URL__c;
    	}
    }
    
    public String confirmDiscountAmount(){
    	if (discount_amount == '0.00'){
    		return '';
    	} else {
    		return ('<td>Discount&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td>$' + discount_amount + '</td>');
    	}
    }
    
    public String getTrackingNumber(){
    	if (this_order.ECS__Shipping_Detail__r.ECS__Tracking_Number__c == null || this_order.ECS__Shipping_Detail__r.ECS__Tracking_Number__c == ''){
    		return '<td></td>';
    	} else {
    		return '<td>Tracking #</td><td>' + String.valueOf(this_order.ECS__Shipping_Detail__r.ECS__Tracking_Number__c) + '</td>';
    	}
    }
    
    public String getLocalStatus(){
    	return (String)this_order.get((String)settings.PDI_Tools__Local_Status_Field__c);
    }
    
    public String getBillCompany(){
    	if (this_order.ECS__Billing_Address__r.ECS__Company__c == null || this_order.ECS__Billing_Address__r.ECS__Company__c == ''){
    		return null;
    	} else {
    		return '<tr><td>' + String.valueOf(this_order.ECS__Billing_Address__r.ECS__Company__c) + '</td></tr>';
    	}
    }
    
    public String getBillLine2(){
    	if (this_order.ECS__Billing_Address__r.ECS__Address_Line_2__c == null || this_order.ECS__Billing_Address__r.ECS__Address_Line_2__c == ''){
    		return null;
    	} else {
    		return '<tr><td>' + String.valueOf(this_order.ECS__Billing_Address__r.ECS__Address_Line_2__c) + '</td></tr>';
    	}
    }
    
    public String getBillPhone() {
    	if (this_order.ECS__Billing_Address__r.ECS__Phone_Number__c == null || this_order.ECS__Billing_Address__r.ECS__Phone_Number__c == ''){
    		return null;
    	} else {
    		return '<tr><td>' + String.valueOf(this_order.ECS__Billing_Address__r.ECS__Phone_Number__c) + '</td></tr>';
    	}
    }
    
    public String getShipCompany(){
    	if (this_order.ECS__Shipping_Address_Company__c == null || this_order.ECS__Shipping_Address_Company__c == ''){
    		return null;
    	} else {
    		return '<tr><td>' + String.valueOf(this_order.ECS__Shipping_Address_Company__c) + '</tr></td>';
    	}
    }
    
    public String getShipLine2(){
    	if (this_order.ECS__Shipping_Address_Line_2__c == null || this_order.ECS__Shipping_Address_Line_2__c == ''){
    		return null;
    	} else {
    		return '<tr><td>' + String.valueOf(this_order.ECS__Shipping_Address_Line_2__c) + '</tr></td>';
    	}
    }
    
    public String getShipPhone() {
    	if (this_order.ECS__Ship_To_Phone__c == null || this_order.ECS__Ship_To_Phone__c == ''){
    		return null;
    	} else {
    		return '<tr><td>' + String.valueOf(this_order.ECS__Ship_To_Phone__c) + '</tr></td>';
    	}
    }
}