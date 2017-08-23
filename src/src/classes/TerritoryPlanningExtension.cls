/**
 * This is an extension for the TerritoryPlanning Visualforce page.
 *
 * @Author salesforce Services
 * @Date 08/31/2016
 */
global class TerritoryPlanningExtension {


  private static WaveAPIUtil wave;
  private static String WAVE_API_BASE;
  private static String SORT_COLUMN;
  private static Integer BATCH_SIZE;
  private static Integer MAX_THREADS;

  private static SystemProperties props;
  static{
    props = new SystemProperties();
    WAVE_API_BASE=props.getSytemProperty('Wave_Api_Endpoint', 'Wave');
    SORT_COLUMN=props.getSytemProperty('Territory_Sort_Column', 'Territory Management');
    BATCH_SIZE = Integer.valueOf(props.getSytemProperty('Batch_Size', 'Territory Management'));
    MAX_THREADS = Integer.valueOf(props.getSytemProperty('Territory_Max_Threads', 'Territory Management'));
      wave = WaveAPIUtil.getInstance();
  }
  global class LensAndXmd{
    WaveLens lens;
    WaveXmd xmd;
    public String xmdStr {get; set;}
    public String versionId {get; set;}
    public String sortColumn {get; set;}
    public Integer batchSize {get; set;}
    public Integer maxThreads {get; set;}
    public LensAndXmd(WaveLens lens,WaveXmd xmd){
      this.lens=lens;
      this.xmd=xmd;
    }
  }



  global class ProcessParams{
    public String lensName {get; set;}
    public String saqlQuery {get; set;}
    public String lastSaqlExecuted {get; set;}
    public String apiRequestId {get; set;}
    public Long requestStartTime {get; set;}
    public String sortColumn {get; set;}
    public Integer batchSize {get; set;}
    public String processName {get; set;}
    public String territoryId {get; set;}
    public String region {get; set;}
    public String censusTracts {get; set;}
    public List<String> columns {get; set;}

    public Integer errorCount {get; set;}
    public List<String> errorIds {get; set;}
    public Integer recordCount {get; set;}
    public Integer currRecordCount {get; set;}
    public Integer currentChunk {get; set;}

    public Map<String,ProcessMetric> processMetrics {get; set;}
    public void addProcessMetric(ProcessMetric metric,boolean additive){
      if(processMetrics==null){
        processMetrics = new Map<String,ProcessMetric>();
      }
      ProcessMetric currMetric =processMetrics.get(metric.metricName);
      if(currMetric!=null){
        if(additive)
          currMetric.metricValue +=metric.metricValue;
        else{
          currMetric.metricValue =metric.metricValue;
        }
      }else{
        processMetrics.put(metric.metricName,metric);
      }
    }
  }

  global class FileInfo{
    public String name {get; set;}
    public String id {get; set;}
    public FileInfo(String name,String id){
      this.name=name;
      this.id=id;
    }
  }
  global class ProcessMetric{
    public String metricName {get; set;}
    public Long metricValue {get; set;}
    public Long metricLimit {get; set;}
    public ProcessMetric(String name,Long val,Long lmt){
      this.metricName=name;
      this.metricValue=val;
      this.metricLimit=lmt;
    }

  }

  @RemoteAction
  global static List<WaveLenses.Lenses> getAvailableLenses(){
    String lensList = wave.getLensList();
      List<WaveLenses.Lenses> retList = new List<WaveLenses.Lenses>();
      WaveLenses lenses = WaveLenses.parse(lensList);
      for(WaveLenses.Lenses lens:lenses.lenses){
        if('valuestable'.equalsIgnoreCase(lens.visualizationType)){
          retList.add(lens);
        }
      }

      return retList;
  }
  @RemoteAction
  global static LensAndXmd getLensData(String lensId){
      String lensData = wave.getLens(lensId);

    WaveLens lens =  WaveLens.parse(lensData);
    System.debug(lens);

    String filters = lens.state.query.query;
    System.debug('filters:'+filters);
    filters = filters.replace('&amp;','&');
    System.debug('filters after & replace:'+filters);
    filters = filters.replace('&quot;','"');
    System.debug('filters after " replace:'+filters);
    lens.state.query.query = filters;

      String dataSetData = wave.getDataset(lens.dataset.id);    
      WaveDataset dataset = WaveDataset.parse(dataSetData);


    String mainXmdUrl = WAVE_API_BASE+dataset.currentVersionUrl+'/xmds/main';

    Http h = new Http();

    HttpRequest req = new HttpRequest();
      req.setEndpoint(mainXmdUrl);
      req.setMethod('GET');
      req.setHeader('Authorization','OAuth '+UserInfo.getSessionId());
      //Send the request, and return a response
      HttpResponse res = h.send(req);

      //WaveXmd xmd = WaveXmd.parse(res.getBody());
      //xmd.versionId = dataset.currentVersionId;
    LensAndXmd retVal = new LensAndXmd(lens,null);
    retVal.versionId= dataset.currentVersionId;
    String xmdStr = res.getBody();
    xmdStr = xmdStr.replace('&quot;&quot;','\\"\\"');
    retVal.xmdStr = xmdStr;
    retVal.sortColumn=SORT_COLUMN;
    retVal.batchSize=BATCH_SIZE;
    retVal.maxThreads=MAX_THREADS;
    return retVal;
  }

  @RemoteAction
  global static Object createTerritory(ProcessParams params){
    //Blank out processMetrics as this hits a Continuation known issue
    params.processMetrics = null;
      Http h = new Http();
    List<String> tokens = params.saqlQuery.split(';');
    String saqlWithCoount='';
    for(Integer i=0;i<tokens.size()-2;i++){
        saqlWithCoount+=tokens.get(i)+';';
    }
    saqlWithCoount +='q = group q by all;';
    saqlWithCoount +='q = foreach q generate count() as \'count\';';
    System.debug('SAQL Query:'+saqlWithCoount);
    String saqlQueryEsc = saqlWithCoount.replace('"', '\\"');
    System.debug('SAQL Query:'+saqlQueryEsc);
      HttpRequest req = new HttpRequest();
      req.setEndpoint(WAVE_API_BASE+'/services/data/v36.0/wave/query');
      req.setMethod('POST');
      req.setHeader('Authorization','OAuth '+UserInfo.getSessionId());
      req.setHeader('Content-Type','application/json');
      req.setBody('{"query":"'+saqlQueryEsc+'"}');

      // Create a Continuation for the HTTPRequest
      Continuation con = new Continuation(60);
      params.apiRequestId = con.addHttpRequest(req);
      params.requestStartTime=System.now().getTime();
      con.state = params;
      con.continuationMethod = 'createTerritoryCallback';
      return con;
  }

  public static ProcessParams createTerritoryCallback(Object state){
    String orderField = SORT_COLUMN;
      ProcessParams params = (ProcessParams)state;
      Long startTime = params.requestStartTime;

      HttpResponse res = Continuation.getResponse(params.apiRequestId);

      JsonParser theParser = Json.createParser(res.getBody());
    theParser.nextToken();
    Boolean countObj = false;
    Integer recCnt=0;
    while(theParser.hasCurrentToken()){
        if('count'.equalsIgnoreCase(theParser.getText()) && theParser.getCurrentToken() == JsonToken.FIELD_NAME){
            countObj=true;
        }
        if(countObj && theParser.getCurrentToken() == JsonToken.VALUE_NUMBER_INT){
            recCnt = theParser.getIntegerValue();
            break;
        }

        theParser.nextToken();
    }

    Territory__c territory = new Territory__c(Name=params.lensName,Region__c=params.region,Territory_Code__c=params.lensName,
                                              Census_Tracts__c=params.censusTracts,Status__c='Draft');

    insert territory;
    params.territoryId=territory.Id;

        //Create the territory if a territory Id is not found
      //Database.insert(territory,false);

    params.recordCount=recCnt;
    params.addProcessMetric(new ProcessMetric('cpuTime',(Long)System.Limits.getCpuTime(),(Long)System.Limits.getLimitCpuTime()),false);
      Long endTime = System.now().getTime();
      params.addProcessMetric(new ProcessMetric('endToEnd',(endTime-startTime),null),true);
      params.addProcessMetric(new ProcessMetric('dbTime',0,null),true);
      params.addProcessMetric(new ProcessMetric('apiTime',0,null),true);
      params.addProcessMetric(new ProcessMetric('processTime',0,null),true);
      return params;
  }


  @RemoteAction
  global static ProcessParams assignAddressToTerritory(ProcessParams params){
    System.debug(params);
      Long startTime = System.now().getTime();
    Integer chunkSize = params.batchSize;
    Integer offset;

    offset = params.currentChunk * chunkSize;
    params.currentChunk++;

    String orderField = params.sortColumn;
      Http h = new Http();
    System.debug('SAQL Query:'+params.saqlQuery);
    List<String> tokens = params.saqlQuery.split(';');
    String saqlWithNewLimit='';
    for(Integer i=0;i<tokens.size()-1;i++){
        saqlWithNewLimit+=tokens.get(i)+';';
    }

    //saqlWithNewLimit +='r = order q by \''+orderField+'\' asc;';
    saqlWithNewLimit +='q = offset q '+offset+';';
    saqlWithNewLimit +='q = limit q '+chunkSize+';';

    System.debug('>>>>>SAQL Query executed:'+saqlWithNewLimit);
    params.lastSaqlExecuted = saqlWithNewLimit;

    Long timeStart = System.now().getTime();
    String resBody = wave.postQuery(saqlWithNewLimit);
    Long timeEnd = System.now().getTime();
    params.addProcessMetric(new ProcessMetric('apiTime',(timeEnd-timeStart),null),false);

    timeStart=System.now().getTime();
    JsonParser theParser = Json.createParser(resBody);
    theParser.nextToken();
    Integer tokenIdx=1,depth=0,recordCnt=0;
    Map<String,String> record = new Map<String,String>();
    Boolean objStarted=false,recordsNode=false;
    String finalCSV='';
    List<Customer_Address__c> addressToUpdate = new List<Customer_Address__c>();
    while(theParser.hasCurrentToken()){
        if(theParser.getCurrentToken() == JsonToken.FIELD_NAME && 'records'.equalsIgnoreCase(theParser.getText())){
            recordsNode=true;
        }

        if(recordsNode && theParser.getCurrentToken() == JsonToken.START_OBJECT){
            objStarted=true;
            recordCnt++;
        }

        if(recordsNode && theParser.getCurrentToken() == JsonToken.END_OBJECT){
            objStarted=false;
            //Add to the list of Address to be updated
            if(record.get('Id')!=null){
              addressToUpdate.add(new Customer_Address__c(Id=record.get('Id'),Territory__c=params.territoryId));
          }
            record = new Map<String,String>();
        }

        if(recordsNode && theParser.getCurrentToken() == JsonToken.FIELD_NAME && objStarted){
            String fieldName = theParser.getText();
            theParser.nextToken();
            String fieldValue = theParser.getText();
            record.put(fieldName,fieldValue);
        }
        theParser.nextToken();
    }

    timeEnd=System.now().getTime();
    params.addProcessMetric(new ProcessMetric('processTime',(timeEnd-timeStart),null),false);

    try{


            //Conduct the update operation
        params.errorIds=new List<String>();
        timeStart = System.now().getTime();
        Database.SaveResult[] srList = Database.Update(addressToUpdate,false);
        timeEnd = System.now().getTime();
        params.addProcessMetric(new ProcessMetric('dbTime',(timeEnd-timeStart),null),false);
        if(params.errorCount == null){
          params.errorCount = 0;
        }

        for(Database.SaveResult saveRes:srList){
          if(!saveRes.isSuccess()){
            for(Database.Error err:saveRes.getErrors()){
              System.debug('>>>>>>'+saveRes.getId()+',Error:'+err.getMessage());
              params.errorCount++;
            }
          }
        }
        params.currRecordCount += recordCnt;


      }
      catch(DmlException e){
        throw e;

      }


      params.addProcessMetric(new ProcessMetric('cpuTime',(Long)System.Limits.getCpuTime(),(Long)System.Limits.getLimitCpuTime()),false);
      Long endTime = System.now().getTime();
      params.addProcessMetric(new ProcessMetric('endToEnd',(endTime-startTime),null),true);
      return params;

  }
}