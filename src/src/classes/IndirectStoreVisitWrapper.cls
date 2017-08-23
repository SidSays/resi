/** 
*Controller for IndirectStoreVisitHistory Lightning Component
* @Author Ashish Srivastava
*/
public with sharing class IndirectStoreVisitWrapper{
    
    @AuraEnabled
    public Store_Visit__c stv {get;set;}
    
    @AuraEnabled
    public Boolean check {get;set;}
    
    @AuraEnabled
    public Boolean onRepeat {get;set;}
    
    @AuraEnabled
    public Boolean checkActivity {get;set;}
    
    @AuraEnabled
    public Boolean onRepeatActivity {get;set;}
    
    @AuraEnabled
    public Integer activityCount {get;set;}
    
   // public static Map<String, Schema.RecordTypeInfo> activityRTMap = Schema.SObjectType.Store_Activity__c.RecordTypeInfosByName;
    
    @AuraEnabled
    //method to retrieve list of objects for Store Visits
    public static List<IndirectStoreVisitWrapper> getStoreVisits(Id storeId){
        Id userId = UserInfo.getUserId();
        List<IndirectStoreVisitWrapper> visitList = new List<IndirectStoreVisitWrapper>();
        List<Store_Visit__c> storeVisitList = [SELECT Id,Number_of_Completed_Activities__c,                                               
                                               Store_Visit_Name__c, Notes__c, Total_Activities__c,
                                               Store_Visit_Status__c, Owner.Name, Start_Date_Time__c, Time_Spent__c 
                                               FROM Store_Visit__c WHERE Store__c = :storeId AND OwnerId = :userId 
                                               AND Completed_Formula__c = TRUE ORDER BY CreatedDate DESC];        
        
        for(Store_Visit__c sv : storeVisitList){
            
            Integer completedActivities;
            IndirectStoreVisitWrapper obj = new IndirectStoreVisitWrapper();
            obj.check = false;
            obj.onRepeat = false;
            obj.checkActivity = false;
            obj.onRepeatActivity = false;
            obj.stv = sv;
            visitList.add(obj);
        }
        return visitList;
    }
    
    @AuraEnabled
    //method to get Activity Details
    public static Store_Activity__c getActivityDetails(String storevisitCategoryRecordId, Id storeVisitId){
      //  Id recordTypeId = activityRTMap.get(storevisitCategoryRTName).getRecordTypeId();      
        List<Store_Activity__c> obj =  [Select Id, Name,Store_Visit__c,RecordTypeId,
                                        RecordType.Name,RecordType.DeveloperName, Store_Type__c 
                                        from Store_Activity__c where Store_Visit__c = :storeVisitId
                                        AND recordTypeId = :storevisitCategoryRecordId AND
                                        Is_Activity_Completed__c = true LIMIT 1];        
        
        if(obj.size() != 0){            
            return obj[0];
        }
        else
        {
            return null;
        }
    }
}