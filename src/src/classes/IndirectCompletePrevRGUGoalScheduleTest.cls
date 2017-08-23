/**************************************************************************************************
Name : IndirectCompletePrevRGUGoalScheduleTest
Description : This batch class created for Test coverage of IndirectCompletePreviousRGUGoalsSchedule apex class.
Date : 22/04/2017
Author : Tejaswini Kasar

***************************************************************************************************/
@isTest
private class IndirectCompletePrevRGUGoalScheduleTest {

    /*
    * Test scheduler call
    */
    static testMethod void IndirectCompletePrevRGUGoalScheduleTest() {
         
        Test.startTest();       
        // Scheduler Test
        IndirectCompletePreviousRGUGoalsSchedule sc = new IndirectCompletePreviousRGUGoalsSchedule();
        
        datetime currentDateTime = datetime.now();
        String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
        String schExp = '0 '+min+' * * * ? ';
        system.schedule('Schedular Test :'+datetime.now(), schExp, sc);      
        Test.stopTest();
    }
    

}