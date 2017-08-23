@isTest 
public class TestSprintRollUpTrigger {


    static testMethod void testAddingActionItems(){
        Sprint__c newSprint = new Sprint__c();
        newSprint.Name = 'Testing';
        insert newSprint;
        
        Action_Item__c newActionItem = new Action_Item__c();
        newActionItem.Sprint__c = newSprint.Id;
        newActionItem.Title__c = 'Test Action Item';
        newActionItem.Details__c = 'Test Action Item';
        newActionItem.Channel__c = 'Communities';
        newActionItem.Initiative__c = 'Communities';
        newActionItem.Type__c = 'Dev';
        newActionItem.Date_Identified__c = date.today();
        newActionItem.Due_Date__c = date.today().addDays(10);
        newActionItem.Status__c = 'Open';
        newActionItem.Assigned_To__c = userinfo.getUserId();
        newActionItem.Identified_by__c = userinfo.getUserId();
        newActionItem.Project_Owner__c = userinfo.getUserId();
        newActionItem.Level_of_effort__c = 'Medium';
        newActionItem.Estimated_Hours__c = 50;       

        Test.startTest();
            insert newActionItem;
            Sprint__c newSprint2 = new Sprint__c();
            newSprint.Name = 'Testing2';
            insert newSprint2;
            newActionItem.Sprint__c = newSprint2.Id;
            update newActionItem;        
            delete newActionItem;
            undelete newActionItem;

        Test.stopTest();
    }
}