/**This class is created to update the goals bases on change in contractor region mapping
    * US626485 XC Quota: Contractors Quota Visibility
    * @Author: Radhika Bansal, Accenture 
    * @Date: 15-Feb-2016
    * @Last Modify: US1149452: XC - Contractor Roles
    * @Last Modify Date: 24-July-2017
*/ 
public with sharing class ContractorRegionMappingController{
    private static final String MONTH_YEAR_FORMAT = 'MMMM yyyy';
    private static final String HYPHEN_STRING = ' - ';
    /**
    * @Description: This method is to give access to goal object records to Goal's owner manager and its manager hierarchy.
    * US626485 XC Quota: Contractors Quota Visibility
    * @Author: Radhika Bansal, Accenture 
    * @Date: 5-Feb-2016    
    * @Return: void.
    */
    /*public static void goalContractorSharingMgrGrp(List<Contractor_Region_Mapping__c> newContractorList)
    {
        
        List<String> regionList = new List<String>();
        List<Contractor_Region_Mapping__c> contRegMapList = new List<Contractor_Region_Mapping__c>();
        String profilevalue = Label.XC_AE_Contractors;
         
        for(Contractor_Region_Mapping__c c: newContractorList)  
        {
            regionList.add(c.Region__c);
        }
       
        List<GoalShare> goalShareList = new List<GoalShare>();
        Date preStartTemplateDate = null;
        Date preDueTemplateDate = null;
        //Getting the Fiscal Year Date period goal start/due dates            
        GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(System.Label.QM_AnnualBaselineBatchContractorCusSetData);
        if(goalDates != null){          
            preStartTemplateDate = goalDates.Current_Period_Start_Date__c.addYears(-12);
            preDueTemplateDate = goalDates.Current_Period_Due_Date__c;                                            
        }
        //Set<String> regionIds = new Set<String>();
        Map<Id, Id> groupMap = new Map<Id, Id>();
        
        List<Goal> selectedGoals = [Select Id, region__c, ownerId from Goal where Owner.Profile.Name = :profilevalue and Region__c =: regionList AND StartDate >= :preStartTemplateDate and DueDate <= :preDueTemplateDate  ORDER by Startdate ASC];      
       
        
        // Map for Owner and its manager
        Map<String, Id> OwnerManagerMap = new Map<String, Id>();
        for(Contractor_Region_Mapping__c contVar: newContractorList)
        {
            OwnerManagerMap.put(contVar.AE_Contractor__c+contVar.Region__c,contVar.Reporting_Manager__c );                
        }
        
        // Map of Owner Manager and their manager hierarchy
        for(Group groupTemp : [SELECT Id, RelatedId,Type FROM Group WHERE Type = 'Manager' AND RelatedId IN :OwnerManagerMap.values()]){
        groupMap.put(groupTemp.RelatedId, groupTemp.Id);
        }               
        
        // Below loop is for user to manager sharing access
        for(Goal goalTemp : selectedGoals){
            String ownerIdRegion = goalTemp.ownerId+goalTemp.Region__c;
        if(!OwnerManagerMap.isEmpty() && OwnerManagerMap.get(ownerIdRegion)!=null ){
                GoalShare goalShareRecord = new GoalShare();
                goalShareRecord.ParentId = goalTemp.Id;
                goalShareRecord.userorgroupId = OwnerManagerMap.get(ownerIdRegion); 
                goalShareRecord.AccessLevel = system.label.GoalEditAccess;                
                goalShareRecord.rowCause = Schema.GoalShare.rowCause.Manual;
                goalShareList.add(goalShareRecord);
            }
       
        String mngrid = OwnerManagerMap.get(ownerIdRegion);     
        if(mngrid != null && mngrid != '' && !groupMap.isEmpty() && groupMap.get(mngrid)!=null ){
            GoalShare goalShareRecord = new GoalShare();
            goalShareRecord.ParentId = goalTemp.Id;
            goalShareRecord.userorgroupId = groupMap.get(mngrid); 
            goalShareRecord.AccessLevel = system.label.GoalEditAccess;                
            goalShareRecord.rowCause = Schema.GoalShare.rowCause.Manual;
            goalShareList.add(goalShareRecord);
            }        
        }
        if(!goalShareList.isEmpty()){
            Database.insert(goalShareList, false);
        }        
    }*/
        
    /**
    * @Description: This method is to update goal object records to Goal's owner manager and its manager hierarchy.
    * US626485 XC Quota: Contractors Quota Visibility
    * @Author: Radhika Bansal, Accenture 
    * @Date: 15-Feb-2016    
    * @Return: void.
    */
    public static void updategoalContractorSharingMgrGrp(List<Contractor_Region_Mapping__c > newCRMList, Map<Id,Contractor_Region_Mapping__c> oldCRMMap){
        List<Contractor_Region_Mapping__c> contractorList = new List<Contractor_Region_Mapping__c>();
        Set<String> regionSet = new Set<String>();
        Set<String> aeContIdSet = new Set<String>();                
        List<Goal> goalList = new List<Goal>();
        Map<String, List<Goal>> contRegionIdGoalListMap = new Map<String, List<Goal>>();
        List<Contractor_Region_Mapping__c> cRMList = new List<Contractor_Region_Mapping__c>();
        List<GoalShare> goalShareList = new List<GoalShare>();
        Date preStartTemplateDate = null;
        Date preDueTemplateDate = null;
        //Map for Owner and its manager
        Map<String, Id> OwnerManagerMap = new Map<String, Id>();        
        Map<Id, Id> groupMap = new Map<Id, Id>();
        
        
        //Getting the Fiscal Year Date period goal start/due dates            
        GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(System.Label.QM_AnnualBaselineBatchContractorCusSetData);
        if(goalDates != null){          
            preStartTemplateDate = goalDates.Current_Period_Start_Date__c.addYears(-12);
            preDueTemplateDate = goalDates.Current_Period_Due_Date__c;                                            
        }
        
        for(Contractor_Region_Mapping__c crmObj : newCRMList){
            if(crmObj.Reporting_Manager__c != oldCRMMap.get(crmObj.id).Reporting_Manager__c && crmObj.Reporting_Manager__c != null){
                contractorList.add(crmObj);               
                aeContIdSet.add(crmObj.AE_Contractor__c);                           
                regionSet.add(oldCRMMap.get(crmObj.id).Region__c);
                OwnerManagerMap.put(crmObj.AE_Contractor__c+crmObj.Region__c, crmObj.Reporting_Manager__c );                
            }
        }
        
        //Fetching Goals of Contractor for current Fiscal Year
        if(!aeContIdSet.isEmpty() && !regionSet.isEmpty() && preStartTemplateDate != null && preDueTemplateDate != null){
            goalList = [SELECT Id, ownerId, Region__c FROM Goal WHERE Region__c IN:regionSet AND ownerId IN:aeContIdSet AND StartDate >= :preStartTemplateDate
                                    AND DueDate <= :preDueTemplateDate];
        }
        
        //Unsharing the records for old manager
        if(!goalList.isEmpty()){
            unshareGoaloncontractor(goalList);        
        }
        
        // Map of Owner Manager and their manager hierarchy
        for(Group groupTemp : [SELECT Id, RelatedId, Type FROM Group WHERE Type = 'Manager' AND RelatedId IN :OwnerManagerMap.values()]){
            groupMap.put(groupTemp.RelatedId, groupTemp.Id);
        }               
        
        // Below loop is for user to manager sharing access
        for(Goal goalTemp : goalList){
            String ownerIdRegion = goalTemp.ownerId+goalTemp.Region__c;
            if(!OwnerManagerMap.isEmpty() && OwnerManagerMap.get(ownerIdRegion)!=null){
                GoalShare goalShareRecord = new GoalShare();
                goalShareRecord.ParentId = goalTemp.Id;
                goalShareRecord.userorgroupId = OwnerManagerMap.get(ownerIdRegion); 
                goalShareRecord.AccessLevel = system.label.GoalEditAccess;                
                goalShareRecord.rowCause = Schema.GoalShare.rowCause.Manual;
                goalShareList.add(goalShareRecord);
            }
       
            String mngrid = OwnerManagerMap.get(ownerIdRegion);     
            if(mngrid != null && mngrid != '' && !groupMap.isEmpty() && groupMap.get(mngrid)!=null){
                GoalShare goalShareRecord = new GoalShare();
                goalShareRecord.ParentId = goalTemp.Id;
                goalShareRecord.userorgroupId = groupMap.get(mngrid); 
                goalShareRecord.AccessLevel = system.label.GoalEditAccess;                
                goalShareRecord.rowCause = Schema.GoalShare.rowCause.Manual;
                goalShareList.add(goalShareRecord);
            }        
        }
        //Inserting sharing records with updated manager
        if(!goalShareList.isEmpty()){
            Database.insert(goalShareList, false);
        }
        
    }
     
     /**
    * @Description: This method is to update goal object records to Goal's owner manager and its manager hierarchy when a contractor regional 
    * mapping record is deleted.
    * US626485 XC Quota: Contractors Quota Visibility
    * @Author: Radhika Bansal, Accenture 
    * @Date: 15-Feb-2016    
    * @Return: void.
    */
     public static void updategoalContractorSharingMgrGrpOnDelete(List<Contractor_Region_Mapping__c> oldList){
        
        List<Goal> goalList = new List<Goal>();
        Set<String> regionSet = new Set<String>();
        Set<String> aeContIdSet = new Set<String>();
        Set<String> mgrIdSet = new Set<String>();
        Date preStartTemplateDate = null;
        Date preDueTemplateDate = null;
        //Getting the Fiscal Year Date period goal start/due dates            
        GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(System.Label.QM_AnnualBaselineBatchContractorCusSetData);
        if(goalDates != null){          
            preStartTemplateDate = goalDates.Current_Period_Start_Date__c.addYears(-12);
            preDueTemplateDate = goalDates.Current_Period_Due_Date__c;                                            
        }    
        
        for(Contractor_Region_Mapping__c crmObj : oldList){
            regionSet.add(crmObj.Region__c);
            aeContIdSet.add(crmObj.AE_Contractor__c);
            mgrIdSet.add(crmObj.Reporting_Manager__c);
        }
        
        //Fetching Goals and Metrics of Contractor for current Fiscal Year
        if(!aeContIdSet.isEmpty() && !regionSet.isEmpty() && preStartTemplateDate != null && preDueTemplateDate != null){       
            goalList = [SELECT Id FROM Goal WHERE OwnerId IN:aeContIdSet AND Region__c IN:regionSet AND
                            StartDate >=: preStartTemplateDate AND DueDate <=: preDueTemplateDate];
        }
        
        if(!goalList.isEmpty()){
            unshareGoaloncontractor(goalList);
        }   
    }
     
     
    /**
    * @Description: This method is to delete goal object records to Goal's owner manager and its manager hierarchy.
    * US626485 XC Quota: Contractors Quota Visibility
    * @Author: Radhika Bansal, Accenture 
    * @Date: 15-Feb-2016    
    * @Return: void.
    */
    public static void unshareGoaloncontractor(List<Goal> goalList){
        List<goalShare> deleteGoalList =  new List<goalShare>();
        List<Database.DeleteResult> drList = new List<Database.DeleteResult>();
        if(goalList.size() > 0){
            deleteGoalList = [SELECT id FROM GoalShare WHERE ParentId IN :goalList];
        }
        //deleting the sharing record for old mananger
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
    * US745492-SalesSpace Communities: Opportunity Edit access for 'AE Contractor' Managers
    * @Author:Shivani Gautam, Accenture 
    * @Date: 9-Aug-2016    
    * @Return: void.
    * Descrition : Returns list of Opportunities assigned to the AE Contractor and its related Contractor region Mapping
    */
    public static void oppContractorSharingMgrGrp(List<Contractor_Region_Mapping__c> newContRegList)
       {
         List<Opportunity> oppList = new List<Opportunity>();
         List<OpportunityShare> oppShareList = new List<OpportunityShare>();
         Set<String>contractorString = new Set<String>();
         Map<String,List<String>> OwnerManagerMap = new Map<String,List<String>>();
         
          for(Contractor_Region_Mapping__c contVar: newContRegList)
            {       
                List<String> tempString = new List<String>();
                if(OwnerManagerMap.containsKey(contVar.AE_Contractor__c)){
                    tempString = OwnerManagerMap.get(contVar.AE_Contractor__c);
                }
                tempString.add(contVar.Reporting_Manager__c);
                OwnerManagerMap.put(contVar.AE_Contractor__c,tempString);                               
            }
         
         oppList =[SELECT id,AssignedAE_ID__c from Opportunity where AssignedAE_ID__c IN :OwnerManagerMap.keySet()];       
                
         // Below loop is for manager sharing access
            for(Opportunity oppTemp : oppList){
                if(!OwnerManagerMap.isEmpty() && OwnerManagerMap.get(oppTemp.AssignedAE_ID__c)!=null ){
                    List<String> mgrString = OwnerManagerMap.get(oppTemp.AssignedAE_ID__c);
                    for(String mgr : mgrString){
                        OpportunityShare oppShareRecord = new OpportunityShare();
                        oppShareRecord.OpportunityId = oppTemp.Id;
                        oppShareRecord.userorgroupId = mgr; 
                        oppShareRecord.OpportunityAccessLevel = system.label.OpportunityEditAccess;                
                        oppShareRecord.rowCause = Schema.OpportunityShare.rowCause.Manual;
                        oppShareList.add(oppShareRecord);
                    }   
                }
            }
        Database.insert(oppShareList,false);
      }
     
     /**
    * US745492-SalesSpace Communities: Opportunity Edit access for 'AE Contractor' Managers
    * @Author:Shivani Gautam, Accenture 
    * @Date: 9-Aug-2016    
    * @Return: void.
    * Descrition : This method is used to update the opportunity sharing 
                   whenever any change is made in the Contractor region mapping for the Assigned AE.
    */
    public static void updateOppContShareMgrGrp(Map<Id,Contractor_Region_Mapping__c> oldContRegMap,List<Contractor_Region_Mapping__c> newContRegList){  

        Set<String> oppIdSet = new Set<String>();
        Set<String> mgrIdSet = new Set<String>();
        Set<String> aeIdSet = new Set<String>();
        List<Contractor_Region_Mapping__c> newContRegListToUpdate = new List<Contractor_Region_Mapping__c>();
        for(Contractor_Region_Mapping__c conRegMapObj : newContRegList){
            if((conRegMapObj.Reporting_Manager__c != oldContRegMap.get(conRegMapObj.Id).Reporting_Manager__c) 
               || (conRegMapObj.AE_Contractor__c != oldContRegMap.get(conRegMapObj.Id).AE_Contractor__c)){               
                mgrIdSet.add(oldContRegMap.get(conRegMapObj.Id).Reporting_Manager__c);
                aeIdSet.add(oldContRegMap.get(conRegMapObj.Id).AE_Contractor__c);
                newContRegListToUpdate.add(conRegMapObj);
           }
        }
       
        for(Opportunity oppObj :[SELECT id,AssignedAE_ID__c from Opportunity where AssignedAE_ID__c IN :aeIdSet]){
            oppIdSet.add(oppObj.Id);
        }
        
        List<OpportunityShare> deleteAllOppShare = [SELECT Id,OpportunityId,RowCause,UserOrGroupId FROM OpportunityShare WHERE OpportunityId IN : oppIdSet AND RowCause =:'manual' AND userorgroupId IN :mgrIdSet ];
        
        If(!deleteAllOppShare.isEmpty()){
            database.delete(deleteAllOppShare,false);
        }
        if(!newContRegListToUpdate.isEmpty()){
            oppContractorSharingMgrGrp(newContRegListToUpdate);
        }
    }
    
     /**
    * US745492-SalesSpace Communities: Opportunity Edit access for 'AE Contractor' Managers
    * @Author:Shivani Gautam, Accenture 
    * @Date: 9-Aug-2016    
    * @Return: void.
    * Descrition : This method is deletes the opportunity sharing 
                   whenever any change is made in the Contractor region mapping for the Assigned AE.
    */
    public static void deleteOppContShareMgrGrp(List<Contractor_Region_Mapping__c> oldContRegList)
    {
        Set<String> oppIdSet = new Set<String>();
        Set<String> mgrIdSet = new Set<String>();
        Set<String> aeIdSet = new Set<String>();
        List<Contractor_Region_Mapping__c> newContRegListToUpdate = new List<Contractor_Region_Mapping__c>();
        for(Contractor_Region_Mapping__c conRegMapObj : oldContRegList){                            
            mgrIdSet.add(conRegMapObj.Reporting_Manager__c);
            aeIdSet.add(conRegMapObj.AE_Contractor__c);
        }
        
        for(Opportunity oppObj :[SELECT id,AssignedAE_ID__c from Opportunity where AssignedAE_ID__c IN :aeIdSet]){
            oppIdSet.add(oppObj.Id);
        }
        
        List<OpportunityShare> deleteAllOppShare = [SELECT Id,OpportunityId,RowCause,UserOrGroupId FROM OpportunityShare WHERE OpportunityId IN : oppIdSet AND RowCause =:'manual' AND userorgroupId IN :mgrIdSet ];
        If(!deleteAllOppShare.isEmpty()){
            database.delete(deleteAllOppShare,false);
        }
    }
    
    
    /**    
    *@Description: Updating "Reporting Manager" field of Goal(from next fisical month) record if Reporing manager changes in CRM record 
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 19-Oct-2016   
    * @User Story: US814546     
    * @Return: None    
    */  
    public static void updateReportingMgrForGoal(Map<Id,Contractor_Region_Mapping__c> oldContRegMap,List<Contractor_Region_Mapping__c> newContRegList){
             
        Map<String,Contractor_Region_Mapping__c> contAEIdCRMMap = new Map<String,Contractor_Region_Mapping__c>();
        Set<String> regionSet = new Set<String>();
        List<Goal> goalToUpdateList = new List<Goal>();
        Map<String,String> contAEReportingMgrMap = new Map<String,String>();   
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
        
        
        for(Contractor_Region_Mapping__c conRegMapObj : newContRegList){
            if((conRegMapObj.Reporting_Manager__c != oldContRegMap.get(conRegMapObj.Id).Reporting_Manager__c) 
                    || (conRegMapObj.AE_Contractor__c != oldContRegMap.get(conRegMapObj.Id).AE_Contractor__c)){ 
                
                contAEIdCRMMap.put(conRegMapObj.AE_Contractor__c,conRegMapObj);
                regionSet.add(oldContRegMap.get(conRegMapObj.Id).Region__c);
                contAEReportingMgrMap.put(conRegMapObj.AE_Contractor__c+oldContRegMap.get(conRegMapObj.Id).Region__c, conRegMapObj.Reporting_Manager__c);                
            }
        }
        
        //Fetching the Goals from next fisical month
        for(Goal goalObj: [SELECT Id, OwnerId, Owner.Name, Region__c, Reporting_Manager__c, DueDate FROM Goal WHERE OwnerId IN:contAEIdCRMMap.keySet() AND Region__c IN: regionSet 
                           AND RecordTypeId =:XfinityCommunitiesRecordTypeId AND StartDate >=: preGoalStartDate AND DueDate <: dueTemplateDate]){
            String contANDRegionString = null;            
            DateTime goalDueDate = goalObj.DueDate;
            if(goalObj.Region__c != null){
                contANDRegionString = goalObj.OwnerId+goalObj.Region__c;
            }
            
            if(contANDRegionString != null && !contAEReportingMgrMap.isEmpty() && contAEReportingMgrMap.containsKey(contANDRegionString) 
                        && !contAEIdCRMMap.isEmpty() && contAEIdCRMMap.containsKey(goalObj.OwnerId)){
                            
                goalObj.Reporting_Manager__c = contAEReportingMgrMap.get(contANDRegionString);
                goalObj.Region__c = contAEIdCRMMap.get(goalObj.OwnerId).Region__c;
                goalObj.Name = goalObj.Owner.Name + HYPHEN_STRING+contAEIdCRMMap.get(goalObj.OwnerId).Region__c+HYPHEN_STRING+goalDueDate.formatGMT(MONTH_YEAR_FORMAT);
                goalToUpdateList.add(goalObj);
            }
        }
        //Updating the Goals
        if(!goalToUpdateList.isEmpty()){
            database.update(goalToUpdateList,false);
        }
    } 
    
    /**
    * @UserStrory : US1149452 XC - Contractor Roles
    * @Description  : Method to share XC AE Contactor with Regional Public group based on
    *                Contractor Region Mapping records.
    * @Author : Suchita Sharma
    * @Date   : 24-July-2017
    * @Return : void
    */
    @future
    public static void contractorPublicGrpAssignment(String triggerNewjsonString){
      try{
           //deserialize the JSON to the Contractor Region Mapping List
      		List<Contractor_Region_Mapping__c> newContRegList= (List<Contractor_Region_Mapping__c>)Json.deserialize(triggerNewjsonString,List<Contractor_Region_Mapping__c>.class);
            Map<String,Id> regionGroupMap = new Map<String,Id>();
            List<PublicGroupRegion__c> publicGroupRegionList = PublicGroupRegion__c.getall().values();
            List<GroupMember> grpMemberlist = new List<GroupMember>();
            //Adding region and regional group to a Map
            for(PublicGroupRegion__c pg : publicGroupRegionList){
                regionGroupMap.put(pg.Name,pg.GroupId__c);
            }
            //Assigning XC AE contractor to Regional Public Group
            for(Contractor_Region_Mapping__c crm : newContRegList) {
                if(RegionGroupMap.get(crm.Region__c) != null) {
                    //Creating GroupMember Record
                    GroupMember grpMember= new GroupMember();
                    grpMember.GroupId = regionGroupMap.get(crm.Region__c);
                    grpMember.UserOrGroupId = crm.AE_Contractor__c;
                    grpMemberlist.add(grpMember);         
                }
            }
            if(!grpMemberlist.isEmpty()){                
                //Insert group member
                Database.insert(grpMemberlist,false);                
            }
        }catch(Exception e){
            System.debug('Exception has occured'+e);
        }  
    }
    
    /**
    * @UserStrory : US1149452 XC - Contractor Roles
    * @Description  : Method to remove share XC AE Contactor with Regional Public group when
    *                Contractor Region Mapping records deleted.
    * @Author : Suchita Sharma
    * @Date   : 24-July-2017
    * @Return : void
    */
    @future
    public static void contractorPublicGrpAssignmentRemoval(String triggerOldjsonString){
      try{
            Set<ID> contractorSet = new Set<ID>();
            Set<ID> crmIdSet = new Set<ID>();
            List<GroupMember> existingGroupMememberList;
            List<Contractor_Region_Mapping__c> currentContRegList;
            //deserialize the JSON to the Contractor Region Mapping List
           	List<Contractor_Region_Mapping__c> oldContRegList = (List<Contractor_Region_Mapping__c>)Json.deserialize(triggerOldjsonString,List<Contractor_Region_Mapping__c>.class);
            for(Contractor_Region_Mapping__c crm :  oldContRegList){
	             contractorSet.add(crm.AE_Contractor__c);
	             crmIdSet.add(crm.id);
            }
			
			if(!contractorSet.isEmpty()){
				existingGroupMememberList = [SELECT id, GroupId, UserOrGroupId from GroupMember where UserOrGroupId in : contractorSet  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
			}
			
            if(!existingGroupMememberList.isEmpty()){
                //Delete group member
                database.delete(existingGroupMememberList,false);
            }
            if(!crmIdSet.isEmpty()){
				currentContRegList = [SELECT id, AE_Contractor__c ,Region__c FROM Contractor_Region_Mapping__c WHERE AE_Contractor__c in :contractorSet            														        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
			}
			
            if(!currentContRegList.isEmpty()){	           
				Map<String,Id> regionGroupMap = new Map<String,Id>();
				List<PublicGroupRegion__c> publicGroupRegionList = PublicGroupRegion__c.getall().values();
				List<GroupMember> grpMemberlist = new List<GroupMember>();
				//Adding region and regional group to a Map
				for(PublicGroupRegion__c pg : publicGroupRegionList){
					regionGroupMap.put(pg.Name,pg.GroupId__c);
				}
				//Assigning XC AE contractor to Regional Public Group
				for(Contractor_Region_Mapping__c crm : currentContRegList) {
					if(RegionGroupMap.get(crm.Region__c) != null) {
						//Creating GroupMember Record
						GroupMember grpMember= new GroupMember();
						grpMember.GroupId = regionGroupMap.get(crm.Region__c);
						grpMember.UserOrGroupId = crm.AE_Contractor__c;
						grpMemberlist.add(grpMember);         
					}
				}
				if(!grpMemberlist.isEmpty()){                
					//Insert group member
					Database.insert(grpMemberlist,false);                
				}
            }
        }catch(Exception e){
            System.debug('Exception has occured'+e);
        }
    }
    /**
    * @UserStrory : US1149452 XC - Contractor Roles
    * @Description  : Method to remove share XC AE Contactor with Regional Public group when
    *                Contractor Region Mapping records is updated.
    * @Author : Suchita Sharma
    * @Date   : 24-July-2017
    * @Return : void
    */    
    public static void contractorPublicGrpAssignmentRecalculate(Map<Id,Contractor_Region_Mapping__c> oldMap,Map<id,Contractor_Region_Mapping__c> newMap){
      try{ 
        
        Set<Id> contratorSET = new Set<Id>();
        
        for(Contractor_Region_Mapping__c crm: newMap.values()){
            if(crm.AE_Contractor__c != oldMap.get(crm.Id).AE_Contractor__c || crm.Region__c!= oldMap.get(crm.Id).Region__c){
               contratorSET.add(crm.AE_Contractor__c);
               contratorSET.add(oldMap.get(crm.Id).AE_Contractor__c);
            }
        }   
        if(!contratorSET.isEmpty()){
	        List<Contractor_Region_Mapping__c> currentContRegList = [SELECT id, AE_Contractor__c ,Region__c FROM Contractor_Region_Mapping__c WHERE AE_Contractor__c in :contratorSET
	        														         LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];			
			if(!currentContRegList.isEmpty()){
				currentContRegList.add(oldMap.values());
			}
	        
	        String currentContractorCRM = json.serialize(currentContRegList);
	        contractorPublicGrpAssignmentRemoval(currentContractorCRM);
		}
        }catch(Exception e){
            System.debug('Exception has occured'+e);
        }
    }    
}