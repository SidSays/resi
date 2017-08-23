@isTest(seeAllData=false)
private class CreateGoalsBatchWestScheduleTest {

    /*
    * Test scheduler call
    */
    static testMethod void engineScheduleTest() {
    
        Test.startTest();
        
        // Schedular Test
        CreateGoalsBatchWestSchedule sc = new CreateGoalsBatchWestSchedule();
        
        datetime currentDateTime = datetime.now();
        String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
        String schExp = '0 '+min+' * * * ? ';

        system.schedule('Schedular Test :'+datetime.now(), schExp, sc);
                
        Test.stopTest();
    }
    

}