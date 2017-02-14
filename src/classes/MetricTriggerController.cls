public class MetricTriggerController {
    
    //Metric Status constants
    private static final string ONTRACK_STATUS = 'OnTrack';
    private static final string BEHIND_STATUS = 'Behind';
    private static final string CRITICAL_STATUS = 'Critical'; 
    private static final string TYPE_RGU = 'RGU';
    private static final string TYPE_ACTIVITY = 'Activity'; 
    private static final string TYPE_COMMUNITIES = 'Communities';
       
    public static boolean allowValidation = true;   
        public static void metricValidation() {
            if(allowValidation ){
                MetricTriggerOperations.metricPermissionValidation();
                MetricTriggerOperations.aeContractorAndMgrValidation();
            }
        }
        
    /**
    * @Description: This method sets Metric status as per the currentValue, targetValue and remaining days.
    * @Author: Malay Desai, Accenture
    * @Date: 23-March-2016
    * @Param: newList
    * @Return: void.
    */   
    public static void updateMetricStatus(List<Metric> newList){
        Integer remainingDays;
        Decimal progessPercVal = 0;
        system.debug(' inside updateMetricStatus******');
        
        
        for(Metric aMetric :newList){
        
        //for(Metric aMetric : [Select id, Goal_Template_Type__c, GoalId, Status, Goal.Recordtypeid, Recordtypeid, currentvalue, targetvalue from Metric where id in : newList]){
           // if(aMetric.GoalId != null && aMetric.Goal.Recordtypeid != '012q00000000S5I' && aMetric.Goal_Template_Type__c != TYPE_RGU && aMetric.Goal_Template_Type__c != TYPE_COMMUNITIES  && aMetric.Goal_Template_Type__c != TYPE_ACTIVITY){
               if(aMetric.GoalId != null && aMetric.Goal_Template_Type__c != TYPE_RGU && aMetric.Goal_Template_Type__c != TYPE_COMMUNITIES  && aMetric.Goal_Template_Type__c != TYPE_ACTIVITY){  
                remainingDays = aMetric.DueDate!=null?System.today().daysBetween(aMetric.DueDate):0;
                if(aMetric.targetvalue >0 && aMetric.currentvalue!=null){
                    Integer roundCurrentVal = Math.round(aMetric.currentValue);           
                    progessPercVal =  roundCurrentVal*100/aMetric.targetvalue;
                }
                
                if(progessPercVal<=25){
                    aMetric.Status=remainingDays >=20?BEHIND_STATUS:CRITICAL_STATUS;     
                    //System.debug('Status Critical' + aMetric.Status);                  
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
            }
            
            
            if(aMetric.GoalId != null && aMetric.Goal_Template_Type__c != null && aMetric.Goal_Template_Type__c == TYPE_COMMUNITIES ){
                if(aMetric.DueDate !=null && aMetric.DueDate >= System.Today() && aMetric.DueDate.addMonths(-1).addDays(1) <= System.Today()){                    
                    if(aMetric.targetvalue >0 && aMetric.currentvalue!=null){
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
}