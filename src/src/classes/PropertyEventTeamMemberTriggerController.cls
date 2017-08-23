/********************************************** 
* @Class Name : PropertyEventTeamMemberTriggerController 
* @Description : When a team member is added to a Property Event, the Property Event record will be shared with him and his Manager Hierarchy
* @Author : Malay Desai, Accenture
* @User Story : US911835,US898827,US908828
* @Last modified By: Shalaka Kadwade, Accenture
* @Last modified Date: 2-Feb-2017 
* @Description : This method is to create a calender event when user gets added as a team member of a property event.
* @User Story : US911767- XC Property Events: Salesforce Event
* @Last Modified By : Amit Kumar Pradhan
* @Last Modified Data : 8th June 2017
* @Description : Code is commented as we are removing the calender event creation functionality
* @User Story : US1117802(XC Property Event - Remove Event Creation)
* @Last Modified By : Amit Kumar Pradhan
* @Last Modified Data : 14th June 2017
* @Description : Team member needs to be added/removed as attendees to the salesforce Event when team member is added/removed.
* @User Story : US1119205(XC Property Event - add/remove team memebr)
* @Last Modified Data : 15th June 2017
* @Description : Team member needs to get an ics file as an email.
* @User Story : US1030894(XC Property Events: Team Members as Event Attendees/EventRelation)
* @Last modified By: Shalaka Kadwade, Accenture
* @Last modified Date: 3-July-2017 
* @Description : Sending one link in ics file so that user can accept/decline the event.
* @User Story : User Story: US1117685(XC Property Event - Status Tracking)
* @Last modified By: Deepika Jain, Accenture
* @Last modified Date: 11-July-2017 
* @Description : When Team member phone number is updated in team member page then the phone number need to be updated in the respective user or contact record.
* @User Story : US1141203(XC Property Event - Team Member phone)
* @Last modified By: Sagarika
* @Last modified Date: 13-July-2017 
* @Description : Modifying code to send cancellation email on removing team members from property event
* @User Story : User Story: US1137238: XC Property Event - Cancellation ICS file 
**********************************************/
public class PropertyEventTeamMemberTriggerController {    
    //Constant variable added for US1030894
    public static final String DATEFORMAT = 'yyyyMMdd\'T\'HHmmss\'z\'';
    public static final String DATEFORMATFOREMAIL = 'yyyy-MM-dd h:mm a';
    public static final String GMTTIMEZONE ='GMT';
    public static final String ICSFILENAME = 'TeamMemberInvite.ics';
    public static final String ICSFILECONTENTTYPE = 'text/calendar';
    public static final String MAILSUBJECT = 'Property Event Details';
    public static final string SITE_URL = 'PropEventStatusTrackingSiteURL';
    
    //User Story: Start :Variables for US1137238: XC Property Event - Cancellation ICS file 
    private static final String CANCELED_ICSFILENAME = 'CANCELED: TeamMemberInvite.ics';
    private static final String CANCELED_MAILSUBJECT = 'CANCELED: Property Event Details';
    private static final String REMOVEDFROMEVENTMAILSUMMARY = 'Property Event Attendee';
    private static final String REMOVEDFROMEVENTMAILDESCRIPTION = 'You have been removed as a team member of the property event.';
	private final static String METHOD_CANCEL = 'CANCEL';
	private final static String STATUS_CANCELLED = 'CANCELLED';
	private final static String SEQUENCE_CANCELLED = '1';
        
    private static final String TEAM_MEMBER_NAME = 'TEAM_MEMBER_NAME';
	private static final String PROPERTY_EVENT_NAME = 'PROPERTY_EVENT_NAME';
	private static final String PROPERTY_NAME = 'PROPERTY_NAME';
	private static final String START_TIME = 'START_TIME';
	private static final String END_TIME = 'END_TIME';
	private static final String PROPERTY_EVENT_OWNER = 'PROPERTY_EVENT_OWNER'; 
	private static final String STATUS_DECLINED = 'Declined';
    //User Story : End : US1137238: XC Property Event - Cancellation ICS file 
    
    /* Method Name : sharePropertyEventsWithTeamMembers 
    *  Description : When a team member is added to a Property Event, the Property Event record will be shared with him and his Manager Hierarchy
    *  Parameter   : Trigger.new and Trigger.oldMap
    *  Return Type : void
    *  Author      : Malay Desai, Accenture
    *  User Story  : US911835,US898827,US908828
    */  
    public static void sharePropertyEventsWithTeamMembers(List<Property_Event_Team_Member__c> teamMembers,
        Map<Id,Property_Event_Team_Member__c> oldMap){
        
        Map<Id,Id> userIdVsPropEvent = new Map<Id,Id>();
        Map<Id,Id> userIdVsManagerGroupId = new Map<Id,Id>();
        
        //Defining String constants
        final String MANAGER = 'Manager';
        final String EDIT_ACCESS = 'Edit';
        
        try{    
            for(Property_Event_Team_Member__c member : teamMembers){                
                if(member.Team_Member__c != null){
                    userIdVsPropEvent.put(member.Team_Member__c,member.Property_Event__c);
                }           
            }
            if(!userIdVsPropEvent.isEmpty()){
                //String userSharingRowCause = Schema.Property_Events__Share.RowCause.Team_Member__c;
                //String userManagerGroupSharingRowCause = Schema.Property_Events__Share.RowCause.Team_Members_Manager__c;
                List<Property_Events__Share> propEventShareList = new List<Property_Events__Share>();
                
                for(Group mGroup : [ SELECT Id, RelatedId FROM Group WHERE type= :MANAGER 
                                            AND RelatedId= :userIdVsPropEvent.keySet()]){
                    userIdVsManagerGroupId.put(mGroup.RelatedId, mGroup.Id);
                }
                
                for(Id userId : userIdVsPropEvent.keySet()){
                    Property_Events__Share propertyEventShare = new Property_Events__Share();
                    propertyEventShare.ParentId = userIdVsPropEvent.get(userId);
                    propertyEventShare.userorgroupId = userId; 
                    propertyEventShare.AccessLevel = EDIT_ACCESS;                
                    //propertyEventShare.rowCause = userSharingRowCause;
                    propEventShareList.add(propertyEventShare);
                    
                    Property_Events__Share propertyEventMgrShare = new Property_Events__Share();
                    propertyEventMgrShare.ParentId = userIdVsPropEvent.get(userId);
                    propertyEventMgrShare.userorgroupId = userIdVsManagerGroupId.get(userId); 
                    propertyEventMgrShare.AccessLevel = EDIT_ACCESS;                
                    //propertyEventMgrShare.rowCause = userManagerGroupSharingRowCause;
                    propEventShareList.add(propertyEventMgrShare);
                }
                
                if(!propEventShareList.isEmpty()){
                    insert propEventShareList;
                }
            }    
        } catch(DMLException ex){
                System.debug('DML Error Message : ' + ex.getMessage());
        } catch(Exception ex){
                System.debug('Error Message : ' + ex.getMessage());
        }
    }

    
    
    /*
    * @Description: This method is to create a calender event when user gets added as a team member of a property event.
    * @Return: void
    * @Date: 2-Feb-2017 
    * @Author: Shalaka Kadwade, Accenture
    * US911767- XC Property Events: Salesforce Event
    * @Last Modified By: Amit Kumar Pradhan
    * @Last Modified Data:8th June 2017
    * @Description: Code is commented as we are removing the calender event creation functionality
    * @User Store: US1117802(XC Property Event - Remove Event Creation)
    */
    /*
    public static void createCalenderEvent(List<Property_Event_Team_Member__c> newPropEventTeamMemberList){
        final String SUBJECT = 'Property Event';
        final String EVENT_STATUS = 'Not Started';
        
        try{
            List<Event> eventList;
            Set<String> propEventIdSet = new Set<String>();
            Map<Id,Property_Events__c> propEventIdAndPropEventMap;
             
            for(Property_Event_Team_Member__c propEventTeamMember: newPropEventTeamMemberList){  
                if(propEventTeamMember.Property_Event__c != null){
                    propEventIdSet.add(propEventTeamMember.Property_Event__c);             
                }
            }
            
            if(!propEventIdSet.isEmpty()){
                propEventIdAndPropEventMap = new Map<Id,Property_Events__c>();
                for(Property_Events__c propEvent : [SELECT Id, Name, Start_Time__c, End_Time__c FROM Property_Events__c  WHERE Id IN: propEventIdSet]){
                    propEventIdAndPropEventMap.put(propEvent.Id,propEvent);
                }
            }
            
            if(propEventIdAndPropEventMap != null && !propEventIdAndPropEventMap.isEmpty()){
                eventList = new List<Event>();                
                for(Property_Event_Team_Member__c propEventTeamMember: newPropEventTeamMemberList){
                    if(propEventIdAndPropEventMap.containsKey(propEventTeamMember.Property_Event__c) && propEventTeamMember.Team_Member__c != null){                        
                        Event eventObj = new Event();       
                        eventObj.StartDateTime = propEventIdAndPropEventMap.get(propEventTeamMember.Property_Event__c).Start_Time__c;
                        eventObj.EndDateTime = propEventIdAndPropEventMap.get(propEventTeamMember.Property_Event__c).End_Time__c;
                        eventObj.Subject = SUBJECT;
                        eventObj.Ownerid = propEventTeamMember.Team_Member__c;
                        eventObj.Whatid = propEventTeamMember.Property_Event__c;
                        eventObj.Event_Status__c = EVENT_STATUS;
                        eventList.add(eventObj);
                    }
                }
            }
            
            if(eventList != null && !eventList.isEmpty()){
                Database.insert(eventList,false);
            }
            
        }catch(Exception ex){
            system.debug('Following error occurred'+ ex.getMessage());
        }   
    }
    */
    
    /*
    * @Description: This method is to create a new calender event(and delete the old event) when a property event team member is updated.
    * @Return: void
    * @Date: 2-Feb-2017 
    * @Author: Shalaka Kadwade, Accenture
    * US911767- XC Property Events: Salesforce Event
    * @Last Modified By: Amit Kumar Pradhan
    * @Last Modified Data:8th June 2017
    * @Description: Code is commented as we are removing the calender event updation functionality
    * @User Store: US1117802(XC Property Event - Remove Event Creation)
    */
    /*
    public static void updateCalenderEvent(List<Property_Event_Team_Member__c> newPropEventTeamMemberList, Map<Id,Property_Event_Team_Member__c> oldPropEventTeamMemberMap){              
        try{            
            Set<String> oldPropEventIdSet = new Set<String>();
            Set<String> newPropEventIdSet = new Set<String>();          
            Set<String> oldTeamMemberSet = new Set<String>();           
            Map<Id,Property_Events__c> newPropEventIdAndPropEventMap;                       
            List<Property_Event_Team_Member__c> toUpdatePropEventTeamMemberList = new List<Property_Event_Team_Member__c>();
             
            for(Property_Event_Team_Member__c propEventTeamMember: newPropEventTeamMemberList){  
                if(propEventTeamMember.Property_Event__c != oldPropEventTeamMemberMap.get(propEventTeamMember.Id).Property_Event__c
                    || propEventTeamMember.Team_Member__c != oldPropEventTeamMemberMap.get(propEventTeamMember.Id).Team_Member__c){
                        
                    oldPropEventIdSet.add(oldPropEventTeamMemberMap.get(propEventTeamMember.Id).Property_Event__c);
                    newPropEventIdSet.add(propEventTeamMember.Property_Event__c);
                    
                    oldTeamMemberSet.add(oldPropEventTeamMemberMap.get(propEventTeamMember.Id).Team_Member__c);                 
                    toUpdatePropEventTeamMemberList.add(propEventTeamMember);
                }
            }
                                
            if(!oldPropEventIdSet.isEmpty() && !oldTeamMemberSet.isEmpty()){                
                deleteEventRecord(oldPropEventIdSet,oldTeamMemberSet);
            }
            
            if(!toUpdatePropEventTeamMemberList.isEmpty()){
                createCalenderEvent(toUpdatePropEventTeamMemberList);
            }
            
        }catch(Exception ex){
            system.debug('Following error occurred'+ ex.getMessage());
        }   
    }*/
       
    /*
    * @Description: This method is to create a delete calender event property event team member is deleted.
    * @Return: void
    * @Date: 2-Feb-2017 
    * @Author: Shalaka Kadwade, Accenture
    * US911767- XC Property Events: Salesforce Event
    * @Last Modified By: Amit Kumar Pradhan
    * @Last Modified Data:8th June 2017
    * @Description: Code is commented as we are removing the calender event deletion functionality
    * @User Store: US1117802(XC Property Event - Remove Event Creation)
    */
    /*
    public static void deleteCalenderEvent(List<Property_Event_Team_Member__c> oldPropEventTeamMemberList){
        Set<String> oldPropEventIdSet = new Set<String>();
        Set<String> oldTeamMemberSet = new Set<String>();
        try{
            for(Property_Event_Team_Member__c propEventTeamMember: oldPropEventTeamMemberList){
                oldPropEventIdSet.add(propEventTeamMember.Property_Event__c); 
                oldTeamMemberSet.add(propEventTeamMember.Team_Member__c);
            }
            
            if(!oldPropEventIdSet.isEmpty() && !oldTeamMemberSet.isEmpty()){                
                deleteEventRecord(oldPropEventIdSet,oldTeamMemberSet);
            }
        }catch(Exception ex){
            System.debug('Following error occurred'+ ex.getMessage());
        } 
    }*/
    
    /*
    * @Description: This method is to create a delete calender event(Called From updateCalenderEvent and deleteCalenderEvent method).
    * @Return: void
    * @Date: 2-Feb-2017 
    * @Author: Shalaka Kadwade, Accenture
    * @US911767- XC Property Events: Salesforce Event
    * @Last Modified By: Amit Kumar Pradhan
    * @Last Modified Data:8th June 2017
    * @Description: Code is commented as we are removing the calender event deletion functionality
    * @User Store: US1117802(XC Property Event - Remove Event Creation)
    */
    /*
    public static void deleteEventRecord(Set<String> oldPropEventIdSet, Set<String> oldTeamMemberSet){
        EventTriggerController.isDelete = false;
        List<Event> oldEventList = null;       
        try{     
            if(!oldPropEventIdSet.isEmpty() && !oldTeamMemberSet.isEmpty()){                
                oldEventList = [SELECT Id FROM Event WHERE WhatId IN :oldPropEventIdSet AND OwnerId IN :oldTeamMemberSet];
            }      
            if(oldEventList != null){
                database.delete(oldEventList,false);
            }
        }catch(Exception ex){
            System.debug('Following error occurred'+ ex.getMessage());
        }      
    }*/
    
    /**************************************
    * @Description : This method is to add attendees to associated event with property event when team member is added.
    * @Author : Amit Kumar Pradhan, Accenture
    * @Date : 14-June-2017 
    * @Return : void
    * @Param : List<Property_Event_Team_Member__c>    
    * @User Story : US1119205(XC Property Event - add/remove team memebr) 
    * @LastModified by: Suchita 
    * @LastModified Date: 15-June-2017
    * @User Story : US1030894(XC Property Events: Team Members as Event Attendees/EventRelation)
    * @Last modified By: Shalaka Kadwade, Accenture
    * @Last modified Date: 3-July-2017 
    * @Description : Sending one link in ics file so that user can accept/decline the event.
    * @User Story : User Story: US1117685(XC Property Event - Status Tracking)
    ***************************************/   
    public static void addAttendeesToCalenderEvent(List<Property_Event_Team_Member__c> newPropEventTeamMemberList){
        Map<String, String> teamMemberIdANDPropEventIdMap = new Map<String, String>();
        Map<String, Property_Events__c> propertyEventIdANDPropertyEvent = new Map<String,Property_Events__c>();
        //String baseURL = URL.getSalesforceBaseUrl().toExternalForm(); 
        
        try{
            //Fetching site URL from variable setting(Part of US1117685)
            Variable_Setting__c eventStatusTrackingSiteURL = Variable_Setting__c.getInstance(SITE_URL);
                        
            for(Property_Event_Team_Member__c propEventTeamMember: newPropEventTeamMemberList){  
                if(propEventTeamMember.Property_Event__c != null){
                    //Creating Map of Team member vs property event
                    teamMemberIdANDPropEventIdMap.put(propEventTeamMember.Id,propEventTeamMember.Property_Event__c);         
                }
            }
            
            if(!teamMemberIdANDPropEventIdMap.isEmpty() && eventStatusTrackingSiteURL != null){
                Map<String, Event> propertyEventIdANDEventMap = new Map<String, Event>();
                List<EventRelation> newEventRelationList = new List<EventRelation>();
                
                //Fetching Propery Event record and create a map of property event id vs property event name
                for(Property_Events__c propertyEvent : [SELECT Id, Name, Owner.Name FROM Property_Events__c WHERE Id IN :    teamMemberIdANDPropEventIdMap.values()
                     LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    propertyEventIdANDPropertyEvent.put(propertyEvent.id,propertyEvent);
                }
                
                //Fetching all event records that are associate with Property_Event__c
                for(Event eventRecord : [SELECT Id, WhatId, Property_Event__c, StartDateTime, EndDateTime, Subject 
                                            FROM Event WHERE isChild = false AND Property_Event__c IN : teamMemberIdANDPropEventIdMap.values() 
                                            LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    propertyEventIdANDEventMap.put(eventRecord.Property_Event__c,eventRecord);
                }
                
                if(!propertyEventIdANDEventMap.isEmpty()){
                    for(Property_Event_Team_Member__c propEventTeamMember : newPropEventTeamMemberList){  
                        if(teamMemberIdANDPropEventIdMap.containsKey(propEventTeamMember.Id)){
                            //Getting Property_Event__c id from teamMemberIdANDPropEventIdMap
                            String propEvent = teamMemberIdANDPropEventIdMap.get(propEventTeamMember.Id);
                            if(propertyEventIdANDEventMap.containsKey(propEvent)){
                                
                                  //creation of EventRelation to add attendees to an event
                                EventRelation eventRelationObj = new EventRelation();                         
                                eventRelationObj.EventId = propertyEventIdANDEventMap.get(propEvent).id;
                                if(propEventTeamMember.Team_Member__c != null ){
                                    eventRelationObj.RelationId = propEventTeamMember.Team_Member__c;
                                }else if(propEventTeamMember.Contact__c != null){
                                    eventRelationObj.RelationId = propEventTeamMember.Contact__c;
                                }
                                 //Adding into a new list                                
                                newEventRelationList.add(eventRelationObj);
                                
                                //Logic to send ics file for event attendee
                                String timeZone = UserInfo.getTimeZone().getID();
                                String startDateTimeEmailStr = propEventTeamMember.Property_Event_Start_Date__c.format(DATEFORMATFOREMAIL,timeZone);
                                String endDateTimeEmailStr = propEventTeamMember.Property_Event_End_Date__c.format(DATEFORMATFOREMAIL,timeZone);
                                
                                String startDateTimeStr = propEventTeamMember.Property_Event_Start_Date__c.format(DATEFORMAT,GMTTIMEZONE);
                                String endDateTimeStr = propEventTeamMember.Property_Event_End_Date__c.format(DATEFORMAT,GMTTIMEZONE);
                                                     
                                //ics file body
                                String vCal = 'BEGIN:VCALENDAR' + '\n' + 'PRODID:-//Force.com Labs//iCalendar Export//EN' + '\n' + + 'X-WR-RELCALID:' + 
                                propEventTeamMember.Email__c+propertyEventIdANDPropertyEvent.get(propEventTeamMember.Property_Event__c).Name + '\n' +
                                'VERSION:2.0' + '\n' + 'CALSCALE:GREGORIAN' + '\n' + 'METHOD:PUBLISH'+ '\n'+ 'BEGIN:VEVENT'+ '\n' +
                                'DTSTART:'+startDateTimeStr+ '\n' + 'DTEND:'+endDateTimeStr+ '\n' + 'DTSTAMP:'+startDateTimeStr+ '\n' +
                                'ORGANIZER;CN=:mailto:'+propEventTeamMember.Email__c + '\n' + 'UID:'+propEventTeamMember.Email__c+propertyEventIdANDPropertyEvent.get(propEventTeamMember.Property_Event__c).Name+ '\n' +
                                'CREATED:'+startDateTimeStr+ '\n' + 'DESCRIPTION:' + '\n' + 'LAST-MODIFIED:'+startDateTimeStr+ '\n' +
                                'SEQUENCE:0' + '\n' + 'STATUS:CONFIRMED' + '\n' + 'SUMMARY:Property Event Attendee' + + '\n' + 'TRANSP:OPAQUE' + '\n' +
                                'END:VEVENT'+ '\n' + 'END:VCALENDAR';
                                  
                                //Mail Boby
                                /***************************************
                                * @Description : Sending one link in ics file so that user can accept/decline the event
                                * @User Story : User Story: US1117685(XC Property Event - Status Tracking)--Start
                                ***************************************/ 
                                String body = '<html><head></head><body> Dear '+propEventTeamMember.Name+','+'<br><br>'+
                                propertyEventIdANDEventMap.get(propEvent).Subject+' has been scheduled for you.<br><br>'+
                                'You have been added as a team member of the property event '+
                                propertyEventIdANDPropertyEvent.get(propEventTeamMember.Property_Event__c).Name+'.'+
                                '<br><br> Property Event Details:<br>'+'Property Events Name – '+
                                propertyEventIdANDPropertyEvent.get(propEventTeamMember.Property_Event__c).Name+'<br>'+
                                'Property – '+propEventTeamMember.Property_Event_Property__c+'<br>'+'Start Time – '+
                                startDateTimeEmailStr+'<br>'+'End Time – '+endDateTimeEmailStr+'<br><br>'+
                                'Click on below link to accept/decline.'+'<br><br>'+eventStatusTrackingSiteURL.value__c+
                                'PropertyEventStatusTracking?EventId='+propertyEventIdANDEventMap.get(propEvent).id+
                                '&RelationId='+eventRelationObj.RelationId+'<br><br>Thank You<br>'+
                                propertyEventIdANDPropertyEvent.get(propEventTeamMember.Property_Event__c).Owner.Name+
                                '</body></html>';
                                /***************************************
                                * @User Story : User Story: US1117685(XC Property Event - Status Tracking)--End
                                ***************************************/
                                
                                List<String> toAddresses = new List<String>();
                                toAddresses.add(propEventTeamMember.Email__c);
                                
                                //Send Mail to Team Member
                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                email.setSaveAsActivity(false);
                                email.setToAddresses(toAddresses);
                                email.setHtmlBody(body);
                                email.setSubject(MAILSUBJECT);
                                
                                Messaging.EmailFileAttachment emailFileAttachemntObj = new Messaging.EmailFileAttachment();
                                emailFileAttachemntObj.setFileName(ICSFILENAME);
                                emailFileAttachemntObj.setBody(blob.valueOf(vCal));                            
                                emailFileAttachemntObj.setContentType(ICSFILECONTENTTYPE);
                                
                                email.setFileAttachments(new Messaging.EmailFileAttachment[] {emailFileAttachemntObj});
                                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                               
                            }
                        }
                    }
                }
                //inserting the EventRelation List
                if(!newEventRelationList.isEmpty()){
                    Database.insert(newEventRelationList,false);
                }
            }
        }catch(Exception ex){ System.debug('Error Message : ' + ex.getMessage());}
    }
    
    /**************************************
    * @Description : This method is to remove attendees to associated event with property event when team member is removed.
    * @Author : Amit Kumar Pradhan, Accenture
    * @Date : 14-June-2017 
    * @Return : void
    * @Param : List<Property_Event_Team_Member__c>    
    * @User Story : US1119205(XC Property Event - add/remove team memebr) 
    * @Last modified By: Sagarika
    * @Last modified Date: 14-July-2017 
    * @Description : Sending cancellation email in ics file when team member is deleted from property event.
    * @User Story : User Story: US1137238: XC Property Event - Cancellation ICS file  
    ***************************************/
	public static void deleteAttendeesFromEvent(List<Property_Event_Team_Member__c> oldPropEventTeamMemberList){
        Set<String> relationIdSet = new Set<String>();
        Set<Id> propertyEventIds = new Set<Id>();
		Set<Id> eventIds = new Set<Id>();
        Map<Id, Property_Event_Team_Member__c> propertyEventTeamMemberMap = new Map<Id, Property_Event_Team_Member__c>();
        try{
            for(Property_Event_Team_Member__c propEventTeamMember: oldPropEventTeamMemberList){
            	
                if(propEventTeamMember.Team_Member__c != null){
                    relationIdSet.add(propEventTeamMember.Team_Member__c); 
                    propertyEventTeamMemberMap.put(propEventTeamMember.Team_Member__c ,propEventTeamMember);            
                }
                
                if(propEventTeamMember.Contact__c != null){
 					relationIdSet.add(propEventTeamMember.Contact__c);
 					propertyEventTeamMemberMap.put(propEventTeamMember.Contact__c ,propEventTeamMember);             
                }
                //US1137238 : Add property events to get property event records
                propertyEventIds.add(propEventTeamMember.Property_Event__c);
            }
            
            //US1137238: Start : Get all property events the property event team members are part of
            Map<Id, Property_Events__c> propEvents =  new Map<Id, Property_Events__c>();
			for(Property_Events__c propEvent:  [SELECT id , Name, Owner.Name FROM Property_Events__c WHERE Id =: propertyEventIds])
			{
				propEvents.put(propEvent.id, propEvent);
			}
	        
	        //US1137238 : Get all events using the property event id to get the event relation data
	        List<Event> events = [SELECT Id FROM Event WHERE Property_Event__c =: propertyEventIds];  
			for(Event event : events)
			{
				eventIds.add(event.id);
			}
			//US1137238: End
            
            if(!relationIdSet.isEmpty()){
                //Fetching all EventRelation records that are associate with team member.
                List<EventRelation> oldEventRelationList = [Select Id, EventId, Status, RelationId FROM EventRelation 
                                                                WHERE RelationId IN :relationIdSet AND EventId IN: eventIds
                                                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                
                //US1137238: Start : Add all team members who has accepted the event invite to deletedTeamMembersEventAccepted                                              
                List<Property_Event_Team_Member__c> deletedTeamMembersEventAccepted = new List<Property_Event_Team_Member__c>();
                Property_Event_Team_Member__c deletedTeamMember = null;                                           
                for(EventRelation oldEventRelation : oldEventRelationList)  
                {
                	if(!STATUS_DECLINED.equalsIgnoreCase(oldEventRelation.Status))
                	{
                		deletedTeamMember = propertyEventTeamMemberMap.get(oldEventRelation.RelationId);
                		if(deletedTeamMember != null && deletedTeamMember.sendRemovedEmail__c)
                		{
                			deletedTeamMembersEventAccepted.add(deletedTeamMember);
                		} 
                	}
                }                       
                
                sendEventCancelation(deletedTeamMembersEventAccepted, propEvents);  
                //US1137238: End   
                                                                
                //deleting all EventRelation records
                if(!oldEventRelationList.isEmpty()){
                    Database.delete(oldEventRelationList, false);
                }                                                   
            }
        }catch(Exception ex){System.debug('Error Message : ' + ex.getMessage());}
    } 
    
    /**************************************
    * @Description : This method is to update the user or contact phone when phone is updated in property event team member page.
    * @Author : Deepika Jain, Accenture
    * @Date : 11-July-2017 
    * @Return : void
    * @Param : List<Property_Event_Team_Member__c>, Map<Id,Property_Event_Team_Member__c> oldPropEventTeamMemberMap   
    * @User Story : US1141203(XC Property Event - Team Member phone)   
    ***************************************/
    public static void updateTeamMemberPhone(List<Property_Event_Team_Member__c> newPropEventTeamMemberList, 
                                                Map<Id,Property_Event_Team_Member__c> oldPropEventTeamMemberMap){
        Map<String, String> userIdMobilePhoneMap = new Map<String, String>();
        Map<String, String> contactIdMobilePhoneMap = new  Map<String, String>();
        List<User> userToUpdateList = new List<User>();
        List<Contact> contactToUpdateList = new List<Contact>();
        List<Property_Event_Team_Member__c> propEventTeamMemberList = new List<Property_Event_Team_Member__c>();
        try{
            for(Property_Event_Team_Member__c propEventTeamMember: newPropEventTeamMemberList){
                if(propEventTeamMember.Mobile_Phone__c != oldPropEventTeamMemberMap.get(propEventTeamMember.Id).Mobile_Phone__c){
                    if(propEventTeamMember.Team_Member__c != null){
                        userIdMobilePhoneMap.put(propEventTeamMember.Team_Member__c,String.valueOf(propEventTeamMember.Mobile_Phone__c));   //adding Userid and mobilephone in a map         
                    }
                    if(propEventTeamMember.Contact__c != null){
                        contactIdMobilePhoneMap.put(propEventTeamMember.Contact__c,String.valueOf(propEventTeamMember.Mobile_Phone__c));    // adding contact id and mobilephone in a map        
                    }
                }
            }
            
            if(!userIdMobilePhoneMap.isEmpty()){
                for(User userRec : [SELECT Id, MobilePhone FROM User WHERE Id IN :userIdMobilePhoneMap.keySet() LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    if(userIdMobilePhoneMap.containsKey(userRec.Id)){
                        userRec.MobilePhone = userIdMobilePhoneMap.get(userRec.Id);
                        userToUpdateList.add(userRec);
                    }
                }
                if(!userToUpdateList.isEmpty()){
                	Database.update(userToUpdateList,false);
                } 
            }
            
            if(!contactIdMobilePhoneMap.isEmpty()){
                for(Contact contactRec : [SELECT Id, MobilePhone FROM Contact WHERE Id IN :contactIdMobilePhoneMap.keySet() LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    if(contactIdMobilePhoneMap.containsKey(contactRec.Id)){
                        contactRec.MobilePhone = contactIdMobilePhoneMap.get(contactRec.Id);
                        contactToUpdateList.add(contactRec);
                    }
                }   
                if(!contactToUpdateList.isEmpty()){
                	Database.update(contactToUpdateList,false);
                }                
            }
            if(!contactToUpdateList.isEmpty() || !userToUpdateList.isEmpty()){
            	for(Property_Event_Team_Member__c propEventTeamMember : [SELECT Id, Contact__c,Team_Member__c FROM Property_Event_Team_Member__c WHERE 
            																		Contact__c IN :contactToUpdateList OR Team_Member__c IN :userToUpdateList 
            																		LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){  
                	if(contactIdMobilePhoneMap.containsKey(propEventTeamMember.Contact__c)){
                        propEventTeamMember.Mobile_Phone__c = contactIdMobilePhoneMap.get(propEventTeamMember.Contact__c);
                        propEventTeamMemberList.add(propEventTeamMember);
                    }
                    if(userIdMobilePhoneMap.containsKey(propEventTeamMember.Team_Member__c)){
                        propEventTeamMember.Mobile_Phone__c = userIdMobilePhoneMap.get(propEventTeamMember.Team_Member__c);
                        propEventTeamMemberList.add(propEventTeamMember);
                    }
                }
                if(!propEventTeamMemberList.isEmpty()){
                	Database.update(propEventTeamMemberList,false);                           
                }  
            }
        }catch(Exception ex){System.debug('Error Message : ' + ex.getMessage());}
    }  
    
    
    /**************************************
    * @Description : This method is to send a cancellation email in ics file when team member is deleted from property event.
    * @Author : Sagarika
    * @Date : 14-July-2017 
    * @Return : void
    * @Param : deletedTeamMembers, propEvents    
    * @User Story : User Story: US1137238: XC Property Event - Cancellation ICS file  
    ***************************************/
    public static void sendEventCancelation(List<Property_Event_Team_Member__c> deletedTeamMembers, Map<Id, Property_Events__c> propEvents)
    {
    	try{
    		Messaging.SingleEmailMessage email = null;
    		Property_Events__c propertyEventForMember =  null;
    		if(!deletedTeamMembers.isEmpty())
    		{
    			List<Messaging.SingleEmailMessage> emailsForTeamMembers = new List<Messaging.SingleEmailMessage>();
    			for(Property_Event_Team_Member__c deletedTeamMember : deletedTeamMembers)
    			{
    				//call createCancelationEmail to create email for tem member
    				propertyEventForMember = propEvents.get(deletedTeamMember.Property_Event__c);
    				if(propertyEventForMember == null)
    				{
    					propertyEventForMember = new Property_Events__c();
    				}
    				email = createCancelationEmail(deletedTeamMember, propertyEventForMember);
    				if(email != null)
    				{
                    	emailsForTeamMembers.add(email);     
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
    
    /**************************************
    * @Description : This method is to send a cancellation email in ics file when team member is deleted from property event.
    * @Author : Sagarika
    * @Date : 14-July-2017 
    * @Return : void
    * @Param : deletedTeamMembers, propEvents    
    * @User Story : User Story: US1137238: XC Property Event - Cancellation ICS file  
    ***************************************/ 
    public static Messaging.SingleEmailMessage  createCancelationEmail(Property_Event_Team_Member__c teamMember, Property_Events__c  propertyEventDetail)
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
                	
  			 //ICS file body
             ICalendarTemplate icalTemplate = new ICalendarTemplate();
             icalTemplate.method = METHOD_CANCEL;
             icalTemplate.status = STATUS_CANCELLED;
			 icalTemplate.organizer = propertyEventDetail.Owner.Name;
			 icalTemplate.mailTo = teamMember.Email__c;
			 icalTemplate.uid = teamMember.Email__c;
			 icalTemplate.summary = REMOVEDFROMEVENTMAILSUMMARY;
			 icalTemplate.description = REMOVEDFROMEVENTMAILDESCRIPTION;
			 icalTemplate.startDt = startDateTimeStr;
			 icalTemplate.endDt = endDateTimeStr;
			 icalTemplate.dateStamp = nowTime;
			 icalTemplate.created = nowTime;
			 icalTemplate.lastModified = nowTime;
			 icalTemplate.sequence = SEQUENCE_CANCELLED;
			 
			 String vCal = icalTemplate.generateVcalString();
			 //Create a email object
             email = new Messaging.SingleEmailMessage();         
             //EMAIL body with property event details
             String body = System.Label.RemoveTeamMemberEmaiBody;
             if(!String.isBlank(body))
             {
	             body = body.replaceAll(TEAM_MEMBER_NAME, teamMember.Name);
	             body = body.replaceAll(PROPERTY_EVENT_NAME, propertyEventDetail.Name);
	             body = body.replaceAll(PROPERTY_NAME, teamMember.Property_Event_Property__c);
	             body = body.replaceAll(START_TIME, startDateTimeEmailStr);
	             body = body.replaceAll(END_TIME, endDateTimeEmailStr);
	             body = body.replaceAll(PROPERTY_EVENT_OWNER, propertyEventDetail.Owner.Name);
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
            
             email.setSubject(MAILSUBJECT);
                    
             Messaging.EmailFileAttachment emailFileAttachemntObj = new Messaging.EmailFileAttachment();
             emailFileAttachemntObj.setFileName(ICSFILENAME);
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
    
    
    public static void validatePhoneNumber(List<Property_Event_Team_Member__c> teamMember){
    	
    	for(Property_Event_Team_Member__c member : teamMember){
    		if(member.Mobile_Phone__c != null){
    			Pattern phoneFormat = Pattern.compile('\\(?\\d{3}\\)?[-\\s]?\\d{3}[-\\s]?\\d{4}');
    			Matcher memberPhone = phoneFormat.matcher(member.Mobile_Phone__c);
    			if(!memberPhone.matches()){
    				member.addError('Phone number must be 10 digits');
    			}
    		}
    	}
    }
      
}