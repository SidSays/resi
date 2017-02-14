/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal, Accenture
 * Date       : 22-October-2013
 * Description: This is Test class for "UpdateOpportunityNameBatch", "ScheduleUpdateOpportunityNameBatch" class.
 * History
     Version             : 1.0
     Author Last Updated : Gaurav Aggarwal, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class UpdateOpportunityNameTest{
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    private static testMethod void testUpdateOpportunityName(){
        SetupTestData.createCustomSettingRecords();
        
        // Create Account
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Customer_Status__c = 'Active';
        insert acc;
        
        //Create Opportunities for this Account
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp;
        for(Integer i =0; i<=6; i++){
            opp = new Opportunity();
            opp.Name = 'LASTNAME HOME';
            opp.AccountId = acc.Id;
            opp.CloseDate = System.today() + i;
            opp.StageName = 'Open';
            oppList.add(opp);
        }
        insert oppList;
        
        Test.StartTest();
        ScheduleUpdateOpportunityNameBatch ScheduleUpdateOpportunityNameBatchObj = new ScheduleUpdateOpportunityNameBatch();
        String scheduledJobId = System.schedule('testScheduledApex', CRON_EXP, ScheduleUpdateOpportunityNameBatchObj);
        Test.StopTest();
    }
}