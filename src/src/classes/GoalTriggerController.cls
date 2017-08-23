/******************************************************************************************************************
 * Author     : 
 * Date       : 
 * Description: Contains Supporting actions for Goal Triggers
 
 * @Last Modified By: Animesh Datta
 * @Description: Share Goal/Metric with Manager hirarchy for Indirect
 * @User Story: US1064087 (Indirect - Coach for Indirect - Object Sharing for Goals and Metrics)
 * @Last Modified Date: 04-April-2017  
 ********************************************************************************************************************/

public with sharing class GoalTriggerController{
    private static final string MANAGER_GROUP_SHARING = 'Manager';
    
    /************
    * @Description: This method share Goal/Metric records with manager hierarchy
    * @Author: 
    * @Date: 
    * @Param: newList
    * @Return: void.
    * @Last Modified By: Animesh Datta
    * @Description: Share Goal/Metric with Manager hirarchy for Indirect
    * @User Story: US1064087 (Indirect - Coach for Indirect - Object Sharing for Goals and Metrics)
    * @Last Modified Date: 04-April-2017                 
    **************/
    
    public static void goalSharingMgrGrp(List<Goal> newGoalList){
        try{
            List<GoalShare> goalShareList = new List<GoalShare>();
            List<Goal> goalUpdatedList = new List<Goal>();
            Set<Id> ownerIdSet = new Set<Id>();
            Map<Id, Id> groupMap = new Map<Id, Id>();
            
            Map<String,Schema.RecordTypeInfo> goalRTMapByName = Schema.SObjectType.Goal.getRecordTypeInfosByName();
            String goalTemplateRecordType = goalRTMapByName.get(system.label.Goal_Goal_Template_Recordtype).getRecordTypeId();
            String goalDirectSalesRecordType = goalRTMapByName.get(system.label.GoalDirectSalesRecordType).getRecordTypeId();
            String goalCommunitiesRecordType = goalRTMapByName.get(system.label.CommunitiesGoalRecordType).getRecordTypeId();
            String goalPropertyLabRecordType = goalRTMapByName.get(system.Label.PL_MonthlyGoalCreationBatchGolTempType).getRecordTypeId();
            String goalIndirectRecordTypeId = goalRTMapByName.get(system.Label.Indirect_Record_Type).getRecordTypeId();// Getting Indirect Sales Goal Record Type Id - SP51 - US1064087
            String profilevalue = Label.XC_AE_Contractors;
            
            for(Goal goalTemp : newGoalList){
                if( goalTemp.recordTypeId != goalTemplateRecordType && goalTemp.Profile_Name__c != profilevalue ){              
                    ownerIdSet.add(goalTemp.ownerId);  
                    goalUpdatedList.add(goalTemp);              
                }                      
            }       
                
            if(!ownerIdSet.isEmpty()){
                for(Group groupTemp : [SELECT Id, RelatedId,Type FROM Group 
                                       WHERE Type = : MANAGER_GROUP_SHARING AND RelatedId IN :ownerIdSet 
                                       LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    groupMap.put(groupTemp.RelatedId, groupTemp.Id);
                }
            }
            
            for(Goal goalTemp : goalUpdatedList){
                if(!groupMap.isEmpty() && groupMap.get(goalTemp.ownerId)!=null ){
                    GoalShare goalShareRecord = new GoalShare();
                    goalShareRecord.ParentId = goalTemp.Id;
                    goalShareRecord.userorgroupId = groupMap.get(goalTemp.ownerId); 
                    if(goalTemp.recordTypeId == goalDirectSalesRecordType || goalTemp.recordTypeId == goalIndirectRecordTypeId){ // Adding check for Indirect RecordTypeId - SP51 - US1064087
                        goalShareRecord.AccessLevel = system.label.GoalReadAccess; 
                    }else if(goalTemp.recordTypeId == goalCommunitiesRecordType || goalTemp.recordTypeId == goalPropertyLabRecordType){
                        goalShareRecord.AccessLevel = system.label.GoalEditAccess ;
                    }else{}
                    goalShareRecord.rowCause = Schema.GoalShare.rowCause.Manual;
                    goalShareList.add(goalShareRecord);
                }
            }
            if(!goalShareList.isEmpty()){
                Database.insert(goalShareList, false);
            }
        }catch(Exception ex){system.debug('***Following exception has occurred***'+ex.getMessage());}     
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
        try{
            String profilevalue = Label.XC_AE_Contractors;
            List<GoalShare> goalShareList = new List<GoalShare>();
            Set<String> regionIds = new Set<String>();
            Map<Id, Id> groupMap = new Map<Id, Id>();
            List<Id> ownerIds = new List<Id>();
            List<Goal> contGoalList = new List<Goal>();
            List<Contractor_Region_Mapping__c> contRegMapList = new List<Contractor_Region_Mapping__c>();
            Map<String, String> ownerManagerMap = new Map<String, String>();
           // List<Goal> selectedGoals = [Select Id, region__c, ownerId from Goal where Owner.Profile.Name = :profilevalue And ID IN : newGoalList];
            for(Goal goalRecords: newGoalList ) {
                if(goalRecords.Profile_Name__c == profilevalue){
                    contGoalList.add(goalRecords);
                    ownerIds.add(goalRecords.OwnerId);
                    regionIds.add(goalRecords.Region__c);
                }               
            }
           
            // List to extract the region,active manager and active contractor
            if(!regionIds.isEmpty() && !ownerIds.isEmpty()){
                contRegMapList = [SELECT AE_Contractor__c, Region__c, Reporting_Manager__c FROM  Contractor_Region_Mapping__c where Region__c IN :regionIds and AE_Contractor__c IN : ownerIds AND AE_Contractor__r.Profile.Name = :profilevalue AND Reporting_Manager__r.isActive=TRUE AND AE_Contractor__r.isActive=TRUE LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            }
            
            // Map for Owner and its manager and List to extract the reporting managers of valid regions and users
            for(Contractor_Region_Mapping__c contVar: contRegMapList) {                   
                ownerManagerMap.put(contVar.AE_Contractor__c+contVar.Region__c, contVar.Reporting_Manager__c ); 
            }           
            
            // Map of Owner Manager and their manager hierarchy
            if(ownerManagerMap != null && !ownerManagerMap.isEmpty()){
                for(Group groupTemp : [SELECT Id, RelatedId,Type FROM Group WHERE Type = : MANAGER_GROUP_SHARING AND RelatedId IN :ownerManagerMap.values() LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    groupMap.put(groupTemp.RelatedId, groupTemp.Id);
                }
            }       
            
            
            for(Goal goalTemp : contGoalList) {
                
                // Below loop is for user to manager sharing access
                String ownerIdRegion = goalTemp.ownerId+goalTemp.Region__c;
                if(!ownerManagerMap.isEmpty() && ownerManagerMap.containsKey(ownerIdRegion) ){
                    GoalShare goalShareRecord = new GoalShare();
                    goalShareRecord.ParentId = goalTemp.Id;
                    goalShareRecord.userorgroupId = ownerManagerMap.get(ownerIdRegion); 
                    goalShareRecord.AccessLevel = system.label.GoalEditAccess;                
                    goalShareRecord.rowCause = Schema.GoalShare.rowCause.Manual;
                    goalShareList.add(goalShareRecord);
                }
                
                // Below loop is for manager to manager hierarchy access
                String mngrid = ownerManagerMap.get(ownerIdRegion);
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
        }catch(Exception ex){system.debug('***Following exception has occurred***'+ex.getMessage());}        
    }
        
    /**
    * @Description: This method is to give access to goal object records to Goal's owner manager and its manager hierarchy.
    * US626485 XC Quota: Contractors Quota Visibility
    * @Author: Radhika Bansal, Accenture 
    * @Date: 5-Feb-2016    
    * @Return: void.
    */
        
    public static void updategoalContractorSharingMgrGrp(List<Goal> newList, Map<Id,Goal> oldGoalMap){
        try{
            List<Goal> listGoal = new List<Goal>();
            List<Goal> oldListGoal = new List<Goal>();
            for(Goal g : newList) {
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
        }catch(Exception ex){system.debug('***Following exception has occurred***'+ex.getMessage());}
    }
    
    public static void unshareGoal(List<Goal> goalList){
        try{
            List<goalShare> deleteGoalList =  new List<goalShare>();
            List<Database.DeleteResult> drList = new List<Database.DeleteResult>();
            if(goalList.size() > 0){
                deleteGoalList = [SELECT id FROM GoalShare WHERE parentId IN :goalList LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            }
            
            if(!deleteGoalList.isEmpty()){
                drList = Database.delete(deleteGoalList,false);
            }
            for(Database.DeleteResult dr : drList) {            
                if(!dr.isSuccess()){                                                 
                    for(Database.Error error : dr.getErrors()){
                        System.Debug('Error Fields : '+ error.getFields());
                        System.Debug('Error Message : ' + error.getMessage());
                        System.Debug('Error Status Code : ' + error.getStatusCode());                                                              
                    }
                }
            }
        }catch(Exception ex){system.debug('***Following exception has occurred***'+ex.getMessage());}
    }  

    /**
        * @Description: This method is use to validating the Goal Record for Contractor and his reporting manager
        * US636901 XC Quota: Validation for Contractors AE & Mgr
        * @Author: Tejaswini Kasar, Accenture 
        * @Date: 26-Feb-2016    
        * @Return: void.
        */
        
    public static void aeContractorAndMgrValidation(List<Goal> goalList,Map<Id, Goal> oldgoalMap ){
        try{      
            Set<Id> ownerIdSet = new Set<Id>();
            Map<String,Map<String,String>> contRegionMgrMap = new Map<String,Map<String,String>>();
            String shortProfileId = String.valueOf(UserInfo.getProfileId()).substring(0, 15);       
            String goalRecordTypIdXfinityCommunities = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.CommunitiesGoalRecordType).getRecordTypeId();
            Map<Id,User> userIdToProfileMap;
            
            for(Goal newGoal :goalList ) { 
                if(newGoal.recordtypeId == goalRecordTypIdXfinityCommunities &&  shortProfileId != Label.SystemAdminProfileId){
                    ownerIdSet.add(newGoal.ownerId);
                }   
            }
                   
            if(!ownerIdSet.isEmpty()){
                userIdToProfileMap = new Map<Id,User>([Select Id,Profile.Name from User where Id IN : ownerIdSet]);
                
                //Fetching the Contractor Region Mapping records
                for(Contractor_Region_Mapping__c contRegionMapObj : [ SELECT id, Name, AE_Contractor__c, Region__c, Reporting_Manager__c 
                                                                      FROM Contractor_Region_Mapping__c 
                                                                      WHERE AE_Contractor__c IN :ownerIdSet 
                                                                      LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                                                                                     
                    Map<String,String> regionMgrMapTemp = new Map<String,String>();
                    if(contRegionMgrMap.containsKey(contRegionMapObj.AE_Contractor__c)){
                        regionMgrMapTemp = contRegionMgrMap.get(contRegionMapObj.AE_Contractor__c);
                    }
                    regionMgrMapTemp.put(contRegionMapObj.Region__c, contRegionMapObj.Reporting_Manager__c);
                    contRegionMgrMap.put(contRegionMapObj.AE_Contractor__c, regionMgrMapTemp);              
                }
            }   
            
            for(Goal newGoal :goalList ) { 
                Goal oldGoal = oldgoalMap.get(newGoal.Id);
                
                if( shortProfileId != Label.SystemAdminProfileId && userIdToProfileMap != null && !userIdToProfileMap.isEmpty() 
                    && userIdToProfileMap.containsKey(newGoal.OwnerId) 
                    && userIdToProfileMap.get(newGoal.OwnerId).Profile.Name != Label.Goal_XC_AE 
                    && userIdToProfileMap.get(newGoal.OwnerId).Profile.Name != Label.XC_Portfolio_AE ){
                    //system.debug('else condition'+((newGoal.status != 'Draft' && oldGoal.status != 'Published')||(newGoal.status != 'Published' && oldGoal.status != 'Draft')) );   
                    if(newGoal.recordtypeId == goalRecordTypIdXfinityCommunities ){  
                        if( !contRegionMgrMap.isEmpty() && contRegionMgrMap.get(newGoal.ownerId).get(oldGoal.Region__c) != Userinfo.getuserId() && ((newGoal.Name != oldGoal.Name) || (newGoal.Assigned_To__c  != oldGoal.Assigned_To__c ) || (newGoal.Description  != oldGoal.Description ) || (newGoal.StartDate != oldGoal.StartDate) || (newGoal.DueDate  != oldGoal.DueDate ) || (newGoal.Profile_Name__c != oldGoal.Profile_Name__c) || (newGoal.status !=oldGoal.status) || (newGoal.Region__c != oldGoal.Region__c) || (newGoal.ImageUrl != oldGoal.ImageUrl) || (newGoal.CompletionDate != oldGoal.CompletionDate) || (newGoal.ownerId != oldGoal.ownerId))){
                            newGoal.addError(Label.Goal_Validation_Message);
                        }else if(((newGoal.status != Label.Status_Draft || oldGoal.status != Label.Status_Published) && (newGoal.status != Label.Status_Published || oldGoal.status != Label.Status_Draft) && (newGoal.status != oldGoal.status)) || (newGoal.Name != oldGoal.Name) || (newGoal.Assigned_To__c  != oldGoal.Assigned_To__c ) || (newGoal.Description  != oldGoal.Description ) || (newGoal.StartDate != oldGoal.StartDate) || (newGoal.DueDate  != oldGoal.DueDate ) || (newGoal.Profile_Name__c != oldGoal.Profile_Name__c) || (newGoal.Region__c != oldGoal.Region__c) || (newGoal.ImageUrl != oldGoal.ImageUrl) || (newGoal.CompletionDate != oldGoal.CompletionDate) || (newGoal.ownerId != oldGoal.ownerId)){
                            newGoal.addError(Label.Goal_Validation_Message);
                        }else{}                                   
                    }  
                }   
            }
        }catch(Exception ex){system.debug('***Following exception has occurred****'+ex.getMessage());}
    }  
}