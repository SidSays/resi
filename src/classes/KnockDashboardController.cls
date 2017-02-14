/**************************************************************************************************
Name : KnockDashboardHistController
Description : This controller class use to fetch knock history data for last 60 days to create VF dashboard
User Story : US526172
Date : 11/9/2015
Author : Ashish Sonawane
***************************************************************************************************/

public class KnockDashboardController{

    private static Map<Id, String> mapSMB = new Map<Id,String> ();
    //public static integer refreshInterval{get;set;}
    private static final string CENTRAL_DIVISION = 'Central';
    private static final string NORTHEAST_DIVISION = 'Northeast';
    private static final string WEST_DIVISION = 'West';
        
    private static final String knockRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(System.Label.Knock.trim()).getRecordTypeId();           
    
    /*This method is call on page load and on clicking refresh button on the VF page*/  
    public PageReference refresh_logic() {
        
        KnockHistoryDashboard__c knock1 = KnockHistoryDashboard__c.getInstance('First Record');
        knock1.LastVisitedDate__c  = System.now();
        update knock1; 
        return null;
                      
    }
    
    /* This method will diplay the last refresh time on VF page*/
    public String getDatevalue(){
   
        KnockHistoryDashboard__c knock = KnockHistoryDashboard__c.getInstance('First Record');
        TimeZone tz = UserInfo.getTimeZone();
        DateTime localTime = knock.LastVisitedDate__c.AddSeconds(tz.getOffset(knock.LastVisitedDate__c)/10000000);    
        String displaytext = 'As of' + ' ' +  String.valueof(localtime);
        return displaytext ;
    }
        
    /* Central Division Hours Data */
    public List<KnockHistoryUtil.Data> getCentralKnockHrsData(){             
        return GenericCalulateHoursData(CENTRAL_DIVISION);          
    }
        
    /* Central Division Weekday Data */
    public List<KnockHistoryUtil.Data> getCentalKnockDaysData(){
        return GenericCalulateWeekdayData(CENTRAL_DIVISION);    
    }   
    
    
    /* North Easter Division Hours Data */
    public List<KnockHistoryUtil.Data> getNortheasternKnockHrsData(){
        return GenericCalulateHoursData(NORTHEAST_DIVISION);          
    }
    
    /* North eastern Division Weekday Data */
    public List<KnockHistoryUtil.Data> getNortheasternKnockDaysData(){
       return GenericCalulateWeekdayData(NORTHEAST_DIVISION);         
    }   
    
    
    /* Western Division Hours Data */
    public List<KnockHistoryUtil.Data> getWesternKnockHrsData(){
        return GenericCalulateHoursData(WEST_DIVISION);     
    }
    
    /* Western Division Weekday Data */
    public List<KnockHistoryUtil.Data> getWesternKnockDaysData(){
        return GenericCalulateWeekdayData(WEST_DIVISION);           
    }   
    
     /* All Division Hours Data */
    public List<KnockHistoryUtil.Data> getOverallKnockHrsData(){
        Map<Integer,Integer> thisWeek = new Map<Integer,Integer>();
        Map<Integer,Integer> monthAvgMap = new Map<Integer,Integer>();
        
        for(AggregateResult thisWeekRecords: [SELECT Count(Id) Prospects,HOUR_IN_DAY(CreatedDate) theDay
             FROM Task
             WHERE CreatedDate = TODAY
             AND RecordTypeId =: knockRecordTypeId
             GROUP BY HOUR_IN_DAY(CreatedDate)
             ORDER BY HOUR_IN_DAY(CreatedDate)   LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ]){
            thisWeek.put((Integer)thisWeekRecords.get('theDay'),(Integer)thisWeekRecords.get('Prospects'));
        }   
        Decimal prospectAvg = 0;
        
        String aggreresultStr = 'SELECT Count(Id) Prospects,HOUR_IN_DAY(CreatedDate) theDay FROM Task WHERE CreatedDate = LAST_N_DAYS:' + Label.KnockHistoryRecordsForLastNDays + ' AND RecordTypeId  =: knockRecordTypeId GROUP BY HOUR_IN_DAY(CreatedDate) ORDER BY HOUR_IN_DAY(CreatedDate)   LIMIT  '+ (Limits.getLimitQueryRows()-Limits.getQueryRows());
        /*List<AggregateResult> aggreresultStrList = database.query(aggreresultStr); 
        if(aggreresultStrList.size()>0){*/
            for(AggregateResult lastNDaysRecords: database.query(aggreresultStr)){
   
                prospectAvg += (Integer)lastNDaysRecords.get('Prospects');
                monthAvgMap.put((Integer)lastNDaysRecords.get('theDay'), (Integer)lastNDaysRecords.get('Prospects'));
            } 
        
        //}
        
        return KnockHistoryUtil.generateHoursChartData(thisWeek, monthAvgMap, prospectAvg);
    }
    
    /* All Division Weekday Data */
    public List<KnockHistoryUtil.Data> getOverallKnockDaysData(){
        Map<Integer,Integer> thisWeek = new Map<Integer,Integer>();
        Map<Integer,Integer> monthAvgMap = new Map<Integer,Integer>();
        
        for(AggregateResult thisWeekRecords: [SELECT Count(Id) prospct,Day_In_Week(CreatedDate) theDay
             FROM Task
             WHERE CreatedDate = THIS_WEEK
             AND RecordTypeId =: knockRecordTypeId 
             GROUP BY DAY_IN_WEEK(CreatedDate)
             ORDER BY DAY_IN_WEEK(CreatedDate)   LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            thisWeek.put((Integer)thisWeekRecords.get('theDay'),(Integer)thisWeekRecords.get('prospct'));
        }   
        Decimal opptyAvg = 0;
            
        String aggreresultStr = 'SELECT Count(Id) Prospct,Day_In_Week(CreatedDate) theDay FROM Task WHERE CreatedDate = LAST_N_DAYS:' + Label.KnockHistoryRecordsForLastNDays + ' AND RecordTypeId  =: knockRecordTypeId GROUP BY Day_In_Week(CreatedDate) ORDER BY Day_In_Week(CreatedDate)   LIMIT '+ (Limits.getLimitQueryRows()-Limits.getQueryRows());
        /*List<AggregateResult> aggreresultStrList = database.query(aggreresultStr);  
        if(aggreresultStrList.size()>0){*/
            for(AggregateResult lastNDaysRecords: database.query(aggreresultStr)){
             
            opptyAvg += (Integer)lastNDaysRecords.get('prospct');
            monthAvgMap.put((Integer)lastNDaysRecords.get('theDay'), (Integer)lastNDaysRecords.get('prospct'));
          }
       //} 
        return KnockHistoryUtil.generateDaysChartData(thisWeek, monthAvgMap, opptyAvg);
    } 
    
    /*
    *  This generaic method created to generate Division wise knock data on hourly basis 
    */        
    public List<KnockHistoryUtil.Data> GenericCalulateHoursData(String division){
        
        Map<Integer,Integer> thisWeek = new Map<Integer,Integer>();
        Map<Integer,Integer> monthAvgMap = new Map<Integer,Integer>();
         System.debug('Hour Genral loop##');
        for(AggregateResult thisWeekRecords: [SELECT Count(Id) Prospects,HOUR_IN_DAY(CreatedDate) theDay
                                                FROM Task
                                                WHERE CreatedDate = TODAY
                                                AND RecordTypeId =: knockRecordTypeId AND Customer_Address__r.Comcast_Division__c =: division
                                                GROUP BY HOUR_IN_DAY(CreatedDate)
                                                ORDER BY HOUR_IN_DAY(CreatedDate)   LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            
            thisWeek.put((Integer)thisWeekRecords.get('theDay'),(Integer)thisWeekRecords.get('Prospects'));
        }   
        Decimal prospectAvg = 0;
        Integer soqlLimit = Limits.getLimitQueryRows()-Limits.getQueryRows();
        String aggreresultStr = 'SELECT Count(Id) Prospects,HOUR_IN_DAY(CreatedDate) theDay FROM Task WHERE CreatedDate = LAST_N_DAYS:' + Label.KnockHistoryRecordsForLastNDays + ' AND RecordTypeId  =: knockRecordTypeId AND Customer_Address__r.Comcast_Division__c =: division GROUP BY HOUR_IN_DAY(CreatedDate) ORDER BY HOUR_IN_DAY(CreatedDate)   LIMIT '+ (Limits.getLimitQueryRows()-Limits.getQueryRows()) ;
        /*List<AggregateResult> aggreresultStrList = database.query(aggreresultStr); 
        if(aggreresultStrList.size()>0){*/
            for(AggregateResult lastNDaysRecords: database.query(aggreresultStr)){
                                                 
            prospectAvg += (Integer)lastNDaysRecords.get('Prospects');
            monthAvgMap.put((Integer)lastNDaysRecords.get('theDay'), (Integer)lastNDaysRecords.get('Prospects'));
        }
      //}  
        return KnockHistoryUtil.generateHoursChartData(thisWeek, monthAvgMap, prospectAvg); 
    }
    
     /*
    *  This generaic method created to generate Division wise knock data on weekday basis basis 
    */ 
    public List<KnockHistoryUtil.Data> GenericCalulateWeekdayData(String division){
        
        Map<Integer,Integer> thisWeek = new Map<Integer,Integer>();
        Map<Integer,Integer> monthAvgMap = new Map<Integer,Integer>();
              
        for(AggregateResult thisWeekRecords: [SELECT Count(Id) prospct,Day_In_Week(CreatedDate) theDay
             FROM Task
             WHERE CreatedDate = THIS_WEEK
             AND RecordTypeId =: knockRecordTypeId AND Customer_Address__r.Comcast_Division__c =: division
             GROUP BY DAY_IN_WEEK(CreatedDate)
             ORDER BY DAY_IN_WEEK(CreatedDate)   LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            thisWeek.put((Integer)thisWeekRecords.get('theDay'),(Integer)thisWeekRecords.get('prospct'));
        }   
        Decimal opptyAvg = 0;
        
        String aggreresultStr = 'SELECT Count(Id) Prospct,Day_In_Week(CreatedDate) theDay FROM Task WHERE CreatedDate = LAST_N_DAYS:' + Label.KnockHistoryRecordsForLastNDays + ' AND RecordTypeId  =: knockRecordTypeId AND Customer_Address__r.Comcast_Division__c =: division GROUP BY Day_In_Week(CreatedDate) ORDER BY Day_In_Week(CreatedDate)   LIMIT '+ (Limits.getLimitQueryRows()-Limits.getQueryRows());
        /*List<AggregateResult> aggreresultStrList = database.query(aggreresultStr); 
        if(aggreresultStrList.size()>0){*/
            for(AggregateResult lastNDaysRecords: database.query(aggreresultStr)){
             
            opptyAvg += (Integer)lastNDaysRecords.get('prospct');
            monthAvgMap.put((Integer)lastNDaysRecords.get('theDay'), (Integer)lastNDaysRecords.get('prospct'));
        } 
     //}
        return KnockHistoryUtil.generateDaysChartData(thisWeek, monthAvgMap, opptyAvg);
        
    }
}