@isTest
public class PropertyEventCreateUpdateControllerTest {
	private static testMethod void testcheckForExistingPropertyEvent(){
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
        
        Event standardEvent = new Event();
        standardEvent.StartDateTime = propEvent.Start_Time__c;
        standardEvent.EndDateTime = propEvent.End_Time__c;
        standardEvent.Subject = 'SUBJECT';
        standardEvent.CAR_Activity_Type__c = 'Visit';
        standardEvent.Property_Event__c = propEvent.Id;
        standardEvent.WhatId = prop.id;
        standardEvent.Event_Status__c = 'In Progress';
        Database.insert(standardEvent);
        
        system.debug('result:'+standardEvent);
        
        PropertyEventCreateUpdateController.init(standardEvent.Id);
	}
}