/**
* This class contains unit tests for validating the MDUAccountDeleteBatchSchedule call.
* Created: 29-Jan-2015
* Date : 16 January 2015
* Author : Sagar Gurav
*/
@isTest
private class MDUAccountDeleteBatchTest {
    
    private static final string RECORD_TYPE_SEPERATION = ';';
    
    /*
     Create Account to Test
    */ 
    public static Account createTestAccountData(){
        
        List<Id> recordTypeIds = new List<Id>();      
        String labelName = System.Label.XfinityAccountRecordType;  
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(RECORD_TYPE_SEPERATION)){
                recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }    
        
        Account accountObject = TestDataUtility.createAccount() ;
        accountObject.Is_Parent_Organization__c = false;
        accountObject.RecordTypeId = recordTypeIds[0];        
        return accountObject;
    }
    
    /* 
      Test deletion of account 
    */
    public static testMethod void accountDeleetTest() {
       
        TestDataUtility.createCustomSettingRecords();
    
        /* Create Account record */  
        List<Account> accList = new List<Account>();
        Account accountObject = createTestAccountData();
        accList.add(accountObject);            
        Account accountObject1 = createTestAccountData();
        accList.add(accountObject1);
        Account accountObject2 = createTestAccountData();
        accList.add(accountObject2);
        Account accountObject3 = createTestAccountData();
        accList.add(accountObject3);
        
        Database.insert(accList);
    
        User u = TestDataUtility.createXCIntegrationUser();
        
        System.runAs(u){ 
            List<Opportunity> oppList = TestDataUtility.createOpportunity(1);       
            oppList[0].AccountId = accList[0].Id;
            Database.insert(oppList[0]);
        }
        
        /* Create Property Record with associated account */
        List<MDU_Property__c> propertyList = new List<MDU_Property__c>();
        for(Integer i = 0;i < 3;i ++ ){
            MDU_Property__c MDUprop1 = new MDU_Property__c();
            MDUprop1.Name = 'Test property'+i;
            MDUprop1.Address__c = 'test address'+i;
            MDUprop1.City__c = 'test city';
            MDUprop1.MDU_State__c = 'Alaska';
            MDUprop1.Corporate__c = 'Comcast Cable';
            MDUprop1.Property_Division__c = 'Central';
            MDUprop1.Property_Region__c = 'Big South';
            MDUprop1.Property_Area__c = 'Delta';
            MDUprop1.system__c = 'Mobile';
            MDUprop1.Industry_Type__c = 'Education';
            MDUprop1.Number_of_Units__c = 5;
            MDUprop1.Comcast_Video_Serviced__c = 'No';
            MDUprop1.Comcast_Voice_Serviced__c = 'No';
            MDUprop1.Comcast_Data_Serviced__c = 'No';
            if(i == 0){
                MDUprop1.Owner_Account__c = accList[i].Id;
                propertyList.add(MDUprop1);
            }else if(i == 1){
                MDUprop1.Management_Company__c = accList[i].Id;
                propertyList.add(MDUprop1);
            }else if(i == 2){
                MDUprop1.Developer__c = accList[i].Id;
                propertyList.add(MDUprop1);
            }
        }
       
        Database.insert(propertyList); 
        
        Contract__c contractObj = new Contract__c();       
        contractObj.Property__c = propertyList[0].id;
        contractObj.Account_Name__c = accList[0].id;
        Database.insert(contractObj);

        Test.startTest();
        //Account to delete when not link with Opportunity, contract and property 
        Database.executebatch(new MDUAccountDeleteBatch());
        
        Test.stopTest();
        
        // accountObject3 will be deleted as its not associated with any object
        List<Account> accountList = [Select id FROM Account where Id IN : accList];
        System.assertEquals(accountList.size(), 3);  
    }
    
    /*
    * This method test account delete for negative scenario.
    */   
    private static testmethod void accountDeleteNegativeTest(){
        
        List<Account> accList = new List<Account>();
        TestDataUtility.createCustomSettingRecords(); 
        // create Account       
        Account accountObject1 = createTestAccountData();
        Account accountObject2 = createTestAccountData();
        accList.add(accountObject1);
        accList.add(accountObject2);
        
        
        //Account Executive Profile doesn't have Delete permission on Account
        User u = TestDataUtility.createXCAccountExecUser();
        
        Test.startTest();
            system.runAs(u){  
                database.insert(accList);
                //Account to delete when not link with Opportunity, contract and property 
                Database.executebatch(new MDUAccountDeleteBatch()); 
            }
        Test.stopTest();

    }   

}