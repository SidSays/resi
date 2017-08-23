/**
*   Controller extension for inline visit summary page
*   @author Sahil Grover
*/
public with sharing class StoreVisitSummaryController {

    public StoreVisitSummary VisitSummary {get; private set;}

    public StoreVisitSummaryController(ApexPages.StandardController stdController) {
        Id visitId = stdController.getId();
        Store_Visit__c visit = StoreQueryUtility.queryStoreVisit(visitId);
        Account store;
        List<Store_Visit_Activity_Category__c> activityCategories; 

        if(visit.Store__c == null) {
            store = null;
        }
        else {
            store = StoreQueryUtility.queryStore(visit.Store__c);
        }

        List<Store_Activity__c> activities = StoreQueryUtility.queryStoreActivities(visitId);

        User visitOwner = StoreQueryUtility.queryUser(visit.OwnerId);
        UserRole role = StoreQueryUtility.queryUserRole(visitOwner.UserRoleId);

        if(store == null) {
            activityCategories = StoreQueryUtility.queryActivityCategories('Prospect', role.DeveloperName);
        }
        else{
            activityCategories = StoreQueryUtility.queryActivityCategories(store.Store_Type__c, role.DeveloperName);
        }

        RequiredStoreActivityBuilder requiredActivityBuilder =
            new RequiredStoreActivityBuilder(activityCategories);
        List<RequiredStoreActivity> requiredActivities = requiredActivityBuilder.buildRequiredStoreActivities(activities);

        List<Task> visitTasks = StoreQueryUtility.queryVisitTasks(visitId);

        if(store == null) {
            this.VisitSummary = new ProspectiveStoreVisitSummary(visit, requiredActivities);
        }
        else {
            this.VisitSummary = new StoreVisitSummary(store, visit, requiredActivities, visitTasks);
        }
    }
}