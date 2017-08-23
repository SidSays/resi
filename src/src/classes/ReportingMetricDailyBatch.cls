/***************************************************************************************************************************************
 * Author     : Vivek Patel
 * Date       : 25-June-2013
 * Description: This batch will run daily and will calculated Reporting metrics for dashboards which will be accumulated for a week and then reset for the next week.
 * Requirement: Daily batch to calculate Reporting Metric.
 * History
     Version             : 1.0
     Author Last Updated : Vivek Patel 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/

public class ReportingMetricDailyBatch implements Database.Batchable<sObject>, Database.Stateful{    
    public String queryString;      
    Map<Id, Reporting_Metric__c> userAndReportingMetric;

/***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 25-June-2013
     * Param      : None
     * Return     : None
     * Description: This is constructor of the class. It deletes Reporting metrics records for inactive users at the starting of the week and created Reporting Metric records so that they can be udpated later on.
************************************************************************************************************************************/
    
    public ReportingMetricDailyBatch() {
        queryString = 'Select Id, Region__c From User Where Profile.Name=\'XFINITY Sales Professional\' AND IsActive=true';  
        userAndReportingMetric = new Map<Id, Reporting_Metric__c>(); 
    }

/***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 25-June-2013
     * Param      : BatchableContext
     * Return     : Database.querylocator
     * Description: This method is called when the batch process starts and gathers knocks for processing.
************************************************************************************************************************************/

    public Database.QueryLocator start(Database.BatchableContext bc) {                                  
        return Database.getQueryLocator(queryString);
    }

/***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 25-June-2013
     * Param      : Database.BatchableContext, List<sObject>
     * Return     : None
     * Description: This method called after the start method to calculate reporting metrics
************************************************************************************************************************************/        

    public void execute(Database.BatchableContext batchContext, List<sObject> scope){       
        Map<Id, List<Task>> userAndKnocks = new Map<Id, List<Task>>();
        Set<Id> dsrSet=new Set<Id>();
        for(User dsr: (List<User>)scope)
        {
            dsrSet.add(dsr.Id);
        }
        if(!dsrSet.isEmpty()){
            for(Task knockObj : [SELECT Id, Disposition__c, Region__c, Knocked_Date__c, Off_Turf__c, Video_Active__c, HSI_Active__c, Voice_Active__c, XH_Active__c, OwnerId  FROM Task WHERE RecordType.Name='Knock' And Region__c != 'Global' And CreatedDate = LAST_N_DAYS:2 AND OwnerId IN:dsrSet ORDER BY OwnerId]) {
                if(knockObj.Knocked_Date__c.Date()==Date.today().addDays(-1)){
                    if(userAndKnocks.containsKey(knockObj.OwnerId)) {
                        userAndKnocks.get(knockObj.OwnerId).add(knockObj);
                    } else {              
                        userAndKnocks.put(knockObj.OwnerId, new List<Task>{knockObj});                
                    }
                }     
            }
        }

        Reporting_Metric__c rmObj;                                 
        
        Id dsrProfileId = [SELECT Id FROM Profile WHERE Name=:Label.DSRProfileName].Id;
        Id dailyRecordTypeId = Schema.SObjectType.Reporting_Metric__c.getRecordTypeInfosByName().get(Label.RM_Daily_Rec_Type).getRecordTypeId();
               
        for(User dsr: (List<User>)scope){
            /*if(userAndReportingMetric.keySet().contains(usr.Id)) {
                userAndReportingMetric.get(usr.Id).Name = Label.DSR_RM_Stats + ' ' + usr.Name;
                userAndReportingMetric.get(usr.Id).Region__c = usr.Region__c;
                continue;
            }*/
            rmObj = new Reporting_Metric__c();
            rmObj.Name = 'Stats for '+Date.today().addDays(-1).format();            
            rmObj.Region__c = dsr.Region__c;
            rmObj.RecordTypeId = dailyRecordTypeId;
            rmObj.Of_Knocks__c = 0;
            rmObj.Of_Starts__c = 0;
            rmObj.Of_Contacts__c = 0;
            rmObj.Of_On_Turf_Starts__c = 0;
            rmObj.Of_Video_Sales__c = 0;
            rmObj.Of_Internet_Sales__c = 0;
            rmObj.Of_Phone_Sales__c = 0;
            rmObj.Of_Home_Security_Sales__c = 0;
            rmObj.DSR_Id__c = dsr.Id;
            rmObj.DSR__c = dsr.Id;
            userAndReportingMetric.put(dsr.Id, rmObj);
        }
       
        System.debug('+++userAndReportingMetric++'+userAndReportingMetric);

        System.debug('+++userAndKnocks++'+userAndKnocks);

        for(Id usrId : userAndKnocks.keySet()) {
            if(userAndReportingMetric.get(usrId) == null){
                continue;
            }
            system.debug(userAndKnocks.get(usrId).size());
            userAndReportingMetric.get(usrId).Of_Knocks__c += userAndKnocks.get(usrId).size();          
            for(Task knockObj : userAndKnocks.get(usrId)) {                                         
                if(knockObj.Disposition__c == Label.DispositionTypeStart) {
                    userAndReportingMetric.get(usrId).Of_Starts__c += 1;                         
                    if(knockObj.Off_Turf__c == false) {
                        userAndReportingMetric.get(usrId).Of_On_Turf_Starts__c += 1;                                                                     
                    }
                }                       
                if(knockObj.Disposition__c == Label.DispositionTypeClose || knockObj.Disposition__c == Label.DispositionTypeEngage || knockObj.Disposition__c == Label.DispositionTypeContact || knockObj.Disposition__c == Label.DispositionTypePosition || knockObj.Disposition__c == Label.DispositionTypeDiscover || knockObj.Disposition__c == Label.DispositionTypeStart) {
                    System.debug('++userId++'+usrId);
                    System.debug('++userAndReportingMetric.get(usrId)++'+userAndReportingMetric.get(usrId));
                    System.debug('++userAndReportingMetric.get(usrId).Of_Contacts__c++'+userAndReportingMetric.get(usrId).Of_Contacts__c );
                    userAndReportingMetric.get(usrId).Of_Contacts__c += 1;                         
                }
                
                if(knockObj.Video_Active__c == true) {
                    userAndReportingMetric.get(usrId).Of_Video_Sales__c += 1;
                }
                if(knockObj.HSI_Active__c == true) {
                    userAndReportingMetric.get(usrId).Of_Internet_Sales__c += 1;
                }
                if(knockObj.Voice_Active__c == true) {
                    userAndReportingMetric.get(usrId).Of_Phone_Sales__c += 1;
                }
                if(knockObj.XH_Active__c == true) {
                    userAndReportingMetric.get(usrId).Of_Home_Security_Sales__c += 1;
                }
            }
            System.debug('+++userAndReportingMetric++'+userAndReportingMetric);
        }                       
    }

/***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 25-June-2013
     * Param      : Database.BatchableContext
     * Return     : None
     * Description: This method is called at the end and creates or updates Reporting Metric records.
************************************************************************************************************************************/ 
    
    public void finish(Database.BatchableContext bc) {  
        if(!userAndReportingMetric.isEmpty()){   
            Database.SaveResult[] insertResult = Database.insert(userAndReportingMetric.values(), false); 
            for (Integer i = 0; i < insertResult.size(); i++) {
                if (insertResult[i].isSuccess()) {
                    System.debug('Successfully updated Record ID: '+ insertResult[i].getId());
                } else {
                    System.debug('The error reported was: '+ insertResult[i].getErrors()[0].getMessage() + '\n');
                }
            } 
        }  
    }  
}