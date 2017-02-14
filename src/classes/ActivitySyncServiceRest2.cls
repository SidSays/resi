@RestResource(urlMapping='/ActivitySyncServicesREST2/*')
/**
 * ActivitySyncServiceRest2.cls
 * Created on: 1/16/2014
 * Author: Doug Beltowski
 * Web service for retrieving the last three activities (Events and/or Tasks)
 * for Addresses in a Turf.
 */
global without sharing class ActivitySyncServiceRest2{
    
    @HttpGet
    global static List<Activity> getActivityByTurf(){
     
        String planId = RestContext.request.params.get('planId');
        Integer page = Integer.valueOf( RestContext.request.params.get('page') );
        Integer RECORD_LIMIT = 500;
        Decimal totalAddressRecords = 0;
        Integer offSet = ( page - 1 ) * RECORD_LIMIT;//It is necessary to subtract one from the page to return the first 500 records.
        
        List<Activity> activityList = new List<Activity>();
        
        for(AggregateResult r : [SELECT COUNT_DISTINCT(id) total, Plan__c FROM Customer_Address__c WHERE Plan__C = :planId GROUP BY Plan__c]){
            totalAddressRecords += Integer.valueOf( r.get('total') );//Count all Addresses in a plan.
        }
        /*System.debug( page );
        System.debug( 'Total Address Records: ' + totalAddressRecords );
        System.debug( RECORD_LIMIT );
        System.debug( 'Plan id is: ' + planId );
        System.debug( 'Querying page ' + page + ' of ' + Math.Ceil( totalAddressRecords / RECORD_LIMIT ) + ' Address Records' );*/
        List<Task> userTasks=[SELECT id, CreatedById, Description, Day_of_Week__C, RecurrenceActivityId, Who.Name, What.Name, LastModifiedDate, Type__c, OwnerId, Owner.Name, Plan_Id__c, WhatId, Status, Priority, Subject, Rejected_Reason__c, Event_Category__c, Internet_Contract_End__c, Phone_Competitor__c, Home_Security_Competitor__c, Internet_Competitor__c, Phone_Contract_End__c, Sales_Type__c, Security_Contract_End__c, Video_Competitor__c, Rejected__c, Video_Contract_End__c, Knocked_Date__c, CreatedDate, ActivityDate, HSI_Sold__c, Video_Sold__c, Voice_Sold__c, XH_Sold__c  FROM Task WHERE Type__c!='Knock' AND (ActivityDate >=TODAY OR Status!='Completed') AND CreatedById=:UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 3];
        //system.debug(userTasks);
        List<Event> userEvents=[SELECT id, CreatedById, Description, Day_of_Week__C, RecurrenceActivityId, Who.Name, What.Name, LastModifiedDate, Type__c, OwnerId, Owner.Name, Plan_Id__c, WhatId, Event_Name_or_Number__c, StartDateTime, Type, WhoId, EndDateTime, ActivityDate, CreatedDate, Rejected__c, Video_Contract_End__c, Knocked_Date__c, Security_Contract_End__c, Video_Competitor__c, Phone_Contract_End__c, Sales_Type__c, Internet_Contract_End__c, Phone_Competitor__c, Home_Security_Competitor__c, Internet_Competitor__c, Subject, HSI_Sold__c, Video_Sold__c, Voice_Sold__c, XH_Sold__c  FROM Event WHERE StartDateTime>=TODAY AND CreatedById=:UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 3];
        //system.debug(userEvents);
        Set<Id> addressIDs=new Set<Id>();
        List<Task> userTasksNoAddress=new List<Task>();
        List<Event> userEventsNoAddress=new List<Event>();
        for(Task userTask: userTasks){
            if(userTask.WhatId!=null){
                addressIDs.add(userTask.WhatId);
            }else{
                userTasksNoAddress.add(userTask);
            }
        }
        for(Event userEvent: userEvents){
            if(userEvent.WhatId!=null){
                addressIDs.add(userEvent.WhatId);
            }else{
                userEventsNoAddress.add(userEvent);
            }
        }

            List<Task> tasks = userTasksNoAddress;
            List<Event> events = userEventsNoAddress;
            //System.debug('Assigned tasks go here '+ tasks );
            //System.debug('Assigned events go here '+ events );
            Integer tIndex = tasks.size();
            Integer eIndex = events.size();
            
            if( tIndex == 0 ){
                activityList.add( new Activity(null, events) );
            }
            else if( eIndex == 0 ){
                activityList.add( new Activity(null, tasks) );
            }
            else if( tIndex > 0 && eIndex > 0){
                tIndex = tasks.size()-1;
                eIndex = events.size()-1;
                while( tasks.size()+events.size() > 3 ){
                    //System.debug( 'Current Task is '+tasks[tIndex] );
                    //System.debug( 'Current Event is '+events[eIndex] );
                    if(tasks[tIndex].CreatedDate < events[eIndex].CreatedDate){
                        tasks.remove(tIndex);
                        if(tIndex > 0){
                            tIndex--;
                        }
                    }else{
                        events.remove(eIndex);
                        if(eIndex > 0){
                            eIndex--;
                        }
                    }
                }
                activityList.add( new Activity(null, tasks, events));
            }
            
            
        for( Customer_Address__c a : [SELECT id, 
                                          (SELECT id, CreatedById, Description, Day_of_Week__C, RecurrenceActivityId, Who.Name, What.Name, LastModifiedDate, Type__c, OwnerId, Owner.Name, Plan_Id__c, WhatId, Event_Name_or_Number__c, StartDateTime, Type, WhoId, EndDateTime, ActivityDate, CreatedDate, Rejected__c, Video_Contract_End__c, Knocked_Date__c, Security_Contract_End__c, Video_Competitor__c, Phone_Contract_End__c, Sales_Type__c, Internet_Contract_End__c, Phone_Competitor__c, Home_Security_Competitor__c, Internet_Competitor__c, Subject, HSI_Sold__c, Video_Sold__c, Voice_Sold__c, XH_Sold__c FROM Events WHERE StartDateTime>=TODAY AND CreatedById=:UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 3),
                                          (SELECT id, CreatedById, Description, Day_of_Week__C, RecurrenceActivityId, Who.Name, What.Name, LastModifiedDate, Type__c, OwnerId, Owner.Name, Plan_Id__c, WhatId, Status, Priority, Subject, Rejected_Reason__c, Event_Category__c, Internet_Contract_End__c, Phone_Competitor__c, Home_Security_Competitor__c, Internet_Competitor__c, Phone_Contract_End__c, Sales_Type__c, Security_Contract_End__c, Video_Competitor__c, Rejected__c, Video_Contract_End__c, Knocked_Date__c, CreatedDate, ActivityDate, HSI_Sold__c, Video_Sold__c, Voice_Sold__c, XH_Sold__c FROM Tasks WHERE Type__c!='Knock' AND (ActivityDate >=TODAY OR Status!='Completed') AND CreatedById=:UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 3)
                                      FROM Customer_Address__c WHERE Id IN:addressIDs OR plan__c = :planID] ){//LIMIT :RECORD_LIMIT OFFSET :offSet
            //System.debug('Query Row Limit at: '+Limits.getQueryRows() );
                                          
            tasks = a.Tasks;
            events = a.Events;
            /*System.debug('Assigned tasks go here '+ tasks );
            System.debug('Assigned events go here '+ events );*/
            tIndex = tasks.size();
            eIndex = events.size();
            if( tIndex == 0 && eIndex == 0 ){
                continue;
            }
            else if( tIndex == 0 ){
                activityList.add( new Activity(a.id, events) );
            }
            else if( eIndex == 0 ){
                activityList.add( new Activity(a.id, tasks) );
            }
            else{
                tIndex = tasks.size()-1;
                eIndex = events.size()-1;
                while( tasks.size()+events.size() > 3 ){
                    //System.debug( 'Current Task is '+tasks[tIndex] );
                    //System.debug( 'Current Event is '+events[eIndex] );
                    if(tasks[tIndex].CreatedDate < events[eIndex].CreatedDate){
                        tasks.remove(tIndex);
                        if(tIndex > 0){
                            tIndex--;
                        }
                    }else{
                        events.remove(eIndex);
                        if(eIndex > 0){
                            eIndex--;
                        }
                    }
                }
                activityList.add( new Activity(a.id, tasks, events));
            }
        }
        
        /*User currentUser=[Select Region__c From User Where Id=:UserInfo.getUserId()];
        List<Task> userKnocks=[SELECT id, WhatId FROM Task WHERE Type__c='Knock' AND Region__c=:currentUser.Region__c ORDER BY Knocked_Date__c DESC LIMIT 100];
        system.debug(userKnocks);
        for(Task userKnock: userKnocks){
            addressIDs.add(userKnock.WhatId);
        }*/

            for( Customer_Address__c a : [SELECT id,
                                          (SELECT id, CreatedById, Description, Day_of_Week__C, RecurrenceActivityId, Who.Name, What.Name, LastModifiedDate, Type__c, OwnerId, Owner.Name, Plan_Id__c, WhatId, Status, Priority, Subject, Rejected_Reason__c, Event_Category__c, Internet_Contract_End__c, Phone_Competitor__c, Home_Security_Competitor__c, Internet_Competitor__c, Phone_Contract_End__c, Sales_Type__c, Security_Contract_End__c, Video_Competitor__c, Rejected__c, Video_Contract_End__c, Knocked_Date__c, CreatedDate, ActivityDate, Non_Marketable_Reason__c, HSI_Sold__c, Video_Sold__c, Voice_Sold__c, XH_Sold__c FROM Tasks WHERE Type__c='Knock' ORDER BY Knocked_Date__c DESC LIMIT 10)
                                      FROM Customer_Address__c WHERE plan__c = :planId] ){
            //System.debug('Query Row Limit at: '+Limits.getQueryRows() );
                                          
            tasks = a.Tasks;
           // events = a.Events;
            //System.debug('Assigned tasks go here '+ tasks );
           // System.debug('Assigned events go here '+ events );
            tIndex = tasks.size();
            //eIndex = events.size();
            if( tIndex == 0 ){
                continue;
            }
            /*else if( tIndex == 0 ){
                activityList.add( new Activity(a.id, events) );
            }*/
          /*  else if( eIndex == 0 ){
                activityList.add( new Activity(a.id, tasks) );
            }*/
            else if(tIndex > 0){
                tIndex = tasks.size()-1;
               // eIndex = events.size()-1;
               /* while( tasks.size() > 3 ){
                    System.debug( 'Current Task is '+tasks[tIndex] );
                    System.debug( 'Current Event is '+events[eIndex] );
                    if(tasks[tIndex].CreatedDate < events[eIndex].CreatedDate){
                        tasks.remove(tIndex);
                        if(tIndex > 0){
                            tIndex--;
                        }
                    }else{
                        events.remove(eIndex);
                        if(eIndex > 0){
                            eIndex--;
                        }
                    }
                }*/
              //  activityList.add( new Activity(a.id, tasks, events));
                activityList.add( new Activity(a.id, tasks));
            }            
        }//End Customer Address List SOQL For Loop
        if( totalAddressRecords != 0 && activityList!=null && !activityList.isEmpty()){//Need this to prevent index out of bounds error
            activityList[0].hasNext = (offset + RECORD_LIMIT < totalAddressRecords);
        }
        //system.debug(activityList);
        return activityList;
    }
    
    global class Activity{
        
        private ID addressId;
        private List<Task> tasks;
        private List<Event> events;
        public boolean hasNext{get;set;}
        
        public Activity(Id addressId, List<Event> events){
            
            this.addressId = addressId;
            this.events = events.size() == 0 ? null : events;
        }
        public Activity(Id addressId, List<Task> tasks){
            
            this.addressId = addressId;
            this.tasks = tasks.size() == 0 ? null : tasks;
        }
        public Activity(Id addressId, List<Task> tasks, List<Event> events){
            this.addressId = addressId;
            this.tasks = tasks.size() == 0 ? null : tasks;
            this.events = events.size() == 0 ? null : events;
        }
    }
}