@RestResource(urlMapping='/CallCenterExportREST/*')

global with sharing class CallCenterExportREST{

	@HttpGet
	global static String getCallCenterExportREST(){
		PageReference csvPage = Page.CallCenterExportPage;
		Blob csvBlob = csvPage.getContent();
		return csvBlob.toString();
	}
}