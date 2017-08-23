/**
    * @Description: This class includes one or more methods which will be executed from "Property Visit Trigger" 
    * @First Author: Tejaswini Kasar, Accenture 
    * @Date: 25-Feb-2016 
    * @Modified By: Animesh
    * @Modified Date: 7/11/2017
    * Modification Details: US1137734(XC DT - Only count completed visits). Calling method "propertyVisitCountGoal" in after update instead of insert and Counting only completed visits for Metric's actual update 
    * @Modified By: Animesh
    * @Modified Date: 7/21/2017
    * Modification Details: Fixed UAT Defect ALMID 76442 - On last of cycle metric was not getting updated
    */
public class PropertyVisitTriggerController{
    
    /*
    * @Description: This method is to update the 'Current Value' on Metrics if the Metric's Owner is same as 'Assigned CAR' 
            of Property object whenever a property visit is done."
    * @Return: void
    * @Date: 25-Feb-2016 
    * Last Modified By : Malay Desai(Roll up 'Total Property Visits per month' AND 'Average Property Visits per day' to CAR manager 
    * AND CAR Director/SR Managers)
    * Last Modified Date : 24-Feb-2017(US932263)
    * @Modified Date: 7/11/2017 
    * @Modified By : Animesh - US1137734(XC DT - Only count completed visits)
    * @Modified Date: 7/13/2017 
    * @Modified By : Animesh - US1137734(XC DT - Only count completed visits) - Auto check out will not be considered for metric update as per discussion board on US1137741
    * @Modified By: Animesh
    * @Modified Date: 7/21/2017
    * Modification Details: Fixed UAT Defect ALMID 76442 - On last of cycle metric was not getting updated
    */
    public static void propertyVisitCountGoal(List<Property_Visit__c> propertVisit, Map<Id,Property_Visit__c> oldPropertyVisitMap){//Added OldMap - US1137734
                      
        Set<String> assignedCarIDSet = new Set<String>();
        Set<String> mgrIdSet = new Set<String>(); 
        Set<String> mgrOfMgrIdSet = new Set<String>(); 
        Set<String> carDayCombo = new Set<String>();
        Set<String> carMgrDayCombo = new Set<String>();
        Set<String> carDirDayCombo = new Set<String>();
        final String CAR_USER = 'carUser', CAR_MGR = 'carMgr', CAR_DIR = 'carDir', DAY_OF_VISIT = 'DY',HASH='#';
        Set<String> cARDirectorOrSrManagers = new Set<String>(); // Contains CAR Director/Sr Manager
        Map<String,Integer> carIdPropertyCount = new Map<String,Integer>(); //CARIds vs No of Property Visited
        Map<String,Integer> mgrIdTotalPropCount = new Map<String,Integer>();//CAR ManagerIds vs No of Property Visited by their CARs
        Map<String,Integer> dirIdTotalPropCount = new Map<String,Integer>();//CAR DirIds vs No of Property Visited by their CARs
        Map<String,Integer> countForCar = new Map<String,Integer>();//CARIds vs No of Days on field
        Map<String,Integer> countForCarMgr = new Map<String,Integer>();//CAR ManagerIds vs No of Days on field by their CARs
        Map<String,Integer> countForCarDir = new Map<String,Integer>();
        Date preGoalStartDate = null,preGoalDueDate = null,todayDate = Date.Today();
        List<Metric> metricUpdateList = new List<Metric>();
        Integer propertySum,daySum;
        String userId,day,uId;
  
        try{
            MetricTriggerController.allowValidation=false;
            //Get the Fiscal Year Date period goal start/due dates            
            GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(PL_Constants.GOAL_DATES_FOR_PROPERTY_LAB);
            
            if(goalDates != null){               
                if(todayDate.Day()>=22){              
                    preGoalStartDate = Date.newInstance(todayDate.Year(), todayDate.Month(), 22);  
                }else if(todayDate.Day() >= 1 && todayDate.Day() <= 21){
                    preGoalStartDate = Date.newInstance(todayDate.Year(), todayDate.Month()-1, 22); 
                }
                //Start - 21-Jul-2017 - Animesh - Fixed UAT Defect ALMID 76442 - On last of cycle metric was not getting updated
                //preGoalDueDate =  preGoalStartDate.addMonths(1).AddDays(-1);
                preGoalDueDate =  preGoalStartDate.addMonths(1);
                //End - 21-Jul-2017 - Fixed UAT Defect ALMID 76442 - On last of cycle metric was not getting updated
            }
            
            for(Property_Visit__c propvisit : propertVisit){
                //Start - Animesh - US1137734 - 7/11/2017 - Populate Set "assignedCarIDSet" only when Property Visit is marked as completed
                //Animesh - US1137734 - 7/13/2017 - Adding check for auto check out so that it is not considered for metric update
                if(propvisit.End_Date_Time__c!= null && propvisit.Status__c != null && 
                propvisit.Status__c != oldPropertyVisitMap.get(propvisit.id).Status__c && 
                propvisit.Status__c.equalsIgnoreCase(ConstantHandler.PROPERTY_VISIT_COMPLETED_STATUS) && !propvisit.Is_auto_checkout__c){
                //End - Animesh - US1137734 - 7/11/2017
                    assignedCarIDSet.add(propvisit.createdbyid);
                }
            }
            
            //Extended Actual roll up for Car manager(US :US760932)
            for(User userObj: [SELECT Id,ManagerId,Manager.isActive,Manager.ManagerId, Manager.Manager.IsActive FROM User WHERE ID IN : assignedCarIDSet AND isActive=True 
                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                if(userObj.ManagerId != null && userObj.Manager.isActive){
                    mgrIdSet.add(userObj.ManagerId);
                } 
                if(userObj.Manager.ManagerId != null && userObj.Manager.Manager.isActive){
                    mgrOfMgrIdSet.add(userObj.Manager.ManagerId);
                } 
            }
            
            for(PermissionSetAssignment psa :  
                    [SELECT AssigneeId FROM PermissionSetAssignment  WHERE (AssigneeId IN :mgrIdSet OR AssigneeId IN: mgrOfMgrIdSet)
                     AND PermissionSet.Name = :PL_Constants.PERM_SET_FOR_CAR_DIR_SR_MGR 
                     LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                cARDirectorOrSrManagers.add(psa.AssigneeId); 
            }
            
            mgrIdSet.removeAll(cARDirectorOrSrManagers); // CAR Managers Only
            //Start - Animesh - US1137734 - 7/11/2017 - Instead of 'CreatedDate' using 'End_Date_Time__c'.
            //Animesh - US1137734 - 7/11/2017 - Added Check for newly created field Status__c in order to fetch only Completed visits.
            //Animesh - US1137734 - 7/11/2017 - Added Date Range "AND End_Date_Time__c <=: preGoalDueDate" to fetch Property Visits so that query fetch all completed visit during fiscal month. But only single count will be taken if there is more than 1 visit for same day in same property (Existing functionality). 
            //Animesh - US1137734 - 7/13/2017 - Adding check for auto check out so that it is not considered for metric update
            //Animesh - 21-Jul-2017 - Animesh - Fixed UAT Defect ALMID 76442 - On last of cycle metric was not getting updated. So chnaged from End_Date_Time__c <=: preGoalDueDate to End_Date_Time__c <: preGoalDueDate
            for(AggregateResult aggregateRes : 
                    [SELECT count(Id) pc ,Property__c,createdById carUser, createdBy.ManagerId carMgr, 
                            createdBy.Manager.ManagerId carDir,DAY_IN_MONTH(End_Date_Time__c) FROM Property_Visit__c 
                     WHERE End_Date_Time__c >=: preGoalStartDate AND End_Date_Time__c <: preGoalDueDate AND (createdById IN: assignedCarIDSet OR createdBy.ManagerId IN :mgrIdSet 
                     OR createdBy.ManagerId IN :cARDirectorOrSrManagers OR createdBy.Manager.ManagerId IN :cARDirectorOrSrManagers) AND Status__c =: ConstantHandler.PROPERTY_VISIT_COMPLETED_STATUS AND Is_auto_checkout__c = false
                     GROUP BY createdById, createdBy.ManagerId, createdBy.Manager.ManagerId,Property__c, DAY_IN_MONTH(End_Date_Time__c) 
                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){       
            //End - Animesh - US1137734 - 7/11/2017    
                //Calcualtion Logic For CAR
                if((String)aggregateRes.get(CAR_USER) != null){
                    if(assignedCarIDSet.contains((String)aggregateRes.get(CAR_USER))){
                        propertySum = 0;
                        userId = (String)aggregateRes.get(CAR_USER);
                        if(carIdPropertyCount.containskey(userId)){
                            propertySum = carIdPropertyCount.get(userId);
                        }
                        propertySum++;
                        carIdPropertyCount.put(userId,propertySum);    
                    }
                }else{}

                //Calcualtion Logic For CAR Manager and CAR Director who are direct manager of CAR
                if((String)aggregateRes.get(CAR_MGR) != null){
                    propertySum = 0;
                    userId = (String)aggregateRes.get(CAR_MGR);
                    if(mgrIdSet.contains(userId)){
                        if(mgrIdTotalPropCount.containsKey(userId)){
                            propertySum = mgrIdTotalPropCount.get(userId);
                        }
                        propertySum++;
                        mgrIdTotalPropCount.put(userId,propertySum);
                    } else{
                        if(cARDirectorOrSrManagers.contains(userId)){
                            if(dirIdTotalPropCount.containsKey(userId)){
                                propertySum = dirIdTotalPropCount.get(userId);
                            }
                            propertySum++;
                            dirIdTotalPropCount.put(userId,propertySum);
                        }
                    }
                }else{}
                
                //Calcualtion Logic For CAR Director who are CAR's Manager's Manager
                if((String)aggregateRes.get(CAR_DIR) != null){
                    propertySum = 0;
                    userId = (String)aggregateRes.get(CAR_DIR);
                    if(dirIdTotalPropCount.containsKey(userId)){
                        propertySum = dirIdTotalPropCount.get(userId);
                    }
                    propertySum++;
                    dirIdTotalPropCount.put(userId,propertySum);
                }else{}
            }
            //Start - Animesh - US1137734 - 7/11/2017 - Instead of 'CreatedDate' using 'End_Date_Time__c'.
            //Animesh - US1137734 - 7/11/2017 - Added Check for newly created field Status__c in order to fetch only Completed visits.
            //Animesh - US1137734 - 7/11/2017 - Added Date Range "AND End_Date_Time__c <=: preGoalDueDate" to fetch Property Visits so that query fetch all completed visit during fiscal month. But only single count will be taken if there is more than 1 visit for same day in same property (Existing functionality)
            //Animesh - US1137734 - 7/13/2017 - Adding check for auto check out so that it is not considered for metric update
            //Animesh - 21-Jul-2017 - Animesh - Fixed UAT Defect ALMID 76442 - On last of cycle metric was not getting updated. So chnaged from End_Date_Time__c <=: preGoalDueDate to End_Date_Time__c <: preGoalDueDate
            for(AggregateResult aggregateRes : 
                [SELECT count(Id) dc, createdById carUser, createdBy.ManagerId carMgr, createdBy.Manager.ManagerId carDir,
                        DAY_IN_MONTH(End_Date_Time__c) DY 
                 FROM Property_Visit__c WHERE End_Date_Time__c >=: preGoalStartDate AND End_Date_Time__c <: preGoalDueDate
                 AND (createdById IN: assignedCarIDSet OR createdBy.ManagerId IN : mgrIdSet OR createdBy.Manager.ManagerId 
                 IN :cARDirectorOrSrManagers ) AND Status__c =: ConstantHandler.PROPERTY_VISIT_COMPLETED_STATUS AND Is_auto_checkout__c = false
                 GROUP BY createdById, createdBy.ManagerId, createdBy.Manager.ManagerId, 
                 DAY_IN_MONTH(End_Date_Time__c) LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){       
            //End - Animesh - US1137734 - 7/11/2017
                day = String.valueOf((Integer)aggregateRes.get(DAY_OF_VISIT));
                //Day Calcualtion Logic For CAR
                if((String)aggregateRes.get(CAR_USER) != null){
                    userId = (String)aggregateRes.get(CAR_USER);
                    if(assignedCarIDSet.contains(userId)){
                        carDayCombo.add(userId+ HASH +day);
                    }
                }else{}

                //Day Calcualtion Logic For CAR Manager and CAR Director who are direct manager of CAR
                if((String)aggregateRes.get(CAR_MGR) != null){
                    userId = (String)aggregateRes.get(CAR_MGR);
                    if(mgrIdSet.contains(userId)){
                        carMgrDayCombo.add(userId+ HASH +day);
                    }else{
                        if(cARDirectorOrSrManagers.contains(userId)){
                            carDirDayCombo.add(userId+ HASH +day);
                        } else{}
                    }
                }else{}
                
                //Day Calcualtion Logic For CAR Director who are CAR's Manager's Manager
                if((String)aggregateRes.get(CAR_DIR) != null){
                    userId = (String)aggregateRes.get(CAR_DIR);
                    carDirDayCombo.add(userId+ HASH +day);
                }else{}
            }
            
            for(String combo : carDayCombo){
                uId = combo.split(HASH)[0];
                Integer cnt = countForCar.get(uId);
                if(cnt == null){
                    countForCar.put(uId, 1);
                } else{
                    countForCar.put(uId, cnt+1);
                }
            }
            
            for(String combo : carMgrDayCombo){
                uId = combo.split(HASH)[0];
                Integer cnt = countForCarMgr.get(uId);
                if(cnt == null){
                    countForCarMgr.put(uId, 1);
                } else{
                    countForCarMgr.put(uId, cnt+1);
                }
            }
            
            for(String combo : carDirDayCombo){
                uId = combo.split(HASH)[0];
                Integer cnt = countForCarDir.get(uId);
                if(cnt == null){
                    countForCarDir.put(uId, 1);
                } else{
                    countForCarDir.put(uId, cnt+1);
                }
            }
            
            //Fetching "Total Property Visits per month" AND "Average Property Visits per day" metrics and update
            //Animesh - 21-Jul-2017 - Animesh - Fixed UAT Defect ALMID 76442 - On last of cycle metric was not getting updated. So chnaged from Goal.DueDate <= :preGoalDueDate to Goal.DueDate < :preGoalDueDate
            for(Metric metr : 
                [SELECT Id, Name, OwnerId, Currentvalue, Goal.OwnerId, Goal.StartDate, Goal.DueDate, Goal.Recordtypeid FROM Metric 
                 WHERE Metric.Name IN (:PL_Constants.METRIC_TOTAL_VISITS_PER_MONTH, :PL_Constants.METRIC_AVG_VISITS_PER_DAY)
                 AND Goal.StartDate >= :preGoalStartDate AND Goal.DueDate < :preGoalDueDate AND Goal.Status =:PL_Constants.GOAL_STATUS_PUBLISHED
                 AND (Goal.OwnerId IN :assignedCarIDSet OR Goal.OwnerId IN :mgrIdSet OR Goal.OwnerId IN :cARDirectorOrSrManagers) 
                 LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){   
                
                if(carIdPropertyCount.containsKey(metr.OwnerId)){
                    
                    if(PL_Constants.METRIC_TOTAL_VISITS_PER_MONTH.equalsIgnoreCase(metr.Name)){ 
                        metr.Currentvalue = carIdPropertyCount.get(metr.OwnerId);
                    }else if(PL_Constants.METRIC_AVG_VISITS_PER_DAY.equalsIgnoreCase(metr.Name)){
                        Integer countInt = carIdPropertyCount.get(metr.OwnerId);
                        Integer countDay = countForCar.get(metr.OwnerId);
                        Decimal avg = ((Decimal)countInt/countDay).setScale(2);
                        metr.Currentvalue = avg;
                    }else{}
                    
                }else if(mgrIdTotalPropCount.containsKey(metr.OwnerId)){
                    
                    if(PL_Constants.METRIC_TOTAL_VISITS_PER_MONTH.equalsIgnoreCase(metr.Name)){ 
                        metr.Currentvalue = mgrIdTotalPropCount.get(metr.OwnerId);
                    }else if(PL_Constants.METRIC_AVG_VISITS_PER_DAY.equalsIgnoreCase(metr.Name)){
                        Integer countInt = mgrIdTotalPropCount.get(metr.OwnerId);
                        Integer countDayForMgr = countForCarMgr.get(metr.OwnerId);
                        Decimal avg = ((Decimal)countInt/countDayForMgr).setScale(2);
                        metr.Currentvalue = avg;
                    }else{}
                }else{
                    if(dirIdTotalPropCount.containsKey(metr.OwnerId)){
                        if(PL_Constants.METRIC_TOTAL_VISITS_PER_MONTH.equalsIgnoreCase(metr.Name)){ 
                            metr.Currentvalue = dirIdTotalPropCount.get(metr.OwnerId);
                        }else if(PL_Constants.METRIC_AVG_VISITS_PER_DAY.equalsIgnoreCase(metr.Name)){
                            Integer countInt = dirIdTotalPropCount.get(metr.OwnerId);
                            Integer countDayForDir = countForCarDir.get(metr.OwnerId);
                            Decimal avg = ((Decimal)countInt/countDayForDir).setScale(2);
                            metr.Currentvalue = avg;
                        }else{}
                    }else{}
                }             
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