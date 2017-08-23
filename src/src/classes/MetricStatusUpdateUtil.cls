/**************************************************************************************************
Name : MetricStatusUpdateUtil
Description : This class uset to set Status on Metric records base on Day remaining to end for commissiob cycle
Date : 12 Jan 2015
Author : Ashish Sonawane

***************************************************************************************************/

Public class MetricStatusUpdateUtil{
     
    //Metric Status constants
    private static final string ONTRACK_STATUS = 'OnTrack';
    private static final string BEHIND_STATUS = 'Behind';
    private static final string CRITICAL_STATUS = 'Critical'; 
    
   
    /*
    Name     : updateSdmAsmStatusPickList
    Description : This method use to set Metric status in current commission cycle 
    Date    : 12 Jan 2015
    Input   : Metric oject, Integer remainingDays 
    Return  : Metric (Updated)
    Author  : Ashish Sonawane    
    */    
    public static Metric updateSdmAsmStatusPickList(Metric oldMetric, Integer remainingDays){
        Decimal progessPercVal = 0;                     
        if(oldMetric.targetvalue >0 && oldMetric.currentvalue!=null){
            Integer roundCurrentVal = Math.round(oldMetric.currentValue);           
            progessPercVal =  roundCurrentVal*100/oldMetric.targetvalue;          
        }
        
        if(progessPercVal<=25){
            oldMetric.Status=remainingDays >=20?BEHIND_STATUS:CRITICAL_STATUS;                                  
        }else if(25<progessPercVal && progessPercVal<=75){
            if(remainingDays >=20){
                oldMetric.Status = ONTRACK_STATUS;               
            }else{
                 oldMetric.Status=remainingDays >=10 && remainingDays<20?BEHIND_STATUS:CRITICAL_STATUS;                 
            }                          
        }else if(75<progessPercVal && progessPercVal<100){
            oldMetric.Status = remainingDays >=10?ONTRACK_STATUS:BEHIND_STATUS;           
        }else {
            oldMetric.Status = ONTRACK_STATUS;          
        }
        return oldMetric;
    }

}