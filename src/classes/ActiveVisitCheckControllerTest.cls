/**
 * Test class for ActiveVisitCheckController
 *
 * @Author Ryan Sayles <rsayles@acumensolutions.com>
 * @Date 9/29/14
 */

@isTest
private class ActiveVisitCheckControllerTest {
    
    static testMethod void otherVisitActiveTest() {
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        insert testUser;
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Store' Limit 1];
       /* Account testAccount1 = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount1;*/
        String str = 'Store';
        Account testAccount2 = StoreTestUtility.createAccount(testUser.Id);
        testAccount2.Name = 'Test Account 2';
        
        testAccount2.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId();
        testAccount2.Store_Type__c = '3PL';
        testAccount2.Store_Location__Latitude__s = 25;
        testAccount2.Store_Location__Longitude__s = 25;
        testAccount2.Region__c = 'Mile High Region';
        testAccount2.Parent_Account_Dropdown__c = 'Walmart';
        
        insert testAccount2;

      /*  Store_Visit__c storeVisit1 = StoreTestUtility.createStoreVisit(testAccount1.Id, testUser.Id, Datetime.now().addMinutes(-15));
        storeVisit1.End_Date_Time__c = null;
        insert storeVisit1; */
       /*Store_Visit__c storeVisit2 = StoreTestUtility.createStoreVisit(testAccount2.Id, testUser.Id, Datetime.now());
        storeVisit2.End_Date_Time__c = null;
        insert storeVisit2; */

        //Store_Visit__c actualVisit1 = [SELECT Id, Store_Visit_Status__c, Store__r.OwnerId, Start_Date_Time__c, End_Date_Time__c FROM Store_Visit__c WHERE Id = :storeVisit1.Id];
       // Store_Visit__c actualVisit2 = [SELECT Id, Store_Visit_Status__c, Store__r.OwnerId, Start_Date_Time__c, End_Date_Time__c FROM Store_Visit__c WHERE Id = :storeVisit2.Id];

        ApexPages.StandardController stdCon = new ApexPages.StandardController(testAccount2);

        System.runAs(testUser) {
            Test.startTest();
            Store_Visit__c  sv = new Store_Visit__c();
            sv.Store__C = testAccount2.Id;
            insert sv;
                ActiveVisitCheckController visitCheckController = new ActiveVisitCheckController(stdCon);               
                ActiveVisitCheckController.isOtherVisitActive(testAccount2.Id);
                ActiveVisitCheckController.setCompletedStatus(testAccount2.Id);
            Test.stopTest();
            //System.assertEquals(true, visitCheckController.isOtherVisitActive, 'There are two active visits');
        }
    }

    static testMethod void otherVisitNotActiveTest() {
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        insert testUser;
        String str = 'Store';
        Account testAccount = StoreTestUtility.createAccount(testUser.Id);      
        testAccount.Name = 'Test Account 2';
               
        testAccount.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId();
        testAccount.Store_Type__c = '3PL';
        testAccount.Store_Location__Latitude__s = 25;
        testAccount.Store_Location__Longitude__s = 25;
        testAccount.Region__c = 'Mile High Region';
        testAccount.Parent_Account_Dropdown__c = 'Walmart';        
        insert testAccount;        

        Store_Visit__c storeVisit1 = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        storeVisit1.End_Date_Time__c = null;
        insert storeVisit1; 
        Store_Visit__c storeVisit2 = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now().addHours(-5));
        insert storeVisit2; 

        ApexPages.StandardController stdCon = new ApexPages.StandardController(testAccount);

        System.runAs(testUser) {
            Test.startTest();
                ActiveVisitCheckController visitCheckController = new ActiveVisitCheckController(stdCon);
                try{
                    ActiveVisitCheckController.isOtherVisitActive(testAccount.Id);
                }catch(Exception e){
                    // System.Assert(e.getMessage().contains('List has no rows for assignment to SObject')); 
                     Boolean exp =  e.getMessage().contains('List has no rows for assignment to SObject') ? true : false;
                     System.debug('exp'+exp);
                     system.assertEquals(exp,true);                    
                } 
                
                ActiveVisitCheckController.setCompletedStatus(testAccount.Id);
            Test.stopTest();
            //System.assertEquals(false, visitCheckController.isOtherVisitActive, 'There are two active visits');
        }
    }
    
}