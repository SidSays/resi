/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ImageServicesRESTTest {
	
	
private static testMethod void testAttachImage()
{
	SetupTestData.createCustomSettingRecords();

	Test.startTest();
	Account acc = new Account();
    acc.Name = 'TestAccount';
    acc.AccountNumber='123456789';
    acc.Customer_Status__c = 'Active';
    acc.Installation_Status__c = 'Active';
    acc.Region__c = null;
    insert acc;
	Restrequest req = new Restrequest();
    req.requestURI = '/services/apexrest/ImageServicesREST/attachImage'; 
	req.httpMethod = 'POST';
	req.addHeader('recordId', String.valueOf(acc.Id));
	req.addHeader('imgName','testImage');
	req.requestBody = Blob.valueof('ksdflskdjflsdf');
	RestContext.request = req;
	ImageServicesREST.returnValues ret = ImageServicesREST.attachImage();
	String attId = ret.attachmentId;
	System.assert(true,attId != Null);
	Test.stopTest();
	
}

private static testMethod void testGetImageData()
{
	SetupTestData.createCustomSettingRecords();

	Test.startTest();
	Account acc = new Account();
    acc.Name = 'TestAccount';
    acc.AccountNumber='123456789';
    acc.Customer_Status__c = 'Active';
    acc.Installation_Status__c = 'Active';
    acc.Region__c = null;
    insert acc;
    Attachment att = new Attachment();
    att.ParentId = acc.Id;
    att.Name = 'Test Attachment';
    att.Body = Blob.valueof('ksdflskdjflsdf');
    insert att;
	Restrequest req = new Restrequest();
	req.requestURI = '/services/apexrest/ImageServicesREST/getImageData';
	req.httpMethod = 'GET';
	req.addParameter('recordId', String.valueOf(acc.Id));
	RestContext.request = req;
	List<Attachment> attachmentList = ImageServicesREST.getImageData();
	System.assert(attachmentList != null, 'aList was null.');
	Test.stopTest();
}
}