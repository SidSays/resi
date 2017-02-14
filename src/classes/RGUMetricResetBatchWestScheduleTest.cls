/**
* This class contains unit tests for validating the RGUMetricResetBatchWestSchedule call.
* Author: Ashish Srivastava
*/
@isTest(seeAllData=false)
private class RGUMetricResetBatchWestScheduleTest {

    /*
    * Test scheduler call
    */
    static testMethod void engineScheduleTest() {
    
        Test.startTest();
        
        // Schedular Test
        RGUMetricResetBatchWestSchedule  sc = new RGUMetricResetBatchWestSchedule();
        
        datetime currentDateTime = datetime.now();
        String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
        String schExp = '0 '+min+' * * * ? ';

        system.schedule('Schedular Test :'+datetime.now(), schExp, sc);
                
        Test.stopTest();
    }
    

}