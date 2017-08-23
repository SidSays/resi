/**************************************************************
* Class Name : PropertyVisitForStandardEventController
* Author : Deepika Jain Naresh, Accenture
* Date : 16-June-2017
* Description : This class is Controller extension of "PropertyVisitForStandardEvent" visualforce page.
* User Story : US1110856(XC DT - Link to Standard activity for Visit)
* @Last modified By: Lavanya Hosbet
* @Last modified Date: 12-July-2017 
* @Description : Need to be able to view 25 records at a time when searching for Team members to add to an event and see more records if needed
* @User Story : US1137253 - XC DT - Edit Property Visit
***************************************************************/
global with sharing class PropertyVisitForStandardEventController{
    //Initialization of constant variable
    private static final string VISIT = 'Visit';
    private static final string SLASH_STRING = '/';
    private static final string COMPLETED = 'Completed';
    
    //Class Variables
    public List<Event> standardEventList = new List<Event>();
    public Id eventId=null;
    
    
    //Getter Setter variable.
    public String propertyName{get;set;} 
    public String selectedVisitPlan{get;set;}
    public String formattedStartDateTimeOfVisit{get;set;}
    public Boolean ispropVisitExists{get;set;}
    
    // Added as a part of US1137253
    public Property_Visit__c propertyVisit{get;set;} 
    
    /*********************************************    
    * @Description : Constructor for PropertyVisitForStandardEventController
                     1.Fetching event id of the current Event.
    * @Author : Deepika Jain Naresh, Accenture    
    * @Date : 16-June-2017 
    * @User Story : US1110856(XC DT - Link to Standard activity for Visit)
    * @Param : ApexPages.StandardController    
    **********************************************/ 
    public PropertyVisitForStandardEventController(ApexPages.StandardController stdController){
        //Getting EventId from controller.
        eventId = stdController.getRecord().id;
        propertyVisit = new Property_Visit__c();
    }
    
    /*********************************************    
    * @Description : initializeData method to initialize the class variables. 
    * @Author : Deepika Jain Naresh, Accenture    
    * @Date : 16-June-2017 
    * @User Story : US1110856(XC DT - Link to Standard activity for Visit)
    * @Last modified By: Lavanya Hosbet
  * @Last modified Date: 12-July-2017 
  * @User Story : US1137253 - XC DT - Edit Property Visit
    * @Param : none  
    * @Return : void  
    **********************************************/ 
    public void initializeData(){
      try{
        standardEventList = [SELECT Id, WhatId, Car_Activity_Type__c, StartDateTime, Property_Visit__c FROM Event  
                                WHERE id =: eventId LIMIT 1]; 
        formattedStartDateTimeOfVisit=standardEventList[0].StartDateTime.format();        
        if(!standardEventList.isEmpty()){
          //Fetching PropertyId related to the current Event Id.
            List<MDU_Property__c> propertyList = [SELECT Id, Name FROM MDU_Property__c
                                   WHERE Id =: standardEventList[0].WhatId LIMIT 1];
            if(!propertyList.isEmpty()){
              //Setting the propertyName into variable.
                propertyName = propertyList[0].Name;
                //Check if event has any existing property visits  
               Property_Visit__c existingPropVisit = checkForDuplicateVisits(propertyList[0].Id, standardEventList[0].Property_Visit__c);
               //US1137253 - Begin
               //if there is an existing Property Visit, then display edit page with property visit details
                if(standardEventList[0].Property_Visit__c != null && existingPropVisit != null){
                    ispropVisitExists = true;
                    propertyVisit = existingPropVisit;
                    selectedVisitPlan = existingPropVisit.Visit_Plan__c;
                    //if Property Visit is completed or being edited, display appropriate message.
                    if(standardEventList[0].Property_Visit__c != null && (COMPLETED).equalsIgnoreCase(existingPropVisit.Status__c)){
                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.PropertyVisitCompleted));
                    }else {
                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.EditPropertyVisit));
                    }
                    
                }else{
                  // display appropriate message while creating a new Property Visit
                    ispropVisitExists = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.NewPropertyVisit));
                }
                 //US1137253 - End
            }   
        }
    }catch(Exception ex){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PESomeThingWentWrong));
      } 
    }
    
    /*********************************************    
    * @Description : getVisitPlanOptions method for dropdown values for the Visit Plan. 
    * @Author : Deepika Jain Naresh, Accenture    
    * @Date : 16-June-2017 
    * @User Story : US1110856(XC DT - Link to Standard activity for Visit)
    * @Param : none  
    * @Return : List<SelectOption>  
    **********************************************/ 
    public List<SelectOption> getVisitPlanOptions(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Property_Visit__c.Visit_Plan__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        SelectOption option = null;
        for(Schema.PicklistEntry entry : picklistValues){
            option = new SelectOption(entry.getValue(), entry.getValue());
          options.add(option); 
        }           
        return options;
    }
    
    /*********************************************    
    * @Description : checkForDuplicateVisits method to Check if event has any existing property visits.
    * @Author : Deepika Jain Naresh, Accenture    
    * @Date : 16-June-2017 
    * @User Story : US1110856(XC DT - Link to Standard activity for Visit)
    * @Last modified By: Lavanya Hosbet
  * @Last modified Date: 12-July-2017 
  * @Description : Modified method to return the property visit record
  * @User Story : US1137253 - XC DT - Edit Property Visit
    * @Param : Id   
    * @Return: Property_Visit__c 
    **********************************************/  
    private Property_Visit__c checkForDuplicateVisits(Id propId, Id propertyVisitId){
      List<Property_Visit__c> propVisit;
      
      if(propertyVisitId != null){
        //US1137253 - Check if Property Visit is alreaddy associated to the event - start
        propVisit = [SELECT id, Property__r.Name, Start_Date_Time__c, Visit_Plan__c, Status__c FROM Property_Visit__c WHERE Property__c =: propId 
                                                  AND CreatedById=: UserInfo.getUserId() 
                                                  AND id =: propertyVisitId
                                                  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ];
           //US1137253 - end
      }else {
        propVisit = [SELECT id, Property__r.Name, Start_Date_Time__c, Visit_Plan__c, Status__c FROM Property_Visit__c WHERE Property__c =: propId 
                                                  AND CreatedById=: UserInfo.getUserId() 
                                                  AND Start_Date_Time__c = :standardEventList[0].StartDateTime 
                                                  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ];
      }
      
                                                  
        //return null if there is no Property Visit                                          
        if(propVisit.isEmpty()){
            return null;
        }else{
          //return the Property Visit record
             return propVisit[0];
        }
    } 
    
    /*********************************************     
    * @Description : savePropertyVisits method for Creating Property visit.
    * @Author : Deepika Jain Naresh, Accenture    
    * @Date : 16-June-2017 
    * @User Story : US1110856(XC DT - Link to Standard activity for Visit)
    * @Last modified By: Lavanya Hosbet
  * @Last modified Date: 12-July-2017 
  * @Description : Modified method to update the existing property visit record
  * @User Story : US1137253 - XC DT - Edit Property Visit
    * @Param : none   
    * @Return: PageReference 
    **********************************************/   
    public PageReference savePropertyVisits(){
      try{
        PageReference pageRef=null;
        if((VISIT).equalsIgnoreCase(standardEventList[0].Car_Activity_Type__c)){
          //check for existing property visit 
            Property_Visit__c existingPropVisit = checkForDuplicateVisits(standardEventList[0].WhatId, standardEventList[0].Property_Visit__c);
          Database.SaveResult result;
          Property_Visit__c newPropVisit = new Property_Visit__c();
          // if an existing property visit doesn't exist, create a new property visit
            if(existingPropVisit == null){
                newPropVisit.Start_Date_Time__c = standardEventList[0].StartDateTime;
                newPropVisit.Property__c = standardEventList[0].WhatId;
                newPropVisit.Visit_Plan__c=selectedVisitPlan;
                result= Database.insert(newPropVisit);
            } else {
              // US1137253 - Begin
              // update the existing property visit with user input
              existingPropVisit.Visit_Plan__c=selectedVisitPlan;
              existingPropVisit.Start_Date_Time__c = propertyVisit.Start_Date_Time__c;
              result= Database.update(existingPropVisit);
              // if start date on the property visit is edited, then update the start date on the standard event 
              standardEventList[0].StartDateTime=propertyVisit.Start_Date_Time__c;
                Database.update(standardEventList[0]);
                // US1137253 - End
            }  
            if(result.isSuccess()){
                  String propertyVisitId=result.getId();
                  pageRef= new PageReference(SLASH_STRING+propertyVisitId);
                  standardEventList[0].Property_Visit__c=propertyVisitId;
                  Database.update(standardEventList[0]);
                }else{
                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.PESomeThingWentWrong));
                } 
        }else{
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Label.PVCARActivityTypeShouldBeVisit));
        }
       return pageRef;
    }catch(Exception ex){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PESomeThingWentWrong));
      return null;
      } 
    }       
}