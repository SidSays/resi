/**************************************************************************************************
Name : KnockHistoryUtil
Description : This use to create Weekly and hour dashboard data for last 60 days
User Story : US526172
Date : 11/9/2015
Author : Ashish Sonawane
***************************************************************************************************/

public class KnockHistoryUtil{
    
    public enum Day {Sun, Mon, Tue, Wed, Thus, Fri, Sat}
    //public static Map<Integer,String> hourMap = new Map<Integer,String>{0=>'12 AM',1=>'1 AM',2=>'2 AM',3=>'3 AM',4=>'4 AM',5=>'5 AM',6=>'6 AM',7=>'7 AM',8=>'8 AM',9=>'9 AM',10=>'10 AM',11=>'11 AM',12=>'12 PM',13=>'1 PM',14=>'2 PM',15=>'3 PM',16=>'4 PM',17=>'5 PM',18=>'6 PM',19=>'7 PM',20=>'8 PM',21=>'9 PM',22=>'10 PM',23=>'11 PM'};
    public static Map<Integer,String> hourMap = new Map<Integer,String>{11=>'7',12=>'8',13=>'9',14=>'10',15=>'11',16=>'12',17=>'13',18=>'14',19=>'15',20=>'16',21=>'17',22=>'18',23=>'19',0=>'20',1=>'21',2=>'22'};
    //public static Map<Integer,String> hourMap = new Map<Integer,String>{10=>'7',11=>'8',12=>'9',13=>'10',14=>'11',15=>'12',16=>'1',17=>'2',18=>'3',19=>'4',20=>'5',21=>'6',22=>'7',23=>'8',0=>'9',1=>'10'};

    //public Map<Integer,Integer> thisWeek = new Map<Integer,Integer>();
    //public Map<Integer,Integer> monthAvgMap = new Map<Integer,Integer>();
    //public Decimal opptyAvg;
  
    
    public static List<Data> generateHoursChartData(Map<Integer,Integer> thisWeek, Map<Integer,Integer> monthAvgMap, Decimal opptyAvg){

        List<Data> hoursData = new List<Data>(); 
        Integer countRecordsThisWeek;
        Decimal dayAvg;
        
        opptyAvg = (opptyAvg/720).setScale(2);
        for(integer i=11;i<=23;i++){
            countRecordsThisWeek = 0; 
            dayAvg = 0;
            
            if(thisWeek.containsKey(i)){
                countRecordsThisWeek = thisWeek.get(i);
            }
            if(monthAvgMap.containsKey(i)){    
                dayAvg += monthAvgMap.get(i);
                dayAvg = (dayAvg/60).setScale(2);               
            }
            Data plotRecords = new Data(countRecordsThisWeek, opptyAvg, dayAvg, hourMap.get(i));   
            hoursData.add(plotRecords);
        }   
        
        for(integer i=0;i<3;i++){
            countRecordsThisWeek = 0; 
            dayAvg = 0;
            
            if(thisWeek.containsKey(i)){
                countRecordsThisWeek = thisWeek.get(i);
            }
            if(monthAvgMap.containsKey(i)){    
                dayAvg += monthAvgMap.get(i);
                dayAvg = (dayAvg/60).setScale(2);
            }
            Data plotRecords = new Data(countRecordsThisWeek, opptyAvg, dayAvg, hourMap.get(i));   
            hoursData.add(plotRecords);
        }                 
        return hoursData;
    }
    
    public static List<Data> generateDaysChartData(Map<Integer,Integer> thisWeek, Map<Integer,Integer> monthAvgMap, Decimal opptyAvg){
        Map<Integer,Integer> weekMap = new Map<Integer,Integer>();
        List<Data> daysData = new List<Data>();
        
        for(integer i=0;i<60;i++)
        {
            Date startDate = system.today()-i;
            Datetime dt = (DateTime)startDate;
            String dayOfWeek = dt.format('EEEE');
            if(dayOfWeek.equalsIgnoreCase('Sunday'))
            {
                if(weekMap.containsKey(1))
                {
                    weekMap.put(1,weekMap.get(1)+1);            
                }
                else
                {
                    weekMap.put(1,1);
                }
            }   
            if(dayOfWeek.equalsIgnoreCase('Monday'))
            {
                if(weekMap.containsKey(2))
                {
                    weekMap.put(2,weekMap.get(2)+1);            
                }
                else
                {
                    weekMap.put(2,1);
                }
            }   
            if(dayOfWeek.equalsIgnoreCase('Tuesday'))
            {
                if(weekMap.containsKey(3))
                {
                    weekMap.put(3,weekMap.get(3)+1);            
                }
                else
                {
                    weekMap.put(3,1);
                }
            }   
            if(dayOfWeek.equalsIgnoreCase('Wednesday'))
            {
                if(weekMap.containsKey(4))
                {
                    weekMap.put(4,weekMap.get(4)+1);            
                }
                else
                {
                    weekMap.put(4,1);
                }
            }   
            if(dayOfWeek.equalsIgnoreCase('Thursday'))
            {
                if(weekMap.containsKey(5))
                {
                    weekMap.put(5,weekMap.get(5)+1);            
                }
                else
                {
                    weekMap.put(5,1);
                }
            }   
            if(dayOfWeek.equalsIgnoreCase('Friday'))
            {
                if(weekMap.containsKey(6))
                {
                    weekMap.put(6,weekMap.get(6)+1);            
                }
                else
                {
                    weekMap.put(6,1);
                }
            }   
            if(dayOfWeek.equalsIgnoreCase('Saturday'))
            {
                if(weekMap.containsKey(7))
                {
                    weekMap.put(7,weekMap.get(7)+1);            
                }
                else
                {
                    weekMap.put(7,1);
                }
            }               
        }
        
        opptyAvg = (opptyAvg/60).setScale(2);
        for(integer i=1;i<=7;i++){
            Integer countRecordsThisWeek = 0;
            Integer countRecordsLastWeek = 0;   
            Decimal dayAvg = 0;
            
            if(thisWeek.containsKey(i)){
                countRecordsThisWeek = thisWeek.get(i);
            }
            if(monthAvgMap.containsKey(i)){    
                    dayAvg = monthAvgMap.get(i);
                dayAvg = (dayAvg/weekMap.get(i)).setScale(2);
            }
            Data plotRecords = new Data(countRecordsThisWeek, opptyAvg, dayAvg, Day.values()[i-1].name());   
            daysData.add(plotRecords);
        }
        
        return daysData;
        
    }
    
    //Wrapper Class
    public class Data {
        public Integer countRecordsThisWeek {get;set;}
        public Decimal last60DaysAvg {get;set;}
        public Decimal weekAvg {get;set;}
        public String dayOfWeek {get;set;}
        public Data(Integer countRecordsThisWeek, Decimal last60DaysAvg, decimal weekAvg, String dayOfWeek) {
            this.countRecordsThisWeek = countRecordsThisWeek;
            this.last60DaysAvg = last60DaysAvg;
            this.weekAvg = weekAvg;
            this.dayOfWeek = dayOfWeek;
        }
    }
}