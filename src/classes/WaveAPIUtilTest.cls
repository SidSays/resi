@isTest
private class WaveAPIUtilTest {
  //////////
  // TEST METHODS
  //////////

  // validateGetDashboard: Validate that getDashboard is called and data is returned
  @isTest static void validateGetDashboard() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    String res = wave.getDashboard('0FK16000000TNLAGA4');

    Map<String, Object> mappedRes = jsonString2Map(res);
    System.assert(mappedRes.get('type') == 'dashboard');
  }

  // validateGetDashboardWithEmptyInput: Validate that getDashboard is called with empty input and null data is returned
  @isTest static void validateGetDashboardWithEmptyInput() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    String res = wave.getDashboard('');

    System.assertEquals(res, null);
  }

  // validateGetDashboardList: Validate that getDashboardList is called and data is returned
  @isTest static void validateGetDashboardList() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    String res = wave.getDashboardList();

    Map<String, Object> mappedRes = jsonString2Map(res);
    System.assert(mappedRes.get('url') == '/services/data/v36.0/wave/dashboards');

    List<Object> dashboardList = (List<Object>)mappedRes.get('dashboards');
    System.assertEquals(dashboardList.size(), 2);
  }

  // validateGetDashboardListOverload: Validate that overloaded getDashboardList is called and data is returned
  @isTest static void validateGetDashboardListOverload() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    Map<String, String> paramMap = new Map<String, String>{'pageSize' => '2'};
    String res = wave.getDashboardList(paramMap);

    Map<String, Object> mappedRes = jsonString2Map(res);
    System.assert(mappedRes.get('url') == '/services/data/v36.0/wave/dashboards');

    List<Object> dashboardList = (List<Object>)mappedRes.get('dashboards');
    System.assertEquals(dashboardList.size(), 2);
  }

  // validateGetDataset: Validate that getDataset is called and data is returned
  @isTest static void validateGetDataset() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    String res = wave.getDataset('0FbP00000006hQiKAI');

    Map<String, Object> mappedRes = jsonString2Map(res);
    System.assert(mappedRes.get('type') == 'dataset');
  }

  // validateGetDatasetWithEmptyInput: Validate that getDataset is called with empty input and null data is returned
  @isTest static void validateGetDatasetWithEmptyInput() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    String res = wave.getDataset(' ');

    System.assertEquals(res, null);
  }

  // validateGetDatasetList: Validate that getDatasetList is called and data is returned
  @isTest static void validateGetDatasetList() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    String res = wave.getDatasetList();

    Map<String, Object> mappedRes = jsonString2Map(res);
    System.assert(mappedRes.get('url') == '/services/data/v36.0/wave/datasets');

    List<Object> datasetList = (List<Object>)mappedRes.get('datasets');
    System.assertEquals(datasetList.size(), 2);
  }

  // validateGetDatasetListOverload: Validate that overloaded getDatasetList is called and data is returned
  @isTest static void validateGetDatasetListOverload() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    Map<String, String> paramMap = new Map<String, String>{'pageSize' => '2'};
    String res = wave.getDatasetList(paramMap);

    Map<String, Object> mappedRes = jsonString2Map(res);
    System.assert(mappedRes.get('url') == '/services/data/v36.0/wave/datasets');

    List<Object> datasetList = (List<Object>)mappedRes.get('datasets');
    System.assertEquals(datasetList.size(), 2);
  }

  // validateGetFolder: Validate that getFolder method is called and data is returned
  @isTest static void validateGetFolder() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    String res = wave.getFolder('00lP0000000rbbzIAA');

    Map<String, Object> mappedRes = jsonString2Map(res);
    System.assert(mappedRes.get('type') == 'folder');
  }

  // validateGetFolderWithEmptyInput: Validate that getFolder method is called with empty input and null data is returned
  @isTest static void validateGetFolderWithEmptyInput() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    String res = wave.getFolder(null);

    System.assertEquals(res, null);
  }

  // validateGetFolderList: Validate that getFolderList method is called and data is returned
  @isTest static void validateGetFolderList() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    String res = wave.getFolderList();

    Map<String, Object> mappedRes = jsonString2Map(res);
    System.assert(mappedRes.get('url') == '/services/data/v36.0/wave/folders');

    List<Object> folderList = (List<Object>)mappedRes.get('folders');
    System.assertEquals(folderList.size(), 2);
  }

  // validateGetFolderListOverload: Validate that overloaded getFolderList method is called and data is returned
  @isTest static void validateGetFolderListOverload() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    Map<String, String> paramMap = new Map<String, String>{'pageSize' => '2'};
    String res = wave.getFolderList(paramMap);

    Map<String, Object> mappedRes = jsonString2Map(res);
    System.assert(mappedRes.get('url') == '/services/data/v36.0/wave/folders');

    List<Object> folderList = (List<Object>)mappedRes.get('folders');
    System.assertEquals(folderList.size(), 2);
  }

  // validateGetLens: Validate that getLens method is called and data is returned
  @isTest static void validateGetLens() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    String res = wave.getLens('0FKP00000004CdhOAE');

    Map<String, Object> mappedRes = jsonString2Map(res);
    System.assert(mappedRes.get('type') == 'lens');
  }

  // validateGetLensWithEmptyInput: Validate that getLens method is called with empty input and null data is returned
  @isTest static void validateGetLensWithEmptyInput() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    String res = wave.getLens('  ');

    System.assertEquals(res, null);
  }

  // validateGetLensList: Validate that getLensList method is called and data is returned
  @isTest static void validateGetLensList() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    String res = wave.getLensList();

    Map<String, Object> mappedRes = jsonString2Map(res);
    System.assert(mappedRes.get('url') == '/services/data/v36.0/wave/lenses');

    List<Object> lensList = (List<Object>)mappedRes.get('lenses');
    System.assertEquals(lensList.size(), 2);
  }

  // validateGetLensListOverload: Validate that overloaded getLensList method is called and data is returned
  @isTest static void validateGetLensListOverload() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    Map<String, String> paramMap = new Map<String, String>{'pageSize' => '2'};
    String res = wave.getLensList(paramMap);

    Map<String, Object> mappedRes = jsonString2Map(res);
    System.assert(mappedRes.get('url') == '/services/data/v36.0/wave/lenses');

    List<Object> lensList = (List<Object>)mappedRes.get('lenses');
    System.assertEquals(lensList.size(), 2);
  }

  // validateGetWave: Validate that getWave method is called and data is returned
  @isTest static void validateGetWave() {
    setupMocks();

    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    String res = wave.getWave();

    Map<String, Object> mappedRes = jsonString2Map(res);
    System.assert(mappedRes.get('dashboards') == '/services/data/v36.0/wave/dashboards');
  }

  // validatePostQuery: Validate that postQuery method is called and data is returned
  @isTest static void validatePostQuery() {
    SetupTestData.createCustomSettingRecords();
    SetupTestData.createUsers();
    SetupTestTerritoryData.createUsers();

    //Create Territory and Plan records for us to use in our test methods
    SetupTestTerritoryData.createTerritoryRecords(1);
    SetupTestTerritoryData.createPlanRecords(2);

    //Create sample Customer_Address__c records
    Id addrOwnerId = SetupTestData.Contractor.Id;
    //Id planId = [SELECT Id FROM Plan__c WHERE Name = 'Plan0'].Id;
    SetupTestTerritoryData.createAddressRecordsWithoutTerritory(2, addrOwnerId);
    setupMocks();

    String queryString = '';
    queryString += 'q = load "0FbP00000006hQiKAI/0FcP00000006geyKAA";';
    queryString += 'q = filter q by \'Orange\' == "true";';
    queryString += 'q = foreach q generate \'Account\' as \'Account\', \'Address\' as \'Address\', \'Census_Block\' as \'Census_Block\', \'County_Code\' as \'County_Code\', \'Disconnect_Days\' as \'Disconnect_Days\', \'Disconnect_Reason\' as \'Disconnect_Reason\', \'HSI_Active1\' as \'HSI_Active1\', \'Record_ID\' as \'Record_ID\', \'Tap_Status1\' as \'Tap_Status1\', \'Write_Off_Amount\' as \'Write_Off_Amount\';';
    queryString += 'q = limit q 100;';
    Test.startTest();
    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    String res = wave.postQuery(queryString);
    Test.stopTest();

    Map<String, Object> mappedRes = jsonString2Map(res);
    System.assert(mappedRes.get('action') == 'query');
  }

  // validatePostQueryWithEmptyInput: Validate that postQuery method is called with empty input and null data is returned
  @isTest static void validatePostQueryWithEmptyInput() {
    setupMocks();

    String queryString = '';
    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    String res = wave.postQuery(queryString);

    System.assertEquals(res, null);
  }

  // validateCreateQueryString: Validate that createQueryString functions correctly
  @isTest static void validateCreateQueryString() {
    Map<String, String> testMap1 = new Map<String, String>{'hello' => 'world'};
    Map<String, String> testMap2 = new Map<String, String>{'green' => 'tea', 'red' => 'leaf'};
    Map<String, String> testMap3 = new Map<String, String>{'one' => 'two', 'uno' => 'dos', 'ichi' => 'ni'};

    testCreateQueryString(testMap1);
    testCreateQueryString(testMap2);
    testCreateQueryString(testMap3);
  }

  // validateSetupHttpRequestSettings: Validate that setupHttpRequest functions correctly
  @isTest static void validateSetupHttpRequestSettings() {
    testSetupHttpRequest('testGetEndpoint', 'GET');
    testSetupHttpRequest('testPostEndpoint', 'POST');
    testSetupHttpRequest('testDeleteEndpoint', 'DELETE');
    testSetupHttpRequest('testPatchEndpoint', 'PATCH');
    testSetupHttpRequest('testPutEndpoint', 'PUT');
  }

  //////////
  // HELPER METHODS
  //////////

  // jsonString2Map: Deserializes a json string into apex mapped object primaries
  static Map<String, Object> jsonString2Map(String jsonRes) {
    Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRes);

    return resMap;
  }

  // setupMocks: Sets the HttpCalloutMock class
  static void setupMocks() {
    Test.setMock(HttpCalloutMock.class, new WaveAPIUtilHttpCalloutMock());
  }

  // testCreateQueryString: Validates queryString
  static void testCreateQueryString(Map<String, String> params) {
    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    String queryString = wave.createQueryString(params);

    System.assert(queryString.contains('?'));

    for (String key : params.keySet()) {
      System.assert(queryString.contains(key));
      System.assert(queryString.contains(params.get(key)));
    }

    if (params.size() > 1) {
      System.assert(queryString.contains('&'));
    }
  }

  // testSetupHttpRequest Validates HttpRequest object
  static void testSetupHttpRequest(String reqEndpoint, String reqMethod) {
    WaveAPIUtil wave = WaveAPIUtil.getInstance();
    HttpRequest req = wave.setupHttpRequest(reqEndpoint, reqMethod);

    String currentEndpoint = req.getEndpoint();
    String currentMethod = req.getMethod();
    String currentAuthHeader = req.getHeader('Authorization');

    System.assert(currentEndpoint.contains(reqEndpoint));
    System.assert(currentMethod == reqMethod);
    System.assert(currentAuthHeader.contains('OAuth '));
    System.assert(currentAuthHeader.length() > 6);
    System.assert(req.getHeader('Content-Type') == 'application/json');
  }
}