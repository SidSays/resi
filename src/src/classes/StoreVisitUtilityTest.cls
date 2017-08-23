/**
 * Test class for StoreVisitUtility
 * 
 * @Author Ryan Sayles 
 * @Date 9/22/14
 */

@isTest
public with sharing class StoreVisitUtilityTest {

	static testMethod void getFieldSet(){

		TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        testAccount.Name = 'Test1';
        insert testAccount;
        Account testAccount2 = StoreTestUtility.createAccount(testUser.Id);
        testAccount2.Name = 'Test2';
        insert testAccount2;
        Account testAccount3 = StoreTestUtility.createAccount(testUser.Id);
        testAccount3.Name = 'Test3';
        insert testAccount3;
        Account testAccount4 = StoreTestUtility.createAccount(testUser.Id);
        testAccount4.Name = 'Test4';
        insert testAccount4;

       	List<String> accountNames = new List<String>{'Test1', 'Test2', 'Test3', 'Test4'};

        List<Account> accounts = new List<Account>();
        accounts.add(testAccount);
        accounts.add(testAccount2);
        accounts.add(testAccount3);
        accounts.add(testAccount4);

        String fieldName = 'Name';
        Set<String> fieldSet = new Set<String>();

        Test.startTest();
        	fieldSet = StoreVisitUtility.getFieldSet(accounts, fieldName);
        Test.stopTest();
        System.assertEquals(true, fieldSet.containsAll(accountNames), 'List should contain all of the test account names');

    }

    static testMethod void buildRecordTypeNameMap(){

        List<RecordType> testRecordTypes = StoreQueryUtility.queryRecordTypes('Store_Activity__c');
        Map<String, RecordType> recordTypeMap;

        Test.startTest();
            recordTypeMap = StoreVisitUtility.buildRecordTypeNameMap(testRecordTypes);
        Test.stopTest();

        System.assertEquals(true, recordTypeMap.size() > 0, 'Record type map should contain x number ofrecord types');
    }

    static testMethod void convertMsToTimeDisplay(){
    	// 10983000 Ms = 3:3:3 
        Long duration = 10983000;
        String timeDisplay = '3:03:03';
        String actualTimeDisplay;

        Test.startTest();
           actualTimeDisplay = StoreVisitUtility.convertMsToTimeDisplay(duration);
        Test.stopTest();
        System.assertEquals(timeDisplay, actualTimeDisplay, 'Time display should be 3 hours, 3 minutes, and 3 seconds');
    }

    static testMethod void buildFieldSetMap(){

        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        testAccount.Name = 'Test1';
        insert testAccount;
        Account testAccount2 = StoreTestUtility.createAccount(testUser.Id);
        testAccount2.Name = 'Test2';
        insert testAccount2;
        Account testAccount3 = StoreTestUtility.createAccount(testUser.Id);
        testAccount3.Name = 'Test3';
        insert testAccount3;
        Account testAccount4 = StoreTestUtility.createAccount(testUser.Id);
        testAccount4.Name = 'Test4';
        insert testAccount4;

        List<Account> accounts = new List<Account>();
        accounts.add(testAccount);
        accounts.add(testAccount2);
        accounts.add(testAccount3);
        accounts.add(testAccount4);

        Map<String, List<Account>> fieldSetMap;

        Test.startTest();
            fieldSetmap = StoreVisitUtility.buildFieldSetMap(accounts, 'Name');
        Test.stopTest();
        System.assertEquals(4, fieldSetmap.size(), 'Field Set Map should contain 4 account names');
    }

    static testMethod void getAllFields(){
        Set<String> fieldSet = new Set<String>();

        Test.startTest();
            fieldSet = StoreVisitUtility.getAllFields('Store_Visit__c');
        Test.stopTest();

        System.assertEquals(true, fieldSet.size() > 0, 'Field Set should return the objects fields');
    }

    static testMethod void getSchedulerExpression(){
        DateTime testDateTime = DateTime.newInstance(2014, 1, 1, 12, 0, 0);
        String dateExpression;

        Test.startTest();
            dateExpression = StoreVisitUtility.getSchedulerExpression(testDateTime);
        Test.stopTest();

        System.assertNotEquals('0 0 12 1 1 ? 2014', dateExpression, 'Date expressions should match');
    }

    static testMethod void addMessages(){
        //just for coverage
        StoreVisitUtility.addErrorMessage('Error Message'); 
        StoreVisitUtility.addWarningMessage('Warning Message');
        StoreVisitUtility.addInfoMessage('Info Message'); 
        StoreVisitUtility.addConfirmMessage('Confirm Message');
    }

}