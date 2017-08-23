/***********************************************************
* Class Name: OpportunityTriggerControllerTest
* Author: Raju Patel, Accenture
* Date: 07-Nov-2013 
* * Description: This class does the test coverage
*              for OpportunityTriggerController class.
***********************************************************/
@isTest
public class OpportunityTriggerControllerTest{
    
   public static testMethod void TestSalespersonIDOpportunity() {
   String xfinityOpportunityRecordTypeId;
   system.runAs(new user(id=userinfo.getuserid())){
        SetupTestData.createCustomSettingRecords();
        SetupTestData.createUsers();
        xfinityOpportunityRecordTypeId =
            Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.XfinityOpportunityRecordType).getRecordTypeId();
   }
    
    system.runAs(SetupTestData.businessAdminUser){
        //Create an Account
        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.Customer_Status__c = 'Active';
        acc.Installation_Status__c = 'Active';
        acc.Region__c = null;
        acc.Customer__c = null;
        insert acc;
        //Create a new Opportunity.
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'TestOpportunity';
        opportunity.Account =   acc;
        opportunity.StageName = 'Open';
        opportunity.CloseDate = System.today();
        opportunity.NTLoginOpp__c= 'FedId4';//Giving the NT ID of the user.
        opportunity.RecordTypeId = xfinityOpportunityRecordTypeId;  
        insert opportunity;
        opportunity.Name = 'TestOpportunity1';
        update opportunity;
        Opportunity ld = [select id , Name ,ActivatedByOppty__c from Opportunity where id =: opportunity.id];
        System.AssertEquals(ld.ActivatedByOppty__c, SetupTestData.dsrUser.id);
        }
    }
}