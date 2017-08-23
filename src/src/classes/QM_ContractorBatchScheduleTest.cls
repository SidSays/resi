/**
* This class contains unit tests for validating the QM_AnnualBaselineContractorBatchSchedule call.
* Created: 17-05-2016
Author - Sucheta Verma
*/

@isTest(seeAllData=false)
public class QM_ContractorBatchScheduleTest {
    
    /*
    * Test scheduler call
    */
    static testMethod void engineScheduleTest() {
                
        Test.startTest();
        
        // Schedular Test
        QM_AnnualBaselineContractorBatchSchedule contractorBatchSchedule = new QM_AnnualBaselineContractorBatchSchedule ();
        
        datetime currentDateTime = datetime.now();
        String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
        String schExp = '0 '+min+' * * * ? ';

        system.schedule('Schedular Test 12:'+datetime.now(), schExp, contractorBatchSchedule);
                
        Test.stopTest();
    }

}