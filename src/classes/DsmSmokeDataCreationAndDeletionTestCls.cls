/**
    * @Description: This is test class for DsmSmokeDataCreationAndDeletion class. 
    * @Author: Revan Bhadange, Accenture 
    * @Date: 22-June-2016    
    * @Return: void.
    */
@isTest
public class DsmSmokeDataCreationAndDeletionTestCls {
    private static testmethod void Testmethod1 () {
        Plan__c objPlan = new Plan__c ();
        objPlan.Name = UserInfo.getName();
        objPlan.Plan_Level__c = 'Turf';
        objPlan.Assigned_Date__c = Date.valueOf(system.now());
        objPlan.Expiration_Date__c = System.Today();  
        objPlan.Plan_Status__c = 'Assigned';
        Database.Insert(objPlan,false);  
        DsmSmokeDataCreationAndDeletion.createTestUser(5,'Test',false);
        DsmSmokeDataCreationAndDeletion.createTestAccAddr(15);
        DsmSmokeDataCreationAndDeletion.createBPAccAddr(15);
        DsmSmokeDataCreationAndDeletion.DelAccAddIsActUser(UserInfo.getName());
    }
}