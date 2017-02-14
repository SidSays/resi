/***********************************************************
* Class Name: LeadTriggerControllerTest
* Author: Raju Patel, Accenture
* Date: 24-Oct-2013 
* * Description: This class does the test coverage
*              for LeadTriggerController class.
***********************************************************/
@isTest
public class LeadTriggerControllerTest{
    
   public static testMethod void TestSalespersonIDLead() {
    SetupTestData.createCustomSettingRecords();
    SetupTestData.createUsers();

    system.runAs(SetupTestData.businessAdminUser){
        //Create an Account
        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.Customer_Status__c = 'Active';
        acc.Installation_Status__c = 'Active';
        acc.Region__c = null;
       // acc.Customer__c = null;
        insert acc;
        //Inserting a Contact      
        contact con = new contact();
        con.LastName = 'TestName';
        con.AccountId = acc.id;
        Insert con;
        //updating contact Last Name.
        con.LastName = 'Test';
        update con;
    
        //Create a new Lead.
        Lead lead = new Lead();
        lead.LastName = 'TestLead';
        lead.Company = 'TestCompany';  
        lead.Company = 'Open';
        lead.NTLoginLead__c = 'abc1111';//Giving the sales ID of the user.
        insert lead;
        lead.LastName = 'TestName1';
        update lead;
        Lead ld = [select id , Name ,ActivatedByLead__c from Lead where id =: lead.id];
        System.AssertEquals(ld.ActivatedByLead__c, SetupTestData.dsrUser.id);
        }
    }
}