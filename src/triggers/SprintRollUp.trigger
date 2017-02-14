trigger SprintRollUp on Action_Item__c (after delete, after update, after insert, after undelete) {

/*Trigger for Rollup Summary field Total Estimated Points on Sprint object*/

 List<Sprint__c> Sprints = new List<sprint__c>();
 List<Action_Item__c> tempList = new list<Action_Item__c>();
 Sprint__c tempsp = new Sprint__c();
 Set<Id> SprintIds = new Set<Id>();

 if(trigger.isInsert){
  for(Action_Item__c actItem : Trigger.new){
      if(actItem.Sprint__c != null){
       SprintIds.add(actItem.Sprint__c);
      } 
   }
}
   else if(trigger.isDelete){
    for(Action_Item__c actItem : Trigger.old){
        if(actItem.Sprint__c != null){
         SprintIds.add(actItem.Sprint__c);
        }
     }
 }
    else if(trigger.isUnDelete){
     for(Action_Item__c actItem : Trigger.new){
     if(actItem.Sprint__c != null){
      SprintIds.add(actItem.Sprint__c);
      }
     }
  }
    else if(trigger.isUpdate){
     for(Action_Item__c actItem : trigger.new){     
     if(trigger.oldmap.get(actItem.id).Sprint__c!=actItem.Sprint__c && trigger.oldmap.get(actItem.id).Sprint__c != null){
      if(actItem.Sprint__c != null){
       SprintIds.add(actItem.Sprint__c);
      }
      SprintIds.add(trigger.oldmap.get(actItem.id).Sprint__c);
     }
      else{
       if(actItem.Sprint__c != null){       
        SprintIds.add(actItem.Sprint__c);
        }
       } 
      }
    }
  
 /*Check for Sprints that don't have any records remaining after the trigger runs and mark Total Estimated Points as zero */
    
   for(Id spid : SprintIds){
     tempList = [SELECT id, Estimated_Hours__c, Sprint__c FROM Action_Item__c where Sprint__c =: spid];
       if(tempList.size() == 0){
       tempsp = [SELECT Total_Estimated_Hours__c, Id  FROM Sprint__c where Id =: spid];
       tempsp.Total_Estimated_Hours__c = 0;
       Sprints.add(tempsp);
       SprintIds.remove(spid);
       }
 }
 
 /*Update the Total Estimated Points based on the records in the trigger */
   
AggregateResult[] groupedResults = [SELECT COUNT(Id) idCount, SUM(Estimated_Hours__c), Sprint__c  FROM Action_Item__c where Sprint__c IN :SprintIds GROUP BY Sprint__c ]; 
   for(AggregateResult ar:groupedResults) {
        Id tempid = (ID)ar.get('Sprint__c');
        Decimal sum = (Decimal)ar.get('expr0');
        Sprint__c temp1 = new Sprint__c(Id=tempid);
        temp1.Total_Estimated_Hours__c = sum;
        Sprints.add(temp1);
     }
     update Sprints;
}