@isTest
private class CrossRegionXCGoalBatchScheduleTest {
    
    static testMethod void scheduleTest(){
        Test.startTest();
            CrossRegionXCGoalBatchSchedule batchScheduler = new CrossRegionXCGoalBatchSchedule();
            DateTime currentDateTime = System.Now();
            String min = String.valueOf(Math.mod((currentDateTime.minute()+2),60));
            String cronExp = '0 '+min+' * * * ? ';
            
            System.Schedule('Cross Regional Schedular :'+System.Now(),cronExp,batchScheduler);
        Test.stopTest();
    }
}