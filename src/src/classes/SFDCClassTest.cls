@isTest
public class SFDCClassTest{
    /*
        Test Coverage for IndirectRGUMetricUpdateRepBatch
    */
    
    public static testmethod void testIndirectRGUMetricUpdateRepBatch(){
        Test.setMock(HttpCalloutMock.class, new WaveAPIUtilHttpCalloutMock()); 
        String goalIndirectSalesRecordTypeId= Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Indirect Sales').getRecordTypeId();
        WorkTestDataUtility.createCustomSettingRecords();
        test.starttest();
         SFDCTest.myMethod();
        test.stoptest();
    }  
  
}