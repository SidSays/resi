/**
* This class contains unit tests for MDUPropertySegmentationTypeAutoSet batch job
* Created: 29-Jan-2015
* Date : 16 January 2015
* Author : Sagar Gurav
*/
@isTest
private class MDUPropertySegmentationTypeAutoSetTest {
    
    private static testMethod void engineScheduleTest() {
        TestDataUtility.createCustomSettingRecords();
        Account acc = TestDataUtility.createAccount();
        Database.insert(acc, false);
        
        List<MDU_Property__c> propertyList = new List<MDU_Property__c>();
        //Bulk property        
        MDU_Property__c MDUpropWithoutIndType = TestDataUtility.createProperty();
        MDUpropWithoutIndType.Industry_Type__c = null;
        propertyList.add(MDUpropWithoutIndType);
        
        MDU_Property__c MDUprop1 = TestDataUtility.createProperty();
        MDUprop1.PostalCode__c = '10541';
        MDUprop1.Bulk_Status__c = 'Bulk';
        MDUprop1.Property_Type__c = 'Commercial';
        propertyList.add(MDUprop1);
        
        MDU_Property__c MDUprop111 = TestDataUtility.createProperty();
        MDUprop111.PostalCode__c = '01431';
        MDUprop111.Bulk_Status__c = 'Bulk';
        MDUprop111.Property_Type__c = 'Commercial';
        propertyList.add(MDUprop111);
        
       
        
        MDU_Property__c MDUprop11 = TestDataUtility.createProperty();
        MDUprop11.PostalCode__c = '01431';
        MDUprop11.Bulk_Status__c = 'Bulk';
        propertyList.add(MDUprop11);
        
      
       
        //Retail property
        //Property With Property Type : Apartment and Zip Fibber % > 35.00 
        MDU_Property__c MDUprop21 = TestDataUtility.createProperty();
        MDUprop21.PostalCode__c = '10541';
        MDUprop21.Bulk_Status__c = 'Retail';
        MDUprop21.Property_Type__c = 'Apartment';
        propertyList.add(MDUprop21);
        
      
       
        //Property With Property Type : Apartment and Zip Fibber % < 35.00 
        MDU_Property__c MDUprop211 = TestDataUtility.createProperty();
        MDUprop211.PostalCode__c = '01431';
        MDUprop211.Bulk_Status__c = 'Retail';
        MDUprop211.Property_Type__c = 'Apartment';
        propertyList.add(MDUprop211);
        
       
                
        //Property With Property Type : NULL and Zip Fibber % < 35.00 
        MDU_Property__c MDUprop212 = TestDataUtility.createProperty();
        MDUprop212.PostalCode__c = '01431';
        MDUprop212.Bulk_Status__c = 'Retail';
        MDUprop212.Property_Type__c = 'Town Homes';
        propertyList.add(MDUprop212);
        
               
        MDU_Property__c MDUprop22 = TestDataUtility.createProperty();
        MDUprop22.PostalCode__c = '01431';
        MDUprop22.Bulk_Status__c = 'Retail';
        MDUprop21.Property_Type__c = 'Assisted Living';
        propertyList.add(MDUprop22);
        
        MDU_Property__c MDUprop29 = TestDataUtility.createProperty();
        MDUprop29.PostalCode__c = '01431';
        MDUprop29.Bulk_Status__c = 'Retail';
        MDUprop21.Property_Type__c = 'Mobile Home';
        propertyList.add(MDUprop29);
        
        
        /*  Ashish Change */
        MDU_Property__c MDUprop30 = TestDataUtility.createProperty();
        MDUprop30.PostalCode__c = '01431';
        MDUprop30.Industry_Type__c = 'Single Family';
        MDUprop30.Bulk_Status__c = 'Retail';
        MDUprop30.Property_Type__c = 'Retirement Home';
        
        propertyList.add(MDUprop30);
        
        
        
        Database.insert(propertyList, false);   
        
        List<Contract__c> contractList = new List<Contract__c>();
         Contract__c contractObj1 = TestDataUtility.createContract(propertyList[0].id);
        contractObj1.Contract_Status__c = 'Franchise';
        contractObj1.Data_Marketing_Rights__c = 'Exclusive';
        contractList.add(contractObj1);
       
        
        Contract__c contractObj11 = TestDataUtility.createContract(propertyList[3].id);
        contractObj11.Contract_Status__c = 'Franchise';
        contractObj11.Data_Marketing_Rights__c = 'Exclusive';
        contractList.add(contractObj11);
        
        
          Contract__c contractObj21 = TestDataUtility.createContract(propertyList[4].id);
        contractObj21.Contract_Status__c = 'Franchise';
        contractObj21.Data_Marketing_Rights__c = 'Exclusive';
        contractList.add(contractObj21);
        
        
         Contract__c contractObj211 = TestDataUtility.createContract(propertyList[5].id);
        contractObj211.Contract_Status__c = 'Franchise';
        contractObj211.Data_Marketing_Rights__c = 'Exclusive';
        contractList.add(contractObj211);
        
         Contract__c contractObj212 = TestDataUtility.createContract(propertyList[6].id);
        contractObj212.Contract_Status__c = 'Franchise';
        contractObj212.Data_Marketing_Rights__c = '';
        contractList.add(contractObj212);
        
        Contract__c contractObj22 = TestDataUtility.createContract(propertyList[7].id);
        contractObj22.Contract_Status__c = 'Franchise';
        contractObj22.Data_Marketing_Rights__c = 'Exclusive';
        contractList.add(contractObj22);
        
        database.insert(contractList,false);
        
        List<MDU_Zip_Code_Fiber__c> MDUzipCodeFiber1 = TestDataUtility.createMduZipCodeFiber(); 
        Database.insert(MDUzipCodeFiber1, false);
              
        Test.startTest();
        MDUPropertySegmentationTypeAutoSetBatch sc = new MDUPropertySegmentationTypeAutoSetBatch();
        Id batchprocessId = Database.executeBatch(sc, 200);
        
        for(MDU_Property__c propInst : [Select id,Name ,PostalCode__c,Risk_Status__c,Comcast_Video_Serviced__c,Comcast_Voice_Serviced__c,Comcast_Data_Serviced__c, 
                            Video_Billing_Type__c,Industry_Type__c,Property_Type__c,Property_Rating__c,Voice_Billing_Type__c,Data_Billing_Type__c, Bulk_Status__c,
                            Number_of_Units__c from MDU_Property__c]){
              
            } 
        Test.stopTest();
    }
    
    /*
    * This method test contract's for auto-renew added against MDU property  
    */   
    private static testmethod void accountSegmentationNegativeTest(){
        Test.startTest(); 
        
        TestDataUtility.createCustomSettingRecords();   
        User xcIntegrationUser = TestDataUtility.createXCIntegrationUser();
                      
        System.runAs(xcIntegrationUser) {            
            TestDataUtility.bypassValidationCS(xcIntegrationUser.Id);  
            MDU_Property__c MDUprop21 = TestDataUtility.createProperty();
            MDUprop21.PostalCode__c = '12';
            MDUprop21.Bulk_Status__c = 'Retail';
            MDUprop21.Property_Type__c = 'Apartment';
            Insert MDUprop21;      
        }
        MDUPropertySegmentationTypeAutoSetBatch sc = new MDUPropertySegmentationTypeAutoSetBatch();
        Id batchprocessId = Database.executeBatch(sc, 200);                                      
        
        Test.stopTest();
    } 
}