/**
* Class Name: KnockTriggerController 
* Author: Amitkumar Bangad, Accenture
* Date: 24-April-2013 
* Requirement # Request Id: 226, 324, 326, 238, 239 
* Description: This class contains controller action for various trigger events on Knocks.
* Last Modified :Animesh Datta, 03-24-2017 - Added logic for Actual roll up of Video/Voice/HSI/XH from knock to Property Event
* Modification History:
       * Modification 1:
       * Modification Description: Incorporated logic to update "On_Territory__c" field on the knock when any team members assigned to the turf team creates the knock.
       * User Story: US1072307 - Territory: Turf, Teams and Commissions
       * Modified By: Srini Bhattiprolu
       * Date: 4/19/2017
*/
public class KnockTriggerController{
     
    private static final String ASDRESS_OBJECT_NAME = 'Customer_Addesss__c';
    private static final String KNOCK_RECORDTYPE = Schema.SObjectType.Task.getRecordTypeInfosByName().get(Label.Knock).getRecordTypeId();
    private static final String KNOCK_TYPE_START = 'Start';
    /**
    * @Description: This method concatenates Subject as Disposition + Knock Date and calculates Location Difference.
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 24-April-2013
    * @Param: Trigger.New
    * @Return: void.
    */
    public static void populateSubjectForKnocks(List<Task> newTasksList) {
        String RecordTypeId = KNOCK_RECORDTYPE;
        for(Task knock : newTasksList){
            if(knock.RecordTypeId == RecordTypeId){
                if(knock.Knocked_Date__c == null){
                    knock.addError('Please enter the Knocked Date.');  
                } else{
                    String s = knock.Knocked_Date__c.format('MM/dd/yyyy');
                    knock.Subject = knock.Disposition__c + ' ' + s;
                    String createdDateUser = knock.Knocked_Date__c.format('MM/dd/yyyy');
                    Date myDate = Date.parse(createdDateUser);
                    knock.Created_Date_Custom__c = myDate;
                }
            }
        }            
    }
    /**
    * @Description: This gives the difference in minutes between dates.
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 16-May-2013
    * @Param: Trigger.NewMap, Trigger.OldMap
    * @Return: void.
    */
    public static Long getSecondsBetween(Datetime dt1, Datetime dt2){
        Long secondsBetween = (dt2.getTime()/(1000*60)) - (dt1.getTime()/(1000*60));
        return Math.abs(secondsBetween);
    }
    
    /**
    * @Description: This method executes onturf/offturf logic and update the off_turf Fields on Task (Knock)
    * @Author: Malay Desai, Accenture
    * @Date: 12-Oct-2015
    * @Param: Trigger.New
    * @Return: void.
    */
    public static void populateOffTurf(List<Task> knockList) {
    
          List<Task> onTurfKnockList = new List<Task>();
          Map<Id,Customer_Address__c> addressMap;
          Set<Id> addressIds = new Set<Id>();
          String knockRecordTypeId = KNOCK_RECORDTYPE;
          Long difference = 0;
          
          if(Trigger.isInsert || Trigger.isUpdate){
            for(Task knock : knockList){
                if(knock.RecordTypeId == knockRecordTypeId){
                    if(knock.Plan_Id__c != null || knock.Event_Category__c != null){
                        onTurfKnockList.add(knock);
                        addressIds.add(knock.whatId);
                    }else{
                        knock.Off_Turf__c=true; 
                    }
                }
            } 
            
            if(addressIds != null){
                addressMap =  new Map<Id,Customer_Address__c>([SELECT id,OwnerId,Assigned_Date__c,Team__c FROM Customer_Address__c WHERE Id IN:addressIds]);
            }
            if(!onTurfKnockList.IsEmpty()){
               for(Task knock:onTurfKnockList){
                     if(knock.WhatId!=null){
                        if(knock.Event_Category__c != null) {
                            knock.Off_Turf__c=false;
                        } else {
                            Customer_Address__c addr = addressMap.get(knock.whatId);
                            if(addr.Team__c == null){
                                if(addr.OwnerId==UserInfo.getUserId()){
                                    if(addr.Assigned_Date__c != null && knock.Knocked_Date__c != null){
                                        difference = getSecondsBetween(addr.Assigned_Date__c, knock.Knocked_Date__c);
                                        if(difference < ConfigurableParameters__c.getValues('OffTurfLimitMinutes').NumberValue__c && knock.Event_Category__c != null){
                                           knock.Off_Turf__c = false;
                                        }
                                        else if(difference < ConfigurableParameters__c.getValues('OffTurfLimitMinutes').NumberValue__c){
                                           knock.Off_Turf__c = true;
                                        } else {
                                            knock.Off_Turf__c = false;
                                        }
                                    }
                                }else{
                                    knock.Off_Turf__c = true;
                                }
                            }else{
                                List<Team_Member__c> teamUserIds=[Select User_Name__c from Team_Member__c WHERE Team__c=:addr.Team__c];
                                Set<Id> teamMemberIds=new Set<Id>();
                                for(Team_Member__c tm: teamUserIds){
                                    teamMemberIds.add(tm.User_Name__c);
                                }
    
                                if(teamMemberIds.contains(UserInfo.getUserId())){
                                    knock.Off_Turf__c = false; 
                                }else{
                                    knock.Off_Turf__c = true;  
                                }
                            }
                        }

                     } 
                    
               }
            }
            
            
          }
    
    }
      
   /**
    * @Description: This method populates most recent Knock Date on Address 
    * @Author: Malay Desai, Accenture
    * @Date: 05-Oct-2015
    * @Param: Trigger.New
    * @Return: void.
    */
    public static void populateKnockDateOnAddress(List<Task> newTasksList) {
        
        Map<Id,Customer_Address__c> addressMap = new Map<Id,Customer_Address__c>();
        Set<Id> addressIds = new Set<Id>();
        Set<Customer_Address__c> updatedAddressSet = new Set<Customer_Address__c>();
        List<Customer_Address__c> updatedAddressList = new List<Customer_Address__c>();
        String RecordTypeId = KNOCK_RECORDTYPE;
        if(Trigger.isInsert || Trigger.isUndelete){
            for(Task knock : newTasksList){
                if(knock.RecordTypeId == RecordTypeId){                                        
                    addressIds.add(knock.WhatId);                                      
                }
           } 
            
            if(!(addressIds.IsEmpty())){
              addressMap =  new Map<Id,Customer_Address__c>([select id, Number_of_Knocks__c, Most_Recent_Disposition__c,
                         Last_Knock_Date__c, Assigned_Date__c, Team__c, Plan__c, Plan__r.Plan_Status__c, OwnerId, Rejected_Reason__c From Customer_Address__c Where Id IN : addressIds]);
               
                for(Task knock: newTasksList){                    
                    if(!String.isEmpty(knock.WhatId) && knock.WhatId != null){
                        Customer_Address__c addr = addressMap.get(knock.WhatId);
                        if(addr.Last_Knock_Date__c != null){
                           if(addr.Last_Knock_Date__c < knock.Knocked_Date__c){
                               addr.Last_Knock_Date__c = knock.Knocked_Date__c;
                               addr.Most_Recent_Disposition__c = knock.Disposition__c;      
                            }
                        }else if(addr.Last_Knock_Date__c == null){
                            addr.Last_Knock_Date__c = knock.Knocked_Date__c; 
                            addr.Most_Recent_Disposition__c = knock.Disposition__c;   
                        }
                        if(knock.Disposition__c == 'Non-Marketable Address'){
                            addr.Non_Marketable__c = true;
                            addr.Non_Marketable_Reason__c = knock.Non_Marketable_Reason__c;
                            if(knock.Non_Marketable_Reason__c == 'No solicitation'){
                                addr.No_Solicitation__c = true;
                            }
                        }else if(knock.Rejected_Reason__c!=null){
                            addr.Rejected_Reason__c=knock.Rejected_Reason__c;
                        }
                        updatedAddressSet.add(addr);                            
                    }else{
                        knock.addError('Knock should be created from Address');
                    }
                    
                }
            }           
        }
       
        updatedAddressList.addAll(updatedAddressSet);
        if(!(updatedAddressList.IsEmpty())){
            try{
                 database.update (updatedAddressList);
            }catch (DmlException dmlEx){
                for(Integer i =0; i<dmlEx.getNumDml(); ++i) { 
                }
            }
        }
        
    }

       
    public static void populateWorkedDateOnAddress(List<Task> newTasksList){
        Map<Id,Datetime> workedDate = new Map<Id,Datetime>();
        Set<String> addressIds = new Set<String>();

        List<Task> workedTasks = new List<Task>();
        for(Task t : newTasksList){
            if(t.Disposition__c == 'Contact' || t.Disposition__c == 'Engage' || t.Disposition__c == 'Discover' || t.Disposition__c == 'Position' || t.Disposition__c == 'Start' || t.Disposition__c == 'Close'){
                addressIds.add(t.WhatId);
                workedDate.put(t.WhatId, t.Knocked_Date__c);
            }
        }

        if(!addressIds.isEmpty()){
            List<Customer_Address__c> addresses = [Select Id, WorkedDate__c From Customer_Address__c Where Id IN: addressIds];

            for(Customer_Address__c addrsObj : addresses){
                addrsObj.WorkedDate__c = workedDate.get(addrsObj.Id).Date();
            }
            try{
                Update addresses;
            } catch(Exception ex){
            }
        }
    }
   

    /**
    * @Description: This method updates the Turf Statistics on Plan.
    *               Handled on Insert, Delete, undelete
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 15-Map-2013
    * @Param: Trigger.old, Trigger.New
    * @Return: void.
    */
    public static void updateTurfStatistics(List<Task> oldTasksList, List<Task> newTasksList) {
        Set<Id> updatePlanIds = new Set<Id>();
        Map<Id,Plan__c> planByIdMap = new Map<Id,Plan__c>();
        Set<Id> updatePlaylistIds = new Set<Id>();
        Map<Id,Plan__c> playlistByIdMap = new Map<Id,Plan__c>();
        String RecordTypeId = KNOCK_RECORDTYPE;
        if(Trigger.IsUndelete || Trigger.isInsert){
            for(Task knock : newTasksList){
                if(knock.RecordTypeId == RecordTypeId){
                    updatePlanIds.add(knock.Plan_Id__c);
                    updatePlaylistIds.add(knock.Playlist_Id__c);
                   
                }
            }
        }
        /*if(Trigger.IsDelete){
            for(Task knock : oldTasksList){
                if(knock.RecordTypeId == RecordTypeId){
                    updatePlanIds.add(knock.Plan_Id__c);
                    updatePlaylistIds.add(knock.Playlist_Id__c);
                }
            }
        }*/
        if(!updatePlanIds.IsEmpty()){
            for (Plan__c pl : [Select Id, Name, Expiration_Date__c, Plan_Level__c, Plan_Status__c, No_of_Close__c,
                               No_of_Contact__c, No_of_Discover__c, No_of_Door_Hanger__c, No_of_Engage__c, No_of_Knock__c,
                               No_of_Start__c, No_of_Position__c, No_of_No_Knock__c, No_of_No_Answer__c from Plan__c 
                               where Id IN: updatePlanIds AND Plan_Level__c =: Label.PlanTypeTurf AND Plan_Status__c =: Label.PlanStatusAssigned]){
                if(pl.No_of_Close__c == null){
                    pl.No_of_Close__c = 0;
                }
                if(pl.No_of_Contact__c == null){
                    pl.No_of_Contact__c = 0;
                }
                if(pl.No_of_Discover__c == null){
                    pl.No_of_Discover__c = 0;
                }
                if(pl.No_of_Door_Hanger__c == null){
                    pl.No_of_Door_Hanger__c = 0;
                }
                if(pl.No_of_Engage__c == null){
                    pl.No_of_Engage__c = 0;
                }
                if(pl.No_of_Knock__c == null){
                    pl.No_of_Knock__c = 0;
                }
                if(pl.No_of_Start__c == null){
                    pl.No_of_Start__c = 0;
                }
                if(pl.No_of_Position__c == null){
                    pl.No_of_Position__c = 0;
                }
                if(pl.No_of_No_Answer__c == null){
                    pl.No_of_No_Answer__c = 0;
                }
                if(pl.No_of_No_Knock__c == null){
                    pl.No_of_No_Knock__c = 0;
                }   
                planByIdMap.put(pl.Id,pl);                  
            }
        }
        //Decrement The Knock Statistics on Plan depending upon type of Disposition on Knock being deleted
        /*if(Trigger.IsDelete && !planByIdMap.IsEmpty()){
            for (Task knock : oldTasksList) {
                if(planByIdMap.containsKey(knock.Plan_Id__c) && planByIdMap.get(knock.Plan_Id__c).No_of_Knock__c != 0){
                    planByIdMap.get(knock.Plan_Id__c).No_of_Knock__c --;
                    
                    if(knock.Disposition__c == Label.DispositionTypeClose 
                        && planByIdMap.get(knock.Plan_Id__c).No_of_Close__c != 0){
                        planByIdMap.get(knock.Plan_Id__c).No_of_Close__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeDoorHanger
                        && planByIdMap.get(knock.Plan_Id__c).No_of_Door_Hanger__c != 0){
                        planByIdMap.get(knock.Plan_Id__c).No_of_Door_Hanger__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeNoAnswer
                        && planByIdMap.get(knock.Plan_Id__c).No_of_No_Answer__c != 0){
                        planByIdMap.get(knock.Plan_Id__c).No_of_No_Answer__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeNoKnock
                        && planByIdMap.get(knock.Plan_Id__c).No_of_No_Knock__c != 0){
                        planByIdMap.get(knock.Plan_Id__c).No_of_No_Knock__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeAddress
                        && planByIdMap.get(knock.Plan_Id__c).No_of_No_Knock__c != 0){
                        planByIdMap.get(knock.Plan_Id__c).No_of_No_Knock__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeStart
                        && planByIdMap.get(knock.Plan_Id__c).No_of_Start__c != 0){
                        planByIdMap.get(knock.Plan_Id__c).No_of_Start__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeDiscover
                        && planByIdMap.get(knock.Plan_Id__c).No_of_Discover__c != 0){
                        planByIdMap.get(knock.Plan_Id__c).No_of_Discover__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeEngage
                        && planByIdMap.get(knock.Plan_Id__c).No_of_Engage__c != 0){
                        planByIdMap.get(knock.Plan_Id__c).No_of_Engage__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypePosition
                        && planByIdMap.get(knock.Plan_Id__c).No_of_Position__c != 0){
                        planByIdMap.get(knock.Plan_Id__c).No_of_Position__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeContact
                        && planByIdMap.get(knock.Plan_Id__c).No_of_Contact__c != 0){
                        planByIdMap.get(knock.Plan_Id__c).No_of_Contact__c --;
                    }
                }
            }
        }*/
        //Increment The Knock Statistics on Plan depending upon type of Disposition on Knock being inserted/undeleted
        if((Trigger.IsUnDelete || Trigger.IsInsert) && !planByIdMap.IsEmpty()){
            for (Task knock : newTasksList) {
                if(planByIdMap.containsKey(knock.Plan_Id__c)){
                    planByIdMap.get(knock.Plan_Id__c).No_of_Knock__c ++;
                    
                    if(knock.Disposition__c == Label.DispositionTypeClose){
                        planByIdMap.get(knock.Plan_Id__c).No_of_Close__c ++;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeDoorHanger){
                        planByIdMap.get(knock.Plan_Id__c).No_of_Door_Hanger__c ++;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeNoAnswer){
                        planByIdMap.get(knock.Plan_Id__c).No_of_No_Answer__c ++;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeNoKnock){
                        planByIdMap.get(knock.Plan_Id__c).No_of_No_Knock__c ++;
                    }
                    if(knock.Disposition__c == label.DispositionTypeAddress){
                        planByIdMap.get(knock.Plan_Id__c).No_of_No_Knock__c ++;
                    }
                    if(knock.Disposition__c == label.DispositionTypeStart){
                        planByIdMap.get(knock.Plan_Id__c).No_of_Start__c ++;
                    }
                    if(knock.Disposition__c == label.DispositionTypeDiscover){
                        planByIdMap.get(knock.Plan_Id__c).No_of_Discover__c ++;
                    }
                    if(knock.Disposition__c == label.DispositionTypeEngage){
                        planByIdMap.get(knock.Plan_Id__c).No_of_Engage__c ++;
                    }
                    if(knock.Disposition__c == label.DispositionTypePosition){
                        planByIdMap.get(knock.Plan_Id__c).No_of_Position__c ++;
                    }
                    if(knock.Disposition__c == label.DispositionTypeContact){
                        planByIdMap.get(knock.Plan_Id__c).No_of_Contact__c ++;
                    }
                }
            }
        }
        
        if(!updatePlaylistIds.IsEmpty()){
        
            for (Plan__c pl : [Select Id, Name, Expiration_Date__c, Plan_Level__c, Plan_Status__c, No_of_Close__c,No_of_Contact__c, No_of_Discover__c, No_of_Door_Hanger__c, No_of_Engage__c, No_of_Knock__c,No_of_Start__c, No_of_Position__c,No_of_No_Knock__c, No_of_No_Answer__c from Plan__c where Id IN:updatePlaylistIds AND Plan_Level__c =: Label.PlanTypePlaylist AND Plan_Status__c =: Label.PlanStatusAssigned]){
               
                if(pl.No_of_Close__c == null){
                    pl.No_of_Close__c = 0;
                }
                if(pl.No_of_Contact__c == null){
                    pl.No_of_Contact__c = 0;
                }
                if(pl.No_of_Discover__c == null){
                    pl.No_of_Discover__c = 0;
                }
                if(pl.No_of_Door_Hanger__c == null){
                    pl.No_of_Door_Hanger__c = 0;
                }
                if(pl.No_of_Engage__c == null){
                    pl.No_of_Engage__c = 0;
                }
                if(pl.No_of_Knock__c == null){
                    pl.No_of_Knock__c = 0;
                }
                if(pl.No_of_Start__c == null){
                    pl.No_of_Start__c = 0;
                }
                if(pl.No_of_Position__c == null){
                    pl.No_of_Position__c = 0;
                }
                if(pl.No_of_No_Answer__c == null){
                    pl.No_of_No_Answer__c = 0;
                }
                if(pl.No_of_No_Knock__c == null){
                    pl.No_of_No_Knock__c = 0;
                }   
                playlistByIdMap.put(pl.Id,pl);                  
            }
        }
        //Decrement The Knock Statistics on Plan depending upon type of Disposition on Knock being deleted
        /*if(Trigger.IsDelete && !playlistByIdMap.IsEmpty()){
            for (Task knock : oldTasksList) {
                if(playlistByIdMap.containsKey(knock.Playlist_Id__c) && playlistByIdMap.get(knock.Playlist_Id__c).No_of_Knock__c != 0){
                    playlistByIdMap.get(knock.Playlist_Id__c).No_of_Knock__c --;
                    
                    if(knock.Disposition__c == Label.DispositionTypeClose 
                        && playlistByIdMap.get(knock.Playlist_Id__c).No_of_Close__c != 0){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_Close__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeDoorHanger
                        && playlistByIdMap.get(knock.Playlist_Id__c).No_of_Door_Hanger__c != 0){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_Door_Hanger__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeNoAnswer
                        && playlistByIdMap.get(knock.Playlist_Id__c).No_of_No_Answer__c != 0){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_No_Answer__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeNoKnock
                        && playlistByIdMap.get(knock.Playlist_Id__c).No_of_No_Knock__c != 0){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_No_Knock__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeAddress
                        && playlistByIdMap.get(knock.Playlist_Id__c).No_of_No_Knock__c != 0){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_No_Knock__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeStart
                        && playlistByIdMap.get(knock.Playlist_Id__c).No_of_Start__c != 0){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_Start__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeDiscover
                        && playlistByIdMap.get(knock.Playlist_Id__c).No_of_Discover__c != 0){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_Discover__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeEngage
                        && playlistByIdMap.get(knock.Playlist_Id__c).No_of_Engage__c != 0){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_Engage__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypePosition
                        && playlistByIdMap.get(knock.Playlist_Id__c).No_of_Position__c != 0){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_Position__c --;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeContact
                        && playlistByIdMap.get(knock.Playlist_Id__c).No_of_Contact__c != 0){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_Contact__c --;
                    }
                }
            }
        }*/
        //Increment The Knock Statistics on Plan depending upon type of Disposition on Knock being inserted/undeleted
        if((Trigger.IsUnDelete || Trigger.isInsert) && !playlistByIdMap.IsEmpty()){
            for (Task knock : newTasksList) {
                if(playlistByIdMap.containsKey(knock.Playlist_Id__c)){
                    playlistByIdMap.get(knock.Playlist_Id__c).No_of_Knock__c ++;
                    
                    if(knock.Disposition__c == Label.DispositionTypeClose){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_Close__c ++;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeDoorHanger){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_Door_Hanger__c ++;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeNoAnswer){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_No_Answer__c ++;
                    }
                    if(knock.Disposition__c == Label.DispositionTypeNoKnock){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_No_Knock__c ++;
                    }
                    if(knock.Disposition__c == label.DispositionTypeAddress){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_No_Knock__c ++;
                    }
                    if(knock.Disposition__c == label.DispositionTypeStart){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_Start__c ++;
                    }
                    if(knock.Disposition__c == label.DispositionTypeDiscover){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_Discover__c ++;
                    }
                    if(knock.Disposition__c == label.DispositionTypeEngage){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_Engage__c ++;
                    }
                    if(knock.Disposition__c == label.DispositionTypePosition){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_Position__c ++;
                    }
                    if(knock.Disposition__c == label.DispositionTypeContact){
                        playlistByIdMap.get(knock.Playlist_Id__c).No_of_Contact__c ++;
                    }
                }
            }
        }
        if(!planByIdMap.isEmpty()){
            try{
                Database.SaveResult[] rest = Database.update(planByIdMap.values(),false);              
            }catch (DmlException dmlEx){
                for(Integer i =0; i<dmlEx.getNumDml(); ++i) {
                }
            }
        }
        
        if(!playlistByIdMap.isEmpty()){
            try{
                Database.SaveResult[] rest = Database.update(playlistByIdMap.values(),false);              
            }catch (DmlException dmlEx){
                for(Integer i =0; i<dmlEx.getNumDml(); ++i) { 
                }
            }
        }
    }
    /**
    * @Description: This method rolls up count of Knock on Address.
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 24-April-2013
    * @Param: Trigger.old, Trigger.New
    * @Return: void.
    */
    public static void rollupKnockCount(List<Task> oldTasksList,List<Task> newTasksList) {
    
        String RecordTypeId = KNOCK_RECORDTYPE; 
        Map<Id,Customer_Address__c> addressMap = new Map<Id,Customer_Address__c>();
        Set<Id> updateAddressIds = new Set<Id>();
        Map<Id, Integer> addressKnockMap = new Map<Id, Integer>();
        if(Trigger.isInsert || Trigger.isUndelete){
            for(Task knock : newTasksList){
                if(knock.RecordTypeId == RecordTypeId){
                    updateAddressIds.add(knock.WhatId);
                    if (addressKnockMap.containsKey(knock.WhatId)){
                        addressKnockMap.put(knock.WhatId,addressKnockMap.get(knock.WhatId) +1);
                    } else {
                        addressKnockMap.put(knock.WhatId,1);
                    }
                }
            }
        }
        /*if(Trigger.isDelete){
            for(Task knock : oldTasksList){
                if(knock.RecordTypeId == RecordTypeId){
                    updateAddressIds.add(knock.WhatId);
                    if (addressKnockMap.containsKey(knock.WhatId)){
                        addressKnockMap.put(knock.WhatId,addressKnockMap.get(knock.WhatId) -1);
                    } else {
                        addressKnockMap.put(knock.WhatId,-1);
                    }
                }
            }
        }*/
        if(!(updateAddressIds.isEmpty())){ 
            // Run an optimized query that looks for all address that meet the if/then criteria
            for(Customer_Address__c add : [select id, Number_of_Knocks__c, Plan__c, Plan__r.Plan_Status__c from Customer_Address__c
                                               where Id in : updateAddressIds  AND Plan__c != null AND Plan__r.Plan_Status__c != : Label.PlanStatusExpired ]){
                if(add.Number_of_Knocks__c != null){
                    add.Number_of_Knocks__c = add.Number_of_Knocks__c + addressKnockMap.get(add.Id); 
                } else {
                    add.Number_of_Knocks__c = 0 + addressKnockMap.get(add.Id);     
                }
                addressMap.put(add.Id,add);
            }
             
            // Update all the address with new value for Knock Count.
            try{
                 database.update (addressMap.values()); 
            }catch (DmlException dmlEx){
                for(Integer i =0; i<dmlEx.getNumDml(); ++i) { 
                }
            }
        }
    }
    /**
    * @Description: This captures Turf Id on Knock.
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 17-May-2013
    * @Param: Trigger.New
    * @Return: void.
    */
    public static void captureTurfIdAndRegion(List<Task> newTasksList) {
    
        String RecordTypeId = KNOCK_RECORDTYPE; 
        Map<Id, Id> planByAddressIdMap = new Map<Id,Id>();
        Map<Id,Id> playlistByAddressIdMap = new Map<Id,Id>();
        Map<Id, Customer_Address__c> AddressIdByAddressMap = new Map<Id,Customer_Address__c>();
        Set<Id> addressIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();
        if(Trigger.isInsert){
            for(Task knock : newTasksList){
                if(knock.RecordTypeId == RecordTypeId){
                    addressIds.add(knock.WhatId);
                    ownerIds.add(knock.OwnerId);                    
                }
            }
        }      
        
        Map<Id, User> userWithIdMap = new Map<Id, User>([SELECT Id, Sales_Rep_Type__c FROM User WHERE Id IN:ownerIds]);
        
        if(!(addressIds.isEmpty())){ 
            for(Customer_Address__c add : [select id, Number_of_Knocks__c, Dwelling_Type__c, Plan__c, Plan__r.Plan_Status__c, Region__c, Plan__r.Plan_Level__c, Plan__r.Parent_Plan__c from Customer_Address__c 
                                           where Id in : addressIds ]){
                if(add.Plan__c != null && add.Plan__r.Plan_Status__c != Label.PlanStatusExpired) {
                    if(add.Plan__r.Plan_Level__c == Label.PlanTypeTurf){
                        planByAddressIdMap.put(add.Id,add.Plan__c); 
                    } else if (add.Plan__r.Plan_Level__c == Label.PlanTypePlaylist){
                        planByAddressIdMap.put(add.Id,add.Plan__r.Parent_Plan__c); 
                        playlistByAddressIdMap.put(add.Id,add.Plan__c);
                    }
                }
                AddressIdByAddressMap.put(add.Id, add);
            }
            if(!planByAddressIdMap.IsEmpty() || !AddressIdByAddressMap.IsEmpty() || !playlistByAddressIdMap.IsEmpty()){
                for(Task knock : newTasksList){
                    if(planByAddressIdMap.get(knock.WhatId) != null){
                        knock.Plan_Id__c = planByAddressIdMap.get(knock.WhatId);
                    }
                    if(playlistByAddressIdMap.get(knock.WhatId) != null){
                        knock.Playlist_Id__c = playlistByAddressIdMap.get(knock.WhatId);
                    }                    
                    if(knock.WhatId!=null){
                        knock.Region__c = AddressIdByAddressMap.get(knock.WhatId).Region__c;
                        knock.Dwelling_Type__c = AddressIdByAddressMap.get(knock.WhatId).Dwelling_Type__c;
                    }
                    if(knock.Knocked_Date__c == null){
                        knock.addError('Please enter the Knocked Date.');  
                    } else {
                        knock.timestamp__c = knock.Knocked_Date__c.format('h:mm a');
                    }
                    knock.DSR_Type__c = userWithIdMap.get(knock.OwnerId).Sales_Rep_Type__c;
                }
            }
        }
    }

    /**
    * @Description: validate Knock creation permission
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 11-June-2013
    * @Param: Trigger.New
    * @Return: void.
    */
    public static void checkKnockCreatePermissions(List<Task> newTasksList) {
        String knockRecordTypeId = KNOCK_RECORDTYPE; 
        String callRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId(); 
        String actRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('General Activity').getRecordTypeId(); 
        String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Task').getRecordTypeId(); 
        Profile p = [Select Id, Name from Profile where Name =:Label.DSRProfileName];
        Map<Id, Id> ownerByAddressIdMap = new Map<Id,Id>();
        Map<Id, Id> ownerByAddressIdTeamMap = new Map<Id,Id>();
        Map<Id, Id> teamByAddressIdMap = new Map<Id,Id>();
        Set<Id> addressIds = new Set<Id>();
        Set<Id> teamIds = new Set<Id>();
        string addressPrefix = Customer_Address__c.sObjectType.getDescribe().getKeyPrefix();        
        if(Trigger.isInsert){
            for(Task knock : newTasksList){
                If(knock.WhatId != null){
                    if(String.Valueof(knock.WhatId).equalsIgnoreCase(addressPrefix)){
                        addressIds.add(knock.WhatId);
                    }
                }
            }
        }
        if(UserInfo.getProfileId() == p.Id){   
            if(!(addressIds.isEmpty())){ 
                User addressQueue = [Select Id, Name from User where Name ='Shared Data User'];
                for(Customer_Address__c add : [select id, OwnerId, Number_of_Knocks__c, Plan__c, Plan__r.Plan_Status__c,                       Plan__r.Plan_Level__c, Team__c, Plan__r.Parent_Plan__c from Customer_Address__c 
                                               where Id in : addressIds]){
                    if(add.OwnerId != UserInfo.getUserId()){    
                        if(add.OwnerId == addressQueue.Id){
                            ownerByAddressIdMap.put(add.Id,add.OwnerId);
                        } else{
                            if (add.Team__c == null){
                                ownerByAddressIdMap.put(add.Id,add.OwnerId);
                            } else{
                                teamByAddressIdMap.put(add.Id,add.Team__c);
                                ownerByAddressIdMap.put(add.Id,add.OwnerId);       
                            }
                        }
                    }
                }
                if(!(teamByAddressIdMap.IsEmpty())){
                    for(Team__c tm : [Select Id, Name, Supervisor__c, (SELECT Id, Name, User_Name__c from Team_Members__r) from                 Team__c where Id =: teamByAddressIdMap.values()]){
                        for (Team_Member__c Tmem : tm.Team_Members__r) {
                            if(Tmem.User_Name__c == UserInfo.getUserId()){
                                teamIds.add(tm.Id);     
                            }                       
                        }
                    }
                }
                if(!(teamIds.IsEmpty())){
                    for(Id addId : teamByAddressIdMap.keyset()){
                        if(teamIds.contains(teamByAddressIdMap.get(addId))){
                            ownerByAddressIdMap.remove(addId);  
                        }
                    }               
                }           
            }
            if(!(ownerByAddressIdMap.IsEmpty())){
                for(Task tk : newTasksList){
                    if(ownerByAddressIdMap.containskey(tk.WhatId)){
                        if(tk.recordTypeId == knockRecordTypeId && tk.Event_Category__c != NULL){
                            //tk.addError(Label.UnAuthorizedKnock);
                            tk.Off_Turf__c = false;
                        }
                        else if(tk.recordTypeId == knockRecordTypeId){
                            tk.Off_Turf__c = true;
                        }
                        /*if(tk.recordTypeId == callRecordTypeId){
                            tk.addError(Label.UnAuthorizedCallLog);
                        }
                        if(tk.recordTypeId == actRecordTypeId){
                            tk.addError(Label.UnAuthorizedActivity);
                        }
                        if(tk.recordTypeId == taskRecordTypeId){
                            tk.addError(Label.UnAuthorizedTask);
                        }*/
                    }
                }
            }
        }
    }
    /**
    * @Description: Create a record of iKnock when knock is created with Disposition as START
    * @Author: Gaurav Aggarwal, Accenture
    * @Date: 09-Oct-2013
    * @Param: Trigger.New
    * @Return: void.
    */
    public static void createiKnockRecords(List<Task> newTaskList) {
        Map<Id,Id> knockByAddressId = new Map<Id,Id>();
        Map<Id,Id> knockByUserId = new Map<Id,Id>();
        Map<ID, Customer_Address__C> addressIdByAddressMap = new Map<ID, Customer_Address__C>();
        List<iKnock__c> iKnockList = new List<iKnock__c>();
        for(Task knock : newTaskList){
            if(knock.Disposition__c == 'Start'){
                knockByAddressId.put(knock.Id,knock.WhatId);
                knockByUserId.put(knock.Id,knock.OwnerId);
            }
        }
        if(!knockByAddressId.isEmpty()){
            Map<Id, User> userWithIdMap = new Map<Id, User>([SELECT Id, name, Email, Sales_ID__c FROM User WHERE Id IN:knockByUserId.values()]);
            for(Customer_Address__c cAdd : [Select Id, Billing_Account_Key__c, Billing_House_Key__c, Corp__c, Do_not_Knock__c,Targeted__c from Customer_Address__c where ID IN: knockByAddressId.values()]){
                addressIdByAddressMap.put(cAdd.ID,cAdd);
            }
            for(Task knk : newTaskList){
                    iKnock__c iknk = new iKnock__c();
                    User usr = userWithIdMap.get(knockByUserId.get(knk.Id));
                    ID custId = knockByAddressId.get(knk.Id);
                    if(custId != null){
                        Customer_Address__c addr = addressIdByAddressMap.get(custId);
                        if(usr != null && addr != null){
                        iknk.name = usr.Sales_ID__c +' '+ knk.Knocked_Date__c;
                        iknk.CreatedDate__c = Date.ValueOf(knk.Knocked_Date__c);
                        iknk.Off_Turf__c = knk.Off_Turf__c;
                        iknk.Knock_Owner__c = usr.name;
                        iknk.Knock_Owner_Email__c = usr.Email;
                        iknk.Sales_ID__c = usr.Sales_ID__c;
                        iknk.Billing_Account_Key__c = addr.Billing_Account_Key__c;
                        iknk.Billing_House_Key__c = addr.Billing_House_Key__c;
                        iknk.Corp_Sysprin__c = addr.Corp__c;
                        iknk.Do_Not_Knock__c = addr.Do_not_Knock__c;
                        //Enchancement done for US739205 iknock record will have Targeted__c flag similar to Address record when created
                        iknk.Targeted__c = addr.Targeted__c;
                        iKnockList.add(iknk);
                        } else{
                        }
                    }else{
                    }
            }
        }
        Database.SaveResult[] saveResult = Database.Insert(iKnockList, false); 
        for (Integer i = 0; i < saveResult.size(); i++) {
            if (saveResult[i].isSuccess()) {
            } else {
            }
        }
    }
    
    /**
    * @Description: This method updates customer address for Knocks on Task.
    /*@User story : US508031
    * @Author: Anil Singh, Accenture
    * @Date: 13-Aug-2015
    */
    Public static void updateCustomerAddressKnockTask (List<Task> newTasksList) {
        String RecordTypeId = KNOCK_RECORDTYPE;
            for(Task knock : newTasksList){
            if(RecordTypeId.equalsIgnoreCase(knock.RecordTypeId)){
                 if(knock.whatId != null && String.valueOf(knock.WhatId).startsWith(Customer_Address__c.sobjecttype.getDescribe().getKeyPrefix())){
                     knock.Customer_Address__c = knock.whatId;
                }
                else{
                    knock.Customer_Address__c = null;
                }
            }
        }
    }
    
    
    /**
    * @Description: This method updates offTurfStartDate/onTurfStartDate field  on customer address with the created date of Knocks on Task.
    /*@User story : US683480
    * @Author: Tejaswini Kasar, Accenture
    * @Date: 18-May-2016
    */
    public static void populateKnockCreatedDateOnAddress(List<Task> newTasksList) {
        String RecordTypeId = KNOCK_RECORDTYPE;
        Set<Id> addressIds = new Set<Id>();
        set<Customer_Address__c> updatedAddressSet = new set<Customer_Address__c>();
        List<Customer_Address__c> updatedAddressList = new List<Customer_Address__c>();
        for(Task knock : newTasksList){
            if(knock.RecordTypeId == RecordTypeId && knock.Disposition__c=='Start'){
               if(knock.Off_Turf__c==true){
                    addressIds.add(knock.WhatId);                 
                } else if(knock.Off_Turf__c==false ){
                    addressIds.add(knock.WhatId);               
                }
            }    
        }
        
        Map<Id,Customer_Address__c> addressMap =  new Map<Id,Customer_Address__c> ([SELECT id,Plan__c,offTurfStartDate__c,onTurfStartDate__c from Customer_Address__c where id=:addressIds]);        
        
        if(!(addressIds.IsEmpty())){
            for(Task knock: newTasksList){            
                if(!String.isEmpty(knock.WhatId) && knock.WhatId != null){
                    Customer_Address__c addr = addressMap.get(knock.WhatId);
                    if(knock.Off_Turf__c==true){
                        addr.offTurfStartDate__c=date.valueOf(knock.CreatedDate);
                    } else if (knock.Off_Turf__c==false){
                        addr.onTurfStartDate__c=date.valueOf(knock.CreatedDate);
                    }
                    updatedAddressSet.add(addr);          
                }
            }
        }
        
        updatedAddressList.addAll(updatedAddressSet);
        
        if(!(updatedAddressList.IsEmpty())){
            try{
                 database.update (updatedAddressList);
            }catch (DmlException dmlEx){
                for(Integer i =0; i<dmlEx.getNumDml(); ++i) {
                }
            }
        }
    }
    
    /**
    * @Description: This method updates Is_Targeted__c and OnTerritory fields on Knock from Address.
    /*@User story : US828881
    * @Author: Ashish Srivastava, Accenture
    * @Date: 26-October-2016
    * Modification History:
       * Modification 1:
       * Modification Description: Incorporated logic to update "On_Territory__c" field on the knock when any team members assigned to the turf team creates the knock.
       * User Story: US1072307 - Territory: Turf, Teams and Commissions
       * Modified By: Srini Bhattiprolu
       * Date: 4/19/2017
     */
    public static void populateOrangeAndTerritoryOnKnocks(List<Task> newTasksList){
        String RecordTypeId = KNOCK_RECORDTYPE;
        Set<Id> addressIds = new Set<Id>();
        Set<Id> addressTeamIds = new Set<Id>();//To capture the team associated to the address
        Map<Id,Customer_Address__c> addressMap =  new Map<Id,Customer_Address__c> ();
        Map<Id,Team_Member__c> addressTeamMembersMap = new Map<Id,Team_Member__c>();
        List<Customer_Address__c> addressList = new List<Customer_Address__c>();
        for(Task knock : newTasksList){
            if(knock.RecordTypeId == RecordTypeId && knock.WhatId != null && Variable_Setting__c.getInstance('AddressObject Prefix') !=null && Variable_Setting__c.getInstance('AddressObject Prefix').Value__c != null && String.valueOf(knock.WhatId).startsWith(Variable_Setting__c.getInstance('AddressObject Prefix').Value__c)){
                addressIds.add(knock.WhatId);
            }
        }
        //*** Start *** US1072307 - To capture required address fields and address team
        if(!addressIds.isEmpty()){
            for(Customer_Address__c address : [SELECT Id,OwnerId,Targeted__c,Territory__c, Territory__r.OwnerId, Team__c from Customer_Address__c where id IN :addressIds]){
            addressMap.put (address.Id, address);
            addressTeamIds.add (address.Team__c);           
            }
        //*** End *** US1072307 - To capture required address fields and address team
        //*** Start *** US1072307 - Map of team members associated to the Address team
            if (!addressTeamIds.isEmpty()){
            for (Team_Member__c teamMembers : [SELECT Id, User_Name__c, Team__c from Team_Member__c where Team__c IN :addressTeamIds ]){
                addressTeamMembersMap.put(teamMembers.User_Name__c, teamMembers);
                }
            }
        //*** End *** US1072307 - Map of team members associated to the Address team
            }
            for(Task knock : newTasksList){
                if(knock.RecordTypeId == RecordTypeId && knock.WhatId != null && !String.isEmpty(knock.WhatId) && Variable_Setting__c.getInstance('AddressObject Prefix') != null && Variable_Setting__c.getInstance('AddressObject Prefix').Value__c != null && String.valueOf(knock.WhatId).startsWith(Variable_Setting__c.getInstance('AddressObject Prefix').Value__c)){
                    Customer_Address__c addr = addressMap.get(knock.WhatId);
                    knock.Is_Targeted__c = addr.Targeted__c;
                   //*** Start *** US1072307 - Logic to update the On Territory flag for the knocks worked by assigned team and assigned user
                   if((addr.Territory__c != null && !addressTeamMembersMap.isEmpty() && addressTeamMembersMap.get(UserInfo.getuserId()) != null) || (addr.Territory__c != null && addr.Territory__r.OwnerId == UserInfo.getuserId())){
                        knock.On_Territory__c = True;
                    }
                    else{
                        knock.On_Territory__c = False;
                    }
                   //*** End *** US1072307 - Logic to update the On Territory flag for the knocks worked by assigned team and assigned user
                }
            }
    }
     /**
    * @Description: This method updates the InTerritory field on Territory if tied to a address.
    /*@User story : US828881
    * @Author: Ashish Srivastava, Accenture
    * @Date: 27-October-2016
    */
   /* public static void populateTerritoryForAssignedAddress(List<Task> newTasksList){
        String RecordTypeId = KNOCK_RECORDTYPE;
        Set<Id> addressIds = new Set<Id>();
        Set<Id> territoryIds = new Set<Id>();
        List<Territory__c> territoryList = new List<Territory__c>();
        List<Territory__c> updateTerritoryList = new List<Territory__c>();
        for(Task knock : newTasksList){
            if(knock.RecordTypeId == RecordTypeId){
                addressIds.add(knock.WhatId);
            }
        }
        if(!addressIds.isEmpty()){
            Map<Id,Customer_Address__c> addressMap =  new Map<Id,Customer_Address__c> ([SELECT Id,OwnerId,Territory__c, Territory__r.OwnerId,Territory__r.In_Territory__c from Customer_Address__c where id=:addressIds]);
            for(Task knock : newTasksList){
                if(knock.WhatId != null && !String.isEmpty(knock.WhatId)){
                    Customer_Address__c addr = addressMap.get(knock.WhatId);
                    if(addr.OwnerId == addr.Territory__r.OwnerId){
                        territoryIds.add(addr.Territory__c);
                    }
                }
            }
        }
        territoryList = [SELECT Id,Name,In_Territory__c FROM Territory__c WHERE ID IN : territoryIds];
        
        if(!territoryList.isEmpty()){
            for(Territory__c territory: territoryList){
                territory.In_Territory__c = TRUE;
                updateTerritoryList.add(territory);
            }
        }
        
        if(!updateTerritoryList.isEmpty()){
            Database.update(updateTerritoryList,false);
        }
    }*/
    
    
    
    
    /**
    * @Description: This method set the HSI Only flag True for non-targeted addresses while creating knock(Only if HSI Active = true addresses)
    * @Author: Amit Kumar Pradhan, Accenture
    * @Date: 11-Nov-2016
    * @Param: Trigger.New
    * @Return: void.
    **/
    public static void settingOfHSIOnlyFlag(List<Task> taskList) {
        List<Task> knockList = new List<Task>();          
        Set<Id> addressIds = new Set<Id>();
        Map<Id,Customer_Address__c> addressMap;
        String knockRecordTypeId = KNOCK_RECORDTYPE;
       
        for(Task taskObj : taskList){
            if(taskObj.RecordTypeId == knockRecordTypeId && taskObj.WhatId != null){                   
                addressIds.add(taskObj.whatId);
                knockList.add(taskObj);
            }
        } 
        
        if(addressIds != null){
            addressMap =  new Map<Id,Customer_Address__c>([SELECT Id,Targeted__c, Video_Active1__c, Voice_Active1__c, XH_Active1__c, HSI_Active1__c FROM Customer_Address__c WHERE Id IN:addressIds]);
        }    
        if(!knockList.isEmpty()){
            for(Task knock : knockList){
                if(!addressMap.isEmpty() && addressMap.containsKey(knock.whatId)){
                    Customer_Address__c addr = addressMap.get(knock.whatId);                            
                    if(addr.Targeted__c != true){
                        if(addr.Video_Active1__c == false && addr.Voice_Active1__c == false && addr.XH_Active1__c == false && addr.HSI_Active1__c == true){
                            knock.HSI_only__c = true;
                        }
                    }
                }
            }                           
        }    
    }
    
    /**
    * @Description: Roll up Voice, Video, XH, HSI to Property Event when Start Knock is created with a property event or updated with a property event
    * @Author: Animesh Datta, Accenture
    * @Date: 30-Jan-2017
    * @Param: Trigger.New, Trigger.OldMap
    * @Return: void.
    **/
    public static void updatePropertyEvent(List<Task> newTaskList,Map<Id,Task> oldTriggerMap) {
        List<Property_Events__c> propertEventList = new List<Property_Events__c>();
        List<Property_Events__c> EventLst;
        List<Task> knockList = new List<Task>();
        Set<Id> propertyEventId = new Set<Id>();
        Map<String,Integer> voiceCountMap = new Map<String,Integer>();
        Map<String,Integer> videoCountMap = new Map<String,Integer>();
        Map<String,Integer> xhCountMap = new Map<String,Integer>();
        Map<String,Integer> hsiCountMap = new Map<String,Integer>();
        try{
            for(Task taskObj: newTaskList){
                if(taskObj.RecordTypeId==KNOCK_RECORDTYPE && taskObj.Property_Event__c!=null && taskObj.Disposition__c == KNOCK_TYPE_START){
                    knockList.add(taskObj);
                    propertyEventId.add(taskObj.Property_Event__c);
                }
            }
            if(propertyEventId != null){
                EventLst = new List<Property_Events__c>([SELECT Id, Name, Video__c, Voice__c, XH__c, HSI__c FROM Property_Events__c WHERE ID IN: propertyEventId]);
            }
            if(!knockList.isEmpty()){
                for(Task taskObj: knockList){
                    Integer voiceCount = 0;
                    Integer videoCount = 0;
                    Integer xhCount = 0;
                    Integer hsiCount = 0;
                    
                    if((trigger.isInsert && taskObj.Property_Event__c!=null) || (trigger.isUpdate && oldTriggerMap.get(taskObj.Id).Property_Event__c==null && taskObj.Property_Event__c!=null)){
                        if(taskObj.Voice_Sold__c){
                            if(voiceCountMap != null && !voiceCountMap.isEmpty() && voiceCountMap.containsKey(taskObj.Property_Event__c)){
                                voiceCount = voiceCountMap.get(taskObj.Property_Event__c);
                            }
                                voiceCount++;
                                voiceCountMap.put(taskObj.Property_Event__c,voiceCount);
                        }
                        if(taskObj.Video_Sold__c){
                            if(videoCountMap != null && !videoCountMap.isEmpty() && videoCountMap.containsKey(taskObj.Property_Event__c)){
                                videoCount = videoCountMap.get(taskObj.Property_Event__c);
                            }
                                videoCount++;
                                videoCountMap.put(taskObj.Property_Event__c,videoCount);
                        }
                        if(taskObj.XH_Sold__c){
                            if(xhCountMap != null && !xhCountMap.isEmpty() && xhCountMap.containsKey(taskObj.Property_Event__c)){
                                xhCount = xhCountMap.get(taskObj.Property_Event__c);
                            }
                                xhCount++;
                                xhCountMap.put(taskObj.Property_Event__c,xhCount);
                        }
                        if(taskObj.HSI_Sold__c){
                            if(hsiCountMap!=null && !hsiCountMap.isEmpty() && hsiCountMap.containsKey(taskObj.Property_Event__c)){
                                hsiCount = hsiCountMap.get(taskObj.Property_Event__c);
                            }
                                hsiCount++;
                                hsiCountMap.put(taskObj.Property_Event__c,hsiCount);
                        }
                    }   
                }
                
                for(Property_Events__c eventObj: EventLst){
                    if(voiceCountMap != null && !voiceCountMap.isEmpty() && voiceCountMap.get(eventObj.Id) != null){
                        if(eventObj.Voice__c == null){
                            eventObj.Voice__c = 0;
                        }
                        eventObj.Voice__c = eventObj.Voice__c + voiceCountMap.get(eventObj.Id);
                    }
                    if(videoCountMap != null && !videoCountMap.isEmpty() && videoCountMap.get(eventObj.Id) != null){
                        if(eventObj.Video__c == null){
                            eventObj.Video__c = 0;
                        }
                        eventObj.Video__c = eventObj.Video__c + videoCountMap.get(eventObj.Id);
                    }
                    if(xhCountMap != null && !xhCountMap.isEmpty() && xhCountMap.get(eventObj.Id) != null){
                        if(eventObj.XH__c == null){
                            eventObj.XH__c = 0;
                        }
                        eventObj.XH__c = eventObj.XH__c + xhCountMap.get(eventObj.Id);
                    }
                    if(hsiCountMap != null && !hsiCountMap.isEmpty() && hsiCountMap.get(eventObj.Id) != null){
                        if(eventObj.HSI__c == null){
                            eventObj.HSI__c = 0;
                        }
                        eventObj.HSI__c = eventObj.HSI__c + hsiCountMap.get(eventObj.Id);
                    }
                    propertEventList.add(eventObj);
                }
                if(!propertEventList.isEmpty()){
                    Database.update(propertEventList,false);
                }
            }
        }catch(exception ex){
            system.debug('***Following exception has occured***'+ex.getMessage());
        }
    }

    /**
    * @Description: Remove Voice, Video, XH, HSI from Property Event when property event is removed from Start Knock
    * @Author: Animesh Datta, Accenture
    * @Date: 30-Jan-2017
    * @Param: Trigger.New, Trigger.OldMap
    * @Return: void.
    **/
    public static void updatePropertyEventWhenNoEventAdded(List<Task> newTaskList,Map<Id,Task> oldTriggerMap) {
        List<Property_Events__c> propertEventList = new List<Property_Events__c>();
        List<Property_Events__c> EventLst;
        List<Task> knockList = new List<Task>();
        Set<Id> propertyEventId = new Set<Id>();
        Map<String,Integer> voiceCountMap = new Map<String,Integer>();
        Map<String,Integer> videoCountMap = new Map<String,Integer>();
        Map<String,Integer> xhCountMap = new Map<String,Integer>();
        Map<String,Integer> hsiCountMap = new Map<String,Integer>();
        try{
            
            for(Task taskObj: newTaskList){
                Task oldKnock = (Task)oldTriggerMap.get(taskObj.Id);
                if(taskObj.RecordTypeId==KNOCK_RECORDTYPE && taskObj.Property_Event__c==null && taskObj.Disposition__c == KNOCK_TYPE_START && oldTriggerMap.get(taskObj.Id).Property_Event__c!=null){
                    knockList.add(taskObj);
                    propertyEventId.add(oldKnock.Property_Event__c);
                }
            }
            if(propertyEventId != null){
                EventLst = new List<Property_Events__c>([SELECT Id, Name, Video__c, Voice__c, XH__c, HSI__c FROM Property_Events__c WHERE ID IN: propertyEventId]);
            }
            if(!knockList.isEmpty()){
                for(Task taskObj: knockList){
                    Integer voiceCount = 0;
                    Integer videoCount = 0;
                    Integer xhCount = 0;
                    Integer hsiCount = 0;
                    Task oldKnock = (Task)oldTriggerMap.get(taskObj.Id);
                    if(oldKnock.Voice_Sold__c){
                        if(voiceCountMap != null && !voiceCountMap.isEmpty() && voiceCountMap.containsKey(oldKnock.Property_Event__c)){
                            voiceCount = voiceCountMap.get(oldKnock.Property_Event__c);
                        }
                            voiceCount--;
                            voiceCountMap.put(oldKnock.Property_Event__c,voiceCount);
                    }
                    
                    if(oldKnock.Video_Sold__c){
                        if(videoCountMap != null && !videoCountMap.isEmpty() && videoCountMap.containsKey(oldKnock.Property_Event__c)){
                            videoCount = videoCountMap.get(oldKnock.Property_Event__c);
                        }
                            videoCount--;
                            videoCountMap.put(oldKnock.Property_Event__c,videoCount);
                    }
                    if(oldKnock.XH_Sold__c){
                        if(xhCountMap != null && !xhCountMap.isEmpty() && xhCountMap.containsKey(oldKnock.Property_Event__c)){
                            xhCount = xhCountMap.get(oldKnock.Property_Event__c);
                        }
                            xhCount--;
                            xhCountMap.put(oldKnock.Property_Event__c,xhCount);
                    }
                    if(oldKnock.HSI_Sold__c){
                        if(hsiCountMap!=null && !hsiCountMap.isEmpty() && hsiCountMap.containsKey(oldKnock.Property_Event__c)){
                            hsiCount = hsiCountMap.get(oldKnock.Property_Event__c);
                        }
                            hsiCount--;
                            hsiCountMap.put(oldKnock.Property_Event__c,hsiCount);
                    }
                }
                
                for(Property_Events__c eventObj: EventLst){
                    if(voiceCountMap != null && !voiceCountMap.isEmpty() && voiceCountMap.get(eventObj.Id) != null){
                        if(eventObj.Voice__c == null){
                            eventObj.Voice__c = 0;
                        }
                        eventObj.Voice__c = eventObj.Voice__c + voiceCountMap.get(eventObj.Id);
                    }
                    if(videoCountMap != null && !videoCountMap.isEmpty() && videoCountMap.get(eventObj.Id) != null){
                        if(eventObj.Video__c == null){
                            eventObj.Video__c = 0;
                        }
                        eventObj.Video__c = eventObj.Video__c + videoCountMap.get(eventObj.Id);
                    }
                    if(xhCountMap != null && !xhCountMap.isEmpty() && xhCountMap.get(eventObj.Id) != null){
                        if(eventObj.XH__c == null){
                            eventObj.XH__c = 0;
                        }
                        eventObj.XH__c = eventObj.XH__c + xhCountMap.get(eventObj.Id);
                    }
                    if(hsiCountMap != null && !hsiCountMap.isEmpty() && hsiCountMap.get(eventObj.Id) != null){
                        if(eventObj.HSI__c == null){
                            eventObj.HSI__c = 0;
                        }
                        eventObj.HSI__c = eventObj.HSI__c + hsiCountMap.get(eventObj.Id);
                    }
                    propertEventList.add(eventObj);
                }
                if(!propertEventList.isEmpty()){
                    Database.update(propertEventList,false);
                }
            }
        }catch(exception ex){
            system.debug('***Following exception has occured***'+ex.getMessage());
        }
    }

    /**
    * @Description: Roll up Voice, Video, XH, HSI to Property Event when Start Knock is updated with a differenet property event or Video, Voice, XH, HSI is modified with same property event
    * @Author: Animesh Datta, Accenture
    * @Date: 30-Jan-2017
    * @Param: Trigger.New, Trigger.OldMap
    * @Return: void.
    **/
    public static void updatePropertyEventOnKnockChange(List<Task> newTaskList,Map<Id,Task> oldTriggerMap) {
        List<Property_Events__c> propertEventList = new List<Property_Events__c>();
        List<Property_Events__c> updateOldPropertEventList = new List<Property_Events__c>();
        List<Property_Events__c> newEventLst;
        List<Property_Events__c> oldEventList;
        List<Task> knockList = new List<Task>();
        Set<Id> newPropertyEventId = new Set<Id>();
        Set<Id> oldPropertyEventId = new Set<Id>();
        Map<String,Integer> voiceCountMap = new Map<String,Integer>();
        Map<String,Integer> videoCountMap = new Map<String,Integer>();
        Map<String,Integer> xhCountMap = new Map<String,Integer>();
        Map<String,Integer> hsiCountMap = new Map<String,Integer>();
        Map<String,Integer> oldvoiceCountMap = new Map<String,Integer>();
        Map<String,Integer> oldvideoCountMap = new Map<String,Integer>();
        Map<String,Integer> oldxhCountMap = new Map<String,Integer>();
        Map<String,Integer> oldhsiCountMap = new Map<String,Integer>();
        
        try{
            
            for(Task taskObj: newTaskList){
                if(taskObj.RecordTypeId==KNOCK_RECORDTYPE && taskObj.Property_Event__c!=null && taskObj.Disposition__c == KNOCK_TYPE_START){
                    knockList.add(taskObj);
                    Task oldKnock = (Task)Trigger.oldMap.get(taskObj.Id);
                    newPropertyEventId.add(taskObj.Property_Event__c);
                    if(oldKnock.Property_Event__c!=null && taskObj.Property_Event__c!=null && oldKnock.Property_Event__c != taskObj.Property_Event__c){
                        oldPropertyEventId.add(oldKnock.Property_Event__c);
                    }
                }
            }
            if(newPropertyEventId != null){
                newEventLst = new List<Property_Events__c>([SELECT Id, Name, Video__c, Voice__c, XH__c, HSI__c FROM Property_Events__c WHERE ID IN: newPropertyEventId]);
            }
            if(oldPropertyEventId != null){
                oldEventList = new List<Property_Events__c>([SELECT Id, Name, Video__c, Voice__c, XH__c, HSI__c FROM Property_Events__c WHERE ID IN: oldPropertyEventId]);
            }
            if(!knockList.isEmpty()){
                for(Task taskObj: knockList){
                    if(taskObj.RecordTypeId==KNOCK_RECORDTYPE){
                        Task oldKnock = (Task)oldTriggerMap.get(taskObj.Id);
                        Integer voiceCount = 0;
                        Integer videoCount = 0;
                        Integer xhCount = 0;
                        Integer hsiCount = 0;
                        Integer oldvoiceCount = 0;
                        Integer oldvideoCount = 0;
                        Integer oldxhCount = 0;
                        Integer oldhsiCount = 0;
                        
                        if(oldKnock.Property_Event__c!=null && taskObj.Property_Event__c!=null){
                            if(oldKnock.Property_Event__c == taskObj.Property_Event__c){
                                if(oldKnock.Voice_Sold__c != taskObj.Voice_Sold__c){
                                    if(!oldKnock.Voice_Sold__c){
                                        if(voiceCountMap != null && !voiceCountMap.isEmpty() && voiceCountMap.containsKey(taskObj.Property_Event__c)){
                                            voiceCount = voiceCountMap.get(taskObj.Property_Event__c);
                                        }
                                        voiceCount++;
                                        voiceCountMap.put(taskObj.Property_Event__c,voiceCount);
                                    }
                                    if(oldKnock.Voice_Sold__c){
                                        if(voiceCountMap != null && !voiceCountMap.isEmpty() && voiceCountMap.containsKey(taskObj.Property_Event__c)){
                                            voiceCount = voiceCountMap.get(taskObj.Property_Event__c);
                                        }
                                        voiceCount--;
                                        voiceCountMap.put(taskObj.Property_Event__c,voiceCount);
                                    }
                                }
                            }
                            else if(oldKnock.Property_Event__c != taskObj.Property_Event__c){
                                if(oldKnock.Voice_Sold__c){
                                    if(oldvoiceCountMap != null && !oldvoiceCountMap.isEmpty() && oldvoiceCountMap.containsKey(oldKnock.Property_Event__c)){
                                        oldvoiceCount = oldvoiceCountMap.get(oldKnock.Property_Event__c);
                                    }
                                        oldvoiceCount--;
                                        oldvoiceCountMap.put(oldKnock.Property_Event__c,oldvoiceCount);
                                }
                                if(taskObj.Voice_Sold__c){
                                    if(voiceCountMap != null && !voiceCountMap.isEmpty() && voiceCountMap.containsKey(taskObj.Property_Event__c)){
                                        voiceCount = voiceCountMap.get(taskObj.Property_Event__c);
                                    }
                                        voiceCount++;
                                        voiceCountMap.put(taskObj.Property_Event__c,voiceCount);
                                }
                            }
                            
                            if(oldKnock.Property_Event__c == taskObj.Property_Event__c){
                                if(oldKnock.Video_Sold__c != taskObj.Video_Sold__c){
                                    if(!oldKnock.Video_Sold__c){
                                        if(videoCountMap != null && !videoCountMap.isEmpty() && videoCountMap.containsKey(taskObj.Property_Event__c)){
                                            videoCount = videoCountMap.get(taskObj.Property_Event__c);
                                        }
                                        videoCount++;
                                        videoCountMap.put(taskObj.Property_Event__c,videoCount);
                                    }
                                    if(oldKnock.Video_Sold__c){
                                        if(videoCountMap != null && !videoCountMap.isEmpty() && videoCountMap.containsKey(taskObj.Property_Event__c)){
                                            videoCount = videoCountMap.get(taskObj.Property_Event__c);
                                        }
                                        videoCount--;
                                        videoCountMap.put(taskObj.Property_Event__c,videoCount);
                                    }
                                }
                            }
                            else if(oldKnock.Property_Event__c != taskObj.Property_Event__c){
                                if(oldKnock.Video_Sold__c){
                                    if(oldvideoCountMap != null && !oldvideoCountMap.isEmpty() && oldvideoCountMap.containsKey(oldKnock.Property_Event__c)){
                                        oldvideoCount = oldvideoCountMap.get(oldKnock.Property_Event__c);
                                    }
                                        oldvideoCount--;
                                        oldvideoCountMap.put(oldKnock.Property_Event__c,oldvideoCount);
                                }
                                if(taskObj.Video_Sold__c){
                                    if(videoCountMap != null && !videoCountMap.isEmpty() && videoCountMap.containsKey(taskObj.Property_Event__c)){
                                        videoCount = videoCountMap.get(taskObj.Property_Event__c);
                                    }
                                        videoCount++;
                                        videoCountMap.put(taskObj.Property_Event__c,videoCount);
                                }
                            }
                            
                            if(oldKnock.Property_Event__c == taskObj.Property_Event__c){
                                if(oldKnock.XH_Sold__c != taskObj.XH_Sold__c){
                                    if(!oldKnock.XH_Sold__c){
                                        if(xhCountMap != null && !xhCountMap.isEmpty() && xhCountMap.containsKey(taskObj.Property_Event__c)){
                                            xhCount = xhCountMap.get(taskObj.Property_Event__c);
                                        }
                                        xhCount++;
                                        xhCountMap.put(taskObj.Property_Event__c,xhCount);
                                    }
                                    if(oldKnock.XH_Sold__c){
                                        if(xhCountMap != null && !xhCountMap.isEmpty() && xhCountMap.containsKey(taskObj.Property_Event__c)){
                                            xhCount = xhCountMap.get(taskObj.Property_Event__c);
                                        }
                                        xhCount--;
                                        xhCountMap.put(taskObj.Property_Event__c,xhCount);
                                    }
                                }
                            }
                            else if(oldKnock.Property_Event__c != taskObj.Property_Event__c){
                                if(oldKnock.XH_Sold__c){
                                    if(oldxhCountMap != null && !oldxhCountMap.isEmpty() && oldxhCountMap.containsKey(oldKnock.Property_Event__c)){
                                        oldxhCount = oldxhCountMap.get(oldKnock.Property_Event__c);
                                    }
                                        oldxhCount--;
                                        oldxhCountMap.put(oldKnock.Property_Event__c,oldxhCount);
                                }
                                if(taskObj.XH_Sold__c){
                                    if(xhCountMap != null && !xhCountMap.isEmpty() && xhCountMap.containsKey(taskObj.Property_Event__c)){
                                        xhCount = xhCountMap.get(taskObj.Property_Event__c);
                                    }
                                        xhCount++;
                                        xhCountMap.put(taskObj.Property_Event__c,xhCount);
                                }
                            }
                            
                            if(oldKnock.Property_Event__c == taskObj.Property_Event__c){
                                if(oldKnock.HSI_Sold__c != taskObj.HSI_Sold__c){
                                    if(!oldKnock.HSI_Sold__c){
                                        if(hsiCountMap != null && !hsiCountMap.isEmpty() && hsiCountMap.containsKey(taskObj.Property_Event__c)){
                                            hsiCount = hsiCountMap.get(taskObj.Property_Event__c);
                                        }
                                        hsiCount++;
                                        hsiCountMap.put(taskObj.Property_Event__c,hsiCount);
                                    }
                                    if(oldKnock.HSI_Sold__c){
                                        if(hsiCountMap != null && !hsiCountMap.isEmpty() && hsiCountMap.containsKey(taskObj.Property_Event__c)){
                                            hsiCount = hsiCountMap.get(taskObj.Property_Event__c);
                                        }
                                        hsiCount--;
                                        hsiCountMap.put(taskObj.Property_Event__c,hsiCount);
                                    }
                                }
                            }
                            else if(oldKnock.Property_Event__c != taskObj.Property_Event__c){
                                if(oldKnock.HSI_Sold__c){
                                    if(oldhsiCountMap != null && !oldhsiCountMap.isEmpty() && oldhsiCountMap.containsKey(oldKnock.Property_Event__c)){
                                        oldhsiCount = oldhsiCountMap.get(oldKnock.Property_Event__c);
                                    }
                                        oldhsiCount--;
                                        oldhsiCountMap.put(oldKnock.Property_Event__c,oldhsiCount);
                                }
                                if(taskObj.HSI_Sold__c){
                                    if(hsiCountMap != null && !hsiCountMap.isEmpty() && hsiCountMap.containsKey(taskObj.Property_Event__c)){
                                        hsiCount = hsiCountMap.get(taskObj.Property_Event__c);
                                    }
                                        hsiCount++;
                                        hsiCountMap.put(taskObj.Property_Event__c,hsiCount);
                                }
                            }
                        }
                    }
                }
                
                for(Property_Events__c eventObj: newEventLst){
                    if(voiceCountMap != null && !voiceCountMap.isEmpty() && voiceCountMap.get(eventObj.Id) != null){
                        if(eventObj.Voice__c == null){
                            eventObj.Voice__c = 0;
                        }
                        eventObj.Voice__c = eventObj.Voice__c + voiceCountMap.get(eventObj.Id);
                    }
                    if(videoCountMap != null && !videoCountMap.isEmpty() && videoCountMap.get(eventObj.Id) != null){
                        if(eventObj.Video__c == null){
                            eventObj.Video__c = 0;
                        }
                        eventObj.Video__c = eventObj.Video__c + videoCountMap.get(eventObj.Id);
                    }
                    if(xhCountMap != null && !xhCountMap.isEmpty() && xhCountMap.get(eventObj.Id) != null){
                        if(eventObj.XH__c == null){
                            eventObj.XH__c = 0;
                        }
                        eventObj.XH__c = eventObj.XH__c + xhCountMap.get(eventObj.Id);
                    }
                    if(hsiCountMap != null && !hsiCountMap.isEmpty() && hsiCountMap.get(eventObj.Id) != null){
                        if(eventObj.HSI__c == null){
                            eventObj.HSI__c = 0;
                        }
                        eventObj.HSI__c = eventObj.HSI__c + hsiCountMap.get(eventObj.Id);
                    }
                    propertEventList.add(eventObj);
                }
                
                if(!propertEventList.isEmpty()){
                    Database.update(propertEventList,false);
                }
                
                for(Property_Events__c oldEventObj: oldEventList){
                    if(oldvoiceCountMap != null && !oldvoiceCountMap.isEmpty() && oldvoiceCountMap.get(oldEventObj.Id) != null){
                        if(oldEventObj.Voice__c == null){
                            oldEventObj.Voice__c = 0;
                        }
                        oldEventObj.Voice__c = oldEventObj.Voice__c + oldvoiceCountMap.get(oldEventObj.Id);
                    }
                    if(oldvideoCountMap != null && !oldvideoCountMap.isEmpty() && oldvideoCountMap.get(oldEventObj.Id) != null){
                        if(oldEventObj.Video__c == null){
                            oldEventObj.Video__c = 0;
                        }
                        oldEventObj.Video__c = oldEventObj.Video__c + oldvideoCountMap.get(oldEventObj.Id);
                    }
                    if(oldxhCountMap != null && !oldxhCountMap.isEmpty() && oldxhCountMap.get(oldEventObj.Id) != null){
                        if(oldEventObj.XH__c == null){
                            oldEventObj.XH__c = 0;
                        }
                        oldEventObj.XH__c = oldEventObj.XH__c + oldxhCountMap.get(oldEventObj.Id);
                    }
                    if(oldhsiCountMap != null && !oldhsiCountMap.isEmpty() && oldhsiCountMap.get(oldEventObj.Id) != null){
                        if(oldEventObj.HSI__c == null){
                            oldEventObj.HSI__c = 0;
                        }
                        oldEventObj.HSI__c = oldEventObj.HSI__c + oldhsiCountMap.get(oldEventObj.Id);
                    }
                    updateOldPropertEventList.add(oldEventObj);
                }
                
                if(!updateOldPropertEventList.isEmpty()){
                    Database.update(updateOldPropertEventList,false);
                }
            }
        }catch(exception ex){
            system.debug('***Following exception has occured***'+ex.getMessage());
        }  
    }
}