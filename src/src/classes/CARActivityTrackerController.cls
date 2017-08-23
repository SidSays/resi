/**    
* @Description: Controller for quick action 'What Did You Do' for CAR users
* @Modified By: Sagarika
* @Modified Date: 6/16/2017
* @Modified By: Suchita for US1111110
* @Modified Date: 7/3/2017
* @Last Modified By: Shalaka Kadwade: US1137741 (XC DT - Mark visit completed): Updating Visit Status field to "Completed".
* @Last Modified By: Suchita Sharma: US1123606: XC DT - Property Visit validation on close
* @Last Modified By: Shalaka Kadwade: US1143306 (XC DT - CAR Last Visit Date): Updating "Last CAR Visit Date" field on Property on check out of the property visit.
* @Last Modified By: Deepika Jain Naresh : US1144825 XC DT - Lunch and learn Visit : Adding a new checkbox for Lunch and Learn.
* @Last Modified By: Shalaka Kadwade : US1144860 XC DT - Qty Dropped off : Adding new number field and validation.
*/ 
global with sharing class CARActivityTrackerController {

    private final sObject mysObject;
    public boolean terms{get;set;}
    public static boolean validationFlag = false;
    public List<EventDetails> existingVisitForProperty{get;set;}
    public boolean existingVisits{get;set;}
    public String selectedCarActivityType{get;set;}
    public String selectedTypeOption{get;set;}
    public String visitPlanOption{get;set;} //Added for US1111110
    public boolean ScheduledVisit{get;set;}
    public String selectedVisitPlanOption{get;set;}
    public PropertyVisitDetails propVisitDetail{get;set;}
    private static final string DEFAULT_PICKLIST_SELECTION = '--- None ---';
    private static final string STR_VISIT = 'Visit';
    private static final string STR_SCHEDULED = 'Scheduled';
    private static final string STR_TASK = 'Task';
    private static final string STR_CAR_ACTIVITY = 'CAR Activity';
    private static final string STR_PRIORITY_NORMAL = 'Normal';
    private static final string STR_STATUS_COMPLETED = 'Completed';
    private static final string STR_ACTIVITY = 'Activity';
    private static final string VISIT_STATUS = 'In Progress';
    private static final string VISIT_STATUS_COMPLETED = 'Completed';
    
    /**    
  * @Description: The extension constructor initializes the private member variable mysObject by using the getRecord method from the standard controller
  * @Modified By: Sagarika
  * @Modified Date: 6/16/2017
  */ 
    public CARActivityTrackerController (ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
        User u = [SELECT id, Terms_and_Conditions_Accepted__c FROM User WHERE Id=:UserInfo.getUserId()];
        if(u.Terms_and_Conditions_Accepted__c != null){
            terms = true;
        }else{
            terms= false;
        }
        propVisitDetail = new PropertyVisitDetails();
    }
    
    /**    
    * @Description: Return property visits for the day which are owned by Logged-in user
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    * @Param: propId
    * @Return: List of property visits for the day which are owner by Logged-in user
    */ 
    @RemoteAction
    global static List<Property_Visit__c> getPropertyVisit(Id propId) {
        
        List<Property_Visit__c> result=[SELECT Id, Start_Date_Time__c, Property__c, Property__r.Name, Checked_In__c 
                                        FROM Property_Visit__c where Checked_In__c = true and CreatedById=: UserInfo.getUserId()
                                        and End_Date_Time__c=null AND Start_Date_Time__c = TODAY];
        return result;
   }
    
    
    /**    
    * @Description: Return values shown in 'Select CAR Activity Type' dropdown
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    * @Param: N/A
    * @Return: List of SelectOption shown in 'Select CAR Activity Type' dropdown
    */ 
    public List<SelectOption> getCARActivityTypeOptions()
    {
        List<SelectOption> carActivityTypes = new List<SelectOption>();
        try{
            carActivityTypes.add(new selectOption(DEFAULT_PICKLIST_SELECTION, DEFAULT_PICKLIST_SELECTION)); 
            Schema.DescribeFieldResult fieldResult = Task.CAR_Activity_Type__c.getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
            SelectOption option = null;
            for(Schema.PicklistEntry entry : picklistValues)
            {
                option = new SelectOption(entry.getValue(), entry.getValue());
                carActivityTypes.add(option); 
                if(String.isBlank(selectedCarActivityType))
                {
                    selectedCarActivityType = entry.getValue();
                }
            }
        }catch(Exception e){
            system.debug('EXCEPTION Occurred'+e.getmessage());
        }
        return carActivityTypes;
    }


    /**    
    * @Description: Return values shown in 'Select Type' dropdown
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    * @Param: N/A
    * @Return: List of SelectOption shown in 'Select Type' dropdown
    */ 
   public List<SelectOption> getTypeOptions()
    {
        List<SelectOption> typeOptions = new List<SelectOption>();
        
        try
        {
            typeOptions.add(new selectOption(DEFAULT_PICKLIST_SELECTION, DEFAULT_PICKLIST_SELECTION)); 
            if(selectedCarActivityType != null)
            {
                SelectOption option = null;
                for(CarActivitySettings__c activityValue : [SELECT ActivityType__c from  CarActivitySettings__c where 
                                                            CarActivityType__c =: selectedCarActivityType])
                {
                    option = new SelectOption(activityValue.ActivityType__c , activityValue.ActivityType__c );
                    typeOptions.add(option); 
                }
            }
        }catch(Exception e){
        system.debug('EXCEPTION Occurred'+e.getmessage());
        }
        return typeOptions;
    }


    /**    
    * @Description: Return values shown in 'Visit Plan' dropdown
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    * @Param: N/A
    * @Return: List of SelectOption shown in 'Visit Plan' dropdown
    */ 
    public List<SelectOption> getVisitPlanOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        try
        {
            Schema.DescribeFieldResult fieldResult = Property_Visit__c.Visit_Plan__c.getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
            SelectOption option = null;
            for(Schema.PicklistEntry entry : picklistValues)
                {
                  option = new SelectOption(entry.getValue(), entry.getValue());
                  options.add(option); 
                }
        }catch(Exception e){
        system.debug('EXCEPTION Occurred'+e.getmessage());
        }
        return options;
    }
    
    
    /**    
    * @Description: Check if Scheduled Visit is selected from the page
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    * @Param: N/A
    * @Return: PageReference to refresh the section of the page
    */       
    public PageReference checkScheduledVisit()
    {
        try
        {
            ScheduledVisit = false;
            if(STR_VISIT.equals(selectedCarActivityType) && STR_SCHEDULED.equalsIgnoreCase(selectedTypeOption))
            {
            ScheduledVisit = true;
            }
            populateExistingVisitForProperty();
            visitPlanOption = propVisitDetail.visitPlan;
        }catch(Exception e){
        system.debug('EXCEPTION Occurred'+e.getmessage());
        }
    return null;
    }
    /**    
    * @Description: Check for Visit Plan option selected from the page
    * @Modified By: Suchita for US1111110
    * @Modified Date: 7/3/2017
    * @Param: N/A
    * @Return: PageReference to refresh the section of the page
    */    
    public PageReference visitDetailOptionValue(){
        try 
        {
            visitPlanOption = propVisitDetail.visitPlan;
        }
        catch(Exception e){
        system.debug('EXCEPTION Occurred'+e.getmessage());
        }
        return null;
    }
    
    /**    
    * @Description: Runs on Save and Check Out, Performs save on Property Visit and updated Metrics 
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    * @Modified By: Suchita for US1111110 
    * @Modified Date: 7/3/2017
    * @Modified By: Suchita for US1123606 
    * @Modified Date: 7/13/2017
    * @Modified By: Deepika Jain for US1144825 - Adding a new checkbox for Lunch and Learn
    * @Modified Date: 7/27/2017
    * @Param: params
    * @Return: boolean
    */ 
    @RemoteAction
    global static boolean saveActivities(Params params) {
        //RecordType recType = [SELECT Id FROM RecordType WHERE sObjecttype=:STR_TASK AND Name=:STR_CAR_ACTIVITY];
        // US1137741 Adding 'Status__c' in query.
        System.debug('inside method');
        
            Property_Visit__c visitToUpdate = null;
            List<Property_Visit__c> result1=[SELECT Id, Checked_In__c, End_Date_Time__c, Visit_Plan__c, Visit_Location__Latitude__s, 
                                            Visit_Location__Longitude__s,Status__c FROM Property_Visit__c WHERE 
                                            Property__c=:params.propertyId AND End_Date_Time__c=null];
            
            if(result1.size() > 0)
            {
              for(Property_Visit__c visit : result1)
                {
                    if((String.valueOf(visit.id)).equalsIgnoreCase(params.propertyVisitId)) 
                    {
                      visitToUpdate = visit;      
                    }         
                }
            }
                if(visitToUpdate == null)
                {
                  visitToUpdate = result1[0];
                }
            
            /*List<Task> tasksToCreate = new List<Task>();
            if(visitToUpdate != null){
                for(CARActivity theActivity:params.activities){
                    if(theActivity.done){
                        tasksToCreate.add(  
                                new Task(
                                    RecordTypeId=recType.Id, Subject=theActivity.activityType,
                                    Type__c=STR_ACTIVITY, CAR_Activity_Type__c=theActivity.activityType,
                                    Status=STR_STATUS_COMPLETED, Priority=STR_PRIORITY_NORMAL, WhatId=params.propertyId,
                                    Disposition_Latitude__c=params.latitude, Disposition_Longitude__c=params.longitude,
                                    Description=theActivity.notes, Property_Visit__c=result1[0].Id,
                                    OwnerId = UserInfo.getUserId()
                                )
                        );

                    }
                }
            */
                //database.insert(tasksToCreate,false);
            //START US1111110
            List<Visit_Detail__c> visitDetailToCreate = new List<Visit_Detail__c>();
            if(visitToUpdate != null){
                for(CARActivity theActivity : params.activities){
                    if(theActivity.done && theActivity.notes != '' && theActivity.activityType != 'Drop Off Materials'){ //Added check US1123606 //US1144860: Added check of "Drop off materials"                   
                            
                            if(params.propertyVisitId == null){
                                visitDetailToCreate.add(  
                                    new Visit_Detail__c(
                                        Name=theActivity.activityType,Visit_Activity__c=theActivity.activityType,
                                        Property_Visit__c=result1[0].Id,
                                        Comments__c=theActivity.notes,
                                        Lunch_and_Learn__c=theActivity.lunchAndLearnDone,      // Added as part of US1144825 - Deepika Jain - 07/27/17 
                                        Qty_dropped_off__c=theActivity.qtyCount  // Added as part of US1144860 - Shalaka Kadwade                   
                                    )
                            );
                            }else{
                                visitDetailToCreate.add(  
                                        new Visit_Detail__c(
                                            Name=theActivity.activityType,Visit_Activity__c=theActivity.activityType,
                                            Property_Visit__c=params.propertyVisitId,
                                            Comments__c=theActivity.notes,
                                            Lunch_and_Learn__c=theActivity.lunchAndLearnDone,      // Added as part of US1144825 - Deepika Jain - 07/27/17
                                            Qty_dropped_off__c=theActivity.qtyCount        // Added as part of US1144860 - Shalaka Kadwade                        
                                        )
                                );
                            }
                        
                    }else if(theActivity.activityType == 'Drop Off Materials' && theActivity.done && theActivity.notes != ''){ // Added as part of US1144860 - Shalaka Kadwade: Start
                      
                        if(theActivity.qtyCount != 0){
                            if(params.propertyVisitId == null){
                                visitDetailToCreate.add(  
                                new Visit_Detail__c(
                                    Name=theActivity.activityType,Visit_Activity__c=theActivity.activityType,
                                    Property_Visit__c=result1[0].Id,
                                    Comments__c=theActivity.notes, 
                                    Qty_dropped_off__c=theActivity.qtyCount  
                                )
                                );
                            }else{
                                visitDetailToCreate.add(  
                                    new Visit_Detail__c(
                                        Name=theActivity.activityType,Visit_Activity__c=theActivity.activityType,
                                        Property_Visit__c=params.propertyVisitId,
                                        Comments__c=theActivity.notes,
                                        Qty_dropped_off__c=theActivity.qtyCount                               
                                    )
                                );
                            }
                        }else{
                            validationFlag = true;
                            return validationFlag;
                        } // Added as part of US1144860 - Shalaka Kadwade: End
                    }else{
                        validationFlag = true;
                    }//Added US1123606
                }
            
                if(!visitDetailToCreate.isEmpty()){
                    //START US1123606
                    validationFlag = false;
                    //END US1123606
                    database.insert(visitDetailToCreate,false);
                    createChatterPost(params); 
                    checkOut(visitToUpdate, params);
                    //Commented for US1111110
                    //CARActivityTrackerHelper.updateMetrics(visitDetailToCreate); 
                    //updateDateCARField(visitDetailToCreate);
                    //Start US1143306  
                    updateLastCARVisitDate(params.propertyId);
                    //End US1143306  
                } 
            }
            return validationFlag;
            //END US1111110
    }
    

    /**    
    * @Description: Performs Check Out. Sets date and location on Property Visit
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    * @Param: visitToUpdate, params
    * @Return: List of property visits for the day which are owner by Logged-in user
    * @Last Modified By: Shalaka Kadwade: US1137741: Marking Property Visit Status as "Completed" on click of "Save and Checkout" button.
    */     
    global static void checkOut(Property_Visit__c visitToUpdate, Params params) {
        List<Event> eventList = [SELECT id,Event_Status__c,property_visit__C FROM Event WHERE
                                property_visit__C  =: visitToUpdate.Id Limit 1];
        
        if(visitToUpdate != null){ 
            visitToUpdate.End_Date_Time__c=datetime.now();
            visitToUpdate.Visit_Plan__c=params.visitPlan;
            visitToUpdate.Visit_Location__Latitude__s= params.latitude;
            visitToUpdate.Visit_Location__Longitude__s= params.longitude;
            visitToUpdate.Checked_In__c= false;
            // US1137741 Start
            visitToUpdate.Status__c=VISIT_STATUS_COMPLETED;
            // US1137741 End
            if(!eventList.isEmpty())
            {
                eventList[0].Event_Status__c = STR_STATUS_COMPLETED;
                Database.update(eventList,false);
            }   
            
            Database.update(visitToUpdate);
        }
    }
    
    
    /**    
    * @Description: Check In for property. Updates Property Visit Record
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    * @Param: propId, latitude, longitude
    * @Return: Property Visit with updated data
    * @Last Modified by : Shalaka Kadwade: US1137741: Updating "Check In Time" field and Status field to "In Progress" when user check in.  
    */       
    @RemoteAction
    global static Property_Visit__c checkIn(Id propId, Decimal latitude,  Decimal longitude) {
      
      Property_Visit__c propertyVisit = null;
        
       
            if(latitude!=0 && latitude!=null){
                MDU_Property__c prop=[select Id, Property_Location__c,Property_Location__Latitude__s,
                                      Property_Location__Longitude__s, Exact_Match__c, Location_Captured_From_Visit__c 
                                      from MDU_Property__c where Id=:propId];    
                if(prop.Exact_Match__c==false || prop.Property_Location__Latitude__s==null || prop.Property_Location__Longitude__s==null){
                    prop.Property_Location__Latitude__s=latitude;
                    prop.Property_Location__Longitude__s=longitude;
                    prop.Exact_Match__c=true;
                    prop.Location_Captured_From_Visit__c=true;
                    Database.update(prop);
                }   
            }
            //insert propertyVisit;
            // US1137741 Adding 'Status__c' in query.
            List<Property_Visit__c> result=[SELECT Id, Start_Date_Time__c, Property__c, Property__r.Name, Checked_In__c,Status__c 
                                              FROM Property_Visit__c where Property__c =: propId and CreatedById=: UserInfo.getUserId()
                                              and End_Date_Time__c=null AND Start_Date_Time__c = TODAY limit 1];
              
            if(!result.isEmpty()){
                propertyVisit = result[0];
                propertyVisit.Checked_In__c  = true;
                propertyVisit.Start_Date_Time__c=datetime.now();
                propertyVisit.Visit_Location__Latitude__s=latitude;
                propertyVisit.Visit_Location__Longitude__s=longitude;
                // US1137741 Start
                propertyVisit.Check_In_Time__c=System.Now();
                propertyVisit.Status__c=VISIT_STATUS;
                // US1137741 End
                Database.update(propertyVisit);
            }
            else{
                propertyVisit=new Property_Visit__c();
                propertyVisit.Start_Date_Time__c=datetime.now();
                propertyVisit.Property__c=propId;
                propertyVisit.Visit_Location__Latitude__s=latitude;
                propertyVisit.Visit_Location__Longitude__s=longitude;
                propertyVisit.Checked_In__c  = true;
                // US1137741 Start
                propertyVisit.Check_In_Time__c=System.Now();
                propertyVisit.Status__c=VISIT_STATUS;
                // US1137741 End
                Database.insert(propertyVisit);
            }
            
      return propertyVisit;
        
   }
   
    /**    
    * @Description: Create Chatter posts for the Activities
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    * @Param: params
    * @Return: void
    */    
   @TestVisible private static void createChatterPost(Params params){
        String chatterText = '';

        for(CARActivity theActivity:params.activities){
            if(theActivity.done){
                chatterText += theActivity.activityType+' :\n';
                if(theActivity.notes !=null){
                    chatterText += theActivity.notes+'\n\n';
                }
            }
        } 
        FeedItem post = new FeedItem();
        post.ParentId = params.propertyId; //eg. Opportunity id, custom object id..
        post.Body = chatterText;
        Database.insert(post);

    }
    
        /**
        * @Description: This method assigns today's date to last car update field on property whenever new task is created.
        * @Author: Prateek Saxena, Accenture
        * @Date: 24-June-2016
        * @Param: none
        */
        /*Commented as no task is created for US1111110
         public static void updateDateCARField(List<Task> newTasksList) {
      
        String tabId = MDU_Property__c.sObjectType.getDescribe().getKeyPrefix();

        String taskRecordTypId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(System.Label.CARActivity).getRecordTypeId();
        set<String> propertyIds = new set<String>();
        List<MDU_Property__c> propertyToUpdate = new List<MDU_Property__c>();
        
        /*
        * Mapping of property to task created date.
        */
      /*
        if(!newTasksList.isEmpty()) {
            for(Task tsk : newTasksList){
                String parentId = tsk.whatId;
                if(parentId != null &&  (tsk.recordTypeId==taskRecordTypId)){
                    if(parentId.startsWith(tabId)){
                        propertyIds.add(tsk.whatId);
                    }
                }       
            }
        }
        
        /*
        * Listing propeties to update based on task created date only on Xfinity Property RecordType.
        */ 
      /*
        if(!propertyIds.isEmpty()){
            for(MDU_Property__c prop:[SELECT id, Last_CAR_Update_Date__c,RecordTypeId FROM MDU_Property__c WHERE ID IN:propertyIds]){
                    prop.Last_CAR_Update_Date__c = system.now();
                    propertyToUpdate.add(prop);
            }
        }
        
        // Updating Last CAR Update Date field on property.
        if(propertyToUpdate != null && propertyToUpdate.size() > 0){
            database.update(propertyToUpdate,false);
        }   
    }
    */
    /**    
    * @Description: Gets all the existing visits for the day for this property
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    * @Param: property Id
    * @Return: void
    */     
    public void populateExistingVisitForProperty(){
      existingVisitForProperty = new List<EventDetails>();
      try
      {
        List<Event> result = [SELECT id, Subject, StartDateTime, EndDateTime, Property_Visit__c , Property_Visit__r.Visit_plan__c
                            FROM Event WHERE StartDateTime = TODAY AND OwnerId =: UserInfo.getUserId()
                            AND WhatId=: mysObject.id AND Property_Visit__c != null AND CAR_Activity_Type__c =: STR_VISIT
                            AND Property_Visit__r.End_Date_Time__c=null ORDER BY StartDateTime ASC];
                            
        if(result.size() > 0){
          existingVisits = true;
          EventDetails eventDetail = null;
          for(Event e : result){
            eventDetail = new EventDetails(e.subject, e.StartDateTime.format(), e.EndDateTime.format(), e.Property_Visit__c);
            eventDetail.propertyVisitDetail.visitPlan = e.Property_Visit__r.Visit_plan__c;
            existingVisitForProperty.add(eventDetail);
            propVisitDetail.visitPlan = e.Property_Visit__r.Visit_plan__c;
          }
        }
        else
        {
          existingVisits = false;
        }
      }
      catch(Exception e)
      {
        system.debug('EXCEPTION Occurred'+e.getmessage());
      }
    }

    /**    
    * @Description: Wrapper Object to save data from page
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    */ 
    global with sharing class Params {
        @TestVisible String propertyId {get; set;}
        @TestVisible Decimal latitude {get; set;}
        @TestVisible Decimal longitude {get; set;}
        @TestVisible List<CARActivity> activities {get; set;}
        @TestVisible String propertyVisitId {get; set;}
        @TestVisible String visitPlan {get; set;}
    }

    /**    
    * @Description: Wrapper Object to save and display data for event details
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    */   
    global with sharing class EventDetails {
        public String subject {get; set;}
        public String startDate {get; set;}
        public String endDate {get; set;}
        public String propertyVisitAttached {get; set;}
        public PropertyVisitDetails propertyVisitDetail {get; set;}
        
        public EventDetails(String subject, String startDt, String endDt, String propertyVisitAttached)
        {
          propertyVisitDetail = new PropertyVisitDetails();
          this.subject = subject;
          this.startDate = startDt;
          this.endDate = endDt;
          this.propertyVisitAttached = propertyVisitAttached;
        }
    }

    /**    
    * @Description: Wrapper Object to save data for Property Visit
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    */     
    global with sharing class PropertyVisitDetails {
        public String visitPlan {get; set;}
        
    }

    /**    
    * @Description: Wrapper Object to save Actity Details
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    * @Modified By: Deepika Jain Naresh - US1144825 - XC DT - Lunch and learn Visit
    * @Modified Date: 07/27/17
    */     
    global with sharing class CARActivity{

        public String activityType {get; set;}
        public Boolean done {get; set;}
        public String notes {get; set;}
        public Boolean lunchAndLearnDone {get;set;} // Added as part of US1144825-XC DT - Lunch and learn Visit- Deepika Jain- 07/27/17
        public Integer qtyCount {get; set;} // Added as part of US1144860 - Shalaka Kadwade
    }
    
     /******************************    
     * @Description: Update Last CAR Visit Date on property
     * @Modified By: Shalaka Kadwade: US1143306 (XC DT - CAR Last Visit Date)
     * @Modified Date: 7/20/2017
     * @Param: propId
     * @Return: void
    *******************************/        
    global static void updateLastCARVisitDate(Id propId){
        //Start US1143306    
        if(propId != null){
            List<MDU_Property__c> propRecord = [SELECT Id, Last_CAR_Update_Date__c FROM MDU_Property__c WHERE ID =: propId Limit 1];
                propRecord[0].Last_CAR_Update_Date__c = system.now();
                Database.update(propRecord[0],false);
        }        
    }//End US1143306

}