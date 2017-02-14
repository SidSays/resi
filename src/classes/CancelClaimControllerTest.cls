@isTest
/***********************************************************
* Class Name: CancelClaimControllerTest
* Author: Amitkumar Bangad, Accenture
* Date: 27-Dec-2012 
* * Description: This class does the test coverage
*              for CancelClaimController class.
***********************************************************/
private class CancelClaimControllerTest{
    static list<Case> caseList;
    static User partnerUser;
    
    /* This method is creates data for code coverage*/
    private static void setupData() {
        SetupTestData.createCustomSettingRecords();
        UserRole role1=[Select Id From UserRole WHERE Name='Comcast: Residential'];
        
        User usr = [select Id, userroleId from User where id = :userInfo.getUserId()];
        system.runas(usr){
            usr.userroleId = role1.Id;
            usr.FederationIdentifier = 'FedId2';
            update usr;
        }
        //Create Account of Type Partner
        Account partAcc = new Account();
        partAcc.Name = 'Test Partner Account';
        partAcc.Type = 'Partner';
        partAcc.ClaimEligibilityDuration__c = 240;
        partAcc.ClaimWaitDuration__c = 60;
        insert partAcc; 
        
        //Create Account of Type Customer
        Account custAcc = new Account();
        custAcc.Name = 'Test Customer Account';
        custAcc.Type = 'Customer';
        insert custAcc;
        
        //Enable the account as partner
        partAcc.IsPartner = true;
        update partAcc;
        
        // Create a contact under the partner account
        Contact partContact = new Contact();
        partContact.AccountId = partAcc.Id;
        partContact.lastName = 'Test Contact';
        insert partContact;
        
        
        /*Update by: Sneha Rathi, Accenture 
            Date: 28 Nov, 2013
            Decription : Adding data for EnvironmentSpecificIds__c custom settings
        
        */
        System.runAs(new user(Id = UserInfo.getUserId()))
        {
         Group g1 = new Group(Name= label.Escalation_Dispute, type='Queue');            
         insert g1;            
         QueueSObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');            
         insert q1; 
        //create the custom setting data            
         EnvironmentSpecificIds__c cs = new EnvironmentSpecificIds__c(ID__c = g1.id, Name = 'EscalationDispute');
         insert cs;
        // fetch the partner profile
        Profile p = [Select UserType, UserLicenseId, Name From Profile where Name = 'Affiliate Claims User' ];
        
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7))+'';
        partnerUser = new User(Alias = 'DA_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    FederationIdentifier = 'FedId9',
                                    Username = 'userTest' + randomstr + '@SampleclassTest.com',
                                    EmployeeNumber = 'Emp' + randomstr.substring(0,4),
                                    ContactId = partContact.Id);
        insert partnerUser;
        
        }
        
        
        //Insert Opportunities
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity'; 
        opp.AccountId = custAcc.Id; 
        opp.StageName='Open';
        opp.Affiliate_Account__c = partAcc.id;
        opp.CloseDate=Date.today()+30;
        opp.LeadSource = 'Affiliate';
        insert opp;
        
        //Create Orders
        list<Order__c> orderList = new list<Order__c>();
        Order__c order = new Order__c();
        order.Name = '110795673534';
        order.Opportunity__c = opp.Id;
        order.Order_Number__c = '110795673533';
        order.OrderStatus__c = 'Activated';
        order.Order_Created_Date__c = system.now() - 200;
        order.OrderCompletedDate__c = system.today() - 100;
        orderList.add(order);
        
        Order__c order1 = new Order__c();
        order1.Name = '110795673534';
        order1.Opportunity__c = opp.Id;
        order1.Order_Number__c = '110795673534';
        order1.OrderStatus__c = 'Activated';
        order1.Order_Created_Date__c = system.now() - 200;
        order1.OrderCompletedDate__c = system.today() - 100;
        orderList.add(order1);
        
        insert orderList;
        
        //Create Case
        system.runas(partnerUser){
            caseList = new list<case>();
            case claim = new Case();
            claim.Case_Name__c = 'test case';
            claim.ContactId = partContact.Id;
            claim.Affiliate_Account__c = partAcc.Id;
            claim.Status = 'Submitted';
            claim.Claimed_Amount__c = 300; 
            caseList.add(claim);
            
            case claim1 = new Case();
            claim1.Case_Name__c = 'test case';
            claim1.ContactId = partContact.Id;
            claim1.Affiliate_Account__c = partAcc.Id;
            claim1.Status = 'Submitted';
            claim1.Claimed_Amount__c = 300; 
            caseList.add(claim1);
            
            insert caseList;
        }
        
        orderlist[0].Claim__c = caseList[0].Id;
        orderlist[1].Claim__c = caseList[1].Id;
        update orderlist;
    }
    /* This method is used for test coverage of Positive scenarios cancelClaimController class*/

    private static testMethod void cancelClaimControllerPositiveTest() {
        
        setupData();
        Test.startTest();
        /* Setting PageReference as relevant Page */
        PageReference pageRef = Page.CancelClaim;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('id',caseList[0].Id);
        ApexPages.StandardController cla = new ApexPages.standardController(caseList[0]);
        CancelClaimController cancelClaimControllerObj = new CancelClaimController(cla);
        
        /*Cancel the Claim*/
        system.runas(partnerUser){
            cancelClaimControllerObj.reason = 'test Reason';
            cancelClaimControllerObj.CancelClaim();
        }
        System.assertEquals(cancelClaimControllerObj.claimToCancel.Status == 'Cancelled', true);
        Test.StopTest();
   }
   
   /* This method is used for test coverage of Negative scenarios cancelClaimController class*/
    private static testMethod void cancelClaimControllerNegativeTest() {
        
        setupData();
        Test.startTest();
        /* Setting PageReference as relevant Page */
        PageReference pageRef = Page.CancelClaim;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('id',caseList[1].Id);
        ApexPages.StandardController cl = new ApexPages.standardController(caseList[1]);
        CancelClaimController cancelClaimControllerObj = new CancelClaimController(cl);
        
        /*Cancel Claim without specifying reason*/
        system.runas(partnerUser){
            cancelClaimControllerObj.reason = '';
            cancelClaimControllerObj.CancelClaim();
        }
        
        /*Cancel claim as Non-Affiliate Claims User*/
        cancelClaimControllerObj.reason = 'test Reason1';
        cancelClaimControllerObj.CancelClaim();
        
        /*Exit the page without cancelling Claim*/
        cancelClaimControllerObj.Exit();
        
        Test.StopTest();
   } 
    
}