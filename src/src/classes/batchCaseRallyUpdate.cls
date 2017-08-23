/************************************************************************************************************************************************************
Name: batchCaseRallyUpdate
Description: This class contains batch update logic for updating Case fields based on updates to Rally. And send email if there are any errors in processing.
Author: Vikram Tummala
Date 02 March 2017
Modification History:
Amit Kumar: 11-JULY-2017 - US1141978: Modified the code to bring the Blocked and blocked reason for a Case which is associated with a Rally US
*************************************************************************************************************************************************************/
global class batchCaseRallyUpdate implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
 public List<string> errors = new List<string>();
 public static final String STR_BLOCKEDREASON = 'BlockedReason';  //Added by AK for US1141978 to captured the blocked reason
 public static final string STR_BLOCKED = 'Blocked';  //Added by AK for US1141978 to captured the blocked reason
 public static final string STR_TRUE = 'True';  //Added by AK for US1141978 to captured the blocked reason
 public static final string STR_FALSE = 'False';  //Added by AK for US1141978 to captured the blocked reason
 Exception[] excps = new Exception[0];
 global Database.QueryLocator start(Database.BatchableContext BC)
 {
    String query = 'Select Id,caseNumber, Rally_ID__c, Status from Case where (Rally_ID__c != null and Status !=\'Closed\')';
    return Database.getQueryLocator(query);
 }
  
 global void execute(Database.BatchableContext BC, List<sObject> scope)
 {
    string response;
    List<Case> toupdate = new List<Case>();
    List<Case> Cases = (List<case>)scope;
    for(case c : Cases){
     string caseNum = c.Rally_ID__c;
     string scheduleState;
     string kanban;
     HttpRequest req = new HttpRequest();
     rally_url__c settings = rally_url__c.getValues('Rally');
     string ep = settings.GET_EP__c;
     string endpoint = 'callout:Rally/'+caseNum+ep;
     req.setEndpoint(endpoint);
     req.setMethod('GET');
     Http http = new Http();
     try{
         HTTPResponse res = http.send(req);
         response = res.getBody();
     }catch (System.CalloutException e){
             excps.add(e);
             System.debug('ERROR:' + e);
     }
     //System.debug(res.getBody());
     if(response != null){
     Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(response);
     if(rawObj.get('OperationResult') != null){
     Map<String,Object> rObj = (Map<String,Object>)rawObj.get('OperationResult');
     if(rObj.get('Errors') != null){
          List<Object> e = new List<Object>();
          e = (List<Object>)robj.get('Errors');
          for(Object a: e){
          errors.add(c.caseNumber+': '+String.valueOf(a));
          }
       }
     }
     if(rawObj.get('HierarchicalRequirement') != null){
     Map<String,Object> responseObj = (Map<String,Object>)rawObj.get('HierarchicalRequirement');
     //system.debug(responseObj);
     if(responseObj.get('Iteration') != null){
     Map<String,Object> iterObj = (Map<String,Object>) responseObj.get('Iteration');
     for (String field : iterObj.keySet()){
         if(field == 'Name'){              
            c.Iteration__c = (string)iterobj.get(field);
         }
       }
     }
     if(responseObj.get('Release') != null){  
     Map<String,Object> releaseObj = (Map<String,Object>) responseObj.get('Release');
     for (String field : releaseObj.keySet()){
          if(field == 'Name'){          
           c.Release__c = (string)releaseobj.get(field);
         }
       }
      }
     if(responseObj.get('c_KanbanState') != null){
          c.Kanban_State__c = (string)responseobj.get('c_KanbanState');
          kanban = (string)responseobj.get('c_KanbanState');
     }
     if(responseObj.get('ScheduleState') != null){
          c.Schedule_State__c = (string)responseobj.get('ScheduleState');
          scheduleState = (string)responseobj.get('ScheduleState');
       }
        /**********  Added by AK for US1141978 to add the blocked and blocked Reason *************   START   *********/
        if(responseobj.get(STR_BLOCKED)!=null && (string.valueof(responseobj.get(STR_BLOCKED))).equalsIgnoreCase(STR_TRUE) ){
          c.Blocked__c = true;
          if(responseobj.get(STR_BLOCKEDREASON)!=null){
          	c.Blocked_Reason__c = (string)responseobj.get(STR_BLOCKEDREASON);
          }else{
          	c.Blocked_Reason__c = null;
          }
        }else if(responseobj.get(STR_BLOCKED)!=null && (string.valueof(responseobj.get(STR_BLOCKED))).equalsIgnoreCase(STR_FALSE)){
          c.Blocked__c = false;
          c.Blocked_Reason__c = (string)responseobj.get(STR_BLOCKEDREASON);
        }
        
       /**********  Added by AK for US1141978 to add the blocked and blocked Reason *************   END   *********/ 
      }
     if(scheduleState == 'Backlog' || scheduleState == 'Defined'){          
           c.Status = 'Approved and Added to Backlog';
     }
       else if(scheduleState == 'In-Progress' || scheduleState == 'Completed'){          
              c.Status = 'In Progress';
       }
         else if(scheduleState == 'Accepted'){          
              c.Status = 'Added to Release Plan';
         }       
     if(kanban != null && kanban == 'Deployed'){
           c.Kanban_State__c = kanban;
           c.Status = 'Closed';
           c.Resolution_Categories__c = 'User Story';
           c.Resolution_Notes__c = 'Released';
     } 
      
         toupdate.add(c);
      }
     }
     try{
      if(toupdate != null){
       update toupdate;
       }
       }catch (DMLException e){
             excps.add(e);
             System.debug('ERROR:' + e);
       }  
 }
 
 global void finish(Database.BatchableContext bc) {
            list<string> toadd = new list<string>(); 
            string address = System.Label.RallyBatchEmail;
            toadd.add(address);
            if(!errors.isEmpty() || !excps.isEmpty()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Errors for Rally Batch Process.');
            mail.setToAddresses(toadd);
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody('Errors: '+errors+'\nExceptions:'+excps);
            Messaging.sendEmail(new Messaging.Email[] { mail });
            }
 }
 
}