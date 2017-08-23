@isTest(seeAllData=false)
private class PropertyEventTriggerControllerTest { 
	
	private static Event standardEvent1;
	private static Property_Events__c propEvent1;
	
	   
    private static final string LABEL_NAME_SPLIT = ';';
    public static MDU_Property__c createTestPropertyData(){
        TestDataUtility.createCustomSettingRecords();
        String labelName = System.Label.XfinityPropertyRecordType;  
        List<String> recordTypeSet = new List<String>();
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(LABEL_NAME_SPLIT)){
                recordTypeSet.add(Schema.SObjectType.MDU_Property__c.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }    
        MDU_Property__c  testProperty = TestDataUtility.createProperty();
        testProperty.recordTypeId = recordTypeSet[0];
        return testProperty;
    }

    private static testMethod void testPropertyEventTriggerController(){    
        List<Property_Events__c> lstPE = new List<Property_Events__c>();                        
        Test.startTest();            
            Property_Events__c propEvent = new Property_Events__c();
            propEvent.name = 'TestPropertyEvent';
            //propEvent.Event_date__c = date.today();
            MDU_Property__c prop = createTestPropertyData();
            Database.insert(prop);            
            propEvent.Property__c = prop.id;
            propEvent.Type__c = 'Other';
            Database.insert(propEvent);
            
            lstPE.add(propEvent);            
            PropertyEventTriggerController objPE = new PropertyEventTriggerController();
            objPE.doNotDeleteWithItems(lstPE);
            
            Property_Event_Item__c propEventItem = new Property_Event_Item__c();
            propEventItem.name = 'TestPropertyEventitem';
            propEventItem.Property_Event__c = propEvent.id;
            propEventItem.Category__c = 'other';
            propEventItem.Quantity__c = 3;
            propEventItem.Cost_per_Unit__c = 4;                
            Database.insert(propEventItem);                  
            //objPE.mapPropertyEventToItems.put(PE.id, new List<Property_Event_Item__c>{propEventItem});
            objPE.doNotDeleteWithItems(lstPE);
        Test.stopTest();       
    }
    
    private static testMethod void testUpdateCalenderEventStatus(){
        List<TriggerSettings__c> triggerSettingList = new List<TriggerSettings__c>();
        TriggerSettings__c propEventTrigger = new TriggerSettings__c();
        propEventTrigger.Name = 'PropertyEventTrigger';
        propEventTrigger.isActive__c = True;
        triggerSettingList.add(propEventTrigger);
        
        TriggerSettings__c eventTrigger = new TriggerSettings__c();
        eventTrigger.Name = 'EventTrigger';
        eventTrigger.isActive__c = false;
        triggerSettingList.add(eventTrigger);
        Database.insert(triggerSettingList);
        
        MDU_Property__c prop = TestDataUtility.createProperty();
        Database.insert(prop);
        
        Property_Events__c propEvent = new Property_Events__c();
        propEvent.name = 'TestPropertyEvent';
        propEvent.Property__c = prop.id;
        propEvent.Start_Time__c = System.Today()+1;
        propEvent.End_Time__c = System.Today()+2;
        propEvent.Type__c = 'Other';
        Database.insert(propEvent);
        
        Property_Event_Item__c propEventItem = new Property_Event_Item__c();
        propEventItem.name = 'TestPropertyEventitem';
        propEventItem.Property_Event__c = propEvent.id;
        propEventItem.Category__c = 'other';
        propEventItem.Quantity__c = 3;
        propEventItem.Cost_per_Unit__c = 4;                
        Database.insert(propEventItem);
        
        Event standardEvent = new Event();
        standardEvent.StartDateTime = propEvent.Start_Time__c;
        standardEvent.EndDateTime = propEvent.End_Time__c;
        standardEvent.Subject = 'SUBJECT';
        standardEvent.Property_Event__c = propEvent.Id;
        standardEvent.Event_Status__c = 'In Progress';
        Database.insert(standardEvent);
        
        Test.startTest();
            propEvent.name = 'TestPropertyEvent1111';
            propEvent.Billing_Type__c = 'Bulk';
            propEvent.Property_Life_cycle__c = 'New Build';
            propEvent.Sales_Channel__c = 'Direct';
            propEvent.Sponsor__c = 'CAR Sponsored';
            propEvent.Total_RGU_Goal__c = 125;
            propEvent.Status__c = 'Completed';
            Database.update(propEvent); 
        Test.stopTest();
    }
    
    
     private static testMethod void testSendEventCancelationAndDeleteTeamMembers(){
     	
        List<TriggerSettings__c> triggerSettingList = new List<TriggerSettings__c>();
        TriggerSettings__c propEventTrigger = new TriggerSettings__c();
        propEventTrigger.Name = 'PropertyEventTrigger';
        propEventTrigger.isActive__c = True;
        triggerSettingList.add(propEventTrigger);
        
        TriggerSettings__c eventTrigger = new TriggerSettings__c();
        eventTrigger.Name = 'EventTrigger';
        eventTrigger.isActive__c = false;
        triggerSettingList.add(eventTrigger);
        Database.insert(triggerSettingList);
        
        //SetupTestData.createCustomSettingRecords();
        VariableSettingTestUtility.variableSettingsData();
                        
        Account comcastAccount = TestDataUtility.createAccount();
        Database.insert(comcastAccount);
        
        Variable_Setting__c variableSetting3 = new Variable_Setting__c();
        variableSetting3.name = 'PropertyEventComcastAccountID';
        variableSetting3.Description__c = 'Dummy Account Record';
        variableSetting3.Value__c = String.valueOf(comcastAccount.Id);
        insert variableSetting3;
        
        User carUser1 = WorkTestDataUtility.createCARUser();
        User carUser = WorkTestDataUtility.createCARUser();
        
        Contact newContact = new Contact();
        newContact.FirstName = 'Sagarika';
        newContact.LastName = 'Contact';
        newContact.Email = 'sagarika@contact.com';
        newContact.AccountId = comcastAccount.Id;
        newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CAR Contact').getRecordTypeId();
        newContact.Phone = '12346789';
        insert newContact;
        
        Property_Events__c propEvent = null;
        system.runAs(carUser1)
        {
        	MDU_Property__c prop = TestDataUtility.createProperty();
	        prop.Assigned_CAR__c = carUser1.id;
	        Database.insert(prop);
	        
            propEvent = new Property_Events__c();
	        propEvent.name = 'TestPropertyEvent';
	        propEvent.Property__c = prop.id;
	        propEvent.Start_Time__c = System.Today() +1;
	        propEvent.End_Time__c = System.Today() +2;
	        propEvent.Type__c = 'Breakfast event';
	        Database.insert(propEvent);
                                
	        Event standardEvent1 = new Event();
	        standardEvent1.StartDateTime = System.Today()+1;
	        standardEvent1.EndDateTime = System.Today()+2;
	        standardEvent1.Subject = 'SUBJECT';
	        standardEvent1.CAR_Activity_Type__c = 'Visit';
	        standardEvent1.WhatId = prop.id;
	        standardEvent1.Event_Status__c = 'In Progress';
            standardEvent1.Property_event__c = propEvent.id;
	        Database.insert(standardEvent1);
	             
	        List<Property_Events__c> propertyEvents = new List<Property_Events__c>();
	        propertyEvents.add(propEvent);
        
	        PropertyEventTriggerController.updatePropertyEventOnStandardEvent(propertyEvents);
	        
	        Property_Event_Team_Member__c teamMember = new Property_Event_Team_Member__c();
	        teamMember.Team_Member__c = carUser.id;
	        teamMember.User_Email__c = 'test@test.com';
	        teamMember.Property_Event__c = propEvent.id;
	        teamMember.Name = 'TestUser';
	        Database.insert(teamMember);
	        
	        teamMember = new Property_Event_Team_Member__c();
	        teamMember.Contact__c = newContact.id;
	        teamMember.User_Email__c = 'testContact@test.com';
	        teamMember.Email__c = 'testContact@test.com';
	        teamMember.Property_Event__c = propEvent.id;
	        teamMember.Name = 'ContactTestUser';
	        Database.insert(teamMember);
	        
	       	EventRelation eventRelation = new EventRelation();
            eventRelation.EventId = standardEvent1.Id;
            eventRelation.Status = 'Accepted';
            eventRelation.RelationId = carUser.id;
            Database.insert(eventRelation); 
            
            eventRelation = new EventRelation();
            eventRelation.EventId = standardEvent1.Id;
            eventRelation.Status = 'Accepted';
            eventRelation.RelationId = newContact.id;
            Database.insert(eventRelation); 
	        
	        Test.startTest();
            propEvent.Start_Time__c = System.Today() +4;
	        propEvent.End_Time__c = System.Today() +5;
            Database.update(propEvent);
			Database.delete(propEvent);
	        Test.stopTest();
        
        }
        
        List<Property_Event_Team_Member__c> members = [SELECT Id from Property_Event_Team_Member__c where Property_Event__c =: propEvent.id];
        system.assertEquals(0, members.size());
        
        
       
    }
    
    private static testMethod void testUpdatePropertyEventOnStandardEvent(){
    
		List<TriggerSettings__c> triggerSettingList = new List<TriggerSettings__c>();
        TriggerSettings__c propEventTrigger = new TriggerSettings__c();
        propEventTrigger.Name = 'PropertyEventTrigger';
        propEventTrigger.isActive__c = True;
        triggerSettingList.add(propEventTrigger);
        
        TriggerSettings__c eventTrigger = new TriggerSettings__c();
        eventTrigger.Name = 'EventTrigger';
        eventTrigger.isActive__c = false;
        triggerSettingList.add(eventTrigger);
        Database.insert(triggerSettingList);
        
        MDU_Property__c prop = TestDataUtility.createProperty();
        Database.insert(prop);
        
        Event standardEvent1 = new Event();
        standardEvent1.StartDateTime = System.Today()+1;
        standardEvent1.EndDateTime = System.Today()+2;
        standardEvent1.Subject = 'SUBJECT';
        standardEvent1.CAR_Activity_Type__c = 'Visit';
        standardEvent1.WhatId = prop.id;
        standardEvent1.Event_Status__c = 'In Progress';
        Database.insert(standardEvent1);
        
        Property_Events__c propEvent1 = new Property_Events__c();
        propEvent1.name = 'TestPropertyEvent';
        propEvent1.Property__c = prop.id;
        propEvent1.Start_Time__c = System.Today()+1;
        propEvent1.End_Time__c = System.Today()+2;
        propEvent1.Type__c = 'Other';
        propEvent1.eventId__c = standardEvent1.id;
        Database.insert(propEvent1);
        
        Event standardEvent2 = new Event();
        standardEvent2.StartDateTime = System.Today()+1;
        standardEvent2.EndDateTime = System.Today()+2;
        standardEvent2.Subject = 'SUBJECT';
        standardEvent2.CAR_Activity_Type__c = 'Visit';
        standardEvent2.WhatId = prop.id;
        standardEvent2.Event_Status__c = 'In Progress';
        Database.insert(standardEvent2);
        
        Property_Events__c propEvent2 = new Property_Events__c();
        propEvent2.name = 'TestPropertyEvent';
        propEvent2.Property__c = prop.id;
        propEvent2.Start_Time__c = System.Today()+1;
        propEvent2.End_Time__c = System.Today()+2;
        propEvent2.Type__c = 'Other';
        propEvent2.eventId__c = standardEvent2.id;
        Database.insert(propEvent2);
        
        List<Property_Events__c> propertyEvents = new List<Property_Events__c>();
        propertyEvents.add(propEvent1);
        propertyEvents.add(propEvent2);
        
        PropertyEventTriggerController.updatePropertyEventOnStandardEvent(propertyEvents);
    
    }
    
      private static testMethod void createData(){
    
		List<TriggerSettings__c> triggerSettingList = new List<TriggerSettings__c>();
        TriggerSettings__c propEventTrigger = new TriggerSettings__c();
        propEventTrigger.Name = 'PropertyEventTrigger';
        propEventTrigger.isActive__c = True;
        triggerSettingList.add(propEventTrigger);
        
        TriggerSettings__c eventTrigger = new TriggerSettings__c();
        eventTrigger.Name = 'EventTrigger';
        eventTrigger.isActive__c = false;
        triggerSettingList.add(eventTrigger);
        Database.insert(triggerSettingList);
        
        MDU_Property__c prop = TestDataUtility.createProperty();
        Database.insert(prop);
        
        standardEvent1 = new Event();
        standardEvent1.StartDateTime = System.Today()+1;
        standardEvent1.EndDateTime = System.Today()+2;
        standardEvent1.Subject = 'SUBJECT';
        standardEvent1.CAR_Activity_Type__c = 'Visit';
        standardEvent1.WhatId = prop.id;
        standardEvent1.Event_Status__c = 'In Progress';
        Database.insert(standardEvent1);
        
        propEvent1 = new Property_Events__c();
        propEvent1.name = 'TestPropertyEvent';
        propEvent1.Property__c = prop.id;
        propEvent1.Start_Time__c = System.Today()+1;
        propEvent1.End_Time__c = System.Today()+2;
        propEvent1.Type__c = 'Other';
        propEvent1.eventId__c = standardEvent1.id;
        Database.insert(propEvent1);
        
    
    }

}