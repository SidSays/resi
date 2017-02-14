/**
* This class contains unit tests for validating the MetricDailyUpdateBatchSchedule call.
* Author: Ritesh Saxena
*/
@isTest(seeAllData=false)
private class MetricDailyNewBatchScheduleTest {

    /*
    * Test scheduler call
    */
    static testMethod void engineScheduleTest() {
    
        WorkTestDataUtility.createCustomSettingRecords();       
        WorkTestDataUtility.setMatricDailyUpdateTimeZoneCS();
        WorkTestDataUtility.setGoalTemplateDateCS();
        WorkTestDataUtility.setGoalTemplateBiWeeklyDateCS();
                        
        Test.startTest();
        
        // Schedular Test
        MetricDailyBatchNewSchedule sc = new MetricDailyBatchNewSchedule();
        
        datetime currentDateTime = datetime.now();
        String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
        String schExp = '0 '+min+' * * * ? ';

        system.schedule('Schedular Test :'+datetime.now(), schExp, sc);
                
        Test.stopTest();
    }
    
    /*
    * Test scheduler call
    */
    static testMethod void engineScheduleTest2() {
    
        WorkTestDataUtility.createCustomSettingRecords();       
        WorkTestDataUtility.setMatricDailyUpdateTimeZoneCS();
        WorkTestDataUtility.setGoalTemplateDateCS();
        WorkTestDataUtility.setGoalTemplateBiWeeklyDateCS();
                
        Test.startTest();
        
        // Schedular Test
        MetricDailyBatchNewSchedule2 sc = new MetricDailyBatchNewSchedule2();
        
        datetime currentDateTime = datetime.now();
        String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
        String schExp = '0 '+min+' * * * ? ';

        system.schedule('Schedular Test :'+datetime.now(), schExp, sc);
                
        Test.stopTest();
    }
    
    /*
    * Test scheduler call
    */
    static testMethod void engineScheduleTest3() {
    
        WorkTestDataUtility.createCustomSettingRecords();       
        WorkTestDataUtility.setMatricDailyUpdateTimeZoneCS();
        WorkTestDataUtility.setGoalTemplateDateCS();
        WorkTestDataUtility.setGoalTemplateBiWeeklyDateCS();
                
        Test.startTest();
        
        // Schedular Test
        MetricDailyBatchNewSchedule3 sc = new MetricDailyBatchNewSchedule3 ();
        
        datetime currentDateTime = datetime.now();
        String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
        String schExp = '0 '+min+' * * * ? ';

        system.schedule('Schedular Test :'+datetime.now(), schExp, sc);
                
        Test.stopTest();
    }
}