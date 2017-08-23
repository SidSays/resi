/**
* Class Name: KnockRecordRollUpSummaryBatch 
* Author: Lalit Singh, Accenture
* Date: 07-29-2015 
* Requirement #US : US481990
* Description: Rolls ups the Knock data of the reps based upon the owner name and knockdate.
* Last Modified :
*/
public class KnockRecordRollUpSummaryBatch implements Database.Batchable<sObject> {
    
    public String queryString='';
    public map<String, User> userMap = new Map<String, User>();
    private static final string NoKnock = 'No Knock';
    private static final string NoAnswer = 'No Answer';
    private static final string DoorHanger = 'Door Hanger';
    private static final string contact = 'Contact';
    private static final string Engage = 'Engage';
    private static final string Discover = 'Discover';
    private static final string Position = 'Position';
    private static final string Close = 'Close';
    private static final string Start = 'Start';
    private static final string NonMarketableAddress = 'Non-Marketable Address';
    private static final string SingleFamily = 'Single Family';
    private static final string BulkBilledMaster = 'Bulk Billed Master';
    private static final string Commercial = 'Commercial';
    private static final string BulkBilledMDU = 'Bulk Billed MDU';
    private static final string NonBulkBilledMDU = 'Non Bulk Billed MDU';
    private static final string Unknown = 'Unknown';
    private static final string SingleFamilyUnit = 'Single Family Unit';
    private static final string MultipleDwellingUnit = 'Multiple Dwelling Unit';
    private static final string Vacant = 'Vacant';
    private static final string NonBulkBilled = 'Non Bulk Billed';
    private static final string SFU = 'SFU';
    private static final string MDU = 'MDU';
    private static final string OTHER = 'OTHER';
    private static final string EXCLUDEMAPPING = 'EXCLUDE MAPPING';
    
   
    public Database.QueryLocator start(Database.BatchableContext bc) {
       Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId();
      // for(User usr : [select FirstName,LastName,CreatedById,ManagerId,PERNR__c,Region__c,division from User]){
       //       userMap.put(usr.FirstName + usr.LastName, usr);
       //}
       
       //Id lid = '00Tq0000008UlAS';
       //And Id = :lid
       //LIMIT 1
       if(queryString==''){
           //queryString = 'SELECT Id,createdDate, WhatId,OwnerFullName__c, OwnerId,Dwelling_Type__c,Region__c,Disposition_Latitude__c,Disposition__c,Knocked_Date__c,Location_Difference__c,Off_Turf__c,Sales_Type__c FROM Task where RecordTypeId = :recordTypeId' ;
           queryString = queryString+' AND RecordTypeId = :recordTypeId AND IsDeleted=false ALL ROWS';
       }
       
        return Database.getQueryLocator(queryString);
    }
    
    //Latest change as per the comments received from vijay query
     //is to be passed for the particular year so we are passing the query to the constructor.
    public KnockRecordRollUpSummaryBatch (String queryToPass){
    queryString = queryToPass;
      //Nothing Do   
    }
    public void execute(Database.BatchableContext bc, List<Task>  knockLst){ 
     try{  
        system.debug('---knockLst.size()-----' +knockLst.size());
        Map<String, List<Task>> summeryKnock = new Map<String, List<Task>>();
        Map<String, Date> knockDateMap = new Map<String, Date>();
        Map<String, Integer> knockHourMap = new Map<String, Integer>();
        Map<String, String> dsrKnockDateMap = new Map<String, String>();
        set<String> dsr = new set<String>();
        for(Task knock : knockLst){
            dsr.add(knock.OwnerId);
        }
        for(User usr : [select FirstName,LastName,Username,CreatedById,ManagerId, Manager.Name,Manager.Manager.Name,PERNR__c,Region_Formula__c,Comcast_Division__c,TimeZoneSidKey from User where Id IN :dsr LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            userMap.put(usr.FirstName + ' ' + usr.LastName, usr);
        }
        for(Task knock: knockLst){
             system.debug('------knock---' +knock);
             system.debug('----knock.Disposition__c11-----' +knock.Disposition__c);
             DateTime knockDT = knock.createdDate;
             String strConvertedDate = knockDT.format('MM/dd/yyyy HH:mm:ss',userMap.get(knock.OwnerFullName__c).TimeZoneSidKey);
             List<String> knckDt = strConvertedDate.split(' ');
             List<String> splitedDate = knckDt[0].split('/');
             List<String> SplitedTime = knckDt[1].split(':');
             dsrKnockDateMap.put(knock.Id ,knckDt[0]);
             knockDateMap.put(knock.Id , Date.newInstance(Integer.valueof(splitedDate[2]),  Integer.valueof(splitedDate[0]),Integer.valueof(splitedDate[1])));
             knockHourMap.put(knock.Id , Integer.valueof(SplitedTime[0]));
             String key = knock.OwnerId + knckDt[0] + String.valueof(knock.Off_Turf__c);
             system.debug('------key---' +key);
            if(summeryKnock.containsKey(key)){
                system.debug('------knockId---' +knock.Id);
                List<Task> tempLst = new List<Task>();
                tempLst = summeryKnock.get(key);
                tempLst.add(knock);
                summeryKnock.put(key,tempLst);
                //system.debug('------summeryKnock.values().size()---' +summeryKnock.values().size());
            }
            else{
                system.debug('------knockId---' +knock.Id);
                List<Task> tempLst = new List<Task>();
                tempLst.add(knock);
                summeryKnock.put(key,tempLst);
                system.debug('------tempLst.size()---' +tempLst.size());
            }
        }
        List<Knock_Summary__c> summeryToUpdate = new List<Knock_Summary__c>();
        Map<String, Knock_Summary__c> existingSummery = new Map<String, Knock_Summary__c>();
        
        for(Knock_Summary__c summery : [select Id, Key__c,On_Turf__c,UserName__c,Bulk_Billed_Master__c,Bulk_Billed_MDU__c,Close__c,
                                         Commercial__c,Contact__c,CreatedById,CreatedDate,Discover__c,Divison__c,Door_Hanger__c,
                                         Dsr__c,Engage__c,EXCLUDE_MAPPING__c,IsDeleted,Knocked_Date_00_Hour__c,Knocked_Date_01_Hour__c,
                                         Knocked_Date_02_Hour__c,Knocked_Date_03_Hour__c,Knocked_Date_04_Hour__c,Knocked_Date_05_Hour__c,
                                         Knocked_Date_06_Hour__c,Knocked_Date_07_Hour__c,Knocked_Date_08_Hour__c,Knocked_Date_09_Hour__c,
                                         Knocked_Date_10_Hour__c,Knocked_Date_11_Hour__c,Knocked_Date_12_Hour__c,Knocked_Date_13_Hour__c,
                                         Knocked_Date_14_Hour__c,Knocked_Date_15_Hour__c,Knocked_Date_16_Hour__c,Knocked_Date_17_Hour__c,
                                         Knocked_Date_18_Hour__c,Knocked_Date_19_Hour__c,Knocked_Date_20_Hour__c,Knocked_Date_21_Hour__c,
                                         Knocked_Date_22_Hour__c,Knocked_Date_23_Hour__c,Knock_Date__c,KNOCK_DAY__c,LastActivityDate,
                                         LastModifiedById,LastModifiedDate,Manager__c,MDU__c,Multiple_Dwelling_Unit__c,Name,
                                         Non_Bulk_Billed_MDU__c,Non_Bulk_Billed__c,Non_Marketable_Address__c,No_Answer__c,No_Knock__c,OTHER__c,
                                         OwnerId,Pernr__c,Position__c,Region__c,SFU__c,Single_Family_Unit__c,Single_Family__c,Start__c,Supervisor__c,
                                         SystemModstamp,Unknown__c,Vacant__c from Knock_Summary__c where Key__c IN :summeryKnock.keySet()]){
            existingSummery.put(summery.Key__c, summery);
        }
        for(String knockKey : summeryKnock.keySet()){
            Knock_Summary__c newknockSummary = new Knock_Summary__c();
            
            if(existingSummery.containsKey(knockKey)){
                newknockSummary = existingSummery.get(knockKey);
            }
            User knowckUser = userMap.get(summeryKnock.get(knockKey)[0].OwnerFullName__c);            
            newknockSummary.Key__c = knockKey;
            //newknockSummary.Knock_Date__c = knockDateMap.get(summeryKnock.get(knockKey)[0].Id);
            newknockSummary.Knock_Date__c = summeryKnock.get(knockKey)[0].createdDate;
            //newknockSummary.DsrKnockDate__c = dsrKnockDateMap.get(summeryKnock.get(knockKey)[0].Id);
            if(knowckUser.Comcast_Division__c != null && knowckUser.Region_Formula__c != null){
                newknockSummary.Divison__c = knowckUser.Comcast_Division__c;
                newknockSummary.Region__c  = knowckUser.Region_Formula__c;
                newknockSummary.Supervisor__c = knowckUser.Manager.Name;
                newknockSummary.Manager__c = knowckUser.Manager.Manager.Name;
            }
            newknockSummary.Pernr__c  = knowckUser.PERNR__c;
            newknockSummary.Dsr__c  = knowckUser.FirstName +' '+knowckUser.LastName;
            newknockSummary.UserName__c = knowckUser.Username;
            DateTime myDate = newknockSummary.Knock_Date__c;
            DateTime myDateTime = (DateTime) myDate;
            String dayOfWeek = myDateTime.format('EEEE');
            newknockSummary.KNOCK_DAY__c = dayOfWeek;
            if(summeryKnock.get(knockKey)[0].Off_Turf__c == true){
                newknockSummary.On_Turf__c = 'No';              
            }
            else{
                newknockSummary.On_Turf__c = 'Yes';
            }
            for(Task knock : summeryKnock.get(knockKey)){
                system.debug('----knock.Disposition__c-----' +knock.Disposition__c);
                if(knock.Disposition__c == NoKnock){
                    if(newknockSummary.No_Knock__c == null){
                        newknockSummary.No_Knock__c = 0;
                    }
                    newknockSummary.No_Knock__c = newknockSummary.No_Knock__c + 1;
                }
                else if(knock.Disposition__c == NoAnswer){
                    if(newknockSummary.No_Answer__c == null){
                        newknockSummary.No_Answer__c = 0;
                    }
                    newknockSummary.No_Answer__c = newknockSummary.No_Answer__c + 1;
                }
                else if(knock.Disposition__c == DoorHanger){
                    if(newknockSummary.Door_Hanger__c == null){
                        newknockSummary.Door_Hanger__c = 0;
                    }
                    newknockSummary.Door_Hanger__c = newknockSummary.Door_Hanger__c + 1;
                }
                else if(knock.Disposition__c == contact){
                    if(newknockSummary.Contact__c == null){
                        newknockSummary.Contact__c = 0;
                    }
                    newknockSummary.Contact__c = newknockSummary.Contact__c + 1;
                }
                else if(knock.Disposition__c == Engage){
                    if(newknockSummary.Engage__c ==null){
                        newknockSummary.Engage__c = 0;
                    }
                    newknockSummary.Engage__c = newknockSummary.Engage__c + 1;
                }
                else if(knock.Disposition__c == Discover){
                    if(newknockSummary.Discover__c == null){
                        newknockSummary.Discover__c = 0;
                    }
                    newknockSummary.Discover__c = newknockSummary.Discover__c + 1;
                }
                else if(knock.Disposition__c == Position){
                    if(newknockSummary.Position__c == null){
                        newknockSummary.Position__c = 0;
                    }
                    newknockSummary.Position__c = newknockSummary.Position__c + 1;
                }
                else if(knock.Disposition__c == Close){
                    if(newknockSummary.Close__c ==  null){
                        newknockSummary.Close__c = 0;
                    }
                    newknockSummary.Close__c = newknockSummary.Close__c + 1;
                }
                else if(knock.Disposition__c == Start){
                    if(newknockSummary.Start__c ==  null){
                        newknockSummary.Start__c = 0;
                    }
                    newknockSummary.Start__c = newknockSummary.Start__c + 1;
                }
                else if(knock.Disposition__c == NonMarketableAddress){
                    if(newknockSummary.Non_Marketable_Address__c ==null){
                        newknockSummary.Non_Marketable_Address__c = 0;
                    }
                    newknockSummary.Non_Marketable_Address__c = newknockSummary.Non_Marketable_Address__c + 1;
                }
                if(knock.Dwelling_Type__c == SingleFamily){
                    if(newknockSummary.Single_Family__c == null){
                        newknockSummary.Single_Family__c = 0;
                    }
                    newknockSummary.Single_Family__c = newknockSummary.Single_Family__c+1;
                }
                else if(knock.Dwelling_Type__c == BulkBilledMaster){
                    if(newknockSummary.Bulk_Billed_Master__c == null){
                        newknockSummary.Bulk_Billed_Master__c =0;
                    }
                    newknockSummary.Bulk_Billed_Master__c = newknockSummary.Bulk_Billed_Master__c+1;
                }
                else if(knock.Dwelling_Type__c == Commercial){
                    if(newknockSummary.Commercial__c == null){
                        newknockSummary.Commercial__c = 0;
                    }
                    newknockSummary.Commercial__c = newknockSummary.Commercial__c+1;
                }
                else if(knock.Dwelling_Type__c == BulkBilledMDU){
                    if(newknockSummary.Bulk_Billed_MDU__c ==null){
                        newknockSummary.Bulk_Billed_MDU__c =0;
                    }
                    newknockSummary.Bulk_Billed_MDU__c = newknockSummary.Bulk_Billed_MDU__c+1;
                }
                else if(knock.Dwelling_Type__c == NonBulkBilledMDU){
                    if(newknockSummary.Non_Bulk_Billed_MDU__c ==null){
                        newknockSummary.Non_Bulk_Billed_MDU__c = 0;
                    }
                    newknockSummary.Non_Bulk_Billed_MDU__c = newknockSummary.Non_Bulk_Billed_MDU__c+1;
                }
                else if(knock.Dwelling_Type__c == Unknown){
                    if(newknockSummary.Unknown__c ==null){
                        newknockSummary.Unknown__c =0;
                    }
                    newknockSummary.Unknown__c = newknockSummary.Unknown__c+1;
                }
                else if(knock.Dwelling_Type__c == SingleFamilyUnit){
                    if(newknockSummary.Single_Family_Unit__c == null){
                        newknockSummary.Single_Family_Unit__c =0;
                    }
                    newknockSummary.Single_Family_Unit__c = newknockSummary.Single_Family_Unit__c+1;
                }
                else if(knock.Dwelling_Type__c == MultipleDwellingUnit){
                    if(newknockSummary.Multiple_Dwelling_Unit__c == null){
                        newknockSummary.Multiple_Dwelling_Unit__c =0;
                    }
                    newknockSummary.Multiple_Dwelling_Unit__c = newknockSummary.Multiple_Dwelling_Unit__c+1;
                }
                else if(knock.Dwelling_Type__c == Vacant){
                    if(newknockSummary.Vacant__c ==null){
                        newknockSummary.Vacant__c =0;
                    }
                    newknockSummary.Vacant__c = newknockSummary.Vacant__c+1;
                }
                else if(knock.Dwelling_Type__c == NonBulkBilled){
                    if(newknockSummary.Non_Bulk_Billed__c ==null){
                        newknockSummary.Non_Bulk_Billed__c =0;
                    }
                    newknockSummary.Non_Bulk_Billed__c = newknockSummary.Non_Bulk_Billed__c+1;
                }
                else if(knock.Dwelling_Type__c == SFU){
                    if(newknockSummary.SFU__c == null){
                        newknockSummary.SFU__c =0;
                    }
                    newknockSummary.SFU__c = newknockSummary.SFU__c+1;
                }
                else if(knock.Dwelling_Type__c == MDU){
                    if(newknockSummary.MDU__c == null){
                        newknockSummary.MDU__c =0;
                    }
                    newknockSummary.MDU__c = newknockSummary.MDU__c+1;
                }
                else if(knock.Dwelling_Type__c == OTHER){
                    if(newknockSummary.OTHER__c == null){
                        newknockSummary.OTHER__c =0;
                    }
                    newknockSummary.OTHER__c = newknockSummary.OTHER__c+1;
                }
                else if(knock.Dwelling_Type__c == EXCLUDEMAPPING){
                    if(newknockSummary.EXCLUDE_MAPPING__c==null){
                        newknockSummary.EXCLUDE_MAPPING__c =0;
                    }
                    newknockSummary.EXCLUDE_MAPPING__c = newknockSummary.EXCLUDE_MAPPING__c+1;
                }
                Integer hrs = knockHourMap.get(knock.Id);
                system.debug('hrs'+hrs);
                if(hrs == 00){
                    if(newknockSummary.Knocked_Date_00_Hour__c==null){
                        newknockSummary.Knocked_Date_00_Hour__c = 0;
                    }
                    newknockSummary.Knocked_Date_00_Hour__c = newknockSummary.Knocked_Date_00_Hour__c + 1;
                }               
                else if(hrs == 01){
                    if(newknockSummary.Knocked_Date_01_Hour__c == null){
                        newknockSummary.Knocked_Date_01_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_01_Hour__c = newknockSummary.Knocked_Date_01_Hour__c + 1;
                }
                else if(hrs == 02){
                    if(newknockSummary.Knocked_Date_02_Hour__c == null){
                        newknockSummary.Knocked_Date_02_Hour__c =0;
                    }
                    newknockSummary.Knocked_Date_02_Hour__c = newknockSummary.Knocked_Date_02_Hour__c + 1;
                }
                else if(hrs == 03){
                    if(newknockSummary.Knocked_Date_03_Hour__c == null){
                        newknockSummary.Knocked_Date_03_Hour__c =0;
                    }
                    newknockSummary.Knocked_Date_03_Hour__c = newknockSummary.Knocked_Date_03_Hour__c + 1;
                }
                else if(hrs == 04){
                    if(newknockSummary.Knocked_Date_04_Hour__c == null){
                        newknockSummary.Knocked_Date_04_Hour__c =0;
                    }
                    newknockSummary.Knocked_Date_04_Hour__c = newknockSummary.Knocked_Date_04_Hour__c + 1;
                }
                else if(hrs == 05){
                    if(newknockSummary.Knocked_Date_05_Hour__c==null){
                        newknockSummary.Knocked_Date_05_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_05_Hour__c = newknockSummary.Knocked_Date_05_Hour__c + 1;
                }
                else if(hrs == 06){
                    if(newknockSummary.Knocked_Date_06_Hour__c ==null){
                        newknockSummary.Knocked_Date_06_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_06_Hour__c = newknockSummary.Knocked_Date_06_Hour__c + 1;
                }
                else if(hrs == 07){
                    if(newknockSummary.Knocked_Date_07_Hour__c ==null){
                        newknockSummary.Knocked_Date_07_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_07_Hour__c = newknockSummary.Knocked_Date_07_Hour__c + 1;
                }
                else if(hrs == 08){
                    if(newknockSummary.Knocked_Date_08_Hour__c==null){
                        newknockSummary.Knocked_Date_08_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_08_Hour__c = newknockSummary.Knocked_Date_08_Hour__c + 1;
                }
                else if(hrs == 09){
                    if(newknockSummary.Knocked_Date_09_Hour__c ==null){
                        newknockSummary.Knocked_Date_09_Hour__c =0;
                    }
                    newknockSummary.Knocked_Date_09_Hour__c = newknockSummary.Knocked_Date_09_Hour__c + 1;
                }
                else if(hrs == 10){
                    if(newknockSummary.Knocked_Date_10_Hour__c==null){
                        newknockSummary.Knocked_Date_10_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_10_Hour__c = newknockSummary.Knocked_Date_10_Hour__c + 1;
                }
                else if(hrs == 11){
                    if(newknockSummary.Knocked_Date_11_Hour__c==null){
                        newknockSummary.Knocked_Date_11_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_11_Hour__c = newknockSummary.Knocked_Date_11_Hour__c + 1;
                }
                else if(hrs == 12){
                    if(newknockSummary.Knocked_Date_12_Hour__c==null){
                        newknockSummary.Knocked_Date_12_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_12_Hour__c = newknockSummary.Knocked_Date_12_Hour__c + 1;
                }
                else if(hrs == 13){
                    if(newknockSummary.Knocked_Date_13_Hour__c==null){
                        newknockSummary.Knocked_Date_13_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_13_Hour__c = newknockSummary.Knocked_Date_13_Hour__c + 1;
                }
                else if(hrs == 14){
                    if(newknockSummary.Knocked_Date_14_Hour__c==null){
                        newknockSummary.Knocked_Date_14_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_14_Hour__c = newknockSummary.Knocked_Date_14_Hour__c + 1;
                }
                else if(hrs == 15){
                    if(newknockSummary.Knocked_Date_15_Hour__c==null){
                        newknockSummary.Knocked_Date_15_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_15_Hour__c = newknockSummary.Knocked_Date_15_Hour__c + 1;
                }
                else if(hrs == 16){
                    if(newknockSummary.Knocked_Date_16_Hour__c==null){
                        newknockSummary.Knocked_Date_16_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_16_Hour__c = newknockSummary.Knocked_Date_16_Hour__c + 1;
                }
                else if(hrs == 17){
                    if(newknockSummary.Knocked_Date_17_Hour__c==null){
                        newknockSummary.Knocked_Date_17_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_17_Hour__c = newknockSummary.Knocked_Date_17_Hour__c + 1;
                }
                else if(hrs == 18){
                    if(newknockSummary.Knocked_Date_18_Hour__c==null){
                        newknockSummary.Knocked_Date_18_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_18_Hour__c = newknockSummary.Knocked_Date_18_Hour__c + 1;
                }
                else if(hrs == 19){
                    if(newknockSummary.Knocked_Date_19_Hour__c==null){
                        newknockSummary.Knocked_Date_19_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_19_Hour__c = newknockSummary.Knocked_Date_19_Hour__c + 1;
                }
                else if(hrs == 20){
                    if(newknockSummary.Knocked_Date_20_Hour__c==null){
                        newknockSummary.Knocked_Date_20_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_20_Hour__c = newknockSummary.Knocked_Date_20_Hour__c + 1;
                }
                else if(hrs == 21){
                    if(newknockSummary.Knocked_Date_21_Hour__c==null){
                        newknockSummary.Knocked_Date_21_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_21_Hour__c = newknockSummary.Knocked_Date_21_Hour__c + 1;
                }
                else if(hrs == 22){
                    if(newknockSummary.Knocked_Date_22_Hour__c==null){
                        newknockSummary.Knocked_Date_22_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_22_Hour__c = newknockSummary.Knocked_Date_22_Hour__c + 1;
                }
                else if(hrs == 23){
                    if(newknockSummary.Knocked_Date_23_Hour__c==null){
                        newknockSummary.Knocked_Date_23_Hour__c=0;
                    }
                    newknockSummary.Knocked_Date_23_Hour__c = newknockSummary.Knocked_Date_23_Hour__c + 1;
                }
                
            }
            summeryToUpdate.add(newknockSummary);
            
        }
        
            //database.upsert(summeryToUpdate, true);
            upsert summeryToUpdate Key__c;
           }
        catch(Exception ex){
            System.debug('Following exception occurred :'+ex.getMessage());
            Integration_Error_Log__c log = new Integration_Error_Log__c();
            log.Error_Exception__c = ex.getMessage();
            log.Server_Response__c = 'Knock Summery Error';
            insert log;            
        }
     }
     
    public void finish(Database.BatchableContext bc) {
      
      
     }
}