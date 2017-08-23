/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal, Accenture
 * Date       : 29-May-2013
 * Description: This is Test class for "ApplyExclusionController" class.
 * History
     Version             : 1.0
     Author Last Updated : Gaurav Aggarwal, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class ApplyExclusionControllerTest {
    private static testMethod void testApplyExclusionController() { 
        SetupTestData.createCustomSettingRecords();
        SetupTestData.createUsers();
        Exclusion__c excl = SetupTestData.createExclusionRecord();
        Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
        System.runAs(SetupTestData.supervisorUser){
            Test.startTest();
            // Create Plans
            Plan__c pln = new Plan__c();
            pln.Name = 'TestPlan';
            pln.Plan_Level__c = 'Turf';   
            pln.Expiration_Date__c = system.Today() + 30;
            ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
            extnObj1.quickSave();
            
            // Create an Address and assign them to plan
            Customer_Address__c addr = new Customer_Address__c();
            addr.Address__c = 'Test Address';
            addr.State__c = 'Test State';
            addr.City__c = 'Test City';
            addr.Country__c = 'Test Country';
            addr.PostalCode__c = '12345';
            addr.Node__c = '12345';
            addr.Route_code__c = '1111111111';
            addr.corp__c = '111111';
            addr.Division = freedomRegion.Id;
            insert addr;
            addr.Plan__c = pln.Id;
            update addr;
            
            // Search Exclusions
            PageReference pageRef = Page.ApplyExclusion;
            Test.setCurrentPage(pageRef);
            ApplyExclusionController ExclusionController= new ApplyExclusionController();
            ExclusionController.Search();
            ExclusionController.searchString = 'Test Exclusion';
            ExclusionController.Search();
            //system.AssertEquals(!(ExclusionController.results.IsEmpty()),true);
            
            // Cover JS methods
            ExclusionController.getFormTag();
            ExclusionController.getTextBox();
            ExclusionController.getIsResultEmpty();
            
            // Apply Exclusions
            pln.User__c = SetupTestData.supervisorUser.Id;
            pln.Exclusion__c = excl.Id;
            extnObj1.Save();
            Test.StopTest();
        }
    }
}