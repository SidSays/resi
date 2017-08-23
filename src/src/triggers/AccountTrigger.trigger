/**
 * Trigger for Account object
 *
 * @Author Ryan Sayles <rsayles@acumensolutions.com>
 * @Date 9/26/14
 * Updated By: Animesh Datta, Date - 3-Nov-2016, calling Method - endActiveStoreVisitOwnerChage, mark active store visit as completed if store owner is changed.
 */
/*
* MDU Implementation - Method added for Parent Account assignment functionality.
* Method added to validate the access to modify the parent account.
*/
trigger AccountTrigger on Account (after insert, before delete, before insert, before update,after update) {         
      //Data Transformation callout
    if(TriggerSettings__c.getValues('AccountTrigger') != null && TriggerSettings__c.getValues('AccountTrigger').IsActive__c){
        if(Trigger.isafter){        
                if(Trigger.isInsert){              
                    //Data Transformation class               
                    DataTransformation.dataTransform(Trigger.New);
                } 
                if(Trigger.isUpdate){
                     Boolean flag = false;
                    for(account a :trigger.new){
                       if((trigger.newMap.get(a.id).Last_Install_Date__c != trigger.oldMap.get(a.id).Last_Install_Date__c) || (trigger.newMap.get(a.id).Type != trigger.oldMap.get(a.id).Type)){
                          flag = true;  
                        }
                    } 
                    
                    if(flag==true){
                        //Data Transformation class 
                        DataTransformation.dataTransform(Trigger.new);
                    }
                }           
         } 
    }
     
    if(TriggerSettings__c.getValues('XfinityAccountTrigger')!=null && TriggerSettings__c.getValues('XfinityAccountTrigger').IsActive__c){
        if(Trigger.isBefore){
        
            if(Trigger.isInsert){
                AccountTriggerHelper.suffixParentAccountName(Trigger.New);
                AccountTriggerHelper.assignParentBeforeInsert(Trigger.New);
                
            } 
            
            if(Trigger.isUpdate){    
                AccountTriggerHelper.validateAccessBeforeUpdate(Trigger.New, Trigger.OldMap);
                AccountTriggerHelper.assignParentBeforeUpdate(Trigger.New, Trigger.OldMap);
            }                              
        }
    
    }
    if(TriggerSettings__c.getValues('AccountTrigger') != null && TriggerSettings__c.getValues('AccountTrigger').IsActive__c) {
      if(Trigger.isBefore){
      //AccountTriggerController.setAccountLastInstallDate(Trigger.New);
       
            if(Trigger.isInsert){
                AccountTriggerHelper.populateParentAccount(Trigger.New);
            }
            if(Trigger.isUpdate){
                AccountTriggerHelper.populateParentAccount(Trigger.New);
               
            }
            if(Trigger.isDelete){
                AccountTriggerHelper.deleteRelatedStoreVisits(Trigger.OldMap);
            }
      } else{
            if(Trigger.isUpdate || Trigger.isInsert){
                AccountTriggerHelper.addressOrangeFieldUpdate(Trigger.New, Trigger.OldMap);
            }
      }       
    }
    
    if(TriggerSettings__c.getValues('StoreAccountTrigger') != null && TriggerSettings__c.getValues('StoreAccountTrigger').IsActive__c){
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                //future code
            }
            if(Trigger.isUpdate){
                //future code
            }
            if(Trigger.isDelete){
                //future code
            }
        }
        else{
            if(Trigger.isUpdate){
                    AccountTriggerHelper.endActiveStoreVisitOwnerChage(Trigger.New,Trigger.OldMap);
            }
      }
    }
}