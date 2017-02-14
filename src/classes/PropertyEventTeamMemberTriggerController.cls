public class PropertyEventTeamMemberTriggerController {
    
    /* Method Name : sharePropertyEventsWithTeamMembers 
    *  Description : When a team member is added to a Property Event, the Property Event record will be shared with him and his Manager Hierarchy
    *  Parameter   : Trigger.new and Trigger.oldMap
    *  Return Type : void
    *  Author      : Malay Desai, Accenture
    *  User Story  : US911835,US898827,US908828,US911762
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
                String userSharingRowCause = Schema.Property_Events__Share.RowCause.Team_Member__c;
                String userManagerGroupSharingRowCause = Schema.Property_Events__Share.RowCause.Team_Members_Manager__c;
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
                    propertyEventShare.rowCause = userSharingRowCause;
                    propEventShareList.add(propertyEventShare);
                    
                    Property_Events__Share propertyEventMgrShare = new Property_Events__Share();
                    propertyEventMgrShare.ParentId = userIdVsPropEvent.get(userId);
                    propertyEventMgrShare.userorgroupId = userIdVsManagerGroupId.get(userId); 
                    propertyEventMgrShare.AccessLevel = EDIT_ACCESS;                
                    propertyEventMgrShare.rowCause = userManagerGroupSharingRowCause;
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
    */
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
            
            if(!propEventIdAndPropEventMap.isEmpty()){
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
            
            if(!eventList.isEmpty()){
                Database.insert(eventList,false);
            }
            
        }catch(Exception ex){
              system.debug('Following error occurred'+ ex.getMessage());
        }   
    }
    
    
    /*
    * @Description: This method is to create a new calender event(and delete the old event) when a property event team member is updated.
    * @Return: void
    * @Date: 2-Feb-2017 
    * @Author: Shalaka Kadwade, Accenture
    * US911767- XC Property Events: Salesforce Event
    */
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
    }
    
    
    /*
    * @Description: This method is to create a delete calender event property event team member is deleted.
    * @Return: void
    * @Date: 2-Feb-2017 
    * @Author: Shalaka Kadwade, Accenture
    * US911767- XC Property Events: Salesforce Event
    */
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
            //System.debug('Following error occurred'+ ex.getMessage());
        } 
    }
    
    /*
    * @Description: This method is to create a delete calender event(Called From updateCalenderEvent and deleteCalenderEvent method).
    * @Return: void
    * @Date: 2-Feb-2017 
    * @Author: Shalaka Kadwade, Accenture
    * US911767- XC Property Events: Salesforce Event
    */
    public static void deleteEventRecord(Set<String> oldPropEventIdSet, Set<String> oldTeamMemberSet){
        EventTriggerController.isDelete = false;
        List<Event> oldEventList = null;       
        if(!oldPropEventIdSet.isEmpty() && !oldTeamMemberSet.isEmpty()){                
            oldEventList = [SELECT Id FROM Event WHERE WhatId IN :oldPropEventIdSet AND OwnerId IN :oldTeamMemberSet];
        }      
        if(oldEventList != null){
            database.delete(oldEventList,false);
        }       
    }
}