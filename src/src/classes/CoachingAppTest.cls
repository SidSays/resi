/***************************************************************************************************************************************
 * Author     : Radhika Bansal
 * Date       : 27-Feb-2017
 * Description: Test class for CoachingApp Apex Class
 * User Story : US1149780
 
***************************************************************************************************************************************/
@isTest
public class CoachingAppTest {
    public static TestMethod void CoachingAppMethod() {
        List<CoachingApp__mdt> objCoachingProp = [SELECT MasterLabel, Value__c FROM CoachingApp__mdt LIMIT 1];
        Test.Starttest();
        if(objCoachingProp != null && objCoachingProp.size() > 0){          
            CoachingApp.getCoachingCustomMetaData();
        }
        Test.Stoptest();
    }
}