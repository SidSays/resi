/**************************************************************************************************
Name : PropertyEventTriggerOperation
Description : This class will hold the different methods for Property Event Trigger.
User Story : Initial Method
             US1143300 : XC DT - Update Sales Event Metrics
Date : 21 July 2017
Author : Amit Kumar 
* @Modified Description: US1160971 - XC DT - Event credit for CARs. Propert Assigned to the CAR should get credit for Sales Event created by anyone. 
                            This should roll up to CAR Manager and CAR Leaders
* @Modified By: Animesh
* @Modified Date: 8/8/2017
***************************************************************************************************/
public without sharing class PropertyEventTriggerOperation {
   /*************************
    * @Description: US1143300: This method is to update the Sales Event Metric for CAR, CAR Manager and CAR Director.
                    Metric Will get update for each Completed Proverty Event.
    * @Return: void
    * @Date: 21 July 2017
    * @Author: Amit Kumar, Accenture
    * @Modified Description: US1160971 - XC DT - Event credit for CARs. Propert Assigned to the CAR should get credit for Sales Event created by anyone. 
                            This should roll up to CAR Manager and CAR Leaders
    * @Modified By: Animesh
    * @Modified Date: 8/8/2017
    **************************/
    public static void updateSalesMetrics(map<id,id> eventidVsassignedcarmap){
        //Declare the variables  ***************************************************** START **************
        map<id,id> valideventIdVsassignedcarmap = new map<id,id>();//map of valid eventid and car id
        Date preGoalStartDate = null;
        Date preGoalDueDate = null; 
        String carDirectorId=null;//temporary variable to store car director id
        String carManagerId = null;//temporary variable to store car manager id
        String carId = null;//temporary variable to store car id
        List<Metric> metricList= new List<Metric>();
        Set<Id> permissionAssignedID = new Set<Id>();//all assignee id of car director permission set
        Map<Id, Integer> carVsCountMap = new Map<Id, Integer>(); //car vs sales event count map
        Map<Id, Integer> carMgrVsCountMap = new Map<Id, Integer>();//car manager vs sales event map
        Map<Id, Integer> carDirectorVsCountMap = new Map<Id, Integer>();//car director and sales event map
        Map<Id,Id> carVsCarMgrMap = new Map<Id,Id>();//car id vs manager id map
        Map<Id,Id>  carVsCarDirMap = new Map<Id,Id>();//car id vs manager of manager id map
        Map<Id, Boolean> managerVsIsdirectorMap = new Map<Id,Boolean>();//Is manager or manager's manager is director? managerid /manager's managerid vs bollean
        Integer tempcarCount = 0;//temporarily store number of car's sales event
        Integer tempcarMgrCount = 0;//temporarily store number of manager's sales event
        Integer tempcarDirCount = 0;//temporarily store number of director's sales event
        //Declare the variables  ***************************************************** END **************
        try{
            //Get the Standard Event Based on CAR Activity type and Activity type   ***********  START *****
            if(!eventidVsassignedcarmap.Isempty()){  //Is event is not empty then get standard event record on the Standard event
                for(Event objevent:[SELECT Id,CAR_Activity_Type__c,Activity__c 
                                    FROM Event WHERE Id IN:eventidVsassignedcarmap.keySet() AND 
                                    CAR_Activity_Type__c =:PL_Constants.EVENT_CAR_ACTIVITY_TYPE AND
                                     Activity__c =:PL_Constants.EVENT_ACTIVITY 
                                    LIMIT:(Limits.getLimitQueryRows()-Limits.getQueryRows())]){  //get the data where Car Activity Type is Event and Actitiy is 
                    valideventIdVsassignedcarmap.put(objevent.id,eventidVsassignedcarmap.get(objevent.id));//Get the Valid Event Id and assigned car
                }
            }
            //Get the Standard Event Based on CAR Activity type and Activity type   ***********  END **********
            if(!valideventIdVsassignedcarmap.isEmpty()){
                //Get the Fiscal Year Date period goal start/due dates            
                GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(PL_Constants.GOAL_DATES_FOR_PROPERTY_LAB);             
                if(goalDates != null){
                    preGoalStartDate = goalDates.Current_Period_Start_Date__c;  
                    preGoalDueDate   = goalDates.Current_Period_Due_Date__c;
                }
                //Get all users assigned to the permission set Coach_CAR_Director_Manager
                for(PermissionSetAssignment psa : [SELECT AssigneeId 
                                                FROM PermissionSetAssignment  
                                                WHERE PermissionSet.Name = :PL_Constants.PERM_SET_FOR_CAR_DIR_SR_MGR 
                                                LIMIT:(Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    permissionAssignedID.add(psa.AssigneeId);                    
                }
                //Populating following maps  1. carVsCarMgrMap - fill car id and manager of that car user
                //2. carVsCarDirMap - fill car id and manager's manager id
                //3. managerVsIsdirectorMap - fill manager or manager's manager id Vs. Boolean flag(set true if key is one director/leaders) 
                for(User userObj: [SELECT Id,ManagerId,Manager.IsActive, Manager.ManagerId, Manager.Manager.IsActive FROM User 
                                   WHERE ID = :valideventIdVsassignedcarmap.values() 
                                   LIMIT:(Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    if(userObj.ManagerId != null && userObj.Manager.IsActive){
                        carVsCarMgrMap.put(userObj.Id, userObj.ManagerId);//populate car id and manager id
                        if(!permissionAssignedID.isEmpty() && permissionAssignedID.contains(userObj.ManagerId))
                        {
                            managerVsIsdirectorMap.put(userObj.ManagerId,true);//manager is car director
                        }
                        else
                        {
                            managerVsIsdirectorMap.put(userObj.ManagerId,false);//manager is not car director
                        }
                    } 
                    if(userObj.Manager.ManagerId != null && userObj.Manager.Manager.IsActive){
                        carVsCarDirMap.put(userObj.Id, userObj.Manager.ManagerId);//populate car id and manager's manager id
                        if(!permissionAssignedID.isEmpty() && permissionAssignedID.contains(userObj.Manager.ManagerId))
                        {
                            managerVsIsdirectorMap.put(userObj.Manager.ManagerId,true);//manager's manager is car director
                        }
                        else
                        {
                            managerVsIsdirectorMap.put(userObj.Manager.ManagerId,false);//manager's manager is not car director
                        }
                    }                   
                }
                //Here creating three maps - iterating over valid events where 
                //1. carVsCountMap - fill this map with car id and number of sales event. Though always it will be one event, but as it is trigger, bulkified
                //2. carMgrVsCountMap - fill this map with car manager id and number of sales event
                //3 - carDirectorVsCountMap - fill this map with car director id and number of sales event
                for(String eventId: valideventIdVsassignedcarmap.keySet()){
                    tempcarCount = 0;
                    tempcarMgrCount = 0;
                    tempcarDirCount = 0;
                    carId = valideventIdVsassignedcarmap.get(eventId);
                    if(!String.isBlank(carId)){
                        if(carVsCountMap.containsKey(carId))// if car has more than 1 sales event in this iteration
                        {
                            tempcarCount = carVsCountMap.get(carId);
                        }
                        tempcarCount++;
                        carVsCountMap.put(carId,tempcarCount);
                            carManagerId = carVsCarMgrMap.get(carId);
                        if(!String.isBlank(carManagerId)){  
                            if(managerVsIsdirectorMap.containsKey(carManagerId)){
                                if(!managerVsIsdirectorMap.get(carManagerId))//manager is not car director
                                {
                                    if(!carMgrVsCountMap.isEmpty() && carMgrVsCountMap.containsKey(carManagerId))// if more than 1 sales event in this iteration
                                    {
                                        tempcarMgrCount = carMgrVsCountMap.get(carManagerId);
                                    }
                                    tempcarMgrCount++;
                                    carMgrVsCountMap.put(carManagerId,tempcarMgrCount);//final count for manager
                                }
                                else//when manager is car director 
                                {
                                    if(!carDirectorVsCountMap.isEmpty() && carDirectorVsCountMap.containsKey(carManagerId))// if more than 1 sales event in this iteration
                                    {
                                        tempcarDirCount = carDirectorVsCountMap.get(carManagerId);
                                    }
                                    tempcarDirCount++;
                                    carDirectorVsCountMap.put(carManagerId,tempcarDirCount);//final count for director
                                }
                            }
                        }
                        tempcarDirCount = 0;
                        carDirectorId = carVsCarDirMap.get(carId);
                        if(!String.isBlank(carDirectorId)){
                            if(!managerVsIsdirectorMap.isEmpty() && managerVsIsdirectorMap.containsKey(carDirectorId)){//when director
                                if(!carDirectorVsCountMap.isEmpty() && carDirectorVsCountMap.containsKey(carDirectorId))// if more than 1 sales event in this iteration
                                {
                                    tempcarDirCount = carDirectorVsCountMap.get(carDirectorId);
                                }
                                tempcarDirCount++;
                                carDirectorVsCountMap.put(carDirectorId,tempcarDirCount);//final count for director
                            }
                        }
                    }
                }
                //Fetching Event metrics of CAR, CAR Manager and CAR Director
                for(Metric metricObj : 
                        [SELECT ID, OwnerId, TargetValue, CurrentValue FROM Metric WHERE Name = :PL_Constants.METRIC_SALES_EVENT 
                         AND Goal.Status =: PL_Constants.GOAL_STATUS_PUBLISHED AND Goal.StartDate =: preGoalStartDate 
                         AND Goal.DueDate =:preGoalDueDate AND 
                         (OwnerId IN :carVsCountMap.keySet() OR OwnerId IN :carMgrVsCountMap.keySet() OR 
                         OwnerId IN :carDirectorVsCountMap.keySet())  
                         LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    if(!carVsCountMap.isEmpty() && carVsCountMap.containsKey(metricObj.OwnerId)){//if iterative metric's owner is car
                        metricObj.CurrentValue = metricObj.CurrentValue == null ? carVsCountMap.get(metricObj.OwnerId) : metricObj.CurrentValue+ carVsCountMap.get(metricObj.OwnerId);
                    }
                    if(!carMgrVsCountMap.isEmpty() && carMgrVsCountMap.containsKey(metricObj.OwnerId)){//if iterative metric's owner is car manager
                        metricObj.CurrentValue = metricObj.CurrentValue == null ? carMgrVsCountMap.get(metricObj.OwnerId) : metricObj.CurrentValue+ carMgrVsCountMap.get(metricObj.OwnerId);
                    }
                    if(!carDirectorVsCountMap.isEmpty() && carDirectorVsCountMap.containsKey(metricObj.OwnerId)){//if iterative metric's owner is car director
                        metricObj.CurrentValue = metricObj.CurrentValue == null ? carDirectorVsCountMap.get(metricObj.OwnerId) : metricObj.CurrentValue+ carDirectorVsCountMap.get(metricObj.OwnerId);
                    } 
                    metricList.add(metricObj);                     
                }
                if(!metricList.isEmpty()){
                    MetricTriggerController.allowValidation = false; //Disable the Metric Validation
                    Database.SaveResult[] saveResult = Database.update(metricList,true);// set this as true to avoid descrepancy may happen in metric between car and hirarchies that can be difficult to track  
                    if(!saveResult.isEmpty()){
                            ApplicationLogUtil.insertApplogforsaveresult(saveResult, ConstantHandler.STR_APPDMLEXCEPTION,
                                                                         PropertyEventTriggerOperation.class.getName() , 
                                                                         Metric.getSObjectType().getDescribe().getName(), 
                                                                         false, metricList, ConstantHandler.nonintegrationRTypeId);
                    }
                }
            }
        }catch(Exception e){
            ApplicationLogUtil.insertApplogforexceptions(e, ConstantHandler.STR_CLASS,PropertyEventTriggerOperation.class.getName(), Metric.getSObjectType().getDescribe().getName(), false, null, ConstantHandler.nonintegrationRTypeId);
        }   
    } 
}