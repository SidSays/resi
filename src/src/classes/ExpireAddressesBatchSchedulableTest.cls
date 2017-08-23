/*****************************************************************
@Author: Suchita Sharma
@Description: Test class for ExpireAddressesBatchSchedulable
@Created Date: 14-July-2017
*****************************************************************/
@isTest
Private class ExpireAddressesBatchSchedulableTest {
    /*Test Method
     */
    static testMethod void scheduleTest(){
        Test.startTest();
            ExpireAddressesBatchSchedulable batchScheduler = new ExpireAddressesBatchSchedulable();
            DateTime currentDateTime = System.Now();
            String min = String.valueOf(Math.mod((currentDateTime.minute()+2),60));
            String cronExp = '0 '+min+' * * * ? ';
            
            System.Schedule('Expire Address batch Schedular :'+System.Now(),cronExp,batchScheduler);
        Test.stopTest();
    }
}