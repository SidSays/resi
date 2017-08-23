@isTest
private class batchCaseRallyUpdateTest {

    static testmethod void test() {
        List<Case> cases = new List<Case>();       
            cases.add(new Case(description='Test Case', 
                Rally_ID__c='12345678900',Kanban_State__c='Deployed', 	Region__c='Corporate'));
        insert Cases;
        Test.startTest();
        rally_url__c cs = new  rally_url__c();   
        cs.Name = 'Rally'; 
        insert cs;
        batchCaseRallyUpdate bc = new batchCaseRallyUpdate();        
        string iteration;
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetFromRallyBlocked');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);       
        database.executebatch(bc);
        Test.stopTest();
        System.assertEquals('12345678900', cases[0].Rally_ID__c);
    }
    static testmethod void testblocked() {
        List<Case> cases = new List<Case>();       
            cases.add(new Case(description='Test Case', 
                Rally_ID__c='12345678900',Kanban_State__c='Deployed',Region__c='Corporate'));
        insert Cases;
        Test.startTest();
        rally_url__c cs = new  rally_url__c();   
        cs.Name = 'Rally'; 
        insert cs;
        batchCaseRallyUpdate bc = new batchCaseRallyUpdate();        
        string iteration;
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetFromRally');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);       
        database.executebatch(bc);
        Test.stopTest();
        System.assertEquals('12345678900', cases[0].Rally_ID__c);
    }
    static testmethod void testblockedblockednoreason() {
        List<Case> cases = new List<Case>();       
            cases.add(new Case(description='Test Case', 
                Rally_ID__c='12345678900',Kanban_State__c='Deployed',Region__c='Corporate'));
        insert Cases;
        Test.startTest();
        rally_url__c cs = new  rally_url__c();   
        cs.Name = 'Rally'; 
        insert cs;
        batchCaseRallyUpdate bc = new batchCaseRallyUpdate();        
        string iteration;
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetFromRallyBlockedNoReason');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);       
        database.executebatch(bc);
        Test.stopTest();
        System.assertEquals('12345678900', cases[0].Rally_ID__c);
    }
    
    static testmethod void negativeTest() {
        List<Case> cases = new List<Case>();       
            cases.add(new Case(description='Test Case2', 
                Rally_ID__c='12345678901',Kanban_State__c='Deployed',Region__c='Corporate'));
        insert cases; 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RallyUnauthorizedEndpointResponse());
        rally_url__c cs = new  rally_url__c();   
        cs.Name = 'Rally'; 
        insert cs;
        batchCaseRallyUpdate bc = new batchCaseRallyUpdate();
        try{
        database.executebatch(bc);
        }catch (System.CalloutException e){
           string message =e.getMessage();
           System.assertEquals('You have uncommitted work pending. Please commit or rollback before calling out.', message);
         }             
        Test.stopTest();
    }
}