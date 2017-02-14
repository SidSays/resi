/**************************************************************************************************************************************
 * Author          : Ashish Sonawane
 * Date            : 9-Feb-2015
 * Description     : Add/Update MDU user Public group  
 * User Story      : 896
 * History Version : 1.0
 * PROJECT         : Mdu SFDC 
 * Updated By      : Sucheta Verma on 11-Dec- 2015 #US581655 : Automatic user to group association for CAR Managers
 * Updated By      : Rahul Prabhakar on 15-Dec- 2015 #US603057 :Add CAR automatically to "All CAR" public  group
 * Updated By      : Ashish Sonawane on 30-dec-2015 #US610402 :Add XC Quota: Baseline Quota creation for new AE & Region change
 * Updated By      : Suchita Sharma on 12-Feb-2016 #US625976 :Add/Update MDU User to Public Group based on Region.
 * Updated By      : Animesh Datta on 16-Nov-2016 #US799120,US799239,US799275 :Add/Remove Users to Chatter Group
**************************************************************************************************************************************/
global class UserTriggerOperation{
    
    //Data Member      
    private static final string GOALTEMPLATE_DATE_CS = 'Default_Communities';
    private static final string MANAGER_GROUP_TYPE = 'Manager';
    private static final string XC_ACCOUNT_EXEC_PROFILE = 'XC Account Executive';
    private static final string EDIT_ACCESS_GOAL = 'Edit';
    private static final string GOAL_STATUS_PUBLISHED = 'Published';
    //private static final string METRIC_STATUS_BEHIND = 'Behind';
    private static final string METRIC_STATUS_NOTSTARTED = 'NotStarted';
    global static  List<Goal> goalList = new List<Goal>();
    global static  Map<String,List<Metric>> UserIDMetricListMap = new Map<String,List<Metric>>() ;

    /**    
    * @Description: Business logic to add CAR/CAR Manager/XC/ Direct users to respective public group.
    * @Author: Malay Desai, Accenture    
    * @Date: 23-Feb-2016  
    * @Param:  Trigger.New, Trigger.OldMap    
    * @Return: None */   
    
    public static void addUsersToPublicGroup(List<User> userList, Map<Id, User> oldMap){
        Map<String, String> regionVsGroupName = new Map<String, String>();
        Map<String, Id> groupNameVsId  = new Map<String, Id>();
        Set<String> groupNamesXC = new Set<String>();
        Set<Id> groupIDsXC = new Set<Id>();
        List<GroupMember> groupMembers = new List<GroupMember>();
        List<Region_Profile_PublicGroups__c> regionProfileVsGroupNameCS = Region_Profile_PublicGroups__c.getAll().values();
        System.debug('regionProfileVsGroupNameCS>>>'+regionProfileVsGroupNameCS);
    final Set<String> profileNames = new Set<String>{'Regional System Admin (RSA)',
                                            'XFINITY Sales Professional','Sales Development Manager','XFINITY Sales Executive','Area Sales Manager','Contractor Sales Professional',
                                            'Contractor Sales Leader','Community Account Manager','Community Account Representative​','Community Account Supervisor',
                                            'FIND Representative','FIND Manager','FIND Supervisor','XC Account Executive','XC AE Contractors','XC Analyst','XC Cabled Units',
                                            'XC Call Centers','XC Integration Profile','XC Manager','XC Portfolio AE','XC Sales Support','XC SME','Xfinity CAR','Xfinity CAR Manager'};
        for(Region_Profile_PublicGroups__c cs : regionProfileVsGroupNameCS){
            regionVsGroupName.put(cs.Region__c+cs.Profile_Channel__c, cs.Public_Group_Name__c);
            
            if(cs.Profile_Channel__c.equalsIgnoreCase(Label.XC_Prefix)){ // To handle Global region
                groupNamesXC.add(cs.Public_Group_Name__c);
            }
        }
        System.debug('regionVsGroupName>>>>'+regionVsGroupName);
        for(Group grp : [SELECT id, Name FROM Group WHERE Name IN :regionVsGroupName.values()]){
            groupNameVsId.put(grp.Name, grp.Id);
            if(groupNamesXC.contains(grp.Name)){ // To handle Global region
                groupIDsXC.add(grp.Id);
            }
        }
        System.debug('groupNameVsId>>>'+groupNameVsId);
        for(User aUser: userList){
            GroupMember groupMemberTobeAdded;
            if(aUser.Region__c != null && profileNames.contains(aUser.Profile_Name_Text__c)){    //Procceed ONLY if new Profile is one of the listed ones.
                if(oldMap != null){ //Event: After Update 
                    if(aUser.ProfileId != oldMap.get(aUser.Id).ProfileId){// Profile updated 
                        if(aUser.Region__c != null && aUser.Region__c.equalsIgnoreCase(Label.Global_Division)){  // If region is Global and profile is XC add it to all XC Groups
                                if((aUSer.Profile_Name_Text__c).startsWith(Label.XC_Prefix)){
                                    for(Id groupId : groupIDsXC){
                                        groupMembers.add(createGroupMember(aUser.Id,groupId));
                                        System.debug('1 group members>>>'+groupMembers);
                                    }
                                }
                        } else{
                            groupMemberTobeAdded = addGroupMember(aUser,regionVsGroupName,groupNameVsId);
                            if(groupMemberTobeAdded != null)
                                { groupMembers.add(groupMemberTobeAdded);
                                System.debug('2 group members>>>'+groupMembers);
                                }
                        }
                    } else if(aUser.Region__c != oldMap.get(aUser.Id).Region__c){//If region is updated
                            if(aUser.Region__c != null && aUser.Region__c.equalsIgnoreCase(Label.Global_Division)){  // If region is Global and profile is XC add it to all XC Groups
                                if((aUSer.Profile_Name_Text__c).startsWith(Label.XC_Prefix)){
                                    for(Id groupId : groupIDsXC){
                                        groupMembers.add(createGroupMember(aUser.Id,groupId));
                                        System.debug('3 group members>>>'+groupMembers);
                                    }
                                }
                            } else{
                                 groupMemberTobeAdded = addGroupMember(aUser,regionVsGroupName,groupNameVsId);
                                 if(groupMemberTobeAdded != null)
                                    groupMembers.add(groupMemberTobeAdded); 
                                System.debug('4 group members>>>'+groupMembers);
                                
                            } 
                    } else if(aUser.UserRoleId != oldMap.get(aUser.Id).UserRoleId){ // Role is changed
                            groupMemberTobeAdded = addGroupMember(aUser,regionVsGroupName,groupNameVsId);
                            if(groupMemberTobeAdded != null)
                                groupMembers.add(groupMemberTobeAdded);
                            System.debug('5 group members>>>'+groupMembers);
                        } 
                   // }
            }  else{ //Event: After Insert
                if(aUser.Region__c != null && aUser.Region__c.equalsIgnoreCase(Label.Global_Division)){  // If region is Global and profile is XC add it to all XC Groups
                    if((aUSer.Profile_Name_Text__c).startsWith(Label.XC_Prefix)){
                        for(Id groupId : groupIDsXC){
                            groupMembers.add(createGroupMember(aUser.Id,groupId));
                            System.debug('6 group members>>>'+groupMembers);
                        }
                    }
                } 
                else{ // For any other region
                    groupMemberTobeAdded = addGroupMember(aUser,regionVsGroupName,groupNameVsId);
                    if(groupMemberTobeAdded != null)
                        groupMembers.add(groupMemberTobeAdded);
                    System.debug('7 group members>>>'+groupMembers);
                }              
            }
          }
        } 
        
        if(groupMembers.size() > 0){
            Database.Insert(groupMembers,false);
            System.debug('groupMembers>>>>'+groupMembers);
        }
        
    }
    
    private static GroupMember addGroupMember(User aUser, Map<String, String> regionVsGroupName, Map<String, Id> groupNameVsId){
        Id groupId = null;
        GroupMember groupMember;
        
        if((aUser.Profile_Name_Text__c).startsWith(Label.XC_Prefix)){ // For all Communities profiles that start with 'XC'
            groupId = groupNameVsId.get(regionVsGroupName.get(aUser.Region__c + Label.XC_Prefix));
         } else if((aUser.Profile_Name_Text__c).equalsIgnoreCase(Label.Xfinity_CARmanager_ProfileName)){ //For Xfinity CAR Manager
                groupId = groupNameVsId.get(regionVsGroupName.get(aUser.Region__c + Label.Xfinity_CARmanager_ProfileName.subString(8)));
         } else if((aUser.Profile_Name_Text__c).equalsIgnoreCase(Label.Xfinity_CAR_ProfileName)){ 
                groupId = groupNameVsId.get(regionVsGroupName.get(aUser.Region__c + Label.Xfinity_CAR_ProfileName.subString(8))); //For Xfinity CAR
         } else{
                groupId = groupNameVsId.get(regionVsGroupName.get(aUser.Region__c + Label.SubmitCaseControllerDirectSales)); // For Direct Sales and few other profiles
         }
         
        if(GroupId != null){
            groupMember = createGroupMember(aUser.Id, groupId);
        }   
        
        return groupMember;
    }
    
    private static GroupMember createGroupMember(Id userId, Id groupId){
        System.debug('in createGroupMember>>> user id '+ userId);
        System.debug('in createGroupMember>>> group id '+ groupId);
        GroupMember groupMember = new GroupMember();
        groupMember.GroupId = groupId;
        groupMember.UserOrGroupId = userId;
        
        return groupMember;
    }
    
  /**    
    * @Description: Business logic to create new goals when new user is created with Account Executive and Region updated for existing users.
    * @Author: Ashish Sonawane, Accenture    
    * @Date: 30-Dec-2015   
    * @Param:  None    
    * @Return: None    
    */ 
    public static void CreateNewAEGoal(){
        Map<id,User> oldUserMap =  (Map<id,User>) Trigger.OldMap;
        Set<String> userRegionChangeSet = new  Set<String>();
        for(User user :(List<User>) Trigger.New){                      
            if(String.valueOf(user.ProfileId).contains(Label.XCAccountExecutive) && user.UserPermissionsWorkDotComUserFeature == True){             
                if(Trigger.IsInsert && user.Region__c!= null){
                    userRegionChangeSet.add(user.id);
                }
                else if(Trigger.IsUpdate && user.Region__c!= oldUserMap.get(user.id).Region__c){                
                    userRegionChangeSet.add(user.id);     
                }                            
            }  
        }  
        if(userRegionChangeSet.size() > 0){
            CreateNewAEGoalFuture(userRegionChangeSet);
        }
            
    }
    
   /**    
    *@Description: future method CreateNewAEGoalFuture use to create Goal records for XC Account Executive user in separate thread to skip setup and non-setup exception  
    * @Author: Ashish Sonawane, Accenture    
    * @Date: 30-Dec-2015   
    * @Param:  set of user id(userRegionChangeSet)     
    * @Return: None    
    */ 
    @future 
    global static void CreateNewAEGoalFuture(Set<String> userRegionChangeSet){
            String userProfileName;  
            String userRegion;
            Set<String> statusSet = new Set<String>{'Draft','Published'};
            Map<String,List<Goal>> ownerIdGoalUpdateListMap = new Map<String,List<Goal>>();         
            List<Goal> existGoalList = new List<Goal>();
            Map<String , Goal> goalSettingMap = new Map<String , Goal>();
            Map<String, Goal> goalMap = new Map<String, Goal>(); 
            List<Goal> goalUpdateFinalList = new  List<Goal>();         
            String XfinityCommunitiesRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.Goal_Xfinity_Communities_Recordtype).getRecordTypeId();                      
            Map<Id,Id> userGroupMap = new Map<Id,Id>();
            String Goal_Template_RecordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.Goal_Goal_Template_Recordtype).getRecordTypeId();
            List<Metric> metricInsertList = new List<Metric>();          
            Map<String,Map<String,List<Goal>>> ownerIdRegionGoalUpdateListMap = new Map<String,Map<String,List<Goal>>>();
            Map<String,Set<String>> ownerIdRegionListExistMap = new Map<String,Set<String>>();
            //Create start date and end date for new user goal
            Date preGoalStartDate = null;
            Date preGoalDueDate = null;
            DateTime preGoalStartDateTime = null;
            DateTime preGoalDueDateTime = null;
            Integer monthsCreated = 0;
            Integer todayDate = Date.Today().Day();
            Integer todayMonth = Date.Today().Month();         
            
            //Get the Fiscal Year Date period goal start/due dates            
            GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(GOALTEMPLATE_DATE_CS);
            
            if(goalDates != null){               
                if(todayDate>=22){              
                    preGoalStartDate = Date.newInstance(date.today().Year(), date.today().Month(), 22);  
                }else if(todayDate>=1 && todayDate<=21){
                    preGoalStartDate = Date.newInstance(date.today().Year(), date.today().Month()-1, 22); 
                }
                preGoalStartDateTime = preGoalStartDate; 
                
                preGoalDueDate =  preGoalStartDate.addMonths(1).AddDays(-1); //Date.newInstance(date.today().Year(), preGoalStartDate.addMonths(1), 21); 
                monthsCreated = preGoalStartDate.monthsBetween(goalDates.Current_Period_Start_Date__c);  
                preGoalDueDateTime = preGoalDueDate;       
            }
            System.debug('userRegionChangeSet***'+userRegionChangeSet);
            System.debug('XfinityCommunitiesRecordTypeId***'+XfinityCommunitiesRecordTypeId);
            System.debug('preGoalStartDate***'+preGoalStartDate);
            System.debug('goalDates.Current_Period_Start_Date__c***'+goalDates.Current_Period_Start_Date__c);
            //Use existing goal for region change if exist
            for(Goal goalObj: [SELECT OwnerId, Id, Region__c, Status FROM Goal WHERE OwnerId IN:userRegionChangeSet AND 
                                RecordTypeId =:XfinityCommunitiesRecordTypeId AND StartDate >=: preGoalStartDate AND Status  IN: statusSet AND
                                DueDate <: goalDates.Current_Period_Start_Date__c  ]){
                
                if(goalObj.Status == 'Published'){      
                    List<Goal> goalUpdateList = new List<Goal>();   
                    if(ownerIdGoalUpdateListMap.containsKey(goalObj.ownerid)){                                              
                        goalUpdateList = ownerIdGoalUpdateListMap.get(goalObj.ownerid);                                      
                    }
                    goalObj.Status = 'Draft';
                    goalUpdateList.add(goalObj);
                    ownerIdGoalUpdateListMap.put(goalObj.ownerId,goalUpdateList);
                    //ownerIdRegionGoalUpdateListMap.put(goalObj.ownerid,ownerIdGoalUpdateListMap); 
                }else if(goalObj.Status == 'Draft'){            
                    Set<String> regionSet = new Set<String>();
                    if(ownerIdRegionListExistMap.containsKey(goalObj.ownerId)){
                        regionSet = ownerIdRegionListExistMap.get(goalObj.ownerId);                        
                    }  
                    if(!regionSet.contains(goalObj.Region__c)){
                        regionSet.add(goalObj.Region__c);
                        ownerIdRegionListExistMap.put(goalObj.ownerId,regionSet);                           
                    }
                    
                }                            
            }
            //Store Goal Tempate for Community In Map 
            for(Goal gol : [SELECT Id,Template_Type__c,DueDate,Name,StartDate,Status,Profile_Name__c,Region__c,Sales_Rep_Type__c,Level__c,(SELECT Id,Name,TargetValue,Status,DueDate,Weight,LastComment from Metrics)  from Goal where Template_Type__c =: system.label.Goal_Template_Type_Communities and RecordtypeId =: Goal_Template_RecordtypeId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) { 
                goalSettingMap.put((gol.Profile_Name__c + gol.Region__c).trim() , gol);            
                goalMap.put(gol.Id , gol);
            }
            // Generate Goal base on Profile Name And Region of User 
            for(User user :[SELECT Id, Region__c, FirstName, LastName,
                                         Sales_Rep_Type__c, Level__c, Profile.name, ManagerId FROM User WHERE Id In:userRegionChangeSet LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
            {
                Boolean isGoalExist = false;
                Set<String> regionList = new Set<String>();                   
                if(ownerIdRegionListExistMap.containsKey(user.id)){
                    regionList = ownerIdRegionListExistMap.get(user.id);
                    isGoalExist = regionList.contains(user.Region__c)?true:false;
                }                                           
                Boolean createNewGoal = false;
                if(ownerIdGoalUpdateListMap.containskey(user.Id)){
                    goalUpdateFinalList.addAll(ownerIdGoalUpdateListMap.get(user.Id));
                   
                    if(!isGoalExist){
                        createNewGoal = true;
                    }
                }else if(!isGoalExist){
                    createNewGoal = true;
                }
                if(createNewGoal &&  userRegionChangeSet.contains(user.id)){                   
                   
                    userProfileName = XC_ACCOUNT_EXEC_PROFILE;             
                    userRegion=user.Region__c;              
                    Date preGoalStartDateInner = preGoalStartDate;
                    Date preGoalDueDateInner = preGoalDueDate;
                    DateTime preGoalStartDateTimeInner = preGoalStartDateTime;
                    DateTime preGoalDueDateTimeInner = preGoalDueDateTime;
                    Goal goalInst = goalSettingMap.get((userProfileName+userRegion).trim());                    
                    
                    if(goalInst != null){
                        //Logic to create  monthly goal when new AE created/Region changed.                        
                        for(integer i=0;i<monthsCreated;i++){
                            String UserIDGoalDueDate=String.valueOf(user.Id) + preGoalDueDateInner;
                            Goal getGoal= goalMap.get(goalInst.id);                         
                            Goal cloneGoal = new Goal();
                            List<Metric> metricList = new List<Metric>();                         
                            cloneGoal=getGoal.Clone(false,true,true,false);                                 
                            if(system.label.Goal_XC_AE.equalsIgnoreCase(userProfileName)) { // xc account executive
                                cloneGoal.OwnerId=user.Id;                            
                            }                                                       
                            cloneGoal.Region__c = user.Region__c;
                            cloneGoal.Sales_Rep_Type__c = user.Sales_Rep_Type__c;
                            cloneGoal.Level__c = user.Level__c;
                            cloneGoal.Status = GOAL_STATUS_PUBLISHED;                          
                            Date d = preGoalStartDateInner; // 22/12/2014
                            String dateString = d.month()+'-'+d.day()+'-'+d.year();                         
                            cloneGoal.Name=user.FirstName+' '+ user.LastName +' - '+ user.Region__c +' - '+preGoalDueDateTimeInner.formatGMT('MMMM yyyy');                         
                            //Put start and due date in the goal to be create                                           
                            cloneGoal.StartDate = preGoalStartDateInner; //22/12/2014    
                            cloneGoal.DueDate = preGoalDueDateInner;                         
                            cloneGoal.RecordTypeId = XfinityCommunitiesRecordTypeId ;
                            if(user.ManagerId != null){
                                cloneGoal.Reporting_Manager__c = user.ManagerId;
                            }
                            goalList.add(cloneGoal);       
                            for(Metric metr: cloneGoal.Metrics){
                                Metric mt = new Metric();
                                mt=metr.Clone(false,true,true,false);                               
                                if(system.label.Goal_XC_AE.equalsIgnoreCase(user.Profile.name)) { // xc account executive
                                    mt.OwnerId=user.Id;
                                }                                                          
                                mt.Status = METRIC_STATUS_NOTSTARTED;
                                mt.DueDate = preGoalDueDateInner;
                                metricList.add(mt);  
                            }    
                            UserIDMetricListMap.put(UserIDGoalDueDate.trim() , metricList);                       
                            preGoalStartDateInner = preGoalStartDateInner.addMonths(1);
                            preGoalDueDateInner = preGoalDueDateInner.addMonths(1);
                            preGoalStartDateTimeInner=preGoalStartDateTimeInner.addMonths(1);
                            
              preGoalDueDateTimeInner=preGoalDueDateTimeInner.addMonths(1);
                        }                                       
                    }
                    
                }  
               
            }      
            //Inserting new Goals records 
            Database.SaveResult[] insertGoals = Database.Insert(goalList,false);
            //Update existing Goal
            Database.SaveResult[] updateGoals = Database.update(goalUpdateFinalList,false);
            // Assigning metric to goal
            for(Goal goalObj : [SELECT id, OwnerId ,Assigned_To__c, DueDate , Name 
                                            FROM Goal WHERE Id In : goalList LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                if(UserIDMetricListMap.get((String.valueOf(goalObj.OwnerId) + goalObj.DueDate).trim()) != null){
                   List<Metric> metricInsertList1 = new List<Metric>();
                   String UserIDGoalDueDate=String.valueOf(goalObj.OwnerId) + goalObj.DueDate; 
                   for(Metric metricObj : (List<Metric>) UserIDMetricListMap.get(UserIDGoalDueDate.trim())){
                        metricObj.GoalId = goalObj.Id;
                        metricInsertList1.add(metricObj);                     
                   }
                   metricInsertList.addAll(metricInsertList1);               
                }              
                
            }
            
            //Inserting new Metrics
            MetricTriggerController.allowValidation = false; //This flag use to disable validation rule written on trigger 
            Database.SaveResult[] insertMetrics = Database.Insert(metricInsertList,false);     
        } 

    /**    
    *@Description: Updating "Reporting Manager" field of Goal(from next fisical month) record if AE manager changes
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 19-Oct-2016   
    * @User Story: US814546     
    * @Return: None    
    */     
 
    public static void updateReportingMgrForGoal(Map<id,User> oldUserMap,List<User> newUserList){
        List<Goal> toUpdateGoalList = new List<Goal>();
        Map<String,String> userIdMgrMap = new  Map<String,String>();
        Date dueTemplateDate = null;
        Date preGoalStartDate = null;        
        Integer todayDate = Date.Today().Day();
        
        String XfinityCommunitiesRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(System.Label.Goal_Xfinity_Communities_Recordtype).getRecordTypeId();     
        //Get the Fiscal Year Date period goal start/due dates            
        GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(System.Label.QM_AnnualBaselineBatchContractorCusSetData);
         
        //Logic to find out next Fisical Month
        if(goalDates != null){
            dueTemplateDate = goalDates.Current_Period_Due_Date__c;
            if(todayDate>=22){              
                preGoalStartDate = Date.newInstance(date.today().Year(), date.today().Month(), 22).addMonths(1);  
            }else if(todayDate>=1 && todayDate<=21){
                preGoalStartDate = Date.newInstance(date.today().Year(), date.today().Month(), 22); 
            }                                   
        }
        
        for(User user : newUserList){
            
            if(Label.XCCommunitiesProfileId.contains(String.valueOf(user.ProfileId)) && user.UserPermissionsWorkDotComUserFeature == True && user.isActive == true){                            
                if(user.ManagerId != null && user.ManagerId != oldUserMap.get(user.id).ManagerId){                
                    userIdMgrMap.put(user.id,user.ManagerId);     
                }                            
            }  
        }  
        
        //Fetching the Goals from next fisical month
        for(Goal goalObj: [SELECT Id, OwnerId, Owner.Name, Region__c, Reporting_Manager__c, DueDate FROM Goal WHERE OwnerId IN:userIdMgrMap.keySet()
                           AND RecordTypeId =:XfinityCommunitiesRecordTypeId AND StartDate >=: preGoalStartDate AND DueDate <: dueTemplateDate]){
                              
            goalObj.Reporting_Manager__c = userIdMgrMap.get(goalObj.OwnerId);
            toUpdateGoalList.add(goalObj);
        }
        
        //Updating the Goals
        if(!toUpdateGoalList.isEmpty()){
            database.update(toUpdateGoalList,false);
        }
    }
    
    /**    
    *@Description: Add/Remove Users from Chatter Group based on Chatter Group Vs Profile Data in Custom Settings ProfileVsChatterGroup__c
    * @Author: Animesh Datta, Accenture    
    * @Date: 16-Nov-2016   
    * @User Story: US799120,US799239,US799275     
    * @Return: None    
    */
    
    public static void addUsersToChatterGroup(Map<Id,User> oldUserDetails,List<User> newUserDetail) {
        Set<ID> userIds = new Set<ID>();
        List<String> groupIdList = new List<String>();
        Map<Id,String> userIdVsChatterGroupMap = new Map<Id,String>();   
        Map<String, ProfileVsChatterGroup__c> customSettingMap = ProfileVsChatterGroup__c.getAll();
        
        try{
            if(trigger.oldMap!=null){
                for(User usr: newUserDetail){               
                    User oldUser = (User)Trigger.oldMap.get(usr.Id);
                    ProfileVsChatterGroup__c oldProfileVsChatterGroupsCS = customSettingMap.get(oldUser.Profile_Name_Text__c);
                    if(oldProfileVsChatterGroupsCS !=null && usr.Profile_Name_Text__c != oldUser.Profile_Name_Text__c){  
                        groupIdList.addAll(oldProfileVsChatterGroupsCS.Chatter_Group_Ids__c.split(','));
                        userIds.add(usr.Id);
                    }
                }
            }
            for(User userObj: newUserDetail){
                ProfileVsChatterGroup__c newProfileVsChatterGroupsCS = customSettingMap.get(userObj.Profile_Name_Text__c);
                if(newProfileVsChatterGroupsCS !=null){
                    userIdVsChatterGroupMap.put(userObj.Id, newProfileVsChatterGroupsCS.Chatter_Group_Ids__c);
                }
            }
            if((!userIds.isEmpty() && !groupIdList.isEmpty()) || userIdVsChatterGroupMap!=null){
                addAndRemoveChatterGroupMembers(groupIdList,userIds,userIdVsChatterGroupMap);
            }
        }catch(Exception ex){
            System.debug('*****Following exception has occurred*****'+ex.getMessage());
        } 
            
    }
    
    /**    
    *@Description: Calling this future method from method addAndRemoveChatterGroupMembers in this class. This method is written in Future context to avoid issue with Set up and Non Set up objects 
    * @Author: Animesh Datta, Accenture    
    * @Date: 16-Nov-2016   
    * @User Story: US799120,US799239,US799275     
    * @Return: None    
    */
    
    @future
    global static void addAndRemoveChatterGroupMembers(List<String> groupIdList, Set<ID> userIds, Map<Id,String> userIdVsChatterGroupMap) {
        List<CollaborationGroupMember> oldGroupMembersList = new List<CollaborationGroupMember>();
        List<CollaborationGroupMember> collaborationGroupMemberList = new List<CollaborationGroupMember>();
        CollaborationGroupMember collaborationGroupMemberObj;
        
        try{
            if(!userIds.isEmpty() && !groupIdList.isEmpty()){
                for(CollaborationGroupMember members: [SELECT Id, CollaborationGroupId, MemberId FROM CollaborationGroupMember 
                                                            WHERE CollaborationGroupId IN :groupIdList AND MemberId IN :userIds]) {
                    oldGroupMembersList.add(members);
                }
                if(!oldGroupMembersList.isEmpty()){
                    Database.delete(oldGroupMembersList,false);
                }
            }
            if(userIdVsChatterGroupMap!=null){
                for(Id userId: userIdVsChatterGroupMap.keySet()){
                        for(String groupId:  userIdVsChatterGroupMap.get(userId).split(',')) {
                            collaborationGroupMemberObj = new CollaborationGroupMember();
                            collaborationGroupMemberObj.CollaborationGroupId = groupId;
                            collaborationGroupMemberObj.MemberId = userId;
                            collaborationGroupMemberList.add(collaborationGroupMemberObj);
                        }   
                }
                if(!collaborationGroupMemberList.isEmpty()) {
                    Database.insert(collaborationGroupMemberList,false);
                }
            }
        }catch(Exception ex){
            System.debug('*****Following exception has occurred*****'+ex.getMessage());
        }
            
    }
}