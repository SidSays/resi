public class MetricTriggerOperations{
 private static final string System_Administrator = 'System Administrator';
 
    public static void metricPermissionValidation() {
        
        String ProfileidsystemAdmin;
        String metricRecordTypIdCompletion = Schema.SObjectType.Metric.getRecordTypeInfosByName().get(System.Label.MetricCompletion).getRecordTypeId();
        String metricRecordTypIdProgress = Schema.SObjectType.Metric.getRecordTypeInfosByName().get(System.Label.MetricProgress).getRecordTypeId();
        String goalRecordTypIdDirectSales = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Direct Sales').getRecordTypeId();
        String goalRecordTypIdXfinityCommunities = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
        String goalRecordTypIdPropertyLab = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Property Lab').getRecordTypeId();
        
        Id profileid = Userinfo.getProfileId();
        ProfileidsystemAdmin = [select Id from Profile where Name = : System_Administrator limit 1].Id;
        String profileName = [select Id,Name from Profile where Id = : profileid limit 1].Name;
        Map<Id,Id> goalIdRecordTypeIdMap = new Map<Id,Id>();
        Map<Id,Id> goalManagerIdMap = new Map<Id,Id>();
        Set<Id> goalIdSet = new Set<Id>();
        Set<Id> ownerIdSet = new Set<Id>();
        List<Metric> metricList = Trigger.New;
        for(Metric newMetric :metricList ){
            Metric oldMetric = (Metric)Trigger.oldMap.get(newMetric.Id);
            goalIdSet.add(oldMetric.goalId);
            ownerIdSet.add(oldMetric.OwnerId);
        }
        
        for(User usr : [select Id, ManagerId from user where Id IN :ownerIdSet]){
            goalManagerIdMap.put(usr.Id, usr.ManagerId);
        }
        for(Goal newGoal : [select Id, recordtypeId from Goal where Id IN :goalIdSet]){
            goalIdRecordTypeIdMap.put(newGoal.Id, newGoal.recordtypeId);
        } 
         
         
        for(Metric newMetric : metricList ){
            Metric oldMetric = (Metric)Trigger.oldMap.get(newMetric.Id);
            if((newMetric.RecordtypeId == metricRecordTypIdCompletion || newMetric.RecordtypeId == metricRecordTypIdProgress )
                && ((oldMetric.Name !=newMetric.Name || oldMetric.TargetValue !=newMetric.TargetValue || oldMetric.CurrentValue !=newMetric.CurrentValue || oldMetric.Status !=newMetric.Status )
                    &&(profileid == Label.DSMProfileIdLabel || profileid == Label.DirectSaleReprProfId || profileid == Label.DSSProfileIdLabel || profileid == Label.DirectorProfileIdLabel)))

                {
                  newMetric.addError(Label.MetricFieldValidationErrorMsg1); 
                }
            
            else if(( goalIdRecordTypeIdMap.get(newMetric.goalId) == goalRecordTypIdDirectSales &&(newMetric.RecordtypeId == metricRecordTypIdCompletion || newMetric.RecordtypeId == metricRecordTypIdProgress ))
                && (profileid == Label.DSMProfileIdLabel || profileid == Label.DirectSaleReprProfId || profileid == Label.DSSProfileIdLabel || profileid == Label.RSAProfileIdLabel || profileid == Label.DirectorProfileIdLabel))

                {
                  newMetric.addError(Label.MetricFieldValidationErrorMsg2); 
                      /**
        * @Description:  Retail Sales Rep or Retail Sales Manager should not edit Metrics or through the UI
        * US1024503 Indirect - Coach for Indirect - Metrics - Page Layout and Validation
        * @Author: Kiran Kumar
        * @Date: 24-Mar-2016    
          */ 
          //<US1024503> Starts
            }
              else if((Label.Indirect_Sales_Profiles).touppercase().contains(ProfileName.touppercase()) ){
                    newMetric.addError(Label.MetricFieldValidationErrorMsg1); 
                    //<US1024503> Ends
                }
                
                if( profileid != ProfileidsystemAdmin){
                    
                    if( (UserInfo.getUserId()==oldMetric.OwnerId)&&(goalIdRecordTypeIdMap.get(oldMetric.goalId) == goalRecordTypIdXfinityCommunities || goalIdRecordTypeIdMap.get(oldMetric.goalId) == goalRecordTypIdPropertyLab)&&( (oldMetric.OwnerId!=newMetric.OwnerId)||(oldMetric.goalId!=newMetric.goalId)||(oldMetric.Description!=newMetric.Description)||(oldMetric.Name!=newMetric.Name) ||(oldMetric.CurrentValue!=newMetric.CurrentValue) || (oldMetric.DueDate!=newMetric.DueDate) || (oldMetric.Sort_Order__c!=newMetric.Sort_Order__c) || (oldMetric.InitialValue!=newMetric.InitialValue) || (oldMetric.Status!=newMetric.Status) || (oldMetric.LastComment!=newMetric.LastComment))){
                        newMetric.addError(Label.MetricFieldValidationErrorMsg1);
                       
                       }
                      
                    if( (UserInfo.getUserId()==goalManagerIdMap.get(oldMetric.OwnerId))&&(goalIdRecordTypeIdMap.get(oldMetric.goalId) == goalRecordTypIdXfinityCommunities || goalIdRecordTypeIdMap.get(oldMetric.goalId) == goalRecordTypIdPropertyLab)&&( (oldMetric.OwnerId!=newMetric.OwnerId)||(oldMetric.goalId!=newMetric.goalId)||(oldMetric.Name!=newMetric.Name) ||(oldMetric.CurrentValue!=newMetric.CurrentValue) || (oldMetric.DueDate!=newMetric.DueDate) || (oldMetric.Sort_Order__c!=newMetric.Sort_Order__c) || (oldMetric.InitialValue!=newMetric.InitialValue) || (oldMetric.LastComment!=newMetric.LastComment))){
                        newMetric.addError(Label.MetricFieldValidationErrorMsg1);
                       
                       }
                    if( (UserInfo.getUserId() != goalManagerIdMap.get(oldMetric.OwnerId)
                            || (UserInfo.getUserId()!=oldMetric.OwnerId))
                            && ((goalIdRecordTypeIdMap.get(oldMetric.goalId) == goalRecordTypIdXfinityCommunities || goalIdRecordTypeIdMap.get(oldMetric.goalId) == goalRecordTypIdPropertyLab) )
                            && (oldMetric.TargetValue == newMetric.TargetValue || oldMetric.TargetValue != newMetric.TargetValue ) 
                            && ( (oldMetric.OwnerId!=newMetric.OwnerId) || (oldMetric.goalId!=newMetric.goalId)||(oldMetric.Name!=newMetric.Name)
                            ||(oldMetric.CurrentValue!=newMetric.CurrentValue) || (oldMetric.DueDate!=newMetric.DueDate)
                            || (oldMetric.Sort_Order__c!=newMetric.Sort_Order__c) || (oldMetric.InitialValue!=newMetric.InitialValue)
                            || (oldMetric.LastComment!=newMetric.LastComment)))
                       {
                      
                        newMetric.addError(Label.MetricFieldValidationErrorMsg1);
                       }
                }
         }
    }
    
    
    /**
        * @Description: This method is use to validating the Metric Record for Contractor and his reporting manager
        * US636901 XC Quota: Validation for Contractors AE & Mgr
        * @Author: Tejaswini Kasar, Accenture 
        * @Date: 26-Feb-2016    
        * @Return: void.
        */
    public static void aeContractorAndMgrValidation(){
        String ProfileidsystemAdmin = [select Id from Profile where Name = : System_Administrator limit 1].Id;
        Id profileid = Userinfo.getProfileId();
        List<Metric> metricList = Trigger.New;                
        Set<Id> ownerIdSet = new Set<Id>();
        Map<Id, Goal> goalIdGoalMap = new Map<Id, Goal>();
        Map<String,Map<String,String>> contRegionMgrMap = new Map<String,Map<String,String>>();
        
        String goalRecordTypIdXfinityCommunities = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
        
        for(Metric newMetric :metricList ){ 
            Metric oldMetric = (Metric)Trigger.oldMap.get(newMetric.Id); 
            ownerIdSet.add(oldMetric.ownerId);
                
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
      
       
        for(Goal goalObj : [SELECT ID, Name,RecordTypeId, Region__c FROM Goal where ownerId IN : ownerIdSet]){
            goalIdGoalMap.put(goalObj.Id, goalObj);
        }
        
        for(Metric newMetric :metricList ){ 
            Metric oldMetric = (Metric)Trigger.oldMap.get(newMetric.Id); 
            
            if(profileid != ProfileidsystemAdmin && !userIdToProfileMap.isEmpty() && userIdToProfileMap.containsKey(oldMetric.OwnerId) 
                && userIdToProfileMap.get(oldMetric.OwnerId).Profile.Name =='XC AE Contractors' ){
               
                  
                    if(( !goalIdGoalMap.isEmpty() && goalIdGoalMap.containsKey(newMetric.GoalId) && goalIdGoalMap.get(newMetric.GoalId).RecordTypeId == goalRecordTypIdXfinityCommunities )
                        && !contRegionMgrMap.isEmpty()&& ( Userinfo.getuserId() != contRegionMgrMap.get(oldMetric.ownerId).get(goalIdGoalMap.get(newMetric.GoalId).Region__c))
                        &&( (oldMetric.TargetValue!=newMetric.TargetValue) ||(oldMetric.OwnerId!=newMetric.OwnerId)||(oldMetric.goalId!=newMetric.goalId)||(oldMetric.Name!=newMetric.Name) ||(oldMetric.CurrentValue!=newMetric.CurrentValue) || (oldMetric.DueDate!=newMetric.DueDate) || (oldMetric.Sort_Order__c!=newMetric.Sort_Order__c) || (oldMetric.InitialValue!=newMetric.InitialValue) || (oldMetric.Status!=newMetric.Status) || (oldMetric.LastComment!=newMetric.LastComment))) {
                        newMetric.addError(Label.MetricFieldValidationErrorMsg1);
                        
                    }else if((oldMetric.OwnerId!=newMetric.OwnerId)||(oldMetric.goalId!=newMetric.goalId)||(oldMetric.Name!=newMetric.Name) ||(oldMetric.CurrentValue!=newMetric.CurrentValue) || (oldMetric.DueDate!=newMetric.DueDate) || (oldMetric.Sort_Order__c!=newMetric.Sort_Order__c) || (oldMetric.InitialValue!=newMetric.InitialValue) || (oldMetric.Status!=newMetric.Status) || (oldMetric.LastComment!=newMetric.LastComment)){
                        newMetric.addError(Label.MetricFieldValidationErrorMsg1);
                        
                    }
                    
                
            }
        }
                
    }
    
       
}