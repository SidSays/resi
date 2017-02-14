/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal, Accenture
 * Date       : 30-May-2013
 * Description: This is Test class for "ExcludedAddressesController" class.
 * History
     Version             : 1.0
     Author Last Updated : Gaurav Aggarwal, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class ExcludedAddressesControllerTest {
    private static testMethod void testExcludedAddressesController() { 
        SetupTestData.createCustomSettingRecords();
        SetupTestData.createUsers();
        
        Exclusion__c excl = SetupTestData.createExclusionRecord();
        Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
        Test.StartTest();
        System.runAs(SetupTestData.supervisorUser){
            // Create Plan
            Plan__c pln = new Plan__c();
            pln.Name = 'TestPlan';
            pln.Plan_Level__c = 'Turf';   
            pln.Expiration_Date__c = system.Today() + 30;
            ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
            extnObj1.quickSave();
            
            // Create Addresses & Attach them to the plan
            Customer_Address__c addr = new Customer_Address__c();
            addr.Address__c = 'Test Address';
            addr.State__c = 'Test State';
            addr.City__c = 'Test City';
            addr.Country__c = 'Test Country';
            addr.PostalCode__c = '12345';
            addr.Node__c = '12345';
            addr.Corp__c = '111111';
            addr.Route_Code__c = '1111111111';
            addr.Division = freedomRegion.Id;
            insert addr;
            addr.Plan__c = pln.Id;
            update addr;
            Customer_Address__c addr1 = new Customer_Address__c();
            addr1.Address__c = 'Test Address1';
            addr1.State__c = 'Test State';
            addr1.City__c = 'Test City';
            addr1.Country__c = 'Test Country';
            addr1.PostalCode__c = '12345';
            addr1.Node__c = '1111';
            addr1.Corp__c = '111111';
            addr1.Route_Code__c = '1111111111';
            addr1.Division = freedomRegion.Id;
            insert addr1;
            addr1.Plan__c = pln.Id;
            update addr1;
            // Assign Plan & Apply Exclusion
            pln.User__c = SetupTestData.supervisorUser.Id;
            pln.Exclusion__c = excl.Id;
            extnObj1.Save();
            
            Plan__c p = [Select Id, Name, True_count_of_Addresses__c from Plan__c where Id=:pln.Id] ;
            System.AssertEquals(p.True_count_of_Addresses__c > 0, true);
            
            // Check out the page
            PageReference pageRef = Page.ViewExcludedAddresses;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',pln.Id);
            ExcludedAddressesController ExcludedController= new ExcludedAddressesController(controller1);
            
        }
        Test.StopTest();
    }
}