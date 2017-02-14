/**
* This class contains unit tests for validating the MetricDailyUpdateBatchSchedule call.
* Author: Ritesh Saxena
*/
@isTest(seeAllData=false)
private class MetricDailyUpdateBatchScheduleTest {

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
        MetricDailyUpdateBatchSchedule sc = new MetricDailyUpdateBatchSchedule();
        
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
        MetricDailyUpdateBatchSchedule2 sc = new MetricDailyUpdateBatchSchedule2();
        
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
        MetricDailyUpdateBatchSchedule3 sc = new MetricDailyUpdateBatchSchedule3();
        
        datetime currentDateTime = datetime.now();
        String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
        String schExp = '0 '+min+' * * * ? ';

        system.schedule('Schedular Test :'+datetime.now(), schExp, sc);
                
        Test.stopTest();
    }
}