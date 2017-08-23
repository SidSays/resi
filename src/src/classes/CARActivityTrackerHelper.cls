/**************************************************************************************************
Name : CARActivityTrackerHelper
Description : This class update the Event metrics of Car and Car Manager when CAR create a sales Event. 
User Story : US760932
Date : 01 Sept 2016
Author : Amit Kumar Pradhan
Last Updated : 24/2/2017
Last Updated By : Malay Desai (US932263)
***************************************************************************************************/

public  without sharing class CARActivityTrackerHelper {
    
    //update the Sales Event metric for CAR, CAR Manager and CAR Director when a CAR create a Sales Event 
    public static void updateMetrics(List<Task> newTasksList){
        
        Date preGoalStartDate = null, preGoalDueDate = null;
        String managerId = null, srManagerId= null, carDirectorId=null;
        Map<String, Metric> ownerIdMetricMap = new Map<String, Metric>();
        List<Metric> metricList= new List<Metric>();
        Metric metricToUpdate;
        Id loggedInUserId = UserInfo.getUserId();
        try{
            //Get the Fiscal Year Date period goal start/due dates            
            GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(PL_Constants.GOAL_DATES_FOR_PROPERTY_LAB);             
            if(goalDates != null){
                preGoalStartDate = goalDates.Current_Period_Start_Date__c;  
                preGoalDueDate   = goalDates.Current_Period_Due_Date__c;
            } 
            
            for(User userObj: [SELECT Id,ManagerId,Manager.IsActive, Manager.ManagerId, Manager.Manager.IsActive FROM User 
                               WHERE ID = :loggedInUserId LIMIT 1]){
                if(userObj.ManagerId != null && userObj.Manager.IsActive){
                    managerId = userObj.ManagerId;
                } 
                if(userObj.Manager.ManagerId != null && userObj.Manager.Manager.IsActive){
                    srManagerId = userObj.Manager.ManagerId;
                } 
            }
            
            for(PermissionSetAssignment psa :  
                    [SELECT AssigneeId FROM PermissionSetAssignment  WHERE AssigneeId IN (:managerId, :srManagerId)
                     AND PermissionSet.Name = :PL_Constants.PERM_SET_FOR_CAR_DIR_SR_MGR]){
                carDirectorId = psa.AssigneeId; 
            }
            
            //Fetching Event metrics of CAR and CAR Manager
            for(Metric metricObj : 
                    [SELECT ID, OwnerId, TargetValue, CurrentValue FROM Metric WHERE Name = :PL_Constants.METRIC_SALES_EVENT 
                     AND Goal.Status =: PL_Constants.GOAL_STATUS_PUBLISHED AND Goal.StartDate =: preGoalStartDate 
                     AND Goal.DueDate =:preGoalDueDate AND OwnerId IN (:loggedInUserId, :managerId, :carDirectorId ) 
                     LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                
                ownerIdMetricMap.put(metricObj.OwnerId,metricObj);                         
            }
            
            for(Task TaskTemp : newTasksList){
                if(TaskTemp.CAR_Activity_Type__c==PL_Constants.METRIC_SALES_EVENT) {
                    //Updating CAR metric
                    if(ownerIdMetricMap.containsKey(loggedInUserId)){
                        metricToUpdate = ownerIdMetricMap.get(loggedInUserId);                
                        metricToUpdate.CurrentValue = metricToUpdate.CurrentValue == null ? 1 : metricToUpdate.CurrentValue+1;               
                        metricList.add(metricToUpdate);
                    }
                    //Updating CAR Manager metric (Could be CAR Manager or CAR Director)
                    if(managerId != null && ownerIdMetricMap.containsKey(managerId)){
                        metricToUpdate = ownerIdMetricMap.get(managerId);               
                        metricToUpdate.CurrentValue = metricToUpdate.CurrentValue == null ? 1 : metricToUpdate.CurrentValue+1;               
                        metricList.add(metricToUpdate);
                    }    
                    //Updating CAR Manager's Manager metric (Must be CAR Director)
                    if(carDirectorId != null && ownerIdMetricMap.containsKey(carDirectorId) && carDirectorId != managerId ){
                        metricToUpdate = ownerIdMetricMap.get(carDirectorId);               
                        metricToUpdate.CurrentValue = metricToUpdate.CurrentValue == null ? 1 : metricToUpdate.CurrentValue+1;               
                        metricList.add(metricToUpdate);
                    }
                } 
            }
            if(!metricList.isEmpty()){
                Database.update(metricList,true); 
            }
        }catch(Exception e){
            System.debug('Exception------'+e.getMessage());
        }   
    } 
}