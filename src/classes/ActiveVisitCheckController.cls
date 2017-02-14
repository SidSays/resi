/**
*   Controller extension for checking active store visits for other stores
*
*   @author Sahil Grover
*/
global class ActiveVisitCheckController {
    
    public Boolean IsOtherVisitActive {get; private set;}
    public Id ActiveStoreId {get; private set;}
    public String StoreName {get;private set;}
    
    public ActiveVisitCheckController(ApexPages.StandardController stdCon) {
        Id storeId = stdCon.getId();
        //this.IsOtherVisitActive = isOtherVisitActive(storeId);
    }
  
    /*
    *  Check for previous store visit is active or complete  
    */
    @RemoteAction
     public static String isOtherVisitActive(Id storeId) {        
        String activeStoreName = '';
        List<Store_Visit__c> activeVisitList = [
            SELECT Id, Store__c,Prospect_Store_Name__c,Store__r.Name 
            FROM Store_Visit__c
            WHERE Store__c <> :storeId 
                AND Store_Visit_Status__c = :StoreVisitUtility.VISIT_STATUS_ACTIVE
                AND OwnerId = :UserInfo.getUserId()
            LIMIT 1
        ]; 
        //this.ActiveStoreId = activeVisit.Store__c;
         if(activeVisitList.size() == 1){ if(activeVisitList[0].Store__c!=null){          
             activeStoreName = activeVisitList[0].Store__r.Name;            }
         else if(activeVisitList[0].Prospect_Store_Name__c!=null){activeStoreName = activeVisitList[0].Prospect_Store_Name__c;}
                                         else{activeStoreName= 'Prospect Visit';}
                                        }
            
        return activeStoreName;
        
    }
    
    
    /*
    *  Mark all previous active store visit as complete
    */
    @RemoteAction
    public static Boolean setCompletedStatus(Id storeId){         
          List<Store_Visit__c> storeVisitMarkAsComplete = new List<Store_Visit__c>();
          for(Store_Visit__c activeVisit : [
                SELECT Id, Store__c,End_Date_Time__c 
                FROM Store_Visit__c
                WHERE Store__c <> :storeId 
                    AND Store_Visit_Status__c = :StoreVisitUtility.VISIT_STATUS_ACTIVE
                    AND OwnerId = :UserInfo.getUserId()
               
            ]){
            
                activeVisit.End_Date_Time__c = System.Now();
                activeVisit.Is_Auto_Check_Out__c=true;
                storeVisitMarkAsComplete.add(activeVisit);                
            }                                    
            Database.update(storeVisitMarkAsComplete);
            return true; 
     }
     
     
      // User Story: US461963 , Sprint 3 Change, Date : 5/29/2015, Author : Pranjal Singh
        //Condition in the query is changed, earlier store__r.OwnerId was being matched 
        //and now the OwnerId of the store visit is being matched 
    /*
    private Boolean isOtherVisitActive2(Id storeId) {
        try {
            Store_Visit__c activeVisit = [
                SELECT Id, Store__c
                FROM Store_Visit__c
                WHERE Store__c <> :storeId 
                    AND Store_Visit_Status__c = :StoreVisitUtility.VISIT_STATUS_ACTIVE
                    AND OwnerId = :UserInfo.getUserId()
                LIMIT 1
            ]; 
            this.ActiveStoreId = activeVisit.Store__c;
        } catch (QueryException ex) {
            return false;
        }
        isOtherVisitActive = false;
        return true;
    }
    */
    
}