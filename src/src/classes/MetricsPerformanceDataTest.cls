/**************************************************************************************************
Name : MetricsPerformanceDataTest
Description : This batch class created for Test coverage of MetricsPerformanceData apex class.
Date : 13/07/2017
Author : Tejaswini Kasar

***************************************************************************************************/@isTest                        
private class MetricsPerformanceDataTest{
      @isTest static void getRGUPerformanceDataTest(){
       
        RGU_Goal_Target_Actual__c  rguGoalTargetActualCs = new RGU_Goal_Target_Actual__c();
        rguGoalTargetActualCs.Name = 'Indirect';
        rguGoalTargetActualCs.Credential__c = 'ZGV2cHJvMkAxMjNZbkttUkZjdGlubUpoNmRTbHJ2bUZmOUk=';
        rguGoalTargetActualCs.Decription__c = 'Test';
        rguGoalTargetActualCs.Lagging_Days__c = 3;
        rguGoalTargetActualCs.Offset__c = 0;
        rguGoalTargetActualCs.Payroll_End_Date__c = Date.newInstance(2017,04,21);
        rguGoalTargetActualCs.Payroll_Start_Date__c = Date.newInstance(2017,03,21);
        rguGoalTargetActualCs.SAQL_Limit__c = 10000;
        rguGoalTargetActualCs.UserName__c = 'YW5pbWVzaC5kYXR0YUBhY2NlbnR1cmUuY29tLmNoYXR0ZXIuZGV2cHJvMg==';
        Database.insert(rguGoalTargetActualCs);
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new MetricsPerformanceDataHttpCalloutMock());
        Date beginPayrollPeriod = Date.newInstance(2017,03,21);
        Date endPayrollPeriod = Date.newInstance(2017,04,21);
        String salesChannel = 'Indirect';
        MetricsPerformanceData mPD = new MetricsPerformanceData();
        Map<String,Metric> testResult = mPD.getRGUPerformanceData(salesChannel, beginPayrollPeriod, endPayrollPeriod, 0,100);
        Test.stopTest(); 
      }
}