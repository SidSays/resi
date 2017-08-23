/**
*	Static utility methods for store visit functionality
*
*	@author	Sahil Grover	<sgrover@acumensolutions.com>
*/
public with sharing class StoreVisitUtility {

	public static final String VISIT_STATUS_ACTIVE = 'Active';
	public static final String VISIT_STATUS_PENDING = 'Pending';
	public static final String VISIT_STATUS_COMPLETE = 'Complete';
	public static final String STORE_FIELD_NAME = 'Store__c';
	public static final String RGU_ORDER_STORE_ID = 'Store_ID__c';
	public static final String RECORD_TYPE_DEV_NAME = 'Store';

	private static final Integer MS_IN_HOUR = 1000 * 60 * 60;
	private static final Integer MS_IN_MINUTE = 1000 * 60;
	private static final Integer MS_IN_SECOND = 1000;

	/**
	*	Returns the unique set of string values for a field in a list of SObject records
	*
	*	@param	records			The SObject records to pull field values from
	*	@param	fieldApiName	The API name of the field to get values from
	*
	*	@return	Returns a unique set of string values from the specified field
	*/
	public static Set<String> getFieldSet(final List<SObject> records, final String fieldApiName) {
		Set<String> fieldValues = new Set<String>();
		for (SObject record : records) {
			fieldValues.add((String)record.get(fieldApiName));
		}
		return fieldValues;
	}

	public static Map<String, RecordType> buildRecordTypeNameMap(final List<RecordType> recordTypes) {
		Map<String, RecordType> recordTypeMap = new Map<String, RecordType>();
		for (RecordType recType : recordTypes) {
			recordTypeMap.put(recType.DeveloperName, recType);
		}
		return recordTypeMap;
	}

	/**
	*	Converts a duration in ms to display as "X hours, Y minutes, and Z seconds"
	*
	*	@param	durationMs	The duration in ms
	*
	*	@return	Returns the duration displayed as a human readable string
	*/
	public static String convertMsToTimeDisplay(final Long durationMs) {
		Integer hours = (Integer)(durationMs / MS_IN_HOUR);
		Long msLeftover = durationMs - (hours * MS_IN_HOUR);
		Integer minutes = (Integer)(msLeftover / MS_IN_MINUTE);
		msLeftover = msLeftover - (minutes * MS_IN_MINUTE);
		Integer seconds = (Integer)(msLeftover / MS_IN_SECOND);

		return String.format('{0}:{1}:{2}', new List<String>{
			String.valueOf(hours),
			String.valueOf(minutes).leftPad(2, '0'),
			String.valueOf(seconds).leftPad(2, '0')
			});
	}

	public static Integer convertMsToMinutes(final long durationMs) {
		return (Integer)durationMs / MS_IN_MINUTE;
	}

	/**
	*	Creates a map of field values to their corresponding SObject records
	*
	*	@param	records			The list of records to build the map from
	*	@param	fieldApiName	The API name of the field to use as the key for the map
	*
	*	@return	Returns a Map where the key is the value of the entered field API name, and the value is the list of records with that field value
	*/
	public static Map<String, List<SObject>> buildFieldSetMap(final List<SObject> records, final String fieldApiName) {
		Map<String, List<SObject>> fieldSetMap = new Map<String, List<SObject>>();
		for (SObject record : records) {
			String fieldValue = String.valueOf(record.get(fieldApiName));
			if (fieldSetMap.get(fieldValue) == null) {
				fieldSetMap.put(fieldValue, new List<SObject>{record});
			} else {
				fieldSetMap.get(fieldValue).add(record);
			}
		}
		return fieldSetMap;
	}

	public static Set<String> getAllFields(String objectName) {
		Map<String, Schema.SObjectField> fieldMap = 
			Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();

		Set<String> fields = new Set<String>();
		for (Schema.SObjectField sobjectField : fieldMap.values()) {
			Schema.DescribeFieldResult fieldDescribe = sobjectField.getDescribe();
			fields.add(fieldDescribe.getName());
		}
		return fields;
	}

	public static String getSchedulerExpression(DateTime scheduleDateTime) {
		Integer second = scheduleDateTime.second();
		Integer minute = scheduleDateTime.minute();
		Integer hour = scheduleDateTime.hour();
		Integer dayOfMonth = scheduleDateTime.day();
		Integer month = scheduleDateTime.month();
		String dayOfWeek = '?';
		Integer year = scheduleDateTime.year();
		return ''
			+ second + ' '
			+ minute + ' '
			+ hour + ' '
			+ dayOfMonth + ' '
			+ month + ' '
			+ dayOfWeek + ' '
			+ year + ' ';
	}
    
    /**
    *   Add an error message to a VF Page
    *   
    *   @param  message The error message to display to the user
    */
    public static void addErrorMessage(final string message) {
        addMessage(message, ApexPages.Severity.ERROR);
    }

    /**
    *   Add a warning message to a VF Page
    *   
    *   @param  message The warning message to display to the user
    */
    public static void addWarningMessage(final string message) {
        addMessage(message, ApexPages.Severity.WARNING);
    }

    /**
    *   Add an info message to a VF Page
    *   
    *   @param  message The info message to display to the user
    */
    public static void addInfoMessage(final string message) {
        addMessage(message, ApexPages.Severity.INFO);
    }

    /**
    *   Add a confirm message to a VF Page
    *   
    *   @param  message The confirm message to display to the user
    */
    public static void addConfirmMessage(final string message) {
        addMessage(message, ApexPages.Severity.CONFIRM);
    }

    /**
    *   Add a page message to a VF page
    *   
    *   @param  message     The message to display to the user
    *   @param  severity    Apex message severity
    */
    public static void addMessage(final string message, final ApexPages.Severity severity) {
        ApexPages.addMessage( new ApexPages.Message(severity, message) );
    }

	// this is the only way to get the current datetime in the local timezone
    public static DateTime getLocalTimeFromGmt(DateTime gmtDateTime) {
        DateTime nowGmt = DateTime.newInstanceGmt(gmtDateTime.date(), gmtDateTime.time());  // specify datetime as GMT
        return DateTime.valueOf(
           nowGmt.format('YYYY-MM-dd HH:mm:ss') // format returns time formatted in local timezone
            );
    }
}