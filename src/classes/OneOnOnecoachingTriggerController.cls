/**
* Class Name: OneOnOnecoachingTriggerController 
* Author: Mandeep Singh, Accenture
* Date: 30-December-2015 
*/

public class OneOnOnecoachingTriggerController{

    public static boolean validationFlag = true;
    
  /**
    * @Description: This method Used for XSP to create new record(1:1 coaching) when relationship between XSP & SDM.
                    SDM to create new record(1:1 coaching) when relationship between SDM & ASM.   
    * @Author: Mandeep Singh, Accenture
    * @Date: 30-December-2015
    * @Param: Trigger.New
  */
    public static void OneOnOneCoachingValidation(List<one_one_Coaching__c> newCoachingList){       
        one_one_Coaching__c newCoachingAddErr = new one_one_Coaching__c();
        Id loggedInUserId = UserInfo.getUserId();
        Id loggedInUserProfileId = UserInfo.getProfileId();
        
        List<one_one_Coaching__c> newCoachingAddErrList = new List<one_one_Coaching__c>();
        Set<Id> coachingIdSet = new Set<Id>();
        
        //Get coaching Id
        for(one_one_Coaching__c oneOneCoaching : newCoachingList){
            coachingIdSet.add(oneOneCoaching.coaching__c);
        } 
       
        //collect coaching id And Coached Id
        for(WorkCoaching workCoachObj : [SELECT Id,CoachId,coachedId FROM WorkCoaching WHERE Id  IN :coachingIdSet]){
            for(one_one_Coaching__c coachingObj : newCoachingList) {
                if((workCoachObj.CoachId == loggedInUserId) && (loggedInUserProfileId != Label.CARManagerProfileId && (loggedInUserProfileId != Label.RetailSalesManagerProfileId))){
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
}