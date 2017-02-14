@isTest
public class CallCenterImportControllerTest{
    private static testMethod void testUpdateLeadsAndOppsElse(){
        Document doc = new Document();
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(doc);
        CallCenterImportController callCenterCtrl = new CallCenterImportController(stdController);
        callCenterCtrl.updateLeadsAndOpps();
        Test.stopTest();
    }
    private static testMethod void testUpdateLeadsAndOpps(){
        Document doc = new Document();
                 doc.name = 'myDoc.csv';
                 doc.body = Blob.valueOf('This, is, goods Unit, Test, till, date, LS_CUST_CONTACT_DT Document Body \r This, is,006 use, for, test, case, unit, testing of functionality means,00Q unit testing, of functionality This is the, goods unit testing till date, I have done');
                 doc.ContentType = 'text/plain';
                 doc.AuthorId = UserInfo.getUserId();
                 doc.FolderId = UserInfo.getUserId();
        insert doc;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(doc);
        CallCenterImportController callCenterCtrl = new CallCenterImportController(stdController);
        callCenterCtrl.document = doc;
        callCenterCtrl.updateLeadsAndOpps();
        Test.stopTest();
    }
    private static testMethod void testUpdateLeadsAndOpps1(){
        
        Document doc = new Document();
                 doc.name = 'myDoc.csv';
                 doc.body = Blob.valueOf('This, is, goods Unit, Test, till, date, LS_CUST_CONTACT_DT Document Body \r This, is,006 use, f,o,r, t,est case, unit, testing of functionality means,00Q unit testing, of functionality This is the, goods unit testing till date, I have done');
                 doc.ContentType = 'text/plain';
                 doc.AuthorId = UserInfo.getUserId();
                 doc.FolderId = UserInfo.getUserId();
        insert doc;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(doc);
        CallCenterImportController callCenterCtrl = new CallCenterImportController(stdController);
        callCenterCtrl.document = doc;
        callCenterCtrl.updateLeadsAndOpps();
        Test.stopTest();
    }
    
    private static testMethod void testUpdateLeadsAndOppsIf(){
       
        SetupTestData.createCustomSettingRecords();
        Lead lead = new Lead();
            lead.LastName = 'TestLead';
            lead.Company = 'TestCompany';  
            lead.Status = 'Open';
            lead.NTLoginLead__c = 'abc1111';//Giving the sales ID of the user.
        insert lead;
        
        //SetupTestData.createCustomSettingRecords();
        Opportunity opportunity = new Opportunity();
            opportunity.StageName = 'Open';
            opportunity.Name = 'New Opportunity';
            opportunity.CloseDate = System.today();
        insert opportunity;     
        
        Document doc = new Document();
                 doc.name = 'myDoc.csv';
                 doc.body = Blob.valueOf('03-06  -200606:36:13 is goods Unit Test till date LS_CUST_CONTACT_DT Document Body \r 03-06  -200606:36:13, is use for test case,03-06  -200606:36:13 unit testing of,'+opportunity.Id+' functionality means, unit testing, of functionality, This the,'+lead.Id+' goods unit testing till date, I have done');
                 doc.ContentType = 'text/plain';
                 doc.AuthorId = UserInfo.getUserId();
                 doc.FolderId = UserInfo.getUserId();
        insert doc;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(doc);
        CallCenterImportController callCenterCtrl = new CallCenterImportController(stdController);
        callCenterCtrl.document = doc;
        callCenterCtrl.updateLeadsAndOpps();
        Test.stopTest();
    }
    
    private static testMethod void testUpdateLeadsAndOppsElse1(){
       
        SetupTestData.createCustomSettingRecords();
        
         Opportunity opportunity = new Opportunity();
            opportunity.StageName = 'Open';
            opportunity.Name = 'New Opportunity';
            opportunity.CloseDate = System.today();
        insert opportunity;
        
        Lead lead = new Lead();
            lead.LastName = 'TestLead';
            lead.Company = 'TestCompany';  
            lead.Status = 'Open';
            lead.NTLoginLead__c = 'abc1111';//Giving the sales ID of the user.
            opportunity.id='006q0000005eY9NAAU';
        insert lead;
        
         Document doc = new Document();
                 doc.name = 'myDoc.csv';
                 doc.body = Blob.valueOf('03-06  -200606:36:13 is goods Unit Test till date LS_CUST_CONTACT_DT Document Body \r 03-06  -200606:36:13, is use for test case,03-06  -200606:36:13 unit testing of,'+opportunity.Id+' functionality means, unit testing, of functionality, This the,'+lead.Id+' goods unit testing till date, I have done');
                 doc.ContentType = 'text/plain';
                 doc.AuthorId = UserInfo.getUserId();
                 doc.FolderId = UserInfo.getUserId();
        insert doc;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(doc);
        CallCenterImportController callCenterCtrl = new CallCenterImportController(stdController);
        callCenterCtrl.document = doc;
        callCenterCtrl.updateLeadsAndOpps();
        Test.stopTest();
    }
    
}