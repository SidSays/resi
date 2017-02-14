global class Export2ExcelController {

	private static String WAVE_API_BASE;
	private static String SORT_COLUMN;
	private static Integer RECORDS_PER_FILE;
	private static Integer BYTES_PER_FILE;
	private static Integer MAX_COLUMNS;
	private static Integer MAX_RECORDS;
	private static String LEADING_0_COLUMNS;

	private static SystemProperties props;
	static{
		props = new SystemProperties();
		WAVE_API_BASE=props.getSytemProperty('Wave_Api_Endpoint', 'Wave');
		SORT_COLUMN=props.getSytemProperty('Wave_Sort_Column', 'Wave');
		RECORDS_PER_FILE = Integer.valueOf(props.getSytemProperty('Records_Per_File', 'Wave'));
		BYTES_PER_FILE = Integer.valueOf(props.getSytemProperty('Bytes_Per_File', 'Wave'));
		MAX_COLUMNS = Integer.valueOf(props.getSytemProperty('Max_Columns', 'Wave'));
		MAX_RECORDS = Integer.valueOf(props.getSytemProperty('Max_Records', 'Wave'));
		LEADING_0_COLUMNS = props.getSytemProperty('Leading_0_Columns', 'Wave');

	}
	global class LensAndXmd{
		WaveLens lens;
		WaveXmd xmd;
		public String xmdStr {get; set;}
		public String versionId {get; set;}
		public String sortColumn {get; set;}
		public Integer recordsPerTempFile {get; set;}
		public Integer bytesPerFile {get; set;}
		public Integer maxColumns {get; set;}
		public String leadingZeroColumns {get; set;}
		public LensAndXmd(WaveLens lens,WaveXmd xmd){
			this.lens=lens;
			this.xmd=xmd;
		}
	}



	global class Export2ExcelParams{
		public String lensName {get; set;}
		public String saqlQuery {get; set;}
		public String lastSaqlExecuted {get; set;}
		public List<String> tempFileIdList {get; set;}
		public String apiRequestId {get; set;}
		public Long requestStartTime {get; set;}
		public String sortColumn {get; set;}
		public Integer recordsPerTempFile {get; set;}
		public Integer bytesPerFile {get; set;}
		public Integer maxRecords {get; set;}
		public String processName {get; set;}		
		public List<String> columnLabels {get; set;}
		public String leadingZeroColumns {get; set;}

		public List<String> fileIdList {
			get {
				if(this.fileIdList==null){
					fileIdList = new List<String>();
				}
				return fileIdList;
			} 
			set;
		}
		public List<FileInfo> finalFileIdList {
			get {
				if(this.finalFileIdList==null){
					finalFileIdList = new List<FileInfo>();
				}
				return finalFileIdList;
			} 
			set;
		}
		public List<String> columns {get; set;}
		public Integer recordCount {get; set;}
		public Integer currRecordCount {get; set;}
		public Integer currentChunk {get; set;}

		public Export2ExcelParams(){
			fileIdList = new List<String>();
		}
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
		public void addFileToList(String fileId){
			if(fileIdList==null){
				fileIdList = new List<String>();
			}
			fileIdList.add(fileId);
		}
		public void addFinalFileToList(FileInfo file){
			if(finalFileIdList==null){
				finalFileIdList = new List<FileInfo>();
			}
			finalFileIdList.add(file);
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
	    Http h = new Http();
	    HttpRequest req = new HttpRequest();
	    req.setEndpoint(WAVE_API_BASE+'/services/data/v36.0/wave/lenses');
	    req.setMethod('GET');
	    req.setHeader('Authorization','OAuth '+UserInfo.getSessionId());
	    HttpResponse res = h.send(req);

	    List<WaveLenses.Lenses> retList = new List<WaveLenses.Lenses>();
	    WaveLenses lenses = WaveLenses.parse(res.getBody());
	    for(WaveLenses.Lenses lens:lenses.lenses){
	    	if('valuestable'.equalsIgnoreCase(lens.visualizationType)){
	    		retList.add(lens);
	    	}
	    }

	    return retList;
	}
	@RemoteAction
	global static LensAndXmd getLensData(String lensId){
	    Http h = new Http();
	     // Get Lens metadata from /services/data/v36.0/wave/lenses/{lensid}
	    HttpRequest req = new HttpRequest();
	    req.setEndpoint(WAVE_API_BASE+'/services/data/v36.0/wave/lenses/'+lensId);
	    req.setMethod('GET');
	    req.setHeader('Authorization','OAuth '+UserInfo.getSessionId());
	    // Send the request, and return a response
	    HttpResponse res = h.send(req);
	
		WaveLens lens =  WaveLens.parse(res.getBody());
		System.debug(lens);

		String filters = lens.state.query.query;
		System.debug('filters:'+filters);
		filters = filters.replace('&amp;','&');
		System.debug('filters after & replace:'+filters);
		filters = filters.replace('&quot;','"');
		System.debug('filters after " replace:'+filters);
		lens.state.query.query = filters;

		// Get dataset version metadata from /services/data/v36.0/wave/datasets/{datasetid}/versions
		req = new HttpRequest();
	    req.setEndpoint(WAVE_API_BASE+'/services/data/v36.0/wave/datasets/'+lens.dataset.id);
	    req.setMethod('GET');
	    req.setHeader('Authorization','OAuth '+UserInfo.getSessionId());
	    
	    // Send the request, and return a response
	    res = h.send(req);		
	    WaveDataset dataset = WaveDataset.parse(res.getBody());


		String mainXmdUrl = WAVE_API_BASE+dataset.currentVersionUrl+'/xmds/main';

		req = new HttpRequest();
	    req.setEndpoint(mainXmdUrl);
	    req.setMethod('GET');
	    req.setHeader('Authorization','OAuth '+UserInfo.getSessionId());
	    //Send the request, and return a response
	    res = h.send(req);	
	    
	    //WaveXmd xmd = WaveXmd.parse(res.getBody());
	    //xmd.versionId = dataset.currentVersionId;
		LensAndXmd retVal = new LensAndXmd(lens,null);
		retVal.versionId= dataset.currentVersionId;
		String xmdStr = res.getBody();
		xmdStr = xmdStr.replace('&quot;&quot;','\\"\\"');
		retVal.xmdStr = xmdStr;
		retVal.sortColumn=SORT_COLUMN;
		retVal.recordsPerTempFile=RECORDS_PER_FILE;
		retVal.bytesPerFile=BYTES_PER_FILE;
		retVal.maxColumns=MAX_COLUMNS;
		retVal.leadingZeroColumns=LEADING_0_COLUMNS;
		return retVal;
	}

	@RemoteAction
	global static Object getRowCount(Export2ExcelParams params){
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
	    con.continuationMethod = 'rowCountCallback';        
	    return con;
	}

	public static Export2ExcelParams rowCountCallback(Object state){
		String orderField = SORT_COLUMN;
	    Export2ExcelParams params = (Export2ExcelParams)state;
	    Long startTime = params.requestStartTime;

	    HttpResponse res = Continuation.getResponse(params.apiRequestId);

	    JsonParser theParser = Json.createParser(res.getBody());
		theParser.nextToken();
		Boolean countObj = false;
		Integer recCnt=0;
		while(theParser.hasCurrentToken()){
		    System.debug('Type='+theParser.getCurrentToken() + ',value=' +theParser.getText());
		    if('count'.equalsIgnoreCase(theParser.getText()) && theParser.getCurrentToken() == JsonToken.FIELD_NAME){
		        countObj=true;
		    }
		    if(countObj && theParser.getCurrentToken() == JsonToken.VALUE_NUMBER_INT){
		        recCnt = theParser.getIntegerValue();
		        break;
		    }

		    theParser.nextToken();
		}
		System.debug('>>>>>>>>'+recCnt);
		params.recordCount=recCnt;
		params.maxRecords = MAX_RECORDS;
		params.addProcessMetric(new ProcessMetric('cpuTime',(Long)System.Limits.getCpuTime(),(Long)System.Limits.getLimitCpuTime()),false);
		params.addProcessMetric(new ProcessMetric('heapSize',(Long)System.Limits.getHeapSize(),(Long)System.Limits.getLimitHeapSize()),false);
	    Long endTime = System.now().getTime();
	    params.addProcessMetric(new ProcessMetric('end-to-end',(endTime-startTime),null),true);
	    return params;		
	}
	@RemoteAction
	global static Export2ExcelParams exportToCSV(Export2ExcelParams params){
		System.debug(params);
	    Long startTime = System.now().getTime();
		Integer chunkSize = params.recordsPerTempFile;
		Integer offset;
		System.debug('>>>>[start] Heap Size:'+ System.Limits.getHeapSize()+' of '+ System.Limits.getLimitHeapSize());

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

		saqlWithNewLimit +='r = order q by \''+orderField+'\' asc;';
		saqlWithNewLimit +='s = offset r '+offset+';';
		saqlWithNewLimit +='t = limit s '+chunkSize+';';

		params.lastSaqlExecuted = saqlWithNewLimit;
		String saqlQueryEsc = saqlWithNewLimit.replace('"', '\\"');
		System.debug('>>>>> Escaped SAQL Query:'+saqlQueryEsc);
	    HttpRequest req = new HttpRequest();
	    req.setEndpoint(WAVE_API_BASE+'/services/data/v36.0/wave/query');
	    req.setMethod('POST');
	    req.setHeader('Authorization','OAuth '+UserInfo.getSessionId());
	    req.setHeader('Content-Type','application/json');
	    req.setBody('{"query":"'+saqlQueryEsc+'"}');
	    //Set a request timeout of 1 min
	    req.setTimeout(60000);
		//System.debug('>>>>> Request:'+req);



	    // Send the request, and return a response
	    HttpResponse res = h.send(req);
		System.debug('>>>>[after callout] response.status='+res.getStatusCode()+',body.length='+res.getHeader('Content-Length'));
		System.debug('>>>>[after callout] Heap Size:'+ System.Limits.getHeapSize()+' of '+ System.Limits.getLimitHeapSize());
	    String resBody = res.getBody();

	    JsonParser theParser = Json.createParser(resBody);
		System.debug('>>>>[after parse] Heap Size:'+ System.Limits.getHeapSize()+' of '+ System.Limits.getLimitHeapSize());
		theParser.nextToken();
		Integer tokenIdx=1,depth=0,recordCnt=0;
		Map<String,String> record = new Map<String,String>();
		Boolean objStarted=false,recordsNode=false;
		String finalCSV='';

		while(theParser.hasCurrentToken()){
		    //System.debug('Token#'+(tokenIdx++)+',Type='+theParser.getCurrentToken()+',text:'+theParser.getText());
		    if(theParser.getCurrentToken() == JsonToken.FIELD_NAME && 'records'.equalsIgnoreCase(theParser.getText())){
		        recordsNode=true;
		    }
		    
		    if(recordsNode && theParser.getCurrentToken() == JsonToken.START_OBJECT){
		        objStarted=true;
		        recordCnt++;
		    }
		    
		    if(recordsNode && theParser.getCurrentToken() == JsonToken.END_OBJECT){
		        objStarted=false;
		        //System.debug('>>>>>>>>Rec#'+recordCnt+',values='+values);
	        	finalCSV = writeRecordToCSV(recordCnt,params.columns,params.leadingZeroColumns,record,finalCSV);
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
		
		System.debug('>>>>[before create file] Heap Size:'+ System.Limits.getHeapSize()+' of '+ System.Limits.getLimitHeapSize());

		String fileName = '_tmp_'+params.lensName + ' Part '+(params.currentChunk);
		String fileId = createOrUpdateFile(fileName,params,true,finalCSV);
		params.addFileToList(fileId);
		params.currRecordCount += recordCnt;

		params.addProcessMetric(new ProcessMetric('cpuTime',(Long)System.Limits.getCpuTime(),(Long)System.Limits.getLimitCpuTime()),false);
		params.addProcessMetric(new ProcessMetric('heapSize',(Long)System.Limits.getHeapSize(),(Long)System.Limits.getLimitHeapSize()),false);
	    Long endTime = System.now().getTime();
	    params.addProcessMetric(new ProcessMetric('end-to-end',(endTime-startTime),null),true);
	    return params;
	    
	}

	@RemoteAction
	global static Export2ExcelParams consolidateFiles(Export2ExcelParams params){
		List<String> newFileIdList = new List<String>();
		Integer ALLOWED_MAX_SIZE = params.bytesPerFile;
		List<String> filesIn1File =new List<String>();
		Integer contentSize=0,bigFileIndex=1,currIndex=0;
		if(params.currentChunk == null){
			params.currentChunk=1;
		}else{
			params.currentChunk++;			
		}
		//Start with the header of column names
		System.debug('>>>>>>> fileIdList.size = '+params.fileIdList.size());
		System.debug('>>>>>>> fileIdList = '+params.fileIdList);
		for(ContentVersion doc: [select Id,Title,ContentDocumentId,ContentSize 
								 from ContentVersion 
								 where IsLatest=true 
								 and Id in :params.fileIdList 
								 order by createddate]){
			System.debug('>>>>>>> file name:'+doc.Title);
			System.debug('>>>>>>> Content Size:'+contentSize+',currFileContentSize='+doc.ContentSize+',currIndex='+currIndex+',newFileIdList.size='+newFileIdList.size());
			if(contentSize > ALLOWED_MAX_SIZE){
				params.addProcessMetric(new ProcessMetric('content_size',contentSize,null),false);
				params.addProcessMetric(new ProcessMetric('tempFileCount',filesIn1File.size(),null),false);
				//Copy the remaining file ids into a new list
				for(Integer i=currIndex;i<params.fileIdList.size();i++){
					newFileIdList.add(params.fileIdList.get(i));
				}
				String fileName = params.lensName + ' Part '+params.currentChunk;
				String docId = combineFiles(filesIn1File,fileName,params);
				params.addFinalFileToList(new FileInfo(fileName,docId));
				break;	
			}else{
				filesIn1File.add(doc.Id);
				//fileCSVData+=doc.VersionData.toString()+'\n';
			}
			contentSize +=doc.ContentSize;
			currIndex++;
		}

		if(newFileIdList.isEmpty()){
			params.addProcessMetric(new ProcessMetric('content_size',contentSize,null),false);
			params.addProcessMetric(new ProcessMetric('tempFileCount',filesIn1File.size(),null),false);
			String fileName = params.lensName + ' Part '+params.currentChunk;
			String docId = combineFiles(filesIn1File,fileName,params);
			params.addFinalFileToList(new FileInfo(fileName,docId));
		}

		params.addProcessMetric(new ProcessMetric('heapSize',(Long)System.Limits.getHeapSize(),(Long)System.Limits.getLimitHeapSize()),false);
		params.fileIdList=newFileIdList;
		return params;

	}

	@RemoteAction
	global static Export2ExcelParams cleanup(Export2ExcelParams params){
		List<Id> docIds = new List<Id>();
		for(ContentVersion ver : [select Id,ContentDocumentId from ContentVersion where Id in :params.tempFileIdList]){
			docIds.add(ver.ContentDocumentId);
		}
		List<ContentDocument> toDel = [select Id from ContentDocument where Id in :docIds];
		
		delete toDel;
		params.tempFileIdList=null;
		return params;
	}
	private static String generateFileHeader(List<String> colNames){
		String finalCSV='';
		for(String colName: colNames){
			finalCSV+='"'+colName+'",';
		}
		finalCSV = finalCSV.substring(0,finalCSV.length()-1)+'\n';
		return finalCSV;
	}

	private static String writeRecordToCSV(Integer recNbr,List<String> colNames,String leadingZeroColumns,Map<String,String> record,String finalCSV){
		if(!record.isEmpty()){
			try{
				String recStr = '',fldVal;
				Integer colIndex = 0;
				for(String colName: colNames){

					fldVal = record.get(colName);
					if(fldVal!=null){
						fldVal = fldVal.replace('"','""');
					}
					if(leadingZeroColumns!=null && leadingZeroColumns.contains(colName)){
						//Add a leading single quote so that Excel doesn't trim the leading 0s
						recStr+='"\''+(fldVal==null?'':fldVal)+'",';
					}else{
						recStr+='"'+(fldVal==null?'':fldVal)+'",';
					}					
					colIndex++;
				}
				recStr = recStr.substring(0,recStr.length()-1);
				if(recNbr>1){
					finalCSV+='\n'+recStr;
				}else{
					finalCSV+=recStr;
				}
				return finalCSV;
			}catch(Exception ex){
				System.debug('Exception with record#'+recNbr+',record:'+record);
				throw ex;
			}
		}else{
			return finalCSV;
		}
	}

	public static String combineFiles(List<String> versionIds,String fileName, Export2ExcelParams params) {
		String fileCSVData=generateFileHeader(params.columnLabels);
		for(ContentVersion doc: [select Id,Title,ContentDocumentId,ContentSize,VersionData 
								 from ContentVersion 
								 where IsLatest=true 
								 and Id in :versionIds 
								 order by createddate]){
			fileCSVData +=doc.VersionData.toString()+'\n';
		}
		return createOrUpdateFile(fileName,params,true,fileCSVData);
	}

	public static String createOrUpdateFile(String fileName, Export2ExcelParams params, Boolean doInsert,String fileContent) {
		System.debug('>>>>>>>> fileContent.length:'+fileContent.length());
	    String currFileData;
	    transient ContentVersion cont = new ContentVersion();
	    cont.Title = fileName;
	    cont.PathOnClient = 'file_' + Datetime.now().getTime() + '.csv';
    	//Create a new file with the data 
		cont.VersionData = Blob.valueOf(fileContent);
	    cont.Origin = 'H';

        insert cont;
		cont  = [select Id,ContentDocumentId,ContentSize from ContentVersion where Id=:cont.Id];
	    return cont.Id;
	}
}