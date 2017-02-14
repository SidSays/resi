/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal, Accenture
 * Date       : 30-May-2013
 * Description: This is Test class for "ViewAddressunitsController" class.
 * History
     Version             : 1.0
     Author Last Updated : Gaurav Aggarwal, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class ViewAddressunitsControllerTest {
    private static testMethod void testViewAddressunitsController() {
        SetupTestData.createCustomSettingRecords();
        
        Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
        // Create Compex Office Address
        Customer_Address__c addr = new Customer_Address__c();
        addr.Address__c = 'Test Address';
        addr.State__c = 'Test State';
        addr.City__c = 'Test City';
        addr.Country__c = 'Test Country';
        addr.PostalCode__c = '12345';
        addr.Node__c = '12345';
        addr.Division = freedomRegion.Id;
        addr.Complex_Office__c = true;
        insert addr;
        
        // Create Customer Addresses
        List<Customer_Address__c> addrList = new List<Customer_Address__c>();
        Customer_Address__c addr1;
        for(integer i=0; i<10; i++){
            addr1 = new Customer_Address__c();
            addr1.Address__c = 'Test Address' +i;
            addr1.State__c = 'Test State' +i;
            addr1.City__c = 'Test City' +i;
            addr1.Country__c = 'Test Country'+i;
            addr1.PostalCode__c = '12345';
            addr1.Node__c = '1111';
            addr1.Corp__c = '11111111';
            addr1.Route_Code__c = '1111111111';
            addr1.Division = freedomRegion.Id;
            addr1.Parent_Address__c = addr.Id;
            addrList.add(addr1);
        }
        insert addrList;
        
        PageReference pageRef = Page.ViewAddressUnits;
        Test.setCurrentPage(pageRef);   
        ApexPages.StandardController controller1 = new ApexPages.StandardController(addr);
        ViewAddressunitsController AddressController= new ViewAddressunitsController(controller1);
        List<Customer_Address__c> custList = AddressController.getUnits();
        system.AssertEquals(custList.size()>0,true);
        
        // Cover Pagination methods
        AddressController.first();
        AddressController.last();
        AddressController.previous();
        AddressController.next();
        AddressController.cancel();
    }
}