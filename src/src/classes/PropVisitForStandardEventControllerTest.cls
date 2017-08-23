@isTest
public class PropVisitForStandardEventControllerTest {
  
  private static PropertyVisitForStandardEventController propVisitStandardEvent;
  private static MDU_Property__c prop;
  private static User carUser;
  private static Property_Visit__c propertyVisit;
  private static User currentUser;
  
    private static void setUpTestData(){
        TestDataUtility.createCustomSettingRecords();

        TriggerSettings__c eventTrigger = new TriggerSettings__c();
        eventTrigger.Name = 'EventTrigger';
        eventTrigger.isActive__c = false;
        insert eventTrigger;
        
        currentUser = [SELECT Id, DefaultDivision, Region__c, Name FROM User WHERE Id=:UserInfo.getUserId()];
        carUser = TestDataUtility.createXfinityCARUser();
       
        System.runAs(currentUser)
        {
            Test.startTest();
            prop = TestDataUtility.createProperty();
          Database.insert(prop);
                      
          Event testEvent = new Event();
          testEvent.OwnerId = carUser.Id;
          testEvent.WhatId = prop.Id;
          testEvent.StartDateTime = datetime.now();
          testEvent.DurationInMinutes = 15;
          testEvent.Subject='Meeting';
          testEvent.Car_Activity_Type__c='Visit';
          insert testEvent;
                                
          PageReference pageRef = Page.PropertyVisitForStandardEvent;
          Test.setCurrentPage(pageRef);       
          ApexPages.currentPage().getParameters().put('testEventId', testEvent.Id);
          ApexPages.currentPage().getHeaders().put('USER-AGENT','iPad');
          ApexPages.StandardController propVisitForStandardEventController = new ApexPages.StandardController(testEvent);
          propVisitStandardEvent = new PropertyVisitForStandardEventController(propVisitForStandardEventController);
    
            
            Test.stopTest();  
         }
        
  }
  
  public static testMethod void testinitializeData(){
      setUpTestData();
      propVisitStandardEvent.initializeData();
      propVisitStandardEvent.savePropertyVisits();
      
      Property_Visit__c propVisit2 = new Property_Visit__c();
          propVisit2.Name ='Test prop visit2';
          propVisit2.Property__c = prop.Id;     
          propVisit2.CreatedById = carUser.Id;  
          propVisit2.Start_Date_Time__c = DateTime.now();        
          insert propVisit2;
          propVisitStandardEvent.initializeData();
  }
     public static testMethod void testgetVisitPlanOptions(){
       
           setUpTestData();
         List<SelectOption>  optionsDisplayed = null;     
          Schema.DescribeFieldResult dfr = Property_Visit__c.Visit_Plan__c.getDescribe();
        List<Schema.PicklistEntry> entries = dfr.getPickListValues();
          optionsDisplayed = propVisitStandardEvent.getVisitPlanOptions();
        
        //Check the number of regions returned. Global should be skipped.
        System.assert(optionsDisplayed.size() == entries.size());   
        propVisitStandardEvent.savePropertyVisits();
     }
     
    public static testMethod void testEditPropertyVisit(){
        
        setUpTestData();
        propertyVisit = new Property_Visit__c();
        propertyVisit.Name ='Test prop visit 1';
        propertyVisit.Property__c = prop.Id;     
        propertyVisit.CreatedById = currentUser.Id;  
        propertyVisit.Start_Date_Time__c = DateTime.now(); 
        insert propertyVisit; 
        propVisitStandardEvent.propertyVisit = propertyVisit;
        propVisitStandardEvent.selectedVisitPlan = 'Service';
        propVisitStandardEvent.initializeData();
        propVisitStandardEvent.savePropertyVisits();
              
    }
        
}