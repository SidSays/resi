/**
*   Trigger helper for store visit object
*
*   @author Sahil Grover    <sgrover@acumensolutions.com>
*   @author Ryan Sayles     <rsayles@acumensolutions.com>

*   Version : 1.0
    Last Modified By : Tejaswini Kasar, Accenture
    Last Modified By : 10-Apr-2017
    User Story : US1024565->Indirect - Coach for Indirect - Retail Sales Rep - Activity Goal - Metric Actuals
    @Description: Methods for metric actual update "Total nmber of Store Visits" and "Average Store Visit Duration" for Retail Sales Rep monthly Activity goals
    PROJECT : Indirect Coach
*   Version : 2.0
    Last Modified By : Amit Kumar Pradhan, Accenture
    Last Modified By : 23rd May 2017
    @Description: Resolving issue of "List has no rows for assignment to SObject"(US820672) and adding try...catch
    PROJECT : Indirect 
*/
public with sharing class StoreVisitTriggerHelper {
    //Constant variable
    private static final String STORE_RECORDTYPE_NAME = 'store';
    private static final String STORE_VISIT_NEW_RECORDTYPE = Schema.SObjectType.Store_Visit__c.getRecordTypeInfosByName().get(Label.Store_visit_new).getRecordTypeId();
    private static final String COMPLETE = 'Complete';
    private static final String STORE_VISIT_CUTOFF_HOUR = 'StoreVisitCutOffHour';
    private static final String STORE_VISIT_CUTOFF_MINUTE = 'StoreVisitCutOffMinute';
    
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
    * Description : visit cut off hour and minute added in a custom setting(US820672)
    * Last Modified By : Amit Kumar Pradhan
    * Last Modified Date : 23rd May 2017
    */
    public static void setVisitCutOffDatetime(List<Store_Visit__c> newStoreVisits){
        try{
            /****************************
             * Start User Story: US820672
             * Description : visit cut off hour and minute added in a custom setting(US820672)
             * Auther : Amit Kumar Pradhan
             * Date : 23rd May 2017
            *****************************/
            Integer visitCutOffHour = 23;
            Integer visitCutOffMinute = 59;
            //Fetching store visit cut off hour from custom setting
            Variable_Setting__c StoreVisitCutOffHourCS = Variable_Setting__c.getInstance(STORE_VISIT_CUTOFF_HOUR); 
            if(StoreVisitCutOffHourCS != null && StoreVisitCutOffHourCS.Value__c.isNumeric()){
                visitCutOffHour = Integer.valueOf(StoreVisitCutOffHourCS.Value__c);//Fetching visit CutOff Hour value from custom setting
            }else{}
            //Fetching store visit cut off minute from custom setting
            Variable_Setting__c StoreVisitCutOffMinuteCS = Variable_Setting__c.getInstance(STORE_VISIT_CUTOFF_MINUTE); 
            if(StoreVisitCutOffMinuteCS != null && StoreVisitCutOffMinuteCS.Value__c.isNumeric()){
                visitCutOffMinute = Integer.valueOf(StoreVisitCutOffMinuteCS.Value__c);//Fetching visit CutOff Minute value from custom setting
            }else{}
            /****************************
             * End User Story: US820672
            *****************************/
            for (Store_Visit__c visit : newStoreVisits) {                
                //DateTime cutDateTime = DateTime.newInstance((system.now()).year(),(system.now()).month(),(system.now()).day(), 23, 59, 0);
                //changes made to make future start date applicable
                DateTime st = visit.Start_Date_Time__c;
                DateTime cutDateTime = DateTime.newInstance(st.year(),st.month(),st.day(), visitCutOffHour, visitCutOffMinute, 0);//Replace hardcoding with visitCutOffHour and visitCutOffMinute
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
    * Description : Resolving issue of "List has no rows for assignment to SObject"(US820672) and adding try...catch
    * Last Modified By : Amit Kumar Pradhan
    * Last Modified Date : 21st May 2017
    */
    public static void setCompletedAllRequiredActivities(List<Store_Visit__c> storeVisits){
        try{    
            Id strvisitId = null;
            Id storeId = null;
            //Boolean requiredAct;
            String storeType = null;
            String userRole = null;
            
            if((storeVisits[0].End_Date_Time__c == storeVisits[0].visit_cutoff_datetime__c || storeVisits[0].Is_Auto_Check_Out__c == true) 
                            && storeVisits[0].Completed_all_required_activities__c == false ){
                                
                strvisitId = storeVisits[0].Id;
                storeId = storeVisits[0].Store__c;           
                
                if(storeId != null){
                     /****************************
                     * Start User Story: US820672
                     * Description : 1.Added in a list List<Account> and adding null check
                                     2.putting storeType != null check
                                     3.Added in a list List<User> and adding null check
                                     4.Adding LIMIT check in every query
                                     5.putting Cate.Number_Required__c != null
                     * Auther : Amit Kumar Pradhan
                     * Date : 21st May 2017
                     *****************************/
                    //Fetching the Account details against storeId to get store type
                    List<Account> storeDetail = [SELECT Id, Store_Type__c FROM Account WHERE Recordtype.Name =: STORE_RECORDTYPE_NAME 
                                                    AND Id =: storeId LIMIT 1];
                                                    
                    if(storeDetail != null && !storeDetail.isEmpty()){
                        storeType = storeDetail[0].Store_Type__c;
                    }
                    
                    if(storeType != null){
                        //Fetching the User record against logged in user to fetch user role
                        List<User> repUser = [SELECT Id, Name, Email, UserRole.DeveloperName, ManagerId, Manager.Email FROM User 
                                                WHERE Id =: userinfo.getuserid() LIMIT 1];
                                            
                        if(repUser != null && !repUser.isEmpty()){
                            userRole = repUser[0].UserRole.DeveloperName; 
                        }
                        
                        if(userRole != null){
                            //Fetching Store_Visit_Activity_Category__c records against Store Type and user role
                            List<Store_Visit_Activity_Category__c> categories = [SELECT Id, Number_Required__c, Record_Type_Name__c, Record_Type_Id__c,
                                                                                    Store_Activity_Category__c,New_Records__c
                                                                                    FROM Store_Visit_Activity_Category__c
                                                                                    WHERE Store_Type__c =: storeType AND User_Role__c =: userRole 
                                                                                    AND New_Records__c = true
                                                                                    ORDER BY Number_Required__c DESC 
                                                                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]; 
                            //Fetching Store_Activity__c records against strvisitId                                                      
                            List<Store_Activity__c> StoreActivityList = [SELECT Id, Name, Activity_Type__c, Is_Activity_Completed_New__c, RecordTypeId         
                                                                            FROM Store_Activity__c WHERE Store_Visit__c =:strvisitId 
                                                                            AND Is_Activity_Completed_New__c= true ORDER BY CreatedDate 
                                                                            LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                            Integer completedNumber = 0;
                            List<Store_Visit_Activity_Category__c> reqAct = new List<Store_Visit_Activity_Category__c>(); 
                            
                            //Recreate Store_Visit_Activity_Category__c list for required category(Cate.Number_Required__c == 1)
                            for(Store_Visit_Activity_Category__c Cate: categories)
                            {   
                                if(Cate.Number_Required__c != null){//Putting null check
                                    if(Cate.Number_Required__c > 0)
                                    {
                                        reqAct.add(Cate);
                                    }
                                }   
                            }
                    /****************************
                     * End User Story: US820672     
                    ****************************/       
                            //compairing completed activities against all Store_Visit_Activity_Category__c that are required
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
                            //If required activity matches with completed activities then make Completed_all_required_activities__c = true
                            if(completedNumber == reqAct.size())
                            {
                                storeVisits[0].Completed_all_required_activities__c = true;               
                            }
                        }   
                    }   
                }   
            }
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage());
        }
    }
     /**
    * @Description: This method will set the value of Created_Date_Custom_TimeZone__c (to avoid Time zone issue).
    * @UserStory: US1024565(Indirect - Coach for Indirect - Retail Sales Rep - Activity Goal - Metric Actuals)
    * @Author:Tejaswini Kasar, Accenture
    * @Date: 10-Apr-2017
    * @param: List<Store_Visit__c>
    * @return type: void
    */ 
     /*public static void populateCustomTimeZoneForStoreVisitCreatedDate(List<Store_Visit__c> storeVisitList) {
        try{
            for(Store_Visit__c storeVisit : storeVisitList){
                if(storeVisit.RecordTypeId == STORE_VISIT_NEW_RECORDTYPE){
                    storeVisit.Created_Date_Custom_TimeZone__c = Date.today();
                }
            } 
        } 
        catch(Exception e){
            System.debug('Exception------'+e.getMessage());
        }       
    }*/
 /**
    * @Description: This method will update the actual value of metrics "Total Number of Store Visits" and "Average Store Visit Duration" for Retail Sales Rep profile user when store visits or other visits gets completed.
    * @UserStory: US1024565(Indirect - Coach for Indirect - Retail Sales Rep - Activity Goal - Metric Actuals)
    * @Author:Tejaswini Kasar, Accenture
    * @Date: 10-Apr-2017
    * @param: List<Store_Visit__c>
    * @return type: void
    */  
    /*public static void updateMetricForRetailSalesRepGoal(List<Store_Visit__c> storeVisitList){
        Set<Id> storeVisitCreatedByIdSet = new Set<Id>();       
        List<Store_Visit__c> otherVisitsList = new List<Store_Visit__c>(); 
        list<metric> metricUpdateList = new list<metric>();
        Map<String,Store_Visit__c> filterStringVsStoreVisitMap = new Map<String,Store_Visit__c>(); 
        Map<String,Integer> storeVisitOwnerIdVsVisitCount = new Map<String,Integer>();
        Map<String,decimal> storeVisitIdVsVisitDuration = new Map<String,decimal>();
        Date startDate;
        Date dueDate;
        
        try{   
            //Bypass metric validation while updating
            MetricTriggerController.allowValidation=false;
            //Fetch 'IndirectActivityGoalCycle' record from "GoalTemplateDates__c" custom setting for current commission cycle
            GoalTemplateDates__c goalTemplateDate = GoalTemplateDates__c.getValues(Indirect_Constants.INDIRECT_MONTHLY_CS_RECORD);
            if(goalTemplateDate != null){
                startDate = goalTemplateDate.Current_Period_Start_Date__c;
                dueDate = goalTemplateDate.Current_Period_Due_Date__c;
            }
            //Filter completed store visits where Is_Auto_Check_Out__c is 'False'
            if(!storeVisitList.isEmpty()){
                for(Store_Visit__c storeVisit : storeVisitList){
                    if(storeVisit.Start_Date_Time__c != null && storeVisit.End_Date_Time__c != null 
                        && storeVisit.Store_Visit_Status__c == COMPLETE && !storeVisit.Is_Auto_Check_Out__c){
                        storeVisitCreatedByIdSet.add(storeVisit.createdById);
                    }
                } 
            }
            
            if(!storeVisitCreatedByIdSet.isEmpty()){
                //Logic for filtering first store visit of the day and all the other visits
                for(Store_Visit__c storeVisit : [SELECT Id, Is_Auto_Check_Out__c, Store_Visit_Status__c, Start_Date_Time__c, End_Date_Time__c, Store__c, 
                                                    createddate, Created_Date_Custom_TimeZone__c, createdById 
                                                    FROM Store_Visit__c  WHERE Created_Date_Custom_TimeZone__c >=: startDate 
                                                    AND Created_Date_Custom_TimeZone__c <=: dueDate AND Store_Visit_Status__c =: COMPLETE 
                                                    AND Is_Auto_Check_Out__c = false AND createdById IN: storeVisitCreatedByIdSet 
                                                    ORDER BY Created_Date_Custom_TimeZone__c ASC
                                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                                                      
                    if(storeVisit.Start_Date_Time__c != null && storeVisit.End_Date_Time__c != null){
                        //if block for fetching store visit created in a store(Account) 
                        if(storeVisit.Store__c != null){
                            String dateVal = string.valueOf(storeVisit.Created_Date_Custom_TimeZone__c);
                            String storeVisitFilterString = dateVal + storeVisit.Store__c + storeVisit.createdById; 
                            //Filter the first store visit created in a day for a store(Account)  by a retail sales rep
                            if(!filterStringVsStoreVisitMap.containsKey(storeVisitFilterString)){
                                filterStringVsStoreVisitMap.put(storeVisitFilterString,storeVisit);
                            }
                        }//else block for fetching Other visits (where Store__c = null)
                        else{
                            otherVisitsList.add(storeVisit);    
                        }
                    }
                }  
                //Adding filtered store visits with other visits
                if(!filterStringVsStoreVisitMap.isEmpty()){             
                    otherVisitsList.addAll(filterStringVsStoreVisitMap.values());
                }
                //Logic for calculation of total number of visits  and average store visit duration
                for(Store_Visit__c storeVisit : otherVisitsList){
                    Integer tempTotalStoreVisit = 0;
                    decimal durationInMins = 0;
                    //Calculating no. of Store Visits per Rep
                    if(storeVisitOwnerIdVsVisitCount.containsKey(storeVisit.createdById)){
                        tempTotalStoreVisit = storeVisitOwnerIdVsVisitCount.get(storeVisit.createdById);
                    }
                    tempTotalStoreVisit ++;
                    storeVisitOwnerIdVsVisitCount.put(storeVisit.createdById,tempTotalStoreVisit);
                    //Calculating Store Visit duration per Rep
                    if(storeVisitIdVsVisitDuration.containsKey(storeVisit.createdById)){
                        durationInMins = storeVisitIdVsVisitDuration.get(storeVisit.createdById);
                    }
                    durationInMins += (decimal.valueOf(storeVisit.End_Date_Time__c.getTime() - storeVisit.Start_Date_Time__c.getTime()))/1000/60;
                    storeVisitIdVsVisitDuration.put(storeVisit.createdById,durationInMins);
                    
                }
                
                //Fetching "Total Number of Store Visits" AND "Average Store Visit Duration" metrics and update
                for(Metric metr : [SELECT Id, Name, OwnerId, Currentvalue, Goal.OwnerId, Goal.StartDate, Goal.DueDate, Goal.RecordtypeId FROM Metric 
                                    WHERE Metric.Name IN (:Indirect_Constants.METRIC_TOTAL_NUMBER_OF_STORE_VISITS_PER_MONTH, :Indirect_Constants.METRIC_AVG_STORE_VISIT_DURATION)
                                    AND Goal.StartDate >=: startDate AND Goal.DueDate <= :duedate AND Goal.Status =:Indirect_Constants.GOAL_STATUS_PUBLISHED
                                    AND Goal.OwnerId IN :storeVisitCreatedByIdSet AND Goal.RecordtypeId =: Indirect_Constants.INDIRECT_RECORD_TYPE_ID 
                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                                        
                    if(!storeVisitOwnerIdVsVisitCount.isEmpty() && storeVisitOwnerIdVsVisitCount.containsKey(metr.OwnerId)){
                        //Metric actuals update for "Total Number of Store Visits"
                        if(Indirect_Constants.METRIC_TOTAL_NUMBER_OF_STORE_VISITS_PER_MONTH.equalsIgnoreCase(metr.Name)){ 
                            metr.Currentvalue = storeVisitOwnerIdVsVisitCount.get(metr.OwnerId);
                        }//Metric actuals update for "Average Store Visit Duration"
                        else if(!storeVisitIdVsVisitDuration.isEmpty() && storeVisitIdVsVisitDuration.containsKey(metr.OwnerId) && Indirect_Constants.METRIC_AVG_STORE_VISIT_DURATION.equalsIgnoreCase(metr.Name)){
                            Decimal totalDurationCount = storeVisitIdVsVisitDuration.get(metr.OwnerId);
                            Integer countTotal = storeVisitOwnerIdVsVisitCount.get(metr.OwnerId);
                            Decimal avgDuration = 0.00;
                            //Average duration count for each rep
                            if(countTotal > 0){
                                avgDuration = (totalDurationCount/(Decimal)countTotal).setScale(2);
                            }
                            metr.Currentvalue = avgDuration;
                        }else{}                     
                    }                                
                    metricUpdateList.add(metr);
                        
                }
                
                if(metricUpdateList != null && !metricUpdateList.isEmpty()){
                    Database.update(metricUpdateList,false);
                }
            }   
        }
        catch(Exception e){
            System.debug('Exception------'+e.getMessage());
        }
                        
    }  */ 

}