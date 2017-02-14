/**************************************************************************************************
Name : PL_Constants
Description : Utility Class used for storing string constants accross Property Lab code base
Date : 06 Feb 2017
Author : Malay Desai
***************************************************************************************************/
public class PL_Constants{
	
	public static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    public static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    public static final String BATCH_JOB_NAME_FOR_CAR = 'PL_MonthlyGoalCreationBatch';
    public static final String BATCH_JOB_NAME_FOR_CARMGR = 'PL_CarMgrMonthlyGoalCreationBatch';
    public static final String BATCH_JOB_NAME_FOR_CARDIR = 'PL_CARDirectoryMonthlyGoalCreationBatch';
    public static final String JOB_STATUS_NEW = 'New';
    public static final String NEW_LINE = '\n';
    public static final String SYSTEM_EXCEPTION = 'System Exception - ';    
    public static final String RECORD_TYPE_SEPERATION = ';';
    public static final String JOB_COMMENT = ' ';
    public static final String JOB_NAME_SPACE =  ' - ';
    public static final String DATE_DELIMIT =  '-';
    public static final String PROPERTY_LAB =  ' - PL - ';
    
    public static final String PROFILE_ID_SEPERATION = ';';  
    public static final String QUERY_INITIAL = '';
    public static final String GOAL_STATUS_COMPLETE = 'Completed'; 
    public static final String GOAL_STATUS_PUBLISHED = 'Published';
    public static final String METRIC_STATUS_NOTSTARTED = 'NotStarted';
    public static final String TEMPLATE_TYPE_PROPERTYLAB = 'Property Lab';
    public static final String STRING_COUNT = 'CNT';
    
    public static final String PERM_SET_FOR_CAR_DIR_SR_MGR = 'Coach_CAR_Director_Manager';
    public static final set<String> GOALTYPE = new Set<String>{'% - PL - %'};
    
    public static final String PROPERTY_LAB_RECORD_TYPE_ID = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(Label.PL_MonthlyGoalCreationBatchGolTempType).getRecordTypeId();
    public static final String GOAL_TEMPLATE_RECORD_TYPE_ID = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(Label.Goal_Goal_Template_Recordtype).getRecordTypeId();

}