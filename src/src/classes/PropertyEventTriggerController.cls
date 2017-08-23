/*************************
* Class Name : PropertyEventTriggerController
* Author : Joognu Rao
* Date : 25-January-2017
* Purpose : To prevent deletion of Property Events if there are Property Event Items associated.
* @Last Modified By: Amit Kumar Pradhan
* @Last Modified Data:8th June 2017
* @Description: Code commented as we are removing the creation of calender Event functionality
* @User Store: US1117802(XC Property Event - Remove Event Creation)
* @Last Modified By : Amit Kumar Pradhan
* @Last Modified Data : 14th June 2017
* @Description : Changing the status of salesforce event to completed when Property Event status is changed to completed.
* @User Story : US1110746(XC DT - Property Event Status)
* @Last Modified By : Amit Kumar Pradhan
* @Last Modified Data : 22nd June 2017
* @Description : Updating Name, Start Date, End Date of Event when Property Event is updated.
* @User Story : US1104342(XC Property Events: Bidirectional Sync between Property Events & Events)
* @Last Modified By : Sagarika 
* @Last Modified Date : 22nd June 2017
* @Description : On Deletion of property event create and send a cancelation email for the event to all invitees
* @User Story :  US1117736(XC Property Event - Delete Events)
* @Last modified By: Sagarika
* @Last modified Date: 13-July-2017 
* @Description : Modifying code to send cancellation email on removing team members from property event
* @User Story : User Story: US1137238: XC Property Event - Cancellation ICS file
* @Last modified By : Amit Kumar
* @Last modified Date : 21st July 2017
* @Description : US1143300: Added method "updatesalemetric". This method will be used to call PropertyEventTriggerOperation to update the metric for CAR. 
* @User Story : US1143300: XC DT - Update Sales Event Metrics
* @Last modified By: Lavanya Hosbet
* @Last modified Date: 26-July-2017 
* @Description : Modifying code to send update email with ICS file to team members
* @User Story : User Story: US1146712 - XC DT - ICS file for change in Property Event
* @Last modified By : Animesh Datta
* @Last modified Date : 8th August 2017
* @Description : US1160971: Modified method updatesalemetric. Creating a map of standard events and assigned car of related property
* @User Story : US1160971: XC DT - Event credit for CARs
*************************/
public class PropertyEventTriggerController{
    //Declare constant(Added by Amit Kumar Pradhan - As a part of US1110746)
    public static final String COMPLETED_STATUS = 'Completed';
    //Declarations
    public map<id,list<Property_Event_Item__c>> PropertyEventToItemsmap = new map<id, list<Property_Event_Item__c>>();
    List <Property_Event_Item__c> Itemslist;
    
    //User Story : US1117736(XC Property Event - Delete Events) - Start 
    //Constants added for US1117736 for email 
    public static final String DATEFORMAT = 'yyyyMMdd\'T\'HHmmss\'z\'';
    public static final String DATEFORMATFOREMAIL = 'yyyy-MM-dd h:mm a';
    public static final String ICSFILENAME_CANCELLED = 'CANCELED: TeamMemberInvite.ics';
    public static final String ICSFILECONTENTTYPE = 'text/calendar';
    public static final String MAILSUBJECT_CANCELLED = 'CANCELED: Property Event Details';
    public static final String MAILSUMMARY = 'Property Event Attendee';
    public static final String MAILDESCRIPTION_CANCELLED = 'Event has been Canceled';
  public final static String METHOD_CANCEL = 'CANCEL';
  public final static String STATUS_CANCELLED = 'CANCELLED';
  public final static String SEQUENCE_CANCELLED = '1';
        
    public static final String TEAM_MEMBER_NAME = 'TEAM_MEMBER_NAME';
  public static final String PROPERTY_EVENT_NAME = 'PROPERTY_EVENT_NAME';
  public static final String PROPERTY_NAME = 'PROPERTY_NAME';
  public static final String START_TIME = 'START_TIME';
  public static final String END_TIME = 'END_TIME';
  public static final String PROPERTY_EVENT_OWNER = 'PROPERTY_EVENT_OWNER';  
  //User Story : US1117736(XC Property Event - Delete Events) - End   
  
  private static final String STATUS_DECLINED = 'Declined';
  
  //US1146712- XC DT - ICS file for change in Property Event - Start
  public final static String METHOD_PUBLISH = 'PUBLISH';
  public final static String STATUS_UPDATED = 'UPDATED';
  public final static String SEQUENCE_UPDATED = '2';
  public static final String MAILSUBJECT_UPDATED = 'UPDATED: Property Event Details';
  public static final String ICSFILENAME_UPDATED = 'UPDATED: TeamMemberInvite.ics';
  public static final String EVENT_STATUS_TRACKING_SITE_URL = 'EVENT_STATUS_TRACKING_SITE_URL';
  public static final String MAILDESCRIPTION_UPDATED = 'Event has been Updated';
  //US1146712- XC DT - ICS file for change in Property Event - End
        
        
    //method to prevent deletion of Property Events if there are Property Event Items associated
    public void doNotDeleteWithItems(List<Property_Events__c> oldList){   
        Itemslist = new List<Property_Event_Item__c>();
        Itemslist = [select id, Property_Event__c from Property_Event_Item__c where Property_Event__c IN: oldList];
        
        try{
            if(!Itemslist.IsEmpty()){ 
                for(Property_Event_Item__c items : Itemslist){
                    
                        if(PropertyEventToItemsmap.ContainsKey(items.Property_Event__c))
                        {
                            PropertyEventToItemsmap.get(items.Property_Event__c).add(items);
                        }else{
                            PropertyEventToItemsmap.put(items.Property_Event__c, new List<Property_Event_Item__c>{items});
                        }                                               
                }
                
                for(Property_Events__c  events: oldList){
                
                   if(PropertyEventToItemsmap.get(events.id).size() > 0){
                        events.adderror(System.Label.PropertyEventErrorMessage);
                   } 
                }
            }
        
        }catch(exception ex){
            system.debug('EXCEPTION Occurred'+ex.getmessage());
        }        
    }
    
    /*************************
    * @Description: This method is to create a calender event when user creats property event.
    * @Return: void
    * @Date: 2-Feb-2017 
    * @Author: Shalaka Kadwade, Accenture
    * US911767- XC Property Events: Salesforce Event
    * @Last Modified By: Amit Kumar Pradhan
    * @Last Modified Data:8th June 2017
    * @Description: Code commented as we are removing the creation of calender Event functionality
    * @User Store: US1117802(XC Property Event - Remove Event Creation)
    **************************/
    /*
    public static void createCalenderEvent(List<Property_Events__c> newPropEventList){
        final String SUBJECT = 'Property Event';
        final String EVENT_STATUS = 'Not Started';
        
        try{
             List<Event> eventList;
             Event eventObj;
             
            if(!newPropEventList.isEmpty()){
                eventList = new List<Event>();
                for(Property_Events__c propEvent: newPropEventList){
                 eventObj = new Event();
                 eventObj.StartDateTime = propEvent.Start_Time__c;
                 eventObj.EndDateTime = propEvent.End_Time__c;
                 eventObj.Subject = SUBJECT;
                 eventObj.Ownerid = propEvent.Ownerid;
                 eventObj.Whatid = propEvent.Id;
                 eventObj.Event_Status__c = EVENT_STATUS;
                 
                 eventList.add(eventObj); 
                }
            
                if(!eventList.isEmpty()) {
                        Database.Insert(eventList,false);
                }
            }
        }catch(Exception ex){
               system.debug('Following error occurred'+ ex.getMessage());
        }   
    }*/
    
    /**************************************
    * @Description : This method is to change the status of salesforce event to completed when
                     Property Event status is changed to completed.
    * @Author : Amit Kumar Pradhan, Accenture
    * @Date : 14-June-2017 
    * @Return : void
    * @Param : List<Property_Events__c>, Map<Id,Property_Events__c>     
    * @User Story : US1110746(XC DT - Property Event Status)
    ***************************************/
    public static void updateCalenderEventStatus(List<Property_Events__c> newPropEventList, Map<Id,Property_Events__c> oldPropEventMap){
        Map<String, String> eventIdAndStatusMap = new Map<String, String>();
        try{
            for(Property_Events__c propEvent : newPropEventList){
                if(propEvent.status__c != oldPropEventMap.get(propEvent.Id).status__c && propEvent.status__c == COMPLETED_STATUS){
                    eventIdAndStatusMap.put(propEvent.Id,propEvent.Status__c);
                }
            }

            if(!eventIdAndStatusMap.isEmpty()){
                List<Event> toUpdateEventList = new List<Event>();
                //Fetching all the event records thats need to be updated(event status)
                for(Event eventObj : [SELECT Id, WhatId, Property_Event__c, Event_Status__c FROM Event 
                                        WHERE Property_Event__c IN : eventIdAndStatusMap.keySet() 
                                        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    if(eventIdAndStatusMap.containsKey(eventObj.Property_Event__c)){
                        eventObj.Event_Status__c = COMPLETED_STATUS;
                        toUpdateEventList.add(eventObj);
                    }
                }
                //Updating event records
                if(!toUpdateEventList.isEmpty()){
                    Database.update(toUpdateEventList,false);
                }
            }
        }catch(Exception ex){
            System.debug('Error Message : ' + ex.getMessage());
        }
    }
  
  /**************************
  * @Description: This method update Name, Start Date, End Date of Event when Property Event is updated
  * @Author: Amit Kumar Pradhan, Accenture
  * @Date: 22-June-2017
  * @User Story: US1104342(XC Property Events: Bidirectional Sync between Property Events & Events)
  * @Param: List<Event>, Map<Id,Event> oldEventsMap
  * @Return: None
  ***************************/
    public static void updateCalenderEvent(List<Property_Events__c> newPropEventList, 
                                                    Map<Id,Property_Events__c> oldPropEventMap){
        Map<String, Property_Events__c> eventIdAndEventMap = new Map<String, Property_Events__c>();
        //US1146712 - Set to hold the events where only time has been modified. 
        Set<Property_Events__c> eventsWithModifiedTimeSet = new Set<Property_Events__c>();
        try{
            for(Property_Events__c propEvent : newPropEventList){
                if(propEvent.Name != oldPropEventMap.get(propEvent.Id).Name
                    || propEvent.Start_Time__c != oldPropEventMap.get(propEvent.Id).Start_Time__c
                    || propEvent.End_Time__c != oldPropEventMap.get(propEvent.Id).End_Time__c){
                    eventIdAndEventMap.put(propEvent.Id,propEvent);
                }
                //US1146712 - Start - create a Set of the events whose time has been modified
                if(propEvent.Start_Time__c != oldPropEventMap.get(propEvent.Id).Start_Time__c
                    || propEvent.End_Time__c != oldPropEventMap.get(propEvent.Id).End_Time__c){
                  eventsWithModifiedTimeSet.add(propEvent);
                }
                //US1146712 - End
            }

            if(!eventIdAndEventMap.isEmpty()){
                List<Event> toUpdateEventList = new List<Event>();
                //Fetching all the event records thats need to be updated(event status)
                for(Event eventObj : [SELECT Id, WhatId, Property_Event__c, Subject, StartDateTime, EndDateTime FROM Event 
                                        WHERE Property_Event__c IN : eventIdAndEventMap.keySet() 
                                        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    if(eventIdAndEventMap.containsKey(eventObj.Property_Event__c)){
                        eventObj.StartDateTime = eventIdAndEventMap.get(eventObj.Property_Event__c).Start_Time__c;
                        eventObj.EndDateTime = eventIdAndEventMap.get(eventObj.Property_Event__c).End_Time__c; 
                        eventObj.Subject = eventIdAndEventMap.get(eventObj.Property_Event__c).Name;
                        toUpdateEventList.add(eventObj);
                    }
                }
                //Updating event records
                if(!toUpdateEventList.isEmpty()){
                    Database.update(toUpdateEventList,false);
                }
                
                //US1146712 - send email notification to team members on updated time for the event
                if(!eventsWithModifiedTimeSet.isEmpty()){
                  sendEmailOnEventUpdate(eventsWithModifiedTimeSet);
                }
                //US1146712 - End
            }
        }catch(Exception ex){
            System.debug('Error Message : ' + ex.getMessage());
        }
    }    
    
    /**    
     * @Author: Lavanya Hosbet
     * @User Story : US1146712 (XC DT - ICS file for change in Property Event)
    * @Description: Whent the time on a Property Event changes, notify all the team members of change in time via an updated ICS file through email
    * @Date: 19 July 2017      
    * @Param: Set<Property_Events__c>
    * @Return: void
    */ 
    public static void sendEmailOnEventUpdate(Set<Property_Events__c> propertyEventsWithUpdate){
      
      try{
        List<Id> propertyEventIds = new List<Id>();
        Set<Id> eventIds = new Set<Id>();
        List<Property_Event_Team_Member__c> teamMembersToNotify = new List<Property_Event_Team_Member__c>();
        Messaging.SingleEmailMessage email = null;
        List<String> declinedStatus = new List<String>();
        declinedStatus.add(STATUS_DECLINED);
        
        
        //fetch the ids of all property events that have been modified
        for(Property_Events__c  propertyEvent: propertyEventsWithUpdate)
        {
          propertyEventIds.add(propertyEvent.id);
        }
        
        if(!propertyEventIds.isEmpty())
        {
          //fetch all associated event ids
        for(Event event : [SELECT Id FROM Event WHERE Property_Event__c IN: propertyEventIds])
        {
          eventIds.add(event.id);
        }
        
        //fetch all relations and find the members who have not declined the event
                Set<Id> eventNotDeclinedTeamMembers = new Set<Id>();
                for(EventRelation relation : [Select Id, EventId, Status, RelationId  FROM EventRelation 
                                                                  WHERE Status NOT IN : declinedStatus AND EventId IN: eventIds
                                                                  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())])  
                {
                  eventNotDeclinedTeamMembers.add(relation.RelationId);
                }
           
          List<Messaging.SingleEmailMessage> emailsForTeamMembers = new List<Messaging.SingleEmailMessage>();
          String teamMemberId = null;
          for(Property_Event_Team_Member__c teamMember : [SELECT Id, Name, Email__c, Team_Member__c, Contact__c, Property_Event__c, Property_Event__r.Name, Property_Event__r.Owner.Name , Property_Event_Property__c, Property_Event_Start_Date__c, Property_Event_End_Date__c, User_Email__c FROM Property_Event_Team_Member__c 
                                                                WHERE Property_Event__c IN : propertyEventIds 
                                                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
          {
            
            //Get the team member id to check with eventAcceptedTeamMember List
            if(teamMember.Team_Member__c != null){
                      teamMemberId = teamMember.Team_Member__c; 
                  }
                  else if(teamMember.Contact__c != null){
             teamMemberId = teamMember.Contact__c;
                  }
            if(eventNotDeclinedTeamMembers.contains(teamMemberId))
            {
              //Create the event update notification email
              email = createEmail(teamMember, METHOD_PUBLISH);
              if(email != null)
              {
                        emailsForTeamMembers.add(email);     
              }
            }
          }
          if(!emailsForTeamMembers.isEmpty())
          {
          Messaging.sendEmail(emailsForTeamMembers);
          }  
        }
                
      }
      catch(Exception e)
      {
        ApplicationLogUtil.insertApplogforexceptions(e, ConstantHandler.STR_CLASS, PropertyEventTriggerController.class.getName(), Property_Event_Team_Member__c.getSObjectType().getDescribe().getName(), false, null, ConstantHandler.nonintegrationRTypeId);
      }
    }
        
    /*
    * @Created By : Sagarika
    * @Created Data : 22th June 2017
    * @Description : On Deletion of property event, create and send a cancelation email for the event to all invitees and delete all team members
    * @Param: propertyEventsToDelete
    * @Return: void
    * @User Story : US1117736(XC Property Event - Delete Events)
    */    
    public static void sendEventCancelationAndDeleteTeamMembers(List<Property_Events__c> propertyEventsToDelete)
    {
      try{
        Set<Id> propertyEventIdsToDelete = new Set<Id>();
        Set<Id> eventIds = new Set<Id>();
        List<Property_Event_Team_Member__c> teamMembersToDelete = new List<Property_Event_Team_Member__c>();
        Messaging.SingleEmailMessage email = null;
        List<String> declinedStatus = new List<String>();
        declinedStatus.add(STATUS_DECLINED);
        
        for(Property_Events__c  propertyEvent: propertyEventsToDelete)
        {
          propertyEventIdsToDelete.add(propertyEvent.id);
        }
        if(!propertyEventIdsToDelete.isEmpty())
        {
          //User Story: Start : US1137238: XC Property Event - Cancellation ICS file
          //Get all event ids to get the event relations
        for(Event event : [SELECT Id FROM Event WHERE Property_Event__c IN: propertyEventIdsToDelete])
        {
          eventIds.add(event.id);
        }
        
        //Get all relations and find the members who have not declined the event
                Set<Id> eventAcceptedTeamMember = new Set<Id>();
                for(EventRelation relation : [Select Id, EventId, Status, RelationId  FROM EventRelation 
                                                                  WHERE Status NOT IN : declinedStatus AND EventId IN: eventIds
                                                                  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())])  
                {
                  eventAcceptedTeamMember.add(relation.RelationId);
                }
           //User Story: End : US1137238: XC Property Event - Cancellation ICS file
           
          List<Messaging.SingleEmailMessage> emailsForTeamMembers = new List<Messaging.SingleEmailMessage>();
          String teamMemberId = null;
          for(Property_Event_Team_Member__c teamMember : [SELECT Id, Name, Email__c, Team_Member__c, Contact__c, Property_Event__c, Property_Event__r.Name, Property_Event__r.Owner.Name , Property_Event_Property__c, Property_Event_Start_Date__c, Property_Event_End_Date__c, User_Email__c FROM Property_Event_Team_Member__c 
                                                                WHERE Property_Event__c IN : propertyEventIdsToDelete 
                                                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
          {
            //User Story: Start : US1137238: XC Property Event - Cancellation ICS file
            //Set sendRemovedEmail__c to not send removed email. Cancellation email will be sent in case property event is cancelled
            teamMember.sendRemovedEmail__c = false;
            //User Story: End : US1137238: XC Property Event - Cancellation ICS file
            //Add the team members to list 
            teamMembersToDelete.add(teamMember);
            //call createCancelationEmail to create email for tem member
            
            //User Story: Start : US1137238: XC Property Event - Cancellation ICS file
            //Get the team member id to check with eventAcceptedTeamMember List
            if(teamMember.Team_Member__c != null){
                      teamMemberId = teamMember.Team_Member__c; 
                  }
                  else if(teamMember.Contact__c != null){
             teamMemberId = teamMember.Contact__c;
                  }
            if(eventAcceptedTeamMember.contains(teamMemberId))
            {
              //User Story: End : US1137238: XC Property Event - Cancellation ICS file
              email = createEmail(teamMember, METHOD_CANCEL);
              if(email != null)
              {
                        emailsForTeamMembers.add(email);     
              }
            }
          }
          if(!emailsForTeamMembers.isEmpty())
          {
          Messaging.sendEmail(emailsForTeamMembers);
          }  
          //User Story: Start : US1137238: XC Property Event - Cancellation ICS file
          //update deleteTeamMembers to update sendRemovedEmail__c 
          if(!teamMembersToDelete.isEmpty())
                {
                  Database.SaveResult[] saveResult = Database.update(teamMembersToDelete, false);
                    if(!saveResult.isEmpty())
                    {
              //User Story: End : US1137238: XC Property Event - Cancellation ICS file
              ApplicationLogUtil.insertApplogforsaveresult(saveResult, ConstantHandler.STR_APPDMLEXCEPTION , PropertyEventTriggerController.class.getName() , Property_Event_Team_Member__c.getSObjectType().getDescribe().getName(), false, teamMembersToDelete, ConstantHandler.nonintegrationRTypeId);
                    }
                }
                //call deleteTeamMembers to delete team members associated with the property event
          deleteTeamMembers(teamMembersToDelete);
          //User Story: Start : US1117736(XC Property Event - Delete Events)
          //call deleteStandardEvents to delete all standard events associated with the property event
          deleteStandardEvents(propertyEventIdsToDelete);
          //User Story: End : US1117736(XC Property Event - Delete Events)
        }
                
      }
      catch(Exception e)
      {
        ApplicationLogUtil.insertApplogforexceptions(e, ConstantHandler.STR_CLASS, PropertyEventTriggerController.class.getName(), Property_Event_Team_Member__c.getSObjectType().getDescribe().getName(), false, null, ConstantHandler.nonintegrationRTypeId);
      }
    }
    
    /*
    * @Created By : Sagarika
    * @Created Data : 13th July 2017
    * @Description : On Deletion of property event delete all associated standard events
    * @Param: standardEventsToDelete
    * @Return: void
    * @User Story : US1117736(XC Property Event - Delete Events)
    */   
    public static void deleteStandardEvents(Set<Id> propertyEventsToDelete)
    {
      try
      {
        if(!propertyEventsToDelete.isEmpty())     
        {
          List<Event> eventRecordsToDelete = new List<Event>();
              for(Event eventRecord : [SELECT Id, Property_Event__c FROM Event WHERE Property_Event__c IN : propertyEventsToDelete]){
                 eventRecordsToDelete.add(eventRecord);
              }
          Database.DeleteResult[] deleteResult = Database.delete(eventRecordsToDelete, false);
          ApplicationLogUtil.insertApplogfordeleteresult(deleteResult, ConstantHandler.STR_APPDMLEXCEPTION , PropertyEventTriggerController.class.getName() , Event.getSObjectType().getDescribe().getName(), false, eventRecordsToDelete, ConstantHandler.nonintegrationRTypeId);
        }
      }
      catch(Exception e)
      {
        ApplicationLogUtil.insertApplogforexceptions(e, ConstantHandler.STR_CLASS, PropertyEventTriggerController.class.getName(), Event.getSObjectType().getDescribe().getName(), false, null, ConstantHandler.nonintegrationRTypeId);
      }
    }
 
    /*
    * @Created By : Sagarika
    * @Created Data : 22th June 2017
    * @Description : On Deletion of property event create cancelation email for the event for each invitee
    * @Param: propertyEventsToDelete
    * @Return: void
    * @User Story : US1117736(XC Property Event - Delete Events)
    * @LastModifiedBy : Lavanya Hosbet
    * @LastModifiedDate :26 July 2017
    * @Description : Modified method to handle creation of 'Update' email
    * @UserStory : US1146712 (XC DT - ICS file for change in Property Event)
    */   
    public static Messaging.SingleEmailMessage  createEmail(Property_Event_Team_Member__c teamMember, String action)
    {
      Messaging.SingleEmailMessage email = null;
      try
      {
         //Date value to add in email body 
             String startDateTimeEmailStr = teamMember.Property_Event_Start_Date__c.format(DATEFORMATFOREMAIL);
             String endDateTimeEmailStr = teamMember.Property_Event_End_Date__c.format(DATEFORMATFOREMAIL);
            
             //Date strings to add in ICS file content         
             String startDateTimeStr = teamMember.Property_Event_Start_Date__c.formatGmt(DATEFORMAT);
             String endDateTimeStr = teamMember.Property_Event_End_Date__c.formatGmt(DATEFORMAT);
            
             String nowTime = System.now().formatGmt(DATEFORMAT);  
             
              //Create a email object
             email = new Messaging.SingleEmailMessage();  
             //Crerate email file attachment object
             Messaging.EmailFileAttachment emailFileAttachemntObj = new Messaging.EmailFileAttachment();
             //Create Email body object
             String body = null;
             //ICS file body
             ICalendarTemplate icalTemplate = new ICalendarTemplate();
             
             //When event is cancelled
             if(action.equalsIgnoreCase(METHOD_CANCEL))
             {
               icalTemplate.method = METHOD_CANCEL;
               icalTemplate.status = STATUS_CANCELLED;
               icalTemplate.sequence = SEQUENCE_CANCELLED;
               icalTemplate.description = MAILDESCRIPTION_CANCELLED;
               
               body = System.Label.EventCancelationEmailBody;
               
               email.setSubject(MAILSUBJECT_CANCELLED);
               
               emailFileAttachemntObj.setFileName(ICSFILENAME_CANCELLED);
               
             } 
             // US1146712 - Start - When event is re-scheduled/updated
             else if(action.equalsIgnoreCase(METHOD_PUBLISH))
             {
               icalTemplate.method = METHOD_PUBLISH;
               icalTemplate.status = STATUS_UPDATED;
               icalTemplate.sequence = SEQUENCE_UPDATED;
               icalTemplate.description = MAILDESCRIPTION_UPDATED;
               
               body = System.Label.EventUpdateEmailBody;
               email.setSubject(MAILSUBJECT_UPDATED);
               
               emailFileAttachemntObj.setFileName(ICSFILENAME_UPDATED);
             }
             // US1146712 - End
             
             //Populate the fields of the Icaltemplate
       icalTemplate.organizer = teamMember.Property_Event__r.Owner.Name;
       icalTemplate.mailTo = teamMember.Email__c;
       icalTemplate.uid = teamMember.Email__c+teamMember.Property_Event__r.Name;
       icalTemplate.summary = MAILSUMMARY;
       icalTemplate.startDt = startDateTimeStr;
       icalTemplate.endDt = endDateTimeStr;
       icalTemplate.dateStamp = nowTime;
       icalTemplate.created = nowTime;
       icalTemplate.lastModified = nowTime;
       
       String vCal = icalTemplate.generateVcalString();
          
       //Populate fiedls of email   
             //EMAIL body with property event details
             if(!String.isBlank(body))
             {
               body = body.replaceAll(TEAM_MEMBER_NAME, teamMember.Name);
               body = body.replaceAll(PROPERTY_EVENT_NAME, teamMember.Property_Event__r.Name);
               body = body.replaceAll(PROPERTY_NAME, teamMember.Property_Event_Property__c);
               body = body.replaceAll(START_TIME, startDateTimeEmailStr);
               body = body.replaceAll(END_TIME, endDateTimeEmailStr);
               body = body.replaceAll(PROPERTY_EVENT_OWNER, teamMember.Property_Event__r.Owner.Name);
               email.setHtmlBody(body);
             }
             email.setSaveAsActivity(false);
             if(!String.isBlank(teamMember.Team_Member__c))
             {
                 email.setTargetObjectId(teamMember.Team_Member__c);
             }
             else
             {
                 email.setTargetObjectId(teamMember.Contact__c);
             }
            
            //Populate the emailFileattachment
             emailFileAttachemntObj.setBody(blob.valueOf(vCal));                            
             emailFileAttachemntObj.setContentType(ICSFILECONTENTTYPE);
             email.setFileAttachments(new Messaging.EmailFileAttachment[] {emailFileAttachemntObj});         
        
      }
      catch(Exception e)
      {
        ApplicationLogUtil.insertApplogforexceptions(e, ConstantHandler.STR_CLASS, PropertyEventTriggerController.class.getName(), Property_Event_Team_Member__c.getSObjectType().getDescribe().getName(), false, teamMember.id, ConstantHandler.nonintegrationRTypeId);
      }
      return email;
    }
    
    
    /*
    * @Created By : Sagarika
    * @Created Data : 22th June 2017
    * @Description : On Deletion of property event delete team members
    * @Param: teamMembersToDelete
    * @Return: void
    * @User Story : US1117736(XC Property Event - Delete Events)
    */   
    public static void deleteTeamMembers(List<Property_Event_Team_Member__c> teamMembersToDelete)
    {
      try
      {
        if(!teamMembersToDelete.isEmpty())     
        {
          Database.DeleteResult[] deleteResult = Database.delete(teamMembersToDelete, false);
          ApplicationLogUtil.insertApplogfordeleteresult(deleteResult, ConstantHandler.STR_APPDMLEXCEPTION , PropertyEventTriggerController.class.getName() , Property_Event_Team_Member__c.getSObjectType().getDescribe().getName(), false, teamMembersToDelete, ConstantHandler.nonintegrationRTypeId);
        }
      }
      catch(Exception e)
      {
        ApplicationLogUtil.insertApplogforexceptions(e, ConstantHandler.STR_CLASS, PropertyEventTriggerController.class.getName(), Property_Event_Team_Member__c.getSObjectType().getDescribe().getName(), false, null, ConstantHandler.nonintegrationRTypeId);
      }
    }
    
    /*
    * @Created By : Sagarika
    * @Created Data : 12th July 2017
    * @Description : When Property Event is created from standard event using a quick Action, it is popultaed with a Event Id to associate it with. Update the associated Event Id with the New Property Event Id 
    * @Param: propertyEvents
    * @Return: void
    * @User Story : US1139296(XC DT - Create Property Event from Event)
    */   
    public static void updatePropertyEventOnStandardEvent(List<Property_Events__c> propertyEvents)
    {
      try
      {
            Map<String, String> standardEventAndPropertyEventMap = new Map<String, String>();
            for(Property_Events__c  propertyEvent : propertyEvents){
              if(!String.isBlank(propertyEvent.eventId__c))
              {
                   standardEventAndPropertyEventMap.put(propertyEvent.eventId__c, propertyEvent.id);
              }
            }
            
            if(!standardEventAndPropertyEventMap.isEmpty())
            {
              List<Event> eventRecordsToUpdate = new List<Event>();
              for(Event eventRecord : [SELECT Id, WhatId, Property_Event__c, StartDateTime, EndDateTime, Subject 
                                          FROM Event WHERE id IN : standardEventAndPropertyEventMap.keyset()]){
                 eventRecord.Property_Event__c = standardEventAndPropertyEventMap.get(eventRecord.id);
                 eventRecordsToUpdate.add(eventRecord);
              }
              if(!eventRecordsToUpdate.isEmpty())
              {
                Database.SaveResult[] saveResult = Database.update(eventRecordsToUpdate, false);
                if(!saveResult.isEmpty())
                {
                  ApplicationLogUtil.insertApplogforsaveresult(saveResult, ConstantHandler.STR_APPDMLEXCEPTION , PropertyEventTriggerController.class.getName() , Event.getSObjectType().getDescribe().getName(), false, eventRecordsToUpdate, ConstantHandler.nonintegrationRTypeId);
                }
              }
            }
      }
      catch(Exception e)
      {
        ApplicationLogUtil.insertApplogforexceptions(e, ConstantHandler.STR_CLASS, PropertyEventTriggerController.class.getName(), Property_Event_Team_Member__c.getSObjectType().getDescribe().getName(), false, null, ConstantHandler.nonintegrationRTypeId);
      }
    }
     /*
    * @Created By : Amit Kumar
    * @Created Date : 21st July 2017
    * @Description : US1143300: This method will be used to call PropertyEventTriggerOperation to update the metrci for CAR. 
    * @Param: list of propertyevent, map of old record version
    * @Return: void
    * @User Story : US1143300: XC DT - Update Sales Event Metrics
    * @Last modified By : Animesh Datta
    * @Last modified Date : 8th August 2017
    * @Description : US1160971: Modified method updatesalemetric. Creating a map of standard events and assigned car of related property
    * @User Story : US1160971: XC DT - Event credit for CARs
    */ 
    public static void updatesalemetric(list<Property_Events__c> lstpropevent,map<id,Property_Events__c> mapoldpropevent){
        //set<id> setevent = new set<id>();//commenting this line as not required, added map of event id and car id - Animesh - 8/8/17-US1160971
        map<id,id> eventidVsassignedcarmap = new map<id,id>();
        //Filter the Property Event based on completed status ************  START *************************
        if(!lstpropevent.Isempty()){ //Check whether Property list is not Empty
            for(Property_Events__c objevent:lstpropevent){   //Iterate on Property Event
                if(objevent.EventId__c !=null &&
                        (objevent.Status__c).equalsIgnoreCase(PL_Constants.PROPERTY_EVENT_STATUS) && 
                    !(((mapoldpropevent.get(objevent.id)).Status__c).equalsIgnoreCase(PL_Constants.PROPERTY_EVENT_STATUS))
                 ){  //Checking the Event ID and status of the Property Event
                    //setevent.add(objevent.EventId__c);   //Add standard event in a set.//commenting this line as not required, added map of event id and car id - Animesh - 8/8/17-US1160971
                    if(!String.isBlank(objevent.AssignedCARID_to_Property__c)){
                        eventidVsassignedcarmap.put(objevent.EventId__c, objevent.AssignedCARID_to_Property__c);//put standard event id and assigned car in this map
                    }
                }
            }
        }
        if(!eventidVsassignedcarmap.isEmpty()){
            PropertyEventTriggerOperation.updateSalesMetrics(eventidVsassignedcarmap); 
        }
        //Filter the Property Event based on completed status ************  END *************************
    }

}