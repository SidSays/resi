/***************************************************************************************************************************************
 * Author     : Ashish Sonawane
 * Date       : 3 Feb 2015
 * Description: This test class created to test the MDUPropertyRatingAutoSetBatch class that will set property rating value
***************************************************************************************************************************************/

@IsTest
private class MDUPropertyRatingAutoSetBatchTest{          
    
    private static final String LABEL_NAME_SPLIT = ';';
    // Create Property Object that will use in Test class
    private static MDU_Property__c createTestPropertyData(){
       
        String sDeveloperName = System.Label.XfinityPropertyRecordType;  
         String labelName = System.Label.XfinityPropertyRecordType;  
        List<String> recordTypeIds = new List<String>();
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(LABEL_NAME_SPLIT)){
                recordTypeIds.add(Schema.SObjectType.MDU_Property__c.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        } 
        //SetupTestData.createCustomSettingRecords();   
        MDU_Property__c propertyObject = TestDataUtility.createProperty() ;
        propertyObject.RecordTypeId = recordTypeIds[0]; 
        propertyObject.PostalCode__c = '10509';  
        propertyObject.Bulk_Status__c = 'Not Serviced';       
        propertyObject.Industry_Type__c = 'Multi Family';         
        propertyObject.Name = 'Test Property';  
        return propertyObject;
    } 
    
    private static testmethod void testPropertyRatingForNoIndustryTypeProp(){
        List<MDU_Property__c> propertyList = new List<MDU_Property__c>();  
        List<Contract__c> contractList = new List<Contract__c>();                
        TestDataUtility.createCustomSettingRecords(); 
        List<MDU_Zip_Code_Fiber__c> zipFiberList = TestDataUtility.createMduZipCodeFiber();
        Database.SaveResult[] zipFiberListRes = Database.insert(zipFiberList, false);      
        for(integer i=0 ; i<18 ; i++){
            
            MDU_Property__c propertyObject = createTestPropertyData();//TestDataUtility.createPropertyForPropertyRatingBatchTest();
            if(i == 0){                                   //for industry type other than 'Single Family'/'Multi Family' or null status record
                propertyObject.Industry_Type__c = null;   
                propertyList.add(propertyObject);
            }else if(i == 1){                             //sub-status other than 'auto-renewed' and Property Risk Status should be '>24'  
                propertyObject.Risk_Status__c = '>24';  
                propertyObject.Bulk_Status__c = null; 
                insert propertyObject;//propertyList.add(propertyObject);   
                Contract__c contractObject = TestDataUtility.createContract(propertyObject.id);
                contractObject.Sub_Status__c = 'New';
                contractObject.Contract_Status__c = 'Active';                  
                contractList.add(contractObject);  
            }else if(i == 2){                             //Create Bulk contract object with (Sub_Status__c != 'Auto-Renewed' AND Contract_Status__c != 'Archived')
                propertyObject.Bulk_Status__c = 'Bulk'; 
                propertyObject.Risk_Status__c = '>0<=6';
                propertyObject.Number_of_Units__c = 1;               
                insert propertyObject;
                Contract__c contractObject = TestDataUtility.createContract(propertyObject.id);
                contractObject.Sub_Status__c = 'Auto-Renewed';
                contractObject.Contract_Status__c = 'Active';  
                contractList.add(contractObject);               
            }else if(i == 3){                             //Create Retail contract object with (Sub_Status__c != 'Auto-Renewed' AND Contract_Status__c != 'Archived')
                propertyObject.Bulk_Status__c = 'Retail'; 
                propertyObject.Property_Type__c = 'Hospital';                         
                propertyObject.Number_of_Units__c = 1; 
                propertyObject.PostalCode__c = '10541';   //Postal Code having %fiber(10541) > .35        
                insert propertyObject;   
                Contract__c contractObject = TestDataUtility.createContract(propertyObject.id);
                contractObject.Sub_Status__c = 'Auto-Renewed';                
                contractObject.Contract_Status__c = 'Active'; 
                contractList.add(contractObject);                  
            }else if(i == 4){                             //Create Retail contract object with (Sub_Status__c != 'Auto-Renewed' AND Contract_Status__c != 'Archived')
                propertyObject.Bulk_Status__c = 'Retail'; 
                propertyObject.Property_Type__c = 'Hospital';                         
                propertyObject.Number_of_Units__c = 1; 
                propertyObject.PostalCode__c = '01431';    //Postal Code having %fiber(10579) < .35         AND 1460 > .35       
                insert propertyObject;   
                Contract__c contractObject = TestDataUtility.createContract(propertyObject.id);
                contractObject.Sub_Status__c = 'Auto-Renewed';                
                contractObject.Contract_Status__c = 'Active'; 
                contractList.add(contractObject);                    
                
            }else if(i == 5){                             //Create Retail contract object with  Contract_Status__c != 'Archived' AND Data_Marketing_Rights__c = 'Exclusive'
                propertyObject.Bulk_Status__c = 'Retail'; 
                propertyObject.Property_Type__c = 'Hospital';                         
                propertyObject.Number_of_Units__c = 1; 
                propertyObject.PostalCode__c = '10541';   //Postal Code having %fiber(10541) > .35        
                insert propertyObject;   
                Contract__c contractObjectWithMarketingRight = TestDataUtility.createContract(propertyObject.id);
                contractObjectWithMarketingRight.Sub_Status__c = 'Auto-Renewed';                
                contractObjectWithMarketingRight.Contract_Status__c = 'Active';  
                contractObjectWithMarketingRight.Data_Marketing_Rights__c = 'Exclusive';  
                contractList.add(contractObjectWithMarketingRight);            
            }else if(i == 6){                         
                propertyObject.Number_of_Units__c = 80; 
                Database.insert(propertyObject, false);   
            }else if(i == 7){                         
                propertyObject.Number_of_Units__c = 180; 
                Database.insert(propertyObject, false);   
            }else if(i == 8){ 
                propertyObject.Bulk_Status__c = 'Bulk';
                propertyObject.Number_of_Units__c = 55; 
                Database.insert(propertyObject, false);   
            }else if(i == 9){ 
                propertyObject.Bulk_Status__c = 'Bulk';
                propertyObject.Number_of_Units__c = 35; 
                Database.insert(propertyObject, false);   
            }else if(i == 10){ 
                propertyObject.Bulk_Status__c = 'Retail';
                propertyObject.Property_Type__c = 'Public Housing'; 
                Database.insert(propertyObject, false);   
            }else if(i == 11){
                propertyObject.Bulk_Status__c = 'Retail'; 
                propertyObject.Property_Type__c = 'Hospital';                         
                propertyObject.Number_of_Units__c = 165; 
                propertyObject.PostalCode__c = '10541';   //Postal Code having %fiber(10541) > .35        
                Database.insert(propertyObject, false);
                Contract__c contractObjectWithMarketingRight = TestDataUtility.createContract(propertyObject.id);
                contractObjectWithMarketingRight.Sub_Status__c = 'Auto-Renewed';                 
                contractObjectWithMarketingRight.Contract_Status__c = 'Active';
                contractList.add(contractObjectWithMarketingRight); 
            }else if(i == 12){                             //Create Retail contract object with  Contract_Status__c != 'Archived' AND Data_Marketing_Rights__c = 'Exclusive'
                propertyObject.Bulk_Status__c = 'Retail'; 
                propertyObject.Property_Type__c = 'Hospital';                         
                propertyObject.Number_of_Units__c = 1; 
                propertyObject.PostalCode__c = '01431';    //Postal Code having %fiber(10579) < .35         
                insert propertyObject;   
                Contract__c contractObjectWithMarketingRight = TestDataUtility.createContract(propertyObject.id);
                contractObjectWithMarketingRight.Sub_Status__c = 'Auto-Renewed';                
                contractObjectWithMarketingRight.Contract_Status__c = 'Active';  
                contractObjectWithMarketingRight.Data_Marketing_Rights__c = 'Exclusive';  
                contractList.add(contractObjectWithMarketingRight);          
            }else if(i == 13){
                propertyObject.Bulk_Status__c = 'Retail'; 
                propertyObject.Property_Type__c = 'Hospital';                         
                propertyObject.Number_of_Units__c = 165; 
                propertyObject.PostalCode__c = '01431';    //Postal Code having %fiber(10579) < .35         
                Database.insert(propertyObject, false);
                Contract__c contractObjectWithMarketingRight = TestDataUtility.createContract(propertyObject.id);
                contractObjectWithMarketingRight.Sub_Status__c = 'Auto-Renewed';                 
                contractObjectWithMarketingRight.Contract_Status__c = 'Active';
                contractList.add(contractObjectWithMarketingRight);      
            }
            
             else{
               propertyList.add(propertyObject);  //For Property with bulk status as 'Not Serviced'
            }             
        }                      
        Database.insert(propertyList, false);    
        Database.insert(contractList,true);
        Test.startTest();
        MDUPropertyRatingAutoSetBatch batch = new MDUPropertyRatingAutoSetBatch();
        Id batchId = Database.executeBatch(batch);                                        
        Test.stopTest();
                
        for(MDU_Property__c propertyInstantTemp : [select Property_Rating__c ,Bulk_Status__c from MDU_Property__c] ){
            System.debug('Property Rating '+propertyInstantTemp.Property_Rating__c+' Bulk Status '+propertyInstantTemp.Bulk_Status__c);   
        }                        
    }
    
     /*
    * This method test property rating batch when any error come during batch process
    */   
    private static testmethod void testPropertyRatingWithException(){
        Test.startTest(); 
        
        TestDataUtility.createCustomSettingRecords();   
        User xcIntegrationUser = TestDataUtility.createXCIntegrationUser();
                      
        System.runAs(xcIntegrationUser) {            
            TestDataUtility.bypassValidationCS(xcIntegrationUser.Id);  
            MDU_Property__c propertyObject = createTestPropertyData();
            propertyObject.Industry_Type__c = null;  
            propertyObject.PostalCode__c = '12';
            insert propertyObject;
        }
        MDUPropertyRatingAutoSetBatch batch = new MDUPropertyRatingAutoSetBatch();
        Id batchId = Database.executeBatch(batch);                                        
        
        Test.stopTest();
    }   
}