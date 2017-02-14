@isTest
private class AddressDetailControllerTest {
	
	@isTest static void AddressDetailControllerTest() {
                    List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();


            TriggerSettings__c addressTrigger = new TriggerSettings__c();
            addressTrigger.Name = 'AddressTrigger';
            addressTrigger.isActive__c = True;
            triggerSettingsList.add(addressTrigger);
        insert triggerSettingslist;
		 List<Super_API_Parameters__c> apiParametersObjList = new List<Super_API_Parameters__c>();
          Super_API_Parameters__c endPointObj = new Super_API_Parameters__c();
            endPointObj.Name = 'Endpoint';
            endPointObj.Value__c = 'https://integration-soa.comcast.com/AccountManagementControllerService/1.35?wsdl';
            apiParametersObjList.add(endPointObj);
            
            Super_API_Parameters__c passWordObj = new Super_API_Parameters__c();
            passWordObj.Name = 'Password';
            passWordObj.Value__c = '8Pa9huku';
            apiParametersObjList.add(passWordObj);
            
            Super_API_Parameters__c userNameObj = new Super_API_Parameters__c();
            userNameObj.Name = 'Username';
            userNameObj.Value__c = 'sftmUser';
            apiParametersObjList.add(userNameObj);
            
            Super_API_Parameters__c ssUsernameObj = new Super_API_Parameters__c();
            ssUsernameObj.Name = 'sourceSystemUserId';
            ssUsernameObj.Value__c = 'sftmUser';
            apiParametersObjList.add(ssUsernameObj);
            
            Super_API_Parameters__c ssIdObj = new Super_API_Parameters__c();
            ssIdObj.Name = 'sourceSystemId';
            ssIdObj.Value__c = 'SF-SSID';
            apiParametersObjList.add(ssIdObj);
            
            Super_API_Parameters__c sServerIdObj = new Super_API_Parameters__c();
            sServerIdObj.Name = 'sourceServerId';
            sServerIdObj.Value__c = '84jfsduifsj8ej';
            apiParametersObjList.add(sServerIdObj);
            
            insert apiParametersObjList;
        List<Customer_Address__c> addresses=new List<Customer_Address__c>();
		Customer_Address__c address1 = new Customer_Address__c();
		address1.Address__c = 'Test Address Line1';
    	address1.City__c = 'Test city';
    	address1.State__c = 'Test State';
    	address1.PostalCode__c = '98564';
    	address1.Country__c = 'Test Country';
    	address1.Property_Code__c = '111111';
    	address1.Complex_Office__c=true;
    	addresses.add(address1);
    	
    	insert addresses;

		PageReference pageRef = Page.AddressDetailPage;
        Test.setCurrentPage(pageRef);

        // Add parameters to page URL
        ApexPages.StandardController stdController = new ApexPages.StandardController(addresses.get(0));
		AddressDetailController adc=new AddressDetailController(stdController);
		ApexPages.currentPage().getParameters().put('Id', addresses.get(0).Id);
		adc.updateAddressFromBiller();
	}
	
}