/**
*	Performs a basic search on store activity records
*
*	@author	Sahil Grover
*/
public with sharing class SimpleStoreActivitySearch {

	private static final String STORE_ACTIVITY_API_NAME = 'Store_Activity__c';

	private final Set<String> visitIds;

	public SimpleStoreActivitySearch(final Set<String> visitIds) {
		this.visitIds = visitIds;
	}

	public List<Store_Activity__c> queryStoreActivities() {
		QueryBuilder activityQueryBuilder = new QueryBuilder(STORE_ACTIVITY_API_NAME);
		setSelectFields(activityQueryBuilder);
		setWhereConditions(activityQueryBuilder);
		return (List<Store_Activity__c>)Database.query(activityQueryBuilder.generateQuery());
	}

	private void setSelectFields(QueryBuilder activityQueryBuilder) {
		activityQueryBuilder.addSelectField(
			StoreVisitUtility.getAllFields(STORE_ACTIVITY_API_NAME)
			);
		activityQueryBuilder.addSelectField('RecordType.DeveloperName');
	}

	private void setWhereConditions(QueryBuilder activityQueryBuilder) {
		activityQueryBuilder.addWhereCondition(
			'Store_Visit__c', 
			new List<String>(this.visitIds), 
			QueryBuilder.ComparisonOperator.IN_LIST
			);
	}
}