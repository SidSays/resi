@isTest
private class CreatePropertyControllerTest {
  
  public static testMethod void  CreatePropertyControllerTest() {
    SetupTestData.createCustomSettingRecords();
    List<Customer_Address__c> addresses=new List<Customer_Address__c>();
    List<Customer_Address__c> UpdateAddressList =new List<Customer_Address__c>();
    Customer_Address__c address1 = new Customer_Address__c();
      address1.Address__c = 'Test Address Line1';
      address1.City__c = 'Test city';
      address1.State__c = 'Test State';
      address1.PostalCode__c = '98564';
      address1.Country__c = 'Test Country';
      //address1.Is_New__c = true;
      address1.Property_Code__c = '111111';
      address1.Census_Block__c = '12345678945612';
      address1.Complex_Office__c=true;
      address1.parent_address__c = null;
      addresses.add(address1);

      Customer_Address__c address2 = new Customer_Address__c();
      address2.Address__c = 'Test Address Line1';
      address2.City__c = 'Test city';
      address2.State__c = 'Test State';
      address2.PostalCode__c = '98564';
      address2.Census_Block__c = '12345678945612';
      address2.Property_Code__c = '111111';
      address2.parent_address__c = address1.id;
      addresses.add(address2);

      Customer_Address__c address3 = new Customer_Address__c();
      address3.Address__c = 'Test Address Line1';
      address3.City__c = 'Test city';
      address3.State__c = 'Test State';
      address3.PostalCode__c = '98564';
      address3.Census_Block__c = '12345678945612';
      address3.Property_Code__c = '111111';
      address3.parent_address__c = address1.id;
      addresses.add(address3);

      Customer_Address__c address4 = new Customer_Address__c();
      address4.Address__c = 'Test Address Line1';
      address4.City__c = 'Test city';
      address4.State__c = 'Test State';
      address4.PostalCode__c = '98564';
      address4.Census_Block__c = '12345678945612';
      address4.Property_Code__c = '111111';
      address4.parent_address__c = address1.id;
      addresses.add(address4);

      Customer_Address__c address5 = new Customer_Address__c();
      address5.Address__c = 'Test Address Line1';
      address5.City__c = 'Test city';
      address5.State__c = 'Test State';
      address5.PostalCode__c = '98564';
      address5.Census_Block__c = '12345678945612';
      address5.Property_Code__c = '111111';
      address5.parent_address__c = address1.id;
      address5.Is_New__c = false;
      addresses.add(address5);
         
          
      Customer_Address__c address6 = new Customer_Address__c();
      address6.Address__c = 'Test Address Line1';
      address6.City__c = 'Test city';
      address6.State__c = 'Test State';
      address6.PostalCode__c = '98564';
      address6.Census_Block__c = '12345678945612';
      address6.Property_Code__c = '111111';
      address6.Is_New__c = true;
      address6.parent_address__c = null;
      addresses.add(address6);  

      Customer_Address__c address7 = new Customer_Address__c();
      address7.Address__c = 'Test Address Line1';
      address7.City__c = 'Test city';
      address7.State__c = 'Test State';
      address7.PostalCode__c = '98564';
      address7.Census_Block__c = '12345678945612';
      address7.Property_Code__c = '111111';
      address7.Is_New__c = true;
      address7.parent_address__c = address6.id;
      addresses.add(address7);
          
      Database.insert(addresses,false);

        PageReference pageRef = Page.CreateProperty;
        Test.setCurrentPage(pageRef);

        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', addresses.get(0).Id);
        ApexPages.currentPage().getParameters().put('ComplexOffice', '0');
        ApexPages.currentPage().getParameters().put('PropertyCode', '');
        CreatePropertyController cpc= new CreatePropertyController();

        ApexPages.currentPage().getParameters().put('PropertyCode', addresses.get(0).Property_Code__c);
        
        // Instantiate a new controller with all parameters in the page
        cpc= new CreatePropertyController();
        ApexPages.currentPage().getParameters().put('ComplexOffice', String.valueOf(addresses.get(0).Complex_Office__c));
        cpc.createProperty();
        System.assert(ApexPages.hasMessages());
        cpc.propertyCodes=addresses.get(0).Property_Code__c;
        cpc.createProperty();
        System.assert(ApexPages.hasMessages());
        cpc= new CreatePropertyController();
        cpc.propertyCodes=addresses.get(0).Property_Code__c+','+addresses.get(4).Property_Code__c;
        cpc.createProperty();
        System.assert(ApexPages.hasMessages());
        cpc.propertyCodes='3333333';
        cpc.createProperty();
        System.assert(ApexPages.hasMessages());
        cpc.propertyCodes='';
        cpc.createProperty();
        System.assert(ApexPages.hasMessages());
    }
}