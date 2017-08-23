@isTest
public class PropertyEventStatusTrackingTest{ 

    private static testMethod void testStatusTrackingForAccepted(){
        SetupTestData.createCustomSettingRecords();                       
        TriggerSettings__c eventTrigger = new TriggerSettings__c();
        eventTrigger.Name = 'EventTrigger';
        eventTrigger.isActive__c = false;
        insert eventTrigger;
        
        Variable_Setting__c variableSetting3 = new Variable_Setting__c();
        variableSetting3.name = 'PropEventStatusTrackingSiteURL';
        variableSetting3.Description__c = 'Site URL for to accept and decline an event';
        variableSetting3.Value__c = 'http://tqm1-onecomcast.cs43.force.com/';
        insert variableSetting3; 
        
        Contact newContact = new Contact();
        newContact.FirstName = 'Amit';
        newContact.LastName = 'Pradhan';
        newContact.Email = 'amit@accenture.com';
        newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CAR Contact').getRecordTypeId();
        newContact.Phone = '12346789';
        Database.insert(newContact);
        
        Event standardEvent = new Event();
        standardEvent.StartDateTime = System.Today()+1;
        standardEvent.EndDateTime = System.Today()+2;
        standardEvent.Subject = 'SUBJECT';
        standardEvent.Event_Status__c = 'In Progress';
        Database.insert(standardEvent);
        
        EventRelation eventRelationObj = new EventRelation();                         
        eventRelationObj.EventId = standardEvent.Id;        
        eventRelationObj.RelationId = newContact.Id;
        Database.insert(eventRelationObj);
        
        ApexPages.currentPage().getParameters().put('EventId', standardEvent.Id);
        ApexPages.currentPage().getParameters().put('RelationId', newContact.Id);
        
        PropertyEventStatusTrackingController statusTracking = new PropertyEventStatusTrackingController();                
        statusTracking.acceptORDecline = 'Accepted';
        statusTracking.isAccepted = true;
        statusTracking.isDeclined = false;
        statusTracking.eventName = 'SUBJECT';
        statusTracking.organizerName = 'Amit';
        statusTracking.comments = 'Test';
        statusTracking.response = 'Test';
        statusTracking.initializeData();
        statusTracking.submitAcceptORDecline(); 
    } 
    
    private static testMethod void testStatusTrackingForDeclined(){
        SetupTestData.createCustomSettingRecords();                       
        TriggerSettings__c eventTrigger = new TriggerSettings__c();
        eventTrigger.Name = 'EventTrigger';
        eventTrigger.isActive__c = false;
        insert eventTrigger;
        
        Variable_Setting__c variableSetting3 = new Variable_Setting__c();
        variableSetting3.name = 'PropEventStatusTrackingSiteURL';
        variableSetting3.Description__c = 'Site URL for to accept and decline an event';
        variableSetting3.Value__c = 'http://tqm1-onecomcast.cs43.force.com/';
        insert variableSetting3; 
        
        Contact newContact = new Contact();
        newContact.FirstName = 'Amit';
        newContact.LastName = 'Pradhan';
        newContact.Email = 'amit@accenture.com';
        newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CAR Contact').getRecordTypeId();
        newContact.Phone = '12346789';
        Database.insert(newContact);
        
        Event standardEvent = new Event();
        standardEvent.StartDateTime = System.Today()+1;
        standardEvent.EndDateTime = System.Today()+2;
        standardEvent.Subject = 'SUBJECT';
        standardEvent.Event_Status__c = 'In Progress';
        Database.insert(standardEvent);
        
        EventRelation eventRelationObj = new EventRelation();                         
        eventRelationObj.EventId = standardEvent.Id;        
        eventRelationObj.RelationId = newContact.Id;
        Database.insert(eventRelationObj);
        
        ApexPages.currentPage().getParameters().put('EventId', standardEvent.Id);
        ApexPages.currentPage().getParameters().put('RelationId', newContact.Id);
        
        PropertyEventStatusTrackingController statusTracking = new PropertyEventStatusTrackingController();                
        statusTracking.acceptORDecline = 'Declined';
        statusTracking.isAccepted = true;
        statusTracking.isDeclined = false;
        statusTracking.eventName = 'SUBJECT';
        statusTracking.organizerName = 'Amit';
        statusTracking.comments = 'Test';
        statusTracking.response = 'Test';
        statusTracking.initializeData();
        statusTracking.submitAcceptORDecline(); 
    } 
    
    private static testMethod void testStatusTrackingAlreadyAccepted(){
        SetupTestData.createCustomSettingRecords();                       
        TriggerSettings__c eventTrigger = new TriggerSettings__c();
        eventTrigger.Name = 'EventTrigger';
        eventTrigger.isActive__c = false;
        insert eventTrigger;
        
        Variable_Setting__c variableSetting3 = new Variable_Setting__c();
        variableSetting3.name = 'PropEventStatusTrackingSiteURL';
        variableSetting3.Description__c = 'Site URL for to accept and decline an event';
        variableSetting3.Value__c = 'http://tqm1-onecomcast.cs43.force.com/';
        insert variableSetting3; 
        
        Contact newContact = new Contact();
        newContact.FirstName = 'Amit';
        newContact.LastName = 'Pradhan';
        newContact.Email = 'amit@accenture.com';
        newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CAR Contact').getRecordTypeId();
        newContact.Phone = '12346789';
        Database.insert(newContact);
        
        Event standardEvent = new Event();
        standardEvent.StartDateTime = System.Today()+1;
        standardEvent.EndDateTime = System.Today()+2;
        standardEvent.Subject = 'SUBJECT';
        standardEvent.Event_Status__c = 'In Progress';
        Database.insert(standardEvent);
        
        EventRelation eventRelationObj = new EventRelation();                         
        eventRelationObj.EventId = standardEvent.Id;        
        eventRelationObj.RelationId = newContact.Id;        
        Database.insert(eventRelationObj);
        
        eventRelationObj.Status = 'Accepted';
        Database.update(eventRelationObj);
        
        ApexPages.currentPage().getParameters().put('EventId', standardEvent.Id);
        ApexPages.currentPage().getParameters().put('RelationId', newContact.Id);
        
        PropertyEventStatusTrackingController statusTracking = new PropertyEventStatusTrackingController();                
        statusTracking.acceptORDecline = 'Declined';
        statusTracking.isAccepted = true;
        statusTracking.isDeclined = false;
        statusTracking.eventName = 'SUBJECT';
        statusTracking.organizerName = 'Amit';
        statusTracking.comments = 'Test';
        statusTracking.response = 'Test';
        statusTracking.initializeData();
        statusTracking.submitAcceptORDecline(); 
    } 
}