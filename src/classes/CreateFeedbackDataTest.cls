/*
* Description: Test class for CreateFeedbackData.
* Created By: Revan Bhadange
*/
@isTest
private class CreateFeedbackDataTest{

    /*
    * Test method to cover the Performance cycle record generation.
    */
    static testmethod void testCreateFeedbackData1(){
        Test.startTest(); 
            CreateFeedbackData.createPerformanceCyclesAndQuestions(52,system.Today(), Label.CAR_Event);
            system.assertEquals([Select Id from WorkPerformanceCycle].size(), 52);       
        Test.stopTest();
    }
    static testmethod void testCreateFeedbackData2(){
        Test.startTest(); 
            CreateFeedbackData.createPerformanceCyclesAndQuestions(52,system.Today(), Label.Property_Visit);
            system.assertEquals([Select Id from WorkPerformanceCycle].size(), 52);       
        Test.stopTest();
    }
    static testmethod void testCreateFeedbackData3(){
        Test.startTest(); 
            CreateFeedbackData.createPerformanceCyclesAndQuestions(52,system.Today(), Label.XSP_Ridealong);
            system.assertEquals([Select Id from WorkPerformanceCycle].size(), 52);       
        Test.stopTest();
    }

}