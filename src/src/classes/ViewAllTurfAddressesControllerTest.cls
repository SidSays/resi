/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal, Accenture
 * Date       : 30-May-2013
 * Description: This is Test class for "ViewAllTurfAddressesController" class.
 * History
     Version             : 1.0
     Author Last Updated : Gaurav Aggarwal, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class ViewAllTurfAddressesControllerTest {
  private static testMethod void testViewAllTurfAddressesController() { 
    SetupTestData.createCustomSettingRecords();
    SetupTestData.createUsers();
    Exclusion__c excl = SetupTestData.createExclusionRecord();
    Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
    System.runAs(SetupTestData.supervisorUser){
      Test.startTest();
    // Create Plan
      Plan__c pln = new Plan__c();
      pln.Name = 'TestPlan';
      pln.Plan_Level__c = 'Turf';   
      pln.Expiration_Date__c = system.Today() + 30;
      ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
      PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
      extnObj1.quickSave();
      
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
            addr1.Plan__c = pln.Id;
            addrList.add(addr1);
        }
        addrList[0].Node__c = '12345';
        addrList[2].node__c = '12345';
        insert addrList;
        
        // Assign Plan
        pln.User__c = SetupTestData.supervisorUser.Id;
        pln.Exclusion__c = excl.Id;
        extnObj1.Save();
        
        PageReference pageRef = Page.ViewExcludedAddresses;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',pln.Id);
        ViewAllTurfAddressesController ViewTurfController= new ViewAllTurfAddressesController(controller1);
        List<Customer_Address__c> custList = ViewTurfController.getAddresses();
        system.AssertEquals(custList.size()>0,true);
        
        // Cover Pagination methods
        ViewTurfController.first();
        ViewTurfController.last();
        ViewTurfController.previous();
        ViewTurfController.next();
        ViewTurfController.cancel();
        Test.stopTest();
    }
  }
}