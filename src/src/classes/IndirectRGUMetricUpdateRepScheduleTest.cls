/**************************************************************************************************
*Name : IndirectRGUMetricUpdateRepScheduleTest
*Description : This test class created to test coverage IndirectRGUMetricUpdateRepBatchSchedule
* User Story : US1024537(Indirect - Coach for Indirect - Retail Sales Rep - RGU Goal - Metric Targets and Actuals)
* Date : 07-May-2017
* Author : Animesh Datta
**************************************************************************************************/
@isTest(seeAllData=false)
private class IndirectRGUMetricUpdateRepScheduleTest {
    /*
    * Test scheduler call
    */
    static testMethod void rguRepSchedulerTest() {
        Test.startTest();
            // Schedular Test
            IndirectRGUMetricUpdateRepBatchSchedule  sc = new IndirectRGUMetricUpdateRepBatchSchedule();

            datetime currentDateTime = datetime.now();
            String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
            String schExp = '0 '+min+' * * * ? ';
            system.schedule('Schedular Test :'+datetime.now(), schExp, sc);
        Test.stopTest();
    }
}