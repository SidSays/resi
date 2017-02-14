@isTest
public Class IndirectStoreVisitWrapperTest {
    
    @isTest
    public static void CreateTestData(){
        String StoreActivityRecType = Schema.SObjectType.Store_Activity__c.getRecordTypeInfosByName().get('Target Rep Review').getRecordTypeId();
        //Create Trigger Settings
        WorkTestDataUtility.createCustomSettingRecords();
        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;
        
        //Create User
        Profile p = [SELECT Id FROM Profile WHERE Name='Retail Sales Rep']; 
        UserRole role=[SELECT Id, DeveloperName, Name FROM UserRole WHERE DeveloperName='Xfinity_Sales_Rep'];

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.UserRole = role;
        insert testUser;
        
        //Create Store and a Contact
        Account testAccount = new Account ();
        testAccount.Name = 'Test Account';
        testAccount.OwnerId = testUser.id;
        testAccount.Store_Type__c = 'Best Buy';
        testAccount.BillingStreet ='TestStreet';
        testAccount.BillingCity = 'TestCity';
        testAccount.BillingState ='TestState'; 
        testAccount.BillingPostalCode= '12345'; 
        testAccount.BillingCountry ='TestCountry';
        insert testAccount;
        
        Contact testContact = StoreTestUtility.createContact(testAccount.Id);
        insert testContact;
        
        //Create Store Visit with a Activity Category
        Store_Visit_Activity_Category__c testActivityCategory = StoreTestUtility.createActivityCategory('Kiosk', 'Xfinity_Sales_Rep');
        insert testActivityCategory;
        
        List<Store_Visit_Activity_Category__c> testCategory = [SELECT Id, Number_Required__c,Record_Type_Name__c,
                                                        Store_Activity_Category__c, Email_Template__c,
                                                        Send_Mail_Check_Field__c, Store_Type__c,Record_Type_Id__c,New_Records__c 
                                                        FROM Store_Visit_Activity_Category__c
                                                        WHERE Id = :testActivityCategory.id];

        Store_Visit__c storeVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        storeVisit.End_Date_Time__c = null;
        storeVisit.Visit_Type__c = 'store visit';
        insert storeVisit;
                
        // Create Store Activity
        Store_Activity__c sA1 = StoreTestUtility.createStoreActivity(storeVisit.Id);    
        sA1.Who_did_you_meet_with__c = testContact.Id;
        sA1.What_is_the_store_s_focus_this_month__c = 'Accessories';
        sA1.Engagement_level_of_manager__c = '3';
        sA1.What_did_you_review_with_the_manager__c = 'Commissions, Incentives';
        sA1.RecordTypeId=StoreActivityRecType;
        insert sA1;
        
        storeVisit.End_Date_Time__c = storeVisit.Start_Date_Time__c.addHours(2);
        update storeVisit;
        
        System.runAs(testUser){
        IndirectStoreVisitWrapper.getStoreVisits(testAccount.Id);
        IndirectStoreVisitWrapper.getActivityDetails(testActivityCategory.Id,storeVisit.Id);
        }
    }
}