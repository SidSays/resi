/**
* This class contains unit tests for validating the RGUMetricResetBatchSchedule call.
* Author: Ashish Srivastava
*/
@isTest(seeAllData=false)
private class RGUMetricResetBatchScheduleTest {

    /*
    * Test scheduler call
    */
    static testMethod void engineScheduleTest() {
    
        Test.startTest();
        
        // Schedular Test
        RGUMetricResetBatchSchedule  sc = new RGUMetricResetBatchSchedule();
        
        datetime currentDateTime = datetime.now();
        String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
        String schExp = '0 '+min+' * * * ? ';

        system.schedule('Schedular Test :'+datetime.now(), schExp, sc);
                
        Test.stopTest();
    }
    

}