/**
* This is the unit test for the AddressAssignment Class
*
* @Author salesforce Services
* @Date 09/06/2016
*/
@isTest(SeeAllData=false)
public class TerritoryPlanningExtensionTest {
    @testSetup static void setup() {
        //Follow existing precedence to set up the test Users we will use in our test methods
        SetupTestData.createCustomSettingRecords();
        VariableSettingTestUtility.variableSettingsData();
        //Create Territory and Plan records for us to use in our test methods
        SetupTestTerritoryData.createTerritoryRecords(1);
        SetupTestTerritoryData.createPlanRecords(2);

        //Create sample Customer_Address__c records
        Id addrOwnerId = UserInfo.getUserId();
        //Id planId = [SELECT Id FROM Plan__c WHERE Name = 'Plan0'].Id;
        SetupTestTerritoryData.createAddressRecordsWithoutTerritory(2, addrOwnerId);
    }
    
    @isTest static void testGetAvailableLenses() {
        // Implement test code
        Test.setMock(HttpCalloutMock.class, new WaveLensMockServiceImpl());
        Test.startTest();
        List<WaveLenses.Lenses> lenses = TerritoryPlanningExtension.getAvailableLenses();
        Test.stopTest();
        System.assert(lenses.size()==1);
    }

    @isTest static void testGetLensData() {
        // Implement test code
        Test.setMock(HttpCalloutMock.class, new WaveLensMockServiceImpl());
        Test.startTest();
        TerritoryPlanningExtension.LensAndXmd lenses = TerritoryPlanningExtension.getLensData('LensId');
        Test.stopTest();
        System.assert(lenses.xmdStr!=null);
        System.assert(lenses.versionId == '0Fc7A0000000wISSAY');

    }


    @isTest static void testCreateTerritory(){
        TerritoryPlanningExtension controller = new TerritoryPlanningExtension();
        TerritoryPlanningExtension.ProcessParams    params = new TerritoryPlanningExtension.ProcessParams();
        params.saqlQuery = 'q = load \"0Fb7A000000FMXlSAO/0Fc7A000000GUHOSA4\";q = filter q by \'Dwelling_Type__c\' != \"Commercial\";q = filter q by \'Excluded__c\' == \"false\";q = filter q by \'Region__c\' == \"Keystone Market\";q = filter q by \'State__c\' == \"PA\";q = filter q by \'Census_Tract__c\' in [\"42003521401\", \"42003564200\", \"42129802103\", \"42129802200\", \"42129802301\", \"42129802304\", \"42129802900\", \"42129803100\", \"42129803200\", \"42129803301\"];q = foreach q generate \'Id\' as \'Id\';q = limit q 100;';
        params.region = 'Keystone Market';
        params.lensName = 'KEY001';
        Test.startTest();
        Continuation conti = (Continuation)TerritoryPlanningExtension.createTerritory(params);
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        system.assert(requests.size() == 1);
        String requestId='';
        for(String key:requests.keySet()){
            requestId=key;
        }
        params.apiRequestId=requestId;

        String ROWCOUNT_JSON=
          '{'+
          '  "action": "query",'+
          '  "responseId": "44WnU6gjmjtRevVeRhezdV",'+
          '  "results": {'+
          '    "records": ['+
          '      {'+
          '        "count": 13113'+
          '      }'+
          '    ]'+
          '  },'+
          '  "query": "q = load \"0Fb7A000000FMXlSAO/0Fc7A000000GUHOSA4\";q = filter q by \'Dwelling_Type__c\' != \"Commercial\";q = filter q by \'Excluded__c\' == \"false\";q = filter q by \'Region__c\' == \"Keystone Market\";q = filter q by \'State__c\' == \"PA\";q = filter q by \'Census_Tract__c\' in [\"42003521401\", \"42003564200\", \"42129802103\", \"42129802200\", \"42129802301\", \"42129802304\", \"42129802900\", \"42129803100\", \"42129803200\", \"42129803301\"];q = foreach q generate \'Id\' as \'Id\';q = limit q 100;",'+
          '  "responseTime": 361'+
          '}';        
        // Perform mock callout 
            // (i.e. skip the callout and call the callback method)
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatus('200');
        res.setBody(ROWCOUNT_JSON);   
        // Set the fake response for the continuation     
        Test.setContinuationResponse(requestId, res);
        params = TerritoryPlanningExtension.createTerritoryCallback(params);
        Test.stopTest();
        // result is the return value of the callback
        System.assert(params.recordCount == 13113);
        System.assert(params.territoryId !=null);
        Territory__c terr = [select Name,Id,Region__c,OwnerId from Territory__c where Id = :params.territoryId];
        System.assert(terr.Name == 'KEY001');
        System.assert(terr.Region__c == 'Keystone Market');
        System.assert(terr.OwnerId == UserInfo.getUserId());

     }
     

    @isTest static void testAssignToTerritory(){

        Territory__c testTerritory = [select Id,Name from Territory__c limit 1];

        List<Customer_Address__c> testAddresses = [select Id,Name from Customer_Address__c];


        List<Id> addressIds = new List<Id>();
        addressIds.add(testAddresses[0].Id);
        addressIds.add(testAddresses[1].Id);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WaveAPIUtilHttpCalloutMock());
        TerritoryPlanningExtension controller = new TerritoryPlanningExtension();
        TerritoryPlanningExtension.ProcessParams    params = new TerritoryPlanningExtension.ProcessParams();
        params.columns = new List<String>{'Id'};
        params.sortColumn='Id';
        params.currentChunk=0;
        params.currRecordCount=0;
        params.batchSize=50;
        params.territoryId = testTerritory.Id;
        params.saqlQuery = 'q = load \"0Fb7A000000FMXlSAO/0Fc7A000000GUHOSA4\";q = filter q by \'Dwelling_Type__c\' != \"Commercial\";q = filter q by \'Excluded__c\' == \"false\";q = filter q by \'Region__c\' == \"Keystone Market\";q = filter q by \'State__c\' == \"PA\";q = filter q by \'Census_Tract__c\' in [\"42003521401\", \"42003564200\", \"42129802103\", \"42129802200\", \"42129802301\", \"42129802304\", \"42129802900\", \"42129803100\", \"42129803200\", \"42129803301\"];q = foreach q generate \'Id\' as \'Id\';q = limit q 100;';

        params.lensName = 'KEY001';
        TerritoryPlanningExtension.ProcessParams paramsRet = TerritoryPlanningExtension.assignAddressToTerritory(params);
        Test.stopTest();

        testAddresses = [select Id,Territory_Name__c,Assigned_To_Territory__c,Territory__c from Customer_Address__c where Id in :addressIds];
        System.debug('>>>>>addresses after assignment:'+testAddresses);
        System.assert(paramsRet.currRecordCount==2);

        System.assert(testAddresses[0].Territory__c==testTerritory.Id);
        System.assert(testAddresses[0].Territory_Name__c=='Territory0');
        System.assert(testAddresses[0].Assigned_To_Territory__c=='YES');

        
    }   
}