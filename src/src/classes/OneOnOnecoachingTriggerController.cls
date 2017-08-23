/**********************************************
* Class Name: OneOnOnecoachingTriggerController 
* Author: Mandeep Singh, Accenture
* Date: 30-December-2015 
* Last Modified By: Suchita Sharma
* Last Modified  Date: 10-April-2017
* Last Modified Details: User story number US1041357, 1-1 Metric actual update for Retail Sales Manager
* Last Modified By: Amit Kumar Pradhan
* Last Modified Date: 01-08-2017
* Description : Bypass validation message for retail sales manager
* User Story : US1141906(Coach/Wave App - Coaching Lightning Component - Create new 1:1 Coaching)
***********************************************/

public class OneOnOnecoachingTriggerController{ 

    public static boolean validationFlag = true;
    private static final string PROFILE_CHECK = 'RetailStoreManagerProfileId';
     
    /************************
    * @Description: This method Used for XSP to create new record(1:1 coaching) when relationship between XSP & SDM.
                    SDM to create new record(1:1 coaching) when relationship between SDM & ASM.   
    * @Author: Mandeep Singh, Accenture
    * @Date: 30-December-2015
    * @Param: Trigger.New
    * @Last Modified By: Amit Kumar Pradhan
    * @Last Modified Date: 01-08-2017
    * @Description : Bypass validation message for retail sales manager
    * @User Story : US1141906(Coach/Wave App - Coaching Lightning Component - Create new 1:1 Coaching)
    *************************/
    public static void OneOnOneCoachingValidation(List<one_one_Coaching__c> newCoachingList){       
        one_one_Coaching__c newCoachingAddErr = new one_one_Coaching__c();
        Id loggedInUserId = UserInfo.getUserId();
        Id loggedInUserProfileId = UserInfo.getProfileId();
        String rsmProfileId = '';//Part of US1141906
        List<one_one_Coaching__c> newCoachingAddErrList = new List<one_one_Coaching__c>();
        Set<Id> coachingIdSet = new Set<Id>();
        
        //Get coaching Id
        for(one_one_Coaching__c oneOneCoaching : newCoachingList){
            coachingIdSet.add(oneOneCoaching.coaching__c);
        } 
        
        /************************
        * User Story : US1141906 ----- Start
        * Description : Getting Retail Sales Profile id from custom setting
        * Last Modified By: Amit Kumar Pradhan
        * Last Modified Date: 01-08-2017
        *************************/
        Variable_Setting__c retailStoreMgrProfileId = Variable_Setting__c.getInstance(PROFILE_CHECK);
        if(retailStoreMgrProfileId != null){
            rsmProfileId = retailStoreMgrProfileId.Value__c;
        }
        /************************
        * User Story : US1141906 ----- End
        *************************/
                
        //collect coaching id And Coached Id
        for(WorkCoaching workCoachObj : [SELECT Id,CoachId,coachedId FROM WorkCoaching WHERE Id  IN :coachingIdSet]){
            for(one_one_Coaching__c coachingObj : newCoachingList) {
                //Putting retail store manager profile id check(Part of US1141906)
                if((workCoachObj.CoachId == loggedInUserId) && (loggedInUserProfileId != Label.CARManagerProfileId && (loggedInUserProfileId != Label.RetailSalesManagerProfileId) && (loggedInUserProfileId != rsmProfileId))){
                    validationFlag = false;
                    coachingObj.adderror(Label.Coaching_Record_Validation);
                    newCoachingAddErrList.add(newCoachingAddErr);                 
                }
            }   
        }
    }
    /**
    * @Description: Maping Task fields to 1-1 coaching record   
    * @Author: Mandeep Singh, Accenture
    * @Date: 30-December-2015
    * @Param: Trigger.New
    */           
    
    public static void coachingTaskMapping(List<one_one_Coaching__c> newCoachingList){        
        List<Task> tasksList = new list<Task>();
        Id recordTypeId_1_1 = Schema.SObjectType.Task.getRecordTypeInfosByName().get('1:1 Coaching').getRecordTypeId();
         
        if(newCoachingList.size()>0){
            for(one_one_Coaching__c newcCoachingObj : newCoachingList){                   
                if(newcCoachingObj!=null){
                    Task tsk = new Task();
                    tsk.Ownerid = UserInfo.getUserId();
                    tsk.Status ='Completed';
                    tsk.Subject ='1:1 Coaching';
                    tsk.RecordTypeId = recordTypeId_1_1;
                    tsk.ActivityDate= System.Today();
                    tsk.WhatId = newcCoachingObj.Coaching__c;
                    tasksList.add(tsk);
                }
            }  
            if(!tasksList.isEmpty()){
                Database.Insert(tasksList, false);
            }
        }

    }
     /**
    * @Description: US1051006 - Update metric recods based on creation of 1-1 Coaching record   
    * @Author: Accenture
    * @Date: 03-Feb-2017
    * @Param: Trigger.New 
    * @return: NA
    * Modification: US1051023: CAR Dir/Sr Mgr Observation Roll-up Actuals - 1:1 Coaching
    */           
    
    public static void updatemetricsrecord(List<one_one_Coaching__c> lstcoaching){        
        try{
            List<Metric> lstmetrics = new list<Metric>();
            Id propertyrecordtypeid = PL_Constants.PROPERTY_LAB_RECORD_TYPE_ID;
            list<Goal> lstgoals; 
            List<Database.SaveResult> srList = new List<Database.SaveResult>();
            Set<Id> coachIdSet = new Set<Id>();
            Date startdate = GoalTemplateDates__c.getValues(PL_Constants.GOAL_DATES_FOR_PROPERTY_LAB).Current_Period_Start_Date__c;
            Date duedate = GoalTemplateDates__c.getValues(PL_Constants.GOAL_DATES_FOR_PROPERTY_LAB).Current_Period_Due_Date__c;
            String metricname = ConstantHandler.oneonOneMetricName;
            String goalstatus = ConstantHandler.goalstatues;
            map<id,PermissionSetAssignment> mapassignment = new map<id,PermissionSetAssignment>();
            list<one_one_Coaching__c> lstfilteredlist = new list<one_one_Coaching__c>();
            set<string> setpermission = new set<string>();
            setpermission.add(ConstantHandler.carmanagerpermissionSet); //modified the If Condition for US1051023 to add director assingment.
            setpermission.add(ConstantHandler.cardirrpermissionSet); //modified the If Condition for US1051023 to add director assingment.
            //Fetch the Xfinity CAR Manager permission Set users
            for(PermissionSetAssignment objassignment :[SELECT AssigneeId, Assignee.Name,PermissionSetId, PermissionSet.Profile.Name 
                                                        FROM PermissionSetAssignment 
                                                        WHERE PermissionSet.Label IN:setpermission]){   //modified the where clause to add IN due to Director addition
                    mapassignment.put(objassignment.AssigneeId,objassignment);  
           }
           //Identify the Filtered list of 
            if(!lstcoaching.isEmpty()){
                for(one_one_Coaching__c oneOneCoaching : lstcoaching){
                    if(oneOneCoaching.Coach_Id__c!= null && mapassignment.containskey(oneOneCoaching.Coach_Id__c)){
                         coachIdSet.add(oneOneCoaching.Coach_Id__c);
                         lstfilteredlist.add(oneOneCoaching);
                    }
                } 
            } 
           if(!coachIdSet.isEmpty()){
                lstgoals = [SELECT g.Template_Type__c, g.Status, g.StartDate, g.RecordTypeId, g.OwnerId, g.Name, g.Id, g.DueDate, g.Assigned_To__c, 
                           (SELECT Name, CurrentValue,Goal_Template_Type__c FROM Metrics WHERE Name =:metricname) 
                            FROM Goal g WHERE g.OwnerId IN: coachIdSet AND  g.Status =: goalstatus 
                            AND RecordTypeId=:propertyrecordtypeid AND g.DueDate =: duedate AND g.StartDate =: startdate];
                                
                if(!lstgoals.Isempty()){
                    for(Goal objgoal:lstgoals){
                        for(one_one_Coaching__c oneOneCoaching : lstfilteredlist){
                            if(objgoal.OwnerId == oneOneCoaching.Coach_Id__c){
                                for(Metric objmetric:objgoal.Metrics){
                                    objmetric.CurrentValue = objmetric.CurrentValue+decimal.valueOf(ConstantHandler.metricincreasecounter);
                                    lstmetrics.add(objmetric);
                                }
                                
                            }
                        }
                    }
                }
            }           
           if(!lstmetrics.isempty()){
                srList = database.update(lstmetrics, false);
            }
        }catch(exception EX){
        }
    }
    /**
    * @Description: US1041357 - Indirect - Coach for Indirect - Retail Sales Manager - Activity Goal - Number of 1:1s -  Metric Actual  
    * @Author: Accenture
    * @Date: 03-April-2017
    * @Param: Trigger.New
    * @return: NA
    */

    public static void updateRetailManagerMetric(List<one_one_Coaching__c> oneOneChoachingList){        
    try{
            List<Metric> lstmetrics = new List<Metric>();
            List<Goal> lstgoals; 
            List<Database.SaveResult> srList = new List<Database.SaveResult>();
            Set<Id> coachIdSet = new Set<Id>();
            Date startdate = GoalTemplateDates__c.getValues(Indirect_Constants.INDIRECTACTIVITYGOALCOMMISSIONCYCLE).Current_Period_Start_Date__c;
            Date duedate = GoalTemplateDates__c.getValues(Indirect_Constants.INDIRECTACTIVITYGOALCOMMISSIONCYCLE).Current_Period_Due_Date__c;
            Map<id,PermissionSetAssignment> mapassignment = new Map<id,PermissionSetAssignment>();
            List<one_one_Coaching__c> lstfilteredlist = new List<one_one_Coaching__c>();
            Set<string> setpermission = new Set<string>();
            setpermission.add(System.Label.Retail_Sales_Manager_Permissionset); 
            //Fetch the Retail Sales Manager permission Set users
            for(PermissionSetAssignment objassignment :[SELECT AssigneeId, Assignee.Name,PermissionSetId, PermissionSet.Profile.Name 
                                                        FROM PermissionSetAssignment 
                                                        WHERE PermissionSet.Label IN:setpermission
                                                        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){   
                    mapassignment.put(objassignment.AssigneeId,objassignment);  
           }
           //Identify the Filtered list of Coaching
            if(!oneOneChoachingList.isEmpty()){
                for(one_one_Coaching__c oneOneCoaching : oneOneChoachingList){
                    if(oneOneCoaching.Coach_Id__c!= null && !mapassignment.isEmpty() && mapassignment.containskey(oneOneCoaching.Coach_Id__c)){
                         coachIdSet.add(oneOneCoaching.Coach_Id__c);
                         lstfilteredlist.add(oneOneCoaching);
                    }
                } 
            } 
           if(!coachIdSet.isEmpty()){
                lstgoals = [SELECT g.Template_Type__c, g.Status, g.StartDate, g.RecordTypeId, g.OwnerId, g.Name,            g.Id,g.DueDate, g.Assigned_To__c, 
                           (SELECT Name, CurrentValue,Goal_Template_Type__c FROM Metrics WHERE Name =:System.Label.NumberOf1_1s) 
                            FROM Goal g 
                            WHERE g.OwnerId IN: coachIdSet AND RecordtypeId =: Indirect_Constants.INDIRECT_RECORD_TYPE_ID AND Status =: Indirect_Constants.GOAL_STATUS_PUBLISHED AND goal.Profile_Name__c =:  System.Label.Retail_Sales_Manager_ProfileName AND g.DueDate =: duedate
                                    AND g.StartDate =: startdate 
                            LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                                
                if(lstgoals!=null && !lstgoals.Isempty()){
                    for(Goal objgoal:lstgoals){
                        for(one_one_Coaching__c oneOneCoaching : lstfilteredlist){
                            if(objgoal.OwnerId == oneOneCoaching.Coach_Id__c){
                                for(Metric objmetric:objgoal.Metrics){
                                    if(objmetric.CurrentValue == null){
                                        objmetric.CurrentValue = 0;                                     
                                    }                                   
                                    objmetric.CurrentValue = objmetric.CurrentValue+decimal.valueOf(ConstantHandler.metricincreasecounter);                                 
                                    lstmetrics.add(objmetric);
                                }
                                
                            }
                        }
                    }
                }
            }           
           if(!lstmetrics.isempty()){
                MetricTriggerController.allowValidation = false;
                srList = database.update(lstmetrics, false);
            }
        }catch(exception e){
        System.debug('***Exception has occured ***'+e.getMessage());
        }
    }
}