/**
 * This is a utility class for interacting with the Wave REST API.
 *
 * @Author salesforce Services
 * @Date 08/31/2016
 */
public with sharing class WaveAPIUtil {
  private static String WAVE_API_BASE_URL;
  private static String WAVE_API_VERSION;

  private static WaveAPIUtil classInstance;

  static {
    WAVE_API_VERSION = 'v36.0';

    WAVE_API_BASE_URL = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/' + WAVE_API_VERSION + '/';

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

  /**
   * Gets a specified Wave dashboard from the Wave REST API.
   *
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

  /**
   * Gets a list of Wave dashboards from the Wave REST API.
   *
   * @return    JSON response of a list of Wave dashboards
   * @see      String
   */
  public String getDashboardList() {
    HttpResponse res = sendHttpRequest('wave/dashboards', 'GET');

    return res.getBody();
  }

  /**
   * Overload function for getting a list of Wave dashboards from the Wave REST
   * API given a map of parameters.
   *
   * @param  params a map of parameters to pass to Wave
   * @return    JSON response of a list of Wave dashboards
   * @see      String
   */
  public String getDashboardList(Map<String, String> params) {
    String reqParams = createQueryString(params);
    HttpResponse res = sendHttpRequest('wave/dashboards' + reqParams, 'GET');

    return res.getBody();
  }

  /**
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

  /**
   * Gets a list of Wave datasets from the Wave REST API.
   *
   * @return    JSON response of a list of Wave datasets
   * @see      String
   */
  public String getDatasetList() {
    HttpResponse res = sendHttpRequest('wave/datasets', 'GET');

    return res.getBody();
  }

  /**
   * Overload function for getting a list of Wave datasets from the Wave REST
   * API given a map of parameters.
   *
   * @param  params a map of parameters to pass to Wave
   * @return    JSON response of a list of Wave datasets
   * @see      String
   */
  public String getDatasetList(Map<String, String> params) {
    String reqParams = createQueryString(params);
    HttpResponse res = sendHttpRequest('wave/datasets' + reqParams, 'GET');

    return res.getBody();
  }

  /**
   * Gets a specified Wave folder from the Wave REST API.
   *
   * @param  folderId the id of the folder to fetch from Wave
   * @return    JSON response of a Wave folder
   * @see      String
   */
  public String getFolder(String folderId) {
    if (!String.isBlank(folderId)) {
      HttpResponse res = sendHttpRequest('wave/folders/' + folderId, 'GET');

      return res.getBody();
    } else {
      return null;
    }
  }

  /**
   * Gets a list of Wave folders from the Wave REST API.
   *
   * @return    JSON response of a list of Wave folders
   * @see      String
   */
  public String getFolderList() {
    HttpResponse res = sendHttpRequest('wave/folders', 'GET');

    return res.getBody();
  }

  /**
   * Overload function for getting a list of Wave folders from the Wave REST API
   * given a map of parameters.
   *
   * @param  params a map of parameters to pass to Wave
   * @return    JSON response of a list of Wave folders
   * @see      String
   */
  public String getFolderList(Map<String, String> params) {
    String reqParams = createQueryString(params);
    HttpResponse res = sendHttpRequest('wave/folders' + reqParams, 'GET');

    return res.getBody();
  }

  /**
   * Gets a specified Wave lens from the Wave REST API.
   *
   * @param  lensId the id of the lens to fetch from Wave
   * @return    JSON response of a Wave lens
   * @see      String
   */
  public String getLens(String lensId) {
    if (!String.isBlank(lensId)) {
      HttpResponse res = sendHttpRequest('wave/lenses/' + lensId, 'GET');

      return res.getBody();
    } else {
      return null;
    }
  }

  /**
   * Gets a list of Wave lenses from the Wave REST API.
   *
   * @return    JSON response of a list of Wave lenses
   * @see      String
   */
  public String getLensList() {
    HttpResponse res = sendHttpRequest('wave/lenses', 'GET');

    return res.getBody();
  }

  /**
   * Overload function for getting a list of Wave lenses from the Wave REST API
   * given a map of parameters.
   *
   * @param  params a map of parameters to pass to Wave
   * @return    somestringofstuff
   * @see      String
   */
  public String getLensList(Map<String, String> params) {
    String reqParams = createQueryString(params);
    HttpResponse res = sendHttpRequest('wave/lenses' + reqParams, 'GET');

    return res.getBody();
  }

  /**
   * Gets the top-level resources available through the Wave REST API.
   *
   * @return    JSON response of the available Wave REST API resources
   * @see      String
   */
  public String getWave() {
    HttpResponse res = sendHttpRequest('wave', 'GET');

    return res.getBody();
  }

  /**
   * Executes a Wave query written in SAQL
   *
   * @param  query the query to post to the Wave Query API endpoint
   * @return    somestringofstuff
   * @see      String
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
  //////////
  // HELPER METHODS
  //////////

  /**
   * Creates a query string for an HttpRequest
   *
   * @return    query string to use in HttpRequest
   * @see      String
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

  /**
   * Sends an HttpRequest and returns a response.
   *
   * @param  reqEndpoint the request endpoint for the intended HttpRequest
   * @param  reqMethod the request method for the intended HttpRequest
   * @return    an HttpRequest for a given endpoint and method
   * @see      HttpResponse
   */
  private HttpResponse sendHttpRequest(String reqEndpoint, String reqMethod) {
    Http h = new Http();
    HttpRequest req = setupHttpRequest(reqEndpoint, reqMethod);
    HttpResponse res = h.send(req);

    return res;
  }

  /**
   * Overload function that sends an HttpRequest with given parameters and
   * returns a response.
   *
   * @param  reqEndpoint the request endpoint for the intended HttpRequest
   * @param  reqMethod the request method for the intended HttpRequest
   * @param  params the parameters for the intended HttpRequest
   * @return    an HttpRequest for a given endpoint and method
   * @see      HttpResponse
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
  /**
   * Sets up an HttpRequest object.
   *
   * @param  reqEndpoint the request endpoint for the intended HttpRequest
   * @param  reqMethod the request method for the intended HttpRequest
   * @return    an HttpRequest for a given endpoint and method
   * @see      HttpRequest
   */
  @TestVisible private HttpRequest setupHttpRequest(String reqEndpoint, String reqMethod) {
    HttpRequest req = new HttpRequest();

    req.setEndpoint(WAVE_API_BASE_URL + reqEndpoint);
    req.setMethod(reqMethod);
    req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
    req.setHeader('Content-Type', 'application/json');

    return req;
  }

  @TestVisible private HttpRequest setupHttpRequestAsync(String reqEndpoint, String reqMethod, String sessionId) {
    HttpRequest req = new HttpRequest();

    req.setEndpoint(WAVE_API_BASE_URL + reqEndpoint);
    req.setMethod(reqMethod);
    req.setHeader('Authorization', 'OAuth ' + sessionId);
    req.setHeader('Content-Type', 'application/json');

    return req;
  }
}