/***************************************************************************************************************************************
 * Author     : Vivek Patel, Accenture
 * Date       : 28-May-2013
 * Description: This is Test class for "PlanningController" class.
 * History
     Version             : 1.0
     Author Last Updated : Vivek Patel, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/

@isTest
public class PlanningControllerTest {
    private static testMethod void testPlanningController() {
        SetupTestData.createCustomSettingRecords();
        List<Address_Statistics__c> addrsStatsList = new List<Address_Statistics__c>();
        User currentUser=[Select Region__c From User Where Id=:UserInfo.getUserId()];
        for(Integer i=0; i<=10; i++) {
            Address_Statistics__c addrsStatsObj = new Address_Statistics__c();
            addrsStatsObj.Name = 'Address Stat '+i;
            addrsStatsObj.Zip_Code__c = '98564'+i;
            addrsStatsObj.Region__c=currentUser.Region__c;
            addrsStatsList.add(addrsStatsObj);          
        }
        for(Integer i=0; i<=10; i++) {
            Address_Statistics__c addrsStatsObj = new Address_Statistics__c();
            addrsStatsObj.Name = 'Address Stat '+i;
            addrsStatsObj.Node__c = '654'+i;
            addrsStatsObj.Region__c=currentUser.Region__c;
            addrsStatsList.add(addrsStatsObj);          
        }
        insert addrsStatsList;
        
        PageReference pageRef = Page.Planning;
        Test.setCurrentPage(pageRef);
        PlanningController planController= new PlanningController();
        planController.searchZipOrNode();
        planController.toPlanPage();
        
        planController.zipString = '985640,985641,985642,985643,985644,985645,985646,985647,985648,985649,9856410';
        planController.navigateToMap();
        planController.navigatingBackFromMap();
        planController.zipString = '';
        planController.navigateToMap();
        planController.navigatingBackFromMap();
        planController.zipString = '9856401';
        planController.navigateToMap();
        planController.navigatingBackFromMap();
        planController.zipString = '985640,985641,985642,985643,985644,985645,985646,985647,985648,985649,9856410';
        planController.searchZipOrNode();
        planController.next();
        planController.next();
        planController.previous();
        planController.previous();
        planController.searchZipOrNode();
        System.assert(planController.addStatWraps.size() == 10);
        planController.addStatWraps[0].selected = true;
        PageReference pageRef1 = planController.toPlanPage();
        System.assert(pageRef1.getUrl().contains('PlanEdit'));
        
        planController= new PlanningController();
        planController.nodeString = '6542';     
        planController.searchZipOrNode();
        System.assert(planController.addStatWraps.size() == 1);
        planController.addStatWraps[0].selected = true;
        pageRef1 = planController.toPlanPage();        
        System.assert(pageRef1.getUrl().contains('PlanEdit'));
        
    }
}