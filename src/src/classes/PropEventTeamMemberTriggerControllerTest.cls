@isTest(SeeAllData = false)
private class PropEventTeamMemberTriggerControllerTest {

    private static testMethod void testCreateCalenderEvent(){         
        TestDataUtility.createCustomSettingRecords();      
        TriggerSettings__c propEventTeamMemberTrigger = new TriggerSettings__c();
        propEventTeamMemberTrigger.Name = 'PropertyEventTeamMemberTrigger';
        propEventTeamMemberTrigger.isActive__c = True;
        insert propEventTeamMemberTrigger;
        
        Test.startTest();           
            User testUser = TestDataUtility.createXfinityCARUser();
            User xspUser = WorkTestDataUtility.createDSRepUserForCoaching();
            insert xspUser;
            User xspUser1 = WorkTestDataUtility.createDSRepUserForCoaching();
            insert xspUser1;
            
            System.runAs(testUser){
                MDU_Property__c  prop = TestDataUtility.createProperty();
                insert prop;            
                Property_Events__c propEvent = new Property_Events__c();    
                propEvent.name = 'TestPropertyEvent';
                propEvent.Property__c = prop.id;
                propEvent.Start_Time__c = System.Today()+1;
                propEvent.End_Time__c = System.Today()+2;
                propEvent.Type__c = 'Other';        
                insert propEvent;
         
                Property_Event_Team_Member__c propEventTeamMember = new Property_Event_Team_Member__c();
                propEventTeamMember.Name = 'Test Name';
                propEventTeamMember.Property_Event__c = propEvent.id;
                propEventTeamMember.Team_Member__c = xspUser.id;
                insert propEventTeamMember;
            
                propEventTeamMember.Team_Member__c = xspUser1.id;
                update propEventTeamMember;
                
                delete propEventTeamMember;     
            }        
        Test.stopTest();    
    }
    
    private static testMethod void testaddAttendees(){         
        TestDataUtility.createCustomSettingRecords();
        List<TriggerSettings__c> triggerSettingList = new List<TriggerSettings__c>();
        TriggerSettings__c propEventTeamMemberTrigger = new TriggerSettings__c();
        propEventTeamMemberTrigger.Name = 'PropertyEventTeamMemberTrigger';
        propEventTeamMemberTrigger.isActive__c = True;
        triggerSettingList.add(propEventTeamMemberTrigger);
               
        TriggerSettings__c propEventTrigger = new TriggerSettings__c();
        propEventTrigger.Name = 'PropertyEventTrigger';
        propEventTrigger.isActive__c = True;
        triggerSettingList.add(propEventTrigger);
        
        TriggerSettings__c eventTrigger = new TriggerSettings__c();
        eventTrigger.Name = 'EventTrigger';
        eventTrigger.isActive__c = false;
        triggerSettingList.add(eventTrigger);
        Database.insert(triggerSettingList);
        
        User testUser = TestDataUtility.createXfinityCARUser();
        User xspUser = WorkTestDataUtility.createDSRepUserForCoaching();
        Database.insert(xspUser);
        
        Variable_Setting__c variableSetting3 = new Variable_Setting__c();
        variableSetting3.name = 'PropEventStatusTrackingSiteURL';
        variableSetting3.Description__c = 'Site URL for to accept and decline an event';
        variableSetting3.Value__c = 'http://tempuat-onecomcast.cs67.force.com/';
        insert variableSetting3; 
        
        Test.startTest();       
        System.runAs(testUser){
            MDU_Property__c  prop = TestDataUtility.createProperty();
            Database.insert(prop);          
            Property_Events__c propEvent = new Property_Events__c();    
            propEvent.name = 'TestPropertyEvent';
            propEvent.Property__c = prop.id;
            propEvent.Start_Time__c = System.Today()+1;
            propEvent.End_Time__c = System.Today()+2;
            propEvent.Type__c = 'Other';        
            Database.insert(propEvent);
            
            Event standardEvent = new Event();
            standardEvent.StartDateTime = propEvent.Start_Time__c;
            standardEvent.EndDateTime = propEvent.End_Time__c;
            standardEvent.Subject = 'SUBJECT';
            standardEvent.Property_Event__c = propEvent.Id;
            standardEvent.Event_Status__c = 'In Progress';
            Database.insert(standardEvent);
            
            Property_Event_Team_Member__c propEventTeamMember = new Property_Event_Team_Member__c();
            propEventTeamMember.Name = 'Test Name';
            propEventTeamMember.Property_Event__c = propEvent.id;
            propEventTeamMember.Team_Member__c = xspUser.id;
            Database.insert(propEventTeamMember);       
        }           
        Test.stopTest();    
    }
    
    private static testMethod void testUpdateTeamMemberPhone(){         
        TestDataUtility.createCustomSettingRecords();
        List<TriggerSettings__c> triggerSettingList = new List<TriggerSettings__c>();
        TriggerSettings__c propEventTeamMemberTrigger = new TriggerSettings__c();
        propEventTeamMemberTrigger.Name = 'PropertyEventTeamMemberTrigger';
        propEventTeamMemberTrigger.isActive__c = True;
        triggerSettingList.add(propEventTeamMemberTrigger);
               
        TriggerSettings__c propEventTrigger = new TriggerSettings__c();
        propEventTrigger.Name = 'PropertyEventTrigger';
        propEventTrigger.isActive__c = True;
        triggerSettingList.add(propEventTrigger);
        
        TriggerSettings__c eventTrigger = new TriggerSettings__c();
        eventTrigger.Name = 'EventTrigger';
        eventTrigger.isActive__c = false;
        triggerSettingList.add(eventTrigger);
        Database.insert(triggerSettingList);
        
        User testUser = TestDataUtility.createXfinityCARUser();
        User xspUser = WorkTestDataUtility.createDSRepUserForCoaching();
        Database.insert(xspUser);
        
        Test.startTest();       
        System.runAs(testUser){
            MDU_Property__c  prop = TestDataUtility.createProperty();
            Database.insert(prop);          
            Property_Events__c propEvent = new Property_Events__c();    
            propEvent.name = 'TestPropertyEvent';
            propEvent.Property__c = prop.id;
            propEvent.Start_Time__c = System.Today()+1;
            propEvent.End_Time__c = System.Today()+2;
            propEvent.Type__c = 'Other';        
            Database.insert(propEvent);
            
            Property_Event_Team_Member__c propEventTeamMember = new Property_Event_Team_Member__c();
            propEventTeamMember.Name = 'Test Name';
            propEventTeamMember.Property_Event__c = propEvent.id;
            propEventTeamMember.Team_Member__c = xspUser.id;
            propEventTeamMember.Mobile_Phone__c = '1234567890';
            Database.insert(propEventTeamMember); 
            
            propEventTeamMember.Mobile_Phone__c = '0987654321';
            Database.update(propEventTeamMember); 
            
            List<Contact> testContact = TestDataUtility.createContactRecord(1);
            Database.insert(testContact[0]);
            
            Property_Event_Team_Member__c propEventTeamMember1 = new Property_Event_Team_Member__c();
            propEventTeamMember1.Name = 'Test Name';
            propEventTeamMember1.Property_Event__c = propEvent.id;
            propEventTeamMember1.Contact__c = testContact[0].id;
            propEventTeamMember1.Mobile_Phone__c = '1234567890';
            propEventTeamMember1.Email__c = 'abc@xyz.com';
            Database.insert(propEventTeamMember1);
            
            propEventTeamMember1.Mobile_Phone__c = '0987654321';
            Database.update(propEventTeamMember1);
        }           
        Test.stopTest();    
    }
    
    private static testMethod void testdeleteAttendeeswithCancelIcis(){         
        TestDataUtility.createCustomSettingRecords();
        List<TriggerSettings__c> triggerSettingList = new List<TriggerSettings__c>();
        TriggerSettings__c propEventTeamMemberTrigger = new TriggerSettings__c();
        propEventTeamMemberTrigger.Name = 'PropertyEventTeamMemberTrigger';
        propEventTeamMemberTrigger.isActive__c = True;
        triggerSettingList.add(propEventTeamMemberTrigger);
               
        TriggerSettings__c propEventTrigger = new TriggerSettings__c();
        propEventTrigger.Name = 'PropertyEventTrigger';
        propEventTrigger.isActive__c = True;
        triggerSettingList.add(propEventTrigger);
        
        TriggerSettings__c eventTrigger = new TriggerSettings__c();
        eventTrigger.Name = 'EventTrigger';
        eventTrigger.isActive__c = false;
        triggerSettingList.add(eventTrigger);
        Database.insert(triggerSettingList);
        
        User testUser = TestDataUtility.createXfinityCARUser();
        User xspUser = WorkTestDataUtility.createDSRepUserForCoaching();
        Database.insert(xspUser);
        
        Variable_Setting__c variableSetting3 = new Variable_Setting__c();
        variableSetting3.name = 'PropEventStatusTrackingSiteURL';
        variableSetting3.Description__c = 'Site URL for to accept and decline an event';
        variableSetting3.Value__c = 'http://tempuat-onecomcast.cs67.force.com/';
        insert variableSetting3; 
        
        Test.startTest();       
        System.runAs(testUser){
            MDU_Property__c  prop = TestDataUtility.createProperty();
            Database.insert(prop);          
            Property_Events__c propEvent = new Property_Events__c();    
            propEvent.name = 'TestPropertyEvent';
            propEvent.Property__c = prop.id;
            propEvent.Start_Time__c = System.Today()+1;
            propEvent.End_Time__c = System.Today()+2;
            propEvent.Type__c = 'Other';        
            Database.insert(propEvent);
            
            Event standardEvent = new Event();
            standardEvent.StartDateTime = propEvent.Start_Time__c;
            standardEvent.EndDateTime = propEvent.End_Time__c;
            standardEvent.Subject = 'SUBJECT';
            standardEvent.Property_Event__c = propEvent.Id;
            standardEvent.Event_Status__c = 'In Progress';
            Database.insert(standardEvent);
            
            Property_Event_Team_Member__c propEventTeamMember = new Property_Event_Team_Member__c();
            propEventTeamMember.Name = 'Test Name';
            propEventTeamMember.Property_Event__c = propEvent.id;
            propEventTeamMember.Team_Member__c = xspUser.id;
            Database.insert(propEventTeamMember); 
            
            EventRelation eventRelation = new EventRelation();
            eventRelation.EventId = standardEvent.Id;
            eventRelation.Status = 'Accepted';
            eventRelation.RelationId = xspUser.id;
            Database.insert(eventRelation); 
            
             delete propEventTeamMember;
        }           
        Test.stopTest();    
    }
}