/**
* This class contains unit tests for MDUPropertyRiskStatusAutoSetBatch 
* Created: 29-Jan-2015
* Date : 16 January 2015
* Author : Sagar Gurav
*/
@isTest
private class MDUPropertyRiskStatusAutoSetBatchTest {

    private static final string RECORD_TYPE_SEPERATION = ';';
        
    // Create Property Object that will use in Test class
    private static MDU_Property__c createTestPropertyData(){
       
        String sDeveloperName = System.Label.XfinityPropertyRecordType;  
        String labelName = System.Label.XfinityPropertyRecordType;  
        List<String> recordTypeIds = new List<String>();
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(RECORD_TYPE_SEPERATION)){
                recordTypeIds.add(Schema.SObjectType.MDU_Property__c.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }         
        MDU_Property__c propertyObject = TestDataUtility.createProperty() ;
        propertyObject.RecordTypeId = recordTypeIds[0]; 
        propertyObject.PostalCode__c = '10509';  
        propertyObject.Bulk_Status__c = 'Not Serviced';       
        propertyObject.Industry_Type__c = 'Commercial';
        propertyObject.Property_Type__c = 'Commercial';
        propertyObject.Contracting_Org_Type__c = 'Developer';                   
        propertyObject.Name = 'Test Property';  
        return propertyObject;
    } 
    
    private static testMethod void propertyRiskStatusAutoSetBatchTestWithMDUBatchSwitchTrue()
    {
        Variable_Setting__c variableSetting = new Variable_Setting__c(Name='MDUBatchSwitch');
        variableSetting.Value__c = 'True';
        insert variableSetting;
        propertyRiskStatusAutoSetBatchTest();
    }
    
    private static testMethod void propertyRiskStatusAutoSetBatchTestWithMDUBatchSwitchFalse()
    {
        Variable_Setting__c variableSetting = new Variable_Setting__c(Name='MDUBatchSwitch');
        variableSetting.Value__c = 'False';
        insert variableSetting;
        propertyRiskStatusAutoSetBatchTest();
    }
    
    
    /*
    * This method tests the property risk status 
    */  
    private static testMethod void propertyRiskStatusAutoSetBatchTest() {
        
        List<String> recordTypeIdSet = new List<String>();
        String labelName = System.Label.XfinityAccountRecordType;  
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(RECORD_TYPE_SEPERATION)){
                recordTypeIdSet.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }   
                 
        /* Set Workflow Setting */      
        WorkflowSetting__c workflowSetting = new WorkflowSetting__c(Name='Test2');
        workflowSetting.Disable_Workflow_Rule__c = true;
        insert workflowSetting;
        
        User user = [Select Id from User where Id=:UserInfo.getUserId()];   
        TestDataUtility.createCustomSettingRecords();     
        Account acc = TestDataUtility.createAccount();
        acc.Name = 'test developer account';
        acc.recordtypeid = recordTypeIdSet[0]; 
        Database.insert(acc, false);
            
        System.runAs(user){ 
                                     
            List<Contract__c> contractObj = new List<Contract__c>();   
            List<MDU_Property__c> propertyList = new List<MDU_Property__c>();
            
            MDU_Property__c property1 = TestDataUtility.createProperty();
            property1.Industry_Type__c = 'Commercial';
            property1.Property_Type__c = 'Commercial';
            property1.Contracting_Org_Type__c = 'Developer';   
            property1.Number_of_Units__c = 5;
            property1.Comcast_Data_Serviced__c = 'Yes';
            property1.Developer__c = acc.id;
            property1.Video_Billing_Type__c = 'Bulk';
            propertyList.add(property1);
            
            MDU_Property__c property2 = TestDataUtility.createProperty();
            property2.Number_of_Units__c = 4;
            property2.Comcast_Video_Serviced__c = 'Yes';
            property2.Developer__c = acc.id;
            property2.Video_Billing_Type__c = 'Retail';
            property2.Data_Billing_Type__c = 'Retail';
            property2.Voice_Billing_Type__c = 'Retail';
            propertyList.add(property2);
            
            //Create Property Without Any Video/Data/Voice Service
            MDU_Property__c propertyObject = TestDataUtility.createProperty();  
            propertyObject.Comcast_Video_Serviced__c = 'No';
            propertyObject.Comcast_Voice_Serviced__c = 'No';
            propertyObject.Comcast_Data_Serviced__c = 'No';
            propertyList.add(propertyObject);           
            
            //Create Property With Type as Retails
            MDU_Property__c retailPropertyObject1 = TestDataUtility.createProperty(); 
            retailPropertyObject1.Comcast_Video_Serviced__c = 'Yes';
            retailPropertyObject1.Video_Billing_Type__c = 'Retail';
            propertyList.add(retailPropertyObject1);
            
            //Create Property With Type as Retails
            MDU_Property__c retailPropertyObject3 = TestDataUtility.createProperty(); 
            retailPropertyObject3.Comcast_Video_Serviced__c = 'Yes';
            retailPropertyObject3.Video_Billing_Type__c = 'Retail';
            propertyList.add(retailPropertyObject3);
            
            MDU_Property__c retailPropertyObject4 = TestDataUtility.createProperty(); 
            retailPropertyObject4.Comcast_Video_Serviced__c = 'Yes';
            retailPropertyObject4.Video_Billing_Type__c = 'Retail';
            propertyList.add(retailPropertyObject4);
            
            MDU_Property__c bulkProperty = TestDataUtility.createProperty();
            bulkProperty.Industry_Type__c = 'Commercial';
            bulkProperty.Property_Type__c = 'Commercial';
            bulkProperty.Contracting_Org_Type__c = 'Developer'; 
            bulkProperty.Number_of_Units__c = 5;
            bulkProperty.Comcast_Data_Serviced__c = 'Yes';
            bulkProperty.Developer__c = acc.id;
            bulkProperty.Video_Billing_Type__c = 'Bulk';
            propertyList.add(bulkProperty);
            
            MDU_Property__c retailProperty = TestDataUtility.createProperty();
            retailProperty.Industry_Type__c = 'Commercial';
            retailProperty.Property_Type__c = 'Commercial';
            retailProperty.Contracting_Org_Type__c = 'Developer'; 
            retailProperty.Number_of_Units__c = 5;
            retailProperty.Comcast_Data_Serviced__c = 'Yes';
            retailProperty.Developer__c = acc.id;
            retailProperty.Video_Billing_Type__c = 'Retail';
            retailProperty.Data_Billing_Type__c = 'Retail';
            retailProperty.Voice_Billing_Type__c = 'Retail';
            propertyList.add(retailProperty);
            
            Database.insert(propertyList, false);

            //Mdu_Property__c proper = [select id, recordTypeId from Mdu_Property__c where id = : propertyList[0].id];          
            Contract__c con = TestDataUtility.createContract(propertyList[0].Id);            
            con.Account_Name__c = acc.id;
            con.Video_Billing_Type__c = 'Bulk';
            con.Initial_Effective_Date__c =  date.newInstance(2016, 2, 23);           
            con.Effective_Date__c =  date.newInstance(2018, 1, 28);
            con.Contract_Status__c = 'Active';
            con.Contract_Term__c = 9;
            con.Contract_Term_Unit__c = 'Months';
            con.Expiration_Date__c  =  date.newInstance(2016, 8, 28);
            contractObj.add(con);
            
            Contract__c con1 = TestDataUtility.createContract(propertyList[0].id);          
            con1.Account_Name__c = acc.id;
            con1.Video_Billing_Type__c = 'Bulk';
            con1.Initial_Effective_Date__c =  date.newInstance(2017, 1, 23);
            con1.Sub_Status__c = 'AutoRenewed';
            con1.Effective_Date__c =  date.newInstance(2018, 1, 28);
            con1.Contract_Status__c = 'Active';
            con1.Expiration_Date__c  =  date.newInstance(2016, 8, 28);
            contractObj.add(con1);
            
            Contract__c con2 = TestDataUtility.createContract(propertyList[0].id);        
            con2.Account_Name__c = acc.id;
            con2.Video_Billing_Type__c = 'Retail';
            con2.Effective_Date__c   =  date.newInstance(2017, 1, 28);
            con2.Contract_Status__c = 'Active';
            con2.Expiration_Date__c  =  date.newInstance(2016, 8, 28);
            contractObj.add(con2);
            
            Contract__c con3 = TestDataUtility.createContract(propertyList[0].id);         
            con3.Account_Name__c = acc.id;
            con3.Video_Billing_Type__c = 'Retail';
            con3.Effective_Date__c  =  date.newInstance(2014, 1, 28);
            con3.Contract_Status__c = 'Active';
            con3.Expiration_Date__c  =  date.newInstance(2016, 8, 28);
            contractObj.add(con3);
            
            Contract__c con4 = TestDataUtility.createContract(propertyList[0].id);         
            con4.Account_Name__c = acc.id;
            con4.Video_Billing_Type__c = 'Retail';
            con4.Effective_Date__c  =  date.newInstance(2016, 1, 28);
            con4.Contract_Status__c = 'Active';
            con4.Expiration_Date__c  =  date.newInstance(2016, 8, 28);
            contractObj.add(con4);
            
            Contract__c con5 = TestDataUtility.createContract(propertyList[0].id);         
            con5.Account_Name__c = acc.id;
            con5.Video_Billing_Type__c = 'Retail';
            con5.Effective_Date__c  =  date.newInstance(2015, 8, 28);
            con5.Contract_Status__c = 'Active';
            con5.Expiration_Date__c  =  date.newInstance(2016, 8, 28);
            contractObj.add(con5);
            
            // null contract list since no expiration date
            Contract__c con66 = TestDataUtility.createContract(propertyList[0].id);           
            con66.Account_Name__c = acc.id;
            con66.Video_Billing_Type__c = 'Bulk';
            con66.Initial_Effective_Date__c =  date.newInstance(2016, 2, 23);
            con66.Effective_Date__c =  date.newInstance(2018, 1, 28);
            con66.Contract_Status__c = 'Active';
            con66.Contract_Term__c = 3;
            con66.Contract_Term_Unit__c = 'Months';
            con66.Expiration_Date__c  =  date.newInstance(2016, 8, 28);
            contractObj.add(con66);           
            
            Contract__c  con6 = TestDataUtility.createContract(propertyList[1].id);           
            con6.Account_Name__c = acc.id;
            con6.Video_Billing_Type__c = 'Retail';
            con6.Effective_Date__c =  date.newInstance(2014, 1, 28);
            con6.Contract_Status__c = 'Archived';
            con6.Life_of_Franchise__c = true;
            con6.Expiration_Date__c  =  date.newInstance(2015, 1, 28);
            contractObj.add(con6);
                                   
            Contract__c  con7 = TestDataUtility.createContract(propertyList[1].id);           
            con7.Account_Name__c = acc.id;
            con7.Video_Billing_Type__c = 'Retail';
            con7.Effective_Date__c =  date.newInstance(2016, 1, 22);
            con7.Initial_Effective_Date__c =  date.newInstance(2019, 1, 22);
            con7.Contract_Status__c = 'Active';
            con7.Life_of_Franchise__c = true;
            con7.Expiration_Date__c  =  date.newInstance(2016, 8, 28);
            contractObj.add(con7);          
            
            Contract__c contractTemp = TestDataUtility.createContract(propertyList[2].id);
            contractTemp.Video_Billing_Type__c = 'Retail';
            contractObj.add(contractTemp);
            
            //Retails Contract 1
            Contract__c retailContractTemp1 = TestDataUtility.createContract(propertyList[3].id);
            retailContractTemp1.Video_Billing_Type__c = 'Retail';
            retailContractTemp1.Account_Name__c = acc.id;
            retailContractTemp1.Effective_Date__c =  date.newInstance(2004, 3, 28);
            contractObj.add(retailContractTemp1);
            
            //Retails Contract 2 With Highest Effective Date
            Contract__c retailHighEffDateContractTemp1 = TestDataUtility.createContract(propertyList[3].id);
            retailHighEffDateContractTemp1.Video_Billing_Type__c = 'Retail';
            retailHighEffDateContractTemp1.Account_Name__c = acc.id;
            retailHighEffDateContractTemp1.Effective_Date__c =  date.newInstance(2016, 6, 28);
            contractObj.add(retailHighEffDateContractTemp1);

            //Retails Contract 2 With Highest Effective Date
            Contract__c retailHighEffDateContractTemp3 = TestDataUtility.createContract(propertyList[4].id);
            retailHighEffDateContractTemp3.Video_Billing_Type__c = 'Retail';
            retailHighEffDateContractTemp3.Account_Name__c = acc.id;
            retailHighEffDateContractTemp3.Effective_Date__c =  date.newInstance(2015, 7, 28);
            contractObj.add(retailHighEffDateContractTemp3);
            
            Contract__c bulkPropContract = TestDataUtility.createContract(bulkProperty.Id);            
            bulkPropContract.Account_Name__c = acc.id;
            bulkPropContract.Video_Billing_Type__c = 'Bulk';
            bulkPropContract.Initial_Effective_Date__c =  date.newInstance(2016, 2, 23);           
            bulkPropContract.Effective_Date__c =  date.newInstance(2018, 1, 28);
            bulkPropContract.Contract_Status__c = 'Active';
            bulkPropContract.Contract_Term__c = 9;
            bulkPropContract.Contract_Term_Unit__c = 'Months';
            bulkPropContract.Expiration_Date__c  =  date.newInstance(2016, 8, 28);
            contractObj.add(bulkPropContract);
            
            Contract__c bulkPropContract1 = TestDataUtility.createContract(bulkProperty.id);          
            bulkPropContract1.Account_Name__c = acc.id;
            bulkPropContract1.Video_Billing_Type__c = 'Bulk';
            bulkPropContract1.Initial_Effective_Date__c =  date.newInstance(2018, 1, 23);
            bulkPropContract1.Sub_Status__c = 'AutoRenewed';
            bulkPropContract1.Effective_Date__c =  date.newInstance(2018, 1, 28);
            bulkPropContract1.Contract_Status__c = 'Active';
            bulkPropContract1.Expiration_Date__c  =  date.newInstance(2016, 8, 28);
            contractObj.add(bulkPropContract1);
            
            Contract__c bulkPropContract2 = TestDataUtility.createContract(bulkProperty.id);         
            bulkPropContract2.Account_Name__c = acc.id;
            bulkPropContract2.Video_Billing_Type__c = 'Retail';
            bulkPropContract2.Effective_Date__c  =  date.newInstance(2015, 8, 28);
            bulkPropContract2.Contract_Status__c = 'Active';
            bulkPropContract2.Expiration_Date__c  =  date.newInstance(2016, 8, 28);
            contractObj.add(bulkPropContract2);
            
            Contract__c retailPropContract = TestDataUtility.createContract(retailProperty.Id);            
            retailPropContract.Account_Name__c = acc.id;
            retailPropContract.Video_Billing_Type__c = 'Retail';
            retailPropContract.Initial_Effective_Date__c =  date.newInstance(2006, 2, 23);           
            retailPropContract.Effective_Date__c =  date.newInstance(2008, 1, 28);
            retailPropContract.Contract_Status__c = 'Active';
            retailPropContract.Contract_Term__c = 9;
            retailPropContract.Contract_Term_Unit__c = 'Months';
            retailPropContract.Expiration_Date__c  =  date.newInstance(2006, 8, 28);
            contractObj.add(retailPropContract);
            
            Contract__c retailPropContract1 = TestDataUtility.createContract(retailProperty.id);          
            retailPropContract1.Account_Name__c = acc.id;
            retailPropContract1.Video_Billing_Type__c = 'Retail';
            retailPropContract1.Initial_Effective_Date__c =  date.newInstance(2008, 1, 23);
            retailPropContract1.Sub_Status__c = 'AutoRenewed';
            retailPropContract1.Effective_Date__c =  date.newInstance(2008, 1, 28);
            retailPropContract1.Contract_Status__c = 'Active';
            retailPropContract1.Expiration_Date__c  =  date.newInstance(2006, 8, 28);
            contractObj.add(retailPropContract1);
 
            
            Contract__c retailPropContract2 = TestDataUtility.createContract(retailProperty.id);         
            retailPropContract2.Account_Name__c = acc.id;
            retailPropContract2.Video_Billing_Type__c = 'Retail';
            retailPropContract2.Effective_Date__c  =  date.newInstance(2005, 8, 28);
            retailPropContract2.Contract_Status__c = 'Active';
            retailPropContract2.Expiration_Date__c  =  date.newInstance(2006, 8, 28);
            contractObj.add(retailPropContract2);        
            
              
            
            // CReate Contracts
            Database.insert (contractObj);
                            
            Test.startTest();
                String queryString = '';
                if(System.Label.MDUPropertyRiskStatusAutoSetBatchQueryLabel != Null){
                    queryString = System.Label.MDUPropertyRiskStatusAutoSetBatchQueryLabel;
                }                           
                database.executebatch(new MDUPropertyRiskStatusAutoSetBatch(queryString), 50);
                
            Test.stopTest(); 
        }
    }
    
    private static testMethod void propertyRiskStatusAutoSetBatchTest2WithMDUBatchSwitchTrue()
    {
        Variable_Setting__c variableSetting = new Variable_Setting__c(Name='MDUBatchSwitch');
        variableSetting.Value__c = 'True';
        insert variableSetting;
        propertyRiskStatusAutoSetBatchTest2();
    }
    
     private static testMethod void propertyRiskStatusAutoSetBatchTest2WithMDUBatchSwitchFalse()
    {
        Variable_Setting__c variableSetting = new Variable_Setting__c(Name='MDUBatchSwitch');
        variableSetting.Value__c = 'False';
        insert variableSetting;
        propertyRiskStatusAutoSetBatchTest2();
    }
    
    /*
    * This method test property risk status 
    */   
    private static testmethod void propertyRiskStatusAutoSetBatchTest2(){
            
        List<String> recordTypeIdSet = new List<String>();
        String labelName = System.Label.XfinityAccountRecordType;  
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(RECORD_TYPE_SEPERATION)){
                recordTypeIdSet.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }
        
        List<MDU_Property__c> propertyList = new List<MDU_Property__c>();        
        TestDataUtility.createCustomSettingRecords();     
        Account acc = TestDataUtility.createAccount();
        acc.Name = 'test developer account';
        acc.recordtypeid = recordTypeIdSet[0]; 
        Database.insert(acc, false);
        
        /* Property 1 with contract  */
        MDU_Property__c propertyWithContract = TestDataUtility.createProperty(); 
        propertyWithContract.Comcast_Video_Serviced__c = 'Yes';
        propertyWithContract.Video_Billing_Type__c = 'Bulk';
        propertyList.add(propertyWithContract);
        
        /* Property 1 with contract */
        MDU_Property__c propertyWithContract2 = TestDataUtility.createProperty(); 
        propertyWithContract2.Comcast_Video_Serviced__c = 'Yes';
        propertyWithContract2.Video_Billing_Type__c = 'Bulk';
        propertyList.add(propertyWithContract2);
        
        /* Property 1 with contract  */
        MDU_Property__c propertyWithContract3 = TestDataUtility.createProperty(); 
        propertyWithContract3.Comcast_Video_Serviced__c = 'Yes';
        propertyWithContract3.Video_Billing_Type__c = 'Retail';
        propertyList.add(propertyWithContract3);
                    
        Database.insert(propertyList, false);
        
        List<Contract__c> contractList = new List<Contract__c>();
        
        Contract__c bulkContractTemp2 = TestDataUtility.createContract(propertyList[0].id);
        bulkContractTemp2.Sub_Status__c = 'New';
        bulkContractTemp2.Video__c = 'Yes';
        bulkContractTemp2.Video_Billing_Type__c = 'Bulk';
        bulkContractTemp2.Account_Name__c = acc.id;
        bulkContractTemp2.Effective_Date__c =  date.newInstance(2015, 5, 19);
        bulkContractTemp2.Contract_Term__c = 9;
        bulkContractTemp2.Contract_Term_Unit__c = 'Months';
        contractList.add(bulkContractTemp2);
        
        Contract__c bulkContractTemp3 = TestDataUtility.createContract(propertyList[1].id);
        bulkContractTemp3.Sub_Status__c = 'New';
        bulkContractTemp3.Video__c = 'Yes';
        bulkContractTemp3.Video_Billing_Type__c = 'Bulk';
        bulkContractTemp3.Account_Name__c = acc.id;
        bulkContractTemp3.Effective_Date__c =  date.newInstance(2015, 5, 19);
        bulkContractTemp3.Contract_Term__c = 3;
        bulkContractTemp3.Contract_Term_Unit__c = 'Months';
        contractList.add(bulkContractTemp3);
        
        Contract__c bulkContractTemp4 = TestDataUtility.createContract(propertyList[1].id);
        bulkContractTemp4.Sub_Status__c = 'New';
        bulkContractTemp4.Voice__c = 'Yes';
        bulkContractTemp4.Voice_Billing_Type__c = 'Bulk';
        bulkContractTemp4.Account_Name__c = acc.id;
        bulkContractTemp4.Effective_Date__c =  date.newInstance(2015, 6, 19);
        bulkContractTemp4.Contract_Term__c = 3;
        bulkContractTemp4.Contract_Term_Unit__c = 'Months';
        contractList.add(bulkContractTemp4);
                    
        Contract__c retailContractTemp2 = TestDataUtility.createContract(propertyList[2].id);
        retailContractTemp2.Sub_Status__c = 'New';
        retailContractTemp2.Video__c = 'Yes';
        retailContractTemp2.Video_Billing_Type__c = 'Retail';
        retailContractTemp2.Account_Name__c = acc.id;
        retailContractTemp2.Effective_Date__c =  date.newInstance(2015, 5, 19);
        retailContractTemp2.Contract_Term__c = 9;
        retailContractTemp2.Contract_Term_Unit__c = 'Months';
        contractList.add(retailContractTemp2);
        
        Contract__c bulkContractTemp5 = TestDataUtility.createContract(propertyList[2].id);
        bulkContractTemp5.Sub_Status__c = 'New';
        bulkContractTemp5.Voice__c = 'Yes';
        bulkContractTemp5.Voice_Billing_Type__c = 'Bulk';
        bulkContractTemp5.Account_Name__c = acc.id;
        bulkContractTemp5.Effective_Date__c =  date.newInstance(2015, 6, 1);
        bulkContractTemp5.Contract_Term__c = 13;
        bulkContractTemp5.Contract_Term_Unit__c = 'Months';
        contractList.add(bulkContractTemp5);
        
        // Create Contracts
        Database.insert(contractList, false);
                    
        Test.startTest(); 
            String queryString = '';
            if(System.Label.MDUPropertyRiskStatusAutoSetBatchQueryLabel != Null){
                queryString = System.Label.MDUPropertyRiskStatusAutoSetBatchQueryLabel;
            }                           
            database.executebatch(new MDUPropertyRiskStatusAutoSetBatch(queryString), 50);                     
        Test.stopTest();
        
    }
    
    /*
    * This method test property risk status batch when any error come during batch process
    */   
    private static testmethod void testPropertyRiskWithException(){
                
        User xcIntegrationUser;
        TestDataUtility.createCustomSettingRecords();
        System.runAs(new User(Id=UserInfo.getUserId())){
            xcIntegrationUser = TestDataUtility.createXCIntegrationUser();
        }   
                
        System.runAs(xcIntegrationUser) {            
            TestDataUtility.bypassValidationCS(xcIntegrationUser.Id);  
            MDU_Property__c propertyObject = createTestPropertyData();
            propertyObject.Comcast_Video_Serviced__c = 'No';
            propertyObject.Comcast_Data_Serviced__c = 'No';
            propertyObject.Comcast_Voice_Serviced__c = 'No';
            propertyObject.Industry_Type__c = 'Healthcare'; 
            propertyObject.Contracting_Org_Type__c = 'owner'; 
            propertyObject.PostalCode__c = '12';
            insert propertyObject;                  
        }
       
        Test.startTest(); 
            String queryString = '';
            if(System.Label.MDUPropertyRiskStatusAutoSetBatchQueryLabel != Null){
                queryString = System.Label.MDUPropertyRiskStatusAutoSetBatchQueryLabel;
            }                           
            database.executebatch(new MDUPropertyRiskStatusAutoSetBatch(queryString), 50);                                      
        Test.stopTest();
    }  
      
}