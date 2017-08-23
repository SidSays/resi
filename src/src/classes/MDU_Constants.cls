/************************************************************************************************************************************************************
    Name: MDU_Constants 
    Description: This is constants class to hold Emptoris request constant values.
    Author: Accenture
    Date PRJ/DFCT/ENHC# Summary of Changes 
    --------------- ------------------ ------------------------------
    16 Feb 2015 Comcast  
* @Last modified By: Sagarika
* @Last modified Date: 07-Aug-2017 
* @Description : Adding constant SEMI_COLON
* @User Story : US1132755: XC LI - Premium Channels Launch Interview
    *************************************************************************************************************************************************************/
    public class MDU_Constants{
    
        /*
        * Variable values declaration
        */
        public static final String ERROR = 'ERROR:';
        public static final String OPERATION = 'Equals';
        public static final String ID = 'id';
        public static final String HOSTSTR = 'hostStr';
        public static final String SOURCESTR = 'sourceStr';
        public static final String ALGOSTR = 'algoStr';
        public static final String SHARED_SECRET = 'SHARED SECRET';
        public static final String MD5 = 'MD5';
        public static final String COLON = ':';
        //US1132755: START : XC LI - Premium Channels Launch Interview 
        public static final String SEMI_COLON = ';';
        //US1132755: END : XC LI - Premium Channels Launch Interview 
        public static final String DATEFORMAT = 'MMMM dd, yyyy hh:mm:ss a';
        public static final String DATEFORMAT_SSM = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        public static final String LAUNCH_EMPTORIS_URL_ENDPOINT = 'LAUNCH_EMPTORIS_URL_ENDPOINT';
        public static final String SEARCH_INDIVIDUAL_ENDPOINT = 'SEARCH_INDIVIDUAL_ENDPOINT';
        public static final String CREATE_INDIVIDUAL_ENDPOINT = 'CREATE_INDIVIDUAL_ENDPOINT';
        public static final String SEARCH_INTERVIEW_ENDPOINT = 'SEARCH_INTERVIEW_ENDPOINT';
        public static final String BUILD_SSO_URL_WIZARD_ENDPOINT = 'BUILD_SSO_URL_WIZARD_ENDPOINT';
        public static final String CREATE_INTERVIEW_ENDPOINT = 'CREATE_INTERVIEW_ENDPOINT';
        public static final String GETCONTRACTUSER_ENDPOINT = 'GETCONTRACTUSER_ENDPOINT';
        public static final String GETCONTRACT_DETAILS_ENDPOINT = 'GETCONTRACT_DETAILS_ENDPOINT';
        public static final String DELETE_CONTRACT_ENDPOINT = 'DELETE_CONTRACT_ENDPOINT';
        public static final String GET_CONTRACT_URL_ENDPOINT = 'GET_CONTRACT_URL_ENDPOINT';
        public static final String EMPTORISORGID = 'EmptorisOrgID';
        public static final String EMPTORISACCOUNT = 'EmptorisAccount';
        public static final String USERTODELETECONTRACT = 'usertodeletecontract';
        
        
        /*
        * Request values declaration
        */
        public static final String POST = 'POST';
        public static final String CONTENT_TYPE = 'Content-Type';
        public static final String TEXT_XML_CHARSET_UTF_8 = 'text/xml; charset=UTF-8';
        public static final String ACCEPT = 'Accept';
        public static final String TEXT_XML = 'text/xml';
        public static final String SOAPACTION = 'Soapaction';
        
        /*
        * Request values declaration
        */
        public static final String BLANKHEADER = '""';
        public static final String COMPANY_TYPE = 'Other';
        public static final String COMPANY_NUMBER = 'vsadvdsv@dfhds.fdhdsf';
        public static final String STATUS = 'status';
        public static final String ACTIVE = 'Active';
        //Changes
        public static final String DEFAULTWIZARDMODE = 'BASIC';
        public static final String FIRSTDAYOFTHEWEEK = 'Monday';
        public static final String LANDINGPAGE = 'Search - Homepage tab';
        public static final String ECM = 'ECM';
        public static final String INTERNALID = '4';
      
        /*
        * Authentication values declaration
        */
        public static final String PORT_NUMBER = '80';
        public static final String HOST_URL = 'HOST_URL';
        public static final String SSORESUMEWIZARDID = 'SSOResumeWizardId';
        public static final String SSORESUMEFIRSTSTEP = 'SSOResumeFirstStep';
        
        public static final String TRUE_STRING = 'true';
        public static final String GET_URL_RESPONSE = 'get-url-response';
        public static final String GET_CONTRACT_RESPONSE = 'get-response';
            
        /*
        * Template values declaration
        */
        public static final String MOBILE_HOME = 'Mobile Home';
        public static final String SINGLE_FAMILY = 'Single Family';
        public static final String MULTI_FAMILY = 'Multi Family';
        public static final String HOSPITALITY = 'Hospitality';
        public static final String HEALTHCARE = 'Healthcare';
        public static final String GOVERNMENT = 'Government';
        public static final String EDUCATION = 'Education';
        public static final String COMMERCIAL = 'Commercial';
        
        /*
        * Data String values declaration
        */
        public static final String NULL_STRING = 'null';
        public static final String CREATE_RESPONSE = 'create-response';
        public static final String MDU = 'mdu';
        public static final String LEFT_PARENTHISYS = ')';
        public static final String NEXT_LINE_OPERATOR = '\n';
        public static final String BULK_TYPE = 'Bulk';
        public static final String RETAIL_TYPE = 'Retail';
        public static final String COMMENT = 'Comment (';
        public static final String RIGHT_PARENTHISYS = ')';
        public static final String TEXT = 'Text (';
        public static final String FAULT_CODE = 'Fault Code:';
        public static final String ERROR_MESSAGE_STRING = 'Error Message :';
        public static final String SEMICOLON = ';';
        
        /*
        * Data String values declaration
        */
        public static final String MDU_CONFIRM_PROPERTY = 'mdu_confirm_property';
        public static final String MDU_CONFIRM_OPTY = 'mdu_confirm_opp';
        public static final String INDUSTRY_TYPE = ' Industry Type: ';
        public static final String PROPERTY_TYPE = ' Property Type: ';
        public static final String FRANCHISE_NAME = ' Franchise Name: ';
        public static final String UTF8 = ' UTF-8';
        public static final String COMCAST_CABLE = 'Comcast Cable';
        public static final String SERVICE_TYPE = 'Service Type: ';
        public static final String TOTAL_CONTRACT_VALUE = 'Total Contract Value: ';
        public static final String BULK_DISCOUNT_RATE = 'Bulk Discount Rate: ';
        public static final String CONTRACT_TERM = 'Contract Term: ';
        public static final String CONTRACT_TERM_UNIT = 'Contract Term Unit: ';
        public static final String NO = 'No';
        public static final String YES = 'Yes';
        
        /*
        * Contact values declaration
        */
        public static final String CONTACT_FIRST_NAME = 'Contact First Name: ';
        public static final String LAST_NAME = 'Last Name: ';
        public static final String CONTACT_EMAIL = 'Contact Email: ';
        
        /*
        * Mdu Resi template data declaration
        */
        public static final String MDU_RESIDENTIAL = 'mdu_residential';
        public static final String MDU_EDUCATION = 'mdu_education'; 
        public static final String MDU_RESIDENTIAL_SFU = 'mdu_residential_sfu'; 
        public static final String MDU_HOSPITALITY = 'mdu_hospitality'; 
        public static final String MDU_HEALTHCARE = 'mdu_healthcare'; 
        public static final String TEMPLATE_DESCRIPTION = 'Use for stesting purposes. Created off of ';
        public static final String TEMPLATE = ' template.';
        public static final String NUMBER_OF_UNITS  = ' Number Of Units: ';
        public static final String CONTRACT_DOCUMENT_REVIEW  = 'Contract Document Review';
        public static final Integer SUCCESSSTATUSCODE = 200;
        public static final String MDU_INDUSTRY_GOVERNMENT = 'Government'; 
        
        /*
        * Request param values declaration
        */
        public static final String MODULE = 'Module';
        public static final String HOMEPAGE = 'HomePage';
        public static final String USERTYPE = 'UserType';
        public static final String ADV = 'adv';
        public static final String USERHOST = 'UserHost';
        public static final String LOGIN = 'login';
        public static final String PROTOCOL = 'https';
        
        /*
        * Response parsing values declaration
        */
        public static final String FAULTCODE= 'faultcode';
        public static final String FAULTSTRING= 'faultstring';
        public static final String PRIMARY_CONTACT_ID = 'primary-contact-id';
        public static final String USERGROUPS = 'usergroups';   
        
        /* 
        * START: CONSTANTS FOR  MDU_ContractWriteBack Batch
        */
        public static final string NODE_TO_FIND = 'id';
        public static final string TERM_LABEL = 'label';
        public static final string TERM_TYPE = 'type';
        public static final string TERM_NAME = 'name';
        public static final string TERM_VALUE = 'value';
        public static final string TERM_REFERENCE_FOR_NAME = 'reference';
        public static final string TERM_STRING_VALUE = 'string-value';
        public static final string TERM_DATE_VALUE = 'date-value';
        public static final string TERM_NUMBER_VALUE = 'number-value';           
        public static final string DECIMAL_TYPE = 'decimal';
        public static final string DATE_TYPE = 'date';
        public static final string NUMBER_TYPE = 'number';
        public static final string STRING_TYPE = 'string';
        public static final string MDUCONTRACT_DIRECT_TYPE = 'MDUContract';
        public static final string PROPERTY_FEE_DIRECT_TYPE = 'MDUContractPropertyFee';
        public static final string CONTRCT_BULKSERVICE_DIRECT_TYPE = 'MDUContractBulkServiceType';
        public static final string BULK_SERVIC_TYPE_NAME = 'bulk_service_type';
        public static final string BULK_SERVIC_TYPE_HOSPITALITY_NAME = 'bulk_service_type_hospitality';
        public static final string COURTESY_ACCOUNT_INTERNAL_NAME = 'coutesy_account_type';
        public static final string VIDEO_SUBS_VARIABLE_NAME = 'Video Subs';
        public static final string DATA_SUBS_VARIABLE_NAME =  'Data Subs';
        public static final string VOICE_SUBS_VARIABLE_NAME = 'Voice Subs';
        public static final string CHW_INSTALL_INTERNAL_NAME = 'chw_will_be_installed_by';
        public static final string CHW_WIRING_INTERNAL_NAME = 'chrw_wiring';   
        public static final string AUTORENEW_TERMNOTICE_INTERNAL_NAME = 'Auto-Renew Termination Notice Period';
        public static final string AUTORENEW_LIMIT_INTERNAL_NAME = 'Auto Renew Limit';
        public static final string PROPERTY_ID = 'property_id';
        public static final string OPPORTUNITY_ID = 'opportunity_id';
        public static final string DOOR_FEES_OBJECT_PROPERTY = 'Door_Fees';
        public static final string RECIRRING_FEES_OBJECT_PROPERTY = 'Recurring_Fees';
        public static final string YES_FLAG = 'Yes';
        public static final string NO_FLAG = 'No';
        public static final string CHANNEL_AGREEMENT_INTERNAL_NAME = 'insertion_channel_agreement';
        public static final string EQUIPMNT_QUANTITY_DCT_INTERNAL_NAME = 'equipment_quantity_dct';
        public static final string EQUIPMNT_QUANTITY_DTA_INTERNAL_NAME = 'equipment_quantity_dta';
        public static final string SPLIT_TREM_BY = ' ';
        public static final string DEFAULT_HOME_PAID_BY = 'Pre-Existing';
        public static final string BLANK_VALUE = '';
        public static final string SFDC_DAYS_CANCEL_API = 'Days_to_Cancel__c';
        public static final string EFF_START_DATE_INT_NAME = 'effective_start_date';
        public static final string DEF_SUBSTATUS = 'New';
        public static final string COMACAST_USER = 'Comcast';
        public static final string EXISTING_CONST = 'Existing';
        public static final string OWNER_CONST = 'Owner';
        public static final string INSTALL_CONST = 'Install';
        public static final string DOOR_FEE = 'Door Fee';
        public static final string RECURRING_FEE = 'Recurring Fee';
        public static final string FLAT_RATE = 'Flat Rate';
        public static final string SLIDING_RATE = 'Sliding Scale';
        public static final string UNIT_TERM = 'Years';
        public static final string CERT_OFINSURANCE_INT_NAME = 'certificate_of_insurance';
        public static final string CERT_INSU_RESP_VALUE  = '@Comcast Signing';
        public static final string CERT_INSU_SFDC_VALUE  = 'Comcast Signing';
        public static final string ASSIGN_INTERNAL_NAME = 'assignability_type';
        public static final string DEFAULT_ASSIGN_ID = 'Unrestricted';
        public static final string REWIRE_CONST = 'Rewire';
        public static final string CHW_WIRING_CONST = 'chw_wiring';
        public static final string DIG_VIDEO_EQPMNT_INT_NAME = 'digital_video_equipment';
        public static final string DIR_SALE_PERMIT_INT_NAME = 'direct_sales_permitted';
        public static final string DTA_DCT_INT_NAME = 'DTA and DCT';
        public static final string DTA_DCT_SFDC_VALUE_NAME = 'DTA & DCT';
        public static final string DIRECT_SALE_PERMIT_VALUE = 'selling';
        public static final string HOME_INSTRUMENT_OWNER_RESP_VALUE = 'Individual Unit Resident';
        public static final string HOME_INSTRUMENT_OWNER_SFDC_VALUE = 'Individual Resident';
        public static final string EXCLUSIVE_MARKETING_RIGHT = 'Exclusive';
        public static final string NONEXCLUSIVE_MARKETING_RIGHT = 'Non-Exclusive';
        public static final string NORIGHT_MARKETING_RIGHT = 'No Rights';
        public static final string MARKETING_RIGHT_RESP_VALUE = 'non exclusive';
        public static final string ASSOCIATE_DEV_USER = 'Association/Developer';
        public static final string INDIVIDUAL_RESIDENT_USER = 'Individual Resident';
        public static final string TERMS_NODE = 'terms';
        public static final string RESPONSEDATA_NODE = 'response-data';
        public static final string CONTRACTLANG_NODE = 'contract-language';
        public static final string DATA_NODE = 'data';
        public static final string FILENAME_NODE = 'file-name';
        public static final string MOMETYPE_NODE = 'mime-type';
        public static final string BATCHNAME = 'ContractBatch';
        public static final string COMPENSATION_PER_UNIT = 'compensation_per_unit';
        public static final string NUMBER_OF_CHANNEL = 'Number_of_Channels__c';
        public static final string MDU_CONTRACT_WRITEBACK_PROCESS = 'MDU Contract Writeback batch Process Initiated at : ';
        public static final String BODY_NODE = 'Body';
        public static final String NODE_FUNCTION = 'http://schemas.xmlsoap.org/soap/envelope/';
        public static final String OPPORTUNITY_STAGE_CLOSE_WON = 'Closed Won';       
        public static final string ACTIVE_STATUS_STRING = 'Active';
        public static final string NAME_STRING = 'contract_saved_in_direct';
        public static final string VALUE_STRING = 'No';
        public static final string EXECUTED_STATUS_STRING = 'Executed';
        public static final string SUBSTATUS_STRING = 'Processed';
        public static final string YES_STRING = 'Yes';               
        public static final Map<string, string> preexistingUserMap = new Map<string, string>{'Comcast' => 'Comcast',  'Install' => 'Comcast',  'Rewire' => 'Comcast',  'Installing' => 'Comcast' ,'Rewiring' => 'Comcast',  'Owner' => 'Owner',  'Association/Developer' => 'Owner',  'Individual Unit Resident' => 'Owner', 'Unknown' => 'Pre-Existing',  'Existing' => 'Pre-Existing'};         
        public static final Set<string> feePropertyFieldSet = new Set<string>{'compensation_per_unit','total_compensation','comp_payable_with','door_fee_provision'};
        public static final Set<string> billingTypeSet = new Set<string>{'billing_type_videp','billing_type_cdv','billing_type_hsi'};
        public static final Set<string> homeExclusiveECMSet = new Set<string>{'chw_exclusive','chrw_exclusive','distribution_exclusive'};
        public static final Set<string> installByECMSet = new Set<string>{'insertion_equip_installed_by','insertion_equip_maintained_by','insertion_equip_owned_by', 'chrw_maintained_by', 'chw_maintained_by', 'distribution_maintained_by','distribution_owned_by'}; //Have same Value 'Comcast' , 'Owner'
        public static final Set<string> bulkRateIncreaseSet = new Set<string> {'Monthly', 'Quarterly', 'Semi-Annually', 'Annually', 'Consistent With Residential Increases'};
        public static final Set<string> installMaintainByECMInternalSet = new Set<string>{'chrw_will_be_installed_by', 'chrw_paid_by', 'distribution_paid_by', 'chw_paid_by', 'chw_wiring', 'distribution'};
        public static final Set<string> assignableValueSet = new Set<string>{'None', 'Notice', 'Consent', 'Unrestricted'};
        public static final Set<string> marketingRightSet = new Set<string>{'marketing_rights_hsi','marketing_rights_video','marketing_rights_cdv'};
        public static final Set<string> homeInstrumnetOwnMaintainSet = new Set<string>{'chrw_owned_by', 'chw_owned_by'};
        public static final Set<string> lobValueSet = new Set<string>{'high speed data','multi-channel video','voice'};
        public static final Set<string> lobECMInternalVariableSet = new Set<string>{'contract_service_video','contract_service_hsi','contract_service_cdv'};
        public static final Set<string> lobUnitdECMIntrnalNameSet = new Set<string>{'cdv_units','hsd_units','court_indiv_num_of_units_vid'};
        public static final Set<string> renewalUnitIntrnalNameSet = new Set<string>{'renewal_period_unit','contract_term_unit'};
        public static final string MDU_WRITEBACT_USER = 'MduWriteBackUser';
        
        /* Courtesy Account Type Set  */
        public static final Set<string> recipientVideoUnitOutletSet = new Set<string>{'Individual', 'Common Area and Individual'};
        public static final Set<string> videoDataOutletOutSet = new Set<string>{'Common Area and Individual', 'Common','Common Area','Individual','Neither'};
        public static final Set<string> videoDataServiceLevelSet = new Set<string>{'Common Area and Individual', 'Common','Common Area'};
        /* Courtesy Account Type Set */
        
        public static final String FUTURE_METHOD_STARTED = 'Method successRequestExecute invocation started for Contract List : ';
        public static final String CONTRACT_STATUS_MESSAGE = 'updateContractSubstatusRequest fail for contract id : ';
        public static final String CONTRACT_TERM_MESSAGE = 'updateContractTermRequest fail for contract id : ';
        public static final String CUST_PROP_MESSAGE = 'updateContractCustomPropertyRequest fail for contract id : ';
        public static final String FUTURE_METHOD_ENDED =  'Method successRequestExecute invocation ended for Contract List';
        public static final String OPPOOPRTUNTY_SFID = ', Opportunity SFDC Id List :';
        public static final String PROPERTY_SFID = ', Property SFDC Id List :';
        public static final String CONTRACT_SFID = '\n Created SFDC Contract Id List :';
        public static final String PROCESS_SUCCESS = '\n\n Contract writeback process completed ';
        public static final String EXCEPTION_MEESAGE =  'Exception Message >>>>>>';
        public static final String CONTRACT_START_TO_FETCH = 'populateContractData method  Get Contract Data and populate object based on Mapping For Contract Id :';
        public static final String CONTRACTED_BULK_AVAIL = '  Contracted Bulk Service Record Available : ';
        public static final String PROPERTY_ID_STRING = ', Property Id For Contract : ';
        public static final String OPPORTUNITY_ID_STRING = ', Opportunity Id For Contract : ';
        public static final String OPPORTUNITY_TYPE_ADDENDUM = 'Addendum';
        public static final String DOOR_FEE_FLAG = ',door_fees flag: ';
        public static final String DOOR_FEE_CREATED = ',isDoorFeeRecordCreated flag: ';
        public static final String REC_FEE_FLAG = ',recurring_fess flag: ';
        public static final String REC_FEE_CREATED =  ',isRecurringFeeRecordCreated flag: ';
        public static final String CONTRACT_END_TO_FETCH =  'Get Contract Data and populate object based on Mapping For Contract Id ';
        public static final String PROCESS_ENDED = ' Ended ';
        public static final String GET_EXEC_WRITEBACK = 'Get Executed And Active Contract Ids';
        public static final String CONTRACT_ATTACHMENT_START = '\n createContractAttachment method Started For Contract Id ';
        public static final String CONTRACT_ATTACHMENT_END = '\n createContractAttachment method End For Contract Id ';
        public static final String CONTRACT_MAPP_START = '\n createContractMappingData method Started For Contract Id';
        public static final String CONTRACT_MAPP_END = '\n createContractMappingData method End For Contract Id'; 
        public static final String CONTRACT_NOT_FOUND = '\n Contract Id Not Found. ' ;
        public static final String NEW_LINE = '\n';
        public static final String EXUCUTED_ERROR = 'searchExecutedRequest executed with error \n';
        public static final String ACTIVE_ERROR = 'searchActiveRequest executed with error \n';
        public static final String CONTRACT_REQUEST_ERROR = 'GetContractRequest executed with error \n';
        public static final String ATACHMENT_REQUEST_ERROR = 'GetContractLanguageRequest executed with error \n';        
        public static final String BULK_RATE_PERIOD_INT_NAME = 'bulk_rate_increase_period_unit';
        public static final String OPPORTUNITY_INSERT_MESSAGE = 'Error In Inserting Opportunity : ';
        public static final String CONTRACT_INSERT_MESSAGE = 'Error In Inserting Contract: ';
        public static final String MARKETING_RIGHT_NONE = 'none';
        public static final String MARKETING_RIGHT_NONE_SFDC_VALUE = 'No Rights';
        public static final String LOB_BILLING_TYPE_NOT_SERVICE = 'Not Serviced';
        /* Contracted Bulk Service Type Constant */
        public static final String VIDEO_SERVICE_TYPE = 'Video';
        public static final String VIDEO_INTERNET_SERVICE_TYPE = 'Video and Internet';
        public static final String VIDEO_INTERNET_VOICE_SERVICE_TYPE = 'Video, Internet and Voice';
        public static final String BULK_SERV_UNIT = 'outlet';
        public static final String ANNUAL_INCREASE_PERIOD = 'Annually';
        public static final String SERVICE_TYPE_INTERNET = 'High Speed Internet';
        public static final String SERVICE_TYPE_VOICE = 'Voice';
        public static final String VIDEO_BILLING_TYPE_BULK = 'Bulk';
        public static final String SERVICE_TYPE_VIDEO = 'Video';   
        public static final String VIDEO_INCREASE_PERD_PER_YEAR = 'per year';
                       
        public static final String PAY_PERIOD_QUARTERLY = 'Quarterly';
        
        public static final string SERVICE_FEE_PER_UNIT = 'service_fee_per_unit';
        public static final string HSI_SERVICE_FEE_PER_UNIT = 'hsi_service_fee_per_unit';
        public static final string VOICE_BULK_BILL_RATE = 'voice_bulk_bill_rate';
        public static final string EQUIPMENT_DCT = 'equipment_quantity_dct';
        public static final string EQUIPMENT_DTA = 'equipment_quantity_dta';
        public static final string INDUSTRY_TYPE_BULK = 'industry_type';
        public static final string BULK_UNIT_OUTLET =  'bulk_unit_outlet_type';
        public static final string BILLING_TYPE = 'billing_type';
        public static final string NUMB_OF_UNIT = 'number_of_units';
        public static final string BULK_RATE_INCR_NOTC_PER = 'bulk_rate_increase_notice_peri';
        public static final string BULK_ACCOUNT_NUMBER = 'bulk_master_account_number';
        public static final string BILLING_TYPE_RETAIL = 'Retail';        
        public static final string RETAIL_ONLY_BULK_SERVICE = ' Contract Bulk Service Retial Only :';        
        
        /* 
        * START: Application Log CONSTANTS Emptoris Integration.
        */  
        public static final string LAUNCH_EMPTORIS_PROCESS = 'Launch Emptoris Process Initiated at : ';
        public static final string NL_NL_REQUEST_NAME= '\n\nRequest Name : ';
        public static final string NL_RESPONSE = '\nResponse: ';
        public static final string NL_ERROR = '\nError: ';
        public static final string DELETE_CONTRACT_PROCESS = 'Delete Contract Process Initiated at : ';
        public static final string VIEW_CONTRACT_PROCESS = 'View Contract Process Initiated at : ';
        public static final string NL_REQUEST_NAME = '\nRequest Name : ';
        public static final string GET_CONTRACT_USER = 'getContractUser';
        public static final string NL_START_TIME = '\nStart Time: ';
        public static final string NL_END_TIME = '\nEnd Time: ';
        public static final string GET_CONTRACT_DETAILS = 'getContractDetails';
        public static final string DELETE_CONTRACT = 'deleteContract';
        public static final string GET_CONTRACT_URL = 'getContractURL';
        public static final string EMPTORIS_INTERVIEW_PROCESS = 'Emptoris Interview Process Initiated at : ';
        public static final string NL_NO_PROPERTY_RECORD_WITH_OPP = '\nThere is no Property record associated with the opportunity. Please include a Primary Property record and try again!' ;       
        public static final string SEARCH_INDIVIDUAL = 'searchIndividual';
        public static final string CREATE_INDIVIDUAL = 'createIndividual';
        public static final string SEARCH_INTERVIEW = 'searchInterview';
        public static final string BUILDSSOURLWIZARD = 'buildSSOUrlWizard';
        public static final string CREATEINTERVIEW = 'createInterview';
        public static final string LAUNCHEMPTORISHTTPREQUEST = 'launchEmptorisHttpRequest';
        public static final string LOG_MESSAGE = '\n\n  Log Message :';
        public static final string LOG_EXCEPTION = 'Exception Occured while processing Contract ID :'; //Added by AK on 06-11-2017 for US-	US1118752
        public static final string OPPORTUNITY_EXCEPTION = 'Exception Occured while processing Contract ID having Opportunity as :'; //Added by AK on 06-11-2017 for US-	US1118752

        /* END: Application Log CONSTANTS */
        
        /*START: Resume/Delete Interview messages*/
        public static final string RESUME_ERR_MESSAGE = 'ERROR: Interview cannot be RESUMED as \'ECM Contract Id\' is present on Opportunity Property. Please refresh the page!';
        public static final string DELETE_ERR_MESSAGE = 'ERROR: Interview cannot be DELETED as \'ECM Contract Id\' is present on Opportunity Property. Please refresh the page!';
        /*END: Resume/Delete Interview messages*/
        
        //Start : Sagarika - Changes for US1132369, US1132449, US1132350 
        public static final string SIMPLE_DATA_CONTROL_STRING = '<simple-input-controls xmlns="http://www.dicarta.com/contracts/types/domain/step"><name xmlns="http://www.dicarta.com/contracts/types/domain/simple-input-control">{0}</name><value xmlns="http://www.dicarta.com/contracts/types/domain/simple-input-control"><string-value xmlns="http://www.dicarta.com/contracts/types/domain/common">{1}</string-value></value></simple-input-controls>';
        public static final string SIMPLE_DATA_CONTROL_NUMBER = '<simple-input-controls xmlns="http://www.dicarta.com/contracts/types/domain/step"><name xmlns="http://www.dicarta.com/contracts/types/domain/simple-input-control">{0}</name><value xmlns="http://www.dicarta.com/contracts/types/domain/simple-input-control"><number-value xmlns="http://www.dicarta.com/contracts/types/domain/common">{1}</number-value></value></simple-input-controls>';
        //End : Sagarika - Changes for US1132369, US1132449, US1132350 
    
    }