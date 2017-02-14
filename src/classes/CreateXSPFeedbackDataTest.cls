/*
* Description: Test class for CreateXSPFeedbackData.
* Created By: Ritesh Saxena
*/
@isTest
private class CreateXSPFeedbackDataTest{

    /*
    * Test method to cover the Performance cycle record generation.
    */
    static testmethod void testXSPFeedbackData(){
    
        Test.startTest(); 

            CreateXSPFeedbackData.createPerformanceCyclesAndQuestions(52, system.Today());
            system.assertEquals([Select Id from WorkPerformanceCycle].size(), 52);
             
        Test.stopTest();
    }

}