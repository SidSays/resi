@isTest(SeeAllData=false)
public with sharing class TerritoryValidationControllerTest {

	@isTest static void testGetRegions() {
	  	Schema.DescribeFieldResult dfr = Territory__c.Region__c.getDescribe();
	  	List<Schema.PicklistEntry> entries = dfr.getPickListValues();
	  	Test.startTest();
	  	List<String> regionList = TerritoryValidationController.getRegions();
	  	Test.stopTest();
	  	//Check the number of regions returned. Global should be skipped.
	  	System.assert(regionList.size() == entries.size()-1);
		
	}

	@isTest static void testFolderIdForRegion() {
		setupMocks();
	  	Test.startTest();
	  	Id folderID = TerritoryValidationController.getFolderIdForRegion('Keystone Market');
	  	System.debug('>>>>>>>> FolderId :'+folderID);
	  	Test.stopTest();
	  	System.assert('00lP0000000rbbzIAA'.equalsIgnoreCase(folderID));
		
	}
	

	@isTest static void testFolderIdForInvalidRegion() {
		setupMocks();
	  	Test.startTest();
	  	Id folderID = TerritoryValidationController.getFolderIdForRegion('KeyMarket');
	  	System.debug('>>>>>>>> FolderId :'+folderID);
	  	Test.stopTest();
	  	System.assert(folderID ==null);
		
	}
	@isTest static void testGetLensForRegion() {
		setupMocks();
	  	Test.startTest();
	  	Id folderID = TerritoryValidationController.getFolderIdForRegion('Keystone Market');
	  	List<String> lensList = TerritoryValidationController.getAvailableLenses(folderID);
	  	Test.stopTest();
	  	System.assert(lensList.size()==2);
		
	}

	@isTest static void testGetLensData(){
		setupMocks();
	  	Test.startTest();
	  	Id folderID = TerritoryValidationController.getFolderIdForRegion('Keystone Market');
	  	List<String> lensList = TerritoryValidationController.getAvailableLenses(folderID);
	  	TerritoryValidationController.ProcessParams params = new TerritoryValidationController.ProcessParams();
	  	List<String> lensIdList = new List<String>();
	  	lensIdList.add('0FKP00000004CdhOAE');
	  	params.lensIdList=lensIdList;
	  	params.currentRecordCount=0;

	  	params.currentLensId=lensIdList[0];
	  	params.censusTracts=new Map<String,List<String>>();
	  	params.recordCount=1;
	  	params.processName='Thread-001';

		params = TerritoryValidationController.getLensData(params);
	  	Test.stopTest();
	  	System.assert(params.lensData !=null);
	  	System.assert('TER001'.equalsIgnoreCase(params.lensData.label));

	}

	// setupMocks: Sets the HttpCalloutMock class
	static void setupMocks() {
	    Test.setMock(HttpCalloutMock.class, new TerritoryValidationHTTPMockImpl());
	}
}