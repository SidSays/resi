@isTest
public class CallCenterExportRESTTest
{
static testMethod void testgetCallCenterExportREST()
{
CallCenterExportREST cst=new CallCenterExportREST();
RestRequest req = new RestRequest(); 
RestResponse res = new RestResponse();

req.requestURI = 'https://cs9.salesforce.com/services/apexrest/v.9/CallCenterExportREST/*';  
req.httpMethod = 'GET';
RestContext.request = req;
RestContext.response = res;
String csvBlob= 'StringToBlob';
Blob myBlob = Blob.valueof(csvBlob);
Try{
CallCenterExportREST.getCallCenterExportREST();
}
Catch(Exception ex){}

}
}