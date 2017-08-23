/**************************************************************************************************
* Name : IndirectRGUMetricUpdateRepScheduleTest
* Description : This test class created to test coverage UpdateMetricBatchSchedule
* User Story : US1096500
* Date : 18th May 2017
* Author : Amit Kumar Pradhan
**************************************************************************************************/
@isTest(seeAllData=false)
private class UpdateMetricBatchScheduleTest {
    /*
    * Test scheduler call
    */
    static testMethod void rguRepSchedulerTest() {
        Test.startTest();
            // Schedular Test
            UpdateMetricBatchSchedule  sc = new UpdateMetricBatchSchedule();
            datetime currentDateTime = datetime.now();
            String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
            String schExp = '0 '+min+' * * * ? ';
            system.schedule('Schedular Test :'+datetime.now(), schExp, sc);
        Test.stopTest();
    }
}