/******************************************************************************************************************
 * Author     : 
 * Date       : 
 * Description: Contains Supporting actions for Metric Triggers
 * @Last Modified By: Amit Kumar Pradhan
 * @Description: Color coding logic for Metrics of Indirect
 * @User Story: US1025305(Indirect - Coach for Indirect - Color Coding - Part 1),
                US1064046(Indirect - Coach for Indirect - Color Coding - Part 2 - Store Visit)
 * @Last Modified Date: 31-Mar-2017  
 ********************************************************************************************************************/

public class MetricTriggerController {    
    //Metric Status constants
    private static final String ONTRACK_STATUS = 'OnTrack';
    private static final String BEHIND_STATUS = 'Behind';
    private static final String CRITICAL_STATUS = 'Critical'; 
    private static final String TYPE_RGU = 'RGU';
    private static final String TYPE_ACTIVITY = 'Activity'; 
    private static final String TYPE_COMMUNITIES = 'Communities';
    private static final string COMPLETED_STATUS = 'Completed';
    private static final string QUARTERLY_METRICS = 'Quarterly_Metrics';
    private static final string COACH_FUNCTIONAL_AREA = 'Coach';
    
    public static boolean allowValidation = true;
        public static void metricValidation() {
            if(allowValidation ){
                MetricTriggerOperations.metricPermissionValidation();
                MetricTriggerOperations.aeContractorAndMgrValidation();
            }
        }
        
    /************
    * @Description: This method sets Metric status as per the currentValue, targetValue and remaining days.
    * @Author: Malay Desai, Accenture
    * @Date: 23-March-2016
    * @Param: newList
    * @Return: void.
    * @Last Modified By: Amit Kumar Pradhan
    * @Description: Color coding logic for Metrics of Indirect
    * @User Story: US1025305(Indirect - Coach for Indirect - Color Coding - Part 1),
                   US1064046(Indirect - Coach for Indirect - Color Coding - Part 2 - Store Visit)
    * @Last Modified Date: 31-Mar-2017                 
    *************/   
    public static void updateMetricStatus(List<Metric> newList){
        Integer remainingDays;
        Decimal progessPercVal = 0; 
        try{
            for(Metric aMetric :newList){
                //Start: Part of US1064046 and US1025305
                /***************************
                 * @Description: Color coding logic for Metrics of Indirect
                 * @User Story: US1025305(Indirect - Coach for Indirect - Color Coding - Part 1),
                                US1064046(Indirect - Coach for Indirect - Color Coding - Part 2 - Store Visit)
                 * @Author: Amit Kumar Pradhan
                 * @Date: 31-Mar-2017    
                 ***************************/
               
                if(aMetric.GoalId != null && aMetric.RecordTypeName__c != null 
                    && aMetric.RecordTypeName__c.equalsIgnoreCase(Label.Indirect_Record_Type) && aMetric.Status != COMPLETED_STATUS){
                    
                        if(aMetric.name.equalsIgnoreCase(Label.AverageStoreVisitDurationMetricName)){                           
                            if(aMetric.currentvalue != null){
                                if(aMetric.currentvalue < 30 || aMetric.currentvalue > 120){
                                    aMetric.Status = CRITICAL_STATUS; //Red Color
                                }else if((aMetric.currentvalue >=30 && aMetric.currentvalue < 45) 
                                            || (aMetric.currentvalue > 90 && aMetric.currentvalue <= 120)){
                                    aMetric.Status = BEHIND_STATUS; //Yellow Color
                                }else if(aMetric.currentvalue >= 45 && aMetric.currentvalue <= 90){
                                    aMetric.Status = ONTRACK_STATUS; //Green Color
                                }else{}
                            }
                        }else{
                            remainingDays = aMetric.DueDate !=null ? System.today().daysBetween(aMetric.DueDate) : 0;                           
                            //Calling updateStatus method for color coding logic
                            updateStatus(aMetric,remainingDays);
                        }
                                                    
                }else{
                //End: Part of US1064046 and US1025305
                                
                    if(aMetric.GoalId != null && aMetric.Goal_Template_Type__c != TYPE_RGU && aMetric.Goal_Template_Type__c != TYPE_COMMUNITIES  && aMetric.Goal_Template_Type__c != TYPE_ACTIVITY){  
                        remainingDays = aMetric.DueDate!=null?System.today().daysBetween(aMetric.DueDate):0;
                        
                        //Start of comment - Below codes are commented as we are replacing in a common method(updateStatus)
                        //Commented By - Amit Kumar Pradhan
                        /*
                        if(aMetric.targetvalue >0 && aMetric.currentvalue!=null){
                            Integer roundCurrentVal = Math.round(aMetric.currentValue);
                            
                            progessPercVal =  (aMetric.currentValue*100)/aMetric.targetvalue;
                            //progessPercVal =  Math.round(progessPercVal);
                            //progessPercVal =  roundCurrentVal*100/aMetric.targetvalue;
                        }
                        
                        if(progessPercVal<=25){
                            aMetric.Status=remainingDays >=20?BEHIND_STATUS:CRITICAL_STATUS;     
                                        
                        }else if(25<progessPercVal && progessPercVal<=75){
                            if(remainingDays >=20){
                                aMetric.Status = ONTRACK_STATUS;
                            }else{
                                 aMetric.Status=remainingDays >=10 && remainingDays<20?BEHIND_STATUS:CRITICAL_STATUS; 
                            }                          
                        }else if(75<progessPercVal && progessPercVal<100){
                            aMetric.Status = remainingDays >=10?ONTRACK_STATUS:BEHIND_STATUS;
                        }else {
                            aMetric.Status = ONTRACK_STATUS;
                        }
                        */
                        //End of comment
                        
                        //Calling updateStatus method for color coding logic
                        updateStatus(aMetric,remainingDays);
                        
                    }
                    
                    
                    if(aMetric.GoalId != null && aMetric.Goal_Template_Type__c != null && aMetric.Goal_Template_Type__c == TYPE_COMMUNITIES ){
                        
                        if(aMetric.DueDate !=null && aMetric.DueDate >= System.Today() && aMetric.DueDate.addMonths(-1).addDays(1) <= System.Today()){
                             
                            if(aMetric.targetvalue != null && aMetric.targetvalue >0 && aMetric.currentvalue!=null){
                                Integer roundCurrentVal = Math.round(aMetric.currentValue);           
                                progessPercVal =  roundCurrentVal*100/aMetric.targetvalue;
                            }
                            
                            if(progessPercVal>=100){
                            
                            aMetric.Status = ONTRACK_STATUS;
                            }else if(75<=progessPercVal && progessPercVal<100){
                            aMetric.Status = BEHIND_STATUS;
                            }else if(progessPercVal<75){
                            aMetric.Status = CRITICAL_STATUS;
                            }
                        }
                    }
                }                
            } 
        }catch(Exception e){
            System.debug('***Following exception has occured***'+e.getMessage());
        }
    }
    
    /************
    * @Description: This method update Metric status as per the currentValue, targetValue and remaining days.
    * @Author: Amit Kumar Pradhan, Accenture
    * @Date: 5-April-2017
    * @Param: Metric,Integer
    * @Return: Metric
    * @LastUpdated : 24/7/2017
    * @LastUpdatedBy: Malay Desai, Accenture 
    * US1112416 - Coach for CAR Leaders: Quarterly Metric Color Coding update
    **************/
    
    private static Metric updateStatus(Metric metricObj, Integer remainingDays){
        Decimal progessPercVal = 0;       
        Integer multiplier = 1; //For monthly metric 1, for Quarterly metric 3
        SystemProperties sp = new SystemProperties();
        String qtrlyMetrics = sp.getSytemProperty(QUARTERLY_METRICS,COACH_FUNCTIONAL_AREA);
        Set<String> metricNames = new Set<String>(qtrlyMetrics.split(','));
        
        if(metricNames.contains(metricObj.Name)){ system.debug('## :'+metricObj.Name);multiplier = 3;}
                      
        if(metricObj.targetvalue != null && metricObj.targetvalue > 0 && metricObj.currentvalue != null){
            progessPercVal = (metricObj.currentValue*100)/metricObj.targetvalue;  
        }
        
        if(progessPercVal<=25){
            metricObj.Status=remainingDays >=(20*multiplier)?BEHIND_STATUS:CRITICAL_STATUS;                                  
        }else if(25<progessPercVal && progessPercVal<=75){
            if(remainingDays >=(20*multiplier)){
                metricObj.Status = ONTRACK_STATUS;               
            }else{
                 metricObj.Status=remainingDays >=(10*multiplier) && remainingDays<(20*multiplier)?BEHIND_STATUS:CRITICAL_STATUS;                 
            }                          
        }else if(75<progessPercVal && progessPercVal<100){
            metricObj.Status = remainingDays >=(10*multiplier)?ONTRACK_STATUS:BEHIND_STATUS;           
        }else {
            metricObj.Status = ONTRACK_STATUS;          
        }
        return metricObj;
    }
}