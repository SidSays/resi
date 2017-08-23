/**************************************************************************************************
Name : CensusTracttrigger
Description :  This trigger will be all Census Tract Trigger Sequence Contoller Class
User Story : US1103983
Date : 11 May 2017
Author : Amit Kumar - Accenture 
***************************************************************************************************/
trigger CensusTracttrigger on CensusTract__c ( before update) {
	if(Trigger.isbefore){        
    	if(Trigger.isUpdate){
        	CensusTractTriggerController.setterritorychanged(trigger.new,trigger.oldmap);  //US1103983---Method to set he Territory Change Flag.
        }  
    }
}