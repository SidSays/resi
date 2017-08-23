@isTest
Private class ContactTriggerControllerTest {
             
        private static testMethod void testContactTriggerController(){ 
        
            TestDataUtility.createCustomSettingRecords();
            
            List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c >();
            TriggerSettings__c contactTrigger= new TriggerSettings__c();
            contactTrigger.Name = 'contactTrigger';
            contactTrigger.isActive__c = True;
            triggerSettingsList.add(contactTrigger);
            Database.insert(triggerSettingsList);
         
                           
            //inserting an Account
            Account ac = new Account();
            ac.Name = 'testName';
            Insert ac;
            
            //Inserting a Contact 
            List<Contact> conList = new List<Contact>();      
            contact con = new contact();
            con.LastName = 'TestName';
            con.AccountId = ac.id;
            con.Birthdate__c = '12/12';
            conList.add(con);
            //Database.insert(conList);
 
                 
            contact con1 = new contact();
            con1.LastName = 'TestName';
            con1.AccountId = ac.id;
            con1.Birthdate__c = '1/1';
            conList.add(con1);
            Database.insert(conList);
}
 /*
        private static User getRunningUser() {
        if ( runningUser == null ) {
            runningUser = [select Id from User where Id = :UserInfo.getUserId() limit 1];
        }
        return runningUser;
       }
    
    /*
    *   Method to validate Primary contact on Account
    
    public static testMethod void testPrimaryContact(){
        
        String labelName = System.Label.XfinityContactRecordType;  
        List<String> recordTypeSet = new List<String>();
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(LABEL_NAME_SPLIT)){
                recordTypeSet.add(Schema.SObjectType.Contact.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }    
        
        TestDataUtility.createCustomSettingRecords(); //Setting custom Settings Data
        Account testAccount = TestDataUtility.createAccount();
        insert testAccount;
        
        List<Contact> testContacts = TestDataUtility.createContactRecord(1);
        testContacts[0].Primary_Contact__c = false;
        testContacts[0].recordTypeId = recordTypeSet[0];
        
        Test.startTest();
        insert testContacts; //Testing insert of Contact 
        
        testContacts[0].Primary_Contact__c = true;
        update testContacts;   //Testing update of contact as Primary contact to an account
        
        List<Contact> testContacts2 = TestDataUtility.createContactRecord(1);
        testContacts2[0].AccountId =testContacts[0].AccountId;
        testContacts2[0].recordTypeId = recordTypeSet[0];
        testContacts2[0].Primary_Contact__c = true;
        try{
            insert testContacts2;  //Testing two Primary contacts on an Account- insertion failure
        }catch(Exception e){
            Boolean exp =  e.getMessage().contains('A contact record is already marked as Primary for this account. An account cannot have more than one primary contact.') ? true : false;
                system.assertEquals(exp,true);
        }
        
        Test.stopTest();
       
    }*/
    private static testMethod void testDeleteTeamMemberIfContactDeleted(){ 
        TestDataUtility.createCustomSettingRecords();
            
            List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c >();
            TriggerSettings__c contactTrigger= new TriggerSettings__c();
            contactTrigger.Name = 'contactTrigger';
            contactTrigger.isActive__c = True;
            triggerSettingsList.add(contactTrigger);
            Database.insert(triggerSettingsList);
        MDU_Property__c  prop = TestDataUtility.createProperty();
        Database.insert(prop); 
                 
        Property_Events__c propEvent = new Property_Events__c();    
        propEvent.name = 'TestPropertyEvent';
        propEvent.Property__c = prop.id;
        propEvent.Start_Time__c = System.Today()+1;
        propEvent.End_Time__c = System.Today()+2;
        propEvent.Type__c = 'Other';        
        Database.insert(propEvent);
        
        List<Contact> testContact = TestDataUtility.createContactRecord(1);
        Database.insert(testContact[0]);
          
        Property_Event_Team_Member__c propEventTeamMember1 = new Property_Event_Team_Member__c();
        propEventTeamMember1.Name = 'Test Name';
        propEventTeamMember1.Property_Event__c = propEvent.id;
        propEventTeamMember1.Contact__c = testContact[0].id;
        propEventTeamMember1.Mobile_Phone__c = '1234567890';
        propEventTeamMember1.Email__c = 'abc@xyz.com';
        Database.insert(propEventTeamMember1);
        
        Database.delete(testContact[0]);
    }
    
}