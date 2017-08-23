/*
* Author : Tejaswini Datta Kasar
*@Modified By: Animesh
*@Last Modification Details: US1137734(XC DT - Only count completed visits). Calling method "propertyVisitCountGoal" in after update instead of insert 
*@Modified Date: 7/11/2017
*/
trigger PropertyVisitTrigger on Property_Visit__c (after insert,after update) {
    
    try{
        TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('PropertyVisitTrigger');
        if(triggerSetting.isActive__c){
            if(Trigger.isafter){
                if(Trigger.isInsert){
                    //Start - Animesh - US1137734 - 7/11/2017 - Commented code as metric will be updated when status is changed to completed i.e. Update event
                    //PropertyVisitTriggerController.propertyVisitCountGoal(Trigger.new);//US1137734
                    //End - Animesh - US1137734 - 7/11/2017 - Commented code as metric will be updated when status is changed to completed i.e. Update event
                }
                //Start - Animesh - US1137734 - 7/11/2017 - Update metric when property visit is marked as completed
                if(Trigger.isUpdate){
                    PropertyVisitTriggerController.propertyVisitCountGoal(Trigger.new,Trigger.oldMap);
                }
                //End - Animesh - US1137734 - 7/11/2017 - Update metric when property visit is marked as completed
            }
        }
    }catch(Exception e){
        System.debug('>>>>>>>>>>>>>Error Message'+e.getMessage());
    }      
}