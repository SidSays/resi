/**************************************************************************************************
Name : ContactTriggerOperation
Description : This class use to check whether primary contact already set for selected account else show validation message
User Story : 003 
Date : 11 December 2014
Author : Ashish Sonawane
***************************************************************************************************/
public class ContactTriggerOperation{


 //Data Member//
 /* Start of commenting - As Contact Trigger is Inactive and this class is calling from contact trigger that is why commenting the class to improve the code coverage
 private static final string OBJECT_TYPE = 'Contact'; 
 private static final string LABEL_NAME_SPLIT = ';'; 
 End of commenting -
 */
 
 /*
   Name : ShowPrimaryContactExist
   Description : Use to show validation message for setting primary contact to allready set account with primary conatct  
   Parameters : None
   Return : void      
 */
/* Start of commenting - As Contact Trigger is Inactive and this class is calling from contact trigger that is why commenting the class to improve the code coverage
 
  public static void showValidationOnContactBeforeInsertUpdate(){     
         
        //Get Developer Name Of Record Type And Fetch Record Only For Selected Record Type //Xfinity Contact Record Type
        String labelName = System.Label.XfinityContactRecordType;  
        Set<String> recordTypeSet = new Set<String>();
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(LABEL_NAME_SPLIT)){
                recordTypeSet.add(Schema.SObjectType.Contact.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }                    
        boolean bIsInsert = Trigger.IsInsert ? true : false;
        Map<id,Contact> mapOfOldContact = new Map<id,Contact>();
        List<Contact> lContactList = (List<Contact>)Trigger.New;
        
        //Check Whether It's Insert or Update trigger
        if(!bIsInsert){
            mapOfOldContact =(Map<id,Contact>) Trigger.OldMap;
        }
        else{
            //future code
        } 
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Contact> accountWithPrimaryCon = new Map<Id,Contact>();
         
        for(Contact contInstance : lContactList){
            if(!recordTypeSet.isEmpty() && recordTypeSet.contains(contInstance.RecordTypeId)){             
                if(bIsInsert){ 
                    accountIdSet.add(contInstance.AccountId);
                }  
                else if(contInstance.Primary_Contact__c && !mapOfOldContact.get(contInstance.id).Primary_Contact__c){                    
                    accountIdSet.add(contInstance.AccountId);           
                }else{
                    //future code
                } 
            }else{
                //future code
            }     
        }      
                             
        for(Contact instantContact : [SELECT id,Primary_Contact__c,AccountId 
                                        FROM Contact where accountid IN: accountIdSet
                                        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            if(instantContact.Primary_Contact__c){
                accountWithPrimaryCon.put(instantContact.accountId,instantContact);
            }else{
                //future code
            } 
        }      
        string validationMessage = System.Label.Primary_Contact_Trigger_Validation;  
        for(Contact conInstance:lContactList){
            if(accountWithPrimaryCon.containsKey(conInstance.accountId) && conInstance.Primary_Contact__c){
                conInstance.addError(validationMessage);
            }else{
                //future code
            } 
        }End of commenting -            
    }*/      
}