/** 
    * @Description: This class will store the static Variables for Constants used in various Class   
    * @Author: Accenture
    * @Date: 03-Feb-2017 
    * @Param: NA
    * @return: NA
*/    
public class ConstantHandler {
    //String literals
    public final static String EMPTY_STRING = '';
    public final static String STR_ONE_ON_ONE_METRIC_NAME = 'OneonOneMetricName';
    public final static String STR_GOAL_STATUS = 'goalstatus';
    public final static String STR_METRIC_INCREASE_COUNTER = 'metricincreasecounter';
    public final static String STR_CAR_MANAGER_PERM_SET = 'CARManagerPermissionSet';
    public final static String STR_CAR_DIR_PERM_SET = 'CARDirPermissionSet';
    //US1090084 (Sagarika): Start
    public final static String STR_ADDR_MULTIPLEDWELLINGTYPE = 'MultipleDwellingUnit';
    public final static String STR_ADDR_MDU = 'MDU';
    public final static String STR_ACCT_DISCONNECT_NONPAY = 'AccountDisconnectReasonNonPay';
    //US1090084 (Sagarika): End
    //Start - Added by Animesh - SP53 - US1094059 - Date - 28-April-2017
    public final static String RETAIL_REP_PROFILE = 'RetailSalesRepProfileName';
    //End - Added by Animesh - SP53 - US1094059 - 28-April-2017
    //Start - US1027533 - Added by Animesh - SP53 - Date: 04-May-2017
    public final static String READ_ACCESS = 'ReadShareAccess';
    public final static String MANUAL_SHARE = 'ManualShare';
    public final static String MANAGER_GROUP = 'ManagerGroup';
    //End - US1027533 - Added by Animesh - SP53 - Date: 04-May-2017
    //Start - US1099361 - Added by Animesh - SP54 - Date: 15-May-2017
    public final static String BUSINESS_ADMIN_PROFILE = 'BusinessAdminProfile';
    //End - US1099361 - Added by Animesh - SP54 - Date: 15-May-2017
    //Start - US1096534 - Added by Amit K - SP54 - Date: 04-June-2017
    public final static String SHARED_DATA_USER = 'ShareDataUser';
    public final static String STR_CENTRAL = 'Centraldivision';
    public final static String STR_HSIONLY_NO = 'HSIOnly'; 
    public final static String STR_NORTHEAST = 'nedivision';
    public final static String STR_WEST = 'westdivision';
    //End - US990966 - Added by Amit K - SP54 - Date: 04-June-2017
    //Start - US990966 - Added by Sagarika - SP55 - Date: 02-Jun-2017
    public final static String STR_OPPORTUNITY_TRIGGER = 'OpportunityTrigger';
    public final static String STR_XFINITY_OPPORTUNITY_TRIGGER = 'XfinityOpportunityTrigger';
    //End - US990966 - Added by Sagarika - SP55 - Date: 02-Jun-2017
    public final static String STR_HSIONLY_YES = 'YES';
    public final static String STR_COMPLETEDOBSERVATIONPROFILES = 'CompletedObservationProfiles';//US1133821: Added by Kiran 
    //START***************************US1026408************************************************
    public final static String STR_APPCOMMASEPERATOR = 'AppCommaseperator';
    public final static String STR_APPDMLEXCEPTION = 'APPDMLException';
    public final static String STR_APPEXCEPTIONCONNECTOR = 'AppExceptionConnector';
    public final static String STR_APPEXCEPTIONCONNECTOR2 = 'AppExceptionConnector2';
    public final static String STR_APPLOGDELETEBATCHQUERY = 'AppLogPurgeQuery';
    public final static String STR_APPBATCHCLASSNAME = 'Appbatchdeletebatch';
    public final static String STR_CLASS = 'AppClass';
    public final static String STR_BATCHCLASS = 'AppBatchClass';
    public final static String STR_TRIGGER = 'AppTrigger';
    public final static String STR_APPLOGNONINTEGRATION = 'NonIntegrationLogRecordType';
    //END***************************US1026408************************************************
    //Start - Added by Animesh - SP58 - US1137734 - 11-July-2017
    public final static String PROPERTY_VISIT_COMPLETED = 'PropertyVisitCompleted';
    //End - Added by Animesh - SP58 - US1137734 - 11-July-2017
    
    //Use this class to store Hard Coding values instead of Labels.
    // Use the Custom Setting - 'Variable_Setting__c' to get the instance value.
    
    public final static String oneonOneMetricName = Variable_Setting__c.getInstance(STR_ONE_ON_ONE_METRIC_NAME) != null ? Variable_Setting__c.getInstance(STR_ONE_ON_ONE_METRIC_NAME).Value__c : EMPTY_STRING; //1:1 Metric Name 
    public final static String goalstatues = Variable_Setting__c.getInstance(STR_GOAL_STATUS) != null ? Variable_Setting__c.getInstance(STR_GOAL_STATUS).Value__c : EMPTY_STRING; //goal status considered for metric update
    public final static String metricincreasecounter = Variable_Setting__c.getInstance(STR_METRIC_INCREASE_COUNTER) != null ? Variable_Setting__c.getInstance(STR_METRIC_INCREASE_COUNTER).Value__c : EMPTY_STRING; //goal status considered for metric update  
    public final static String carmanagerpermissionSet = Variable_Setting__c.getInstance(STR_CAR_MANAGER_PERM_SET) != null ? Variable_Setting__c.getInstance(STR_CAR_MANAGER_PERM_SET).Value__c : EMPTY_STRING; //CAR Manager Permission Set
    public final static String cardirrpermissionSet = Variable_Setting__c.getInstance(STR_CAR_DIR_PERM_SET) != null ? Variable_Setting__c.getInstance(STR_CAR_DIR_PERM_SET).Value__c : EMPTY_STRING; //CAR Manager Permission Set
    public final static String indirectobsrecordtypename = Variable_Setting__c.getInstance('Indirect_Observation') != null ? Variable_Setting__c.getInstance('Indirect_Observation').Value__c : EMPTY_STRING; //CAR Manager Permission Set
    //US1090084 (Sagarika): Start
    public final static String multipleDwellingUnitDwellingType = Variable_Setting__c.getInstance(STR_ADDR_MULTIPLEDWELLINGTYPE) != null ? Variable_Setting__c.getInstance(STR_ADDR_MULTIPLEDWELLINGTYPE).Value__c : EMPTY_STRING; //Address : Multiple Dwelling Unit
    public final static String mduDwellingType = Variable_Setting__c.getInstance(STR_ADDR_MDU) != null ? Variable_Setting__c.getInstance(STR_ADDR_MDU).Value__c : EMPTY_STRING; //Address : Multiple Dwelling Unit
    public final static String nonPayAcctDisconnReason = Variable_Setting__c.getInstance(STR_ACCT_DISCONNECT_NONPAY) != null ? Variable_Setting__c.getInstance(STR_ACCT_DISCONNECT_NONPAY).Value__c : EMPTY_STRING; //Account Disconnect Reason Non Pay
    //US1090084 (Sagarika): End
    //Start - Added by Animesh - SP53 - US1094059 - Date - 28-April-2017
    public final static String RETAIL_SALES_REP_PROFILE_NAME = Variable_Setting__c.getInstance(RETAIL_REP_PROFILE) != null ? Variable_Setting__c.getInstance(RETAIL_REP_PROFILE).Value__c : EMPTY_STRING;//Added by Animesh - User Story US1094059 - SP53 - Get "Retail Sales Rep" Profile Name from variable settings custom settings. Used in class WalkalongUtilsReadOnly. Can be reused for future needs
    //End - Added by Animesh - SP53 - US1094059 - 28-April-2017
    //Start - US1027533 - Added by Animesh - SP53 - Date: 04-May-2017 - Sharing record records in Read Only mode with Manager Group Manually. Keeping hard coded values.
    public final static String SHARE_READ_ACCESS = Variable_Setting__c.getInstance(READ_ACCESS) != null ? Variable_Setting__c.getInstance(READ_ACCESS).Value__c : EMPTY_STRING;//Value = "Read"
    public final static String SHARING_REASON_MANUAL = Variable_Setting__c.getInstance(MANUAL_SHARE) != null ? Variable_Setting__c.getInstance(MANUAL_SHARE).Value__c : EMPTY_STRING;//Value = "Manual"
    public final static String MANAGER_GROUP_SHARING = Variable_Setting__c.getInstance(MANAGER_GROUP) != null ? Variable_Setting__c.getInstance(MANAGER_GROUP).Value__c : EMPTY_STRING;//Value = "Manager"
    //End - US1027533 - Added by Animesh - SP53 - Date: 04-May-2017 
    //Start - US1099361 - Added by Animesh - SP54 - Date: 15-May-2017
    public final static String BUSINESS_ADMIN_PROFILE_NAME = Variable_Setting__c.getInstance(BUSINESS_ADMIN_PROFILE) != null ? Variable_Setting__c.getInstance(BUSINESS_ADMIN_PROFILE).Value__c : EMPTY_STRING;//Value = "Business Administrator"
    //End - US1099361 - Added by Animesh - SP54 - Date: 15-May-2017
    //Start - US1099361 - Added by Amit K - SP54 - Date: 04-June-2017
    public final static String SHARED_DATA_USER_NAME = Variable_Setting__c.getInstance(SHARED_DATA_USER) != null ? Variable_Setting__c.getInstance(SHARED_DATA_USER).Value__c : EMPTY_STRING;//Value = "Shared Data User"
    public final static String STR_CENTRAL_NAME = Variable_Setting__c.getInstance(STR_CENTRAL) != null ? Variable_Setting__c.getInstance(STR_CENTRAL).Value__c : EMPTY_STRING;//Value = "Central"
    public final static String STR_HSIONLY_NO_VAL = Variable_Setting__c.getInstance(STR_HSIONLY_NO) != null ? Variable_Setting__c.getInstance(STR_HSIONLY_NO).Value__c : EMPTY_STRING;//Value = "No"
    public final static String STR_NORTHEAST_NAME = Variable_Setting__c.getInstance(STR_NORTHEAST) != null ? Variable_Setting__c.getInstance(STR_NORTHEAST).Value__c : EMPTY_STRING;//Value = "Northeast"
    public final static String STR_WEST_NAME = Variable_Setting__c.getInstance(STR_WEST) != null ? Variable_Setting__c.getInstance(STR_WEST).Value__c : EMPTY_STRING;//Value = "West"
    //End - US1099361 - Added by Amit K - SP54 - Date: 04-June-2017
    //Start - US990966 - Added by Sagarika - SP55 - Date: 02-Jun-2017
    public final static String OPPORTUNITY_TRIGGER = Variable_Setting__c.getInstance(STR_OPPORTUNITY_TRIGGER) != null ? Variable_Setting__c.getInstance(STR_OPPORTUNITY_TRIGGER).Value__c : STR_OPPORTUNITY_TRIGGER;//Value = "OpportunityTrigger"
    public final static String XFINITY_OPPORTUNITY_TRIGGER = Variable_Setting__c.getInstance(STR_XFINITY_OPPORTUNITY_TRIGGER) != null ? Variable_Setting__c.getInstance(STR_XFINITY_OPPORTUNITY_TRIGGER).Value__c : STR_XFINITY_OPPORTUNITY_TRIGGER;//Value = "XfinityOpportunityTrigger"
    //End - US990966 - Added by Sagarika - SP55 - Date: 02-Jun-2017
    //Start - US1097310 - Added by Kiran
     public final static String STR_HSIONLY_YES_VAL = Variable_Setting__c.getInstance(STR_HSIONLY_YES) !=null ? Variable_Setting__c.getInstance(STR_HSIONLY_YES).Value__c : STR_HSIONLY_YES ;//Value = "YES" 
     //END - US1097310 - Added by Kiran
     //START-US1133821: Added by Kiran
     public final static String STR_COMPLETED_OBSERVATION_PROFILES = Variable_Setting__c.getInstance(STR_COMPLETEDOBSERVATIONPROFILES ) != null ? Variable_Setting__c.getInstance(STR_COMPLETEDOBSERVATIONPROFILES ).Value__c : STR_COMPLETEDOBSERVATIONPROFILES ;//Value = "XC Manager,CAR/XC Regional Lead"
     //END-US1133821: Added by Kiran
     //START***************************US1026408************************************************
     public final static String APPCOMMASEPERATOR = Variable_Setting__c.getInstance(STR_APPCOMMASEPERATOR ) != null ? Variable_Setting__c.getInstance(STR_APPCOMMASEPERATOR ).Value__c : STR_APPCOMMASEPERATOR ;
     public final static String APPDMLEXCEPTION = Variable_Setting__c.getInstance(STR_APPDMLEXCEPTION ) != null ? Variable_Setting__c.getInstance(STR_APPDMLEXCEPTION ).Value__c : STR_APPDMLEXCEPTION ;
     public final static String APPEXCEPTIONCONNECTOR = Variable_Setting__c.getInstance(STR_APPEXCEPTIONCONNECTOR ) != null ? Variable_Setting__c.getInstance(STR_APPEXCEPTIONCONNECTOR ).Value__c : STR_APPEXCEPTIONCONNECTOR ;
     public final static String APPEXCEPTIONCONNECTOR2 = Variable_Setting__c.getInstance(STR_APPEXCEPTIONCONNECTOR2 ) != null ? Variable_Setting__c.getInstance(STR_APPEXCEPTIONCONNECTOR2 ).Value__c : STR_APPEXCEPTIONCONNECTOR2 ; 
     public final static String APPLOGDELETEBATCHQUERY = Variable_Setting__c.getInstance(STR_APPLOGDELETEBATCHQUERY ) != null ? Variable_Setting__c.getInstance(STR_APPLOGDELETEBATCHQUERY ).Value__c : STR_APPLOGDELETEBATCHQUERY ;
     public final static String APPBATCHCLASSNAME = Variable_Setting__c.getInstance(STR_APPBATCHCLASSNAME ) != null ? Variable_Setting__c.getInstance(STR_APPBATCHCLASSNAME ).Value__c : STR_APPBATCHCLASSNAME ;
     public final static String STR_CLASS_CODE = Variable_Setting__c.getInstance(STR_CLASS ) != null ? Variable_Setting__c.getInstance(STR_CLASS ).Value__c : STR_CLASS ;
     public final static String STR_BATCHCLASS_CODE = Variable_Setting__c.getInstance(STR_BATCHCLASS ) != null ? Variable_Setting__c.getInstance(STR_BATCHCLASS ).Value__c : STR_BATCHCLASS ;
     public final static String STR_TRIGGER_CODE = Variable_Setting__c.getInstance(STR_TRIGGER ) != null ? Variable_Setting__c.getInstance(STR_TRIGGER ).Value__c : STR_TRIGGER ;
     public final static String APPLOGNONINTEGRATION = Variable_Setting__c.getInstance(STR_APPLOGNONINTEGRATION ) != null ? Variable_Setting__c.getInstance(STR_APPLOGNONINTEGRATION ).Value__c : STR_APPLOGNONINTEGRATION ;
      public final static Id nonintegrationRTypeId = Schema.SObjectType.Application_Log__c.getRecordTypeInfosByName().get(ConstantHandler.APPLOGNONINTEGRATION).getRecordTypeId();
     //END***************************US1026408************************************************
    //Start - Added by Animesh - SP58 - US1137734 - 11-July-2017
    public final static String PROPERTY_VISIT_COMPLETED_STATUS = Variable_Setting__c.getInstance(PROPERTY_VISIT_COMPLETED) != null ? Variable_Setting__c.getInstance(PROPERTY_VISIT_COMPLETED).Value__c : EMPTY_STRING;
    //End - Added by Animesh - SP58 - US1137734 - 11-July-2017
}