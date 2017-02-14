/**************************************************************************************************
Name : CARActivityTrackerHelper
Description : This class update the Event metrics of Car and Car Manager when CAR create a sales Event. 
User Story : US760932
Date : 01 Sept 2016
Author : Amit Kumar Pradhan
***************************************************************************************************/

public  without sharing class CARActivityTrackerHelper {
    private static final String GOAL_STATUS = 'Published';
    private static final String EVENT_METRIC = Label.Metric_Name_Events;
    private static final String PROPERTY_LAB_GOAL_TEMPLATE = 'Property Lab CAR';
    
    //update the Event metrics of Car and Car Manager when CAR create a sales Event 
    
    public static void updateMetricForCarANDMgr(List<Task> newTasksList){
        
        Date preGoalStartDate = null;
        Date preGoalDueDate = null; 
        String managerId = null;
        Map<String, Metric> ownerIdMetricMap = new Map<String, Metric>();
        List<Metric> metricList= new List<Metric>();
        Metric metricToUpdate;
        try{
            String recordTypeProgress = Schema.SObjectType.Metric.getRecordTypeInfosByName().get(system.label.MetricProgress).getRecordTypeId();
          
            //Get the Fiscal Year Date period goal start/due dates            
            GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(PROPERTY_LAB_GOAL_TEMPLATE);             
            if(goalDates != null){
                preGoalStartDate = goalDates.Current_Period_Start_Date__c;  
                preGoalDueDate =  goalDates.Current_Period_Due_Date__c;
            } 
            
            User userObj = [SELECT ID, ManagerId FROM User WHERE ID =: UserInfo.getUserId() LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            
            if(userObj.ManagerId != null){
                managerId = userObj.ManagerId;
            }
            //Fetching Event metrics of CAR and Car Manager
            For(Metric metricObj : [SELECT ID, OwnerId, TargetValue, CurrentValue FROM Metric WHERE name like : EVENT_METRIC AND Goal.Status =: GOAL_STATUS 
                                       AND Goal.StartDate =: preGoalStartDate AND Goal.DueDate =:preGoalDueDate AND Recordtypeid =:recordTypeProgress 
                                       AND (OwnerId =: UserInfo.getUserId() OR OwnerId =: managerId) LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                
                ownerIdMetricMap.put(metricObj.OwnerId,metricObj);                         
                                       
            }
            //System.debug('ownerIdMetricMap*****'+ownerIdMetricMap);
            
            for(Task TaskTemp : newTasksList){
                if(TaskTemp.CAR_Activity_Type__c==Label.SalesEventActivityType) {
                    //Updating Car metric
                    if(ownerIdMetricMap.containsKey(UserInfo.getUserId())){
                        metricToUpdate = ownerIdMetricMap.get(UserInfo.getUserId());                
                        metricToUpdate.CurrentValue = metricToUpdate.CurrentValue == NULL ? 1 : metricToUpdate.CurrentValue+1;               
                        metricList.add(metricToUpdate);
                    }
                    //Updating Car Manager metric
                    If(managerId != null && ownerIdMetricMap.containsKey(managerId)){
                        metricToUpdate = ownerIdMetricMap.get(managerId);               
                        metricToUpdate.CurrentValue = metricToUpdate.CurrentValue == NULL ? 1 : metricToUpdate.CurrentValue+1;               
                        metricList.add(metricToUpdate);
                    }    
                } 
                 
            }
            //System.debug('metricList*****'+metricList);
            if(!metricList.isEmpty()){
                database.update(metricList,false); 
            }
        }catch(Exception e){
            System.debug('Exception------'+e.getMessage());
        }   
    } 
}