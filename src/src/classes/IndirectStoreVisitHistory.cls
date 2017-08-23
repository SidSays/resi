/** 
*Controller for IndirectStoreVisitHistory Lightning Component
* @Author Ashish Srivastava
*/
public with sharing class IndirectStoreVisitHistory{
    
    //method to retrieve list of objects for Store Visits
    @AuraEnabled
    public static List<StoreVisitWrapper> getStoreVisits(Account store, UserRole role){
        
        List<StoreVisitWrapper> visitList = new List<StoreVisitWrapper>();
        
        List<Store_Visit__c> storeVisitList = [SELECT Id,Number_of_Completed_Activities__c,Number_of_Completed_Activities_New__c,                                               
                                               Store_Visit_Name__c, Notes__c, Total_Activities__c,
                                               Store_Visit_Status__c, Owner.Name, Start_Date_Time__c, Time_Spent__c 
                                               FROM Store_Visit__c WHERE Store__c = :store.Id AND OwnerId = :UserInfo.getUserId() 
                                               AND Completed_Formula__c = TRUE ORDER BY CreatedDate DESC];        
        
        for(Store_Visit__c sv : storeVisitList){
            StoreVisitWrapper obj = new StoreVisitWrapper();
            obj.check = false;
            obj.onRepeat = false;
            obj.checkActivity = false;
            obj.onRepeatActivity = false;
            obj.stv = sv;
            visitList.add(obj);
        }        
        return visitList;
    } 
    
    public class StoreVisitWrapper{
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
    }
    
    @AuraEnabled
    public static List<ChildStoreVisitWrapper> getStoreVisitWrapper(List<Store_Visit_Activity_Category__c> categories, String storeVisitId){
        Set<String> listOfRecordType = new Set<String>();
        List<Store_Visit_Activity_Category__c> newCate = new List<Store_Visit_Activity_Category__c>();
        List<Store_Visit__c> storeVisitRecord = [Select Old_records__c from Store_Visit__c where Id = :storeVisitId];
        if(storeVisitRecord[0].Old_records__c == true)
        {
            for(Store_Visit_Activity_Category__c stc : categories)
            {
			if(stc.New_Records__c == false)     
                {
                    listOfRecordType.add(stc.Record_Type_Id__c);
                    newCate.add(stc);
                }
                
            }       
            List<Store_Activity__c> existingActivities =  [Select Id, Name,Store_Visit__c,RecordTypeId,
                                                           RecordType.Name,RecordType.DeveloperName, Store_Type__c 
                                                           from Store_Activity__c where Store_Visit__c = :storeVisitId 
                                                           and RecordTypeId IN :listOfRecordType 
                                                           AND Is_Activity_Completed__c = true ];           
            
            List<ChildStoreVisitWrapper> listOfWrapper = new List<ChildStoreVisitWrapper>();
            for(Store_Visit_Activity_Category__c ct: newCate)
            {
                ChildStoreVisitWrapper classObj = new ChildStoreVisitWrapper();
                classObj.check = false;
                classObj.stc = ct;
                for(Store_Activity__c sta: existingActivities)
                {
                    if(sta.RecordTypeId == ct.Record_Type_Id__c)
                    {  
                        classObj.sta = sta;
                    }
                }
                
                listOfWrapper.add(classObj);
            }
            return listOfWrapper;
        }
        else
        {
            for(Store_Visit_Activity_Category__c stc : categories)
            {
                if(stc.New_Records__c == true)      
                {
                    listOfRecordType.add(stc.Record_Type_Id__c);
                    newCate.add(stc);
                }
            }
            List<Store_Activity__c> existingActivities =  [Select Id, Name,Store_Visit__c,RecordTypeId,
                                                           RecordType.Name,RecordType.DeveloperName, Store_Type__c 
                                                           from Store_Activity__c where Store_Visit__c = :storeVisitId 
                                                           and RecordTypeId IN :listOfRecordType 
                                                           AND Is_Activity_Completed_New__c = true];            
            
            List<ChildStoreVisitWrapper> listOfWrapper = new List<ChildStoreVisitWrapper>();
            for(Store_Visit_Activity_Category__c ct: newCate)
            {
                ChildStoreVisitWrapper classObj = new ChildStoreVisitWrapper();
                classObj.check = false;
                classObj.stc = ct;
                for(Store_Activity__c sta: existingActivities)
                {
                    if(sta.RecordTypeId == ct.Record_Type_Id__c)
                    {  
                        classObj.sta = sta;
                    }
                }
                
                listOfWrapper.add(classObj);
            }
            return listOfWrapper;
        }
    }
    
    // Class created to show control the toggle arrows properly on store visit page   
    public class ChildStoreVisitWrapper
    {
        @AuraEnabled
        public Boolean check {get;set;}        
        @AuraEnabled
        public Store_Visit_Activity_Category__c stc {get;set;}
        @AuraEnabled
        public Store_Activity__c sta {get;set;}
    }
    
     @AuraEnabled
    //method to get Activity Details
    public static Store_Activity__c getActivityDetails(String storevisitCategoryRecordId, Id storeVisitId){
      //  Id recordTypeId = activityRTMap.get(storevisitCategoryRTName).getRecordTypeId();      
        List<Store_Activity__c> obj =  [Select Id, Name,Store_Visit__c,RecordTypeId,
                                        RecordType.Name,RecordType.DeveloperName, Store_Type__c 
                                        from Store_Activity__c where Store_Visit__c = :storeVisitId
                                        AND recordTypeId = :storevisitCategoryRecordId AND
                                        Is_Activity_Completed_New__c = true LIMIT 1];        
        
        if(obj.size() != 0){            
            return obj[0];
        }
        else
        {
            return null;
        }
    }
    
    /* Added by - Radhika Bansal
     * Date - 12-July-2016 
     * Requirement - To get all categories for old and new categories on pull to refresh.
     */ 
    @AuraEnabled
    public static List<Store_Visit_Activity_Category__c> queryActivityCategoriesForHistory(String storeType, String userRoleName) {
        List<Store_Visit_Activity_Category__c> historyCategories = [SELECT Id, Number_Required__c,Record_Type_Name__c,
                                                                    Record_Type_Id__c, Store_Activity_Category__c,
                                                                    Lookup_field_value__c,New_Records__c  
                                                                    FROM Store_Visit_Activity_Category__c
                                                                    WHERE Store_Type__c = :storeType 
                                                                    AND User_Role__c = :userRoleName
                                                                    ORDER BY Number_Required__c DESC,
                                                                    Record_Type_Name__c asc
                                                                            ];
            return historyCategories;
    }
    
}