/***************************************************************************************************************************************
 * Author     : Amitkumar Bangad, Accenture
 * Date       : 26-July-2013
 * Description: This is Test class for "UpdateInformationInSalesforce" class.
 * History
     Version             : 1.0
     Author Last Updated : Amitkumar Bangad, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class UpdateInformationInSalesforceTest{
    
    private static void setupData(){
        SetupTestData.createCustomSettingRecords();

        List<Asset> asstList = new List<Asset>();
        List<Product2> productList = new List<Product2>();
        List<Customer_Address__c> customerAddressList = new List<Customer_Address__c>(); 
        List<Account> accList = new List<Account>(); 
        
        // Create Account
        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.Customer_Status__c = 'Former';
        acc.Installation_Status__c = 'Active';
        acc.Region__c = 'Freedom Market';
        accList.add(acc);
        
        Account acc1 = new Account();
        acc1.Name = 'TestAccount1';
        acc1.Customer_Status__c = 'Active';
        acc1.Installation_Status__c = 'Active';
        acc1.Region__c = 'Freedom Market';
        accList.add(acc1);
        
        insert accList;
        
        Customer_Address__c addr = new Customer_Address__c();
        addr.Address__c = 'Test Address';
        addr.Address_2__c = 'Test Address2';
        addr.State__c = 'Test State';
        addr.City__c = 'Test City';
        addr.Country__c = 'Test Country';
        addr.Node__c = '1111';
        addr.Corp__c = '11111111';
        addr.Route_Code__c = '1111111111';
        addr.PostalCode__c = '12345';
        addr.PostalCode_4__c = '12345-1234';
//        addr.Status__c = 'Active';            
        addr.Region__c = 'Freedom Market';
        addr.Billing_House_Key__c = '12415252627';
        addr.Location_Id__c = '12414525646';
        customerAddressList.add(addr);
        
        Customer_Address__c addr1 = new Customer_Address__c();
        addr1.Address__c = 'Test Address12';
        addr1.Address_2__c = 'Test Address22';
        addr1.State__c = 'Test State2';
        addr1.City__c = 'Test City2';
        addr1.Country__c = 'Test Country2';
        addr1.Account__c = accList[0].Id;
        addr1.Node__c = '99991';
        addr1.Corp__c = '9999999991';
        addr1.Route_Code__c = '99999991';
        addr1.PostalCode__c = '98765';
        addr1.PostalCode_4__c = '98765-1234';
//        addr1.Status__c = 'Active';            
        addr1.Region__c = 'Freedom Market';
        addr1.Billing_House_Key__c = '123456789';
        addr1.Location_Id__c = '1122334455';
        customerAddressList.add(addr1);
        
        Customer_Address__c addr2 = new Customer_Address__c();
        addr2.Address__c = 'Test Address123';
        addr2.Address_2__c = 'Test Address3';
        addr2.State__c = 'Test State3';
        addr2.City__c = 'Test City3';
        addr2.Country__c = 'Test Country3';
        addr2.Account__c = accList[1].Id;
        addr2.Node__c = '91999';
        addr2.Corp__c = '9199999999';
        addr2.Route_Code__c = '19999999';
        addr2.PostalCode__c = '56789';
        addr2.PostalCode_4__c = '56789-1234';
//        addr2.Status__c = 'Active';            
        addr2.Region__c = 'Freedom Market';
        addr2.Billing_House_Key__c = '987654321';
        addr2.Location_Id__c = '9988776655';
        customerAddressList.add(addr2);
        insert customerAddressList;
        
        // Create Products
        
        Product2 prod1 = new Product2();
        prod1.name = 'Video';
        prod1.ProductCode = 'Video';
        prod1.Family = 'Service';
        productList.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.name = 'Voice';
        prod2.ProductCode = 'Voice';
        prod2.Family = 'Service';
        productList.add(prod2);
        
        Product2 prod3 = new Product2();
        prod3.name = 'XHS';
        prod3.ProductCode = 'XHS';
        prod3.Family = 'Service';
        productList.add(prod3);
        
        Product2 prod4 = new Product2();
        prod4.name = 'XSS';
        prod4.ProductCode = 'XSS';
        prod4.Family = 'Service';
        productList.add(prod4);
        
        Product2 prod5 = new Product2();
        prod5.name = 'HSD';
        prod5.ProductCode = 'HSD';
        prod5.Family = 'Service';
        productList.add(prod5);
        
        Product2 prod6 = new Product2();
        prod6.name = 'WIRELESSDATA';
        prod6.ProductCode = 'WIRELESSDATA';
        prod6.Family = 'Service';
        productList.add(prod6);
        
        Product2 prod7 = new Product2();
        prod7.name = 'Equipment';
        prod7.ProductCode = 'Equipment';
        prod7.Family = 'Equipment';
        productList.add(prod7);
        
        Product2 prod8 = new Product2();
        prod8.name = 'VIDEO_HD_ADDON';
        prod8.ProductCode = 'VIDEO_HD_ADDON';
        prod8.Family = 'Service';
        productList.add(prod8);
        insert productList;
        
         // Create Assets of Type Equipments
        Asset asst = new Asset();
        asst.Name ='TestAsset';
        asst.AccountId = acc.id;
        asst.Product2Id= prod7.id;
        asst.Type__c ='Equipment';
        asst.Status = 'Active';
        asstList.add(asst);
        
        Asset asst1 = new Asset();
        asst1.Name ='TestAsset1';
        asst1.AccountId = acc.id;
        asst1.Product2Id= prod7.id;
        asst1.Type__c ='Equipment';
        asst1.Status = 'Active';
        asstList.add(asst1);
        
        Asset asst7 = new Asset();
        asst7.Name ='TestAsset7';
        asst7.AccountId = acc1.id;
        asst7.Product2Id= prod7.id;
        asst7.Type__c ='Equipment';
        asst7.Status = 'Active';
        asstList.add(asst7);
        asst7.Status = 'Inactive';
        
        Asset asst11 = new Asset();
        asst11.Name ='MTA';
        asst11.AccountId = acc1.id;
        asst11.Product2Id= prod7.id;
        asst11.Type__c ='Equipment';
        asst11.Status = 'Active';
        asstList.add(asst11);
        asst11.Status = 'Inactive';
        
        //Create Assets of type Service
     
        Asset asst3 = new Asset();
        asst3.name = 'TestAsset3';
        asst3.AccountId = acc1.id;
        asst3.Type__c ='Service';
        asst3.Status = 'Active';
        asst3.Product2Id= prod1.id;
        asstList.add(asst3);
        
        
        Asset asst6 = new Asset();
        asst6.name = 'TestAsset4';
        asst6.AccountId = acc1.id;
        asst6.Type__c ='Service';
        asst6.Status = 'Active';
        asst6.Product2Id= prod2.id;
        asstList.add(asst6);
        
        Asset asst8 = new Asset();
        asst8.name = 'TestAsset8';
        asst8.AccountId = acc.id;
        asst8.Type__c ='Service';
        asst8.Status = 'Active';
        asst8.Product2Id= prod3.id;
        asstList.add(asst8);
        
        Asset asst9 = new Asset();
        asst9.name = 'TestAsset9';
        asst9.AccountId = acc1.id;
        asst9.Type__c ='Service';
        asst9.Status = 'Active';
        asst9.Product2Id= prod4.id;
        asstList.add(asst9);
        
        Asset asst10 = new Asset();
        asst10.name = 'TestAsset10';
        asst10.AccountId = acc.id;
        asst10.Type__c ='Service';
        asst10.Status = 'Active';
        asst10.Product2Id= prod5.id;
        asstList.add(asst10);
        
        insert asstList;
    }
    private static testMethod void testUpdateInformationNull() {
        Test.setMock(HttpCalloutMock.class, new SuperAPIMock());
        SetupTestData.createCustomSettingRecords();
        UpdateInformationInSalesforce updateInfo = new UpdateInformationInSalesforce();
        UpdateInformationInSalesforce.cAddress addressInfo = new UpdateInformationInSalesforce.cAddress();
        Test.StartTest(); 
        addressInfo = null;
        String result = UpdateInformationInSalesforce.getUpdateStatus(null);
        Test.StopTest();
    }
    private static testMethod void testUpdateInformationBillingHousekey() {
        setupData();
        Test.setMock(HttpCalloutMock.class, new SuperAPIMock());
        UpdateInformationInSalesforce updateInfo = new UpdateInformationInSalesforce();
        UpdateInformationInSalesforce.cAddress addressInfo = new UpdateInformationInSalesforce.cAddress();
        addressInfo.billingHouseKey = '12415252627';
        Test.StartTest(); 
        String result = UpdateInformationInSalesforce.getUpdateStatus(addressInfo);
        Test.StopTest();
    }
    private static testMethod void testUpdateInformationExistingAccount() {
        setupData();
        Test.setMock(HttpCalloutMock.class, new SuperAPIMock());
        UpdateInformationInSalesforce updateInfo = new UpdateInformationInSalesforce();
        UpdateInformationInSalesforce.cAddress addressInfo = new UpdateInformationInSalesforce.cAddress();
        addressInfo.billingHouseKey = '123456789';
        Test.StartTest(); 
        String result = UpdateInformationInSalesforce.getUpdateStatus(addressInfo);
        Test.StopTest();
    }
    private static testMethod void testUpdateInformationLocationId() {
        setupData();
        Test.setMock(HttpCalloutMock.class, new SuperAPIMock());
        UpdateInformationInSalesforce updateInfo = new UpdateInformationInSalesforce();
        UpdateInformationInSalesforce.cAddress addressInfo = new UpdateInformationInSalesforce.cAddress();
        Test.StartTest(); 
        addressInfo.billingHouseKey = '';
        addressInfo.locationId = '12414525646';
        String result = UpdateInformationInSalesforce.getUpdateStatus(addressInfo);
        Test.StopTest();
    }
    private static testMethod void testUpdateInformationAddressSet1() {
        setupData();
        Test.setMock(HttpCalloutMock.class, new SuperAPIMock());
        UpdateInformationInSalesforce updateInfo = new UpdateInformationInSalesforce();
        UpdateInformationInSalesforce.cAddress addressInfo = new UpdateInformationInSalesforce.cAddress();
        Test.StartTest(); 
        addressInfo.billingHouseKey = '';
        addressInfo.locationId = '';
        addressInfo.country = 'Test Country3';
        addressInfo.city = 'Test City3';
        addressInfo.unitType = 'ABC';
        addressInfo.zipCode = '56789';
        addressInfo.state = 'Test State3';
        addressInfo.unitNumber = '12123';
        addressInfo.zip4Code = '56789-1234';
        addressInfo.streetAddress1 = 'Test Address123';
        addressInfo.streetAddress2 = 'Test Address3';
        String result = UpdateInformationInSalesforce.getUpdateStatus(addressInfo);
        Test.StopTest();
    }
    private static testMethod void testUpdateInformationMockSet1() {
        setupData();
        Test.setMock(HttpCalloutMock.class, new SuperAPIMock1());
        UpdateInformationInSalesforce updateInfo = new UpdateInformationInSalesforce();
        UpdateInformationInSalesforce.cAddress addressInfo = new UpdateInformationInSalesforce.cAddress();
        Test.StartTest(); 
        addressInfo.billingHouseKey = '';
        addressInfo.locationId = '';
        addressInfo.country = 'Test Country3';
        addressInfo.city = 'Test City3';
        addressInfo.unitType = 'ABC';
        addressInfo.zipCode = '56789';
        addressInfo.state = 'Test State3';
        addressInfo.unitNumber = '12123';
        addressInfo.zip4Code = '56789-1234';
        addressInfo.streetAddress1 = 'Test Address123';
        addressInfo.streetAddress2 = 'Test Address3';
        String result = UpdateInformationInSalesforce.getUpdateStatus(addressInfo);
        Test.StopTest();
    }
    private static testMethod void testUpdateInformationMockSet2() {
        setupData();
        Test.setMock(HttpCalloutMock.class, new SuperAPIMock2());
        UpdateInformationInSalesforce updateInfo = new UpdateInformationInSalesforce();
        UpdateInformationInSalesforce.cAddress addressInfo = new UpdateInformationInSalesforce.cAddress();
        Test.StartTest(); 
        addressInfo.billingHouseKey = '';
        addressInfo.locationId = '';
        addressInfo.country = 'Test Country3';
        addressInfo.city = 'Test City3';
        addressInfo.unitType = 'ABC';
        addressInfo.zipCode = '56789';
        addressInfo.state = 'Test State3';
        addressInfo.unitNumber = '12123';
        addressInfo.zip4Code = '56789-1234';
        addressInfo.streetAddress1 = 'Test Address123';
        addressInfo.streetAddress2 = 'Test Address3';
        String result = UpdateInformationInSalesforce.getUpdateStatus(addressInfo);
        Test.StopTest();
    }
}