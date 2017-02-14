global with sharing class CARActivityTrackerController {

    private final sObject mysObject;
    public boolean terms{get;set;}
    
    
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller. 
    public CARActivityTrackerController(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
        User u = [Select id, Terms_and_Conditions_Accepted__c from User where Id=:UserInfo.getUserId()];
        if(u.Terms_and_Conditions_Accepted__c != null){
            terms = true;
        }else{
            terms= false;
        }
    }
    @RemoteAction
    global static List<Property_Visit__c> getPropertyVisit(Id propId) {
        
        List<Property_Visit__c> result=database.query('SELECT Id,Start_Date_Time__c, Property__c, Property__r.Name FROM Property_Visit__c where CreatedById=\''+UserInfo.getUserId()+'\' and End_Date_Time__c=null limit 1');
        system.debug('RESULT:' +result);
        return result;
        
       }

    @RemoteAction
    global static void saveActivities(Params params ) {
        RecordType recType = [select Id from RecordType where sObjecttype='Task' and Name='CAR Activity'];
        List<Property_Visit__c> result1=[select Id from Property_Visit__c where Property__c=:params.propertyId and End_Date_Time__c=null limit 1];
        List<Task> tasksToCreate = new List<Task>();
        System.debug('params.activities****'+params.activities);
        if(result1.size()>0){
            for(CARActivity theActivity:params.activities){
                if(theActivity.done){
                    tasksToCreate.add(  
                            new Task(
                                RecordTypeId=recType.Id,
                                Subject=theActivity.activityType,
                                Type__c='Activity',
                                CAR_Activity_Type__c=theActivity.activityType,
                                Status='Completed',
                                Priority='Normal',
                                WhatId=params.propertyId,
                                Disposition_Latitude__c=params.latitude,
                                Disposition_Longitude__c=params.longitude,
                                Description=theActivity.notes,
                                Property_Visit__c=result1[0].Id,
                                OwnerId = UserInfo.getUserId()
                            )
                    );

                }
              
            }
            database.insert(tasksToCreate,false);
            createChatterPost(params);
            if(!tasksToCreate.isEmpty()){        
                checkOut(result1);
                CARActivityTrackerHelper.updateMetricForCarANDMgr(tasksToCreate);
                updateDateCARField(tasksToCreate);
            }
        }
    }
    
    
    /*
     *This method are written in "CARActivityTrackerHelper.updateMetricForCarANDMgr", because we need to run in system mode(without sharing) to update mgr event metric(US760932)
     */
    // Adding Task for 'Sales Event' Actitvity for What Id events
    /*global static void addTask(List<Task> newTasksList){
        
        Date preGoalStartDate = null;
        Date preGoalDueDate = null; 
        String ManagerId = null;
        Map<String, Metric> ownerIdMetricMap = new Map<String, Metric>();
        List<Metric> metricList= new List<Metric>();
        Metric metricToUpdate;
        String RecordtypeProgress = Schema.SObjectType.Metric.getRecordTypeInfosByName().get(system.label.MetricProgress).getRecordTypeId();
      
        //Get the Fiscal Year Date period goal start/due dates            
        GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(PROPERTY_LAB_GOAL_TEMPLATE);             
        if(goalDates != null){
            preGoalStartDate = goalDates.Current_Period_Start_Date__c;  
            preGoalDueDate =  goalDates.Current_Period_Due_Date__c;
        } 
        
        User UserObj = [SELECT ID, ManagerId FROM User WHERE ID =: UserInfo.getUserId()];
        
        if(UserObj.ManagerId != null){
            ManagerId = UserObj.ManagerId;
        }
        //Fetching Event metrics of CAR and Car Manager
        For(Metric metricObj : [SELECT ID, OwnerId, TargetValue, CurrentValue FROM Metric WHERE name like : EVENT_METRIC AND Goal.Status =: GOAL_STATUS 
                                   AND Goal.StartDate =: preGoalStartDate AND Goal.DueDate =:preGoalDueDate AND Recordtypeid =:RecordtypeProgress 
                                   AND (OwnerId =: UserInfo.getUserId() OR OwnerId =: ManagerId)]){
            
            ownerIdMetricMap.put(metricObj.OwnerId,metricObj);                         
                                   
        }
        System.debug('ownerIdMetricMap*****'+ownerIdMetricMap);
        
        for(Task TaskTemp : newTasksList){
            if(TaskTemp.CAR_Activity_Type__c==Label.SalesEventActivityType) {
                //Updating Car metric
                if(ownerIdMetricMap.containsKey(UserInfo.getUserId())){
                    metricToUpdate = ownerIdMetricMap.get(UserInfo.getUserId());                
                    metricToUpdate.CurrentValue = metricToUpdate.CurrentValue == NULL ? 1 : metricToUpdate.CurrentValue+1;               
                    metricList.add(metricToUpdate);
                }
                //Updating Car Manager metric
                If(ManagerId != null && ownerIdMetricMap.containsKey(ManagerId)){
                    metricToUpdate = ownerIdMetricMap.get(ManagerId);               
                    metricToUpdate.CurrentValue = metricToUpdate.CurrentValue == NULL ? 1 : metricToUpdate.CurrentValue+1;               
                    metricList.add(metricToUpdate);
                }    
            } 
             
        }
        System.debug('metricList*****'+metricList);
        if(!metricList.isEmpty()){
            database.update(metricList,false); 
        }
    }*/ 
    
    
       
    global static void checkOut(List<Property_Visit__c> result1) {
        if(result1.size()>0){ 
        result1[0].End_Date_Time__c=datetime.now();
        update result1;
        system.debug('RESULT1:' +result1);
        }}
     @RemoteAction
    global static Property_Visit__c checkIn(Id propId, Decimal latitude,  Decimal longitude) {
        Property_Visit__c propertyVisit=new Property_Visit__c();
        propertyVisit.Start_Date_Time__c=datetime.now();
        propertyVisit.Property__c=propId;
        propertyVisit.Visit_Location__Latitude__s=latitude;
        propertyVisit.Visit_Location__Longitude__s=longitude;
        System.debug('My Data' +propertyVisit);
        if(latitude!=0 && latitude!=null)
        {
        MDU_Property__c prop=[select Id, Property_Location__c,Property_Location__Latitude__s,Property_Location__Longitude__s, Exact_Match__c,  Location_Captured_From_Visit__c from MDU_Property__c where Id=:propId];    
            if(prop.Exact_Match__c==false || prop.Property_Location__Latitude__s==null || prop.Property_Location__Longitude__s==null) {
                prop.Property_Location__Latitude__s=latitude;
                prop.Property_Location__Longitude__s=longitude;
                prop.Exact_Match__c=true;
                prop.Location_Captured_From_Visit__c=true;
                update prop;
                
            }   
        }
        insert propertyVisit;
        return propertyVisit;
       }
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
        insert post;

    }
    
    /**
    * @Description: This method assigns today's date to last car update field on property whenever new task is created.
    * @Author: Prateek Saxena, Accenture
    * @Date: 24-June-2016
    * @Param: none
    */

        public static void updateDateCARField(List<Task> newTasksList) {
      
        String tabId = MDU_Property__c.sObjectType.getDescribe().getKeyPrefix();

        String taskRecordTypId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(System.Label.CARActivity).getRecordTypeId();
        set<String> propertyIds = new set<String>();
        List<MDU_Property__c> propertyToUpdate = new List<MDU_Property__c>();
        
        /*
        * Mapping of property to task created date.
        */
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
        if(!propertyIds.isEmpty()){
            for(MDU_Property__c prop:[SELECT id, Last_CAR_Update_Date__c,RecordTypeId FROM MDU_Property__c WHERE ID IN:propertyIds]){
                    prop.Last_CAR_Update_Date__c = system.now();
                    propertyToUpdate.add(prop);
            }
        }
        
        /*
        * Updating Last CAR Update Date field on property.
        */
        if(propertyToUpdate != null && propertyToUpdate.size() > 0){
            database.update(propertyToUpdate,false);
        }   
    }

    global class Params {
        @TestVisible String propertyId {get; set;}
        @TestVisible Decimal latitude {get; set;}
        @TestVisible Decimal longitude {get; set;}
        @TestVisible List<CARActivity> activities {get; set;}
    }
    global class CARActivity{

        public String activityType {get; set;}
        public Boolean done {get; set;}
        public String notes {get; set;}
    }

}