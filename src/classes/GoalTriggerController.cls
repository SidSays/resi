public with sharing class GoalTriggerController{
    private static final string System_Administrator = 'System Administrator';
    
    public static void goalSharingMgrGrp(List<Goal> newGoalList){
        List<GoalShare> goalShareList = new List<GoalShare>();
        List<Goal> goalUpdatedList = new List<Goal>();
        Set<Id> ownerIdSet = new Set<Id>();
        Map<Id, Id> groupMap = new Map<Id, Id>();
        String goalTemplateRecordType = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.Goal_Goal_Template_Recordtype).getRecordTypeId();
        String goalDirectSalesRecordType = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.GoalDirectSalesRecordType).getRecordTypeId();
        String goalCommunitiesRecordType = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.CommunitiesGoalRecordType).getRecordTypeId();
        String goalPropertyLabRecordType = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.Label.PL_MonthlyGoalCreationBatchGolTempType).getRecordTypeId();
        String profilevalue = Label.XC_AE_Contractors;
        
        for(Goal goalTemp : newGoalList){
            if( goalTemp.recordTypeId != goalTemplateRecordType && goalTemp.Profile_Name__c != profilevalue ){              
                ownerIdSet.add(goalTemp.ownerId);  
                goalUpdatedList.add(goalTemp);              
            }                      
        }       
            
        if(!ownerIdSet.isEmpty()){
            for(Group groupTemp : [SELECT Id, RelatedId,Type FROM Group WHERE Type = 'Manager' AND RelatedId IN :ownerIdSet]){
                groupMap.put(groupTemp.RelatedId, groupTemp.Id);
            }
        }
        
        for(Goal goalTemp : goalUpdatedList){
            if(!groupMap.isEmpty() && groupMap.get(goalTemp.ownerId)!=null ){
                GoalShare goalShareRecord = new GoalShare();
                goalShareRecord.ParentId = goalTemp.Id;
                goalShareRecord.userorgroupId = groupMap.get(goalTemp.ownerId); 
                if(goalTemp.recordTypeId == goalDirectSalesRecordType){
                    goalShareRecord.AccessLevel = system.label.GoalReadAccess; 
                }else if(goalTemp.recordTypeId == goalCommunitiesRecordType || goalTemp.recordTypeId == goalPropertyLabRecordType){
                    goalShareRecord.AccessLevel = system.label.GoalEditAccess ;
                }
                goalShareRecord.rowCause = Schema.GoalShare.rowCause.Manual;
                goalShareList.add(goalShareRecord);
            }
        }
        if(!goalShareList.isEmpty()){
            Database.insert(goalShareList, false);
        }     
    }
        
    /**
    * @Description: This method is to give access to goal object records to Goal's owner manager and its manager hierarchy.
    * US626485 XC Quota: Contractors Quota Visibility
    * @Author: Radhika Bansal, Accenture 
    * @Date: 5-Feb-2016    
    * @Return: void.
    */
    public static void goalContractorSharingMgrGrp(List<Goal> newGoalList)
    {         
        String profilevalue = Label.XC_AE_Contractors;
        List<GoalShare> goalShareList = new List<GoalShare>();
        Set<String> regionIds = new Set<String>();
        Map<Id, Id> groupMap = new Map<Id, Id>();
        List<Id> ownerIds = new List<Id>();
        List<Goal> contGoalList = new List<Goal>();
        List<Contractor_Region_Mapping__c> contRegMapList = new List<Contractor_Region_Mapping__c>();
        Map<String, String> OwnerManagerMap = new Map<String, String>();
       // List<Goal> selectedGoals = [Select Id, region__c, ownerId from Goal where Owner.Profile.Name = :profilevalue And ID IN : newGoalList];
        for(Goal goalRecords: newGoalList )
        {
            if(goalRecords.Profile_Name__c == profilevalue){
                contGoalList.add(goalRecords);
                ownerIds.add(goalRecords.OwnerId);
                regionIds.add(goalRecords.Region__c);
            }               
        }
       
        // List to extract the region,active manager and active contractor
        if(!regionIds.isEmpty() && !ownerIds.isEmpty()){
            contRegMapList = [SELECT AE_Contractor__c, Region__c, Reporting_Manager__c FROM  Contractor_Region_Mapping__c where Region__c IN :regionIds and AE_Contractor__c IN : ownerIds AND AE_Contractor__r.Profile.Name = :profilevalue AND Reporting_Manager__r.isActive=TRUE AND AE_Contractor__r.isActive=TRUE];
        }
        
        // Map for Owner and its manager and List to extract the reporting managers of valid regions and users
        for(Contractor_Region_Mapping__c contVar: contRegMapList)
        {                   
            OwnerManagerMap.put(contVar.AE_Contractor__c+contVar.Region__c, contVar.Reporting_Manager__c ); 
        }           
        
        // Map of Owner Manager and their manager hierarchy
        for(Group groupTemp : [SELECT Id, RelatedId,Type FROM Group WHERE Type = 'Manager' AND RelatedId IN :OwnerManagerMap.values()]){
            groupMap.put(groupTemp.RelatedId, groupTemp.Id);
        }               
        
        
        for(Goal goalTemp : contGoalList){
            
            // Below loop is for user to manager sharing access
            String ownerIdRegion = goalTemp.ownerId+goalTemp.Region__c;
            if(!OwnerManagerMap.isEmpty() && OwnerManagerMap.containsKey(ownerIdRegion) ){
                GoalShare goalShareRecord = new GoalShare();
                goalShareRecord.ParentId = goalTemp.Id;
                goalShareRecord.userorgroupId = OwnerManagerMap.get(ownerIdRegion); 
                goalShareRecord.AccessLevel = system.label.GoalEditAccess;                
                goalShareRecord.rowCause = Schema.GoalShare.rowCause.Manual;
                goalShareList.add(goalShareRecord);
            }
            
            // Below loop is for manager to manager hierarchy access
            String mngrid = OwnerManagerMap.get(ownerIdRegion);
            if(mngrid != null && mngrid != '' && !groupMap.isEmpty() && groupMap.containsKey(mngrid)){
                GoalShare goalShareRecord = new GoalShare();
                goalShareRecord.ParentId = goalTemp.Id;
                goalShareRecord.userorgroupId = groupMap.get(mngrid); 
                goalShareRecord.AccessLevel = system.label.GoalEditAccess;                
                goalShareRecord.rowCause = Schema.GoalShare.rowCause.Manual;
                goalShareList.add(goalShareRecord);
            }
        }
        
        if(!goalShareList.isEmpty()){
            Database.insert(goalShareList,false);
        }        
    }
        
    /**
    * @Description: This method is to give access to goal object records to Goal's owner manager and its manager hierarchy.
    * US626485 XC Quota: Contractors Quota Visibility
    * @Author: Radhika Bansal, Accenture 
    * @Date: 5-Feb-2016    
    * @Return: void.
    */
        
    public static void updategoalContractorSharingMgrGrp(List<Goal> newList, Map<Id,Goal> oldGoalMap){
        List<Goal> listGoal = new List<Goal>();
        List<Goal> oldListGoal = new List<Goal>();
        for(Goal g : newList){
            if((g.ownerId != oldGoalMap.get(g.id).ownerId && g.ownerId != null)||(g.Region__c!= oldGoalMap.get(g.id).Region__c && g.Region__c != null)){
                listGoal.add(g);
                oldListGoal.add(oldGoalMap.get(g.id));
            }
        }
        
        if(!oldListGoal.isEmpty()){
            unshareGoal(oldListGoal);
        }
        
        if(!listGoal.isEmpty()){
            goalContractorSharingMgrGrp(listGoal);
        }
    }
    
    public static void unshareGoal(List<Goal> goalList){
        List<goalShare> deleteGoalList =  new List<goalShare>();
        List<Database.DeleteResult> drList = new List<Database.DeleteResult>();
        if(goalList.size() > 0){
            deleteGoalList = [SELECT id FROM GoalShare WHERE parentId IN :goalList];
        }
        
        if(!deleteGoalList.isEmpty()){
            drList = Database.delete(deleteGoalList,false);
        }
        for(Database.DeleteResult dr : drList){            
            if(!dr.isSuccess()){                                                 
                for(Database.Error error : dr.getErrors()){
                    System.Debug('Error Fields : '+ error.getFields());
                    System.Debug('Error Message : ' + error.getMessage());
                    System.Debug('Error Status Code : ' + error.getStatusCode());                                                              
                }
            }
        }
    }  

    /**
        * @Description: This method is use to validating the Goal Record for Contractor and his reporting manager
        * US636901 XC Quota: Validation for Contractors AE & Mgr
        * @Author: Tejaswini Kasar, Accenture 
        * @Date: 26-Feb-2016    
        * @Return: void.
        */
    public static void aeContractorAndMgrValidation(List<Goal> goalList,Map<Id, Goal> oldgoalMap ){
              
        Set<Id> ownerIdSet = new Set<Id>();
        Map<String,Map<String,String>> contRegionMgrMap = new Map<String,Map<String,String>>();
        String ProfileidsystemAdmin = [select Id from Profile where Name = : System_Administrator limit 1].Id;
        
        String goalRecordTypIdXfinityCommunities = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
        
        for(Goal newGoal :goalList ){ 
            if(newGoal.recordtypeId == goalRecordTypIdXfinityCommunities &&  Userinfo.getProfileId() != ProfileidsystemAdmin){
                ownerIdSet.add(newGoal.ownerId);
            }   
        }
        Map<Id,User> userIdToProfileMap = new Map<Id,User>([Select Id,Profile.Name from User where Id IN : ownerIdSet]);
        
        //Fetching the Contractor Region Mapping records
        for(Contractor_Region_Mapping__c contRegionMapObj : [ SELECT id, Name, AE_Contractor__c, Region__c, Reporting_Manager__c 
                                                                            FROM Contractor_Region_Mapping__c 
                                                                             WHERE AE_Contractor__c IN :ownerIdSet]){
                                                                             
            Map<String,String> regionMgrMapTemp = new Map<String,String>();
            if(contRegionMgrMap.containsKey(contRegionMapObj.AE_Contractor__c)){
                regionMgrMapTemp = contRegionMgrMap.get(contRegionMapObj.AE_Contractor__c);
            }
            regionMgrMapTemp.put(contRegionMapObj.Region__c, contRegionMapObj.Reporting_Manager__c);
            contRegionMgrMap.put(contRegionMapObj.AE_Contractor__c, regionMgrMapTemp);
                            
        }
        
        for(Goal newGoal :goalList ){ 
            Goal oldGoal = oldgoalMap.get(newGoal.Id);
            
            if( Userinfo.getProfileId() != ProfileidsystemAdmin && !userIdToProfileMap.isEmpty() && userIdToProfileMap.containsKey(newGoal.OwnerId) 
                && userIdToProfileMap.get(newGoal.OwnerId).Profile.Name !='XC Account Executive' && userIdToProfileMap.get(newGoal.OwnerId).Profile.Name !='XC Portfolio AE' ){
                system.debug('else condition'+((newGoal.status != 'Draft' && oldGoal.status != 'Published')||(newGoal.status != 'Published' && oldGoal.status != 'Draft')) );   
                if(newGoal.recordtypeId == goalRecordTypIdXfinityCommunities ){  
                    if( !contRegionMgrMap.isEmpty() && contRegionMgrMap.get(newGoal.ownerId).get(oldGoal.Region__c) != Userinfo.getuserId()
                        && ((newGoal.Name != oldGoal.Name) || (newGoal.Assigned_To__c  != oldGoal.Assigned_To__c ) || (newGoal.Description  != oldGoal.Description ) || (newGoal.StartDate != oldGoal.StartDate) || (newGoal.DueDate  != oldGoal.DueDate )
                             ||(newGoal.Profile_Name__c != oldGoal.Profile_Name__c) || (newGoal.status !=oldGoal.status) || (newGoal.Region__c != oldGoal.Region__c) || (newGoal.ImageUrl != oldGoal.ImageUrl) || (newGoal.CompletionDate != oldGoal.CompletionDate) || (newGoal.ownerId != oldGoal.ownerId))){
                        //system.debug('inside If *****' );       
                        newGoal.addError('You cannot change this field value.');
                    }else if(((newGoal.status != 'Draft' || oldGoal.status != 'Published') && (newGoal.status != 'Published' || oldGoal.status != 'Draft') && (newGoal.status != oldGoal.status))
                                || (newGoal.Name != oldGoal.Name) || (newGoal.Assigned_To__c  != oldGoal.Assigned_To__c ) || (newGoal.Description  != oldGoal.Description ) || (newGoal.StartDate != oldGoal.StartDate) || (newGoal.DueDate  != oldGoal.DueDate )
                                ||(newGoal.Profile_Name__c != oldGoal.Profile_Name__c) || (newGoal.Region__c != oldGoal.Region__c) || (newGoal.ImageUrl != oldGoal.ImageUrl) || (newGoal.CompletionDate != oldGoal.CompletionDate) || (newGoal.ownerId != oldGoal.ownerId)){
                        newGoal.addError('You cannot change this field value.');
                        //system.debug('inside else *****' );
                    }
                                   
                }  
            }   
        }
    }
    
    
}