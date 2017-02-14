/**
    * @Description: This class is to update the 'Actual Value' on Metrics if the Metric's Owner is same as 'Assigned CAR' of Property object whenever a property visit is done."
    * US636891 CAR Coach: Property Visits Metrics Actual Updates
    * @Author: Tejaswini Kasar, Accenture 
    * @Date: 25-Feb-2016    
    * Last Modified By : Amit Kumar Pradhan(Roll up 'Total Property Visits per month' AND 'Average Property Visits per day' to CAR manager)
    * Last Modified Date : 8-Sept-2016(US760932)
    */
    public class PropertyVisitTriggerController{
        private static final String VISIT_PER_MONTH = 'Total Property Visits per month';
        private static final String VISIT_PER_DAY = 'Average Property Visits per day';
        private static final String CAR_USER = 'carUser';
        private static final String CAR_MGR = 'carMgr';
        private static final String TOTAL_PROPERTY_VISITS_PER_MONTH = '%Total Property Visits per month%';
        private static final String AVERAGE_PROPERTY_VISITS_PER_DAY = '%Average Property Visits per day%';
        private static final String GOAL_STATUS = 'Published';
        private static final String PROPERTY_LAB_GOAL_TEMPLATE = 'Property Lab CAR';
    /*
     * @Description: This method is to update the 'Actual Value' on Metrics if the Metric's Owner is same as 'Assigned CAR' 
                    of Property object whenever a property visit is done."
     * @Return: void
     * @Date: 25-Feb-2016 
     * Last Modified By : Amit Kumar Pradhan(Roll up 'Total Property Visits per month' AND 'Average Property Visits per day' to CAR manager)
     * Last Modified Date : 8-Sept-2016(US760932)
     */
    public static void propertyVisitCountGoal(List<Property_Visit__c> propertVisit){
                      
        Set<String> assignedCarIDSet = new Set<String>();
        Set<String> mgrIdSet = new Set<String>();        
        Map<String,Integer> carIdPropertyCount = new Map<String,Integer>();
        Map<String,Integer> mgrIdTotalPropCount = new Map<String,Integer>();
        Map<String,Integer> noOfDaysCountForCar = new Map<String,Integer>();
        Map<String,Integer> noOfDaysCountForCarMgr = new Map<String,Integer>();
        Integer todayDate = Date.Today().Day();
        Date preGoalStartDate = null;
        Date preGoalDueDate = null;          
        List<Metric> metricUpdateList = new List<Metric>();
        Date dueTemplateDate = null;
        
        try{
            MetricTriggerController.allowValidation=false;
            String goalPropertyLabRecordType = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.Label.PL_MonthlyGoalCreationBatchGolTempType).getRecordTypeId();      
            //Get the Fiscal Year Date period goal start/due dates            
            GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(PROPERTY_LAB_GOAL_TEMPLATE);
            dueTemplateDate = goalDates.Current_Period_Due_Date__c;           
            if(goalDates != null){               
                if(todayDate>=22){              
                    preGoalStartDate = Date.newInstance(date.today().Year(), date.today().Month(), 22);  
                }else if(todayDate>=1 && todayDate<=21){
                    preGoalStartDate = Date.newInstance(date.today().Year(), date.today().Month()-1, 22); 
                }                       
                preGoalDueDate =  preGoalStartDate.addMonths(1).AddDays(-1);
            }
            
            Integer numberDaysDue = preGoalStartDate.daysBetween(System.Today())+1;
            
            for(Property_Visit__c propvisit : propertVisit){
                assignedCarIDSet.add(propvisit.createdbyid);
            }
            
            //Extended Actual roll up for Car manager(US :US760932)
            for(User userObj: [SELECT Id,ManagerId,Manager.isActive FROM User WHERE ID IN : assignedCarIDSet AND isActive=True 
                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                if(userObj.ManagerId != null && userObj.Manager.isActive){
                    mgrIdSet.add(userObj.ManagerId);
                }   
            }
            
            
            for(AggregateResult aggregateRes : [SELECT count(Id) propertycount ,Property__c,Property__r.Assigned_CAR__c carUser, Property__r.Assigned_CAR__r.managerId carMgr,
                                                DAY_IN_MONTH(createddate),CALENDAR_MONTH(createddate),CALENDAR_YEAR(createddate) FROM Property_Visit__c WHERE createddate >=: preGoalStartDate 
                                                AND (createdBy.managerId IN :mgrIdSet OR createdById IN: assignedCarIDSet ) Group By Property__r.Assigned_CAR__c, 
                                                Property__r.Assigned_CAR__r.managerId, Property__c,DAY_IN_MONTH(createddate),CALENDAR_MONTH(createddate),CALENDAR_YEAR(createddate) 
                                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){       
                
                //Calcualtion Logic For CAR
                if((String)aggregateRes.get(CAR_USER) != null){
                    If(assignedCarIDSet.contains((String)aggregateRes.get(CAR_USER))){
                        Integer propertySum = 0;
                        String carIdString = (String)aggregateRes.get(CAR_USER);
                        if(carIdPropertyCount.containskey(carIdString)){
                            propertySum = carIdPropertyCount.get(carIdString);
                        }
                        propertySum++;
                        carIdPropertyCount.put(carIdString,propertySum);    
                    }
                }else{}

                //Calcualtion Logic For CAR Manager
                If((String)aggregateRes.get(CAR_MGR) != null){
                    Integer propSumForCarMgr = 0;
                    String mgrIdString = (String)aggregateRes.get(CAR_MGR);
                    if(mgrIdTotalPropCount.containsKey(mgrIdString)){
                        propSumForCarMgr = mgrIdTotalPropCount.get(mgrIdString);
                    }
                    propSumForCarMgr++;
                    mgrIdTotalPropCount.put(mgrIdString,propSumForCarMgr);
                }else{}
  
            }
            
            
            for(AggregateResult aggregateRes : [SELECT count(Id) propertycount ,Property__r.Assigned_CAR__c carUser, Property__r.Assigned_CAR__r.managerId carMgr,
                                                DAY_IN_MONTH(createddate),CALENDAR_MONTH(createddate),CALENDAR_YEAR(createddate) FROM Property_Visit__c WHERE createddate >=: preGoalStartDate 
                                                AND (createdBy.managerId IN :mgrIdSet OR createdById IN: assignedCarIDSet ) Group By Property__r.Assigned_CAR__c, 
                                                Property__r.Assigned_CAR__r.managerId, DAY_IN_MONTH(createddate),CALENDAR_MONTH(createddate),CALENDAR_YEAR(createddate) 
                                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){       
                
                //Day Calcualtion Logic For CAR
                if((String)aggregateRes.get(CAR_USER) != null){
                    If(assignedCarIDSet.contains((String)aggregateRes.get(CAR_USER))){
                        Integer daySum = 0;
                        String carIdString = (String)aggregateRes.get(CAR_USER);
                        if(noOfDaysCountForCar.containskey(carIdString)){
                            daySum = noOfDaysCountForCar.get(carIdString);
                        }
                        daySum++;
                        noOfDaysCountForCar.put(carIdString,daySum);    
                    }
                }else{}

                //Day Calcualtion Logic For CAR Manager
                If((String)aggregateRes.get(CAR_MGR) != null){
                    Integer daySumForCarMgr = 0;
                    String mgrIdString = (String)aggregateRes.get(CAR_MGR);
                    if(noOfDaysCountForCarMgr.containsKey(mgrIdString)){
                        daySumForCarMgr = noOfDaysCountForCarMgr.get(mgrIdString);
                    }
                    daySumForCarMgr++;
                    noOfDaysCountForCarMgr.put(mgrIdString,daySumForCarMgr);
                }else{}
  
            }
            
            /*Set<date> valueForCAR =new set<date>();
            integer countForCAR = 0;
            for(Property_Visit__c pv :[SELECT Property__c,createddate FROM Property_Visit__c WHERE createddate >=: preGoalStartDate 
                                                AND createdById IN: assignedCarIDSet]){
               valueForCAR.add(date.valueof(pv.createddate));    
                
            }
            system.debug('@@valueforcar'+valueForCAR);
            countForCAR = valueForCAR.size();
            
            Set<date> valueForCARMgr =new set<date>();
            integer countForCARMgr = 0;
            for(Property_Visit__c pvc :[SELECT Property__c,createddate FROM Property_Visit__c WHERE createddate >=: preGoalStartDate 
                                                AND createdBy.managerId IN: mgrIdSet]){
               valueForCARMgr.add(date.valueof(pvc.createddate));
              // system.debug('@@value'+value.size());
            }
             system.debug('@@valueForCARMgr'+valueForCARMgr.size());
            countForCARMgr = valueForCARMgr.size();
            */
            //Fetching "Total Property Visits per month" AND "Average Property Visits per day" metrics and update
            for(Metric metr : [SELECT Id, Name, OwnerId, Currentvalue, Goal.OwnerId, Goal.StartDate, Goal.DueDate, Goal.Recordtypeid FROM Metric 
                                WHERE (Metric.Name like : TOTAL_PROPERTY_VISITS_PER_MONTH OR Metric.Name like : AVERAGE_PROPERTY_VISITS_PER_DAY)
                                AND Goal.StartDate >=: preGoalStartDate AND Goal.DueDate <=:  preGoalDueDate AND Goal.Status =: GOAL_STATUS
                                AND (Goal.OwnerId IN : carIdPropertyCount.keySet() OR Goal.OwnerId IN : mgrIdSet) 
                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){   
                
                if(carIdPropertyCount.containsKey(metr.OwnerId)){
                    
                    if(VISIT_PER_MONTH.equalsIgnoreCase(metr.Name)){ 
                        metr.Currentvalue = carIdPropertyCount.get(metr.OwnerId);
                          
                    }else if(VISIT_PER_DAY.equalsIgnoreCase(metr.Name)){
                        Integer countInt = carIdPropertyCount.get(metr.OwnerId);
                        Integer countDay = noOfDaysCountForCar.get(metr.OwnerId);
                        
                        Decimal avg = ((Decimal)countInt/countDay).setScale(2);
                        metr.Currentvalue = avg;
                    }else{}
                    
                }else if(mgrIdTotalPropCount.containsKey(metr.OwnerId)){
                    
                    if(VISIT_PER_MONTH.equalsIgnoreCase(metr.Name)){ 
                        metr.Currentvalue = mgrIdTotalPropCount.get(metr.OwnerId);
                          
                    }else if(VISIT_PER_DAY.equalsIgnoreCase(metr.Name)){
                        Integer countInt = mgrIdTotalPropCount.get(metr.OwnerId);
                        Integer countDayForMgr = noOfDaysCountForCarMgr.get(metr.OwnerId);
                        Decimal avg = ((Decimal)countInt/countDayForMgr).setScale(2);
                        metr.Currentvalue = avg;
                    }else{}
                }else{}             
                metricUpdateList.add(metr);
            }
            
            if(!metricUpdateList.isEmpty()){
                Database.update(metricUpdateList,false);
            }
        }catch(Exception e){
            System.debug('Exception------'+e.getMessage());
        }       
    }        
}