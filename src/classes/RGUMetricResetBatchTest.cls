/*
* Description: Test class for RGUMetricResetBatch
*/
@isTest(SeeAllData=false)
private class RGUMetricResetBatchTest {
  
    static testmethod void testBatchBiWeekly() {
        
        //Create custom setting data
        MatricDailyUpdateTimeZone__c timeZoneDetails = new MatricDailyUpdateTimeZone__c();
        timeZoneDetails.Name='KnockTimeZone';
        timeZoneDetails.DispPmStartTime__c=16;
        timeZoneDetails.DispPmEndTime__c=21;
        insert timeZoneDetails;
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c metricTrigger = new TriggerSettings__c();
            metricTrigger.Name = 'MetricTrigger';
            metricTrigger.isActive__c = False;
            triggerSettingsList.add(metricTrigger);
             
        TriggerSettings__c goalTrigger = new TriggerSettings__c();
            goalTrigger.Name = 'GoalTrigger';
            goalTrigger.isActive__c = False;
            triggerSettingsList.add(goalTrigger);
                                                
        Database.insert(triggerSettingsList);
        
        WorkTestDataUtility.setGoalTemplateBiWeeklyDateCS();
        String goalDirectsaleRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Direct Sales').getRecordTypeId();  
        Goal GoalByRep = WorkTestDataUtility.createGoal();
        GoalByRep.RecordTypeId = goalDirectsaleRecordTypeId;
        GoalByRep.Name = 'Test RGU 3';
        Database.Update(GoalByRep);        
        
        List<Metric> merticRepresentList = WorkTestDataUtility.CreateMetric();  
        List<Metric> newMerticList = new List<Metric>();
        for(Metric metric : merticRepresentList){
            metric.GoalId = GoalByRep.id;
            metric.DueDate=System.Today().addDays(+2);
            metric.CurrentValue=1;
            newMerticList.add(metric);
        }
        update newMerticList;
        
        Test.startTest();
           // String query= 'SELECT Id, Status, DueDate, CurrentValue FROM Metric where Goal.RecordTypeId=: GOAL_DIRECTSALES_RECORD_ID and Goal.Name like \'%RGU%\' and DueDate =: BYWEEK_COMMISION_END_DATE ';
            //Database.executeBatch(new RGUMetricResetBatch(query));
        String queryString = '';
        if(System.Label.RGUMetricResetBatchQuery!= Null){
            queryString = System.Label.RGUMetricResetBatchQuery;
        }
        Boolean isWest = false;
        RGUMetricResetBatch inst= new RGUMetricResetBatch(queryString,isWest); 
        database.executebatch(inst, 10);
        Test.stopTest();        
    }
    
    static testmethod void testBatchMonthly() {
        
        //Create custom setting data
        MatricDailyUpdateTimeZone__c timeZoneDetails = new MatricDailyUpdateTimeZone__c();
        timeZoneDetails.Name='KnockTimeZone';
        timeZoneDetails.DispPmStartTime__c=16;
        timeZoneDetails.DispPmEndTime__c=21;
        insert timeZoneDetails;
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c metricTrigger = new TriggerSettings__c();
            metricTrigger.Name = 'MetricTrigger';
            metricTrigger.isActive__c = False;
            triggerSettingsList.add(metricTrigger);
             
        TriggerSettings__c goalTrigger = new TriggerSettings__c();
            goalTrigger.Name = 'GoalTrigger';
            goalTrigger.isActive__c = False;
            triggerSettingsList.add(goalTrigger);
                                                
        Database.insert(triggerSettingsList);
        
        WorkTestDataUtility.setGoalTemplateMonthlyDateCS();
        String goalDirectsaleRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Direct Sales').getRecordTypeId();  
        Goal GoalByRep = WorkTestDataUtility.createGoal();
        GoalByRep.RecordTypeId = goalDirectsaleRecordTypeId;
        GoalByRep.Name = 'Test RGU 3';
        Database.Update(GoalByRep);        
        
        List<Metric> merticRepresentList = WorkTestDataUtility.CreateMetric();  
        List<Metric> newMerticList = new List<Metric>();
        for(Metric metric : merticRepresentList){
            metric.GoalId = GoalByRep.id;
            metric.DueDate=System.Today().addDays(+2);
            metric.CurrentValue=1;
            newMerticList.add(metric);
        }
        update newMerticList;
        
        Test.startTest();
           // String query= 'SELECT Id, Status, DueDate, CurrentValue FROM Metric where Goal.RecordTypeId=: GOAL_DIRECTSALES_RECORD_ID and Goal.Name like \'%RGU%\' and DueDate =: BYWEEK_COMMISION_END_DATE ';
            //Database.executeBatch(new RGUMetricResetBatch(query));
        String queryString = '';
        if(System.Label.RGUMetricResetBatchQuery!= Null){
            queryString = System.Label.RGUMetricResetBatchQuery;
        }
        Boolean isWest = true;
        RGUMetricResetBatch inst= new RGUMetricResetBatch(queryString,isWest); 
        database.executebatch(inst, 10);
        Test.stopTest();        
    }
}