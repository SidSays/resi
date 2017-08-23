/*
* This is a utility class for interacting with the Wave REST API.
* @Author salesforce Services
* @Date 08/31/2016
*/
public with sharing class WaveAPIUtil {
    private static WaveAPIUtil classInstance;
    private static String WAVE_API_BASE_URL;
    private static String WAVE_API_VERSION;
    // <Salesforce Program Architect 20170603>
    // Add attributes to capture max pagesize for a Wave REST API call
    // Used to maximize the number of records in a JSON response
    private static SystemProperties sysProps;
    private static String WAVE_REST_API_MAX_PAGESIZE;
    // Define an attribute to cache the WAVE_API_BASE_URL (below) for use in getWaveAssetMetadata
    private static String cachedWaveApiBaseUrl;
    // </Salesforce Program Architect 20170603>
    static {
        // <Salesforce Program Architect 20170603>
        // Capture max pagesize for Wave REST API call
        sysProps = new SystemProperties();
        WAVE_REST_API_MAX_PAGESIZE = sysProps.getSytemProperty('WaveRestApiMaxPageSize', 'Wave');
        // We need a big of insurance on max page size, to avoid an ILLEGAL_QUERY_PARAMETER_VALUE error or erroneously get null results
        // We could add a whole bunch of conditional logic below to avoid passing in this parameter when null, but this is more expedient
        if(String.isEmpty(WAVE_REST_API_MAX_PAGESIZE)) {
            WAVE_REST_API_MAX_PAGESIZE = '200';
        }
        // </Salesforce Program Architect 20170603>
        WAVE_API_VERSION = 'v36.0';
        WAVE_API_BASE_URL = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/' + WAVE_API_VERSION + '/';
        // <Salesforce Program Architect 20170603>
        // Cache the WAVE_API_BASE_URL value for us in getWaveAssetMetadata
        cachedWaveApiBaseUrl = WAVE_API_BASE_URL;
        // </Salesforce Program Architect 20170603>
        classInstance = new WaveAPIUtil();
    }

    private WaveAPIUtil() {
    }

    // PUBLIC METHODS
    public static WaveAPIUtil getInstance() {
        return classInstance;
    }

    //////////
    // API METHODS
    //////////
    
    /*
    * Gets a specified Wave dashboard from the Wave REST API.
    * @param  dashboardId the id of the dashboard to fetch from Wave
    * @return    JSON response of a Wave dashboard
    * @see      String
    */
    public String getDashboard(String dashboardId) {
        if (!String.isBlank(dashboardId)) {
            HttpResponse res = sendHttpRequest('wave/dashboards/' + dashboardId, 'GET');
            
            return res.getBody();
        } else {
            return null;
        }
    }

    /*
    * Gets a list of Wave dashboards from the Wave REST API.
    * @return JSON response of a list of Wave dashboards
    * @see String
    */
    public String getDashboardList() {
        HttpResponse res = sendHttpRequest('wave/dashboards', 'GET');
        return res.getBody();
    }
    
    /*
    * Overload function for getting a list of Wave dashboards from the Wave REST
    * API given a map of parameters.
    * @param  params a map of parameters to pass to Wave
    * @return    JSON response of a list of Wave dashboards
    * @see      String
    */
    public String getDashboardList(Map<String, String> params) {
        String reqParams = createQueryString(params);
        HttpResponse res = sendHttpRequest('wave/dashboards' + reqParams, 'GET');
        return res.getBody();
    }

    /*
    * Gets a specified Wave dataset from the Wave REST API.
    *
    * @param  datasetId the id of the dataset to fetch from Wave
    * @return    JSON response of a Wave dataset
    * @see      String
    */
    public String getDataset(String datasetId) {
        if (!String.isBlank(datasetId)) {
            HttpResponse res = sendHttpRequest('wave/datasets/' + datasetId, 'GET');
            return res.getBody();
        } else {
            return null;
        }
    }

    /*
    * Gets a list of Wave datasets from the Wave REST API.
    * @return JSON response of a list of Wave datasets
    * @see String
    */
    public String getDatasetList() {
        HttpResponse res = sendHttpRequest('wave/datasets', 'GET');
        return res.getBody();
    }

    /*
    * Overload function for getting a list of Wave datasets from the Wave REST
    * API given a map of parameters.
    * @param  params a map of parameters to pass to Wave
    * @return JSON response of a list of Wave datasets
    * @see String
    */
    public String getDatasetList(Map<String, String> params) {
        String reqParams = createQueryString(params);
        HttpResponse res = sendHttpRequest('wave/datasets' + reqParams, 'GET');
        return res.getBody();
    }

    // <Salesforce Program Architect 20170524> 
    /*
    * Get Current Version Id for a given Dataset
    * - The Version Id for Dataset gets updated with each refresh
    * - Eventually (though I am not sure when) it can no longer be used in the Dataset Id/VersionId string for the REST API call
    * - This method will allow a Dataset Id to be cached in the org, with programmatic access to the latest Version Id
    * @Author: Salesforce Program Architect
    * @Date: 2017-05-24
    */
   
    // Define a data structure to be used in related JSON parsing.
    private class WaveDatasetInfo { 
        String currentVersionId; 
    } 

    public String getDatasetCurrentVersionId (String datasetId) {
        if (!String.isBlank(datasetId)) {
            String waveDatasetJson = getDataset(datasetId); 
            System.JSONParser parser = System.JSON.createParser(waveDatasetJson); 
            system.debug('parser>>>'+parser);
            WaveDatasetInfo wDI = new WaveDatasetInfo(); 
            if (parser.nextToken() != null) { 
                wDI = (WaveDatasetInfo)parser.readValueAs(WaveDatasetInfo.class); 
            } 
            if (!String.isBlank(wDI.currentVersionId)) {
                return wDI.currentVersionId;
            } else {
                return null;
            }
        } else {
            return null;
        }
    }
    // </Salesforce Program Architect 20170524> 
    
    /*
    * Gets a specified Wave folder from the Wave REST API.
    * @param folderId the id of the folder to fetch from Wave
    * @return JSON response of a Wave folder
    * @see String
    */
    public String getFolder(String folderId) {
        if (!String.isBlank(folderId)) {
            HttpResponse res = sendHttpRequest('wave/folders/' + folderId, 'GET');
            return res.getBody();
        } else {
            return null;
        }
    }

    /*
    * Gets a list of Wave folders from the Wave REST API.
    * @return JSON response of a list of Wave folders
    * @see String
    */
    public String getFolderList() {
        HttpResponse res = sendHttpRequest('wave/folders', 'GET');
        return res.getBody();
    }

    /*
    * Overload function for getting a list of Wave folders from the Wave REST API given a map of parameters
    * @param  params a map of parameters to pass to Wave
    * @return JSON response of a list of Wave folders
    * @see String
    */
    public String getFolderList(Map<String, String> params) {
        String reqParams = createQueryString(params);
        HttpResponse res = sendHttpRequest('wave/folders' + reqParams, 'GET');
        return res.getBody();
    }

    /*
    * Gets a specified Wave lens from the Wave REST API
    * @param lensId the id of the lens to fetch from Wave
    * @return JSON response of a Wave lens
    * @see String
    */
    public String getLens(String lensId) {
        if (!String.isBlank(lensId)) {
            HttpResponse res = sendHttpRequest('wave/lenses/' + lensId, 'GET');
            return res.getBody();
        } else {
            return null;
        }
    }

    /*
    * Gets a list of Wave lenses from the Wave REST API
    * @return JSON response of a list of Wave lenses
    * @see String
    */
    public String getLensList() {
        HttpResponse res = sendHttpRequest('wave/lenses', 'GET');
        return res.getBody();
    }

    /*
    * Overload function for getting a list of Wave lenses from the Wave REST API given a map of parameters.
    * @param params a map of parameters to pass to Wave
    * @return somestringofstuff
    * @see String
    */
    public String getLensList(Map<String, String> params) {
        String reqParams = createQueryString(params);
        HttpResponse res = sendHttpRequest('wave/lenses' + reqParams, 'GET');
        return res.getBody();
    }

    /*
    * Gets the top-level resources available through the Wave REST API
    * @return JSON response of the available Wave REST API resources
    * @see String
    */
    public String getWave() {
        HttpResponse res = sendHttpRequest('wave', 'GET');
        return res.getBody();
    }

    /*
    * Executes a Wave query written in SAQL
    * @param query the query to post to the Wave Query API endpoint
    * @return somestringofstuff
    * @see String
    */
    public String postQuery(String query) {
        if (!String.isBlank(query)) {
            String escQuery = query.replace('"', '\\"');
            String jsonBodyString = '{"query": "' + escQuery + '"}';
            HttpResponse res = sendHttpRequest('wave/query', 'POST', jsonBodyString);
            return res.getBody();
        } else {
            return null;
        }
    }

    public String postQueryAsync(String query, String sessionId) {
        if (!String.isBlank(query)) {
            String escQuery = query.replace('"', '\\"');
            String jsonBodyString = '{"query": "' + escQuery + '"}';
            HttpResponse res = sendHttpRequestAsync('wave/query', 'POST', jsonBodyString, sessionId);            
            return res.getBody();
        } else {
            return null;
        }
    }
    
    // <Salesforce Program Architect 20170603> 
    // The following block of code is meant to return Wave Asset Metadata
    // This requries a bit of recursion to deal with the fact that the REST API is limited to a max of 200 records with a nextPageURL 
    
    // Define the Wave Asset Metadata that we are interested in
    // (Currently, this is common across asset types, so we have a uniform data structure)
    public class WaveAssetRecord {
        string id;
        string label;
    }

    // This is the initialization method that will start the recursive calls, based on the asset type
    public Map<String,String> getWaveAssetMetadata (String assetType) {
        System.debug('>>>sfdcDebug>>> ENTER getWaveAssetMetadata');
        System.debug('>>>sfdcDebug>>> assetType = ' + assetType);        
        System.debug('>>>sfdcDebug>>> Save WAVE_API_BASE_URL in cachedWaveApiBaseUrl = ' + cachedWaveApiBaseUrl);
        // Reset WAVE_API_BASE_URL and then set it to ''
        // - This is to support a slightly different pattern wherein the entire URL will be passed into sendHttpRequest
        // - This is something of a hack, but it allows us to re-use existing code, and it is not too quirky
        WAVE_API_BASE_URL = '';
        System.debug('>>>sfdcDebug>>> Reset WAVE_API_BASE_URL = ' + WAVE_API_BASE_URL);
        if(assetType == 'dashboards') {
            System.debug('>>>sfdcDebug>>> Get Dashboard Metadata');
            return recursivelyGetWaveAssetMetadata (cachedWaveApiBaseUrl + 'wave/dashboards?pageSize=' + WAVE_REST_API_MAX_PAGESIZE);
        } else if (assetType == 'datasets') {
            System.debug('>>>sfdcDebug>>> Get Dataset Metadata');
            return recursivelyGetWaveAssetMetadata (cachedWaveApiBaseUrl + 'wave/datasets?pageSize=' + WAVE_REST_API_MAX_PAGESIZE);
        } else if (assetType == 'lenses') {
            System.debug('>>>sfdcDebug>>> Get Lens Metadata');
            return recursivelyGetWaveAssetMetadata (cachedWaveApiBaseUrl + 'wave/lenses?pageSize=' + WAVE_REST_API_MAX_PAGESIZE);
        } else {
            return null;        
        }
    }
    
    // Keep track of the stack, and, for DEV validation, the number of assets
    // These do not need to be static, because we are recursively invoking a method, not recursively instantiating the class
    Private Integer recursiveCallCounter = 1;
    Private Integer waveAssetCounter = 0;
    
    // Recursively call the Wave REST API until nextPageUrl == 'null' - i.e. no more results to process
    public Map<String,String> recursivelyGetWaveAssetMetadata (String serviceUrl) {
        System.debug('>>>sfdcDebug>>> ENTER recursivelyGetWaveAssetMetadata');
        System.debug('>>>sfdcDebug>>> WAVE_API_BASE_URL (should still be blank) = ' + WAVE_API_BASE_URL);
        System.debug('>>>sfdcDebug>>> serviceUrl = ' + serviceUrl);
        Map<String,String> waveAssetMetadataMap = new Map<String,String>();
        String nextPageUrl;
        HttpResponse res = sendHttpRequest(serviceUrl, 'GET');
        System.JSONParser parser = System.JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        ++waveAssetCounter;
                        WaveAssetRecord waveRec = (WaveAssetRecord)parser.readValueAs(WaveAssetRecord.class);
                        waveAssetMetadataMap.put(waveRec.id, waveRec.label);
                        parser.skipChildren();
                    } else if (parser.getCurrentName() == 'nextPageUrl') {
                        nextPageUrl = parser.getText();
                    }
                }
            }
        }
        // Here is where we determine if we have reached the end of recursion, i.e. based on the presence (or not) of nextPageUrl
        // In reality, nextPageUrl will be the string 'null' because this is how JSON represents it, but we'll also check for null
        if(nextPageUrl == 'null' || nextPageUrl == null) {
            System.debug('>>>sfdcDebug>>> End of Recursion');
            System.debug('>>>sfdcDebug>>> # Recursive Calls = ' + recursiveCallCounter);
            System.debug('>>>sfdcDebug>>> # Wave Assets Accumulated = ' + waveAssetCounter);            
            return waveAssetMetadataMap;
        } else {
            // nextPageUrl includes everything except the base URL, e.g. /services/data/v##.#/wave/dashboards?page=<identifier>
            // Thus, we need only prepend the base URL to nextPageUrl to get a valid URL for the next recursive call
            // We append the map returned from the recursive call to the map generated in this call, thereby accumulating results
            // Note: I would prefer to put the recursive call in the return statement itself, but Map.putAll returns void :-/
            ++recursiveCallCounter;
            System.debug('>>>sfdcDebug>>> Continue Recursion (# Recursive Calls = ' + recursiveCallCounter + ')');
            System.debug('>>>sfdcDebug>>> URL for Next Call: ' + URL.getSalesforceBaseUrl().toExternalForm() + nextPageUrl);
            waveAssetMetadataMap.putAll(recursivelyGetWaveAssetMetadata(URL.getSalesforceBaseUrl().toExternalForm() + nextPageUrl));
            return(waveAssetMetadataMap);
        }
    }
    // </Salesforce Program Architect 20170603> 
    
    //////////
    // HELPER METHODS
    //////////

    /*
    * Creates a query string for an HttpRequest
    *
    * @return query string to use in HttpRequest
    * @see String
    */
    @TestVisible private String createQueryString(Map<String, String> params) {
        String[] keyValuePairs = new List<String>();
        String queryString = '?';        
        for (String key : params.keySet()) {
            keyValuePairs.add(key + '=' + params.get(key));
        }
        queryString += String.join(keyValuePairs, '&');
        return queryString;
    }

    /*
    * Sends an HttpRequest and returns a response
    * @param reqEndpoint the request endpoint for the intended HttpRequest
    * @param reqMethod the request method for the intended HttpRequest
    * @return an HttpRequest for a given endpoint and method
    * @see HttpResponse
    */
    private HttpResponse sendHttpRequest(String reqEndpoint, String reqMethod) {
        Http h = new Http();
        HttpRequest req = setupHttpRequest(reqEndpoint, reqMethod);
        HttpResponse res = h.send(req);        
        return res;
    }

    /*
    * Overload function that sends an HttpRequest with given parameters and returns a response
    * @param reqEndpoint the request endpoint for the intended HttpRequest
    * @param reqMethod the request method for the intended HttpRequest
    * @param params the parameters for the intended HttpRequest
    * @return an HttpRequest for a given endpoint and method
    * @see HttpResponse
    */
    private HttpResponse sendHttpRequest(String reqEndpoint, String reqMethod, String params) {
        Http h = new Http();
        HttpRequest req = setupHttpRequest(reqEndpoint, reqMethod);        
        if (reqMethod == 'POST') {
            req.setBody(params);
        }
        HttpResponse res = h.send(req);
        return res;
    }

    private HttpResponse sendHttpRequestAsync(String reqEndpoint, String reqMethod, String params, String sessionId) {
        Http h = new Http();
        HttpRequest req = setupHttpRequestAsync(reqEndpoint, reqMethod, sessionId);        
        if (reqMethod == 'POST') {
            req.setBody(params);
        }
        HttpResponse res = h.send(req);
        return res;
    }
    // setupHttpRequest: Sets up an HttpRequest object
    /*
    * Sets up an HttpRequest object
    * @param reqEndpoint the request endpoint for the intended HttpRequest
    * @param reqMethod the request method for the intended HttpRequest
    * @return an HttpRequest for a given endpoint and method
    * @see HttpRequest
    */
    @TestVisible private HttpRequest setupHttpRequest(String reqEndpoint, String reqMethod) {
        // <Salesforce Program Architect 20170602>
        // Determine if we have an active session (i.e. we are not in batch mode) or else establish one.
        String waveSessionId;
        if(UserInfo.getSessionId() == null) {
            LoginCredentials__c waveUser = LoginCredentials__c.getInstance('SalesforceWaveIntegrationUser');
            if(waveUser != null) {
                waveSessionId = LoginToGetSessionId.login(waveUser.UserName__c, DecodeEncodeUtility.decodeData(waveUser.EncryptedPassword__c));
            }
        } else {
            waveSessionId = UserInfo.getSessionId();
        }
        // </Salesforce Program Architect 20170602>        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(WAVE_API_BASE_URL + reqEndpoint);
        req.setMethod(reqMethod);
        req.setHeader('Authorization', 'OAuth ' + waveSessionId);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(30000);
        return req;
    }

    @TestVisible private HttpRequest setupHttpRequestAsync(String reqEndpoint, String reqMethod, String sessionId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(WAVE_API_BASE_URL + reqEndpoint);
        req.setMethod(reqMethod);
        req.setHeader('Authorization', 'OAuth ' + sessionId);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(30000);       
        return req;
    }
}