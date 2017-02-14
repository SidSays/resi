/**
* This class contains unit tests for validating the QM_PortfolioAEQuotaBatchSchedule call.
* Created: 11-May-2106
*/
@isTest(seeAllData=false)
public class QM_PortfolioAEQuotaBatchScheduleTest {
    
    /*
    * Test scheduler call
    */
    static testMethod void engineScheduleTest() {
        WorkTestDataUtility.createCustomSettingRecords();               
       // WorkTestDataUtility.setMatricDailyUpdateTimeZoneCS();        
        //WorkTestDataUtility.setGoalTemplateDateCS();        
        //WorkTestDataUtility.setGoalTemplateBiWeeklyDateCS(); 
                
        Test.startTest();
        
        // Schedular Test
        QM_PortfolioAEQuotaBatchSchedule  PortfolioAEBatchSchedule = new QM_PortfolioAEQuotaBatchSchedule();
        
        datetime currentDateTime = datetime.now();
        String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
        String schExp = '0 '+min+' * * * ? ';

        system.schedule('Schedular Test 12:'+datetime.now(), schExp, PortfolioAEBatchSchedule);
                
        Test.stopTest();
    }

}