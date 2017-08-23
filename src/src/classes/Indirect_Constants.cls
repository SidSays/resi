/**************************************************************************************************
Name : Indirect_Constants
Description : Utility Class used for storing string constants accross Indirect code base
Date :   21/03/2017
Author : Tejaswini Kasar
***************************************************************************************************/
public class Indirect_Constants{
    
    public static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    public static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    public static final String BATCH_JOB_NAME_FOR_INDIRECT = 'IndirectMonthlyGoalCreationBatch';
    public static final String BATCH_JOB_NAME_FOR_MGR_ACTIVITY = 'IndirectRetailManagerActivityGoalBatch';
    public static final String BATCH_JOB_NAME_FOR_INDIRECT_COMPLETE_PREVIOUS_RGU_GOAL = 'IndirectCompletePreviousRguGoalsBatch';
    public static final String MONTHLY_GOAL = 'Monthly - ';
    public static final String QUARTERLY_GOAL = 'Quarterly - ';
    public static final String JOB_STATUS_NEW = 'New';
    public static final String NEW_LINE = '\n';
    public static final String SYSTEM_EXCEPTION = 'System Exception - ';    
    public static final String RECORD_TYPE_SEPERATION = ';';
    public static final String JOB_COMMENT = ' ';
    public static final String JOB_NAME_SPACE =  ' - ';
    public static final String DATE_DELIMIT =  '-';
    public static final String CUSTOMSET_INDIRECT =  'Indirect';
    
    public static final String PROFILE_ID_SEPERATION = ';';  
    public static final String QUERY_INITIAL = '';
    public static final String GOAL_STATUS_COMPLETE = 'Completed'; 
    public static final String GOAL_STATUS_PUBLISHED = 'Published';
    public static final String METRIC_STATUS_NOTSTARTED = 'NotStarted';
    public static final String DATE_FORMAT_STR = 'MMM-yyyy';
    public static final String REP_COUNT = 'Rep';
    public static final String RETAIL_SALES_REP_PROFILE = System.Label.Retail_Sales_Rep_ProfileName;
    
    public static final String ACTIVITY_TEMPLATE = '-Activity-';
    public static final String RGU_TEMPLATE = '-RGU-';
    public static final String ACTIVITY_STRING = 'Activity';
    public static final String RGU_STRING = 'RGU';
    public static final set<String> GOALTYPE = new Set<String>{'%RGU%', '%Activity%'};
    public static final set<String> GOALACTIVITYTYPE = new Set<String>{'%Activity%'};
    public static final String METRIC_TOTAL_NUMBER_OF_STORE_VISITS_PER_MONTH = 'Total Number of Store Visits';
    public static final String METRIC_AVG_STORE_VISIT_DURATION = 'Average Store Visit Duration';
    public static final string INDIRECT_MONTHLY_CS_RECORD = 'IndirectActivityGoalCycle';
    public static final string INDIRECT_RET_REP_RGU_CS_RECORD = 'IndirectRetRepRguGoalCycle';
    public static final string INDIRECT_MONTHLY_RGU_RECORD = 'IndirectPreviousRguGoalCycle';
    public static final string INDIRECTACTIVITYGOALCOMMISSIONCYCLE = 'IndirectActivityGoalCommissionCycle';
    public static final string INDIRECT_RET_MGR_RGU_GOALCOMMISSIONCYCLE = 'IndirectRetMgrRguGoalCommissionCycle';
    public static final String INDIRECT_RECORD_TYPE_ID = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(Label.Indirect_Record_Type).getRecordTypeId();
    public static final String GOAL_TEMPLATE_RECORD_TYPE_ID = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(Label.Goal_Goal_Template_Recordtype).getRecordTypeId();
   

}