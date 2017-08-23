/*****************************************************************
@Author: Suchita Sharma
@Description: Test class for PL_MonthlyGoalCreationBatchSchedule
@Created Date: 14-July-2017
*****************************************************************/
@isTest
Private class PL_MonthlyGoalCreationBatchScheduleTest {
     /*Test Method
     */
     static testMethod void scheduleTest(){
        Test.startTest();
            PL_MonthlyGoalCreationBatchSchedule batchScheduler = new PL_MonthlyGoalCreationBatchSchedule();
            DateTime currentDateTime = System.Now();
            String min = String.valueOf(Math.mod((currentDateTime.minute()+2),60));
            String cronExp = '0 '+min+' * * * ? ';
            
            System.Schedule('Monthly Goal Creation Schedular :'+System.Now(),cronExp,batchScheduler);
        Test.stopTest();
    }
}