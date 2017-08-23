/**************************************************************************************************
Name : PL_Constants
Description : Utility Class used for storing string constants accross Property Lab code base
Date : 06 Feb 2017
Author : Malay Desai
Last Modified By/Date/Description : Animesh Datta/15-May-2017/ SP54 - US1087049. Changed value of constant METRIC_NAME_1_1_SUPER_COACH_OBSERVATION and METRIC_NAME_FIELD_OBSERVATION_SUPER_COACH
Modified by: Amit Kumar
Date: 23 July 2017
Description: US1143300: XC DT - Update Sales Event Metrics
***************************************************************************************************/
public class PL_Constants{
    
    public static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    public static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    public static final String BATCH_JOB_NAME_FOR_CAR = 'PL_MonthlyGoalCreationBatch';
    public static final String BATCH_JOB_NAME_FOR_CARMGR = 'PL_CarMgrMonthlyGoalCreationBatch';
    public static final String BATCH_JOB_NAME_FOR_CARDIR = 'PL_CARDirectoryMonthlyGoalCreationBatch';
    public static final String BATCH_JOB_NAME_FOR_CARDIR_QUATERLY = 'PL_CARDirectorQuaterlyGoalCreationBatch';
    public static final String BATCH_JOB_NAME_FOR_CROSS_LEAD_CAR = 'CrossRegionCARGoalBatch';
    public static final String BATCH_JOB_NAME_FOR_CROSS_LEAD_XC = 'CrossRegionXCGoalBatch';
    public static final String MONTHLY_GOAL = 'Monthly - ';
    public static final String QUATERLY_GOAL = 'Quarterly - ';
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
    public static final String TEMPLATE_TYPE_COMMUNITIES = 'Xfinity Communities';
    public static final String GOAL_DATES_FOR_PROPERTY_LAB = 'Property Lab CAR';
    public static final String STRING_COUNT = 'CNT';
    
    public static final String PERM_SET_FOR_CAR_DIR_SR_MGR = 'Coach_CAR_Director_Manager';
    public static final set<String> GOALTYPE = new Set<String>{'% - PL - %'};
    
    public static final String METRIC_NAME_1_1_COACHING = '1:1 Coaching';   
    public static final String METRIC_NAME_OBSERVATION = 'Observations';
    public static final String METRIC_NAME_HUDDLES = 'Huddles';
    public static final String METRIC_TOTAL_VISITS_PER_MONTH = 'Total Property Visits per month';
    public static final String METRIC_AVG_VISITS_PER_DAY = 'Average Property Visits per day';
    public static final String METRIC_PROFILE_COMPLETION_PERCENT = 'Profile Completion Percent';
    public static final String METRIC_SALES_EVENT = 'Sales Event';
    public static final String METRIC_NAME_FORUM = 'Forum';
    public static final String METRIC_NAME_1_1_SUPER_COACH_OBSERVATION = '1:1 Observation';//US1087049 - SP54- Animesh - Changed value from "1:1 Super Coach Observation" to "1:1 Observation"
    public static final String METRIC_NAME_FIELD_OBSERVATION_SUPER_COACH = 'Field Observation';//US1087049 -SP54- Animesh - Changed value from "Field Observation Super Coach" to "Field Observation"
    public static final String METRIC_NAME_HUDDLE_OBSERVATION = 'Huddle Observation';
    
    public static final String PROPERTY_LAB_RECORD_TYPE_ID = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(Label.PL_MonthlyGoalCreationBatchGolTempType).getRecordTypeId();
    public static final String GOAL_TEMPLATE_RECORD_TYPE_ID = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(Label.Goal_Goal_Template_Recordtype).getRecordTypeId();
    public static final String XFINITY_COMMUNITIES_RECORD_TYPE_ID = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(System.Label.Goal_Xfinity_Communities_Recordtype).getRecordTypeId();
    /********************  START       US1143300: XC DT - Update Sales Event Metrics**********************************/
    public static final String PROPERTY_EVENT_STATUS = 'Completed';
    public static final String EVENT_CAR_ACTIVITY_TYPE = 'Event';
    public static final String EVENT_ACTIVITY = 'Sales'; 
    /********************  END       US1143300: XC DT - Update Sales Event Metrics**********************************/
}