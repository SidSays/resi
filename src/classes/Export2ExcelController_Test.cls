@isTest
private class Export2ExcelController_Test {
	
		
	@isTest static void testGetAvailableLenses() {
		// Implement test code
		Test.setMock(HttpCalloutMock.class, new WaveLensMockServiceImpl());
        List<WaveLenses.Lenses> lenses = Export2ExcelController.getAvailableLenses();
        System.assert(lenses.size()==1);
	}
	
	
	
	
 	@isTest static void testGetLensData() {
		// Implement test code
		Test.setMock(HttpCalloutMock.class, new WaveLensMockServiceImpl());
        Export2ExcelController.LensAndXmd lenses = Export2ExcelController.getLensData('LensId');
		System.assert(lenses.xmdStr!=null);
		System.assert(lenses.versionId == '0Fc7A0000000wISSAY');

	}
	
	
	
	
	@isTest static void testRowCount(){
		Export2ExcelController controller = new Export2ExcelController();
		Export2ExcelController.Export2ExcelParams	params = new Export2ExcelController.Export2ExcelParams();
		params.saqlQuery = 'q = load \"0Fb7A0000000SbtSAE/0Fc7A0000000vseSAA\";q = filter q by \'Cntrct_Contract_Status__c\' in [\"Active\", \"Expired\", \"Franchise\"];q = filter q by \'Prop1_Property_Region__c\' == \"Beltway Market\";q = foreach q generate \'Cntrct_Contract_Status__c\' as \'Cntrct_Contract_Status__c\', \'IsExposed\' as \'IsExposed\', \'Oppty_ForecastCategory\' as \'Oppty_ForecastCategory\', \'Oppty_Type\' as \'Oppty_Type\', \'Prop1_Active_Opportunity__c\' as \'Prop1_Active_Opportunity__c\', \'Prop1_County__c\' as \'Prop1_County__c\', \'Prop1_Development__c\' as \'Prop1_Development__c\', \'Prop1_Industry_Type__c\' as \'Prop1_Industry_Type__c\', \'Prop1_Name\' as \'Prop1_Name\', \'Prop1_Number_of_Units__c\' as \'Prop1_Number_of_Units__c\', \'Prop1_Property_Grade__c\' as \'Prop1_Property_Grade__c\', \'Prop1_Property_Rating__c\' as \'Prop1_Property_Rating__c\', \'Prop1_Property_Type__c\' as \'Prop1_Property_Type__c\', \'Prop1_Risk_Status__c\' as \'Prop1_Risk_Status__c\', \'Prop1_Status_SubStatus__c\' as \'Prop1_Status_SubStatus__c\';q = limit q 100;';

        Continuation conti = (Continuation)Export2ExcelController.getRowCount(params);
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
	      '  "query": "q = load \"0Fb7A0000000SbtSAE/0Fc7A0000000vseSAA\";q = filter q by \'Cntrct_Contract_Status__c\' in [\"Active\", \"Expired\", \"Franchise\"];q = filter q by \'Prop1_Property_Region__c\' == \"Beltway Market\";q = group q by all;q = foreach q generate count() as \'count\';",'+
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
        params = Export2ExcelController.rowCountCallback(params);
        // result is the return value of the callback
        System.assert(params.recordCount == 13113);
    }

	@isTest static void testExport2CSV(){
		Test.setMock(HttpCalloutMock.class, new WaveLensMockServiceImpl());
		Export2ExcelController controller = new Export2ExcelController();
		Export2ExcelController.Export2ExcelParams	params = new Export2ExcelController.Export2ExcelParams();
		params.columns = new List<String>{'IsExposed',
'Prop1_Risk_Status__c',
'Prop1_Name',
'Prop1_Number_of_Units__c',
'Prop1_Status_SubStatus__c',
'Prop1_Property_Rating__c',
'Prop1_Active_Opportunity__c',
'Cntrct_Contract_Status__c',
'Oppty_ForecastCategory',
'Oppty_Type',
'Prop1_County__c',
'Prop1_Development__c',
'Prop1_Industry_Type__c',
'Prop1_Property_Grade__c',
'Prop1_Property_Type__c',
'Prop1_Complex_ID__c'};
		params.sortColumn='Prop1_Complex_ID__c';
		params.leadingZeroColumns='';
		params.currentChunk=0;
		params.currRecordCount=0;
		params.saqlQuery = 'q = load \"0Fb7A0000000SbtSAE/0Fc7A0000000vseSAA\";q = filter q by \'Cntrct_Contract_Status__c\' in [\"Active\", \"Expired\", \"Franchise\"];q = filter q by \'Prop1_Property_Region__c\' == \"Beltway Market\";q = foreach q generate \'Cntrct_Contract_Status__c\' as \'Cntrct_Contract_Status__c\', \'IsExposed\' as \'IsExposed\', \'Oppty_ForecastCategory\' as \'Oppty_ForecastCategory\', \'Oppty_Type\' as \'Oppty_Type\', \'Prop1_Active_Opportunity__c\' as \'Prop1_Active_Opportunity__c\', \'Prop1_Complex_ID__c\' as \'Prop1_Complex_ID__c\', \'Prop1_County__c\' as \'Prop1_County__c\', \'Prop1_Development__c\' as \'Prop1_Development__c\', \'Prop1_Industry_Type__c\' as \'Prop1_Industry_Type__c\', \'Prop1_Name\' as \'Prop1_Name\', \'Prop1_Number_of_Units__c\' as \'Prop1_Number_of_Units__c\', \'Prop1_Property_Grade__c\' as \'Prop1_Property_Grade__c\', \'Prop1_Property_Rating__c\' as \'Prop1_Property_Rating__c\', \'Prop1_Property_Type__c\' as \'Prop1_Property_Type__c\', \'Prop1_Risk_Status__c\' as \'Prop1_Risk_Status__c\', \'Prop1_Status_SubStatus__c\' as \'Prop1_Status_SubStatus__c\';q = limit q 100;';
		params.recordsPerTempFile=5;
		params.lensName = 'Apex Unit Test';
		Export2ExcelController.Export2ExcelParams paramsRet = Export2ExcelController.exportToCSV(params);
		System.assert(paramsRet.currRecordCount==1);
		System.assert(paramsRet.fileIdList.size()==1);
    }
	
	@isTest static void testExport2CSVWithLeading0s(){
		Test.setMock(HttpCalloutMock.class, new WaveLensMockServiceImpl());
		Export2ExcelController controller = new Export2ExcelController();
		Export2ExcelController.Export2ExcelParams	params = new Export2ExcelController.Export2ExcelParams();
		params.columns = new List<String>{'IsExposed',
'Prop1_Risk_Status__c',
'Prop1_Name',
'Prop1_Number_of_Units__c',
'Prop1_Status_SubStatus__c',
'Prop1_Property_Rating__c',
'Prop1_Active_Opportunity__c',
'Cntrct_Contract_Status__c',
'Oppty_ForecastCategory',
'Oppty_Type',
'Prop1_County__c',
'Prop1_Development__c',
'Prop1_Industry_Type__c',
'Prop1_Property_Grade__c',
'Prop1_Property_Type__c',
'Prop1_Complex_ID__c'};
		params.sortColumn='Prop1_Complex_ID__c';
		params.leadingZeroColumns='Prop1_Complex_ID__c';
		params.currentChunk=0;
		params.currRecordCount=0;
		params.saqlQuery = 'q = load \"0Fb7A0000000SbtSAE/0Fc7A0000000vseSAA\";q = filter q by \'Cntrct_Contract_Status__c\' in [\"Active\", \"Expired\", \"Franchise\"];q = filter q by \'Prop1_Property_Region__c\' == \"Beltway Market\";q = foreach q generate \'Cntrct_Contract_Status__c\' as \'Cntrct_Contract_Status__c\', \'IsExposed\' as \'IsExposed\', \'Oppty_ForecastCategory\' as \'Oppty_ForecastCategory\', \'Oppty_Type\' as \'Oppty_Type\', \'Prop1_Active_Opportunity__c\' as \'Prop1_Active_Opportunity__c\', \'Prop1_Complex_ID__c\' as \'Prop1_Complex_ID__c\', \'Prop1_County__c\' as \'Prop1_County__c\', \'Prop1_Development__c\' as \'Prop1_Development__c\', \'Prop1_Industry_Type__c\' as \'Prop1_Industry_Type__c\', \'Prop1_Name\' as \'Prop1_Name\', \'Prop1_Number_of_Units__c\' as \'Prop1_Number_of_Units__c\', \'Prop1_Property_Grade__c\' as \'Prop1_Property_Grade__c\', \'Prop1_Property_Rating__c\' as \'Prop1_Property_Rating__c\', \'Prop1_Property_Type__c\' as \'Prop1_Property_Type__c\', \'Prop1_Risk_Status__c\' as \'Prop1_Risk_Status__c\', \'Prop1_Status_SubStatus__c\' as \'Prop1_Status_SubStatus__c\';q = limit q 100;';
		params.recordsPerTempFile=5;
		params.lensName = 'Apex Unit Test';
		Export2ExcelController.Export2ExcelParams paramsRet = Export2ExcelController.exportToCSV(params);
		System.assert(paramsRet.currRecordCount==1);
		System.assert(paramsRet.fileIdList.size()==1);
		String fileId = paramsRet.fileIdList[0];
		ContentVersion ver = [select Id,Title,ContentDocumentId,ContentSize,VersionData 
								 from ContentVersion 
								 where IsLatest=true 
								 and Id =:fileId ];
		String csvData = ver.VersionData.toString();
		System.assert(csvData.endsWith('"\'100596"'));	
    }	
    
	@isTest static void testConsolidateFiles(){
		Export2ExcelController.Export2ExcelParams	params = new Export2ExcelController.Export2ExcelParams();
		String csvData = '"IsExposed","Prop1_Risk_Status__c","Prop1_Name","Prop1_Number_of_Units__c","Prop1_Status_SubStatus__c","Prop1_Property_Rating__c","Prop1_Active_Opportunity__c","Cntrct_Contract_Status__c","Oppty_ForecastCategory","Oppty_Type","Prop1_County__c","Prop1_Development__c","Prop1_Industry_Type__c","Prop1_Property_Grade__c","Prop1_Property_Type__c","Prop1_Complex_ID__c"';
	    List<ContentVersion> toIns = new List<ContentVersion>();
	    Integer nbrOfTempFiles=7;
	    for(Integer i=0;i<nbrOfTempFiles;i++){
			ContentVersion cont = new ContentVersion();
		    cont.Title = 'File-'+i;
		    cont.PathOnClient = i+'file_' + Datetime.now().getTime() + '.csv';
	    	//Create a new file with the data 
			cont.VersionData = Blob.valueOf(csvData);
		    cont.Origin = 'H';
		    toIns.add(cont);
	    }
	    insert toIns;
	    List<String> fileIds = new List<String>();
	    for(ContentVersion ver: toIns){
	    	fileIds.add(ver.Id);
	    }

	    //Fetch the Content size
	    Integer totalFileSize = 0;
	    for(ContentVersion ver: [select Id,ContentSize from ContentVersion where Id in :fileIds]){
	    	totalFileSize+=ver.ContentSize;
	    }    
	    params.bytesPerFile = totalFileSize/2;

		params.columns = new List<String>{  'IsExposed',
											'Prop1_Risk_Status__c',
											'Prop1_Name',
											'Prop1_Number_of_Units__c',
											'Prop1_Status_SubStatus__c',
											'Prop1_Property_Rating__c',
											'Prop1_Active_Opportunity__c',
											'Cntrct_Contract_Status__c',
											'Oppty_ForecastCategory',
											'Oppty_Type',
											'Prop1_County__c',
											'Prop1_Development__c',
											'Prop1_Industry_Type__c',
											'Prop1_Property_Grade__c',
											'Prop1_Property_Type__c',
											'Prop1_Complex_ID__c'};
		params.columnLabels = new List<String>{  'IsExposed',
											'Prop1_Risk_Status__c',
											'Prop1_Name',
											'Prop1_Number_of_Units__c',
											'Prop1_Status_SubStatus__c',
											'Prop1_Property_Rating__c',
											'Prop1_Active_Opportunity__c',
											'Cntrct_Contract_Status__c',
											'Oppty_ForecastCategory',
											'Oppty_Type',
											'Prop1_County__c',
											'Prop1_Development__c',
											'Prop1_Industry_Type__c',
											'Prop1_Property_Grade__c',
											'Prop1_Property_Type__c',
											'Prop1_Complex_ID__c'};										
		params.fileIdList = fileIds;
		params.sortColumn='Prop1_Complex_ID__c';
		params.lensName = 'Apex Unit Test';
		Export2ExcelController.Export2ExcelParams paramsRet = Export2ExcelController.consolidateFiles(params);
		System.debug('>>>>>>'+paramsRet.finalFileIdList);
		paramsRet = Export2ExcelController.consolidateFiles(paramsRet);
		System.debug('>>>>>>'+paramsRet.finalFileIdList);
		System.assert(paramsRet.finalFileIdList.size()==2);

    }
    
    
	@isTest static void testCleanup(){
		Export2ExcelController.Export2ExcelParams	params = new Export2ExcelController.Export2ExcelParams();
		String csvData = '"IsExposed","Prop1_Risk_Status__c","Prop1_Name","Prop1_Number_of_Units__c","Prop1_Status_SubStatus__c","Prop1_Property_Rating__c","Prop1_Active_Opportunity__c","Cntrct_Contract_Status__c","Oppty_ForecastCategory","Oppty_Type","Prop1_County__c","Prop1_Development__c","Prop1_Industry_Type__c","Prop1_Property_Grade__c","Prop1_Property_Type__c","Prop1_Complex_ID__c"';
	    List<ContentVersion> toIns = new List<ContentVersion>();
	    Integer nbrOfTempFiles=6;
	    for(Integer i=0;i<nbrOfTempFiles;i++){
			ContentVersion cont = new ContentVersion();
		    cont.Title = 'File-'+i;
		    cont.PathOnClient = i+'file_' + Datetime.now().getTime() + '.csv';
	    	//Create a new file with the data 
			cont.VersionData = Blob.valueOf(csvData);
		    cont.Origin = 'H';
		    toIns.add(cont);
	    }
	    insert toIns;
	    List<String> fileIds = new List<String>();
	    for(ContentVersion ver: toIns){
	    	fileIds.add(ver.Id);
	    }


		params.columns = new List<String>{  'IsExposed',
											'Prop1_Risk_Status__c',
											'Prop1_Name',
											'Prop1_Number_of_Units__c',
											'Prop1_Status_SubStatus__c',
											'Prop1_Property_Rating__c',
											'Prop1_Active_Opportunity__c',
											'Cntrct_Contract_Status__c',
											'Oppty_ForecastCategory',
											'Oppty_Type',
											'Prop1_County__c',
											'Prop1_Development__c',
											'Prop1_Industry_Type__c',
											'Prop1_Property_Grade__c',
											'Prop1_Property_Type__c',
											'Prop1_Complex_ID__c'};
		params.fileIdList = fileIds;
		params.tempFileIdList = fileIds;
		params.sortColumn='Prop1_Complex_ID__c';
		params.lensName = 'Apex Unit Test';
		Export2ExcelController.Export2ExcelParams paramsRet = Export2ExcelController.cleanup(params);
		
		List<ContentVersion> docs = [select Id from ContentVersion where Id in :fileIds];
		System.assert(docs.isEmpty());
    }
    
    
}