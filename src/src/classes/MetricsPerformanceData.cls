/*
 * Functional class to retrieve external performance data for Metrics
 * @Author Salesforce Program Architect
 * @Date 2017-03-29
 * 
 * Information:
 * 
 * Created Remote Site Setting: https://onecomcastx--DevPro.cs53.my.salesforce.com/services/data/v36.0/wave/query
 *      TODO: Need to discuss the current paradigm for this and address appropriately.
 * Created Wave_Metrics_Performance_Dataset_Id System Property [Wave Functional Area] (Setup -> Develop -> Custom Metadata Types)
 *      Value = 0Fb16000000TSegCAG/0Fc0j000000AHC4CAO
 * Created Metric.ExternalId__c Custom Field
 *      Type: Text(32)
 *          Do Not Allow Duplicates (Unique, Case Insensitve)
 *          Set as External Id
 *      Visible to 
 *          Integration User
 *          System Administrator
 *          System Administrator EX Lightning (necessary evil for DevPro)
 *      Page Layouts: None
 *      Purpose: Store a Composite Key: User.PERNR__c + Metric.DueDate + [RGU Metric Enumeration, e.g. HSD, Video, Voice, XH]
 *      TODO:
 *          (1) Bulk load this field when initially created
 *          (2) Create or enhanced trigger to maintain this field upon RGU Metric Insert/Update
 * Created Metric.Exception__c Custom Field
 *      Tyep: Text(255)
 *      Visible to 
 *          Integration User
 *          System Administrator
 *          System Administrator EX Lightning (necessary evil for DevPro)
 *      Page Layouts: None
 *      Purpose: Store automated update exceptions to be used in reporting (preferably a daily report emailed to Admins)
 *      TODO: Determine if field history trackig should be on this field.
 * Created Metric.RGU_Actual_Update_Date__c Custom Field
 *      Type: Date
 *      Visible to All Users (Read-Only)
 *      Page Layouts: None (this will be used in a formula field)
 *      Purpose:  Store the AUDIT_UPDATED_TS timestamp date from the Wave data set, to capture the as of update date from InfoQuest
 *      TODO: Hear back from Peter Brousseau RE the exact lag time for this data (i.e. 1-day or 2-day)
 * Created Metric.RGU_Actual_Update_Note__c Custom Formula Field
 *      Type: Formula
 *      Visible to All Users (Read-Only)
 *      Page Layouts: All (just below 'Current Value') EXCEPT Completion Metric Layout (does not show 'Current Value')
 *          Note: Inclusion and position in page layouts should be groomed with the product manager.
 *          Note: It may not make sense to display this field for certain metrics, so might need different record types / page layouts.
 *      Purpose: Display the 'as of' update date for the RGU actual, based on the timestamp from InfoQuest (i.e. RGU_Actual_Update_Date__c)
 * Get Session Id via Log in method of Partner WSDL (pass username and password). 
 *      Userinfo.GetSessionId() gives null value in future method. 
 *      1. We can create a Connected Apps to get Client Id and Client Secret. Utilize the same to get session id. 
 *      2. Alternatively, we can use Partner WSDL's log in method. 2nd option looks more promising.
 * Adding lagging days in configureable custom setting (RGU_Goal_Target_Actual__c).
 *      Field RGU_Actual_Update_Date__c on metric record will store (Today - Lagging days)
 */     
public with sharing class MetricsPerformanceData { 

    private static WaveAPIUtil wave;
    private static String WAVE_API_BASE;
    private static String WAVE_DATASET_ID;
    // <Salesforce Program Architect 20170524> 
    // 		Update Code to get Dataset Current Version Id by Dataset Id
    // 		Define new attributes
    private static String WAVE_DATASET_CURRENT_VERSION_ID;
    private static String WAVE_QUERY_ID;
	// </Salesforce Program Architect 20170524>
    private static Integer BATCH_SIZE;
    private static SystemProperties sysProps;
    private static RGU_Goal_Target_Actual__c targetActualCustomSettings;
    private static String USERNAME;
    private static String PASSWORD;
    private static Integer LAGGING_DAYS;
    static{
        sysProps = new SystemProperties();
        WAVE_API_BASE = sysProps.getSytemProperty('Wave_Api_Endpoint', 'Wave');
        WAVE_DATASET_ID = sysProps.getSytemProperty('Wave_Metrics_Performance_Dataset_Id', 'Wave'); 
        /*  TODO-OPTIONAL
                Create Wave.Wave_Metrics_Performence_Dataset_Name and set to WAVE_DAILY_COMMISSION_SUMMARY_1
                Implement logic to retrieve Dataset Id by Name if initial query by property.Id fails
         */        
        wave = WaveAPIUtil.getInstance();
	    // <Salesforce Program Architect 20170524>
	    // 		Update Code to get Dataset Current Version Id by Dataset Id
	    // 		Set new attributes
		WAVE_DATASET_CURRENT_VERSION_ID = wave.getDatasetCurrentVersionId(WAVE_DATASET_ID);
        WAVE_QUERY_ID = WAVE_DATASET_ID + '/' + WAVE_DATASET_CURRENT_VERSION_ID;
		// </Salesforce Program Architect 20170524>
        targetActualCustomSettings = RGU_Goal_Target_Actual__c.getInstance(Indirect_Constants.CUSTOMSET_INDIRECT );//add in label or constant class
        LAGGING_DAYS = Integer.valueOf(targetActualCustomSettings.Lagging_Days__c);//Get lagging days
        USERNAME = DecodeEncodeUtility.decodeData(targetActualCustomSettings.UserName__c);//decrypted user name
        PASSWORD = DecodeEncodeUtility.decodeData(targetActualCustomSettings.Credential__c);//decrypted password
    }

    // Define the Record Structure for JSON Results
    private class WaveMetricRecord {
        String SALES_REP_PERNR;
        String SALES_REP_NAME;
        String PAYROLL_END_DATE; // This is a date, but will be used as a string.
        String SALES_COMP_SALES_CHNL_DESC; // Channel
        String DIVISION_NAME;
        String REGION_NAME;
        String SITE_NAME;
        String SITE_NUMBER;
        Decimal IQ_HSD_ACTUAL_CNT;
        Decimal IQ_HSD_ADJUSTED_GOAL_CNT;
        Decimal IQ_VIDEO_ACTUAL_CNT;
        Decimal IQ_VIDEO_ADJUSTED_GOAL_CNT;
        Decimal IQ_CDV_ACTUAL_CNT;
        Decimal IQ_CDV_ADJUSTED_GOAL_CNT;
        Decimal IQ_XH_ACTUAL_CNT;
        Decimal IQ_XHS_ADJUSTED_GOAL_CNT;
        Decimal IQ_TOTAL_ACTUAL_CNT;
        Decimal IQ_TOTAL_ADJUSTED_GOAL_CNT;
        Date AUDIT_UPDATED_TS;
    }

    // Create a cleaner version of the JSON record representation to buffer the code
    private class MetricRecord {
        String hsdKey;
        String videoKey;
        String voiceKey;
        String xhKey;
        String totalKey;
        String salesRepPERNR;
        String salesRepName;
        String payrollEndDate;
        String salesChannel;
        String divisionName;
        String regionName;
        String siteName;
        String siteNumber;
        Decimal hsdActualRGU;
        Decimal hsdAdjustedGoal;
        Decimal videoActualRGU;
        Decimal videoAdjustedGoal;
        Decimal voiceActualRGU;
        Decimal voiceAdjustedGoal;
        Decimal xhActualRGU;
        Decimal xhAdjustedGoal;
        Decimal totalActualRGU;
        Decimal totalAdjustedGoal;
        Date updateDate;
    }
    
    private MetricRecord copyWaveMetricRecordToMetricRecord (WaveMetricRecord wmRec) {
        MetricRecord mRec = new MetricRecord();
        /* TODO
         *      These hard coded enumerations could be setup as System Properties
         *      (The drawback is that their values are germane to the success of the code, so, perhaps, should remain in code)
         */ 
        mRec.hsdKey = wmRec.SALES_REP_PERNR + wmRec.PAYROLL_END_DATE.remove('-') + 'HSD';
        mRec.videoKey = wmRec.SALES_REP_PERNR + wmRec.PAYROLL_END_DATE.remove('-') + 'Video';
        mRec.voiceKey = wmRec.SALES_REP_PERNR + wmRec.PAYROLL_END_DATE.remove('-') + 'Voice';
        mRec.xhKey = wmRec.SALES_REP_PERNR + wmRec.PAYROLL_END_DATE.remove('-') + 'XH';
        mRec.totalKey = wmRec.SALES_REP_PERNR + wmRec.PAYROLL_END_DATE.remove('-') + 'Total Units';
        mRec.salesRepPERNR = wmRec.SALES_REP_PERNR;
        mRec.salesRepName = wmRec.SALES_REP_NAME;
        mRec.payrollEndDate = wmRec.PAYROLL_END_DATE;
        mRec.salesChannel = wmRec.SALES_COMP_SALES_CHNL_DESC;
        mRec.divisionName = wmRec.DIVISION_NAME;
        mRec.regionName = wmRec.REGION_NAME;
        mRec.siteName = wmRec.SITE_NAME;
        mRec.siteNumber = wmRec.SITE_NUMBER;
        mRec.hsdActualRGU = wmRec.IQ_HSD_ACTUAL_CNT;
        mRec.hsdAdjustedGoal = wmRec.IQ_HSD_ADJUSTED_GOAL_CNT;
        mRec.videoActualRGU = wmRec.IQ_VIDEO_ACTUAL_CNT;
        mRec.videoAdjustedGoal = wmRec.IQ_VIDEO_ADJUSTED_GOAL_CNT;
        mRec.voiceActualRGU = wmRec.IQ_CDV_ACTUAL_CNT;
        mRec.voiceAdjustedGoal = wmRec.IQ_CDV_ADJUSTED_GOAL_CNT;
        mRec.xhActualRGU = wmRec.IQ_XH_ACTUAL_CNT;
        mRec.xhAdjustedGoal = wmRec.IQ_XHS_ADJUSTED_GOAL_CNT;
        mRec.totalActualRGU = wmRec.IQ_TOTAL_ACTUAL_CNT;
        mRec.totalAdjustedGoal = wmRec.IQ_TOTAL_ADJUSTED_GOAL_CNT;
        /* TODO
         *      Replace the "-2" below with the system property (I am not finding it in DevPro2 at the moment)
         *      You can either save -2 in the system property or use -[system property]. I suggest the former.
         *      
         */ 
        //Update field RGU_Actual_Update_Date__c as (Today - Lagging days). Keeping Lagging days configurable as this is not fixed
        mRec.updateDate = Date.today().addDays(-LAGGING_DAYS); // Use a Today - 2 Days vs wmRec.AUDIT_UPDATED_TS, which is not reliable.
        return mRec;
    }
    
    /* TODO
     *      Determine if this method should be overloaded or if new methods (i.e. name and parameters) should
     *      be created to enable fine-tuning of updates by channel, division, region or a combination of same. 
     *      This would require additional abstraction and refactoring to preserve reusability (not necessary now)           
     */      
    public Map<String, Metric> getRGUPerformanceData
    (
        String salesChannel,
        Date beginPayrollPeriod, 
        Date endPayrollPeriod, 
        Integer saqlOffset, 
        Integer saqlLimit
    ) {
        
        // TEMPORARY: Statistics 
        Integer totalRecords = 0;
        Integer recordsWithKeys = 0;
        Integer hsdMetricUpdates = 0;
        Integer videoMetricUpdates = 0;
        Integer voiceMetricUpdates = 0;
        Integer xhMetricUpdates = 0; 
        Integer totalMetricUpdates = 0;
        Integer totalDuplicateMetrics = 0; 
        
        // Prepare the date arguments
        String beginPayrollParameter = beginPayrollPeriod.year() + ',' + beginPayrollPeriod.month() + ',' + beginPayrollPeriod.day();
        String endPayrollParameter = endPayrollPeriod.year() + ',' + endPayrollPeriod.month() + ',' + endPayrollPeriod.day();

        // Collect Metrics records for upsert, with composite Key
        Map<String,Metric> upsertMetricsMap = new Map<String,Metric>();
	    // <Salesforce Program Architect 20170524> 
	    // 		Update Code to get Dataset Current Version Id by Dataset Id
	    // 		Use the new WAVE_QUERY_ID with DatasetId/VersionId
	    // 		Where VersionId is programmatically set to be the most current version
        String saqlQuery = 'q = load "'+WAVE_QUERY_ID+'"; q = filter q by \'SALES_COMP_SALES_CHNL_DESC\' == "'+salesChannel+'"; q = filter q by date(\'PAYROLL_END_DATE_Year\', \'PAYROLL_END_DATE_Month\', \'PAYROLL_END_DATE_Day\') in [dateRange([' + beginPayrollParameter + '], [' + endPayrollParameter + '])]; q = foreach q generate \'PAYROLL_END_DATE\' as \'PAYROLL_END_DATE\', \'SALES_REP_PERNR\' as \'SALES_REP_PERNR\', \'SALES_REP_NAME\' as \'SALES_REP_NAME\', \'SALES_COMP_SALES_CHNL_DESC\' as \'SALES_COMP_SALES_CHNL_DESC\', \'DIVISION_NAME\' as \'DIVISION_NAME\', \'REGION_NAME\' as \'REGION_NAME\', \'SITE_NAME\' as \'SITE_NAME\', \'SITE_NUMBER\' as \'SITE_NUMBER\', \'IQ_CDV_ACTUAL_CNT\' as \'IQ_CDV_ACTUAL_CNT\', \'IQ_CDV_ADJUSTED_GOAL_CNT\' as \'IQ_CDV_ADJUSTED_GOAL_CNT\', \'IQ_HSD_ACTUAL_CNT\' as \'IQ_HSD_ACTUAL_CNT\', \'IQ_HSD_ADJUSTED_GOAL_CNT\' as \'IQ_HSD_ADJUSTED_GOAL_CNT\', \'IQ_VIDEO_ACTUAL_CNT\' as \'IQ_VIDEO_ACTUAL_CNT\', \'IQ_VIDEO_ADJUSTED_GOAL_CNT\' as \'IQ_VIDEO_ADJUSTED_GOAL_CNT\', \'IQ_XHS_ADJUSTED_GOAL_CNT\' as \'IQ_XHS_ADJUSTED_GOAL_CNT\', \'IQ_XH_ACTUAL_CNT\' as \'IQ_XH_ACTUAL_CNT\', \'IQ_TOTAL_ACTUAL_CNT\' as \'IQ_TOTAL_ACTUAL_CNT\', \'IQ_TOTAL_ADJUSTED_GOAL_CNT\' as \'IQ_TOTAL_ADJUSTED_GOAL_CNT\', \'AUDIT_UPDATED_TS\' as \'AUDIT_UPDATED_TS\' ; q = order q by (\'PAYROLL_END_DATE\' desc, \'SALES_REP_PERNR\'); q = offset q ' + saqlOffset + '; q = limit q ' + saqlLimit + ';';
	    // </Salesforce Program Architect 20170524>
        String sessionid = LoginToGetSessionId.login(USERNAME,PASSWORD);//Get session id
        //String saqlResult = wave.postQuery(saqlQuery); // This could be embedded in the JSON Parser instantiation below, but easier to debug if separate.
        String saqlResult = wave.postQueryAsync(saqlQuery,sessionId);//commented above line as session id is needed
        System.JSONParser parser = System.JSON.createParser(saqlResult);
        //system.debug('messge??????'+parser);
        // Parse JSON Response
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                // Parse Array of Records within JSON
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        // Parse Record within Array of Records
                        ++totalRecords;
                        WaveMetricRecord wmRec = (WaveMetricRecord)parser.readValueAs(WaveMetricRecord.class);
                        MetricRecord mRec = copyWaveMetricRecordToMetricRecord(wmRec);
                        // Must have the necessary data for the ExternalId__c, otherwise we should bypass this record
                        if(mRec.salesRepPERNR != null && mRec.payrollEndDate != null){
                            ++recordsWithKeys;
                           // Update HSD Metric
                            Metric hsdMetric = new Metric();
                            if(!upsertMetricsMap.containsKey(mRec.hsdKey)) {
                                // Not a Duplicate (so far)
                                if(mRec.hsdActualRGU != null || mRec.hsdAdjustedGoal != null){
                                    // There is minimum viable data for an update 
                                    ++hsdMetricUpdates; 
                                    hsdMetric.ExternalId__c = mRec.hsdKey;
                                    // Update actual RGU, without nullifying it
                                    if(mRec.hsdActualRGU != null){
                                        hsdMetric.CurrentValue = mRec.hsdActualRGU;
                                    }
                                    // Update adjusted Goal, without nullifying it
                                    if(mRec.hsdAdjustedGoal != null){
                                        hsdMetric.TargetValue = mRec.hsdAdjustedGoal;
                                    }
                                    // Set the updated date from the Wave dataset
                                    hsdMetric.RGU_Actual_Update_Date__c = mRec.updateDate;
                                    // Set the Exception__c field for this Metric to null, in case it was a duplicate in the past
                                    hsdMetric.Exception__c = null;
                                }
                            } else {
                                // Duplicate (i.e. Metric was found in upsertMetricsMap)
                                if(upsertMetricsMap.get(mRec.hsdKey).Exception__c == null){
                                    // This is the first time we are encountering a duplicate
                                    // Increment the duplicate counter by 2 to account for the existing Metric in upsertMetricsMap + THIS Metric
                                    totalDuplicateMetrics+=2; 
                                    // Decrement the update counter by 1 to account for the fact that a previous Metric was counted in error
                                    --hsdMetricUpdates;
                                    // Remove the previous, errant Metric to ensure that we do not update an existing Metric with errant values
                                    upsertMetricsMap.remove(mRec.hsdKey);
                                    // Initialize Exception__c for THIS Metric. This will be the _only_ field to get updated by the upsert
                                    hsdMetric.ExternalId__c = mRec.hsdKey;
                                    hsdMetric.Exception__c = System.now() + ' RGU-HSD Update Exception: Duplicate Records in Wave for PERNR: ' + mRec.salesRepPERNR + ', Payroll End Date: ' + mRec.payrollEndDate;
                                } else {
                                    // This is the second time we are encountering a duplicate
                                    //  The existing Metric in upsertMetricsMap already has the correct Exception message
                                    //  The only thing we need to do here is just update the internal counter
                                    ++totalDuplicateMetrics;
                                }
                            }
                            // Add the current Metric to upsertMetricsMap IFF the ExternalId__c field has been set
                            // (In the logic above, setting the ExternalId__c is the signal that a Metric needs to be added to the map)
                            if(hsdMetric.ExternalId__c != null){
                                upsertMetricsMap.put(mRec.hsdKey, hsdMetric);
                            }
                           // Update Video Metric
                            Metric videoMetric = new Metric();
                            if(!upsertMetricsMap.containsKey(mRec.videoKey)) {
                                // Not a Duplicate (so far)
                                if(mRec.videoActualRGU != null || mRec.videoAdjustedGoal != null){
                                    // There is minimum viable data for an update 
                                    ++videoMetricUpdates;
                                    videoMetric.ExternalId__c = mRec.videoKey;
                                    // Update actual RGU, without nullifying it
                                    if(mRec.videoActualRGU != null){
                                        videoMetric.CurrentValue = mRec.videoActualRGU;
                                    }
                                    // Update adjusted Goal, without nullifying it
                                    if(mRec.videoAdjustedGoal != null){
                                        videoMetric.TargetValue = mRec.videoAdjustedGoal;
                                    }                                   
                                    // Set the updated date from the Wave dataset
                                    videoMetric.RGU_Actual_Update_Date__c = mRec.updateDate;
                                    // Set the Exception__c field for this Metric to null, in case it was a duplicate in the past
                                    videoMetric.Exception__c = null;
                                }
                            } else {
                                // Duplicate (i.e. Metric was found in upsertMetricsMap)
                                if(upsertMetricsMap.get(mRec.videoKey).Exception__c == null){
                                    // This is the first time we are encountering a duplicate
                                    // Increment the counter by 2 to account for the existing Metric in upsertMetricsMap + THIS Metric
                                    totalDuplicateMetrics+=2;
                                    // Decrement the update counter by 1 to account for the fact that a previous Metric was counted in error
                                    --videoMetricUpdates;                                    
                                    // Remove the previous, errant Metric to ensure that we do not update an existing Metric with errant values
                                    upsertMetricsMap.remove(mRec.videoKey);
                                    // Initialize Exception__c for THIS Metric. This will be the _only_ field to get updated by the upsert
                                    videoMetric.ExternalId__c = mRec.videoKey;
                                    videoMetric.Exception__c = System.now() + ' RGU-Video Update Exception: Duplicate Records in Wave for PERNR: ' + mRec.salesRepPERNR + ', Payroll End Date: ' + mRec.payrollEndDate;
                                } else {
                                    // This is the second time we are encountering a duplicate
                                    //  The existing Metric in upsertMetricsMap already has the correct Exception message
                                    //  The only thing we need to do here is just update the internal counter
                                    ++totalDuplicateMetrics;
                                }
                            }
                            // Add the current Metric to upsertMetricsMap IFF the ExternalId__c field has been set
                            // (In the logic above, setting the ExternalId__c is the signal that a Metric needs to be added to the map)
                            if(videoMetric.ExternalId__c != null){
                                upsertMetricsMap.put(mRec.videoKey, videoMetric);
                            }
                            // Update Voice Metric
                            Metric voiceMetric = new Metric();
                            if(!upsertMetricsMap.containsKey(mRec.voiceKey)) {
                                // Not a Duplicate (so far)
                                if(mRec.voiceActualRGU != null || mRec.voiceAdjustedGoal != null){
                                    // There is minimum viable data for an update 
                                    ++voiceMetricUpdates;
                                    voiceMetric.ExternalId__c = mRec.voiceKey;
                                    // Update actual RGU, without nullifying it
                                    if(mRec.voiceActualRGU != null){
                                        voiceMetric.CurrentValue = mRec.voiceActualRGU;
                                    }
                                    // Update adjusted Goal, without nullifying it
                                    if(mRec.voiceAdjustedGoal != null){
                                        voiceMetric.TargetValue = mRec.voiceAdjustedGoal;
                                    }                                   
                                    // Set the updated date from the Wave dataset
                                    voiceMetric.RGU_Actual_Update_Date__c = mRec.updateDate;
                                    // Set the Exception__c field for this Metric to null, in case it was a duplicate in the past
                                    voiceMetric.Exception__c = null;
                                }
                            } else {
                                // Duplicate (i.e. Metric was found in upsertMetricsMap)
                                if(upsertMetricsMap.get(mRec.voiceKey).Exception__c == null){
                                    // This is the first time we are encountering a duplicate
                                    // Increment the counter by 2 to account for the existing Metric in upsertMetricsMap + THIS Metric
                                    totalDuplicateMetrics+=2;
                                    // Decrement the update counter by 1 to account for the fact that a previous Metric was counted in error
                                    --voiceMetricUpdates;
                                    // Remove the previous, errant Metric to ensure that we do not update an existing Metric with errant values
                                    upsertMetricsMap.remove(mRec.voiceKey);                                    
                                    // Initialize Exception__c for THIS Metric. This will be the _only_ field to get updated by the upsert
                                    voiceMetric.ExternalId__c = mRec.voiceKey;
                                    voiceMetric.Exception__c = System.now() + ' RGU-Voice Update Exception: Duplicate Records in Wave for PERNR: ' + mRec.salesRepPERNR + ', Payroll End Date: ' + mRec.payrollEndDate;
                                } else {
                                    // This is the second time we are encountering a duplicate
                                    //  The existing Metric in upsertMetricsMap already has the correct Exception message
                                    //  The only thing we need to do here is just update the internal counter
                                    ++totalDuplicateMetrics;
                                }
                            }
                            // Add the current Metric to upsertMetricsMap IFF the ExternalId__c field has been set
                            // (In the logic above, setting the ExternalId__c is the signal that a Metric needs to be added to the map)
                            if(voiceMetric.ExternalId__c != null){
                                upsertMetricsMap.put(mRec.voiceKey, voiceMetric);
                            }
                           // Update XH Metric
                            Metric xhMetric = new Metric();
                            if(!upsertMetricsMap.containsKey(mRec.xhKey)) {
                                // Not a Duplicate (so far)
                                if(mRec.xhActualRGU != null || mRec.xhAdjustedGoal != null){
                                    // There is minimum viable data for an update 
                                    ++xhMetricUpdates;
                                    xhMetric.ExternalId__c = mRec.xhKey;
                                    // Update actual RGU, without nullifying it
                                    if(mRec.xhActualRGU != null){
                                        xhMetric.CurrentValue = mRec.xhActualRGU;
                                    }
                                    // Update adjusted Goal, without nullifying it
                                    if(mRec.xhAdjustedGoal != null){
                                        xhMetric.TargetValue = mRec.xhAdjustedGoal;
                                    }                                   
                                    // Set the updated date from the Wave dataset
                                    xhMetric.RGU_Actual_Update_Date__c = mRec.updateDate;
                                    // Set the Exception__c field for this Metric to null, in case it was a duplicate in the past
                                    xhMetric.Exception__c = null;
                                }
                            } else {
                                // Duplicate (i.e. Metric was found in upsertMetricsMap)
                                if(upsertMetricsMap.get(mRec.xhKey).Exception__c == null){
                                    // This is the first time we are encountering a duplicate
                                    // Increment the counter by 2 to account for the existing Metric in upsertMetricsMap + THIS Metric
                                    totalDuplicateMetrics+=2;
                                    // Decrement the update counter by 1 to account for the fact that a previous Metric was counted in error
                                    --xhMetricUpdates;
                                    // Remove the previous, errant Metric to ensure that we do not update an existing Metric with errant values
                                    upsertMetricsMap.remove(mRec.xhKey);                                    
                                    // Initialize Exception__c for THIS Metric. This will be the _only_ field to get updated by the upsert
                                    xhMetric.ExternalId__c = mRec.xhKey;
                                    xhMetric.Exception__c = System.now() + ' RGU-XH Update Exception: Duplicate Records in Wave for PERNR: ' + mRec.salesRepPERNR + ', Payroll End Date: ' + mRec.payrollEndDate;
                                } else {
                                    // This is the second time we are encountering a duplicate
                                    //  The existing Metric in upsertMetricsMap already has the correct Exception message
                                    //  The only thing we need to do here is just update the internal counter
                                    ++totalDuplicateMetrics;
                                }
                            }
                            // Add the current Metric to upsertMetricsMap IFF the ExternalId__c field has been set
                            //  (In the logic above, setting the ExternalId__c is the signal that a Metric needs to be added to the map)
                            if(xhMetric.ExternalId__c != null){
                                upsertMetricsMap.put(mRec.xhKey, xhMetric);
                            }
                           // Update Total Units Metric
                            Metric totalMetric = new Metric();
                            if(!upsertMetricsMap.containsKey(mRec.totalKey)) {
                                // Not a Duplicate (so far)
                                if(mRec.totalActualRGU != null || mRec.totalAdjustedGoal != null){
                                    // There is minimum viable data for an update 
                                    ++totalMetricUpdates; 
                                    totalMetric.ExternalId__c = mRec.totalKey;
                                    // Update actual RGU, without nullifying it
                                    if(mRec.totalActualRGU != null){
                                        totalMetric.CurrentValue = mRec.totalActualRGU;
                                    }
                                    // Update adjusted Goal, without nullifying it
                                    if(mRec.totalAdjustedGoal != null){
                                        totalMetric.TargetValue = mRec.totalAdjustedGoal;
                                    }
                                    // Set the updated date from the Wave dataset
                                    totalMetric.RGU_Actual_Update_Date__c = mRec.updateDate;
                                    // Set the Exception__c field for this Metric to null, in case it was a duplicate in the past
                                    totalMetric.Exception__c = null;
                                }
                            } else {
                                // Duplicate (i.e. Metric was found in upsertMetricsMap)
                                if(upsertMetricsMap.get(mRec.totalKey).Exception__c == null){
                                    // This is the first time we are encountering a duplicate
                                    // Increment the duplicate counter by 2 to account for the existing Metric in upsertMetricsMap + THIS Metric
                                    totalDuplicateMetrics+=2; 
                                    // Decrement the update counter by 1 to account for the fact that a previous Metric was counted in error
                                    --totalMetricUpdates;
                                    // Remove the previous, errant Metric to ensure that we do not update an existing Metric with errant values
                                    upsertMetricsMap.remove(mRec.totalKey);
                                    // Initialize Exception__c for THIS Metric. This will be the _only_ field to get updated by the upsert
                                    hsdMetric.ExternalId__c = mRec.totalKey;
                                    hsdMetric.Exception__c = System.now() + ' RGU-Total Update Exception: Duplicate Records in Wave for PERNR: ' + mRec.salesRepPERNR + ', Payroll End Date: ' + mRec.payrollEndDate;
                                } else {
                                    // This is the second time we are encountering a duplicate
                                    //  The existing Metric in upsertMetricsMap already has the correct Exception message
                                    //  The only thing we need to do here is just update the internal counter
                                    ++totalDuplicateMetrics;
                                }
                            }
                            // Add the current Metric to upsertMetricsMap IFF the ExternalId__c field has been set
                            // (In the logic above, setting the ExternalId__c is the signal that a Metric needs to be added to the map)
                            if(totalMetric.ExternalId__c != null){
                                upsertMetricsMap.put(mRec.totalKey, totalMetric);
                            }                        
                        }
                        parser.skipChildren();
                    }
                }
            }
        }
        //commenting below code
        /*for(String mTMP : upsertMetricsMap.keySet()) {
            System.debug('>>>sfdcDebug>>> upsertMetric: ' + mTMP + ': ' + upsertMetricsMap.get(mTMP));
        }*/
        // Return Metrics for Upsert
        return upsertMetricsMap;
    }
}