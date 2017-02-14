/**
*   Trigger helper for store visit object
*
*   @author Sahil Grover    <sgrover@acumensolutions.com>
*   @author Ryan Sayles     <rsayles@acumensolutions.com>
*/
public with sharing class StoreVisitTriggerHelper {
    
    public static void removeStartedEvents(List<Store_Visit__c> updatedStoreVisits, final Map<Id, Store_Visit__c> oldVisitMap) {
        Set<String> storeIds = StoreVisitUtility.getFieldSet(updatedStoreVisits, StoreVisitUtility.STORE_FIELD_NAME);
        Set<Date> startDates = getStartDateSet(updatedStoreVisits, oldVisitMap);
        Map<String, List<Event>> storeIdEventMap = getStoreIdEventMap(storeIds, startDates);

        List<Event> eventsToUpdate = new List<Event>();
        for (Store_Visit__c storeVisit : updatedStoreVisits) {
            Store_Visit__c oldVisit;
            if (oldVisitMap != null) {
                oldVisit = oldVisitMap.get(storeVisit.Id);
            }

            if(!shouldEventBeRemoved(storeVisit, oldVisit)){
                continue; 
            }

            List<Event> storeEvents = new List<Event>();
            if (storeVisit.Store__c != null && storeIdEventMap.containsKey(storeVisit.Store__c)) {
                storeEvents = storeIdEventMap.get(storeVisit.Store__c);
            }
            else {
                storeEvents = null;
            }
            
            if (storeEvents != null && !storeEvents.isEmpty()) {
                // only complete the first event in case there are multiple visits for the same store in the same day
                storeEvents[0].Is_Visit_Complete__c = true;
                eventsToUpdate.add(storeEvents[0]);
            }
        }

        update eventsToUpdate;
    }

    private static Map<String, List<Event>> getStoreIdEventMap(final Set<String> storeIds, final Set<Date> startDates) {
        try {
            List<Event> storeEvents = new List<Event>([
                SELECT Is_Visit_Complete__c, StartDateTime, EndDateTime, AccountId
                FROM Event
                WHERE AccountId IN :storeIds 
                    AND DAY_ONLY(StartDateTime) IN :startDates
                    AND Is_Visit_Complete__c = false
                ORDER BY StartDateTime ASC
                ]);

            return StoreVisitUtility.buildFieldSetMap(storeEvents, 'AccountId');
        } catch (QueryException ex) {
            return null;
        }
    }

    private static Set<Date> getStartDateSet(final List<Store_Visit__c> updatedStoreVisits, final Map<Id, Store_Visit__c> oldVisitMap) {
        Set<Date> startDates = new Set<Date>();
        for (Store_Visit__c storeVisit : updatedStoreVisits) {
            Store_Visit__c oldVisit;
            if (oldVisitMap != null) {
                oldVisit = oldVisitMap.get(storeVisit.Id);
            }

            if(shouldEventBeRemoved(storeVisit, oldVisit)){
                startDates.add(storeVisit.Start_Date_Time__c.date());
            }
        }
        return startDates;
    }

    private static Boolean shouldEventBeRemoved(final Store_Visit__c storeVisit, final Store_Visit__c oldVisit) {
        return 
            (oldVisit == null && storeVisit.Store_Visit_Status__c == StoreVisitUtility.VISIT_STATUS_ACTIVE) // newly inserted and active
            || (
                oldVisit != null 
                && oldVisit.Store_Visit_Status__c == StoreVisitUtility.VISIT_STATUS_PENDING
                && storeVisit.Store_Visit_Status__c == StoreVisitUtility.VISIT_STATUS_ACTIVE
                );  // updated, changed from pending to active

    }

    public static void setLastStoreVisitDate(List<Store_Visit__c> newStoreVisits) {
        try {
        Set<String> storeIds = StoreVisitUtility.getFieldSet(newStoreVisits, StoreVisitUtility.STORE_FIELD_NAME);
        Map<Id, Account> storeMap = StoreQueryUtility.queryStoreMap(storeIds);

        List<Account> storesToUpdate = new List<Account>();
        for (Store_Visit__c visit : newStoreVisits) {
         
            Account store = storeMap.get(visit.Store__c);
            if (store == null) {
                continue;
            }

            Date lastVisitDate = visit.CreatedDate.date();
            if (visit.Start_Date_Time__c != null) {
                lastVisitDate = visit.Start_Date_Time__c.date();
            }
            store.Last_Visit_Date__c = lastVisitDate;
            storesToUpdate.add(store);
        }

        update storesToUpdate;
        }
        catch (Exception e){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You cannot visit this store as it is not assigned to you') );
    }
    }
    
     /**
    * @Description: This method use to set visit_cutoff_datetime__c as 23:59:00
    * @UserStory: US475053 (Automatically stop the visit at mid-night of the visit )
    * @Author: Amit Kumar Pradhan, Accenture
    * @Date: 3-Nov-2015    
    * @Return: void.
    */
    public static void setVisitCutOffDatetime(List<Store_Visit__c> newStoreVisits){
        try{
            for (Store_Visit__c visit : newStoreVisits) {
                
                //DateTime cutDateTime = DateTime.newInstance((system.now()).year(),(system.now()).month(),(system.now()).day(), 23, 59, 0);
               // changes made to make future start date applicable
                DateTime st = visit.Start_Date_Time__c;
                DateTime cutDateTime = DateTime.newInstance(st.year(),st.month(),st.day(), 23, 59, 0);
                visit.visit_cutoff_datetime__c = cutDateTime ;
                
                // Update for US760734 :Set title in case of Event Visit and title is null
                if(visit.Visit_Type__c == 'Event' && (visit.End_date_time__c != null && visit.Title__c == null)){
                    visit.Title__c = Label.Title_for_Auto_Completed_Event_Visit;
                }
            }
        }catch (Exception e){
            
        }
    }
    
   /**
    * @Description: This method is use to check/uncheck Store_Visit_Status__c field on 
    *                account as per changes in Store_Visit_Status__c field on store visit 
    * @UserStory: US700694(Indirect - Add an indicator to My Stores page to indicate a store visit is in progress)
    * @Author: Mandeep Singh, Accenture
    * @Date: 24-Jun-2016
    * @Return: void.
    */
     public static void storeVisitStatusIndicator(List<Store_Visit__c> storeVisits){
    
       Set<Account> storeToUpdateSet = new Set<Account>();
       List<Account> trueList = new List<Account>();
       List<Account> falseList = new List<Account>();
       Set<Id> storeIdStatusTrue = new Set<Id>();
       Set<Id> storeIdStatusFalse = new Set<Id>();
           
        
        for(Store_Visit__c visit : storeVisits){
          
          if(visit.Store_Visit_Status__c == 'Active'){
                    storeIdStatusTrue.add(visit.Store__c);
            }
            else if(visit.Store_Visit_Status__c == 'Complete'){
                storeIdStatusFalse.add(visit.Store__c);
            }
        }
        Set<Account> trueSet,falseSet;
        if(storeIdStatusTrue.size() > 0 ){
          trueSet = new Set<Account>();
          for(Account acc : [ SELECT id,Store_Visit_Status__c FROM Account WHERE Id IN :storeIdStatusTrue ]){
            acc.Store_Visit_Status__c = true;
            trueSet.add(acc);
          }                    
        }
        
        if(storeIdStatusFalse.size() > 0 ){
          falseSet = new Set<Account>();
          for(Account acc : [ SELECT id,Store_Visit_Status__c FROM Account WHERE Id IN :storeIdStatusFalse ]){
            acc.Store_Visit_Status__c = false;
            falseSet.add(acc);
          }
        }
        
        if(trueSet != null && trueSet.size() > 0){
          trueList.addAll(trueSet);
          update trueList;
        }
        if(falseSet != null && falseSet.size() > 0){
          falseList.addAll(falseSet);
          update falseList;
        }
  }
 
    /**
    * @Description: This method will set CompletedAllRequiredActivities field 
        on store visit when all the required activities gets completed
    * @UserStory: US764794(Indirect: Email notification for visit completed automatically end of the day)
    * @Author: Mandeep Singh, Accenture
    * @Date: 24-Aug-2016
    * @Return: void.
    */
     public static void setCompletedAllRequiredActivities(List<Store_Visit__c> storeVisits){
    
        Id strvisitId;
        Id storeId;
        Boolean requiredAct;
        String storeType;
          
            if((storeVisits[0].End_Date_Time__c == storeVisits[0].visit_cutoff_datetime__c || storeVisits[0].Is_Auto_Check_Out__c == true) && storeVisits[0].Completed_all_required_activities__c == false ){              
                strvisitId = storeVisits[0].id;
                storeId = storeVisits[0].Store__c;           
            
        if(storeId != null){           
        Account storeDetail =[SELECT Id,Store_Type__c FROM Account
                                  WHERE recordtype.name='store' AND id =: storeId];              
            
            storeType = storeDetail.Store_Type__c;
        }    
        User repuser = [SELECT id, name ,email ,UserRole.DeveloperName, managerid , manager.email FROM user 
                        WHERE id=:userinfo.getuserid()];
        
        String userRole = repuser.UserRole.DeveloperName; 
                    
         List<Store_Visit_Activity_Category__c>  categories=  [SELECT Id,Number_Required__c,Record_Type_Name__c,Record_Type_Id__c, Store_Activity_Category__c,New_Records__c
                                                               FROM Store_Visit_Activity_Category__c
                                                               WHERE Store_Type__c = :storeType AND User_Role__c =: userRole AND New_Records__c = true
                                                               ORDER BY Number_Required__c DESC]; 
                                                                 
         List<Store_Activity__c> StoreActivityList = [SELECT Id, Name ,Activity_Type__c,Is_Activity_Completed_New__c,
                                                     RecordTypeId         
                                                     FROM Store_Activity__c WHERE Store_Visit__c =:strvisitId 
                                                     AND Is_Activity_Completed_New__c= true ORDER BY CreatedDate];
            Integer completedNumber = 0;
            List<Store_Visit_Activity_Category__c> reqAct = new List<Store_Visit_Activity_Category__c>();                                
            for(Store_Visit_Activity_Category__c Cate: categories)
            {
                if(Cate.Number_Required__c > 0)
                {
                    reqAct.add(Cate);
                }
            }
            for(Store_Visit_Activity_Category__c allCate: reqAct)
            {
                for(Store_Activity__c sta: StoreActivityList)
                {
                    if(sta.RecordTypeId == allCate.Record_Type_Id__c)
                    {
                        completedNumber++;
                    }
                }
            }                             
            if(completedNumber == reqAct.size())
            {
              storeVisits[0].Completed_all_required_activities__c =  true;
               
            } 
        }
    }  
}