/**
* This class contains unit tests for validating the QM_QuotaAnnualBaselineBatchSchedule call.
* Created: 20-Dec-2106
*/
@isTest(seeAllData=false)
public class QM_QuotaAnnualBaselineBatchScheduleTest {
    
    /*
    * Test scheduler call
    */
    static testMethod void engineScheduleTest() {
        WorkTestDataUtility.createCustomSettingRecords();               
            
        Test.startTest();      
        // Schedular Test
        QM_QuotaAnnualBaselineBatchSchedule quotaBaseLineSchedule = new QM_QuotaAnnualBaselineBatchSchedule();
        
        datetime currentDateTime = datetime.now();
        String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
        String schExp = '0 '+min+' * * * ? ';

        system.schedule('Schedular Test 12:'+datetime.now(), schExp, quotaBaseLineSchedule );
                
        Test.stopTest();
    }

}