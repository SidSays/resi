@isTest
public class CallCenterExportControllerTest{
    
    private static testMethod void testCallCenterExportController(){
        User u = [Select Id From User where Id =: UserInfo.getUserId() Limit 1];
        System.runAs(u){
            SetupTestData.createCustomSettingRecords();

            Account affiliate = new Account();
            affiliate.Name = 'Comcast';
            affiliate.Customer_Status__c = 'Never';
            affiliate.Installation_Status__c = 'Active';
            affiliate.Region__c = null;
            insert affiliate;


            Account acc = new Account();
            acc.Name = 'TestAccount';
            acc.Customer_Status__c = 'Active';
            acc.Installation_Status__c = 'Active';
            acc.Region__c = null;
            insert acc;

            Contact cont = new Contact();
            cont.LastName = 'TestLastName';
            cont.Phone = '(555) 555-5555';
            cont.MailingState = 'NY';
            cont.AccountId = acc.Id;
            insert cont;

            acc.Customer__c=cont.Id;
            update acc;
        }

        //Account account = [Select Id, Customer__r.Phone, Customer__r.MailingState From Account Where Name = 'TestAccount' limit 1];
        Account affiliate1 = new Account();
            affiliate1.Name = 'Comcast';
            affiliate1.Customer_Status__c = 'Never';
            affiliate1.Installation_Status__c = 'Active';
            affiliate1.Region__c = null;
            insert affiliate1;
        Test.startTest();
        

        //create exportable lead
        Lead lead1 = new Lead();
        lead1.LastName = 'GoodLeadLastName';
        lead1.Company = 'Test';
        lead1.Status = 'Open';
        lead1.Credit_Check__c = 'GOOD';
        lead1.Phone = '(555) 555-5555';
        lead1.State = 'NY';
        insert lead1;

        //create non-exportable lead
        Lead lead2 = new Lead();
        lead2.LastName = 'BadLeadLastName';
        lead2.Company = 'Test';
        lead2.Status = 'Open';
        lead2.Credit_Check__c = 'BAD';
        lead2.Phone = '(555) 555-5555';
        lead2.State = 'NY';
        insert lead2;

        //create exportable opportunity
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Good Test Opportunity';
        opp1.AccountId = affiliate1.Id;
        opp1.CloseDate = Date.today() + 1;
        opp1.StageName = 'Open';
        opp1.Credit_Check__c = 'GOOD';
        opp1.Opportunity_Channel__c='TELESALES';
        opp1.Last_Export_Date__c=Date.today();
        opp1.Customer_Type__c='New';
        opp1.LeadSource='Comcast Internal';
        opp1.Customer_Exportable_Phone__c='982086459';
        //opp1.Account.Customer__c=affiliate1.Id;
        insert opp1;

        //create non-exportable opportunity
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Bad Test Opportunity';
        opp2.AccountId = affiliate1.Id;
        opp2.CloseDate = Date.today() + 1;
        opp2.StageName = 'Open';
        opp2.Credit_Check__c = 'BAD';
        insert opp2;

        Order__c ord1= new Order__c();
        ord1.Opportunity__c=opp1.Id;
        insert ord1;

        Order__c ord2= new Order__c();
        ord2.Opportunity__c=opp2.Id;
        insert ord2;
        List<Opportunity> oppsList = new List<Opportunity>();
        oppsList.add(opp1);
        oppsList.add(opp2);
        
        List<Opportunity> oppsRemoveList = new List<Opportunity>();
        oppsRemoveList.add(opp1);

        CallCenterExportController controller = new CallCenterExportController();
        controller.updateLists();
        CallCenterExportController.removeOppDuplicates(oppsRemoveList);

        CallCenterExportController.getOpportunities();
        List<Lead> leads = new List<Lead>([Select Id From Lead Where Last_Export_Date__c != null limit 2]);
        //List<Opportunity> opps = new List<Opportunity>([Select Id From Opportunity Where Last_Export_Date__c != null limit 2]);

        System.assert(leads.size() == 0, 'Leads did not update correctly: leads.size = ' + leads.size());
        //System.assert(opps.size() == 1, 'Opportunities did not update correctly: opps.size = ' + opps.size());
        
        CallCenterExport CCExport = new CallCenterExport();
        List<Lead> leadsList =new List<Lead>();
        leadsList.add(lead1);
        CallCenterExport.queryLeads();

        Test.stopTest();
    }
}