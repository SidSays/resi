/*
*   This class is to update Retail Sales Rep and Retail Sales Manager's actuals
*   Version : 1.0
    Created By: Srini Bhattiprolu & Tejaswini Kasar, Accenture
    Last Modified By : Srini Bhattiprolu
    Last Modified By : 12-Apr-2017
    User Story : US1024565->Indirect - Coach for Indirect - Retail Sales Rep - Activity Goal - Metric Actuals
    User Story : US1088485 ->Indirect - Coach for Indirect - Retail Sales Manager - Activity Goal - Store Visits - Metric Actuals
    @Description: Methods for metric actual update "Total nmber of Store Visits" and "Average Store Visit Duration" for Retail Sales Rep and Retail Sales Manager monthly Activity goals
    PROJECT : Indirect Coach    
    *Modification History:
       *Modification 1:
          *User Story: US1099963 - Coach for Indirect - Total Number of Store Visits Metric - exclude Manager visits; and Work.com required to count actuals
          *Method: updateMetricForRetailSalesRepAndMgrGoal
          *Modified By: Srini Bhattiprolu
          *Modified Date: 5/18/2017
    
*/

public class StoreVisitCompletionAndMetricsActuals {
    private static final String COMPLETE = 'Complete';
    private static final String STORE_VISIT_NEW_RECORDTYPE = Schema.SObjectType.Store_Visit__c.getRecordTypeInfosByName().get(Label.Store_visit_new).getRecordTypeId();
    
/**
    * @Description: This method will set the value of Created_Date_Custom_TimeZone__c (to avoid Time zone issue).
    * @UserStory: US1024565(Indirect - Coach for Indirect - Retail Sales Rep - Activity Goal - Metric Actuals)
    * @Author:Tejaswini Kasar, Accenture
    * @Date: 12-Apr-2017
    * @param: List<Store_Visit__c>
    * @return type: void
*/ 
     public static void populateCustomTimeZoneForStoreVisitCreatedDate(List<Store_Visit__c> storeVisitList) {
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
    }
    
/*
    * @Description: This method will update the actual value of metrics "Total Number of Store Visits" and "Average Store Visit Duration" for Retail Sales Rep and Retail Sales manager goals when Retail Sales Rep store visits or other visits gets completed.
    * @UserStory: US1024565(Indirect - Coach for Indirect - Retail Sales Rep - Activity Goal - Metric Actuals)
    * @User Story : US1088485 ->Indirect - Coach for Indirect - Retail Sales Manager - Activity Goal - Store Visits - Metric Actuals
    * @Author:Tejaswini Kasar and Srini Bhattiprolu, Accenture
    * @Date: 12-Apr-2017
    * @param: List<Store_Visit__c>
    * @return type: void
    *Modification History:
       *Modification 1:
          *User Story: US1099963 - Coach for Indirect - Total Number of Store Visits Metric - exclude Manager visits; and Work.com required to count actuals
          *Modified By: Srini Bhattiprolu
          *Modified Date: 5/18/2017
*/
    public static void updateMetricForRetailSalesRepAndMgrGoal(List<Store_Visit__c> storeVisitList){
        Set<Id> storeVisitCreatedByIdSet = new Set<Id>();  
        Set<Id> retailSalesMgrIdSet = new Set<Id>();   //To capture the Retail Sales Manager IDs
        Set<Id> storeVisitRepAndMgrSet = new Set<Id>();//Set for combining Rep and Manager Ids 
        List<Store_Visit__c> otherVisitsList = new List<Store_Visit__c>(); 
        list<metric> metricUpdateList = new list<metric>();
        Map<String,Store_Visit__c> filterStringVsStoreVisitMap = new Map<String,Store_Visit__c>(); 
        Map<String,Integer> storeVisitOwnerIdVsVisitCount = new Map<String,Integer>();
        Map<String,Integer> storeVisitMgrIdVsVisitCount = new Map<String,Integer>();
        Map<String,decimal> storeVisitIdVsVisitDuration = new Map<String,decimal>();
        Map<String,decimal> storeVisitMgrIdVsVisitDuration = new Map<String,decimal>();
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
            //Added By Srini - US1099963: Profile check to filter the visits created only by Retail Sales Rep
            if(!storeVisitList.isEmpty()){
                for(Store_Visit__c storeVisit : storeVisitList){
                    if(storeVisit.Start_Date_Time__c != null && storeVisit.End_Date_Time__c != null 
                        && storeVisit.Store_Visit_Status__c == COMPLETE && !storeVisit.Is_Auto_Check_Out__c 
                        && Variable_Setting__c.getInstance('RetailSalesRepProfileId') != null 
                        && Variable_Setting__c.getInstance('RetailSalesRepProfileId').Value__c != null 
                        && userinfo.getProfileId() == Variable_Setting__c.getInstance('RetailSalesRepProfileId').Value__c){
                        storeVisitCreatedByIdSet.add(storeVisit.createdById);
                        
                    }
                } 
            }

            //Fetch the Manager Ids for the Reps who create store or other visits
            if (!storeVisitCreatedByIdSet.isEmpty()){
            for(User userObj: [SELECT Id,ManagerId,Manager.isActive FROM User WHERE Id IN : storeVisitCreatedByIdSet AND isActive=True 
                               LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                if(userObj.ManagerId != null && userObj.Manager.isActive){
                    retailSalesMgrIdSet.add(userObj.ManagerId);
                }  
            }
            }
            
            if(!storeVisitCreatedByIdSet.isEmpty()){
                //Logic for filtering first store visit of the day and all the other visits
                //Added By Srini - US1099963: Added Filter for Work.com permission
                for(Store_Visit__c storeVisit : [SELECT Id, Is_Auto_Check_Out__c, Store_Visit_Status__c, Start_Date_Time__c, End_Date_Time__c, Store__c, 
                                                    createddate, Created_Date_Custom_TimeZone__c, createdById, createdBy.ManagerId 
                                                    FROM Store_Visit__c  WHERE Created_Date_Custom_TimeZone__c >=: startDate 
                                                    AND Created_Date_Custom_TimeZone__c <=: dueDate AND Store_Visit_Status__c =: COMPLETE 
                                                    AND Is_Auto_Check_Out__c = false 
                                                    AND (createdById IN: storeVisitCreatedByIdSet OR createdBy.ManagerId IN : retailSalesMgrIdSet)
                                                    AND createdBy.UserPermissionsWorkDotComUserFeature = true
                                                    ORDER BY CreatedDate ASC
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
                    Integer tempMgrTotalStoreVisit = 0;
                    decimal mgrDurationInMins = 0;
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
                    //Calculating no. of Store Visits for Retail Sales Manager
                    if(storeVisitMgrIdVsVisitCount.containsKey(storeVisit.createdBy.ManagerId)){
                        tempMgrTotalStoreVisit = storeVisitMgrIdVsVisitCount.get(storeVisit.createdBy.ManagerId);
                    }
                    tempMgrTotalStoreVisit ++;
                    storeVisitMgrIdVsVisitCount.put(storeVisit.createdBy.ManagerId,tempMgrTotalStoreVisit);
                    //Calculating Store Visit duration for Manager
                    if(storeVisitMgrIdVsVisitDuration.containsKey(storeVisit.createdBy.ManagerId)){
                        mgrDurationInMins = storeVisitMgrIdVsVisitDuration.get(storeVisit.createdBy.ManagerId);
                    }
                    mgrDurationInMins += (decimal.valueOf(storeVisit.End_Date_Time__c.getTime() - storeVisit.Start_Date_Time__c.getTime()))/1000/60;
                    storeVisitMgrIdVsVisitDuration.put(storeVisit.createdBy.ManagerId,mgrDurationInMins);
                    
                }
                
                storeVisitRepAndMgrSet.addAll(storeVisitCreatedByIdSet);
                //Added isEmpty check per review comments
                if (!retailSalesMgrIdSet.isEmpty()){
                storeVisitRepAndMgrSet.addAll(retailSalesMgrIdSet);
                }                                
                //Fetching "Total Number of Store Visits" AND "Average Store Visit Duration" metrics and update
             
                for(Metric metr : [SELECT Id, Name, OwnerId, Currentvalue, Goal.OwnerId, Goal.StartDate, Goal.DueDate, Goal.RecordtypeId FROM Metric 
                                    WHERE Metric.Name IN (:Indirect_Constants.METRIC_TOTAL_NUMBER_OF_STORE_VISITS_PER_MONTH, :Indirect_Constants.METRIC_AVG_STORE_VISIT_DURATION)
                                    AND Goal.StartDate >=: startDate AND Goal.DueDate <= :duedate AND Goal.Status =:Indirect_Constants.GOAL_STATUS_PUBLISHED
                                    AND Goal.OwnerId IN :storeVisitRepAndMgrSet AND Goal.RecordtypeId =: Indirect_Constants.INDIRECT_RECORD_TYPE_ID 
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
                        }                    
                    
                    }
                    if(!storeVisitMgrIdVsVisitCount.isEmpty() && storeVisitMgrIdVsVisitCount.containsKey(metr.OwnerId)){
                        
                        //Metric actuals update for "Total Number of Store Visits" for Manager
                        if(Indirect_Constants.METRIC_TOTAL_NUMBER_OF_STORE_VISITS_PER_MONTH.equalsIgnoreCase(metr.Name)){ 
                            metr.Currentvalue = storeVisitMgrIdVsVisitCount.get(metr.OwnerId);
                        }//Metric actuals update for "Average Store Visit Duration"
                        else if(!storeVisitMgrIdVsVisitDuration.isEmpty() && storeVisitMgrIdVsVisitDuration.containsKey(metr.OwnerId) && Indirect_Constants.METRIC_AVG_STORE_VISIT_DURATION.equalsIgnoreCase(metr.Name)){
                            Decimal totalDurationCount = storeVisitMgrIdVsVisitDuration.get(metr.OwnerId);
                            Integer countTotal = storeVisitMgrIdVsVisitCount.get(metr.OwnerId);
                            Decimal avgDuration = 0.00;
                            //Average duration count for Manager
                            if(countTotal > 0){
                                avgDuration = (totalDurationCount/(Decimal)countTotal).setScale(2);
                            }
                            metr.Currentvalue = avgDuration;
                        }                    
                    }                            
                    metricUpdateList.add(metr);
                  }
                //Removed IsNULL check on metricUpdateList per review comments
                if(!metricUpdateList.isEmpty()){
                    Database.update(metricUpdateList,false);
                }
             
            }
        }  
        catch(Exception e){
            System.debug('Exception------'+e.getMessage());
        }
                        
    }   
}