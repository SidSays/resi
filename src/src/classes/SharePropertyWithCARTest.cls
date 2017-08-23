/**************************************************************
@Author: Shalaka
@Date: 14-July-2017
@Description: To increase code coverage for SharePropertyWithCAR apex class
***************************************************************/
@isTest
private class SharePropertyWithCARTest{

	private static testMethod void sharePropertyWithCAR() {
		//Creating custom settings/trigger settings data
		SetupTestData.createCustomSettingRecords();
		TriggerSettings__c propertyTrigger = new TriggerSettings__c();
		propertyTrigger.Name = 'PropertyInsertUpdateTrigger';
		propertyTrigger.isActive__c = True;
		insert propertyTrigger;
		//other variables
		List<MDU_Property__c> propList = new List<MDU_Property__c>();
		List<MDU_Property__c> propList1 = new List<MDU_Property__c>();
		List<user> userList = new List<user>();
		//Get car and car manager profile ids
		Profile car = TestDataUtility.getXfinityCARProfile();
		Profile carManager = TestDataUtility.getXfinityCARManagerProfile();
		//create 2 car user and 1 car manager. 2 car user in order to reassign property
		String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
		User xfinityCARManagerUser = new User(Alias = 'MDU_' + randomstr.substring(0,4),
									Email = randomstr + 'userTest1@SampleTest.com',
									LastName='Testing1',
									EmailEncodingKey='UTF-8', 
									LanguageLocaleKey='en_US', 
									LocaleSidKey='en_US', 
									TimeZoneSidKey='America/Los_Angeles',
									ProfileId = carManager.Id,
									Username = 'userTest1' + randomstr + '@SampleTest.com',
									Region__c = 'Freedom Market',
									FederationIdentifier = 'FedId1'+randomstr,
									EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
		insert xfinityCARManagerUser;

		String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
		User xfinityCARUser = new User(Alias = 'MDU_' + randomstr1.substring(0,4),
									Email = randomstr1 + 'userTest1@SampleTest.com',
									LastName='Testing1',
									EmailEncodingKey='UTF-8', 
									LanguageLocaleKey='en_US', 
									LocaleSidKey='en_US', 
									TimeZoneSidKey='America/Los_Angeles',
									ProfileId = car.Id,
									Username = 'userTest1' + randomstr1 + '@SampleTest.com',
									Region__c = 'Freedom Market',
									FederationIdentifier = 'FedId1'+randomstr1,
									ManagerId = XfinityCARManagerUser.id,
									EmployeeNumber = 'Emp1' + randomstr1.substring(0,4));
		userList.add(xfinityCARUser);

		String randomstr2 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
		User xfinityCARUser1 = new User(Alias = 'MDU_' + randomstr2.substring(0,4),
									Email = randomstr2 + 'userTest11@SampleTest.com',
									LastName='Testing11',
									EmailEncodingKey='UTF-8', 
									LanguageLocaleKey='en_US', 
									LocaleSidKey='en_US', 
									TimeZoneSidKey='America/Los_Angeles',
									ProfileId = car.Id,
									Username = 'userTest11' + randomstr2 + '@SampleTest.com',
									Region__c = 'Freedom Market',
									FederationIdentifier = 'FedId1'+randomstr2,
									ManagerId = XfinityCARManagerUser.id,
									EmployeeNumber = 'Emp1' + randomstr2.substring(0,4));
									userList.add(xfinityCARUser1);
		insert userList;
		//create property by assigning it to first car
		MDU_Property__c prop = new MDU_Property__c();
			prop = TestDataUtility.createProperty();            
			prop.Assigned_CAR__c = XfinityCARUser.Id;
			prop.ownerId = XfinityCARUser.Id;
			propList.add(prop);
		insert propList;
		//reassigning property to another car
		prop.Assigned_CAR__c = XfinityCARUser1.Id;
		propList1.add(prop);
		update propList1;
		
		SharePropertyWithCAR.removeSharing();
	}
}