@isTest

public class displayAccountHistoryTest
{
 static testMethod void createDataForCSG()
  {
  
  TriggerSettings__c addressTrigger = new TriggerSettings__c();
            addressTrigger.Name = 'AddressTrigger';
            addressTrigger.isActive__c = True;
            insert addressTrigger;
            
            AccountManagementServiceCS__c  setting = new AccountManagementServiceCS__c();
            setting.Name = 'Endurl';
            setting.Param_Value__c = 'http://xml.comcast.com/accountmanagement/services';
            insert setting;
            
   Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Store').getRecordTypeId();
        acc.Name='Hometown America';
        acc.Zip_Code__c = '12345';
        acc.Description = 'test Desc';
        acc.Billing_Account_Number__c = '1234567890123';
        acc.Is_Parent_Organization__c= true;
        acc.Store_Type__c = 'Target';
        acc.Store_Location__Latitude__s= 11.1111;
        acc.Store_Location__Longitude__s = 22.2222;
        acc.Parent_Account_Dropdown__c = 'LFO_Dealer';
        insert acc;
  
  Customer_Address__c address1 = new Customer_Address__c();
        address1.Address__c = 'Test Address Line1';
        address1.City__c = 'Test city';
        address1.State__c = 'Test State';
        address1.PostalCode__c = '98564';
        address1.Country__c = 'Test Country';
        address1.Corp__c = '111111';
        address1.Route_Code__c = '1111111111';
        address1.Node__c = '1111';
        address1.Assigned_Date__c = Date.today()-10;
        //address1.Plan__c = plan.Id; 
        address1.Latitude__c = 11.1111;
        address1.Longitude__c = 22.2222;
        //address1.Last_Knock_Date__c = System.now();
       // address1.Most_Recent_Disposition__c = 'Contact';
       address1.Billing_House_Key__c ='78945612322111';
       address1.Account__c = acc.id;
        insert address1;
        //displayAccountHistory dispAccObj = new displayAccountHistory();
        //List<ContactWrapp> conWrapList = new List<ContactWrapp>();
        displayAccountHistory.ContactWrapp conWrapObj = new displayAccountHistory.ContactWrapp();
        List<displayAccountHistory.ContactWrapp> conWrapObj1 = new List<displayAccountHistory.ContactWrapp>();
        conWrapObj.Phone = '0123456789';
        conWrapObj.Email = 'abc@xyz.com';
        conWrapObj.FirstName = 'Mike';
        conWrapObj.LastName = 'Ross';
        conWrapObj.areaCode = '1234';
        conWrapObj.extension = '1234567891';
        conWrapObj1.add(conWrapObj);
        
        displayAccountHistory.AccountWrapp accWrapObj = new displayAccountHistory.AccountWrapp();
        accWrapObj.accountName = 'Comcast';
        accWrapObj.AccountNumber = '1234567';
        accWrapObj.CustomerStatus = 'Active';
        accWrapObj.Type = 'Enterprise';
        accWrapObj.LastInstallDate = '01-14-2016';
        accWrapObj.BillingAccountNumber = '01234567890123';
        accWrapObj.AccountSource = 'test';
        accWrapObj.PastDueBalance = '100';
        accWrapObj.InstallationStatus = 'Completed';
        accWrapObj.TotalMonthlyRate = '100';
        accWrapObj.LastDisconnectedDate = '01-16-2016';
        accWrapObj.WriteOffAmount = '80';
        accWrapObj.contactlst = conWrapObj1;
        PageReference myVfPage = Page.AccountHistoryDisplayerPage;
        Test.setCurrentPageReference(myVfPage);
        ApexPages.currentPage().getParameters().put('id',address1.Id);
        String id = ApexPages.currentPage().getParameters().get('id');
      Test.startTest(); 
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorGetBilling(true));
        List<ESPAccountContactHistory> wrapObjTemp = getBillingArrangement.getBillingArrangementRequest(address1.Id);
       Test.stopTest();           
        ApexPages.StandardController sc = new ApexPages.StandardController(address1);
        displayAccountHistory dispAcc = new displayAccountHistory(sc);
         //wrapObjTemp.tempAccountWrapp =  accWrapObj();
          
          
       // List<ESPAccountContactHistory>lstWrap = new list<ESPAccountContactHistory> ();
       
        
      
      
        //dispAcc.queryStringAddressId = address1.id;
        
        
        
        //List<ESPAccountContactHistory> wrapObjTemp = getBillingArrangement.getBillingArrangementRequest(id);
   }
  
   static testMethod void createDataForDDP()
  {
  
  TriggerSettings__c addressTrigger = new TriggerSettings__c();
            addressTrigger.Name = 'AddressTrigger';
            addressTrigger.isActive__c = True;
            insert addressTrigger;
            
            AccountManagementServiceCS__c  setting = new AccountManagementServiceCS__c();
            setting.Name = 'Endurl';
            setting.Param_Value__c = null;
            insert setting;
            
            
   Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Store').getRecordTypeId();
        acc.Name='Hometown America';
        acc.Zip_Code__c = '12345';
        acc.Description = 'test Desc';
        acc.Billing_Account_Number__c = '1234567890123';
        acc.Is_Parent_Organization__c= true;
        acc.Store_Type__c = 'Target';
        acc.Store_Location__Latitude__s= 11.1111;
        acc.Store_Location__Longitude__s = 22.2222;
        acc.Parent_Account_Dropdown__c = 'LFO_Dealer';
        insert acc;
  
  Customer_Address__c address1 = new Customer_Address__c();
        address1.Address__c = 'Test Address Line1';
        address1.City__c = 'Test city';
        address1.State__c = 'Test State';
        address1.PostalCode__c = '98564';
        address1.Country__c = 'Test Country';
        address1.Corp__c = '111111';
        address1.Route_Code__c = '1111111111';
        address1.Node__c = '1111';
        address1.Assigned_Date__c = Date.today()-10;
        //address1.Plan__c = plan.Id; 
        address1.Latitude__c = 11.1111;
        address1.Longitude__c = 22.2222;
        //address1.Last_Knock_Date__c = System.now();
       // address1.Most_Recent_Disposition__c = 'Contact';
       address1.Billing_House_Key__c ='78945612322';
       address1.Account__c = acc.id;
        insert address1;
        //displayAccountHistory dispAccObj = new displayAccountHistory();
        //List<ContactWrapp> conWrapList = new List<ContactWrapp>();
        displayAccountHistory.ContactWrapp conWrapObj = new displayAccountHistory.ContactWrapp();
        List<displayAccountHistory.ContactWrapp> conWrapObj1 = new List<displayAccountHistory.ContactWrapp>();
        conWrapObj.Phone = '0123456789';
        conWrapObj.Email = 'abc@xyz.com';
        conWrapObj.FirstName = 'Mike';
        conWrapObj.LastName = 'Ross';
        conWrapObj.areaCode = '1234';
        conWrapObj.extension = '1234567891';
        conWrapObj1.add(conWrapObj);
        
        displayAccountHistory.AccountWrapp accWrapObj = new displayAccountHistory.AccountWrapp();
        accWrapObj.accountName = 'Comcast';
        accWrapObj.AccountNumber = '1234567';
        accWrapObj.CustomerStatus = 'Active';
        accWrapObj.Type = 'Enterprise';
        accWrapObj.LastInstallDate = '01-14-2016';
        accWrapObj.BillingAccountNumber = '01234567890123';
        accWrapObj.AccountSource = 'test';
        accWrapObj.PastDueBalance = '100';
        accWrapObj.InstallationStatus = 'Completed';
        accWrapObj.TotalMonthlyRate = '100';
        accWrapObj.LastDisconnectedDate = '01-16-2016';
        accWrapObj.WriteOffAmount = '80';
        accWrapObj.contactlst = conWrapObj1;
        PageReference myVfPage = Page.AccountHistoryDisplayerPage;
        Test.setCurrentPageReference(myVfPage);
        ApexPages.currentPage().getParameters().put('id',address1.Id);
        String id = ApexPages.currentPage().getParameters().get('id');      
      Test.startTest();  
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorGetBilling(false));      
        List<ESPAccountContactHistory> wrapObjTemp = getBillingArrangement.getBillingArrangementRequest(address1.Id);
       Test.stopTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(address1);
        displayAccountHistory dispAcc = new displayAccountHistory(sc);         
   }   
   
   static testMethod void createDataForNull()
  {
  
  TriggerSettings__c addressTrigger = new TriggerSettings__c();
            addressTrigger.Name = 'AddressTrigger';
            addressTrigger.isActive__c = True;
            insert addressTrigger;
            
            AccountManagementServiceCS__c  setting = new AccountManagementServiceCS__c();
            setting.Name = 'Endurl';
            setting.Param_Value__c = 'https://eproxy.comcast.com/AccountManagementService/15.04';
            insert setting;
            
   Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Store').getRecordTypeId();
        acc.Name='Hometown America';
        acc.Zip_Code__c = '12345';
        acc.Description = 'test Desc';
        acc.Billing_Account_Number__c = '1234567890123';
        acc.Is_Parent_Organization__c= true;
        acc.Store_Type__c = 'Target';
        acc.Store_Location__Latitude__s= 11.1111;
        acc.Store_Location__Longitude__s = 22.2222;
        acc.Parent_Account_Dropdown__c = 'LFO_Dealer';
        insert acc;
  
  Customer_Address__c address1 = new Customer_Address__c();
        address1.Address__c = 'Test Address Line1';
        address1.City__c = 'Test city';
        address1.State__c = 'Test State';
        address1.PostalCode__c = '98564';
        address1.Country__c = 'Test Country';
        address1.Corp__c = '111111';
        address1.Route_Code__c = '1111111111';
        address1.Node__c = '1111';
        address1.Assigned_Date__c = Date.today()-10;
        //address1.Plan__c = plan.Id; 
        address1.Latitude__c = 11.1111;
        address1.Longitude__c = 22.2222;
        //address1.Last_Knock_Date__c = System.now();
       // address1.Most_Recent_Disposition__c = 'Contact';
       address1.Billing_House_Key__c ='7894561232211';
       address1.Account__c = acc.id;
        insert address1;
        //displayAccountHistory dispAccObj = new displayAccountHistory();
        //List<ContactWrapp> conWrapList = new List<ContactWrapp>();
        displayAccountHistory.ContactWrapp conWrapObj = new displayAccountHistory.ContactWrapp();
        List<displayAccountHistory.ContactWrapp> conWrapObj1 = new List<displayAccountHistory.ContactWrapp>();
        conWrapObj.Phone = '0123456789';
        conWrapObj.Email = 'abc@xyz.com';
        conWrapObj.FirstName = 'Mike';
        conWrapObj.LastName = 'Ross';
        conWrapObj.areaCode = '1234';
        conWrapObj.extension = '1234567891';
        conWrapObj1.add(conWrapObj);
        
        displayAccountHistory.AccountWrapp accWrapObj = new displayAccountHistory.AccountWrapp();
        accWrapObj.accountName = 'Comcast';
        accWrapObj.AccountNumber = '1234567';
        accWrapObj.CustomerStatus = 'Active';
        accWrapObj.Type = 'Enterprise';
        accWrapObj.LastInstallDate = '01-14-2016';
        accWrapObj.BillingAccountNumber = '01234567890123';
        accWrapObj.AccountSource = 'test';
        accWrapObj.PastDueBalance = '100';
        accWrapObj.InstallationStatus = 'Completed';
        accWrapObj.TotalMonthlyRate = '100';
        accWrapObj.LastDisconnectedDate = '01-16-2016';
        accWrapObj.WriteOffAmount = '80';
        accWrapObj.contactlst = conWrapObj1;
        PageReference myVfPage = Page.AccountHistoryDisplayerPage;
        Test.setCurrentPageReference(myVfPage);
        ApexPages.currentPage().getParameters().put('id',address1.Id);
        String id = ApexPages.currentPage().getParameters().get('id');
      String selfDate = '2015-05-15T10:15:18.000Z';
      Test.startTest();  
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorGetBilling(false));
        String wrapObjTemp = getBillingArrangement.getDateFromESP(selfDate);
      Test.stopTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(address1);
        displayAccountHistory dispAcc = new displayAccountHistory(sc);        
   }
  
  

}