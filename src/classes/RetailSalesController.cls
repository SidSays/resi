/**
 * Controller for the RetailSalesPage. This page shows the users Store Visits and Stores
 *
 *  @author Ryan Sayles     <rsayles@acumensolutions.com>
 *  @author Sahil Grover    <sgrover@acumensolutions.com>
 */
 
public with sharing class RetailSalesController {

    private Id UserId; 

    private final String DATE_OPTION_TODAY = 'Today';
    private final String DATE_OPTION_YESTERDAY = 'Yesterday';
    private final String DATE_OPTION_WEEK = 'Week';
    private final String DATE_OPTION_MONTH = 'Past 30 days';

    public Boolean HasProspectOption {get; set;}
    public String SelectedDateFilter {get; set;}
    public List<StoreVisitEvent> SelectedVisitEvents {
        get {
            return buildStoreVisitEventList(SelectedDateFilter);
        }
    }
    public DateTime LocalCurrentDateTime {
        get {
            return StoreVisitUtility.getLocalTimeFromGmt(DateTime.now());
        }
    }

    public RetailSalesController () {
        UserId = UserInfo.getUserId();
        checkUserRole();
        this.SelectedDateFilter = DATE_OPTION_TODAY;
    }

    public void checkUserRole() {
        User currentUser = [SELECT Sales_Rep_Type__c FROM User WHERE Id = :UserId];
        if (currentUser.Sales_Rep_Type__c != null && currentUser.Sales_Rep_Type__c.equals('Dealer AE')) {
            HasProspectOption = true;
        }
        else {
            HasProspectOption = false;
        }
    }

    // need this to trigger rerender
    public void dummyFunc() {}

    public List<Account> getUserStores() {  
        return [SELECT Id, Name, OwnerId, Store_Nickname__c, BillingStreet, BillingState, 
                       BillingPostalCode, BillingCity, Overdue__c, 
                       (SELECT Id FROM Tasks WHERE Status =: 'Open')
                FROM Account
                WHERE OwnerId =: UserId OR Owner.ManagerID = :UserInfo.getUserId() 
                ORDER BY Name ASC];

        
    }

    public List<Event> getEvents(String filterDate) {
        QueryBuilder eventQuery = new QueryBuilder('Event');
        Set<String> selectFieldsList = new Set<String>{'Id','OwnerId', 'StartDateTime', 'EndDateTime', 
                      'AccountId', 'Account.Name', 'Account.Store_Nickname__c', 'Account.BillingStreet', 'Account.BillingState',
                       'Account.BillingCity', 'Account.BillingPostalCode', 'Account.Overdue__c', 'Is_Visit_Complete__c'};

        eventQuery.addSelectField(selectFieldsList);
        QueryBuilder.WhereCondition userIdCondition = eventQuery.createWhereCondition('OwnerId', UserId, QueryBuilder.ComparisonOperator.EQUALS);
        QueryBuilder.WhereCondition isCompletedCondition = eventQuery.createWhereCondition('Is_Visit_Complete__c', false, QueryBuilder.ComparisonOperator.EQUALS);
        QueryBuilder.WhereCondition dateFilterCondition;
        if (filterDate == DATE_OPTION_TODAY) {
            dateFilterCondition = eventQuery.createWhereCondition('StartDateTime', 'TODAY', QueryBuilder.ComparisonOperator.EQUALS, false);
        }
        else if (filterDate == DATE_OPTION_YESTERDAY) {
            dateFilterCondition = eventQuery.createWhereCondition('StartDateTime', 'YESTERDAY', QueryBuilder.ComparisonOperator.EQUALS, false);            
        }
        else if (filterDate == DATE_OPTION_WEEK) {
            dateFilterCondition = eventQuery.createWhereCondition('StartDateTime', 'THIS_WEEK', QueryBuilder.ComparisonOperator.EQUALS, false);            
        }
        else {
            dateFilterCondition = eventQuery.createWhereCondition('StartDateTime', 'LAST_N_DAYS:30', QueryBuilder.ComparisonOperator.EQUALS, false);
        }

        QueryBuilder.WhereConditionGroup eventWhereGroup = new QueryBuilder.WhereConditionGroup(
                new List<QueryBuilder.WhereCondition>{
                    userIdCondition,
                    isCompletedCondition,
                    dateFilterCondition
                },
                QueryBuilder.ConditionOperator.AND_CONDITION
                );

        eventQuery.addWhereCondition(eventWhereGroup);

        eventQuery.addOrderField('StartDateTime', QueryBuilder.OrderType.ASCENDING);

        String eventQueryText = eventQuery.generateQuery();
        return (List<Event>)Database.query(eventQueryText);

    }

    public List<Store_Visit__c> getStoreVisits(String filterDate) {
        QueryBuilder storeVisitQuery = new QueryBuilder('Store_Visit__c');
        Set<String> selectFieldsList = new Set<String>{'Id', 'Store__r.Id','Store__r.OwnerId', 'Store__c', 'Prospect_Store_Name__c', 'End_Date_Time__c', 'Start_Date_Time__c', 
            'Subject__c', 'Store__r.Name', 'Store__r.Store_Nickname__c', 'Store__r.BillingStreet', 'Store__r.BillingState', 'Store__r.BillingCity', 
            'Store__r.BillingPostalCode', 'Store__r.Overdue__c', 'Store_Visit_Status__c'};

        storeVisitQuery.addSelectField(selectFieldsList);
        QueryBuilder.WhereCondition userIdCondition = storeVisitQuery.createWhereCondition('OwnerId', UserId, QueryBuilder.ComparisonOperator.EQUALS);
        QueryBuilder.WhereCondition dateFilterCondition;
        if (filterDate == DATE_OPTION_TODAY) {
            dateFilterCondition = storeVisitQuery.createWhereCondition('Start_Date_Time__c', 'TODAY', QueryBuilder.ComparisonOperator.EQUALS, false);
        }
        else if (filterDate == DATE_OPTION_YESTERDAY) {
            dateFilterCondition = storeVisitQuery.createWhereCondition('Start_Date_Time__c', 'YESTERDAY', QueryBuilder.ComparisonOperator.EQUALS, false);            
        }
        else if (filterDate == DATE_OPTION_WEEK) {
            dateFilterCondition = storeVisitQuery.createWhereCondition('Start_Date_Time__c', 'THIS_WEEK', QueryBuilder.ComparisonOperator.EQUALS, false);            
        }
        else {
            dateFilterCondition = storeVisitQuery.createWhereCondition('Start_Date_Time__c', 'LAST_N_DAYS:30', QueryBuilder.ComparisonOperator.EQUALS, false);
        }

        QueryBuilder.WhereConditionGroup visitWhereGroup = new QueryBuilder.WhereConditionGroup(
                new List<QueryBuilder.WhereCondition>{
                    userIdCondition,
                    dateFilterCondition
                },
                QueryBuilder.ConditionOperator.AND_CONDITION
                );

        storeVisitQuery.addWhereCondition(visitWhereGroup);

        storeVisitQuery.addOrderField('Start_Date_Time__c', QueryBuilder.OrderType.ASCENDING);

        String storeVisitQueryText = storeVisitQuery.generateQuery();
        return (List<Store_Visit__c>)Database.query(storeVisitQueryText);

    }

    public List<StoreVisitEvent> buildStoreVisitEventList(String filterDate) {
        List<StoreVisitEvent> storeVisitEvents = new List<StoreVisitEvent>(); 

        for (Store_Visit__c storeVisit : getStoreVisits(filterDate)) {
            StoreVisitEvent visitEvent = new StoreVisitEvent(storeVisit);
            storeVisitEvents.add(visitEvent);
        }

        for (Event storeEvent : getEvents(filterDate)) {
            StoreVisitEvent visitEvent = new StoreVisitEvent(storeEvent);
            storeVisitEvents.add(visitEvent);
        }

        storeVisitEvents.sort();

        return storeVisitEvents;
    }
}