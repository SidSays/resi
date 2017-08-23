/*******************************
* Class Name: EventTriggerController 
* Author: Amitkumar Bangad, Accenture
* Date: 30-November-2012 
* Requirement # Request Id: 005
* Description: Contains supporting Actions for Event Triggers (Time to Touch metric Calculations)
* Last Modified : 11-June-2013 (Defect Fix : check event create permissions for DSR) 
* Last Modified : 1-June-2015 (Defect Fix : Added a check to stop recursion.)
* Last Modified By : Malay Desai, Accenture
* @Last Modified By : Amit Kumar Pradhan
* @Last Modified Data : 22nd June 2017
* @Description : Updating Name, Start Date, End Date of Property Event when Event is updated.
* @User Story : US1104342(XC Property Events: Bidirectional Sync between Property Events & Events)
********************************/
public class EventTriggerController {
    
    /* Delete Event is fired not only when you "Delete" Event record but also when you "Edit" the Event Series.
        This variable is used in the trigger to differenciate between these two events */   
    public static Boolean isDelete = true; 
     
    /*****************
    * @Description: This method populates Visit_Start_Date_And_Duration__c field on Activity which displays event scheduling detail.
    * @Author: Malay Desai, Accenture
    * @Date: 22-APR-2016
    * @Param: Trigger.new
    * @Return: void.
    ******************/
    public static void populateVisitStartDateAndDuration(List<Event> newList){
       for(Event evt : newList){        
            if(evt.StartDateTime != null && evt.EndDateTime != null){           
                evt.Visit_Start_Date_And_Duration__c = evt.StartDateTime.format() + ' to ' + (evt.EndDateTime.format()).substringAfter(' ');
            }
        }
    }
   
    /*****************************
    * @Description: This method restricts deletion of event from system.
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 28-December-2012
    * @Param: Trigger.old
    * @Return: void.
    * @Description : Added a check to stop recursion.
    * @Defect : DE71370, Sprint 3 Change, Date : 6/1/2015, Author : Sucheta Verma
    * @Modified: Amit Kumar Pradhan, Accenture 
    * @Description: Allowed to delete the tasks and events irrespective of their status
    * @UserStory:US533722(SP 9)
    *****************************/     
    public static void restrictEventDelete(List<Event> oldEventsList) {
        Profile businessAdminProfile = [Select Id, Name from Profile where Name=: label.BusinessAdminProfileName];
        Profile systemAdminProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        //Fetch profile Record from Custom Setting
        AllowTaskEventDelProfName__c profileRecord = AllowTaskEventDelProfName__c.getValues(UserInfo.getProfileId());
        for(Event eventObj : oldEventsList){
            if(profileRecord  == null){
                if(UserInfo.getProfileId() != businessAdminProfile.Id){
                  eventObj.addError(Label.Event_Delete);
                } 
                else if(eventObj.Event_Status__c != Label.Event_Status_Completed){
                  eventObj.addError(Label.Incomplete_Event_Delete);
                }  
            }else if(profileRecord != null && UserInfo.getProfileId() != systemAdminProfile.id && eventObj.OwnerId != UserInfo.getUserId()){
              eventObj.addError(Label.ErrMsgForDelOfEvent);
            }           
        }          
    }
    
    /**
    * @Description: This method captures time to touch on relevant leads
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 30-November-2012
    * @Param: Trigger.NewMap
    * @Return: void.
    */
    public static void identifyLeadTimeToTouch (Map<Id, Event> newEventsMap) {
        long dateDifference;
        set<Id> leadIds = new set<Id>();
        set<Id> ownerIds = new set<Id>();
        Map<Id, Lead> leadsMap = new Map<Id, Lead>();
        Map<Id, Event> leadEventsMap = new Map<Id, Event>();

        /*Fetch all the events related to Leads with lead ids*/
        for (Event evt : newEventsMap.values()){
            if (evt.WhoId != null && String.Valueof(evt.WhoId).StartsWith('00Q')){
                leadIds.add(evt.WhoId);
                leadEventsMap.put(evt.Id,evt);    
            } 
        }
        if (!(leadIds.isEmpty())){
          
            /*Fetch all the leads for which event is being logged and time to touch not calculated*/
            for (Lead lead: [Select OwnerId, Ownership_Transfer_Date__c,  
                                CreatedDate, Affiliate_Account__c, Time_to_Touch__c, LeadSource 
                                from Lead where Id =: leadIds AND 
                                Time_to_Touch__c =: null]){
                leadsMap.put(lead.Id,lead); 
                ownerIds.add(lead.OwnerId);  
            }
            if (!(leadsMap.isEmpty())){
                Profile p = [Select Id, Name from Profile where Name =: Label.Integration_User_Profile];

                /*Discard the leads where logged in user is integration user*/
                for (User user: [Select ProfileId from User where Id =: ownerIds]){
                    for (lead le : leadsMap.values()){
                        if ((user.Id == le.OwnerId) && (user.ProfileId == p.Id)){
                          leadsMap.remove(le.Id);
                        }
                    }   
                }
              
                /*Capture time to touch on remaining leads*/
                for (event ev : leadEventsMap.values()){
                    if(ev.WhoId!=null){
                        if(leadsMap.containsKey(ev.whoId)  && leadsMap.get(ev.WhoId) != null){
                            if(leadsMap.get(ev.whoId).LeadSource == label.Lead_Source_Affiliate && leadsMap.get(ev.whoId).Ownership_Transfer_Date__c != null){
                                dateDifference  = SubtractDate(leadEventsMap.get(ev.Id).createdDate,leadsMap.get(ev.whoId).Ownership_Transfer_Date__c);
                            } else{
                                dateDifference  = SubtractDate(leadEventsMap.get(ev.Id).createdDate,leadsMap.get(ev.whoId).createdDate);
                            }
                            if (dateDifference != null){
                                leadsMap.get(ev.whoId).Time_to_Touch__c = dateDifference;
                                leadsMap.get(ev.whoId).FirstModifiedDate__c = leadEventsMap.get(ev.Id).createdDate;
                                leadsMap.get(ev.whoId).FirstModifiedBy__c = UserInfo.getUserId();
                            }
                        }
                    }
                }
                try{
                    database.update (leadsMap.values());
                }catch (DmlException dmlEx){
                    for(Integer i =0; i<dmlEx.getNumDml(); ++i) { 
                      system.debug('*******Following Errors occurred on Lead Update ****** :' + dmlEx.getDmlMessage(i));
                    }
                }
            }
        }
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
      
    /** Commented for US670601  
    public static void countEvents(List<Event> eventList) 
        {

        String propertyKeyPrefix = Schema.MDU_Property__c.sobjecttype.getDescribe().getKeyPrefix();


        //Profile p = [Select Id, Name from Profile where Name =: Xfinity CAR];
        set<Id> propertyIdSet = new Set<Id>();
        set<Id> assignedCarIdSet = new Set<Id>();
        String RecordtypeProgress = Schema.SObjectType.Metric.getRecordTypeInfosByName().get(system.label.MetricProgress).getRecordTypeId();
        String RecordtypeCompletion = Schema.SObjectType.Metric.getRecordTypeInfosByName().get(system.label.MetricCompletion).getRecordTypeId();
        List<Metric> metricList= new List<Metric>();
        String[] likeFilter = new String[]{'%Event%'};

        Integer todayDate = Date.Today().Day();
        Date preGoalStartDate = null;
        Date preGoalDueDate = null;   
        //Get the Fiscal Year Date period goal start/due dates            
        GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance('Property Lab CAR'); 
        Integer remainingDays = goalDates.Current_Period_Due_Date__c!=null?System.today().daysBetween(goalDates.Current_Period_Due_Date__c):0;       

          if(goalDates != null){
              preGoalStartDate = goalDates.Current_Period_Start_Date__c;  
              preGoalDueDate =  goalDates.Current_Period_Due_Date__c;
        } 
         
        //for all the events find the related property using whatid


        for(Event eve : eventList)
        { 
            
            if(eve.WhatId != null){ 
            if(String.valueOf((eve.WhatId)).startsWith(propertyKeyPrefix) ){     
            propertyIdSet.add(eve.whatid);  
           
            }
          }       
        }   

        //
        if(!propertyIdSet.isEmpty())
        {
        for(MDU_Property__c property : [select Id,Assigned_CAR__c from MDU_Property__c Where id IN : propertyIdSet ]){  
          assignedCarIdSet.add(property.Assigned_CAR__c);    
          
        }

        MetricTriggerController.allowValidation=false;
        for(Metric metr : [select id ,TargetValue,CurrentValue FROM Metric WHERE name like'%Event%' AND Goal.status='Published' AND Goal.StartDate =:preGoalStartDate AND Recordtypeid =:RecordtypeProgress  AND  Goal.Ownerid  IN: assignedCarIdSet])
            {
           
             metr.CurrentValue = metr.CurrentValue == NULL?1:metr.CurrentValue+1;
             
                metricList.add(metr);
             MetricStatusUpdateUtil.updateSdmAsmStatusPickList(metr,remainingDays);    
               
        } 
          
        Database.update(metricList);  

        }
    } **/
    
    
    /**************************
    * @Description: This method update Name, Start Date, End Date of Property Event when Event is updated
    * @Author: Amit Kumar Pradhan, Accenture
    * @Date: 22-June-2017
    * @User Story: US1104342(XC Property Events: Bidirectional Sync between Property Events & Events)
    * @Param: List<Event>, Map<Id,Event> oldEventsMap
    * @Return: None
    ***************************/
    public static void updatePropertyEvents(List<Event> eventList, Map<Id,Event> oldEventsMap){
        Map<String, Event> eventIdAndEventMap = new Map<String, Event>();
        try{
            //Getting prefix of Property Event Object.
            String propEventKeyPrefix = Schema.Property_Events__c.sobjecttype.getDescribe().getKeyPrefix();
            for(Event eventObj : eventList){            
                if(eventObj.Property_Event__c != null && String.valueOf((eventObj.Property_Event__c)).startsWith(propEventKeyPrefix) 
                    && (eventObj.Subject != oldEventsMap.get(eventObj.Id).Subject
                    || eventObj.StartDateTime != oldEventsMap.get(eventObj.Id).StartDateTime
                    || eventObj.EndDateTime != oldEventsMap.get(eventObj.Id).EndDateTime)){                 
                    eventIdAndEventMap.put(eventObj.Property_Event__c, eventObj);                 
                }       
            }

            if(!eventIdAndEventMap.isEmpty()){
                List<Property_Events__c> propEventListToUpdate = new List<Property_Events__c>();
                //Fetching all the Property Event records associate with event.
                for(Property_Events__c propEvent : [SELECT Id, Name, Start_Time__c, End_Time__c 
                                                        FROM Property_Events__c WHERE Id IN:eventIdAndEventMap.keySet() 
                                                        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    if(eventIdAndEventMap.containsKey(propEvent.Id)){
                        propEvent.Name = eventIdAndEventMap.get(propEvent.Id).Subject;
                        propEvent.Start_Time__c = eventIdAndEventMap.get(propEvent.Id).StartDateTime;
                        propEvent.End_Time__c = eventIdAndEventMap.get(propEvent.Id).EndDateTime;
                        propEventListToUpdate.add(propEvent);
                    }
                }
                //Updating the Property Event List
                if(!propEventListToUpdate.isEmpty()){
                    Database.update(propEventListToUpdate,false);
                }
            }
        }catch(Exception ex){
            System.debug('Error Message : ' + ex.getMessage());
        }   
    } 
}