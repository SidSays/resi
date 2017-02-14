/**************************************************************************************************
Name : UserDeactivationBatch
Description : This batch class is created to deactivate users on that are either not active since 45 days or have never logged at all.
User Story : US608950
Date : 21/Jan/2016
Author : Radhika Bansal
***************************************************************************************************/

global class UserDeactivationBatch implements Database.Batchable<sObject> {
    global final String Query;
    
    global UserDeactivationBatch(String q)
    {
        Query=q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<User> scope) {
        List<GroupMember> grpMemberList = [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = :Label.Exclude_User_from_deactivation]; 
        List<Id> successfulRecords = new List<Id>();
        List<User> failedUserRecords = new List<User>();
        try{
            for(User UserObj: scope){
                Boolean check = false;
                for(GroupMember grpMember: grpMemberList)
                { 
                    if(UserObj.Id == grpMember.UserOrGroupId)
                    {
                        check = true;
                        break;
                    }
                }
                if(check == false)
                {
                    UserObj.IsActive = False; 
                    UserObj.Last_Deactivation_Date__c= System.now();
                    UserObj.Deactivation_Reason__c = Label.Deactivation_Reason;
                    UserObj.Deactivation_Status__c = Label.Success_Deactivate_users;   
                    if(UserObj.Deactivation_Failure_Reason__c != ''){
                        UserObj.Deactivation_Failure_Reason__c = '';  
                    } 
                }
            }
            Database.saveResult[] srList = database.update(scope, false);
            // Iterate through each returned result
            for (Integer i = 0; i< srList.size(); i++) {
                if (srList[i].isSuccess()) {
                    successfulRecords.add(srList[i].getID());
                }
                else {
                    // Operation failed, so get all errors   
                    scope[i].Deactivation_Status__c = Label.Failed_Deactivate_User;
                    scope[i].Last_Deactivation_Date__c= System.now();
                    scope[i].Deactivation_Reason__c= Label.Deactivation_Reason;
                    scope[i].IsActive = True;
                    String errorValue = '';
                    for(Database.Error err : srList[i].getErrors()) {  
                        errorValue += err.getMessage();
                    }
                    scope[i].Deactivation_Failure_Reason__c = errorValue;
                    failedUserRecords.add(scope[i]);
                }
            }
                   
            Database.saveResult[] srList1 = database.update(failedUserRecords, false);
            
            if(srList1!=null && !srList1.isEmpty()){
                for (Integer i = 0; i< srList1.size(); i++) {
                    if (!srList1[i].isSuccess()) {
                        String errValue=''; 
                        for(Database.Error err : srList1[i].getErrors()) {  
                            errValue+= err.getMessage();
                        }
                        system.debug('>>> Error Value for failed records:' + errValue);
                    }
                    
                }
            }
                    
        }catch(Exception e) {
            System.debug('the errors are'+ e.getMessage());
        }
    }
      
    global void finish(Database.BatchableContext BC) {
        //No action
    }
}