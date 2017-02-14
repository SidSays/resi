/**
* This class contains unit tests for validating the MDUPropertyRiskStatusAutoSetSchedule call.
* Created: 29-Jan-2015
*/
@isTest(seeAllData=false)
private class MDUPropertyRiskAutoSetScheduleTest {

    /*
    * Test scheduler call
    */
    static testMethod void engineScheduleTest() {
                
        Test.startTest();
        
        // Schedular Test
        MDUPropertyRiskStatusAutoSetSchedule sc = new MDUPropertyRiskStatusAutoSetSchedule();
        
        datetime currentDateTime = datetime.now();
        String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
        String schExp = '0 '+min+' * * * ? ';

        system.schedule('Schedular Test :'+datetime.now(), schExp, sc);
                
        Test.stopTest();
    }
}