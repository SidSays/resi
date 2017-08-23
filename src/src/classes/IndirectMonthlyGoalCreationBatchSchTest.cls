/*****************************************************************
@Author: Suchita Sharma
@Description: Test class for IndirectMonthlyGoalCreationBatchSchedule
@Created Date: 14-July-2017
*****************************************************************/
@isTest
Private class IndirectMonthlyGoalCreationBatchSchTest {
    /*Test Method
     */
    static testMethod void scheduleTest(){
        Test.startTest();
           
            IndirectMonthlyGoalCreationBatchSchedule batchScheduler = new IndirectMonthlyGoalCreationBatchSchedule();
            DateTime currentDateTime = System.Now();
            String min = String.valueOf(Math.mod((currentDateTime.minute()+2),60));
            String cronExp = '0 '+min+' * * * ? ';
            
            System.Schedule('Indiect Monthly Goal Creation Schedular :'+System.Now(),cronExp,batchScheduler);
        Test.stopTest();
    }
}