/**
* Class Name: PlanTriggerController 
* Author: Amitkumar Bangad, Accenture
* Date: 18-March-2013 
* Requirement # Request Id: 
* Description: Contains supporting Actions for Plan Triggers
* Last Modified :
*/
public class PlanTriggerController {
    
    /**
    * @Description: This method restricts a plan from deletion.
    * @Author: Vivek Patel, Accenture
    * @Date: 25-April-2013
    * @Param: None
    * @Return: void.
    */
    /*public static void restrictDelete() {
        List<Plan__c> plans = Trigger.old;
        Profile usrProfile = [Select Id, Name from Profile where Id =:UserInfo.getProfileId()];
        //system.debug(usrProfile.Name);
        for(Plan__c plan : plans) {
            //system.debug(plan.Plan_Status__c);
           // system.debug(plan.Plan_Level__c);
            if(usrProfile.Name != Label.SystemAdminProfileName && usrProfile.Name != Label.RSA_Profile_Name && usrProfile.Name != Label.DS_Supervisor && usrProfile.Name != Label.DS_Manager){
                if(plan.Plan_Status__c != Label.PlanStatusDraft && plan.Plan_Level__c != Label.PlanTypePlaylist) {
                    plan.addError(Label.PlanDeleteError);
                    break;
                }
                if(plan.Plan_Status__c == Label.PlanStatusAssigned && plan.Plan_Level__c != Label.PlanTypePlaylist) {
                    plan.addError(Label.AssignedPlanDeleteError);
                    break;
                }
                if(plan.Plan_Status__c == Label.PlanStatusDraft && plan.Plan_Level__c == Label.PlanTypeTurf) {
                    plan.addError(Label.DraftTurfPlanDeleteError);
                    break;
                }
            }
        }
    }*/

    /**
    * @Description: This method updates the associated playlists when a plan's expiration date has changed
    * @Author: Comcast Resi
    * @Date: 24-Sept-2015
    */
    
    public static void updateAssociatedPlaylists(List<Plan__c> newPlansList,Map<Id, Plan__c> oldPlansMap) {
        //system.debug('newPlansList**********'+newPlansList);
        //system.debug('oldPlansMap**********'+oldPlansMap);
        Map<Id,Plan__c> planWExpirationDate=new Map<Id,Plan__c>();
        Map<Id,Plan__c> planWExpirationDateBulk=new Map<Id,Plan__c>();
        //system.debug('in the method');
        for (Plan__c pl : newPlansList){
            if(pl.Plan_Level__c!= 'Bulk'){              
                if(pl.Expiration_Date__c != null && pl.Expiration_Date__c !=  oldPlansMap.get(pl.Id).Expiration_Date__c){
                    planWExpirationDate.put(pl.Id,pl);
                    //system.debug('planWExpirationDate>>>'+planWExpirationDate);
                }               
                //method1(newPlansList,oldPlansMap);
            } else{                             
            if(pl.Expiration_Date__c != null && pl.Expiration_Date__c !=  oldPlansMap.get(pl.Id).Expiration_Date__c){
                    planWExpirationDateBulk.put(pl.Id,pl);
                    //system.debug('planWExpirationDateBulk>>>'+planWExpirationDateBulk);
                }
                //method2(newPlansList,oldPlansMap);
            }           
        }       
        if(!planWExpirationDate.isEmpty()){
            updateExpirationDate(newPlansList,oldPlansMap,planWExpirationDate);
        }
        if(!planWExpirationDateBulk.isEmpty()){
            updateExpirationDateForBulk(newPlansList,oldPlansMap,planWExpirationDateBulk);
        }       
    }
    
    
    
    public static void updateExpirationDate(List<Plan__c> newPlansList,Map<Id, Plan__c> oldPlansMap, Map<Id,Plan__c> planWExpirationDate){
        if(!planWExpirationDate.isEmpty()){
            List<Plan__c> playlistsChangeExpirationDate=[Select Id, Parent_Plan__c, Expiration_Date__c From Plan__c Where Parent_Plan__c IN: planWExpirationDate.keySet() AND Plan_Status__c !='Expired'];
            for(Plan__c playList:playlistsChangeExpirationDate){
                //system.debug('hhhh'+planWExpirationDate.get(playlist.Parent_Plan__c).Expiration_Date__c);
                playlist.Expiration_Date__c=planWExpirationDate.get(playlist.Parent_Plan__c).Expiration_Date__c;
            }   
            if(!playlistsChangeExpirationDate.isEmpty()){
                //system.debug('inside final ifffff');
                Database.SaveResult[] saveResult;
                try {           
                    saveResult = Database.update(playlistsChangeExpirationDate, false);
                } 
                catch(Exception ex) {         
                    System.debug('Following exception occurred while updating Playlist Expiration Date :'+ex);
                } 
            }
        }
    }
    
    
    
    public static void updateExpirationDateForBulk(List<Plan__c> newPlansList,Map<Id, Plan__c> oldPlansMap, Map<Id,Plan__c> planWExpirationDateBulk){    
        if(!planWExpirationDateBulk.isEmpty()){
            List<Plan__c> playlistsChangeExpirationDate=[Select Id, Parent_Plan__c, Expiration_Date__c From Plan__c Where Parent_Plan__c IN: planWExpirationDateBulk.keySet() AND Plan_Status__c !='Expired'];
            for(Plan__c playList:playlistsChangeExpirationDate){
                //system.debug('playlist.Expiration_Date__c*****'+playlist.Expiration_Date__c);
                //system.debug('hhhh'+planWExpirationDateBulk.get(playlist.Parent_Plan__c).Expiration_Date__c);
                if(playlist.Expiration_Date__c>planWExpirationDateBulk.get(playlist.Parent_Plan__c).Expiration_Date__c){
                    playlist.Expiration_Date__c=planWExpirationDateBulk.get(playlist.Parent_Plan__c).Expiration_Date__c;
                }
            }
            if(!playlistsChangeExpirationDate.isEmpty()){
                //system.debug('inside final ifffff');
                Database.SaveResult[] saveResult;
                try {           
                    saveResult = Database.update(playlistsChangeExpirationDate, false);
                } 
                catch(Exception ex) {         
                    System.debug('Following exception occurred while updating Playlist Expiration Date :'+ex);
                } 
            }
        }        
    }
    
    
    /**
    * @Description: This method deletes the associated playlists when a plan is deleted and updates all addresses to Shared Data User.
    * @Author: Erin McGee, Acumen Solutions
    * @Date: 06-August-2014
    * @Param: None
    * @Return: void.
    */
   public static void deleteAssociatedPlaylists(List<Plan__c> plans) {
        //system.debug('inside deleteAssociatedPlaylists method');
        Set<Id> planIds= new Set<Id>();
        Set<Id> turfPlanIdSet= new Set<Id>();
        Map<Id,Plan__c> IdTurfPlanMap = new Map<Id,Plan__c>();
        Map<Id,Plan__c> IdPlayListPlanMap = new Map<Id,Plan__c>();
        //Turfs Being Deleted
        //Bulk Plan cann't be deleted
        for(Plan__c plan : plans) {
            if(plan.Plan_Level__c == Label.PlanTypeBulk){
                plan.addError(Label.ErrMsgOnBulkPlanDeletion);
            }
        
            if(plan.Plan_Level__c=='Turf'){
                turfPlanIdSet.add(plan.Id);                                 
            }
        }
        //system.debug('turfPlanIdSet***'+turfPlanIdSet);   
        for(Plan__c plan : [Select Id,Parent_Plan__r.Plan_Level__c,OwnerId,User__c,Parent_Plan__r.User__c,Parent_Plan__r.Parent_Plan__r.Plan_Level__c From Plan__c WHERE Id IN: turfPlanIdSet]){
            if(plan.Parent_Plan__r.Plan_Level__c == Label.PlanTypeBulk){
                //system.debug('Is ParentPlanBulk ???');
                IdTurfPlanMap.put(plan.id,plan);
            }else{
                planIds.add(plan.Id);
            }                   
        }
            
        //system.debug('IdTurfPlanMap***'+IdTurfPlanMap);
        if(!planIds.isEmpty() || !IdTurfPlanMap.isEmpty()){
            List<Plan__c> playlistPlans=[Select Id,OwnerId,User__c,Parent_Plan__r.User__c, Parent_Plan__r.Plan_Level__c,Parent_Plan__r.Parent_Plan__r.Plan_Level__c From Plan__c Where (Parent_Plan__c IN:planIds OR Parent_Plan__c IN:IdTurfPlanMap.KeySet())];
            for(Plan__c plan: playlistPlans){
                if(plan.Parent_Plan__r.Parent_Plan__r.Plan_Level__c == Label.PlanTypeBulk){
                    //system.debug('inside If');
                    IdPlayListPlanMap.put(plan.id,plan);
                }else{
                    //system.debug('inside else');
                    planIds.add(plan.Id);
                }
            }
            
            If(!planIds.isEmpty() || !IdTurfPlanMap.isEmpty() || !IdPlayListPlanMap.isEmpty() ){
                //system.debug('IdPlayListPlanMap***'+IdPlayListPlanMap);
                //system.debug('planIds***'+planIds);
                List<Customer_Address__c> planAddresses=[Select Id, OwnerId, Plan__c,Plan__r.OwnerId,Plan__r.User__c,Plan__r.Parent_Plan__c,Plan__r.Parent_Plan__r.User__c, Team__c, Off_Turf__c, Excluded__c, Number_of_Knocks__c, Most_Recent_Disposition__c From Customer_Address__c Where (Plan__c IN: planIds OR Plan__c IN: IdTurfPlanMap.Keyset() OR Plan__c IN: IdPlayListPlanMap.Keyset())];
                List<Customer_Address__c> addressList=new List<Customer_Address__c>();
                User sharedData = [Select Id, Name from User where Name='Shared Data User'];
                for(Customer_Address__c add:planAddresses){
                    //system.debug('CurrentPlan****'+add.Plan__c);
                    add.Team__c = null;
                    add.CAR_Owner__c = null;
                    add.Off_Turf__c = false;
                    add.Excluded__c = false;
                    
                    add.Number_of_Knocks__c = 0;   
                    add.Most_Recent_Disposition__c = Label.DispositionTypeNoKnock; 
                    if(IdTurfPlanMap.containsKey(add.Plan__c)){                      
                        add.OwnerId = IdTurfPlanMap.get(add.Plan__c).Parent_Plan__r.User__c;
                        add.Plan__c = IdTurfPlanMap.get(add.Plan__c).Parent_Plan__c; 
                    }else if(IdPlayListPlanMap.containsKey(add.Plan__c)){                        
                        add.OwnerId = IdTurfPlanMap.get(add.Plan__r.Parent_Plan__c).Parent_Plan__r.User__c;
                        add.Plan__c = IdTurfPlanMap.get(add.Plan__r.Parent_Plan__c).Parent_Plan__c; 
                        
                    }else{
                       // system.debug('in the else block');
                        add.OwnerId = sharedData.Id;
                        add.Plan__c = null;
                    }
                    addressList.add(add);  
                }
                //system.debug('addressList>>>>>'+addressList);

                if(!addressList.isEmpty()){
                    
                    update addressList;
                   
                }
                if(!playlistPlans.isEmpty()){
                    //system.debug('playlistPlans:::::'+playlistPlans);
                    delete playlistPlans;
                }
            }   
                
       }
    }
            
    
    /**
    * @Description: This method validates plan assignment.
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 14-May-2013
    * @Param: Trigger.NewMap, Trigger.OldMap
    * @Return: void.
    */
    public static void validateAssignment (List<Plan__c> newPlansList,Map<Id, Plan__c> oldPlansMap) {
        //system.debug('******newPlansList**********'+newPlansList);
        //system.debug('*******oldPlansMap**********'+oldPlansMap);
        set<Id> userIds = new set<Id>();
        set<Id> teamIds = new set<Id>();
        Map<Id,User> userNames=new Map<Id,User>();
        //system.debug(newPlansList);
       // system.debug(oldPlansMap);
        Map<Id,Integer> userIdsbyPlanCount = new Map<Id,Integer>();         
        for (Plan__c pl : newPlansList){
            //system.debug('*******pl.Plan_Level__c**********'+pl.Plan_Level__c);
           // system.debug('*******pl.User__c**********'+pl.User__c);
            if(pl.Plan_Level__c == Label.PlanTypeTurf){
                if(pl.User__c != null && pl.User__c !=  oldPlansMap.get(pl.Id).User__c){
                    userIds.add(pl.User__c);    
                }
                if(pl.Assigned_Team__c!=null && pl.Assigned_Team__c!=oldPlansMap.get(pl.Id).Assigned_Team__c){
                    teamIds.add(pl.Assigned_Team__c);
                }
            }
        }
        //system.debug(userIds);
        //system.debug(teamIds);
        if(!userIds.IsEmpty() || !teamIds.IsEmpty()){
        Map<Id,List<User>> teamUsers=new Map<Id,List<User>>();
        for(Team_Member__c tm:[Select User_Name__c, User_Name__r.Sales_Rep_Type__c, User_Name__r.Name, Team__c From Team_Member__c Where (Team__c IN:teamIds OR User_Name__c IN:userIds)]){
            if(teamUsers.containsKey(tm.Team__c)){
                 List<User> users=teamUsers.get(tm.Team__c);
                 users.add(tm.User_Name__r);
                 teamUsers.put(tm.Team__c,users);
             }else{
                List<User> users=new List<User>();
                 users.add(tm.User_Name__r);
                 teamUsers.put(tm.Team__c,users);
             }
            
            userIds.add(tm.User_Name__c);
        }
        //system.debug(teamUsers);
        if(!userIds.IsEmpty()){
            userNames=new Map<Id,User>([Select Id, Name From User Where Id IN:userIds]);
            Profile p = [Select Id, Name from Profile where Name =:Label.DSRProfileName];
                if(!teamUsers.isEmpty())
                {
                for (Plan__c pl : [Select Id, User__c, User__r.ProfileId, User__r.Sales_Rep_Type__c, Plan_Status__c from Plan__c where User__c IN: userIds AND Plan_Status__c !=:Label.PlanStatusExpired AND Plan_Level__c =: Label.PlanTypeTurf]){
                    system.debug('*******pl**********'+pl);
                        if(pl.User__r.ProfileId == p.Id && pl.User__r.Sales_Rep_Type__c != 'Multiple Dwelling Unit (MDU)' && pl.User__r.Sales_Rep_Type__c != 'Xfinity Home')
                        {
                            system.debug('*****pl.User__r.ProfileId*****'+ pl.User__r.ProfileId);
                            if (userIdsbyPlanCount.containsKey(pl.User__c)){
                                userIdsbyPlanCount.put(pl.User__c,userIdsbyPlanCount.get(pl.User__c) +1);
                            } else {
                                userIdsbyPlanCount.put(pl.User__c,1);
                            }
                        }
                    }
                    for (Plan__c pl : [Select Id, Plan_Status__c, Assigned_Team__c from Plan__c where Assigned_Team__c IN: teamUsers.keySet() AND Plan_Status__c !=:Label.PlanStatusExpired AND Plan_Level__c =: Label.PlanTypeTurf]){
                        if(pl.Assigned_Team__c!=null){
                            List<User> usersInTeam=teamUsers.get(pl.Assigned_Team__c);
                            for(User teamUser:usersInTeam){
                                //system.debug(teamUser);
                                //system.debug(userIdsbyPlanCount);
                        if(teamUser.Sales_Rep_Type__c != 'Multiple Dwelling Unit (MDU)' && teamUser.Sales_Rep_Type__c != 'Xfinity Home'){
                            if (userIdsbyPlanCount.containsKey(teamUser.Id)){
                                userIdsbyPlanCount.put(teamUser.Id,userIdsbyPlanCount.get(teamUser.Id) +1);
                            } else {
                                userIdsbyPlanCount.put(teamUser.Id,1);
                            }

                                }
                            }
                        }
                    }
                }
                else{
                    for (Plan__c pl : [Select Id, User__c, User__r.ProfileId, User__r.Sales_Rep_Type__c, Plan_Status__c from Plan__c where User__c IN: userIds AND Plan_Status__c !=:Label.PlanStatusExpired AND Plan_Level__c =: Label.PlanTypeTurf]){
                        if(pl.User__r.ProfileId == p.Id && pl.User__r.Sales_Rep_Type__c != 'Multiple Dwelling Unit (MDU)' && pl.User__r.Sales_Rep_Type__c != 'Xfinity Home'){
                            if (userIdsbyPlanCount.containsKey(pl.User__c)){
                                userIdsbyPlanCount.put(pl.User__c,userIdsbyPlanCount.get(pl.User__c) +1);
                            } else {
                                userIdsbyPlanCount.put(pl.User__c,1);
                            }
                        }

                    }

                }

                for (Plan__c pl : newPlansList){
                    if(userIdsbyPlanCount.get(pl.User__c) > ConfigurableParameters__c.getValues('HardStopForDSR').NumberValue__c){
                            system.debug('**userIdsbyPlanCount***'+userIdsbyPlanCount);
                            pl.adderror(Label.HardStopForDSRErrorMsg1 + ' ' +Integer.valueOf(ConfigurableParameters__c.getValues('HardStopForDSR').NumberValue__c) + ' ' + Label.HardStopForDSRErrorMsg2.replace('[user]',userNames.get(pl.User__c).Name));
                            //system.debug('**userIdsbyPlanCount***'+userIdsbyPlanCount);
                            pl.User__c=null;
                            pl.Plan_Status__c='Draft';
                        }
                        if(pl.Assigned_Team__c!=null){
                            List<User> usersInTeam=teamUsers.get(pl.Assigned_Team__c);
                            for(User teamUser:usersInTeam){
                        if(userIdsbyPlanCount.get(teamUser.Id) > ConfigurableParameters__c.getValues('HardStopForDSR').NumberValue__c){                          
                            pl.adderror(Label.HardStopForDSRErrorMsg1 + ' ' +Integer.valueOf(ConfigurableParameters__c.getValues('HardStopForDSR').NumberValue__c) + ' ' + Label.HardStopForDSRErrorMsg2.replace('[user]',teamUser.Name));
                            pl.Assigned_Team__c=null;
                            pl.Plan_Status__c='Draft';
                        }
                                }
                            }
                        }

            }
        }
    }
    /**
    * @Description: This method attaches addresses to turf when a playlist is deleted and clears Plan lookup field when Plan is deleted.
    * @Author: Gaurav Aggarwal, Accenture
    * @Date: 23-Oct-2013 
    * @Param: Trigger.NewMap, Trigger.OldMap
    * @Return: void.
    */
    public static void attachAddressToTurf(List<Plan__c>plans) {
        AddressTerritoryHandler.hasExecuted = true;
        Map<Id,Plan__c> playlistByIdMap = new Map<Id,Plan__c>();
        Map<Id,Plan__c> planByIdMap = new Map<Id,Plan__c>();
        List<Customer_Address__c> playlistAddrList = new List<Customer_Address__c>();
        List<Customer_Address__c> planAddrList = new List<Customer_Address__c>();
        for(Plan__c newPlanObj : plans) {         
           if(newPlanObj.Plan_Level__c == 'Playlist'){
                playlistByIdMap.put(newPlanObj.Id,newPlanObj);
           }else if (newPlanObj.Plan_Level__c == 'Plan'){
                planByIdMap.put(newPlanObj.Id,newPlanObj);
           }
        }
        //Playlist Reassignment
        for(Customer_Address__c AddrsObj : [Select Id, Name, Plan__c from  Customer_Address__c where Plan__c IN: playlistByIdMap.keySet()]){
            AddrsObj.Plan__c = playlistByIdMap.get(AddrsObj.Plan__c).Parent_Plan__c;
            playlistAddrList.add(AddrsObj);
        }
        if(!playlistAddrList.isEmpty()){
            Database.SaveResult[] saveResult;

            List<Customer_Address__c> addressesToUpdate = new List<Customer_Address__c>();
            Integer numberUpdated = 0;
            
            for(Customer_Address__c ca : playlistAddrList){
                addressesToUpdate.add(ca);
                numberUpdated++;
                if(addressesToUpdate.size() == Integer.valueOf(Label.Address_Chunk_Size) || numberUpdated == playlistAddrList.size()){
                    try {   
                                
                        saveResult = Database.update(addressesToUpdate, false);
                        addressesToUpdate.clear();
                    } catch(Exception ex) {         
                        System.debug('Following exception occurred while updating Addresses :'+ex);
                    } 

                    for (Integer i = 0; i < saveResult.size(); i++) {
                        if (saveResult[i].isSuccess()) {
                            System.debug('Successfully updated Record ID: '+ saveResult[i].getId());
                        } else {
                            System.debug('The error reported was: '+ saveResult[i].getErrors()[0].getMessage() + '\n');
                        }
                    }                  
                }
            }
        }

        //Plan Reassignment
        for(Customer_Address__c AddrsObj : [Select Id, Name, Plan__c from  Customer_Address__c where Plan__c IN: planByIdMap.keySet()]){
            AddrsObj.Plan__c = playlistByIdMap.get(AddrsObj.Plan__c).Parent_Plan__c;
            planAddrList.add(AddrsObj);
        }
        if(!planAddrList.isEmpty()){
            Database.SaveResult[] saveResult;

            List<Customer_Address__c> addressesToUpdate = new List<Customer_Address__c>();
            for(Customer_Address__c ca : planAddrList){
                addressesToUpdate.add(ca);

                if(addressesToUpdate.size() == Integer.valueOf(Label.Address_Chunk_Size) || planAddrList.size() == addressesToUpdate.size()){
                    try {           
                        saveResult = Database.update(addressesToUpdate, false);
                        addressesToUpdate.clear();
                    } catch(Exception ex) {         
                        System.debug('Following exception occurred while updating Addresses :'+ex);
                    } 

                    for (Integer i = 0; i < saveResult.size(); i++) {
                        if (saveResult[i].isSuccess()) {
                            System.debug('Successfully updated Record ID: '+ saveResult[i].getId());
                        } else {
                            System.debug('The error reported was: '+ saveResult[i].getErrors()[0].getMessage() + '\n');
                        }
                    }                  
                }
            }
        }
    }

    public static void updateNumberOfAddressOnPlan(List<Plan__c> plans, Map<Id, Plan__c> oldPlansMap){
        Set<Id> ids = new Set<Id>();
        Set<Id> pids = new Set<Id>();
        Map<Id, Plan__c> planMap = new Map<Id,Plan__c>();
        List<Plan__c> playlists = new List<Plan__c>();
        Set<Id> playlistids = new Set<Id>();
         List<Plan__c> plansToUpdate=new List<Plan__c>();
        // User Story: US448962 , Sprint 2 Change, Date : 5/19/2015, Author : Pranjal Singh
        // added playlistToUpdate list for getting the playlist plans to be updated
        List<Plan__c> playlistToUpdate=new List<Plan__c>();
        for(Plan__c p : plans){
            if(p.Plan_Level__c != Label.PlanTypeBulk){
                if(!p.Playlist_Is_Being_Updated__c && p.Plan_Status__c != Label.PlanStatusExpired){
                    ids.add(p.Id);
                    p.Number_of_Addresses_Currently_on_Plan__c=0;
                    plansToUpdate.add(p);
                }
              // User Story: US448962 , Sprint 2 Change, Date : 5/19/2015, Author : Pranjal Singh
            //added playlists to be updated in the playlistToUpdate list and playlist ids to pids made the fields below 0 to get updated 
                else if( p.Plan_Status__c != Label.PlanStatusExpired && p.Plan_Level__c != Label.PlanTypeBulk){
                  pids.add(p.Id);
                    p.Number_of_Addresses_Currently_on_Plan__c=0;
                    p.True_count_of_Addresses__c=0;
                    p.Number_of_Addresses__c=0;
                    playlistToUpdate.add(p);
                }
                
                planMap.put(p.Id, p);
            } 
        }
        // User Story: US448962 , Sprint 2 Change, Date : 5/19/2015, Author : Pranjal Singh
        //updates the number of addresses in the playlist and in the parent turf
        if(!playlistToUpdate.isEmpty()){
              List<Customer_Address__c> paddresses = [Select Id, Plan__c From Customer_Address__c Where Plan__c IN: pids];
              List<Plan__c> parentPlansToUpdate = new List<Plan__c>();
            if(paddresses != null && !paddresses.isEmpty()){
                for(Customer_Address__c pa : paddresses){
                    
                    Plan__c p =planMap.get(pa.Plan__c);
                    p.Number_of_Addresses_Currently_on_Plan__c += 1;
                    p.True_count_of_Addresses__c += 1;
                    p.Number_of_Addresses__c +=1;
                }
                
                for(Plan__c p : playlistToUpdate){ 
                    if(oldPlansMap.get(p.Id).Number_of_Addresses_Currently_on_Plan__c !=p.Number_of_Addresses_Currently_on_Plan__c){
                        decimal change=0;
                        
                        if(oldPlansMap.get(p.Id).Number_of_Addresses_Currently_on_Plan__c==null){
                            change=p.Number_of_Addresses_Currently_on_Plan__c;
                        } else {
                            change=p.Number_of_Addresses_Currently_on_Plan__c-oldPlansMap.get(p.Id).Number_of_Addresses_Currently_on_Plan__c;
                        }
                 
                       List<Plan__c> ParentListToUpdate= New List<Plan__c>([Select Id, Number_of_Addresses_Currently_on_Plan__c, Number_of_Addresses_on_Playlists__c, Number_of_Addresses__c, True_count_of_Addresses__c, Number_of_Excluded_Addresses__c  From Plan__c Where ID =: p.Parent_Plan__c]);
                        for(Plan__c paa : ParentListToUpdate){
                             paa.Number_of_Addresses_Currently_on_Plan__c -=change;
                             paa.Number_of_Addresses_on_Playlists__c += change;
                             paa.Number_of_Addresses__c=paa.Number_of_Addresses_Currently_on_Plan__c+ paa.Number_of_Addresses_on_Playlists__c;
                             parentPlansToUpdate.add(paa);
                        } 
                    }
                }
                
                 database.update(parentPlansToUpdate,false);
            } 
        }
        if(!plansToUpdate.isEmpty()){
            List<Customer_Address__c> addresses = [Select Id, Plan__c From Customer_Address__c Where Plan__c IN: ids];
            
            for(Customer_Address__c a : addresses){
                Plan__c p =planMap.get(a.Plan__c);
                p.Number_of_Addresses_Currently_on_Plan__c += 1;
            }
            
            for(Plan__c p : plansToUpdate){
                if(p.Number_of_Addresses_on_Playlists__c==null){
                    p.Number_of_Addresses_on_Playlists__c=0;
                }
                if(p.Number_of_Excluded_Addresses__c==null){
                    p.Number_of_Excluded_Addresses__c=0;
                }
                if(p.Number_of_Addresses__c==null){
                    p.Number_of_Addresses__c=0;
                }
                
                p.Number_of_Addresses__c = p.Number_of_Addresses_Currently_on_Plan__c + p.Number_of_Addresses_on_Playlists__c;
                p.True_count_of_Addresses__c = p.Number_of_Addresses__c - p.Number_of_Excluded_Addresses__c;
            }
        }
    }

   
    public static void movePlaylistAddressCountToParent(List<Plan__c> plans){
        Set<Id> parentIds = new Set<Id>();
        for(Plan__c p : plans){
            if(p.Plan_Level__c == 'Playlist'){
                parentIds.add(p.Parent_Plan__c);
            }
        }
        if(!parentIds.isEmpty()){
            List<Plan__c> parentPlans = [Select Id, Number_of_Addresses__c, True_count_of_Addresses__c, 
                                Number_of_Addresses_Currently_on_Plan__c, Number_of_Addresses_on_Playlists__c
                                From Plan__c Where Id IN: parentIds];
            List<Plan__c> updateCountPlans=new List<Plan__c>();
            for(Plan__c parentPlan : parentPlans){
                for(Plan__c playlist : plans){
                    if(playlist.Parent_Plan__c == parentPlan.Id){
                        //system.debug(parentPlan.Number_of_Addresses_on_Playlists__c);
                        //system.debug(parentPlan.Number_of_Addresses_Currently_on_Plan__c);
                        //system.debug(playlist.Number_of_Addresses__c);
                        if(parentPlan.Number_of_Addresses_on_Playlists__c==null){
                            parentPlan.Number_of_Addresses_on_Playlists__c=0;
                        }
                        if(parentPlan.Number_of_Addresses_Currently_on_Plan__c==null){
                            parentPlan.Number_of_Addresses_Currently_on_Plan__c=0;
                        }
                        if(playlist.Number_of_Addresses__c!=null){
                            parentPlan.Number_of_Addresses_on_Playlists__c -= playlist.Number_of_Addresses__c;
                            parentPlan.Number_of_Addresses_Currently_on_Plan__c += playlist.Number_of_Addresses__c;
                        }
                        
                       // parentPlan.Playlist_Is_Being_Updated__c=true;
                        updateCountPlans.add(parentPlan);
                        //system.debug(parentPlan.Number_of_Addresses_on_Playlists__c);
                        //system.debug(parentPlan.Number_of_Addresses_Currently_on_Plan__c);
                    }
                }
            }
            try{
                update updateCountPlans;
            } catch(Exception ex){
                System.debug('Following exception occurred while updating parentPlans :'+ex);
            }
        }
    }

    public static void moveTurfAddressCountToPlaylist(List<Plan__c> plans){
        Set<Id> parentIds = new Set<Id>();
        for(Plan__c p : plans){
            if(p.Plan_Level__c == 'Playlist'){
                parentIds.add(p.Parent_Plan__c);
            }
        }
        if(!parentIds.isEmpty()){
            List<Plan__c> parentPlans = [Select Id, Number_of_Addresses__c, True_count_of_Addresses__c, 
                                Number_of_Addresses_Currently_on_Plan__c, Number_of_Addresses_on_Playlists__c
                                From Plan__c Where Id IN: parentIds];
            List<Plan__c> updateCountPlans=new List<Plan__c>();
            for(Plan__c parentPlan : parentPlans){
                for(Plan__c playlist : plans){
                    if(playlist.Parent_Plan__c == parentPlan.Id){
                        //system.debug(parentPlan.Number_of_Addresses_on_Playlists__c);
                        //system.debug(parentPlan.Number_of_Addresses_Currently_on_Plan__c);
                        //system.debug(playlist.Number_of_Addresses__c);
                        if(parentPlan.Number_of_Addresses_on_Playlists__c==null){
                            parentPlan.Number_of_Addresses_on_Playlists__c=0;
                        }
                        if(parentPlan.Number_of_Addresses_Currently_on_Plan__c==null){
                            parentPlan.Number_of_Addresses_Currently_on_Plan__c=0;
                        }
                        if(playlist.Number_of_Addresses__c!=null){
                            parentPlan.Number_of_Addresses_on_Playlists__c += playlist.Number_of_Addresses__c;
                            parentPlan.Number_of_Addresses_Currently_on_Plan__c -= playlist.Number_of_Addresses__c;
                        }
                        //parentPlan.Playlist_Is_Being_Updated__c=true;
                        updateCountPlans.add(parentPlan);
                        //system.debug(parentPlan.Number_of_Addresses_on_Playlists__c);
                        //system.debug(parentPlan.Number_of_Addresses_Currently_on_Plan__c);
                    }
                }
            }
            try{
                update updateCountPlans;
            } catch(Exception ex){
                System.debug('Following exception occurred while updating parentPlans :'+ex);
            }
        }
    }

    public static void updatePlaylistStatus(List<Plan__c> plans){
        for(Plan__c p : plans){
            if(p.Plan_Level__c == 'Playlist'){
                p.Playlist_Is_Being_Updated__c=true;
            }
        }
    }

    public static void setFieldsForAddressStatsSearch(List<Plan__c> plans){
        Set<String> ids = new Set<String>();
        for(Plan__c p : plans){
            if(p.Plan_Level__c != Label.PlanTypeBulk) {
                ids.add(p.Id);
                p.Address_Nodes_1__c = '';
                p.Address_Nodes_2__c = '';
                p.Address_Nodes_3__c = '';
                p.Address_Nodes_4__c = '';
                p.Address_Nodes_5__c = '';
                p.Address_Zip_Codes__c = '';
            }
        }

        List<Customer_Address__c> addresses = new List<Customer_Address__c>();
        //system.debug('CheckId'+ ids.contains(null));
        //system.debug('plan Ids:'+ ids);
        if(ids.size()>0)
        addresses.addAll([Select Id, Plan__c, Node__c, PostalCode__c From Customer_Address__c Where Plan__c IN: ids]);
        for(Customer_Address__c a : addresses){
            for(Plan__c p : plans){
                if(p.id!=null && p.Plan_Level__c != Label.PlanTypeBulk) {
                    if(a.Plan__c == p.Id){
                        if((a.Node__c!=null)&&(!p.Address_Nodes_1__c.contains(a.Node__c) && !p.Address_Nodes_2__c.contains(a.Node__c) && !p.Address_Nodes_3__c.contains(a.Node__c) && !p.Address_Nodes_4__c.contains(a.Node__c) && !p.Address_Nodes_5__c.contains(a.Node__c))){
                             if (p.Address_Nodes_1__c.length() < 255 && p.Address_Nodes_1__c.length() + (a.Node__c.length() + 1) <= 255)
                                {
                                    p.Address_Nodes_1__c += a.Node__c + ',';
                                }
                                else if (p.Address_Nodes_2__c.length() < 255 && p.Address_Nodes_2__c.length() + (a.Node__c.length() + 1) <= 255)
                                {
                                    p.Address_Nodes_2__c += a.Node__c + ',';
                                }
                                else if (p.Address_Nodes_3__c.length() < 255 && p.Address_Nodes_3__c.length() + (a.Node__c.length() + 1) <= 255)
                                {
                                    p.Address_Nodes_3__c += a.Node__c + ',';
                                }
                                else if (p.Address_Nodes_4__c.length() < 255 && p.Address_Nodes_4__c.length() + (a.Node__c.length() + 1) <= 255)
                                {
                                    p.Address_Nodes_4__c += a.Node__c + ',';
                                }
                                else if (p.Address_Nodes_5__c.length() < 255 && p.Address_Nodes_5__c.length() + (a.Node__c.length() + 1) <= 255)
                                {
                                    p.Address_Nodes_5__c += a.Node__c + ',';
                                }
                            }
                        if((a.PostalCode__c!=null)&&(!p.Address_Zip_Codes__c.contains(a.PostalCode__c))){
                            p.Address_Zip_Codes__c += a.PostalCode__c + ',';
                        }
                    }
                }
            }
        }

        for(Plan__c p : plans){
            if(p.id!=null && p.Plan_Level__c != Label.PlanTypeBulk) {
                if(p.Address_Nodes_1__c!=''){
                    p.Address_Nodes_1__c = p.Address_Nodes_1__c.subString(0,p.Address_Nodes_1__c.length()-1);
                 }
                if(p.Address_Nodes_2__c!=''){
                    p.Address_Nodes_2__c = p.Address_Nodes_2__c.subString(0,p.Address_Nodes_2__c.length()-1);
                }
                if(p.Address_Nodes_3__c!=''){
                    p.Address_Nodes_3__c = p.Address_Nodes_3__c.subString(0,p.Address_Nodes_3__c.length()-1);
                }
                if(p.Address_Nodes_4__c!=''){
                    p.Address_Nodes_4__c = p.Address_Nodes_4__c.subString(0,p.Address_Nodes_4__c.length()-1);
                }
                if(p.Address_Nodes_5__c!=''){
                    p.Address_Nodes_5__c = p.Address_Nodes_5__c.subString(0,p.Address_Nodes_5__c.length()-1);
                }
                if(p.Address_Zip_Codes__c != ''){
                    p.Address_Zip_Codes__c = p.Address_Zip_Codes__c.subString(0,p.Address_Zip_Codes__c.length()-1);
                }
            }
        }
    }
        
}