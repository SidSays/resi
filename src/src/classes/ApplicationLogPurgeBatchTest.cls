/*************************************************************************************
    Name             : ApplicationLogPurgeBatchTest.cls
    Description      : Test Class for Batch Class ApplicationLogPurgeBatch
    Created By       : Accenture
    Created Date     : 06/25/2017
    User Story		 : US1026408: Create a trigger exception logging framework
 
************************************************************************************/
@isTest (seealldata =false)
private class ApplicationLogPurgeBatchTest{
	
	
	static void setup(){
		
		VariableSettingTestUtility.variableSettingsData();
		system.debug('ConstantHandler.APPLOGNONINTEGRATION-->'+ConstantHandler.APPLOGNONINTEGRATION);
		Id nonintegrationRTypeId = Schema.SObjectType.Application_Log__c.getRecordTypeInfosByName().get(ConstantHandler.APPLOGNONINTEGRATION).getRecordTypeId();
		List<Application_Log__c> lstlog = new List<Application_Log__c>();
		for(integer i =0;i<150;i++){
			Application_Log__c objapplicationlog = new Application_Log__c();
			       objapplicationlog.Log_Message__c = 'testing'+i;
					objapplicationlog.Object_Name__c = 'objec';
					objapplicationlog.Snippet_Name__c = 'test class';
					objapplicationlog.RecordTypeId = nonintegrationRTypeId;
					objapplicationlog.Send_Email__c = false;
					lstlog.add(objapplicationlog);
		}
		
		Database.insert(lstlog,false);
	}
	
	static testMethod void testapplicationlogPurgeBatch(){
		
		setup();
		Test.startTest();
		ApplicationLogPurgeBatch lpb = new ApplicationLogPurgeBatch(ConstantHandler.APPLOGDELETEBATCHQUERY);
		Database.executeBatch(lpb);
		Test.stopTest();
	}
	
}