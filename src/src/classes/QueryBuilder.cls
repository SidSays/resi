/**
*	Generates a SOQL query
*
*	@author	Sahil Grover	<sgrover@acumensolutions.com>
*/
public with sharing class QueryBuilder {

	public enum ComparisonOperator {
		EQUALS,			// =
		NOT_EQUALS,		// <>
		GREATER,		// >
		LESS,			// <
		GREATER_EQUAL,	// >=
		LESS_EQUAL,		// <=
		IN_LIST,		// IN (cannot use IN here, because apex compiler thinks it is a query)
		NOT_IN_LIST,	// NOT IN
		CONTAINS,		// %%
		STARTS_WITH,	// %
		ENDS_WITH		// %
	}

	public enum OrderType {
		ASCENDING,
		DESCENDING
	}

	public enum ConditionOperator {
		AND_CONDITION,
		OR_CONDITION
	}

	public boolean IgnoreBlankValues {get; set;}

	private static final String OPERATION_LIKE = 'LIKE';
	private static final String CONDITION_AND = 'AND';
	private static final String CONDITION_OR = 'OR';

	private List<String> selectFields;
	private String fromStr;
	private String orderStr;
	private String limitStr;
	private integer recordLimit;
	private List<Condition> conditions;

	public QueryBuilder(final String objectName) {
		this.selectFields = new List<String>();
		fromStr = 'FROM ' + String.escapeSingleQuotes(objectName);	// don't need this here but we can prevent security scan from complaining
		orderStr = '';
		limitStr = 'LIMIT';
		conditions = new List<Condition>();
		recordLimit = -1;
		IgnoreBlankValues = true;
	}

	/**
	*	Generate the SOQL query String
	*
	*	@return	The generated SOQL query String
	*/
	public String generateQuery() {
		if (selectFields.isEmpty()) {
			throw new DynamicQueryException('A dynamic query must have at least one select field before being generated');
		}

		String whereStr = buildWhereString(this.conditions);
		String queryStr =
			'SELECT ' + String.join(this.selectFields, ', ') + ' '
			+ this.fromStr + ' ' 
			+ (String.isEmpty(whereStr) ? '' : 'WHERE ' + whereStr + ' ') 
			+ this.orderStr + (String.isEmpty(orderStr) ? '' : ' ')
			+ (this.recordLimit > 0 ? this.limitStr + ' ' + this.recordLimit : '');
		return queryStr.trim();
	}

	/**
	*	Add a subquery to the select statement of the query
	*
	*	@param	subquery	A QueryBuilder instance that generates a subquery
	*/
	public void addSelectField(final QueryBuilder subquery) {
		addSelectField(
			'(' + subquery.generateQuery() + ')'
			);
	}

	/**
	*	Add a field to the select statement of the query
	*
	*	@param	selectField	The API name of the field to add to the select statement
	*/
	public void addSelectField(final String selectField) {
		addSelectField(new Set<String>{selectField});
	}

	/**
	*	Add a list of fields to the select statement of the query
	*
	*	@param	selectFields	A set of field API names to add to the select statement
	*/
	public void addSelectField(final Set<String> selectFields) {
		this.selectFields.addAll(selectFields);
	}

	/**
	*	Add a field to the order statement of the query
	*
	*	@param	orderField	The field to add to the order statement
	*/
	public void addOrderField(final String orderField) {
		addOrderField(orderField, OrderType.ASCENDING);
	}

	/**
	*	Add a list of fields to the order statement of the query
	*
	*	@param	orderFields	The list of fields to add to the order statement
	*/
	public void addOrderField(final List<String> orderFields) {
		addOrderField(orderFields, OrderType.ASCENDING);
	}

	/**
	*	Add a field to the order statement of the query
	*
	*	@param	orderField	The field to add to the order statement
	*	@param	order		How the fields should be ordered (ascending or descending)
	*/
	public void addOrderField(final String orderField, final OrderType order) {
		addOrderField(new List<String>{orderField}, order);
	}

	/**
	*	Add a list of fields to the order statement of the query
	*
	*	@param	orderFields	The list of fields to add to the order statement
	*	@param	order		How the fields should be ordered (ascending or descending)
	*/
	public void addOrderField(final List<String> orderFields, final OrderType order) {	// this is a list so we keep the same order fields were entered
		for (String s : orderFields) {
			if (String.isEmpty(orderStr)) {
				orderStr = 'ORDER BY ';
			} else {
				orderStr += ', ';
			}
			// same rules for escaping as select fields
			orderStr += s + ' ' + translateOrderType(order);
		}
	}

	private String translateOrderType(final OrderType order) {
		if (order == OrderType.ASCENDING) {
			return 'ASC';
		} else if (order == OrderType.DESCENDING) {
			return 'DESC';
		}
		throw new QuerySupportException('The entered order type ' + order + ' is not supported.');
	}

	/**
	*	Set the record limit for the query
	*
	*	@param	recordLimit	The value for the limit statement
	*/
	public void setLimit(final integer recordLimit) {
		this.recordLimit = recordLimit;
	}


	/**
	*	Add a condition the WHERE statement
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The value of the field to check against
	*	@param	op			The comparison operator of the where condition
	*/
	public void addWhereCondition(final String fieldName, final boolean value, final ComparisonOperator op) {
		addWhereCondition(fieldName, String.valueof(value), op, false);
	}

	/**
	*	Add a condition the WHERE statement
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The value of the field to check against
	*	@param	op			The comparison operator of the where condition
	*/
	public void addWhereCondition(final String fieldName, final integer value, final ComparisonOperator op) {
		addWhereCondition(fieldName, String.valueof(value), op, false);
	}

	/**
	*	Add a condition the WHERE statement
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The value of the field to check against
	*	@param	op			The comparison operator of the where condition
	*/
	public void addWhereCondition(final String fieldName, final decimal value, final ComparisonOperator op) {
		addWhereCondition(fieldName, String.valueof(value), op, false);
	}

	/**
	*	Add a condition the WHERE statement
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The value of the field to check against
	*	@param	op			The comparison operator of the where condition
	*/
	public void addWhereCondition(final String fieldName, final double value, final ComparisonOperator op) {
		addWhereCondition(fieldName, String.valueof(value), op, false);
	}

	/**
	*	Add a condition the WHERE statement
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The value of the field to check against
	*	@param	op			The comparison operator of the where condition
	*/
	public void addWhereCondition(final String fieldName, final Date value, final ComparisonOperator op) {
		addWhereCondition(fieldName, String.valueof(value), op, false);
	}

	/**
	*	Add a condition the WHERE statement
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The date range of the field to check against
	*/
	public void addWhereCondition(final String fieldName, final DateRange value) {
		addWhereCondition(
			createWhereCondition(fieldName, value)
			);
	}

	/**
	*	Add a condition the WHERE statement
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The value of the field to check against
	*	@param	op			The comparison operator of the where condition
	*/
	public void addWhereCondition(final String fieldName, final DateTime value, final ComparisonOperator op) {
		addWhereCondition(fieldName, String.valueof(value), op, false);
	}

	/**
	*	Add a condition the WHERE statement
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The value of the field to check against
	*	@param	op			The comparison operator of the where condition
	*/
	public void addWhereCondition(final String fieldName, final String value, final ComparisonOperator op) {
		addWhereCondition(fieldName, value, op, true);
	}

	/**
	*	Add a condition the WHERE statement
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The value of the field to check against
	*	@param	op			The comparison operator of the where condition
	*	@param	needsQuotes	True to add single quotes around the value
	*/
	public void addWhereCondition(final String fieldName, final String value, final ComparisonOperator op, final boolean needsQuotes) {
		addWhereCondition(
			createWhereCondition(fieldName, value, op, needsQuotes)
			);
	}

	/**
	*	Add a condition the WHERE statement
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	values		The values of the field to check against
	*	@param	op			The comparison operator of the where condition
	*/
	public void addWhereCondition(final String fieldName, final List<String> values, final ComparisonOperator op) {
		addWhereCondition(
			createWhereCondition(fieldName, values, op)
			);
	}

	/**
	*	Create a where condition
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The value of the field to check against
	*	@param	op			The comparison operator of the where condition
	*
	*	@return	Returns a WhereCondition object
	*/
	public WhereCondition createWhereCondition(final String fieldName, final boolean value, final ComparisonOperator op) {
		return createWhereCondition(fieldName, String.valueof(value), op, false);
	}

	/**
	*	Create a where condition
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The value of the field to check against
	*	@param	op			The comparison operator of the where condition
	*
	*	@return	Returns a WhereCondition object
	*/
	public WhereCondition createWhereCondition(final String fieldName, final integer value, final ComparisonOperator op) {
		return createWhereCondition(fieldName, String.valueof(value), op, false);
	}

	/**
	*	Create a where condition
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The value of the field to check against
	*	@param	op			The comparison operator of the where condition
	*
	*	@return	Returns a WhereCondition object
	*/
	public WhereCondition createWhereCondition(final String fieldName, final decimal value, final ComparisonOperator op) {
		return createWhereCondition(fieldName, String.valueof(value), op, false);
	}

	/**
	*	Create a where condition
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The value of the field to check against
	*	@param	op			The comparison operator of the where condition
	*
	*	@return	Returns a WhereCondition object
	*/
	public WhereCondition createWhereCondition(final String fieldName, final double value, final ComparisonOperator op) {
		return createWhereCondition(fieldName, String.valueof(value), op, false);
	}

	/**
	*	Create a where condition
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The value of the field to check against
	*	@param	op			The comparison operator of the where condition
	*
	*	@return	Returns a WhereCondition object
	*/
	public WhereCondition createWhereCondition(final String fieldName, final Date value, final ComparisonOperator op) {
		return createWhereCondition(fieldName, String.valueof(value), op, false);
	}

	/**
	*	Create a where condition group for a date range
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The date range of the field to check against
	*
	*	@return Returns a WhereConditionGroup object
	*/
	public WhereConditionGroup createWhereCondition(final String fieldName, final DateRange value) {
		List<Condition> conditions = new List<Condition>{
			createWhereCondition(fieldName, String.valueof(value.FromDate), ComparisonOperator.GREATER_EQUAL, false),
			createWhereCondition(fieldName, String.valueof(value.ToDate), ComparisonOperator.LESS_EQUAL, false)
			};
		return new WhereConditionGroup(conditions, ConditionOperator.AND_CONDITION);
	}

	/**
	*	Create a where condition
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The value of the field to check against
	*	@param	op			The comparison operator of the where condition
	*
	*	@return	Returns a WhereCondition object
	*/
	public WhereCondition createWhereCondition(final String fieldName, final DateTime value, final ComparisonOperator op) {
		return createWhereCondition(fieldName, String.valueof(value), op, false);
	}

	/**
	*	Create a where condition
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The value of the field to check against
	*	@param	op			The comparison operator of the where condition
	*
	*	@return	Returns a WhereCondition object
	*/
	public WhereCondition createWhereCondition(final String fieldName, final String value, final ComparisonOperator op) {
		return createWhereCondition(fieldName, value, op, true);
	}

	/**
	*	Create a where condition
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	value		The value of the field to check against
	*	@param	op			The comparison operator of the where condition
	*	@param	needsQuotes	True to add single quotes around the value
	*
	*	@return	Returns a WhereCondition object
	*/
	public WhereCondition createWhereCondition(final String fieldName, final String value, final ComparisonOperator op, final boolean needsQuotes) {
		String whereCondition = buildWhereCondition(fieldName, value, op, needsQuotes);
		return createWhereCondition(whereCondition);
	}

	/**
	*	Create a where condition
	*
	*	@param	fieldName	The API name of the field to check
	*	@param	values		The values of the field to check against
	*	@param	op			The comparison operator of the where condition
	*
	*	@return	Returns a WhereCondition object
	*/
	public WhereCondition createWhereCondition(final String fieldName, final List<String> values, final ComparisonOperator op) {
		String whereCondition = buildWhereCondition(fieldName, values, op);
		return createWhereCondition(whereCondition);
	}

	/**
	*	Add a where condition to the query
	*
	*	@param	whereCond	The where condition to add
	*/
	public void addWhereCondition(final WhereCondition whereCond) {
		this.conditions.add(whereCond);
	}

	/**
	*	Add a group of where conditions to the query
	*
	*	@param	whereCondGroup	The where condition group to add
	*/
	public void addWhereCondition(final WhereConditionGroup whereCondGroup) {
		this.conditions.add(whereCondGroup);
	}

	private WhereCondition createWhereCondition(string conditionString) {
		return new WhereCondition(conditionString);
	}

	private String buildWhereCondition(final String fieldName, final String value, final ComparisonOperator op, final boolean needsQuotes) {
		if (IgnoreBlankValues && !hasValue(value)) {
			return '';
		}

		String whereCondition = fieldName + ' ';
		String opStr = '';

		if (op == ComparisonOperator.CONTAINS) {
			return whereCondition + OPERATION_LIKE + ' \'%' + String.escapeSingleQuotes(value) + '%\'';
		} else if (op == ComparisonOperator.STARTS_WITH) {
			return whereCondition + OPERATION_LIKE + ' \'' + String.escapeSingleQuotes(value) + '%\'';
		} else if (op == ComparisonOperator.ENDS_WITH) {
			return whereCondition + OPERATION_LIKE + ' \'%' + String.escapeSingleQuotes(value) + '\'';
		} else if (op == ComparisonOperator.EQUALS) {
			opStr = '=';
		} else if (op == ComparisonOperator.NOT_EQUALS) {
			opStr = '<>';
		} else if (op == ComparisonOperator.GREATER) {
			opStr = '>';
		} else if (op == ComparisonOperator.GREATER_EQUAL) {
			opStr = '>=';
		} else if (op == ComparisonOperator.LESS) {
			opStr = '<';
		} else if (op == ComparisonOperator.LESS_EQUAL) {
			opStr = '<=';
		} else {
			throw new QuerySupportException('The comparison operator ' + op + ' is not supported with a String value.');
		}

		String formattedValue;
		if (needsQuotes) {
			formattedValue = '\'' + String.escapeSingleQuotes(value) + '\'';
		} else {
			formattedValue = String.escapeSingleQuotes(value);
		}

		return whereCondition + opStr + ' ' + formattedValue;
	}

	private String buildWhereCondition(final String fieldName, final List<String> values, final ComparisonOperator op) {
		if (IgnoreBlankValues && !hasItems(values)) {
			return '';
		}

		String whereCondition = fieldName + ' ';
		String opStr = '';
		if (op == ComparisonOperator.IN_LIST) {
			opStr = 'IN';
		} else if (op == ComparisonOperator.NOT_IN_LIST) {
			opStr = 'NOT IN';
		} else {
			throw new QuerySupportException('The comparison operator ' + op + ' is not supported with a list of String values.');
		}

		String whereValue = '(';
		for (integer i=0; i<values.size(); i++) {
			if (i > 0) {
				whereValue += ', ';
			}
			whereValue += '\'' + String.escapeSingleQuotes(values[i]) + '\'';
		}
		whereValue += ')';

		return whereCondition + opStr + ' ' + whereValue;
	}

	private boolean hasValue(final object value) {
		return value != null && !String.isEmpty( String.valueof(value) );
	}

	private boolean hasItems(final List<object> items) {
		return items != null && !items.isEmpty();
	}

	private static String buildWhereString(final List<Condition> conditions) {
		return buildWhereString(conditions, CONDITION_AND);
	}

	private static String buildWhereString(final List<Condition> conditions, final String conditionalOperator) {
		if (conditions.size() == 0) {
			return '';
		}

		List<String> whereConditions = new List<String>();
		for (Condition cond : conditions) {
			whereConditions.add(cond.getConditionString());
		}
		return String.join(whereConditions, ' ' + conditionalOperator + ' ');
	}

	/**
	*	Base class for where conditions and groups of where conditions
	*/
	public abstract class Condition {
		abstract String getConditionString();
	}

	/**
	*	Decorator for a condition in the WHERE string
	*/
	public class WhereCondition extends Condition {
		private String conditionString;

		public WhereCondition(final String conditionString) {
			this.conditionString = conditionString;
		}

		public override String getConditionString() {
			return conditionString;
		}
	}

	/**
	*	Decorator for a group of conditions in the WHERE string
	*/
	public class WhereConditionGroup extends Condition {

		private List<Condition> conditions;
		private ConditionOperator conditionOp;

		public WhereConditionGroup(final List<Condition> conditions, final ConditionOperator conditionOp) {
			this.conditions = conditions;
			this.conditionOp = conditionOp;
		}

		public override String getConditionString() {
			String conditionOpName = getConditionOpName(this.conditionOp);
 			return '(' + buildWhereString(this.conditions, conditionOpName) + ')';
		}

		private String getConditionOpName(final ConditionOperator conditionOp) {
			if (conditionOp == ConditionOperator.OR_CONDITION) {
				return CONDITION_OR;
			}
			return CONDITION_AND;
		}
	}
}