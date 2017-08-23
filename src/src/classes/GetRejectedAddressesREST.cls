@RestResource(urlMapping='/GetRejectedAddressesREST/*')
/**
*Ashish Srivastava  06/03/2016 : US693122 DSM: Reject Filter Enhancement
*/
global with sharing class GetRejectedAddressesREST{

@HttpGet
global static List<Customer_Address__c> doGet(){
    
    RestRequest request = RestContext.request;
    String planId = request.params.get('planId');
    Date startDate = Date.valueOf(request.params.get('startDate')); //System.Today();
    Date endDate =  Date.valueOf(request.params.get('endDate')); //startDate - 179;
    TimeZone tz = UserInfo.getTimeZone(); 
    DateTime dt1 = DateTime.newInstance(startDate.year(),startDate.month(),startDate.day(),0,0,0);
    DateTime dt2 = DateTime.newInstance(endDate.year(),endDate.month(),endDate.day(),23,59,59);
    String RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(Label.Knock).getRecordTypeId();
    List<Customer_Address__c> addressList = new List<Customer_Address__c>();
    
    //Retrieve the List of Addresses in the Plan
    List<Customer_Address__c> addressPlanList = [SELECT Id,Account_Name__c,Address__c,Plan__c,OwnerId,Rejected_Reason__c 
                                                 From Customer_Address__c WHERE Plan__c = :planId AND Rejected_Reason__c != null AND Last_Knock_Date__c>= :dt1];
    Set<Id> addrIDs = new Set<Id>();
    for(Customer_Address__c addr : addressPlanList){
          addrIDs.add(addr.Id);
     }
     Map<Id,List<Task>> rejectedTaskMap = new Map<Id,List<Task>>();
     List<Task> rejectedTaskList = new List<Task>();
     List<Task> rejectedList = [SELECT Id,WhatId,CreatedDate,Rejected_Reason__c FROM Task WHERE RecordType.Id = :RecordTypeId AND WhatId IN :addrIDs AND Rejected__c = True AND Rejected_Reason__c != null AND CreatedDate >= :dt1 AND CreatedDate <= :dt2];   
     for(Customer_Address__c addrList : addressPlanList){
          for(Task taskList : rejectedList){
              if(taskList != null && taskList.WhatId == addrList.Id){
                      rejectedTaskList.add(taskList);
                  
           }
      }
      if(!rejectedTaskList.isEmpty()) {
            rejectedTaskMap.put(addrList.Id,rejectedTaskList);
      }  
      }
      Set<Id> addressIDs = rejectedTaskMap.keySet();
       
      addressList = [SELECT Id,Account_Name__c,Address__c,Plan__c,OwnerId, Last_Knock_Date__c, LastModifiedDate, Rejected_Reason__c,(SELECT Id, WhatId,CreatedDate,Rejected_Reason__c FROM Tasks WHERE Rejected_Reason__c != null AND Rejected__c = true) 
                    From Customer_Address__c WHERE Id IN : addressIDs AND Rejected_Reason__c != null  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                    
           //Creating wrapper Objects for the API
           try{
               return addressList;
           }
          catch(Exception e){
              System.debug('Exception occured' + e);
              return null;
          }
   }
}