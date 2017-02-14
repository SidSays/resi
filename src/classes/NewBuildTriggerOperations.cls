/** **********************************************************************
* Name: NewBuildTriggerOperations
* Author: Jui Desai
* User Story :
* Description: This class is used to perform operations for NewBuildTrigger events
    Date                 PRJ/DFCT/ENHC#            Summary of Changes 
  -------------         -----------------       ------------------------------
  08-May-2015        Comcast Resi(MDU)              Initial Release 
  
**************************************************************************/
public class NewBuildTriggerOperations{
    
    /* Data Member */
    private static final string ACTIVE_STATUS = System.Label.NewBuild_Status_Active;
    
    /*
    * Changes the property Status based on child records Completed Status after insert
    */
    public static void afterInsertNewBuild(){
        List<New_Build__c> NewBuildList = (List<New_Build__c>)Trigger.New;
        Set<Id> PropertIdSet = new Set<Id>();
        for(New_Build__c NewBuildObj : NewBuildList){
            PropertIdSet.add(NewBuildObj.Property__c);
        }
        updateStatus(PropertIdSet);
    }  
    
    /*
    * Changes the Property Status based on child records Completed Status after update
    */
    public static void afterUpdateNewBuild(){
        Set<id> PropertIdSet = new Set<id>();
        Map<id,New_Build__c> oldNewBuildMap = (Map<id,New_Build__c>) Trigger.OldMap;
        for(New_Build__c tempNewBuild : (List<New_Build__c>)Trigger.New){
            //Check whether Completed status on new new build change 
            if(oldNewBuildMap.get(tempNewBuild.id).Status__c != tempNewBuild.Status__c){
                PropertIdSet.add(tempNewBuild.Property__c);
            }else{
                //future code
            }          
        }                                   
        updateStatus(PropertIdSet);
    } 
    
    /*
    *   This method is use to set Active Status for New Build on insert/update of phase status
    */
    public static void updateStatus(Set<id> PropertIdSet){
    
        // check in after update if saved record gets the new value on Query.
        Set<Id> NewBuildNonCompletedIdSet = new Set<Id>(); 
        Set<Id> NewBuildCompletedIdSet = new Set<Id>(); 
        for(New_Build__c tempNewBuild : [SELECT Id, Status__c, Property__c 
                                               FROM New_Build__c 
                                               WHERE Status__c =: ACTIVE_STATUS and Property__c IN: PropertIdSet
                                               LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            NewBuildNonCompletedIdSet.add(tempNewBuild.Property__c);
        }
                   
        // Update the status on Property Parent object base on condition
        List<MDU_Property__c> toUpdateList = new List<MDU_Property__c>();       
        for(MDU_Property__c tempProperty: [SELECT Id, New_Build_Property__c 
                                          FROM MDU_Property__c WHERE Id IN: PropertIdSet
                                         LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            if(NewBuildNonCompletedIdSet.contains(tempProperty.Id) ){
                tempProperty.New_Build_Property__c = true;
                toUpdateList.add(tempProperty);
            } else {
                tempProperty.New_Build_Property__c = false;
                toUpdateList.add(tempProperty);
            }
        }   
        
        // execute dml Update operation here     
        Database.SaveResult[] saveresultUpdate = Database.update(toUpdateList, false);
    }
    
    /*
    * Changes the new Property based on child records Completed Status after delete
    */
    public static void afterDeleteNewBuild(){
        List<New_Build__c> deleteNewBuildList = (List<New_Build__c>)Trigger.Old;
        Set<Id> PropertyIdSet = new Set<Id>();
        for(New_Build__c NewBuildObj : deleteNewBuildList){
            PropertyIdSet.add(NewBuildObj.Property__c);
        }
        
        updateStatusOnDelete(PropertyIdSet);
    }

    /*
    * This method is use to set Status for New Build on delete of phase status
    */
    public static void updateStatusOnDelete(Set<id> PropertyIdSet){
       
        // check in after update if saved record gets the new value on Query.
        Set<Id> NewBuildNonCompletedIdSet = new Set<Id>(); 
        Set<Id> NewBuildCompletedIdSet = new Set<Id>(); 
        for(New_Build__c tempNewBuild : [SELECT Id, Status__c, Property__c 
                                               FROM New_Build__c 
                                               WHERE Property__c IN: PropertyIdSet
                                               LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
       
            if(tempNewBuild.Status__c==ACTIVE_STATUS){
                NewBuildNonCompletedIdSet.add(tempNewBuild.Property__c);
            } else {
                NewBuildCompletedIdSet.add(tempNewBuild.Property__c);
            }
        }

        // Update the status on Property Parent object base on condition
        List<MDU_Property__c> toUpdateList = new List<MDU_Property__c>();       
        for(MDU_Property__c tempProperty: [SELECT Id, New_Build_Property__c
                                          FROM MDU_Property__c WHERE Id IN: PropertyIdSet
                                         LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
           
            if(NewBuildNonCompletedIdSet.contains(tempProperty.Id)){                               
                tempProperty.New_Build_Property__c = true;
                toUpdateList.add(tempProperty);  
            } else if(NewBuildCompletedIdSet.contains(tempProperty.Id) ||(NewBuildNonCompletedIdSet.isEmpty() && NewBuildCompletedIdSet.isEmpty())){                
                tempProperty.New_Build_Property__c = false;
                toUpdateList.add(tempProperty);
            }
        }   
        
        // execute dml Update operation here     
        Database.SaveResult[] saveresultUpdate = Database.update(toUpdateList, false);
    }
}