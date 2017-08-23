/***************************************************************************************************************************************
 * Author     : Ashish Sonawane
 * Date       : 28 Jan 2014
 * Description: This test class created to test the MduContractAutoRenewBatch class that will set contract sub-status as Auto-Renewed  
***************************************************************************************************************************************/

@IsTest
private class MDUContractAutoRenewBatchTest{            
     
    private static testmethod void testPropertyWithMultipleContract(){
         
        Test.startTest(); 
      
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        System.runAs(user) { 
                      
            Set<String> recordTypeSet = new Set<String>();
            
            //Get Developer Name Of Record Type And Fetch Record Only For That Record Type
            string labelName = System.Label.XfinityContractRecordType; 
            List<String> recordTypeIds = new List<String>();              
            if(!string.isBlank(labelName)){
                for(String str: labelName.split(';')){
                    recordTypeIds.add(Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get(str).getRecordTypeId());                
                }
            }       
            TestDataUtility.createCustomSettingRecords();   
            List<Contract__c> contractList = new List<Contract__c>();
            
            /*  Create Property Object */
            MDU_Property__c propertyObject = TestDataUtility.createProperty() ;
            //This is mandatory field of property  
            propertyObject.Name = 'Test Property'; 
            propertyObject.Comcast_Data_Serviced__c = 'Yes';
            database.insert(propertyObject, true);
            
            /*  Insert Contract for above created property  */
            for(Integer i = 0 ;i < 10 ;i++){
                Contract__c contractObject = TestDataUtility.createContract(propertyObject.id);
                contractObject.RecordTypeId = recordTypeIds[0];            
                contractObject.Effective_Date__c =  date.newInstance(2013, 1, 21);
                contractObject.Sub_Status__c = 'New';
                contractObject.Contract_Term__c = i+1;
                contractObject.Expiration_Date__c  =  date.newInstance(2013, 1, 21);
                contractObject.Auto_Renewal_Limit__c = 0;
                if(i == 0 ){       //For Term Unit As Months         
                    contractObject.Contract_Term_Unit__c = 'Months';
                    contractObject.Renewal_Term_Unit__c = 'Months';
                }else if(i == 1){  //For Term Unit As Years
                    contractObject.Contract_Term_Unit__c = 'Years';
                    contractObject.Auto_Renewal_Count__c = 1;
                    contractObject.Renewal_Term_Unit__c = 'Years';
                }else if(i == 2){  //For Term Unit As Years               
                    contractObject.Video__c = 'Yes';
                    contractObject.Video_Billing_Type__c = '';
                    contractObject.Contract_Term_Unit__c = 'Years';
                    contractObject.Auto_Renewal_Count__c = 1;
                    contractObject.Renewal_Term_Unit__c = 'Years';                
                }
                else{
                    contractObject.Contract_Term_Unit__c = 'Months';
                    contractObject.Auto_Renewal_Count__c = 1;
                    contractObject.Renewal_Term_Unit__c = 'Months';
                }
                contractObject.Renewal_Term__c = 1;            
                contractObject.Data__c = 'Yes';
                contractObject.Data_Billing_Type__c = 'Bulk';
                contractList.add(contractObject);                    
            } 
                       
            try{
                database.insert(contractList, true);
            }
            catch(exception e){
                System.debug('Exception :  '+e.getmessage());
            }
            
            List<Contract__c> contract = [select Expiration_Date__c  ,Property__c from  Contract__c  LIMIT 5];           
            /* execute batch class  */
            String queryString = '';
            if(System.Label.MDUContractAutoRenewBatchLabel != Null){
                queryString = System.Label.MDUContractAutoRenewBatchLabel;
            }     
            MduContractAutoRenewBatch batch = new MduContractAutoRenewBatch(queryString);           
            Id batchId = Database.executeBatch(batch);             
            Test.stopTest();
            
            List<Contract__c> tempContractList = [select Sub_Status__c, Contract_Term_Unit__c, RecordTypeId, Auto_Renewal_Count__c, Property__c from  Contract__c];       
           
        }  
        
    }
    
    /*
    * This method test contract's for auto-renew added against MDU property  
    */   
    private static testmethod void testPropertyContractWithException(){
       
        TestDataUtility.createCustomSettingRecords();
        User xcIntegrationUser;
        System.runAs(new User(Id=UserInfo.getUserId())){
            xcIntegrationUser = TestDataUtility.createXCIntegrationUser();
        }               
        System.runAs(xcIntegrationUser) {
            
            TestDataUtility.bypassValidationCS(xcIntegrationUser.Id);  
            //Get Developer Name Of Record Type And Fetch Record Only For That Record Type
            string labelName = System.Label.XfinityContractRecordType; 
            List<String> recordTypeIds = new List<String>();              
            if(!string.isBlank(labelName)){
                for(String str: labelName.split(';')){
                    recordTypeIds.add(Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get(str).getRecordTypeId());                
                }
            }                   
            List<Contract__c> contractList = new List<Contract__c>();
            
            
            try{
            //  Create Property Object 
            MDU_Property__c propertyObject = TestDataUtility.createProperty() ;
            //This is mandatory field of property  
            propertyObject.Name = 'Test Property'; 
            propertyObject.Comcast_Data_Serviced__c = 'Yes';
            database.insert(propertyObject, true);
            
            // Create Contract 
            Contract__c contractObject = TestDataUtility.createContract(propertyObject.id);
            contractObject.RecordTypeId = recordTypeIds[0];            
            contractObject.Effective_Date__c =  date.newInstance(2013, 1, 21);
            contractObject.Sub_Status__c = 'New';
            contractObject.Contract_Term__c = 1;
            contractObject.Expiration_Date__c  =  date.newInstance(2013, 1, 21);
            contractObject.Auto_Renewal_Limit__c = 0;
            contractObject.Video_Units__c = 101;
            contractObject.Video__c = 'Yes';
            contractObject.Video_Billing_Type__c = '';
            contractObject.Contract_Term_Unit__c = 'Years';
            contractObject.Auto_Renewal_Count__c = 1;
            contractObject.Renewal_Term_Unit__c = 'Years';
            contractObject.Renewal_Term__c = 1;            
            contractObject.Data__c = 'Yes';
            contractObject.Data_Billing_Type__c = 'Bulk';   
           
                 insert contractObject;
                 //database.insert(contractObject, true);  
            }
            catch(Exception e){
                System.debug('exception'+e.getMessage());
            }
            List<Contract__c> contract = [Select id,Video_Units__c,Days_to_Cancel__c from Contract__c ] ;            
            contract[0].Video_Units__c = -1;
            contract[0].Days_to_Cancel__c = -1;
            contract[0].Renewal_Term_Unit__c = 'Test';
            try{
                update contract[0];
            }
            catch(Exception e){
                System.debug('Update exception'+e.getMessage());
            }
                  
        }
        
        //List<Contract__c> contract = [Select id,Video_Units__c,Days_to_Cancel__c, Expiration_Date__c,Contract_Term__c,Contract_Term_Unit__c from Contract__c ] ;                              
        //User user = [Select Id, LastName from User where Id=:UserInfo.getUserId()]; 
         String queryString = '';
        if(System.Label.MDUContractAutoRenewBatchLabel != Null){
            queryString = System.Label.MDUContractAutoRenewBatchLabel;
        }
        Test.startTest();       
        MduContractAutoRenewBatch batch = new MduContractAutoRenewBatch(queryString);
        Id batchId = Database.executeBatch(batch);   
        
        Test.stopTest();
    }   
     
 }