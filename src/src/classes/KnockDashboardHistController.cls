/**************************************************************************************************
Name : KnockDashboardHistController
Description : This controller class use to fetch knock history data for last 60 days to create VF dashboard
User Story : US526172
Date : 11/9/2015
Author : Ashish Sonawane
***************************************************************************************************/

public class KnockDashboardHistController{

    private static Map<Id, String> mapSMB = new Map<Id,String> ();
    public static integer refreshInterval{get;set;}
    private static final string CENTRAL_DIVISION = 'Central';
    private static final string NORTHEAST_DIVISION = 'Northeast';
    private static final string WEST_DIVISION = 'West';
    
    private static final String knockRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(System.Label.Knock.trim()).getRecordTypeId();           
    
    public KnockDashboardHistController(){       
        String refreshIntervalTempInMin = System.label.KnockDashboardRefreshIntervalInMinutes;
        //Refresh the page as per minute set in label, by default set to 2 min
        if(refreshIntervalTempInMin!=null && refreshIntervalTempInMin.isNumeric()){
            refreshInterval = Integer.valueOf(System.label.KnockDashboardRefreshIntervalInMinutes)*60000;
        }else{
            refreshInterval = 120000;
        }
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
             ORDER BY HOUR_IN_DAY(CreatedDate)]){
            thisWeek.put((Integer)thisWeekRecords.get('theDay'),(Integer)thisWeekRecords.get('Prospects'));
        }   
        Decimal prospectAvg = 0;
        for(AggregateResult last60DaysRecords :[SELECT Count(Id) Prospects,HOUR_IN_DAY(CreatedDate) theDay
             FROM Task
             WHERE CreatedDate = LAST_N_DAYS:60 
             AND RecordTypeId  =: knockRecordTypeId 
             GROUP BY HOUR_IN_DAY(CreatedDate)
             ORDER BY HOUR_IN_DAY(CreatedDate)]){
            prospectAvg += (Integer)last60DaysRecords.get('Prospects');
            monthAvgMap.put((Integer)last60DaysRecords.get('theDay'), (Integer)last60DaysRecords.get('Prospects'));
        } 
        
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
             ORDER BY DAY_IN_WEEK(CreatedDate)]){
            thisWeek.put((Integer)thisWeekRecords.get('theDay'),(Integer)thisWeekRecords.get('prospct'));
        }   
        Decimal opptyAvg = 0;
        for(AggregateResult last60DaysRecords :[SELECT Count(Id) prospct,Day_In_Week(CreatedDate) theDay
             FROM Task
             WHERE CreatedDate = LAST_N_DAYS:60 
             AND RecordTypeId =: knockRecordTypeId
             GROUP BY DAY_IN_WEEK(CreatedDate)
             ORDER BY DAY_IN_WEEK(CreatedDate)]){
            opptyAvg += (Integer)last60DaysRecords.get('prospct');
            monthAvgMap.put((Integer)last60DaysRecords.get('theDay'), (Integer)last60DaysRecords.get('prospct'));
        } 
        
        return KnockHistoryUtil.generateDaysChartData(thisWeek, monthAvgMap, opptyAvg);
    } 
    
    /*
    *  This generaic method created to generate Division wise knock data on hourly basis 
    */        
    public List<KnockHistoryUtil.Data> GenericCalulateHoursData(String division){
        
        Map<Integer,Integer> thisWeek = new Map<Integer,Integer>();
        Map<Integer,Integer> monthAvgMap = new Map<Integer,Integer>();
        
        for(AggregateResult thisWeekRecords: [SELECT Count(Id) Prospects,HOUR_IN_DAY(CreatedDate) theDay
                                                FROM Task
                                                WHERE CreatedDate = TODAY
                                                AND RecordTypeId =: knockRecordTypeId AND Customer_Address__r.Comcast_Division__c =: division
                                                GROUP BY HOUR_IN_DAY(CreatedDate)
                                                ORDER BY HOUR_IN_DAY(CreatedDate)]){
            
            thisWeek.put((Integer)thisWeekRecords.get('theDay'),(Integer)thisWeekRecords.get('Prospects'));
        }   
        Decimal prospectAvg = 0;
        for(AggregateResult last60DaysRecords :[SELECT Count(Id) Prospects,HOUR_IN_DAY(CreatedDate) theDay
                                                 FROM Task
                                                 WHERE CreatedDate = LAST_N_DAYS:60 
                                                 AND RecordTypeId  =: knockRecordTypeId AND Customer_Address__r.Comcast_Division__c =: division
                                                 GROUP BY HOUR_IN_DAY(CreatedDate)
                                                 ORDER BY HOUR_IN_DAY(CreatedDate)]){
            prospectAvg += (Integer)last60DaysRecords.get('Prospects');
            monthAvgMap.put((Integer)last60DaysRecords.get('theDay'), (Integer)last60DaysRecords.get('Prospects'));
        }
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
             ORDER BY DAY_IN_WEEK(CreatedDate)]){
            thisWeek.put((Integer)thisWeekRecords.get('theDay'),(Integer)thisWeekRecords.get('prospct'));
        }   
        Decimal opptyAvg = 0;
        for(AggregateResult last60DaysRecords :[SELECT Count(Id) prospct,Day_In_Week(CreatedDate) theDay
             FROM Task
             WHERE CreatedDate = LAST_N_DAYS:60 
             AND RecordTypeId =: knockRecordTypeId AND Customer_Address__r.Comcast_Division__c =: division
             GROUP BY DAY_IN_WEEK(CreatedDate)
             ORDER BY DAY_IN_WEEK(CreatedDate)]){
            opptyAvg += (Integer)last60DaysRecords.get('prospct');
            monthAvgMap.put((Integer)last60DaysRecords.get('theDay'), (Integer)last60DaysRecords.get('prospct'));
        } 
        
        return KnockHistoryUtil.generateDaysChartData(thisWeek, monthAvgMap, opptyAvg);
        
    }
}