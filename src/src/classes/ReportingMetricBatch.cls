/***************************************************************************************************************************************
 * Author     : Vivek Patel
 * Date       : 19-June-2013
 * Description: This batch will run weekly and monthly to calculate Reporting Metric on weekly and monthly basis.
 * Requirement: Weekly and Monthly batch to calculate Reporting Metric.
 * History
     Version             : 1.0
     Author Last Updated : Vivek Patel 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
public class ReportingMetricBatch implements Database.Batchable < sObject > , Database.Stateful {
    String queryString;
    Map < String, Map < String, List < Task >>> regionWithTypeAndKnocks;
    Map < String, Map < String, Reporting_Metric__c >> regionAndReportingMetric;
    Reporting_Metric__c rmNationalObj;
    Map < String, Map < String, Map < Id, Map < Integer, Set < String >>> >> userAndHoursWorked;
    Map < String, Map < String, Set < Id >>> regionWithProductiveUserCount;
    Map < String, Map < String, Set < Id >>> regionWithProductiveStartUserCount;

    /***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 19-June-2013
     * Param      : None
     * Return     : None
     * Description: This is constructor of the class. It creates Reporting Metric records so that they can be udpated later on.
     ************************************************************************************************************************************/

    public ReportingMetricBatch(String frequency) {
        Reporting_Metric__c rmObj;
        Map < String, Map < String, Integer >> regionWithUserCount = new Map < String, Map < String, Integer >> ();
        regionAndReportingMetric = new Map < String, Map < String, Reporting_Metric__c >> ();
        userAndHoursWorked = new Map < String, Map < String, Map < Id, Map < Integer, Set < String >>> >> ();
        regionWithProductiveUserCount = new Map < String, Map < String, Set < Id >>> ();
        regionWithProductiveStartUserCount = new Map < String, Map < String, Set < Id >>> ();

        Id dsrProfileId = [SELECT Id FROM Profile WHERE Name = : Label.DSRProfileName].Id;
        for (User usr: [SELECT Id, Region__c, Sales_Rep_Type__c FROM User WHERE IsActive = True AND ProfileId = : dsrProfileId]) {
            if (regionWithUserCount.keySet().contains(usr.Region__c)) {
                if (usr.Sales_Rep_Type__c == Label.DSRType_Winback || usr.Sales_Rep_Type__c == Label.DSRType_USR) {
                    if (regionWithUserCount.get(usr.Region__c).keySet().contains(Label.DSRType_SFU))
                        regionWithUserCount.get(usr.Region__c).put(Label.DSRType_SFU, regionWithUserCount.get(usr.Region__c).get(Label.DSRType_SFU) + 1);
                    else
                        regionWithUserCount.get(usr.Region__c).put(Label.DSRType_SFU, 1);
                } else {
                    if (regionWithUserCount.get(usr.Region__c).keySet().contains(usr.Sales_Rep_Type__c))
                        regionWithUserCount.get(usr.Region__c).put(usr.Sales_Rep_Type__c, regionWithUserCount.get(usr.Region__c).get(usr.Sales_Rep_Type__c) + 1);
                    else
                        regionWithUserCount.get(usr.Region__c).put(usr.Sales_Rep_Type__c, 1);
                }
            } else {
                if (usr.Sales_Rep_Type__c == Label.DSRType_Winback || usr.Sales_Rep_Type__c == Label.DSRType_USR)
                    regionWithUserCount.put(usr.Region__c, new Map < String, Integer > {
                        Label.DSRType_SFU => 1
                    });
                else
                    regionWithUserCount.put(usr.Region__c, new Map < String, Integer > {
                        usr.Sales_Rep_Type__c => 1
                    });
            }
        }

        System.debug('+++regionWithUserCount++' + regionWithUserCount);

        Id metricRecordTypeId;
        String metricName;
        Date metricCreatedDate;
        String knockRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(Label.Knock).getRecordTypeId();
        queryString = 'SELECT Id, Disposition__c, Region__c, Knocked_Date__c, DSR_Type__c, Dwelling_Type__c, Sales_Type__c, Off_Turf__c, Disposition_Latitude__c, Disposition_Longitude__c, Hour_of_Day__c, OwnerId  FROM Task WHERE RecordTypeId=\'' + knockRecordTypeId + '\' AND Region__c != \'Global\'';

        if (frequency == 'Weekly') {
            queryString += ' AND Knocked_Date__c >= LAST_WEEK AND Knocked_Date__c != THIS_WEEK';
            metricRecordTypeId = Schema.SObjectType.Reporting_Metric__c.getRecordTypeInfosByName().get(Label.RM_Week_Rec_Type).getRecordTypeId();
            metricName = Label.Report_Stats_Weekly + ' ' + (System.Today() - 7).format() + ' ' + Label.To + ' ' + (System.Today() - 1).format();
            metricCreatedDate = System.Today();
        } else if (frequency == 'Monthly') {
            queryString += ' AND Knocked_Date__c >= LAST_MONTH AND Knocked_Date__c != THIS_MONTH';
            metricRecordTypeId = Schema.SObjectType.Reporting_Metric__c.getRecordTypeInfosByName().get(Label.RM_Month_Rec_Type).getRecordTypeId();
            Date monthEndDate = Date.today().toStartOfMonth().addDays(-1);
            metricName = Label.Report_Stats_Montly + ' ' + monthEndDate.toStartOfMonth().format() + ' ' + Label.To + ' ' + monthEndDate.format();
            metricCreatedDate = System.today();
        }

        rmNationalObj = new Reporting_Metric__c();
        rmNationalObj.Name = metricName;
        rmNationalObj.Region__c = Label.DivisionGlobal;
        rmNationalObj.DSR_Type__c = Label.DSRType_All;
        rmNationalObj.RecordTypeId = metricRecordTypeId;
        rmNationalObj.Of_Knocks__c = 0;
        rmNationalObj.Of_Contacts__c = 0;
        rmNationalObj.Of_Knocks_SFU__c = 0;
        rmNationalObj.Of_Knocks_MDU__c = 0;
        rmNationalObj.Of_Starts__c = 0;
        rmNationalObj.Of_Starts_SFU__c = 0;
        rmNationalObj.Of_Starts_MDU__c = 0;
        rmNationalObj.Of_Winback_Starts__c = 0;
        rmNationalObj.Of_On_Turf_Starts__c = 0;
        rmNationalObj.Of_Knocks_with_GPS__c = 0;
        rmNationalObj.Of_Dispositions_4_through_9pm__c = 0;
        rmNationalObj.Of_Days__c = 0;
        rmNationalObj.Of_Hours__c = 0;
        rmNationalObj.Of_Productive_Users_In_Region__c = 0;
        rmNationalObj.Of_Productive_Users_With_Start__c = 0;
        rmNationalObj.Of_Active_Users_In_Region__c = 0;
        rmNationalObj.Created_Date__c = metricCreatedDate;

        for (Division divObj: [SELECT Id, Name FROM Division where Name != : Label.DivisionGlobal]) {
            regionAndReportingMetric.put(divObj.Name, new Map < String, Reporting_Metric__c > ());
            regionWithProductiveUserCount.put(divObj.Name, new Map < String, Set < Id >> ());
            regionWithProductiveStartUserCount.put(divObj.Name, new Map < String, Set < Id >> ());
            userAndHoursWorked.put(divObj.Name, new Map < String, Map < Id, Map < Integer, Set < String >>> > ());

            for (String dsrType: new List < String > {
                Label.DSRType_SFU, Label.DSRType_MDU, Label.DSRType_XH, Label.DSRType_Con, Label.DSRType_All
            }) {
                rmObj = new Reporting_Metric__c();
                rmObj.Name = metricName;
                rmObj.Region__c = divObj.Name;
                rmObj.RecordTypeId = metricRecordTypeId;
                rmObj.Of_Knocks__c = 0;
                rmObj.Of_Contacts__c = 0;
                rmObj.Of_Knocks_SFU__c = 0;
                rmObj.Of_Knocks_MDU__c = 0;
                rmObj.Of_Starts__c = 0;
                rmObj.Of_Starts_SFU__c = 0;
                rmObj.Of_Starts_MDU__c = 0;
                rmObj.Of_Winback_Starts__c = 0;
                rmObj.Of_On_Turf_Starts__c = 0;
                rmObj.Of_Knocks_with_GPS__c = 0;
                rmObj.Of_Dispositions_4_through_9pm__c = 0;
                rmObj.Of_Days__c = 0;
                rmObj.Of_Hours__c = 0;
                rmObj.Of_Productive_Users_In_Region__c = 0;
                rmObj.Of_Productive_Users_With_Start__c = 0;
                rmObj.Of_Active_Users_In_Region__c = 0;

                if ((regionWithUserCount.get(divObj.Name) == null || regionWithUserCount.get(divObj.Name).get(dsrType) == null) && dsrType != Label.DSRType_All) {
                    rmObj.Of_Active_Users_In_Region__c = 0;
                } else {
                    if (dsrType == Label.DSRType_All) {
                        if (regionWithUserCount.get(divObj.Name) != null) {
                            for (String dsrType1: regionWithUserCount.get(divObj.Name).keySet()) {
                                if (regionWithUserCount.get(divObj.Name).get(dsrType1) != null)
                                    rmObj.Of_Active_Users_In_Region__c += regionWithUserCount.get(divObj.Name).get(dsrType1);
                            }
                        }
                    } else {
                        rmObj.Of_Active_Users_In_Region__c = regionWithUserCount.get(divObj.Name).get(dsrType);
                        rmNationalObj.Of_Active_Users_In_Region__c += regionWithUserCount.get(divObj.Name).get(dsrType);
                    }
                }

                rmObj.DSR_Type__c = dsrType;
                rmObj.Created_Date__c = metricCreatedDate;
                regionAndReportingMetric.get(divObj.Name).put(dsrType, rmObj);
                regionWithProductiveUserCount.get(divObj.Name).put(dsrType, new Set < Id > ());
                regionWithProductiveStartUserCount.get(divObj.Name).put(dsrType, new Set < Id > ());
                userAndHoursWorked.get(divObj.Name).put(dsrType, new Map < Id, Map < Integer, Set < String >>> ());
            }
        }
        System.debug('+++regionAndReportingMetric++' + regionAndReportingMetric);
        System.debug('+++queryString++' + queryString);
    }

    /***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 19-June-2013
     * Param      : BatchableContext
     * Return     : Database.querylocator
     * Description: This method is called when the batch process starts and gathers knocks for processing.
     ************************************************************************************************************************************/

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(queryString);
    }

    /***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 19-June-2013
     * Param      : Database.BatchableContext, List<sObject>
     * Return     : None
     * Description: This method called after the start method to calculate reporting metrics.
     ************************************************************************************************************************************/

    public void execute(Database.BatchableContext batchContext, List < sObject > scope) {
        regionWithTypeAndKnocks = new Map < String, Map < String, List < Task >>> ();

        for (Task knockObj: (List < Task > ) scope) {
            if (regionWithTypeAndKnocks.containsKey(knockObj.Region__c)) {
                if (knockObj.DSR_Type__c == Label.DSRType_Winback || knockObj.DSR_Type__c == Label.DSRType_USR) {
                    if (regionWithTypeAndKnocks.get(knockObj.Region__c).keySet().contains(Label.DSRType_SFU))
                        regionWithTypeAndKnocks.get(knockObj.Region__c).get(Label.DSRType_SFU).add(knockObj);
                    else
                        regionWithTypeAndKnocks.get(knockObj.Region__c).put(Label.DSRType_SFU, new List < Task > {
                            knockObj
                        });
                } else {
                    if (regionWithTypeAndKnocks.get(knockObj.Region__c).keySet().contains(knockObj.DSR_Type__c))
                        regionWithTypeAndKnocks.get(knockObj.Region__c).get(knockObj.DSR_Type__c).add(knockObj);
                    else
                        regionWithTypeAndKnocks.get(knockObj.Region__c).put(knockObj.DSR_Type__c, new List < Task > {
                            knockObj
                        });
                }
            } else {
                if (knockObj.DSR_Type__c == Label.DSRType_Winback || knockObj.DSR_Type__c == Label.DSRType_USR)
                    regionWithTypeAndKnocks.put(knockObj.Region__c, new Map < String, List < Task >> {
                        Label.DSRType_SFU => new List < Task > {
                            knockObj
                        }
                    });
                else
                    regionWithTypeAndKnocks.put(knockObj.Region__c, new Map < String, List < Task >> {
                        knockObj.DSR_Type__c => new List < Task > {
                            knockObj
                        }
                    });
            }
        }

        System.debug('+++regionWithTypeAndKnocks++' + regionWithTypeAndKnocks);

        for (String region: regionWithTypeAndKnocks.keySet()) {
            if (region == null)
                continue;
            for (String dsrType: regionWithTypeAndKnocks.get(region).keySet()) {
                if (dsrType == null)
                    continue;

                Integer hourOfDay;
                System.debug('++Region++' + region);
                System.debug('++regionAndReportingMetric.get(region)++' + regionAndReportingMetric.get(region));
                System.debug('++dsrType++'+ dsrType);
                if (regionAndReportingMetric.get(region).get(dsrType) != null) {
                    System.debug('++regionAndReportingMetric.get(region).get(dsrType)++' + regionAndReportingMetric.get(region).get(dsrType));
                    System.debug('++regionAndReportingMetric.get(region).get(dsrType).Of_Knocks__c++' + regionAndReportingMetric.get(region).get(dsrType).Of_Knocks__c);

                    System.debug('++regionWithTypeAndKnocks.get(region)++' + regionWithTypeAndKnocks.get(region));
                    System.debug('++regionWithTypeAndKnocks.get(region).get(dsrType)++' + regionWithTypeAndKnocks.get(region).get(dsrType));
                    System.debug('++regionWithTypeAndKnocks.get(region).get(dsrType).size()++' + regionWithTypeAndKnocks.get(region).get(dsrType).size());

                    regionAndReportingMetric.get(region).get(dsrType).Of_Knocks__c += regionWithTypeAndKnocks.get(region).get(dsrType).size();
                    regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Knocks__c += regionWithTypeAndKnocks.get(region).get(dsrType).size();
                    rmNationalObj.Of_Knocks__c += regionWithTypeAndKnocks.get(region).get(dsrType).size();

                    for (Task knockObj: regionWithTypeAndKnocks.get(region).get(dsrType)) {
                        if (knockObj.Disposition__c == Label.DispositionTypeClose || knockObj.Disposition__c == Label.DispositionTypeEngage || knockObj.Disposition__c == Label.DispositionTypeContact || knockObj.Disposition__c == Label.DispositionTypePosition || knockObj.Disposition__c == Label.DispositionTypeDiscover || knockObj.Disposition__c == Label.DispositionTypeStart) {
                            regionAndReportingMetric.get(region).get(dsrType).Of_Contacts__c += 1;
                            regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Contacts__c += 1;
                            rmNationalObj.Of_Contacts__c += 1;
                        }

                        if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_SF) {
                            regionAndReportingMetric.get(region).get(dsrType).Of_Knocks_SFU__c += 1;
                            regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Knocks_SFU__c += 1;
                            rmNationalObj.Of_Knocks_SFU__c += 1;
                        }
                        if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_SFU) {
                            regionAndReportingMetric.get(region).get(dsrType).Of_Knocks_SFU__c += 1;
                            regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Knocks_SFU__c += 1;
                            rmNationalObj.Of_Knocks_SFU__c += 1;
                        }
                        if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_NBB) {
                            regionAndReportingMetric.get(region).get(dsrType).Of_Knocks_SFU__c += 1;
                            regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Knocks_SFU__c += 1;
                            rmNationalObj.Of_Knocks_SFU__c += 1;
                        }
                        if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_SFUAbbr) {
                            regionAndReportingMetric.get(region).get(dsrType).Of_Knocks_SFU__c += 1;
                            regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Knocks_SFU__c += 1;
                            rmNationalObj.Of_Knocks_SFU__c += 1;
                        }
                        if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_Other) {
                            regionAndReportingMetric.get(region).get(dsrType).Of_Knocks_SFU__c += 1;
                            regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Knocks_SFU__c += 1;
                            rmNationalObj.Of_Knocks_SFU__c += 1;
                        }

                        if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_BBM) {
                            regionAndReportingMetric.get(region).get(dsrType).Of_Knocks_MDU__c += 1;
                            regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Knocks_MDU__c += 1;
                            rmNationalObj.Of_Knocks_MDU__c += 1;
                        }
                        if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_BBMDU) {
                            regionAndReportingMetric.get(region).get(dsrType).Of_Knocks_MDU__c += 1;
                            regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Knocks_MDU__c += 1;
                            rmNationalObj.Of_Knocks_MDU__c += 1;
                        }
                        if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_MDU) {
                            regionAndReportingMetric.get(region).get(dsrType).Of_Knocks_MDU__c += 1;
                            regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Knocks_MDU__c += 1;
                            rmNationalObj.Of_Knocks_MDU__c += 1;
                        }
                        if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_NBBMDU) {
                            regionAndReportingMetric.get(region).get(dsrType).Of_Knocks_MDU__c += 1;
                            regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Knocks_MDU__c += 1;
                            rmNationalObj.Of_Knocks_MDU__c += 1;
                        }
                        if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_MDUAbbr) {
                            regionAndReportingMetric.get(region).get(dsrType).Of_Knocks_MDU__c += 1;
                            regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Knocks_MDU__c += 1;
                            rmNationalObj.Of_Knocks_MDU__c += 1;
                        }
                        

                        if (knockObj.Disposition__c == Label.DispositionTypeStart) {
                            regionAndReportingMetric.get(region).get(dsrType).Of_Starts__c += 1;
                            regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Starts__c += 1;
                            rmNationalObj.Of_Starts__c += 1;

                            if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_SF) {
                                regionAndReportingMetric.get(region).get(dsrType).Of_Starts_SFU__c += 1;
                                regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Starts_SFU__c += 1;
                                rmNationalObj.Of_Starts_SFU__c += 1;
                            }
                            if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_SFU) {
                                regionAndReportingMetric.get(region).get(dsrType).Of_Starts_SFU__c += 1;
                                regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Starts_SFU__c += 1;
                                rmNationalObj.Of_Starts_SFU__c += 1;
                            }
                            if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_NBB) {
                                regionAndReportingMetric.get(region).get(dsrType).Of_Starts_SFU__c += 1;
                                regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Starts_SFU__c += 1;
                                rmNationalObj.Of_Starts_SFU__c += 1;
                            }
                            if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_SFUAbbr) {
                                regionAndReportingMetric.get(region).get(dsrType).Of_Starts_SFU__c += 1;
                                regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Starts_SFU__c += 1;
                                rmNationalObj.Of_Starts_SFU__c += 1;
                            }
                            if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_Other) {
                                regionAndReportingMetric.get(region).get(dsrType).Of_Starts_SFU__c += 1;
                                regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Starts_SFU__c += 1;
                                rmNationalObj.Of_Starts_SFU__c += 1;
                            }

                            if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_BBM) {
                                regionAndReportingMetric.get(region).get(dsrType).Of_Starts_MDU__c += 1;
                                regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Starts_MDU__c += 1;
                                rmNationalObj.Of_Starts_MDU__c += 1;
                            }
                            if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_BBMDU) {
                                regionAndReportingMetric.get(region).get(dsrType).Of_Starts_MDU__c += 1;
                                regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Starts_MDU__c += 1;
                                rmNationalObj.Of_Starts_MDU__c += 1;
                            }
                            if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_MDU) {
                                regionAndReportingMetric.get(region).get(dsrType).Of_Starts_MDU__c += 1;
                                regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Starts_MDU__c += 1;
                                rmNationalObj.Of_Starts_MDU__c += 1;
                            }
                            if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_NBBMDU) {
                                regionAndReportingMetric.get(region).get(dsrType).Of_Starts_MDU__c += 1;
                                regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Starts_MDU__c += 1;
                                rmNationalObj.Of_Starts_MDU__c += 1;
                            }
                            if (knockObj.Dwelling_Type__c == Label.Addrs_Dwell_Type_MDUAbbr) {
                                regionAndReportingMetric.get(region).get(dsrType).Of_Starts_MDU__c += 1;
                                regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Starts_MDU__c += 1;
                                rmNationalObj.Of_Starts_MDU__c += 1;
                            }

                            if (knockObj.Sales_Type__c == Label.KnockSalesType_Winback) {
                                regionAndReportingMetric.get(region).get(dsrType).Of_Winback_Starts__c += 1;
                                regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Winback_Starts__c += 1;
                                rmNationalObj.Of_Winback_Starts__c += 1;
                            }

                            if (knockObj.Off_Turf__c == false) {
                                regionAndReportingMetric.get(region).get(dsrType).Of_On_Turf_Starts__c += 1;
                                regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_On_Turf_Starts__c += 1;
                                rmNationalObj.Of_On_Turf_Starts__c += 1;
                            }
                        }

                        if (knockObj.Disposition_Latitude__c != null && knockObj.Disposition_Longitude__c != null) {
                            regionAndReportingMetric.get(region).get(dsrType).Of_Knocks_with_GPS__c += 1;
                            regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Knocks_with_GPS__c += 1;
                            rmNationalObj.Of_Knocks_with_GPS__c += 1;
                        }

                        hourOfDay = Integer.valueOf(knockObj.Hour_of_Day__c.left(2));
                        if (hourOfDay >= 16 && hourOfDay < 21) {
                            regionAndReportingMetric.get(region).get(dsrType).Of_Dispositions_4_through_9pm__c += 1;
                            regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Dispositions_4_through_9pm__c += 1;
                            rmNationalObj.Of_Dispositions_4_through_9pm__c += 1;
                        }

                        if (userAndHoursWorked.get(region).get(dsrType).keySet().contains(knockObj.OwnerId)) {
                            if (userAndHoursWorked.get(region).get(dsrType).get(knockObj.OwnerId).keySet().contains(knockObj.Knocked_Date__c.day())) {
                                userAndHoursWorked.get(region).get(dsrType).get(knockObj.OwnerId).get(knockObj.Knocked_Date__c.day()).add(knockObj.Hour_of_Day__c);
                            } else {
                                userAndHoursWorked.get(region).get(dsrType).get(knockObj.OwnerId).put(knockObj.Knocked_Date__c.day(), new Set < String > {
                                    knockObj.Hour_of_Day__c
                                });
                            }
                        } else {
                            userAndHoursWorked.get(region).get(dsrType).put(knockObj.OwnerId, new Map < Integer, Set < String >> {
                                knockObj.Knocked_Date__c.day() => new Set < String > {
                                    knockObj.Hour_of_Day__c
                                }
                            });
                        }

                        regionWithProductiveUserCount.get(region).get(dsrType).add(knockObj.OwnerId);
                        if (knockObj.Disposition__c == Label.DispositionTypeStart) {
                            regionWithProductiveStartUserCount.get(region).get(dsrType).add(knockObj.OwnerId);
                        }
                    }
                }
            }
            System.debug('+++regionAndReportingMetric++' + regionAndReportingMetric);
        }
    }

    /***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 19-June-2013
     * Param      : Database.BatchableContext
     * Return     : None
     * Description: This method is called at the end and creates Reporting Metric records.
     ************************************************************************************************************************************/

    public void finish(Database.BatchableContext bc) {

        List < Reporting_Metric__c > metricList = new List < Reporting_Metric__c > ();
        for (String region: regionAndReportingMetric.keySet()) {
            for (String dsrType: regionAndReportingMetric.get(region).keySet()) {
                if (dsrType != Label.DSRType_All) {
                    for (Id userId: userAndHoursWorked.get(region).get(dsrType).keySet()) {
                        regionAndReportingMetric.get(region).get(dsrType).Of_Days__c += userAndHoursWorked.get(region).get(dsrType).get(userId).values().size();
                        regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Days__c += userAndHoursWorked.get(region).get(dsrType).get(userId).values().size();
                        rmNationalObj.Of_Days__c += userAndHoursWorked.get(region).get(dsrType).get(userId).values().size();

                        for (Integer dayOfWeekOrMonth: userAndHoursWorked.get(region).get(dsrType).get(userId).keySet()) {
                            regionAndReportingMetric.get(region).get(dsrType).Of_Hours__c += userAndHoursWorked.get(region).get(dsrType).get(userId).get(dayOfWeekOrMonth).size();
                            regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Hours__c += userAndHoursWorked.get(region).get(dsrType).get(userId).get(dayOfWeekOrMonth).size();
                            rmNationalObj.Of_Hours__c += userAndHoursWorked.get(region).get(dsrType).get(userId).get(dayOfWeekOrMonth).size();
                        }
                    }

                    regionAndReportingMetric.get(region).get(dsrType).Of_Productive_Users_In_Region__c = regionWithProductiveUserCount.get(region).get(dsrType).size();
                    regionAndReportingMetric.get(region).get(dsrType).Of_Productive_Users_With_Start__c = regionWithProductiveStartUserCount.get(region).get(dsrType).size();

                    regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Productive_Users_In_Region__c += regionWithProductiveUserCount.get(region).get(dsrType).size();
                    regionAndReportingMetric.get(region).get(Label.DSRType_All).Of_Productive_Users_With_Start__c += regionWithProductiveStartUserCount.get(region).get(dsrType).size();

                    rmNationalObj.Of_Productive_Users_In_Region__c += regionWithProductiveUserCount.get(region).get(dsrType).size();
                    rmNationalObj.Of_Productive_Users_With_Start__c += regionWithProductiveStartUserCount.get(region).get(dsrType).size();

                    metricList.add(regionAndReportingMetric.get(region).get(dsrType));
                }
            }
            metricList.add(regionAndReportingMetric.get(region).get(Label.DSRType_All));
        }
        metricList.add(rmNationalObj);
        System.debug('+++metricList++' + metricList);
        Database.SaveResult[] saveResult = Database.Insert(metricList, false);
        for (Integer i = 0; i < saveResult.size(); i++) {
            if (saveResult[i].isSuccess()) {
                System.debug('Successfully created Record ID: ' + saveResult[i].getId());
            } else {
                System.debug('The error reported was: ' + saveResult[i].getErrors()[0].getMessage() + '\n');
            }
        }
    }
}