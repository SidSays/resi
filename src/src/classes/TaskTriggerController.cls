/**
* Class Name: TaskTriggerController 
* Author: Amitkumar Bangad, Accenture
* Date: 10-December-2012 
* Requirement # Request Id: 105,005
* Description: Contains supporting Actions for Task Triggers (Time to Touch metric Calculations, Call Count)

* Last Modified by : Ashish Srivastava, Accenture
* Last Modified Date : 22-03-2017
* Description : Code Added for US1051011 and US1051026 
* Last Modified By : Tejaswini Kasar(US1106419)
* Last Modified Date : 11 July 2017
* * Description : Code Added for US1106419 (CAR process removed from feed post for "CAR team forum")             
*/
public class TaskTriggerController {
    ///Data Member//
    private static final string DEVELOPER_NAME_SPLIT = ';';
    private static final string OBJECT_TYPE = 'Task';
    private static final Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.SObjectType.Task.getRecordTypeInfosByName();
        
    /*private static final string NoKnock = 'No Knock';
    private static final string NoAnswer = 'No Answer';
    private static final string DoorHanger = 'Door Hanger';
    private static final string contact = 'Contact';
    private static final string Engage = 'Engage';
    private static final string Discover = 'Discover';
    private static final string Position = 'Position';
    private static final string Close = 'Close';
    private static final string Start = 'Start';
    private static final string NonMarketableAddress = 'Non-Marketable Address';
    private static final string SingleFamily = 'Single Family';
    private static final string BulkBilledMaster = 'Bulk Billed Master';
    private static final string Commercial = 'Commercial';
    private static final string BulkBilledMDU = 'Bulk Billed MDU';
    private static final string NonBulkBilledMDU = 'Non Bulk Billed MDU';
    private static final string Unknown = 'Unknown';
    private static final string SingleFamilyUnit = 'Single Family Unit';
    private static final string MultipleDwellingUnit = 'Multiple Dwelling Unit';
    private static final string Vacant = 'Vacant';
    private static final string NonBulkBilled = 'Non Bulk Billed';*/
    private static final string SFU = 'SFU';
    private static final string MDU = 'MDU';
    private static final string OTHER = 'OTHER';
    private static final string EXCLUDEMAPPING = 'EXCLUDE MAPPING';
    private static final string CAR_PROCESS_STR = 'Car Process : ';
     private static final string CAR_TEAM_HUDDLE_RECORDTYPE = 'CAR Team Huddle';
    private static final string CAR_TEAM_FORUM_RECORDTYPE = 'CAR Team Forum';
    
    private static final string TEAM_HUDDLE_RECORDTYPE = 'Team Huddles';
    private static final string TEAM_FORUM_RECORDTYPE = 'Team Forum';
    private static final string HUDDLE_STR = 'Huddle';
    private static final string FORUM_STR = 'Forum';
    private static final string HUDDLE_FORUM_STR = 'Huddle/Forum';
    private static final string SINGLE_SPACE = ' ';
    private static final string SINGLE_LINE_BREAK = '\n';
    private static final string DOUBLE_LINE_BREAK = '\n\n';
    private static final string SUBJECT_STR = 'Subject : ';
    private static final string SALES_PROCESS_STR = 'Sales Process : ';
    private static final string HUDDLEFORUM_STR = 'Huddle/Forum : ';
    private static final string HUDDLE_NAME_STR = 'Huddle Name : ';
    private static final string FORUM_NAME_STR = 'Forum Name: ';
    private static final string STATUS_STR = 'Status : ';
    private static final string COMMENTS_STR = 'Comments : ';
    private static final string DUE_DATE_STR = 'Due Date : ';
    private static final string EMPTY_STR = '';
    private static final String OPP_PREFIX = '006';
    private static final String LEAD_PREFIX = '00Q';
    //private static final String OneAsOneCoachingRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('1:1 Coaching').getRecordTypeId();
    
     
    private static final string SYSTEM_ADMIN = 'System Administrator' ;
    private static final string PRI_VATE = 'Private';
    private static final string ADMIN = 'Admin';
    private static final string TEAM_HUDDLE = '%#TeamHuddle%';
    private static final string TEAM_FORUM = '%#TeamForum%';
    private static final String ACTIVITY_GOAL_COMMISSION = 'ActivityGoalCommissionCycle';
    private static final String PROPERTY_LAB_CAR = 'Property Lab CAR';

    
   /**
    * @Description: This method assigns today's date to last car update field on property whenever new task is created.
    * @Author: Sagar Gurav, Accenture
    * @Date: 16-July-2015
    * @Param: none
    */

        public static void updateDateCARField(List<Task> newTasksList) {
      
        String tabId = MDU_Property__c.sObjectType.getDescribe().getKeyPrefix();

        String taskRecordTypId = recordTypeMap.get(System.Label.CARActivity).getRecordTypeId();
        set<String> propertyIds = new set<String>();
        List<MDU_Property__c> propertyToUpdate = new List<MDU_Property__c>();
        try{
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
        } catch(Exception ex){ String msg = ex.getMessage();} 
    }
    
    /**
    * @Description: This method Used for XSP to create new task(1:1 coaching) when relationship between XSP & SDM.
                    SDM to create new task(1:1 coaching) when relationship between SDM & ASM.   
    * @Author: Laxman Raj, Accenture
    * @Date: 25-August-2015
    * @Param: Trigger.New
    * @Return: void.
    */
    /*
    public static void oneAsonecoachingvalidation(List<Task> newTasksList){
    
       try{
        
        String oneAsOneRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('1:1 Coaching').getRecordTypeId();            
        Id loggedInUserId = UserInfo.getUserId();               
        Map<Id,Id> coachIdCoachedId = new Map<Id,Id>();
        Set<Id> coachIdSet = new Set<Id>();
       
        //Get coaching Id
        for(Task TaskTemp : newTasksList){
            If(taskTemp.RecordtypeId == oneAsOneRecordTypeId){
                coachIdSet.add(TaskTemp.WhatId);
            }            
                                                          
        }
        
        //collect coaching id And Coached Id
        
        for(WorkCoaching workCoachObj:[SELECT Id,coachedId FROM WorkCoaching WHERE Id IN: coachIdSet LIMIT : 
        (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            coachIdCoachedId.put(workCoachObj.Id, workCoachObj.coachedId);
                                            
        }
        
        for(Task taskTemp : newTasksList){
            if(loggedInUserId != coachIdCoachedId.get(taskTemp.WhatId) && taskTemp.RecordtypeId == oneAsOneRecordTypeId ){
                taskTemp.adderror('You do not have permission to create 1:1 coaching activity');               
            }              
        }
        }
        catch(Exception e)
        {
           
        }
      
    }*/
    
    
    /**
    * @Description: This method restricts deletion of task from system.
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 28-December-2012
    * @Param: Trigger.old
    * @Return: void.
    * @Modified: Abhishek Mathur, Accenture 
    * @Description: Modified to check the Record type and update the logic to exclude MDU record type
    * @Modified: Amit Kumar Pradhan, Accenture 
    * @Description: Allowed to delete the tasks and events irrespective of their status
    * @UserStory:US533722(SP 9)
    */
    public static void restrictTaskDelete(List<Task> oldTasksList) {
        Set<String> recordTypeSet = new Set<String>();
        final String SYS_ADMIN = 'System Administrator';
        
        String sDeveloperName = System.Label.XfinityTaskRecordType + DEVELOPER_NAME_SPLIT + OBJECT_TYPE; //Get Developer Name Of Record Type And Fetch Record Only For That Record Type
        
        try{
        if(!string.IsBlank(sDeveloperName)){
            for(String str: sDeveloperName.split(DEVELOPER_NAME_SPLIT)){
                recordTypeSet.add(str);
            }
            
        }else{
            //Future code
        }  
                       
        Set<Id> recordTypeIdSet = new Set<Id>();
        for(RecordType rt: [SELECT  Id  FROM  RecordType 
                             WHERE SobjectType =: OBJECT_TYPE AND DeveloperName IN: recordTypeSet
                             LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            recordTypeIdSet.add(rt.Id);
            
        }
                
        Profile businessAdminProfile = [Select Id, Name from Profile WHERE Name=: Label.BusinessAdminProfileName];
        Profile systemAdminProfile = [Select Id, Name from Profile WHERE Name = :SYS_ADMIN];
        
        //Fetch profile Record from Custom Setting
        AllowTaskEventDelProfName__c profileRecord = AllowTaskEventDelProfName__c.getValues(UserInfo.getProfileId());
        
         for(Task taskObj : oldTasksList) {
            if(profileRecord == null){                              
                if(recordTypeIdSet.isEmpty() || !recordTypeIdSet.contains(taskObj.RecordTypeId)){ 
                    if(UserInfo.getProfileId() != businessAdminProfile.Id){
                        taskObj.addError(Label.ActivityDeleteErrorMsg1);  
                    }
                    else if(taskObj.Status != Label.TaskStatusCompleted){
                        taskObj.addError(Label.ActivityDeleteErrorMsg2);
                    } else{}
                }               
            } 
            else if(profileRecord != null && UserInfo.getProfileId() != systemAdminProfile.id && taskObj.OwnerId != UserInfo.getUserId()){
                taskObj.addError(Label.ErrMsgForDelOfTask);
            } else{}       
        }   
        } catch(Exception ex){ String msg = ex.getMessage();} 
    }
    
    /**
    * @Description: This method captures time to touch on relevant leads
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 30-November-2012
    * @Param: Trigger.NewMap, Trigger.OldMap
    * @Return: void.
    * @Modified: Abhishek Mathur, Accenture 
    * @Description: Modified to check the Record type and update the logic to exclude MDU record type
    */
    public static void identifyLeadTimeToTouch (Map<Id, Task> newTasksMap,Map<Id, Task> oldTasksMap) {
        //Code updated to ignore MDU records from the trigger event
        Set<String> recordTypeSet = new Set<String>();
        String sDeveloperName = System.Label.XfinityTaskRecordType; //Get Developer Name Of Record Type And Fetch Record Only For That Record Type
        try{
        if(!string.IsBlank(sDeveloperName)){
            for(String str: sDeveloperName.split(DEVELOPER_NAME_SPLIT)){
                recordTypeSet.add(str);
            }
        }else{
            //Future code
        }                 
        Set<Id> recordTypeIdSet = new Set<Id>();
        for(RecordType rt: [SELECT  Id  FROM  RecordType 
                             WHERE SobjectType =: OBJECT_TYPE AND DeveloperName IN: recordTypeSet
                             LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            recordTypeIdSet.add(rt.Id);
        }
        
        long dateDifference;
        set<Id> leadIds = new set<Id>();
        set<Id> ownerIds = new set<Id>();
        Map<Id, Lead> leadsMap = new Map<Id, Lead>();
        Map<Id, Task> leadTasksMap = new Map<Id, Task>();
        
         /*Fetch all the completed tasks related to Leads with lead ids*/
        for (Task tsk : newTasksMap.values()){
            if(recordTypeIdSet.isEmpty() || !recordTypeIdSet.contains(tsk.RecordTypeId)){
                if (tsk.WhoId != null && String.Valueof(tsk.WhoId).StartsWith(LEAD_PREFIX) && tsk.Status == label.Task_Status_Completed){
                    if ((oldTasksMap == null) || (oldTasksMap != null && oldTasksMap.get(tsk.Id).Status != label.Task_Status_Completed)){
                        leadIds.add(tsk.WhoId); 
                        leadTasksMap.put(tsk.Id, tsk);  
                    } 
                } 
            }
        }
        if (!(leadIds.isEmpty())){
            /*Fetch all the leads for which competed task is being logged and time to touch not calculated*/
            for (Lead lead: [Select OwnerId, Ownership_Transfer_Date__c,  
                    CreatedDate, Affiliate_Account__c, Time_to_Touch__c, LeadSource  
                    from Lead WHERE Id =: leadIds AND 
                                    Time_to_Touch__c =: null]){
                leadsMap.put(lead.Id,lead); 
                ownerIds.add(lead.OwnerId);  
            }
            /*Discard the leads WHERE logged in user is integration user*/
            if (!(leadsMap.isEmpty())){
                Profile p = [Select Id, Name from Profile WHERE Name =: Label.Integration_User_Profile];
                
                for (User user: [Select ProfileId from User WHERE Id =: ownerIds]){
                    for (lead le : leadsMap.values()){
                        if ((user.Id == le.OwnerId) && (user.ProfileId == p.Id)){
                            leadsMap.remove(le.Id);
                        }
                    }   
                }
                /*Capture time to touch on remaining leads*/
                for (task tk : leadTasksMap.values()){
                        if(tk.WhoId!=null){
                            if(leadsMap.containsKey(tk.whoId)  && leadsMap.get(tk.WhoId) != null){
                                        if (trigger.IsInsert){
                                            if(leadsMap.get(tk.whoId).LeadSource == label.Lead_Source_Affiliate && leadsMap.get(tk.whoId).Ownership_Transfer_Date__c != null){
                                                dateDifference  = SubtractDate(leadTasksMap.get(tk.Id).createdDate,leadsMap.get(tk.whoId).Ownership_Transfer_Date__c);
                                            } else{
                                                dateDifference  = SubtractDate(leadTasksMap.get(tk.Id).createdDate,leadsMap.get(tk.whoId).createdDate);
                                            }
                                        }
                                        if (trigger.IsUpdate){
                                            if(leadsMap.get(tk.whoId).LeadSource == label.Lead_Source_Affiliate && leadsMap.get(tk.whoId).Ownership_Transfer_Date__c != null){
                                                dateDifference  = SubtractDate(leadTasksMap.get(tk.Id).LastModifiedDate,leadsMap.get(tk.whoId).Ownership_Transfer_Date__c);
                                            } else{
                                                dateDifference  = SubtractDate(leadTasksMap.get(tk.Id).LastModifiedDate,leadsMap.get(tk.whoId).createdDate);
                                            }
                                        }
                            if (dateDifference != null){
                                leadsMap.get(tk.whoId).Time_to_Touch__c = dateDifference;
                                leadsMap.get(tk.whoId).FirstModifiedBy__c = UserInfo.getUserId();
                                if (trigger.IsInsert){
                                    leadsMap.get(tk.whoId).FirstModifiedDate__c = leadTasksMap.get(tk.Id).createdDate;
                                } else {
                                    leadsMap.get(tk.whoId).FirstModifiedDate__c = leadTasksMap.get(tk.Id).LastModifiedDate;    
                                }
                            }
                        }
                    } 
                }
                try{
                    database.update (leadsMap.values()); 
                } catch (DmlException dmlEx){
                    for(Integer i =0; i<dmlEx.getNumDml(); ++i) { 
                        system.debug('*******Following Errors occurred on Lead Update ****** :' + dmlEx.getDmlMessage(i));
                    }
                }
            }
        }
        } catch(Exception ex){ String msg = ex.getMessage();} 
    }
    
    /**
    * @Description: This method Calculates the difference between two date time fields in days
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 30-November-2012
    * @Param: Datetime field 1, Datetime field 2
    * @Return: time difference in days.
    */
    public static Long SubtractDate(DateTime highDate, DateTime lowDate){
        Long timeDiff = highDate.getTime() - lowDate.getTime();
        return timeDiff/(60000*60*24);
    }
    
    /**
    * @Description: This method calculates the number of calls logged on Leads & Opportunities
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 30-November-2012
    * @Param: Datetime field 1, Datetime field 2
    * @Return: time difference in days.
    */
    public static void countCallLogs (Map<Id, Task> newTasksMap, Map<Id, Task> oldTasksMap) {
        
        set<Id> leadIds = new set<Id>();
        list<Lead> leadList = new List<Lead>();
        Map<Id, Integer> leadTasksMap = new Map<Id, Integer>();
        set<Id> opptyIds = new set<Id>();
        list<Opportunity> opptyList = new List<Opportunity>();
        Map<Id, Integer> opptyTasksMap = new Map<Id, Integer>();
        final String CALL = 'Call';
        
        String RecordTypeId = recordTypeMap.get(CALL).getRecordTypeId(); 
        if(Trigger.isInsert || Trigger.isUndelete){
            for (Task tsk : newTasksMap.values()){
                if (tsk.Status == Label.TaskStatusCompleted && tsk.RecordTypeId == RecordTypeId){
                    /* Fetch all tasks of type 'call' being logged in the system related to Leads*/
                    if (tsk.WhoId != null && String.Valueof(tsk.WhoId).StartsWith(LEAD_PREFIX)){ 
                        
                        leadIds.add(tsk.WhoId); 
                        if (leadTasksMap.containsKey(tsk.whoId)){
                            leadTasksMap.put(tsk.whoId,leadTasksMap.get(tsk.whoId) +1);
                        } else {
                            leadTasksMap.put(tsk.whoId,1);
                        }
                    }
                    /* Fetch all tasks of type 'call' being logged in the system related to Opportunities*/
                    if (tsk.WhatId != null && String.Valueof(tsk.WhatId).StartsWith(OPP_PREFIX)){
                        opptyIds.add(tsk.WhatId);
                        if (opptyTasksMap.containsKey(tsk.whatId)){
                            opptyTasksMap.put(tsk.whatId,opptyTasksMap.get(tsk.whatId) +1);
                        } else {
                            opptyTasksMap.put(tsk.whatId,1);
                        }
                    }
                }
            }
        }
        if(Trigger.isDelete){
            for (Task tsk : oldTasksMap.values()){
                if (tsk.Status == Label.TaskStatusCompleted && tsk.RecordTypeId == RecordTypeId){
                    /* Fetch all tasks of type 'call' being logged in the system related to Leads*/
                    if (tsk.WhoId != null && String.Valueof(tsk.WhoId).StartsWith(LEAD_PREFIX)){ 
                        
                        leadIds.add(tsk.WhoId); 
                        if (leadTasksMap.containsKey(tsk.whoId)){
                            leadTasksMap.put(tsk.whoId,leadTasksMap.get(tsk.whoId) -1);
                        } else {
                            leadTasksMap.put(tsk.whoId,-1);
                        }
                    }
                    /* Fetch all tasks of type 'call' being logged in the system related to Opportunities*/
                    if (tsk.WhatId != null && String.Valueof(tsk.WhatId).StartsWith(OPP_PREFIX)){
                        opptyIds.add(tsk.WhatId);
                        if (opptyTasksMap.containsKey(tsk.whatId)){
                            opptyTasksMap.put(tsk.whatId,opptyTasksMap.get(tsk.whatId) -1);
                        } else {
                            opptyTasksMap.put(tsk.whatId,-1);
                        }
                    }
                }
            }
        }
        /* Capture the call count on Leads*/
        if (!(leadIds.isEmpty())){
            for (Lead lead: [Select Id, Call_Count__c 
                                from Lead WHERE Id =: leadIds]){
                                   
                if (lead.Call_Count__c != null){
                    lead.Call_Count__c = lead.Call_Count__c + leadTasksMap.get(lead.Id); 
                } else {
                    lead.Call_Count__c = 0 + leadTasksMap.get(lead.Id);     
                }
                leadList.add(lead);       
            }
        }
        
        /* Capture the call count on Opportunities*/
        if (!(opptyIds.isEmpty())){
            for (Opportunity opp: [Select Id, Call_Count__c 
                                from Opportunity WHERE Id =: opptyIds]){
                 if(opp.Call_Count__c != null){               
                    opp.Call_Count__c = opp.Call_Count__c + opptyTasksMap.get(opp.Id);
                 } else{
                      opp.Call_Count__c = 0 + opptyTasksMap.get(opp.Id);    
                 }
                opptyList.add(opp);         
            } 
        }
        
        if(!opptyList.IsEmpty()){    
            try{
                database.update (opptyList, false); 
            } catch (DmlException dmlEx){
                for(Integer i =0; i<dmlEx.getNumDml(); ++i) { 
                system.debug('*******Following Errors occurred on Opportunity Update ****** :' + dmlEx.getDmlMessage(i));
                }
            }
        }
        if(!leadList.IsEmpty()){  
            try{
                database.update (leadList, false); 
            } catch (DmlException dmlEx){
                for(Integer i =0; i<dmlEx.getNumDml(); ++i) { 
                system.debug('*******Following Errors occurred on Lead Update ****** :' + dmlEx.getDmlMessage(i));
                }
            }
        }       
    }

    /**
    * @Description: This method retrieves the last Location point from the Location object and places it on the Task.
    * @Author: Erin McGee, Acumen Solutions
    * @Date: 17-Sep-2014
    * @Param: List<Task>
    * @Return: void.
    * @Last Modified: 1-Aug-2017, Malay Desai. US1139040 - Code updated to calculate Location Difference when Knock i
    * is done through SF1.   
    */
    public static void populateDispositionLocationandLocationDifference(List<Task> newTasksList) {
        final String KNOCK = 'Knock';
        final String KNOCK_MINUTES = 'KnockMinutes';
        String KnockRecordTypeId = recordTypeMap.get(KNOCK).getRecordTypeId();
        String GARecordTypeId = recordTypeMap.get(OBJECT_TYPE).getRecordTypeId();
        Set<Id> addressIds=new Set<Id>();
        List<Task> tasksToAddLocation= new List<Task>();
        try{
            for(Task task : newTasksList){
                if(task.RecordTypeId == KnockRecordTypeId || task.RecordTypeId == GARecordTypeId){
                    addressIds.add(task.WhatId);
                    tasksToAddLocation.add(task);
                }
            }
            Map<Id,Customer_Address__c> taskAddressMap= new Map<Id,Customer_Address__c>([Select Id, Latitude__c, Longitude__c From Customer_Address__c Where Id IN:addressIds]);
    
            ConfigurableParameters__c knockMinutes = ConfigurableParameters__c.getValues(KNOCK_MINUTES);
            List<Location__c> locationForTaskList=
                [SELECT Longitude__c, Latitude__c, Geocode_TimeStamp__c, CreatedDate 
                 FROM Location__c 
                 WHERE CreatedById =: userInfo.getUserId() 
                 AND CreatedDate >= : DateTime.now().addHours(-1) ORDER 
                 BY CreatedDate DESC LIMIT 1];
            if(!locationForTaskList.isEmpty()){
                Location__c locationForKnock=locationForTaskList.get(0);
                if(processLocationDateTime(locationForKnock.Geocode_TimeStamp__c) >= System.now().addMinutes(-Integer.valueOf(knockMinutes.NumberValue__c))){
                    for(Task task : tasksToAddLocation){
                        task.Disposition_Location__Latitude__s=locationForKnock.Latitude__c;
                        task.Disposition_Latitude__c=locationForKnock.Latitude__c;
                        task.Disposition_Location__Longitude__s=locationForKnock.Longitude__c;
                        task.Disposition_Longitude__c=locationForKnock.Longitude__c;
                        task.Location_Difference__c=getDistance(task,taskAddressMap.get(task.WhatId));
                    }
                }
            }else{
                for(Task task : tasksToAddLocation){
                    if(task.Disposition_Latitude__c != null && task.Disposition_Longitude__c !=null){
                        task.Location_Difference__c=getDistance(task,taskAddressMap.get(task.WhatId));
                    }
                }
            }
        } catch(Exception ex){ String msg = ex.getMessage();} 
    }
    

    @TestVisible private static Decimal getDistance(Task knock, Customer_Address__c knockedAddress){
         
        if (knock.Disposition_Latitude__c != null && knock.Disposition_Longitude__c!= null  && 
            knockedAddress.Latitude__c != null && knockedAddress.Longitude__c != null){
            double r = 3963.1;
            double toRad = 57.29577951;
            
            double kLat = double.valueOf(knock.Disposition_Latitude__c) / toRad;
            double kLon = double.valueOf(knock.Disposition_Longitude__c) / toRad;
            double aLat = double.valueOf(knockedAddress.Latitude__c) / toRad;
            double aLon = double.valueOf(knockedAddress.Longitude__c) / toRad;
            Decimal a = math.sin(kLat) * math.sin(aLat) + math.cos(kLat) * math.cos(aLat) * math.cos(kLon - aLon);
            Decimal c = math.acos(a);
            Decimal distance = (r * c).setScale(2);
            return distance;
        }
        else{ return 0;}
    }

    @TestVisible private static DateTime processLocationDateTime(string dt){
        integer year = Integer.valueOf(dt.substring(0,4));
        integer month =  Integer.valueOf(dt.substring(5,7));
        integer day =  Integer.valueOf(dt.substring(8,10));
        integer hour =  Integer.valueOf(dt.substring(11,13));
        integer min =  Integer.valueOf(dt.substring(14,16));
        integer sec =  Integer.valueOf(dt.substring(17,19));
        date d =date.newInstance(year, month, day);
        Time t = time.newInstance(hour, min, sec, 0);
        DateTime finalDt = dateTime.newInstance(d, t);
        return finalDt;
    }
    
    
    
    /**
    * @Description: This method update current value of metricses when task is created(1:1 coaching, team Huddles, Team forum).
    * @Author: Rahul Prabhakar, Accenture
    * @Created Date: 03-Dec-2015
    * @Param: List<Task>
    * @Return: void.
    
    * @Last Modified by : Ashish Srivastava, Accenture
    * @Last Modified Date : 22-03-2017
    * @Description : Code Added for US1051011 and US1051026
    */
    
    public static void metricUpdate(List<Task> newTasksList){
        try{ 
            final String coachingString = '1:1 Coaching', huddleString = 'Team Huddles',forumString = 'Team Forum';
            final String publishedString = 'Published', forumMetricName = 'Team Forums';
            final String CARTeamHuddleString = 'CAR Team Huddle', CARTeamForumString = 'CAR Team Forum';
            MetricTriggerController.allowValidation = false;      
            String oneAsOneRecordTypeId = recordTypeMap.get(coachingString).getRecordTypeId();
            String teamHuddlesRecordTypeId = recordTypeMap.get(huddleString).getRecordTypeId();
            String teamForumRecordTypeId = recordTypeMap.get(forumString).getRecordTypeId();
            String CARTeamHuddleRecordTypeId = recordTypeMap.get(CARTeamHuddleString).getRecordTypeId();
            String CARTeamForumRecordTypeId = recordTypeMap.get(CARTeamForumString).getRecordTypeId();
            String loggedInUserId = UserInfo.getUserId();
            String shortProfileId = String.valueOf(UserInfo.getProfileId()).substring(0, 15); 
            String xseUser = '';
            List<Metric> metricUpdateList = new List<Metric>();
            Set<Id> xspId = new Set<Id>(); 
            Set<Id> CARDirectorOrSrManagersIds = new Set<Id>(); // Contains CAR Director/Sr Manager
            Set<Id> CARManagerIds = new Set<Id>(); //Contains CAR Managers Ids
            Date startTemplateDate = NULL, dueTemplateDate = NULL;
            GoalTemplateDates__c templateDates = NULL;        
            Profile xspProfile = [SELECT Id, Name FROM Profile WHERE Name =: Label.xspProfileName];
            Profile carMgrProfile = [SELECT Id,Name FROM Profile WHERE Name = :Label.Xfinity_CARmanager_ProfileName];
            List<Metric> listOfMetrics,listOfNewMetrics,CARManagerMetricList,CARDirOrSrMgrMetricList;
            Set<String> profileNameString = new Set<String>{Label.DS_Manager,Label.DS_Supervisor,Label.DSRProfileName,Label.DirectSalesDirectorProfile};
            
            for(PermissionSetAssignment psa :  [SELECT AssigneeId FROM PermissionSetAssignment 
                        WHERE PermissionSet.Name = :PL_Constants.PERM_SET_FOR_CAR_DIR_SR_MGR]){
                    CARDirectorOrSrManagersIds.add(psa.AssigneeId);  //Set for CAR Director User Ids                           
            }
            if(UserInfo.getProfileId() == carMgrProfile.Id && !CARDirectorOrSrManagersIds.contains(loggedInUserId)){
                CARManagerIds.add(loggedInUserId); //Set for CAR Manager Ids
            }
            if(UserInfo.getProfileId() == xspProfile.Id){    
                 for(PermissionSetAssignment p : [SELECT PermissionSetId,AssigneeId,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =: loggedInUserId and PermissionSet.Name =: Label.xsePermissionSetName ]){
                    xspId.add(p.AssigneeId);
                    xseUser = string.valueof(xspId);
                }
            }
            for(Task TaskTemp : newTasksList){
                if(taskTemp.RecordtypeId!=null){
                    if(taskTemp.RecordtypeId.equals(oneAsOneRecordTypeId) || taskTemp.RecordtypeId.equals(teamForumRecordTypeId) 
                    || (taskTemp.RecordtypeId.equals(teamHuddlesRecordTypeId) && (ShortProfileId == Label.DSSProfileIdLabel || (xseUser !=null && xseUser.contains(loggedInUserId))  ))) {
                        templateDates = GoalTemplateDates__c.getInstance(Label.ActivityGoalCommissionCycle);
                        if(templateDates != null){
                            startTemplateDate = templateDates.Current_Period_Start_Date__c;
                            dueTemplateDate = templateDates.Current_Period_Due_Date__c;
                        }                    
                        //Date dueTemplateDate = Date.valueOf(templateDates.get('Current_Period_Due_Date__c'));
                    }
                    else{
                        if((taskTemp.RecordtypeId.equals(CARTeamHuddleRecordTypeId) && CARManagerIds != null && CARManagerIds.contains(loggedInUserId))
                            ||(taskTemp.RecordtypeId.equals(CARTeamForumRecordTypeId) && CARDirectorOrSrManagersIds != null && CARDirectorOrSrManagersIds.contains(loggedInUserId))){
                            templateDates = GoalTemplateDates__c.getInstance(Label.PL_MonthlyGoalCreationBatchCusSetData);
                            if(templateDates != null){
                                startTemplateDate = templateDates.Current_Period_Start_Date__c;
                                dueTemplateDate = templateDates.Current_Period_Due_Date__c;
                            }
                        }
                    }
                }           
            }        
            Integer remainingDays = dueTemplateDate!=null?System.today().daysBetween(dueTemplateDate):0;     
            User usr = [Select id,name,Profile.Name,ManagerId from User where Id =:loggedInUserId];
            //Check for Coach For CAR Channel
            if(usr.Profile.Name == Label.Xfinity_CARmanager_ProfileName){
                if(CARManagerIds.contains(usr.Id)){
                    Map<Id,Goal> CARManagerGoal = new Map<Id,Goal>([SELECT Id,Name,OwnerId FROM Goal WHERE OwnerId = :usr.Id and
                    status =:publishedString and StartDate =:startTemplateDate and DueDate =:dueTemplateDate]);
                    Set<Id> carMgrGoalId = CARManagerGoal.keyset();
                    CARManagerMetricList = [SELECT Id,Name,CurrentValue,TargetValue FROM Metric WHERE Goal.id IN: carMgrGoalId and ownerid =:usr.Id];
                } else if(CARDirectorOrSrManagersIds.contains(usr.Id)){
                    Map<Id,Goal> CARDirOrSrMgrGoal = new Map<Id,Goal>([SELECT Id,Name,OwnerId FROM Goal WHERE OwnerId = :usr.Id and
                    status =:publishedString and StartDate =:startTemplateDate and DueDate =:dueTemplateDate]);
                    Set<Id> CARDirOrSrMgrGoalId = CARDirOrSrMgrGoal.keyset();
                    CARDirOrSrMgrMetricList = [SELECT Id,Name,CurrentValue,TargetValue FROM Metric WHERE Goal.id IN: CARDirOrSrMgrGoalId and ownerid =:usr.Id];
                } else{}
            }
            // Check for Direct Channel
            else if(profileNameString.contains(usr.Profile.Name)){
                Map<Id,Goal> activityGoal = new Map<Id,Goal>([Select id, ownerid,name from Goal where ownerid =:usr.ManagerId and status =:publishedString and StartDate =:startTemplateDate and DueDate =:dueTemplateDate ]);
                Set<Id> activityGoalId = activityGoal.keyset();
                listOfMetrics = [select id,name,CurrentValue,targetvalue from Metric where Goal.id IN: activityGoalId and ownerid =:usr.ManagerId]; 
                Map<Id,Goal> activityGoalMap = new Map<Id,Goal>([Select id, ownerid,name from Goal where ownerid =:usr.Id and status =:publishedString and StartDate =:startTemplateDate and DueDate =:dueTemplateDate ]);
                Set<Id> activityGoalSetId  = activityGoalMap.keyset();
                listOfNewMetrics = [select id,name,CurrentValue,targetvalue from Metric where Goal.id IN: activityGoalSetId and ownerid =:usr.Id];
            }
            
            for(Task TaskTemp : newTasksList){
                if(taskTemp.RecordtypeId!=null){                
                    if(taskTemp.RecordtypeId.equals(oneAsOneRecordTypeId)) {
                        if(listOfMetrics != null && !listOfMetrics.Isempty()){
                            for(Metric metric:listOfMetrics){
                                if(metric.Name.equalsIgnoreCase(coachingString)){
                                    metric.CurrentValue =  metric.CurrentValue!=null?metric.CurrentValue+1:1; 
                                    MetricStatusUpdateUtil.updateSdmAsmStatusPickList(metric,remainingDays);                         
                                    metricUpdateList.add(metric);
                                } 
                            } 
                        }
                    }               
                    else if(taskTemp.RecordtypeId.equals(teamForumRecordTypeId) || (taskTemp.RecordtypeId.equals(teamHuddlesRecordTypeId) && shortProfileId == Label.DSSProfileIdLabel)){
                        if(listOfNewMetrics !=null && !listOfNewMetrics.Isempty()){
                            for(Metric metric:listOfNewMetrics){
                                if(metric.Name.equalsIgnoreCase(forumMetricName) || metric.Name.equalsIgnoreCase(huddleString)){
                                    metric.CurrentValue =  metric.CurrentValue!=null?metric.CurrentValue+1:1;  
                                    MetricStatusUpdateUtil.updateSdmAsmStatusPickList(metric,remainingDays);                        
                                    metricUpdateList.add(metric);
                                } 
                            } 
                        }                   
                    }                
                    else if (taskTemp.RecordtypeId.equals(teamHuddlesRecordTypeId) && xseUser!= null && xseUser.contains(loggedInUserId)) {
                        if(listOfMetrics != null && !listOfMetrics.Isempty()){   
                            for(Metric metric:listOfMetrics){
                                if(metric.Name.equalsIgnoreCase(huddleString)){
                                    metric.CurrentValue =  metric.CurrentValue!=null?metric.CurrentValue+1:1; 
                                    MetricStatusUpdateUtil.updateSdmAsmStatusPickList(metric,remainingDays);                         
                                    metricUpdateList.add(metric);
                                } 
                            } 
                        }                   
                    }
                    // Last Modifed by : Ashish Srivastava 
                    // Description : Code Added for US1051011 (Sprint 49) - Update Huddle Metric for CAR Manager
                    else if(taskTemp.RecordtypeId.equals(CARTeamHuddleRecordTypeId)){
                        if(CARManagerMetricList!=null && !CARManagerMetricList.isEmpty()){
                            for(Metric metric : CARManagerMetricList){
                                if(metric.Name.equalsIgnoreCase(PL_Constants.METRIC_NAME_HUDDLES)){  
                                    metric.CurrentValue =  metric.CurrentValue!=null?metric.CurrentValue+1:1;
                                    metricUpdateList.add(metric);
                                } else{}
                            }
                        } else{}
                    }
                    // Last Modifed by : Ashish Srivastava 
                    // Description : Code Added for US1051026 (Sprint 50) - Update Forum Metric for CAR Director
                    else if(taskTemp.RecordtypeId.equals(CARTeamForumRecordTypeId)){
                        if(CARDirOrSrMgrMetricList != null && !CARDirOrSrMgrMetricList.isEmpty()){
                            for(Metric metric : CARDirOrSrMgrMetricList){
                                if(metric.Name.equalsIgnoreCase(PL_Constants.METRIC_NAME_FORUM)){
                                    metric.CurrentValue =  metric.CurrentValue!=null?metric.CurrentValue+1:1;
                                    metricUpdateList.add(metric);
                                }
                            }
                        }
                    }else{}             
                } else {}            
            }
            
            if(metricUpdateList != null && !metricUpdateList.isEmpty()){
                Database.update(metricUpdateList,false);
            }   
        }catch(Exception ex) {
            System.debug('****Following Error Occurred **** :' + ex.getMessage());
        }
        
    }

     /**
      * @Description: This method will post a team huddle or team forum feed to private chatter group and will include all the reps in that group as @mention
      * @Author: Mandeep Singh, Accenture
      * @Date: 11-March-2016
      * @Param: none
      * Last Modified By : Tejaswini Kasar(US1106419)
      * Last Modified Date : 11 July 2017
      * Description : Code Added for US1106419 (CAR process removed from feed post for "CAR team forum") 
    */ 
    public static void createfeedpost(List<Task> newTasksList) {
        String teamHuddlesRecordTypeId = recordTypeMap.get(TEAM_HUDDLE_RECORDTYPE).getRecordTypeId();
        String teamForumRecordTypeId = recordTypeMap.get(TEAM_FORUM_RECORDTYPE).getRecordTypeId();
        String teamCarTeamHuddleRecordTypeId = recordTypeMap.get(CAR_TEAM_HUDDLE_RECORDTYPE).getRecordTypeId();
        String teamCarTeamForumRecordTypeId = recordTypeMap.get(CAR_TEAM_FORUM_RECORDTYPE).getRecordTypeId();
        Id loggedInUserProfileId = UserInfo.getProfileId();
        Id loggedInUserId = UserInfo.getUserId();
        set<id> groupid2 = new set<id>();
        Id SystemAdminProfileId = [select id, name from profile WHERE name =: SYSTEM_ADMIN].id ;
        List<Id> repId = new List<Id>();
        for(User usr: [SELECT  Id , Name from User WHERE ManagerId =: UserInfo.getUserId() AND isActive = true]){
            if(usr != null)
                repId.add(usr.id);
        }
        Map<Id,List<CollaborationGroupMember>> colGrpMemberMap = new Map<Id,List<CollaborationGroupMember>>();
        Map<Id,List<CollaborationGroupMember>> colGrpMemberMap2 = new Map<Id,List<CollaborationGroupMember>>();
        for(CollaborationGroup collaborationGroup: [SELECT Id,Name,Description,CollaborationType FROM CollaborationGroup WHERE CollaborationType =: PRI_VATE AND (Description LIKE : TEAM_HUDDLE OR Description  LIKE : TEAM_FORUM )]){
            if(collaborationGroup != null)
                colGrpMemberMap.put(collaborationGroup.id, new List<CollaborationGroupMember>());
        }
        if(loggedInUserProfileId != SystemAdminProfileId ){
        for(CollaborationGroupMember colAdmin : [SELECT CollaborationGroupId,MemberId,CollaborationRole  FROM CollaborationGroupMember WHERE  MemberId =: loggedInUserId AND CollaborationRole =: ADMIN AND  CollaborationGroupId IN : colGrpMemberMap.keySet()]){
            groupid2.add(colAdmin.CollaborationGroupId);          
         }
        }        
        for(CollaborationGroup collaborationGroup2: [SELECT Id,Name,Description,CollaborationType FROM CollaborationGroup WHERE id in : groupid2]){
            if(collaborationGroup2 != null)
                colGrpMemberMap2.put(collaborationGroup2.id, new List<CollaborationGroupMember>());
        }
        for(CollaborationGroupMember colMem: [SELECT CollaborationGroupId,MemberId,CollaborationRole  FROM CollaborationGroupMember WHERE  MemberId IN:repId AND CollaborationGroupId IN : groupid2]){
           if(colGrpMemberMap2.get(colMem.CollaborationGroupId)==null){
                colGrpMemberMap2.put(colMem.CollaborationGroupId, new List<CollaborationGroupMember>());
            }
            colGrpMemberMap2.get(colMem.CollaborationGroupId).add(colMem);
        }
        for(Task taskTemp : newTasksList){
            if(taskTemp.RecordtypeId!=null){
                if((taskTemp.RecordtypeId.equals(teamHuddlesRecordTypeId)) || 
                   (taskTemp.RecordtypeId.equals(teamForumRecordTypeId)) || 
                   (taskTemp.RecordtypeId.equals(teamCarTeamHuddleRecordTypeId)) || 
                   (taskTemp.RecordtypeId.equals(teamCarTeamForumRecordTypeId)) ){

                    String subjectVal = String.isBlank(taskTemp.Subject)?EMPTY_STR:taskTemp.Subject;
                    String HuddleForumName = String.isBlank(taskTemp.Huddle_Forum_Name__c)?EMPTY_STR:taskTemp.Huddle_Forum_Name__c;
                    String CarHuddleName = String.isBlank(taskTemp.CAR_Huddle_Forum_Name__c)?EMPTY_STR:taskTemp.CAR_Huddle_Forum_Name__c;
                    String CarForumName = String.isBlank(taskTemp.Forum_Name__c)?EMPTY_STR:taskTemp.Forum_Name__c;
                    String display;
                    String dueDateVal = String.isBlank(String.valueof(TaskTemp.ActivityDate))?EMPTY_STR:String.valueof(TaskTemp.ActivityDate);
                    String commentsString = String.isBlank(taskTemp.Description)?EMPTY_STR:taskTemp.Description;
                    //Checking the record type id for Team huddle and Team Forum 
                    if((taskTemp.RecordtypeId.equals(teamHuddlesRecordTypeId)) || (taskTemp.RecordtypeId.equals(teamForumRecordTypeId))){
                        //Construct Feed body
                        display = DOUBLE_LINE_BREAK + SUBJECT_STR + SINGLE_SPACE+subjectVal + SINGLE_LINE_BREAK +
                        SALES_PROCESS_STR + SINGLE_SPACE + taskTemp.Sales_Process__c + SINGLE_LINE_BREAK +
                        HUDDLEFORUM_STR + SINGLE_SPACE + HuddleForumName + SINGLE_LINE_BREAK +
                        STATUS_STR + SINGLE_SPACE + taskTemp.Status + SINGLE_LINE_BREAK +
                        COMMENTS_STR + SINGLE_SPACE + commentsString + SINGLE_LINE_BREAK +
                        DUE_DATE_STR + SINGLE_SPACE + dueDateVal;
                    }
                    //Checking the record type id for Team Car huddle and Team Car Forum
                    //Modified by :Tejaswini Kasar(US1106419)
                    //Date : 11 July 2017
                    //HUDDLE/FORUM name changed to HUDDLE NAME"
                    else if(taskTemp.RecordtypeId.equals(teamCarTeamHuddleRecordTypeId) ){
                        display = DOUBLE_LINE_BREAK + SUBJECT_STR + SINGLE_SPACE+subjectVal + SINGLE_LINE_BREAK +
                        CAR_PROCESS_STR + SINGLE_SPACE + taskTemp.CAR_Process__c+ SINGLE_LINE_BREAK +
                        HUDDLE_NAME_STR + SINGLE_SPACE + CarHuddleName + SINGLE_LINE_BREAK +//HUDDLE/FORUM name changed to HUDDLE NAME"
                        STATUS_STR + SINGLE_SPACE + taskTemp.Status + SINGLE_LINE_BREAK +
                        COMMENTS_STR + SINGLE_SPACE + commentsString + SINGLE_LINE_BREAK +
                        DUE_DATE_STR + SINGLE_SPACE + dueDateVal;
                    }
                    //Added by :Tejaswini Kasar(US1106419)
                    //CAR process removed from feed post for "CAR team forum"
                    //Date : 11 July 2017
                    //Start (US1106419)             
                    else if(taskTemp.RecordtypeId.equals(teamCarTeamForumRecordTypeId)){
                        display = DOUBLE_LINE_BREAK + SUBJECT_STR + SINGLE_SPACE+subjectVal + SINGLE_LINE_BREAK +
                        FORUM_NAME_STR + SINGLE_SPACE + CarForumName + SINGLE_LINE_BREAK +
                        STATUS_STR + SINGLE_SPACE + taskTemp.Status + SINGLE_LINE_BREAK +
                        COMMENTS_STR + SINGLE_SPACE + commentsString + SINGLE_LINE_BREAK +
                        DUE_DATE_STR + SINGLE_SPACE + dueDateVal;
                    }//end(US1106419)
                    else{}
                    
                    for(ID groupId: colGrpMemberMap2.keySet()){
                        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
                        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

                        //Create FeedItemInput to hold message body 
                        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();

                        feedItemInput.body = messageInput;
                        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                        feedItemInput.subjectId = groupId;
                        for(CollaborationGroupMember grpMemberId : colGrpMemberMap2.get(groupId)){
                            if(grpMemberId!=null){
                                //Create mention segment to hold an @mention
                                ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                                mentionSegment.id = grpMemberId.MemberId ;
                                messageInput.messageSegments.add(mentionSegment);
                            } else{}
                        } 
                        //Create text segment to hold message body
                        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                        textSegmentInput.text = display;
                        messageInput.messageSegments.add(textSegmentInput);   
                        try { 
                            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput, null);
                        } catch (Exception ex){
                            System.debug('****Following Error Occurred **** :' + ex.getMessage());
                        }
                    }
                }
            }
        } 
    } 
    
     /**
    * @Description: This method is used to get the knocks and pass them to the trigger.
    * @Author: Lalit Singh , Accenture
    * @Date: 07-July-2015
    * @Param: List<Task>
    * @Return: void.
    */
    /*
    public static void newKnockRollUpData(List<Task> taskLst) {
        List<Task> taskToSummerize = new List<Task>();
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId();
           for(Task tsk : taskLst){
                if(tsk.recordTypeId == recordTypeId){
                    taskToSummerize.add(tsk);
                }
           }
                if(taskToSummerize != null && taskToSummerize.size() > 0){
                        //TaskTriggerController.newRollUpSummaryData(taskToSummerize);
                        newRollUpSummaryData(taskToSummerize);
                }
    }*/
    /**
    * @Description: This method creates the new roll up data for the knock for the reps.
    * @Author: Lalit Singh , Accenture
    * @Date: 07-July-2015
    * @Param: List<Task>
    * @Return: void.
    */
    /*
    public static void newRollUpSummaryData(List<Task> knockLst) {
        Map<String, User> userMap = new Map<String, User>();
        Map<String, List<Task>> summeryKnock = new Map<String, List<Task>>();
        Map<String, Date> knockDateMap = new Map<String, Date>();
        Map<String, Integer> knockHourMap = new Map<String, Integer>();
        Map<String, String> dsrKnockDateMap = new Map<String, String>();
        set<String> dsr = new set<String>();
        for(Task knock : knockLst){
            dsr.add(knock.OwnerId);
        }
        for(User usr : [select FirstName ,Username ,LastName,CreatedById,ManagerId, Manager.Name,Manager.Manager.Name,PERNR__c,Region_Formula__c,Comcast_Division__c,TimeZoneSidKey from User WHERE Id IN :dsr]){
            userMap.put(usr.FirstName + ' ' + usr.LastName, usr);
        }
        
        for(Task knock: knockLst){
             DateTime knockDT = knock.createdDate;
             String strConvertedDate = knockDT.format('MM/dd/yyyy HH:mm:ss',userMap.get(knock.OwnerFullName__c).TimeZoneSidKey);
             List<String> knckDt = strConvertedDate.split(' ');
             List<String> splitedDate = knckDt[0].split('/');
             List<String> SplitedTime = knckDt[1].split(':');
             dsrKnockDateMap.put(knock.Id ,knckDt[0]);
             Date newDate = Date.newInstance(Integer.valueof(splitedDate[2]),  Integer.valueof(splitedDate[0]),Integer.valueof(splitedDate[1]));
             String GtDate = newDate.format();
             Date datetoPass = Date.parse(GtDate);
             knockDateMap.put(knock.Id ,datetoPass);
             knockHourMap.put(knock.Id , Integer.valueof(SplitedTime[0]));
             String key = knock.OwnerFullName__c + knckDt[0] + String.valueof(knock.Off_Turf__c);
            if(summeryKnock.containsKey(key)){
                List<Task> tempLst = new List<Task>();
                tempLst = summeryKnock.get(key);
                tempLst.add(knock);
                summeryKnock.put(key,tempLst);
            }
            else{
                List<Task> tempLst = new List<Task>();
                tempLst.add(knock);
                summeryKnock.put(key,tempLst);
            }
        }
        List<Knock_Summary__c> summeryToUpdate = new List<Knock_Summary__c>();
        Map<String, Knock_Summary__c> existingSummery = new Map<String, Knock_Summary__c>();
        
        for(Knock_Summary__c summery : [select Id, Key__c,On_Turf__c, UserName__c,Bulk_Billed_Master__c,Bulk_Billed_MDU__c,Close__c,Commercial__c,
                                               Contact__c,CreatedById,CreatedDate,Discover__c,Divison__c,Door_Hanger__c,Dsr__c,Engage__c,
                                               EXCLUDE_MAPPING__c,IsDeleted,Knocked_Date_00_Hour__c,Knocked_Date_01_Hour__c,Knocked_Date_02_Hour__c,
                                               Knocked_Date_03_Hour__c,Knocked_Date_04_Hour__c,Knocked_Date_05_Hour__c,Knocked_Date_06_Hour__c,
                                               Knocked_Date_07_Hour__c,Knocked_Date_08_Hour__c,Knocked_Date_09_Hour__c,Knocked_Date_10_Hour__c,
                                               Knocked_Date_11_Hour__c,Knocked_Date_12_Hour__c,Knocked_Date_13_Hour__c,Knocked_Date_14_Hour__c,
                                               Knocked_Date_15_Hour__c,Knocked_Date_16_Hour__c,Knocked_Date_17_Hour__c,Knocked_Date_18_Hour__c,
                                               Knocked_Date_19_Hour__c,Knocked_Date_20_Hour__c,Knocked_Date_21_Hour__c,Knocked_Date_22_Hour__c,
                                               Knocked_Date_23_Hour__c,Knock_Date__c,KNOCK_DAY__c,LastActivityDate,LastModifiedById,LastModifiedDate,
                                               Manager__c,MDU__c,Multiple_Dwelling_Unit__c,Name,Non_Bulk_Billed_MDU__c,Non_Bulk_Billed__c,
                                               Non_Marketable_Address__c,No_Answer__c,No_Knock__c,OTHER__c,OwnerId,Pernr__c,Position__c,Region__c,
                                               SFU__c,Single_Family_Unit__c,Single_Family__c,Start__c,Supervisor__c,SystemModstamp,Unknown__c,Vacant__c from Knock_Summary__c WHERE Key__c IN :summeryKnock.keySet()]){
            existingSummery.put(summery.Key__c, summery);
        }
        for(String knockKey : summeryKnock.keySet()){
            Knock_Summary__c newknockSummary = new Knock_Summary__c();
            
            if(existingSummery.containsKey(knockKey)){
                newknockSummary = existingSummery.get(knockKey);
            }
            User knowckUser = userMap.get(summeryKnock.get(knockKey)[0].OwnerFullName__c);            
            newknockSummary.Key__c = knockKey;
            newknockSummary.Knock_Date__c = summeryKnock.get(knockKey)[0].createdDate;
            //newknockSummary.DsrKnockDate__c = dsrKnockDateMap.get(summeryKnock.get(knockKey)[0].Id);
            if(knowckUser.Comcast_Division__c != null && knowckUser.Region_Formula__c != null){
                newknockSummary.Divison__c = knowckUser.Comcast_Division__c;
                newknockSummary.Region__c  = knowckUser.Region_Formula__c;
                newknockSummary.Supervisor__c = knowckUser.Manager.Name;
                newknockSummary.Manager__c = knowckUser.Manager.Manager.Name;
            }
            newknockSummary.Pernr__c  = knowckUser.PERNR__c;
            newknockSummary.Dsr__c  = knowckUser.FirstName + knowckUser.LastName;
            newknockSummary.UserName__c = knowckUser.Username;
            DateTime myDate = newknockSummary.Knock_Date__c;
            DateTime myDateTime = (DateTime) myDate;
            String dayOfWeek = myDateTime.format('EEEE');
            newknockSummary.KNOCK_DAY__c = dayOfWeek;
            if(summeryKnock.get(knockKey)[0].Off_Turf__c == true){
                newknockSummary.On_Turf__c = 'No';              
            }
            else{
                newknockSummary.On_Turf__c = 'Yes';
            }
            for(Task knock : summeryKnock.get(knockKey)){
               if(knock.Disposition__c == NoKnock){
                    if(newknockSummary.No_Knock__c == null){
                        newknockSummary.No_Knock__c = 0;
                    }
                    newknockSummary.No_Knock__c = newknockSummary.No_Knock__c + 1;
                }
                else if(knock.Disposition__c == NoAnswer){
                    if(newknockSummary.No_Answer__c == null){
                        newknockSummary.No_Answer__c = 0;
                    }
                    newknockSummary.No_Answer__c = newknockSummary.No_Answer__c + 1;
                }
                else if(knock.Disposition__c == DoorHanger){
                    if(newknockSummary.Door_Hanger__c == null){
                        newknockSummary.Door_Hanger__c = 0;
                    }
                    newknockSummary.Door_Hanger__c = newknockSummary.Door_Hanger__c + 1;
                }
                else if(knock.Disposition__c == contact){
                    if(newknockSummary.Contact__c == null){
                        newknockSummary.Contact__c = 0;
                    }
                    newknockSummary.Contact__c = newknockSummary.Contact__c + 1;
                }
                else if(knock.Disposition__c == Engage){
                    if(newknockSummary.Engage__c ==null){
                        newknockSummary.Engage__c = 0;
                    }
                    newknockSummary.Engage__c = newknockSummary.Engage__c + 1;
                }
                else if(knock.Disposition__c == Discover){
                    if(newknockSummary.Discover__c == null){
                        newknockSummary.Discover__c = 0;
                    }
                    newknockSummary.Discover__c = newknockSummary.Discover__c + 1;
                }
                else if(knock.Disposition__c == Position){
                    if(newknockSummary.Position__c == null){
                        newknockSummary.Position__c = 0;
                    }
                    newknockSummary.Position__c = newknockSummary.Position__c + 1;
                }
                else if(knock.Disposition__c == Close){
                    if(newknockSummary.Close__c ==  null){
                        newknockSummary.Close__c = 0;
                    }
                    newknockSummary.Close__c = newknockSummary.Close__c + 1;
                }
                else if(knock.Disposition__c == Start){
                    if(newknockSummary.Start__c ==  null){
                        newknockSummary.Start__c = 0;
                    }
                    newknockSummary.Start__c = newknockSummary.Start__c + 1;
                }
                else if(knock.Disposition__c == NonMarketableAddress){
                    if(newknockSummary.Non_Marketable_Address__c ==null){
                        newknockSummary.Non_Marketable_Address__c = 0;
                    }
                    newknockSummary.Non_Marketable_Address__c = newknockSummary.Non_Marketable_Address__c + 1;
                }
                if(knock.Dwelling_Type__c == SingleFamily){
                    if(newknockSummary.Single_Family__c == null){
                        newknockSummary.Single_Family__c = 0;
                    }
                    newknockSummary.Single_Family__c = newknockSummary.Single_Family__c+1;
                }
                else if(knock.Dwelling_Type__c == BulkBilledMaster){
                    if(newknockSummary.Bulk_Billed_Master__c == null){
                        newknockSummary.Bulk_Billed_Master__c =0;
                    }
                    newknockSummary.Bulk_Billed_Master__c = newknockSummary.Bulk_Billed_Master__c+1;
                }
                else if(knock.Dwelling_Type__c == Commercial){
                    if(newknockSummary.Commercial__c == null){
                        newknockSummary.Commercial__c = 0;
                    }
                    newknockSummary.Commercial__c = newknockSummary.Commercial__c+1;
                }
                else if(knock.Dwelling_Type__c == BulkBilledMDU){
                    if(newknockSummary.Bulk_Billed_MDU__c ==null){
                        newknockSummary.Bulk_Billed_MDU__c =0;
                    }
                    newknockSummary.Bulk_Billed_MDU__c = newknockSummary.Bulk_Billed_MDU__c+1;
                }
                else if(knock.Dwelling_Type__c == NonBulkBilledMDU){
                    if(newknockSummary.Non_Bulk_Billed_MDU__c ==null){
                        newknockSummary.Non_Bulk_Billed_MDU__c = 0;
                    }
                    newknockSummary.Non_Bulk_Billed_MDU__c = newknockSummary.Non_Bulk_Billed_MDU__c+1;
                }
                else if(knock.Dwelling_Type__c == Unknown){
                    if(newknockSummary.Unknown__c ==null){
                        newknockSummary.Unknown__c =0;
                    }
                    newknockSummary.Unknown__c = newknockSummary.Unknown__c+1;
                }
                else if(knock.Dwelling_Type__c == SingleFamilyUnit){
                    if(newknockSummary.Single_Family_Unit__c == null){
                        newknockSummary.Single_Family_Unit__c =0;
                    }
                    newknockSummary.Single_Family_Unit__c = newknockSummary.Single_Family_Unit__c+1;
                }
                else if(knock.Dwelling_Type__c == MultipleDwellingUnit){
                    if(newknockSummary.Multiple_Dwelling_Unit__c == null){
                        newknockSummary.Multiple_Dwelling_Unit__c =0;
                    }
                    newknockSummary.Multiple_Dwelling_Unit__c = newknockSummary.Multiple_Dwelling_Unit__c+1;
                }
                else if(knock.Dwelling_Type__c == Vacant){
                    if(newknockSummary.Vacant__c ==null){
                        newknockSummary.Vacant__c =0;
                    }
                    newknockSummary.Vacant__c = newknockSummary.Vacant__c+1;
                }
                else if(knock.Dwelling_Type__c == NonBulkBilled){
                    if(newknockSummary.Non_Bulk_Billed__c ==null){
                        newknockSummary.Non_Bulk_Billed__c =0;
                    }
                    newknockSummary.Non_Bulk_Billed__c = newknockSummary.Non_Bulk_Billed__c+1;
                }
                else if(knock.Dwelling_Type__c == SFU){
                    if(newknockSummary.SFU__c == null){
                        newknockSummary.SFU__c =0;
                    }
                    newknockSummary.SFU__c = newknockSummary.SFU__c+1;
                }
                else if(knock.Dwelling_Type__c == MDU){
                    if(newknockSummary.MDU__c == null){
                        newknockSummary.MDU__c =0;
                    }
                    newknockSummary.MDU__c = newknockSummary.MDU__c+1;
                }
                else if(knock.Dwelling_Type__c == OTHER){
                    if(newknockSummary.OTHER__c == null){
                        newknockSummary.OTHER__c =0;
                    }
                    newknockSummary.OTHER__c = newknockSummary.OTHER__c+1;
                }
                else if(knock.Dwelling_Type__c == EXCLUDEMAPPING){
                    if(newknockSummary.EXCLUDE_MAPPING__c==null){
                        newknockSummary.EXCLUDE_MAPPING__c =0;
                    }
                    newknockSummary.EXCLUDE_MAPPING__c = newknockSummary.EXCLUDE_MAPPING__c+1;
                }
                Integer hrs = knockHourMap.get(knock.Id);
                if(hrs == 00){
                    if(newknockSummary.Knocked_Date_00_Hour__c==null){
                        newknockSummary.Knocked_Date_00_Hour__c = 0;
                    }
                    newknockSummary.Knocked_Date_00_Hour__c = newknockSummary.Knocked_Date_00_Hour__c + 1;
                }               
                else if(hrs == 01){
                    if(newknockSummary.Knocked_Date_01_Hour__c == null){
                        newknockSummary.Knocked_Date_01_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_01_Hour__c = newknockSummary.Knocked_Date_01_Hour__c + 1;
                }
                else if(hrs == 02){
                    if(newknockSummary.Knocked_Date_02_Hour__c == null){
                        newknockSummary.Knocked_Date_02_Hour__c =0;
                    }
                    newknockSummary.Knocked_Date_02_Hour__c = newknockSummary.Knocked_Date_02_Hour__c + 1;
                }
                else if(hrs == 03){
                    if(newknockSummary.Knocked_Date_03_Hour__c == null){
                        newknockSummary.Knocked_Date_03_Hour__c =0;
                    }
                    newknockSummary.Knocked_Date_03_Hour__c = newknockSummary.Knocked_Date_03_Hour__c + 1;
                }
                else if(hrs == 04){
                    if(newknockSummary.Knocked_Date_04_Hour__c == null){
                        newknockSummary.Knocked_Date_04_Hour__c =0;
                    }
                    newknockSummary.Knocked_Date_04_Hour__c = newknockSummary.Knocked_Date_04_Hour__c + 1;
                }
                else if(hrs == 05){
                    if(newknockSummary.Knocked_Date_05_Hour__c==null){
                        newknockSummary.Knocked_Date_05_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_05_Hour__c = newknockSummary.Knocked_Date_05_Hour__c + 1;
                }
                else if(hrs == 06){
                    if(newknockSummary.Knocked_Date_06_Hour__c ==null){
                        newknockSummary.Knocked_Date_06_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_06_Hour__c = newknockSummary.Knocked_Date_06_Hour__c + 1;
                }
                else if(hrs == 07){
                    if(newknockSummary.Knocked_Date_07_Hour__c ==null){
                        newknockSummary.Knocked_Date_07_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_07_Hour__c = newknockSummary.Knocked_Date_07_Hour__c + 1;
                }
                else if(hrs == 08){
                    if(newknockSummary.Knocked_Date_08_Hour__c==null){
                        newknockSummary.Knocked_Date_08_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_08_Hour__c = newknockSummary.Knocked_Date_08_Hour__c + 1;
                }
                else if(hrs == 09){
                    if(newknockSummary.Knocked_Date_09_Hour__c ==null){
                        newknockSummary.Knocked_Date_09_Hour__c =0;
                    }
                    newknockSummary.Knocked_Date_09_Hour__c = newknockSummary.Knocked_Date_09_Hour__c + 1;
                }
                else if(hrs == 10){
                    if(newknockSummary.Knocked_Date_10_Hour__c==null){
                        newknockSummary.Knocked_Date_10_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_10_Hour__c = newknockSummary.Knocked_Date_10_Hour__c + 1;
                }
                else if(hrs == 11){
                    if(newknockSummary.Knocked_Date_11_Hour__c==null){
                        newknockSummary.Knocked_Date_11_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_11_Hour__c = newknockSummary.Knocked_Date_11_Hour__c + 1;
                }
                else if(hrs == 12){
                    if(newknockSummary.Knocked_Date_12_Hour__c==null){
                        newknockSummary.Knocked_Date_12_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_12_Hour__c = newknockSummary.Knocked_Date_12_Hour__c + 1;
                }
                else if(hrs == 13){
                    if(newknockSummary.Knocked_Date_13_Hour__c==null){
                        newknockSummary.Knocked_Date_13_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_13_Hour__c = newknockSummary.Knocked_Date_13_Hour__c + 1;
                }
                else if(hrs == 14){
                    if(newknockSummary.Knocked_Date_14_Hour__c==null){
                        newknockSummary.Knocked_Date_14_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_14_Hour__c = newknockSummary.Knocked_Date_14_Hour__c + 1;
                }
                else if(hrs == 15){
                    if(newknockSummary.Knocked_Date_15_Hour__c==null){
                        newknockSummary.Knocked_Date_15_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_15_Hour__c = newknockSummary.Knocked_Date_15_Hour__c + 1;
                }
                else if(hrs == 16){
                    if(newknockSummary.Knocked_Date_16_Hour__c==null){
                        newknockSummary.Knocked_Date_16_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_16_Hour__c = newknockSummary.Knocked_Date_16_Hour__c + 1;
                }
                else if(hrs == 17){
                    if(newknockSummary.Knocked_Date_17_Hour__c==null){
                        newknockSummary.Knocked_Date_17_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_17_Hour__c = newknockSummary.Knocked_Date_17_Hour__c + 1;
                }
                else if(hrs == 18){
                    if(newknockSummary.Knocked_Date_18_Hour__c==null){
                        newknockSummary.Knocked_Date_18_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_18_Hour__c = newknockSummary.Knocked_Date_18_Hour__c + 1;
                }
                else if(hrs == 19){
                    if(newknockSummary.Knocked_Date_19_Hour__c==null){
                        newknockSummary.Knocked_Date_19_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_19_Hour__c = newknockSummary.Knocked_Date_19_Hour__c + 1;
                }
                else if(hrs == 20){
                    if(newknockSummary.Knocked_Date_20_Hour__c==null){
                        newknockSummary.Knocked_Date_20_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_20_Hour__c = newknockSummary.Knocked_Date_20_Hour__c + 1;
                }
                else if(hrs == 21){
                    if(newknockSummary.Knocked_Date_21_Hour__c==null){
                        newknockSummary.Knocked_Date_21_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_21_Hour__c = newknockSummary.Knocked_Date_21_Hour__c + 1;
                }
                else if(hrs == 22){
                    if(newknockSummary.Knocked_Date_22_Hour__c==null){
                        newknockSummary.Knocked_Date_22_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_22_Hour__c = newknockSummary.Knocked_Date_22_Hour__c + 1;
                }
                else if(hrs == 23){
                    if(newknockSummary.Knocked_Date_23_Hour__c==null){
                        newknockSummary.Knocked_Date_23_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_23_Hour__c = newknockSummary.Knocked_Date_23_Hour__c + 1;
                }
                
            }
            summeryToUpdate.add(newknockSummary);
            
        }
        try{
            upsert summeryToUpdate Key__c;
           }
        catch(Exception ex){
            System.debug('Following exception occurred :'+ex.getMessage()); 
        }
     }*/
}