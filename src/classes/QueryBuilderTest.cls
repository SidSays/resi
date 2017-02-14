/**
*	Test class for Query
*
*	@author	Sahil Grover	<sgrover@acumensolutions.com>
*/
@isTest
private class QueryBuilderTest {
	@isTest static void testGenerateQuery() {
		final String testQuery = 
			'SELECT ID, Name, (SELECT ID, Name FROM ChildObjects__r LIMIT 1000)' +
			' FROM ParentObject__c' +
			' WHERE integerValue = 1' +
			' AND decimalValue > 2.0' + 
			' AND doubleValue >= 2.0' +
			' AND dateValue < 2013-07-29' +
			' AND dateTimeValue <= 2013-07-29 08:38:43' +
			' AND containsValue LIKE \'%value1%\'' +
			' AND startsWithValue LIKE \'value1%\'' +
			' AND endsWithValue LIKE \'%value1\'' +
			' AND inStringValue IN (\'value1\', \'value2\')' +
			' AND notInStringValue NOT IN (\'value1\', \'value2\')' +
			' AND (dateRangeValue >= 2013-07-29 AND dateRangeValue <= 2013-07-29)' +
			' ORDER BY orderField1 ASC, orderField2 DESC' +
			' LIMIT 500';

		String queryStr;
		test.startTest();
			QueryBuilder subq = new QueryBuilder('ChildObjects__r');
			subq.addSelectField('ID');
			subq.addSelectField('Name');
			subq.setLimit(1000);
			QueryBuilder q = new QueryBuilder('ParentObject__c');
			q.addSelectField('ID');
			q.addSelectField('Name');
			q.addSelectField(subq);
			q.addOrderField('orderField1');
			q.addOrderField('orderField2', QueryBuilder.OrderType.DESCENDING);
			q.setLimit(500);
			q.addWhereCondition('integerValue', 1, QueryBuilder.ComparisonOperator.EQUALS);
			q.addWhereCondition('decimalValue', 2.0, QueryBuilder.ComparisonOperator.GREATER);
			q.addWhereCondition('doubleValue', 2.0, QueryBuilder.ComparisonOperator.GREATER_EQUAL);
			q.addWhereCondition('dateValue', Date.valueof('2013-07-29'), QueryBuilder.ComparisonOperator.LESS);
			q.addWhereCondition('dateTimeValue', DateTime.valueof('2013-07-29 08:38:43'), QueryBuilder.ComparisonOperator.LESS_EQUAL);
			q.addWhereCondition('containsValue', 'value1', QueryBuilder.ComparisonOperator.CONTAINS);
			q.addWhereCondition('startsWithValue', 'value1', QueryBuilder.ComparisonOperator.STARTS_WITH);
			q.addWhereCondition('endsWithValue', 'value1', QueryBuilder.ComparisonOperator.ENDS_WITH);
			q.addWhereCondition('inStringValue', new List<String>{'value1', 'value2'}, QueryBuilder.ComparisonOperator.IN_LIST);
			q.addWhereCondition('notInStringValue', new List<String>{'value1', 'value2'}, QueryBuilder.ComparisonOperator.NOT_IN_LIST);
			DateRange dr = new DateRange();
			dr.FromDate = Date.valueof('2013-07-29');
			dr.ToDate = Date.valueof('2013-07-29');
			q.addWhereCondition('dateRangeValue', dr);
			queryStr = q.generateQuery();
		test.stopTest();
		system.assertEquals(testQuery, queryStr);
	}

	@isTest
	static void testWhereConditionGroups() {
		final String testQuery = 
			'SELECT ID'
			+ ' FROM ParentObject__c'
			+ ' WHERE integerField = 1'
			+ ' AND (decimalField < 10.0 OR decimalField > 20.0)'
			+ ' AND ((stringField1 = \'value1\' OR stringField1 = \'value2\') AND stringField2 = \'value3\')'
			;
		String queryStr;
		test.startTest();
			QueryBuilder q = new QueryBuilder('ParentObject__c');
			q.addSelectField('ID');
			q.addWhereCondition(
				q.createWhereCondition('integerField', 1, QueryBuilder.ComparisonOperator.EQUALS)
				);

			QueryBuilder.WhereConditionGroup decimalFieldGroup = new QueryBuilder.WhereConditionGroup(
				new List<QueryBuilder.WhereCondition>{
					q.createWhereCondition('decimalField', 10.0, QueryBuilder.ComparisonOperator.LESS),
					q.createWhereCondition('decimalField', 20.0, QueryBuilder.ComparisonOperator.GREATER)
				},
				QueryBuilder.ConditionOperator.OR_CONDITION
				);

			q.addWhereCondition(decimalFieldGroup);

			QueryBuilder.WhereConditionGroup stringField1Group = new QueryBuilder.WhereConditionGroup(
				new List<QueryBuilder.WhereCondition>{
					q.createWhereCondition('stringField1', 'value1', QueryBuilder.ComparisonOperator.EQUALS),
					q.createWhereCondition('stringField1', 'value2', QueryBuilder.ComparisonOperator.EQUALS)
					},
				QueryBuilder.ConditionOperator.OR_CONDITION
				);
			QueryBuilder.WhereConditionGroup stringGroup = new QueryBuilder.WhereConditionGroup(
				new List<QueryBuilder.Condition>{
					stringField1Group,
					q.createWhereCondition('stringField2', 'value3', QueryBuilder.ComparisonOperator.EQUALS)
					},
				QueryBuilder.ConditionOperator.AND_CONDITION
				);

			q.addWhereCondition(stringGroup);

			queryStr = q.generateQuery();
		test.stopTest();
		system.assertEquals(testQuery, queryStr);
	}
}