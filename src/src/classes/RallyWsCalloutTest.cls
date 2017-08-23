@isTest
private class RallyWsCalloutTest {

    @isTest static void testGetCallout() {
        // Create the mock response based on a static resource
        VariableSettingTestUtility.variableSettingsData();
        string result;
        List<Case> cases = new List<Case>{};
        Case testCase = new Case(Description='Test 123', Status = 'New', Priority = 'Nice To Have',Region__c = 'Freedom Market', Rally_ID__c = '12345678901', Rally_Project__c = 'Salesforce');
            cases.add(testCase);
            insert cases;
        ApexPages.StandardController sc = new ApexPages.StandardController(testCase);    
        rally_url__c cs = new  rally_url__c();   
        cs.Name = 'Rally';
        cs.GET_EP__c = '?fetch=ObjectID,FormattedID,Name,Description,ScheduleState,Release,c_KanbanState,Iteration';
        cs.Key__c = '_0dT9cEPWSyC4rcDz2RIMZVwL';
        cs.Order_Lab_Proj__c = '/project/106284789800';
        cs.Order_Lab_URL__c = 'https://rally1.rallydev.com/#/106284789800d/detail/userstory/';
        cs.SF_Proj__c = '/project/56680359985';
        cs.SF_URL__c = 'https://rally1.rallydev.com/#/56680359985d/detail/userstory/';
        insert cs;
        Test.startTest();
        string state;
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetFromRally');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        RallyWsCallout rc = new RallyWsCallout(sc);        
        rc.getFromRally();
        result = rc.response;             
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(result);
        Map<String,Object> responseObj = (Map<String,Object>)results.get('HierarchicalRequirement');
         system.debug(responseObj);
         for (String field : responseObj.keySet()){
             if(field == 'ScheduleState'){
              system.debug('The field: ' + field);
              state = (string)responseobj.get(field);
             }
           }
        System.assertEquals('Accepted', state, 'The state is different.');
        Test.StopTest();    
    }
    
    @isTest static void testPostCallout() {
    // Set mock callout class
    VariableSettingTestUtility.variableSettingsData();
    string result;
    List<Case> cases = new List<Case>{};
        Case testCase = new Case(Description='Test Name123', Status = 'New', Priority = 'Nice To Have',Region__c = 'Freedom Market', Rally_ID__c = null, Rally_Project__c = 'Salesforce');
            cases.add(testCase);
            insert cases;
    ApexPages.StandardController sc = new ApexPages.StandardController(testCase);
    rally_url__c cs = new  rally_url__c();   
        cs.Name = 'Rally';
        cs.GET_EP__c = '?fetch=ObjectID,FormattedID,Name,Description,ScheduleState,Release,c_KanbanState,Iteration';
        cs.Key__c = '_0dT9cEPWSyC4rcDz2RIMZVwL';
        cs.Order_Lab_Proj__c = '/project/106284789800';
        cs.Order_Lab_URL__c = 'https://rally1.rallydev.com/#/106284789800d/detail/userstory/';
        cs.SF_Proj__c = '/project/56680359985';
        cs.SF_URL__c = 'https://rally1.rallydev.com/#/56680359985d/detail/userstory/';
        insert cs;    
    Test.startTest();   
    Test.setMock(HttpCalloutMock.class, new RallyHttpCalloutMock());
    RallyWsCallout rc = new RallyWsCallout(sc); 
    rc.postToRally();
    result = rc.response;
    // Verify that the response received contains fake values
    String actualValue = result;
    String expectedValue = '{"CreateResult":{"Object": {"FormattedID": "US1049569", "ScheduleState": "Backlog", "c_KanbanState": "Backlog", "Errors": [], "Warnings": []}}}';
    System.assertEquals(actualValue, expectedValue);
    Test.StopTest();
}

    @isTest static void testdeleteCallout() {
    // Set mock callout class
    VariableSettingTestUtility.variableSettingsData();
    string result;
    List<Case> cases = new List<Case>{};
        Case testCase = new Case(Description='Test Desc Name123', Status = 'New',Region__c = 'Freedom Market', Priority = 'Nice To Have', Rally_ID__c = '12345678902', Rally_Project__c = 'Salesforce');
            cases.add(testCase);
            insert cases;
    ApexPages.StandardController sc = new ApexPages.StandardController(testCase);    
    rally_url__c cs = new  rally_url__c();   
        cs.Name = 'Rally';
        cs.GET_EP__c = '?fetch=ObjectID,FormattedID,Name,Description,ScheduleState,Release,c_KanbanState,Iteration';
        cs.Key__c = '_0dT9cEPWSyC4rcDz2RIMZVwL';
        cs.Order_Lab_Proj__c = '/project/106284789800';
        cs.Order_Lab_URL__c = 'https://rally1.rallydev.com/#/106284789800d/detail/userstory/';
        cs.SF_Proj__c = '/project/56680359985';
        cs.SF_URL__c = 'https://rally1.rallydev.com/#/56680359985d/detail/userstory/';
        insert cs;
    Test.startTest();     
    Test.setMock(HttpCalloutMock.class, new RallyHttpCalloutMock());
    RallyWsCallout rc = new RallyWsCallout(sc); 
    rc.removeRally();
    result = rc.response;
    Test.StopTest();
}   

    @isTest static void negativeTest() {
        VariableSettingTestUtility.variableSettingsData();
        List<Case> cases = new List<Case>();       
            Case testCase = new Case(Description='Test 123', Status = 'New', Region__c = 'Freedom Market',Priority = 'Nice To Have', Rally_ID__c = '12345678901', Rally_Project__c = 'Salesforce');
            cases.add(testCase);
        insert cases;
        rally_url__c cs = new  rally_url__c();   
        cs.Name = 'Rally';
        cs.GET_EP__c = '?fetch=ObjectID,FormattedID,Name,Description,ScheduleState,Release,c_KanbanState,Iteration';
        cs.Key__c = '_0dT9cEPWSyC4rcDz2RIMZVwL';
        cs.Order_Lab_Proj__c = '/project/106284789800';
        cs.Order_Lab_URL__c = 'https://rally1.rallydev.com/#/106284789800d/detail/userstory/';
        cs.SF_Proj__c = '/project/56680359985';
        cs.SF_URL__c = 'https://rally1.rallydev.com/#/56680359985d/detail/userstory/';
        insert cs;
        Test.startTest();       
        Test.setMock(HttpCalloutMock.class, new RallyUnauthorizedEndpointResponse());
        ApexPages.StandardController sc = new ApexPages.StandardController(testCase);
        try{
        RallyWsCallout rc = new RallyWsCallout(sc);
        rc.removeRally();
        }catch (System.CalloutException e){
           string message =e.getMessage();
           System.assertEquals('You have uncommitted work pending. Please commit or rollback before calling out.', message);
         }             
        Test.stopTest();
    } 
    
    @isTest static void testGetCalloutblocked() {
        // Create the mock response based on a static resource
        VariableSettingTestUtility.variableSettingsData();
        string result;
        List<Case> cases = new List<Case>{};
        Case testCase = new Case(Description='Test 123', Status = 'New',Region__c = 'Freedom Market', Priority = 'Nice To Have', Rally_ID__c = '12345678901', Rally_Project__c = 'Salesforce');
            cases.add(testCase);
            insert cases;
        ApexPages.StandardController sc = new ApexPages.StandardController(testCase);    
        rally_url__c cs = new  rally_url__c();   
        cs.Name = 'Rally';
        cs.GET_EP__c = '?fetch=ObjectID,FormattedID,Name,Description,ScheduleState,Release,c_KanbanState,Iteration,Blocked,BlockedReason';
        cs.Key__c = '_0dT9cEPWSyC4rcDz2RIMZVwL';
        cs.Order_Lab_Proj__c = '/project/106284789800';
        cs.Order_Lab_URL__c = 'https://rally1.rallydev.com/#/106284789800d/detail/userstory/';
        cs.SF_Proj__c = '/project/56680359985';
        cs.SF_URL__c = 'https://rally1.rallydev.com/#/56680359985d/detail/userstory/';
        insert cs;
        Test.startTest();
        string state;
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetFromRallyBlocked');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        RallyWsCallout rc = new RallyWsCallout(sc);        
        rc.getFromRally();
        result = rc.response;             
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(result);
        Map<String,Object> responseObj = (Map<String,Object>)results.get('HierarchicalRequirement');
         system.debug(responseObj);
         for (String field : responseObj.keySet()){
             if(field == 'ScheduleState'){
              system.debug('The field: ' + field);
              state = (string)responseobj.get(field);
             }
           }
        System.assertEquals('Accepted', state, 'The state is different.');
        Test.StopTest();    
    }
     @isTest static void testGetCalloutblockedNoReason() {
        // Create the mock response based on a static resource
        VariableSettingTestUtility.variableSettingsData();
        string result;
        List<Case> cases = new List<Case>{};
        Case testCase = new Case(Description='Test 123', Status = 'New',Region__c = 'Freedom Market', Priority = 'Nice To Have', Rally_ID__c = '12345678901', Rally_Project__c = 'Salesforce');
            cases.add(testCase);
            insert cases;
        ApexPages.StandardController sc = new ApexPages.StandardController(testCase);    
        rally_url__c cs = new  rally_url__c();   
        cs.Name = 'Rally';
        cs.GET_EP__c = '?fetch=ObjectID,FormattedID,Name,Description,ScheduleState,Release,c_KanbanState,Iteration,Blocked,BlockedReason';
        cs.Key__c = '_0dT9cEPWSyC4rcDz2RIMZVwL';
        cs.Order_Lab_Proj__c = '/project/106284789800';
        cs.Order_Lab_URL__c = 'https://rally1.rallydev.com/#/106284789800d/detail/userstory/';
        cs.SF_Proj__c = '/project/56680359985';
        cs.SF_URL__c = 'https://rally1.rallydev.com/#/56680359985d/detail/userstory/';
        insert cs;
        Test.startTest();
        string state;
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetFromRallyBlockedNoReason');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        RallyWsCallout rc = new RallyWsCallout(sc);        
        rc.getFromRally();
        result = rc.response;             
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(result);
        Map<String,Object> responseObj = (Map<String,Object>)results.get('HierarchicalRequirement');
         system.debug(responseObj);
         for (String field : responseObj.keySet()){
             if(field == 'ScheduleState'){
              system.debug('The field: ' + field);
              state = (string)responseobj.get(field);
             }
           }
        System.assertEquals('Accepted', state, 'The state is different.');
        Test.StopTest();    
    }

}