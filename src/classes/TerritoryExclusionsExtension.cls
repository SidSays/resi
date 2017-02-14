/**
 * This is an extension for the TerritoryExclusions Visualforce page.
 *
 * @Author salesforce Services
 * @Date 10/24/2016
 */
global class TerritoryExclusionsExtension {
  private static WaveAPIUtil wave;
  private static String WAVE_API_BASE;
  private static String SORT_COLUMN;
  private static Integer BATCH_SIZE;
  private static Integer MAX_THREADS;
  public static Boolean exclude {get; set;}

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

  public static Integer saqlToCount(String saql){
    List<String> tokens = saql.split(';');
    String saqlWithCoount='';
    for(Integer i=0;i<tokens.size()-1;i++){
        saqlWithCoount+=tokens.get(i)+';';
    }
    saqlWithCoount +='q = group q by all;';
    saqlWithCoount +='q = foreach q generate count() as \'count\';';  
    System.debug('SAQL Query:'+saqlWithCoount);
    String saqlQueryEsc = saqlWithCoount.replace('"', '\\"');
    System.debug('SAQL Query:'+saqlQueryEsc);

   
    String queryRes = wave.postQueryAsync(saqlWithCoount, UserInfo.getSessionId());
    // We only care about the list of records contained in this response (queryRes.results.records)
    Map<String, Object> postQueryMap = (Map<String, Object>) JSON.deserializeUntyped(queryRes);
    System.debug('>>>>>>> postQueryMap='+postQueryMap);
    Map<String, Object> results = (Map<String, Object>)postQueryMap.get('results');
    List<Object> countList = (List<Object>)results.get('records');
    Map<String,Object> countRow = (Map<String,Object>)countList.get(0);
    System.debug('>>>>>>> countRow='+countRow);
    return Integer.valueOf(countRow.get('count'));
  }

  @RemoteAction
  global static void executeExclusionsBatch(String saql, Boolean excludeTerritories, String lensId, String lensName){
    Integer count = saqlToCount(saql);
    TerritoryExclusionsBatch t = new TerritoryExclusionsBatch(saql, excludeTerritories, UserInfo.getSessionId(), UserInfo.getUserId(), count, lensId, lensName);
    t.executeBatch();
  }
}