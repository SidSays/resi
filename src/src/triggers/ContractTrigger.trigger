trigger ContractTrigger on Contract__c(after insert,after update, before delete, after delete, before update, before insert) {
  try{
        TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('ContractTrigger');
        if(triggerSetting.isActive__c){       
            if(trigger.isAfter && trigger.isInsert){
                ContractTriggerSequencer.atferOperation();
                ContractTriggerSequencer.updateCoterminousCheck();
                ContractTriggerOperations.updateContractToArchived(Trigger.New);
            }else if(trigger.isAfter && trigger.isUpdate){        
                ContractTriggerSequencer.atferOperation();
                ContractTriggerSequencer.updateCoterminousCheck();
            }
            else if(trigger.isAfter && trigger.isDelete) {
                ContractTriggerSequencer.updateCoterminousCheck();
            }
            if(trigger.isBefore && trigger.isDelete){                
                ContractTriggerSequencer.beforeDelete();
            }
            if(trigger.isBefore && (trigger.isUpdate || trigger.isInsert) ){                
                ContractTriggerSequencer.expireDateSetInBefore();
            }            
        } 
     }
     catch(Exception e)
     {
        System.debug('Error message>>>>'+e.getMessage());
     }         
 }