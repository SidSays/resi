global class TerritoryValidationController {
	private static WaveAPIUtil wave;
	private static Integer LENS_PAGE_SIZE=200;


  private static SystemProperties props;
  static{
      wave = WaveAPIUtil.getInstance();
  }
  
  global class ProcessParams{
  	public String currentLensId {get; set;}
  	public Map<String,List<String>> censusTracts {get; set;}
  	public List<String> lensIdList {get; set;}
    public WaveLens lensData {get; set;}
    public Integer recordCount {get; set;}
    public Integer currentRecordCount {get; set;}
    public String processName {get; set;}

  }


  @RemoteAction
  global static List<String> getRegions(){
    List<String>regionList = new List<String>();
  	Schema.DescribeFieldResult dfr = Territory__c.Region__c.getDescribe();
  	for(Schema.PicklistEntry pickListEntry: dfr.getPickListValues()){
  		if('Global' != picklistEntry.getValue()){
  			regionList.add(pickListEntry.getValue());
  		}    
  	}

	  return regionList;
  }

  @RemoteAction
  global static String getFolderIdForRegion(String region){
  	String folderResp = wave.getFolderList();
  	WaveFolders folders = WaveFolders.parse(folderResp);

	for(WaveFolders.Folders theFolder:folders.folders){
		if((region+' Territories').equalsIgnoreCase(theFolder.label)){
		  return theFolder.id;
		}
	}

    return null;
  }

  @RemoteAction
  global static List<String> getAvailableLenses(String folderId){
  	Map<String,String> apiParams = new Map<String,String>();
  	apiParams.put('folderId',folderId);
  	apiParams.put('pageSize',String.valueOf(LENS_PAGE_SIZE));
    String lensList = wave.getLensList(apiParams);
	List<String> retList = new List<String>();
	Integer lensCount = 0;
	WaveLenses lenses = WaveLenses.parse(lensList);
	for(WaveLenses.Lenses lens:lenses.lenses){

		if('valuestable'.equalsIgnoreCase(lens.visualizationType)){
			retList.add(lens.id);
		}
	}
  	return retList;
  }
  
  @RemoteAction
  global static ProcessParams getLensData(ProcessParams params){
  	System.debug('>>>>>>>> lendsId:'+params.lensIdList.get(params.currentRecordCount));
    String lensData = wave.getLens(params.lensIdList.get(params.currentRecordCount));
  
    WaveLens lens =  WaveLens.parse(lensData);
    System.debug(lens);

    String filters = lens.state.query.query;
    System.debug('filters:'+filters);
    filters = filters.replace('&amp;','&');
    System.debug('filters after & replace:'+filters);
    filters = filters.replace('&quot;','"');
    System.debug('filters after " replace:'+filters);
    lens.state.query.query = filters;
    params.lensData = lens;
    return params;
  }

}