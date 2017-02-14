/**************************************************************************************************
Name : IndirectAddTaskController 
Description : This class is created to get the task related data and save the task record for Indirect Redesign
User Story : US668758 and US674971
Date : 3 May 2016
Author : Suchita Sharma

***************************************************************************************************/


public class IndirectAddTaskController {
    @AuraEnabled
    public static String getTaskData(String storeId){
          List<String> statusOptions = new List<String>();
          List<String> priorityOptions = new List<String>();
          Store_Visit__c storeVisits = [
                    Select id,Name,Store_Visit_Name__c from Store_Visit__c 
                    where Store__c=:storeId 
                    and Store_Visit_Status__c='Active' 
                    limit 1];
                
           Schema.DescribeFieldResult fieldResult = Task.Status.getDescribe();
           List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
           for( Schema.PicklistEntry f : ple){
              statusOptions.add(f.getLabel());
           }     
           
           Schema.DescribeFieldResult fieldResult2 = Task.Priority.getDescribe();
           List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
                
           for( Schema.PicklistEntry f : ple2){
              priorityOptions.add(f.getLabel());
           }    
          
          return System.json.serialize(new TaskDetails (statusOptions,priorityOptions,storeVisits));
        }
    //Wrapper class 
    public class TaskDetails{
        List<String> statuses;
        List<String> priorities;
        Store_Visit__c storeVisits;
        
        public TaskDetails(List<String> statuses, List<String> priorities, Store_Visit__c storeVisits){
            this.statuses = statuses;
            this.priorities = priorities;
            this.storeVisits = storeVisits;
        }
    }
     @AuraEnabled
     public static Task CreateTask(Task task,String whatId,String status,String priority){ 
            Task t=new Task();
            t.Subject=task.Subject;          
            t.WhatId=whatId;           
            t.Description=task.Description;
            t.ActivityDate=task.ActivityDate;
            t.Status=status;
            t.Priority=priority;

            insert t;
            return t;
        }
    
    //Method for getting the recommended Activity on doInit
    @AuraEnabled
    public static List<String> getRecommendedCategories(String storeId, List<Store_Visit_Activity_Category__c> categories,
                                                        String loggedInUserId)
    {   
        List<String> messageList = new List<String>();
        List<String> recordTypeList = new List<String>();
        List<Store_Visit__c> storeVisit = new List<Store_Visit__c>();
        List<Store_Activity__c> storeActList = new List<Store_Activity__c>();
        Map<Id,String> result = new Map<Id,String>();
        String Msg='You have completed all recommended activities';
      
        for(Store_Visit_Activity_Category__c ct: categories){
            if(ct.Number_Required__c > 0)          
                recordTypeList.add(ct.Record_Type_Id__c);       
        }
        
        storeVisit=[Select Id from Store_visit__c where store__c =:storeId AND Store_Visit_Status__c = 'Active' 
                    AND OwnerId = :loggedInUserId ORDER BY LastModifiedDate DESC LIMIT 1];
        
        Set<Id> setStoreVisitId = new  Set<Id>(); 
        
        if(storeVisit!=null){
            for(Store_Visit__c sv : storeVisit){
                setStoreVisitId.add(sv.Id);
            }
        }
        
        if(setStoreVisitId != null){            
            storeActList =  [Select Id, Name,Store_Visit__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName,
                             Store_Type__c,Is_Activity_Completed__c from Store_Activity__c where  Store_Visit__c In :setStoreVisitId 
                             and recordTypeId In :recordTypeList and Store__c != null];
            
            integer size = storeActList.size();            
            for(Store_Visit_Activity_Category__c ct: categories){
                if(ct.Number_Required__c > 0){
                    result.put(ct.Record_Type_Id__c, ct.Store_Activity_Category__c);
                    for(integer i=0; i<size ; i++){
                        if(storeActList[i].recordTypeId == ct.Record_Type_Id__c  && storeActList[i].Is_Activity_Completed__c == true){
                            if(result.size()>0){
                                result.remove(ct.Record_Type_Id__c);                                
                            }
                        }
                    }
                }
            }
        }
        
        if(!result.isEmpty()){
            return result.values();
        }else{
            messageList.add(Msg);           
            return messageList;
        }        
        
    } 
}