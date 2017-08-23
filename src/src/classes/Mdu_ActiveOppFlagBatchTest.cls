/***************************************************************************************************************************************
 * Author     : Jui Desai, Accenture
 * Date       : 02-June-2015
 * Description: This is Test class for "Mdu_ActiveOpportunityFlagSetBatch" Class
 * History
     Version             : 1.0
     Author Last Updated : Jui, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class Mdu_ActiveOppFlagBatchTest{
    
    /*
    *Method to Create account with Property with associated contract
    */
    static testmethod void InsertOpptyProp(){ 

        TestDataUtility.createCustomSettingRecords();         
        
        
        MDU_Property__c propObj = TestDataUtility.createProperty();       
        Database.insert(propObj); 
        
        //Create opportunuty with stage as Assigned       
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        System.runAs(xcUser){  
            List<Opportunity> oppList = TestDataUtility.createOpportunity(1);
            oppList[0].AssignedAE_ID__c = xcUser.id;
            oppList[0].property__c = propObj.id;
            Database.insert(oppList);
        }                
        
        Test.startTest();
        
        Database.executebatch(new Mdu_ActiveOpportunityFlagSetBatch());
        
        MDU_Property__c propObjUpdated = [Select id, Active_Opportunity__c  from MDU_Property__c where id =: propObj.id];       
        system.assertequals(propObjUpdated.Active_Opportunity__c, true);
 
        Test.stopTest();
    }
}