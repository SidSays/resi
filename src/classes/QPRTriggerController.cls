/**
* Class Name: QPRTriggerController 
* Author: Animesh Datta, Accenture
* Date: 03-February-2017
* Requirement # US932271
* Description: Do not allow user to delete 'Completed' QPR record
* Last Modified :
*/
public class QPRTriggerController {
    
    private static final string QPR_COMPLETED = 'Completed';
   
    
    /**
    * @Description: This method prevents user to delete completed QPR records.   
    * @Author: Animesh Datta, Accenture
    * @Date: 03-February-2017
    * @Param: Trigger.Old,Trigger.oldMap,
    * @Return: void.
    */
    
    public static void doNotDeleteCompletedQPR(List<Quarterly_Portfolio_Review__c> oldQPRList, Map<Id,Quarterly_Portfolio_Review__c> oldTriggerMap){
        String loggedInUserId = UserInfo.getUserId();
        try{
            if(!oldQPRList.isEmpty()){
            for(Quarterly_Portfolio_Review__c portfolioObj: [SELECT Id,Status__c,Coaching__c,Coaching__r.CoachedId, Coaching__r.CoachId FROM Quarterly_Portfolio_Review__c WHERE Id In: oldQPRList]){
                if(portfolioObj.Coaching__r.CoachedId !=null && portfolioObj.Coaching__r.CoachId !=null && portfolioObj.Status__c !=null){
                    if(QPR_COMPLETED.equalsIgnoreCase(portfolioObj.Status__c) && (loggedInUserId.equalsIgnoreCase(portfolioObj.Coaching__r.CoachedId) || loggedInUserId.equalsIgnoreCase(portfolioObj.Coaching__r.CoachId))){
                        oldTriggerMap.get(portfolioObj.Id).addError(Label.QPRErrorMessageOnDelete);
                    }
                    else if(!loggedInUserId.equalsIgnoreCase(portfolioObj.Coaching__r.CoachedId) && !loggedInUserId.equalsIgnoreCase(portfolioObj.Coaching__r.CoachId)){
                        oldTriggerMap.get(portfolioObj.Id).addError(Label.QPRErrorMessageOnDeleteForOther);
                    }
                }   
            }
        }
        }catch(Exception ex){
            system.debug('***Following exception has occurred***'+ex.getMessage());
        }
    }
    
        
    /**
    * @Description: Check Selected Property Assigned to PersonCoach or not.   
    * @Author: Animesh Datta, Accenture
    * @Date: 10-February-2017
    * @Param: Trigger.new
    * @Return: void.
    */
    
    public static void isPropertyAssignedToCAR(List<Quarterly_Portfolio_Review__c> newQPRList){
        Set<String> setOfProperty = new Set<String>();
        Set<String> coachingIdSet = new Set<String>();
        Map<String, String> propIdAndAssignedCARMap = new Map<String, String>();
        Map<String, WorkCoaching> coachingIdAndCoachingMap;
        String personCoachId = '';
        
        try{
            for(Quarterly_Portfolio_Review__c qprObj: newQPRList){      
                if(qprObj.Top_Property_1__c!=null){             
                    setOfProperty.add(qprObj.Top_Property_1__c);
                }
                if(qprObj.Bottom_Property_1__c!=null){              
                    setOfProperty.add(qprObj.Bottom_Property_1__c);
                }
                if(qprObj.Top_Property_2__c!=null){
                    setOfProperty.add(qprObj.Top_Property_2__c);
                }
                if(qprObj.Bottom_Property_2__c!=null){
                    setOfProperty.add(qprObj.Bottom_Property_2__c);
                }
                if(qprObj.Top_Property_3__c!=null){
                    setOfProperty.add(qprObj.Top_Property_3__c);
                }
                if(qprObj.Bottom_Property_3__c!=null){
                    setOfProperty.add(qprObj.Bottom_Property_3__c);
                }
                if(qprObj.Top_Property_4__c!=null){
                    setOfProperty.add(qprObj.Top_Property_4__c);
                }
                if(qprObj.Bottom_Property_4__c!=null){
                    setOfProperty.add(qprObj.Bottom_Property_4__c);
                }
                if(qprObj.Top_Property_5__c!=null){
                    setOfProperty.add(qprObj.Top_Property_5__c);
                }
                if(qprObj.Bottom_Property_5__c!=null){
                    setOfProperty.add(qprObj.Bottom_Property_5__c);
                }
                
                coachingIdSet.add(qprObj.Coaching__c);
            }
            if(!setOfProperty.isEmpty()){
                for(MDU_Property__c propObj : [SELECT Id, Assigned_CAR__c FROM MDU_Property__c WHERE Id IN: setOfProperty]){
                    propIdAndAssignedCARMap.put(propObj.Id, propObj.Assigned_CAR__c);
                }
            }
            
            if(!coachingIdSet.isEmpty()){
                coachingIdAndCoachingMap = new Map<String, WorkCoaching>();
                for(WorkCoaching coachingObj : [SELECT Id, CoachedId FROM WorkCoaching WHERE Id IN: coachingIdSet]){
                    coachingIdAndCoachingMap.put(coachingObj.Id, coachingObj);
                }
            }
            
            for(Quarterly_Portfolio_Review__c qprObj: newQPRList){              
                personCoachId = coachingIdAndCoachingMap.get(qprObj.Coaching__c).CoachedId;             
                if(!propIdAndAssignedCARMap.isEmpty()){
                    if((qprObj.Top_Property_1__c != null && propIdAndAssignedCARMap.containsKey(qprObj.Top_Property_1__c) && propIdAndAssignedCARMap.get(qprObj.Top_Property_1__c) != personCoachId) ||
                    (qprObj.Top_Property_2__c != null && propIdAndAssignedCARMap.containsKey(qprObj.Top_Property_2__c) && propIdAndAssignedCARMap.get(qprObj.Top_Property_2__c) != personCoachId) ||
                    (qprObj.Top_Property_3__c != null && propIdAndAssignedCARMap.containsKey(qprObj.Top_Property_3__c) && propIdAndAssignedCARMap.get(qprObj.Top_Property_3__c) != personCoachId) ||
                    (qprObj.Top_Property_4__c != null && propIdAndAssignedCARMap.containsKey(qprObj.Top_Property_4__c) && propIdAndAssignedCARMap.get(qprObj.Top_Property_4__c) != personCoachId) ||
                    (qprObj.Top_Property_5__c != null && propIdAndAssignedCARMap.containsKey(qprObj.Top_Property_5__c) && propIdAndAssignedCARMap.get(qprObj.Top_Property_5__c) != personCoachId) ||
                    (qprObj.Bottom_Property_1__c != null && propIdAndAssignedCARMap.containsKey(qprObj.Bottom_Property_1__c) && propIdAndAssignedCARMap.get(qprObj.Bottom_Property_1__c) != personCoachId) ||
                    (qprObj.Bottom_Property_2__c != null && propIdAndAssignedCARMap.containsKey(qprObj.Bottom_Property_2__c) && propIdAndAssignedCARMap.get(qprObj.Bottom_Property_2__c) != personCoachId) ||
                    (qprObj.Bottom_Property_3__c != null && propIdAndAssignedCARMap.containsKey(qprObj.Bottom_Property_3__c) && propIdAndAssignedCARMap.get(qprObj.Bottom_Property_3__c) != personCoachId) ||
                    (qprObj.Bottom_Property_4__c != null && propIdAndAssignedCARMap.containsKey(qprObj.Bottom_Property_4__c) && propIdAndAssignedCARMap.get(qprObj.Bottom_Property_4__c) != personCoachId) ||
                    (qprObj.Bottom_Property_5__c != null && propIdAndAssignedCARMap.containsKey(qprObj.Bottom_Property_5__c) && propIdAndAssignedCARMap.get(qprObj.Bottom_Property_5__c) != personCoachId)){
                        qprObj.addError('Only Property Assigned to CAR can be selected');
                    }
                }
            }
        }catch(Exception ex){
            system.debug('***Following exception has occurred***'+ex.getMessage());
        }
    }
    
    /**
    * @Description: Check Selected Property Assigned to PersonCoach or not while updating QPR.   
    * @Author: Animesh Datta, Accenture
    * @Date: 10-February-2017
    * @Param: Trigger.new,Trigger.oldMap
    * @Return: void.
    */
    
    public static void isUpdatePropertyAssignedToCAR(List<Quarterly_Portfolio_Review__c> newQPRList, Map<Id,Quarterly_Portfolio_Review__c> oldQPRMap){
        List<Quarterly_Portfolio_Review__c> updatedQPRList = new List<Quarterly_Portfolio_Review__c>();
        try{
            for(Quarterly_Portfolio_Review__c qprObj: newQPRList){
                if((qprObj.Top_Property_1__c != oldQPRMap.get(qprObj.Id).Top_Property_1__c) || (qprObj.Top_Property_2__c != oldQPRMap.get(qprObj.Id).Top_Property_2__c)
                    || (qprObj.Top_Property_3__c != oldQPRMap.get(qprObj.Id).Top_Property_3__c) || (qprObj.Top_Property_4__c != oldQPRMap.get(qprObj.Id).Top_Property_4__c) 
                    || (qprObj.Top_Property_5__c != oldQPRMap.get(qprObj.Id).Top_Property_5__c) || (qprObj.Bottom_Property_1__c != oldQPRMap.get(qprObj.Id).Bottom_Property_1__c)
                    || (qprObj.Bottom_Property_2__c != oldQPRMap.get(qprObj.Id).Bottom_Property_2__c) || (qprObj.Bottom_Property_3__c != oldQPRMap.get(qprObj.Id).Bottom_Property_3__c)
                    || (qprObj.Bottom_Property_4__c != oldQPRMap.get(qprObj.Id).Bottom_Property_4__c) || (qprObj.Bottom_Property_5__c != oldQPRMap.get(qprObj.Id).Bottom_Property_5__c)){
                     updatedQPRList.add(qprObj);
                }
            }

            if(!updatedQPRList.isEmpty()){
                isPropertyAssignedToCAR(updatedQPRList);
            }
        }catch(Exception ex){
            system.debug('***Following exception has occurred***'+ex.getMessage());
        }
    }
    /**
    * @Description: Duplicate check if any of the Properties among 10 is duplicate. Throw validation if duplicate.   
    * @Author: Animesh Datta, Accenture
    * @Date: 10-February-2017
    * @Param: Trigger.new,
    * @Return: void.
    */
    
    public static void duplicatePropertyCheck(List<Quarterly_Portfolio_Review__c> newQPRList){
        
        List<String> listOfProperty = new List<String>();
        Set<String> setOfProperty = new Set<String>();
        
        try{
            for(Quarterly_Portfolio_Review__c qprObj: newQPRList){      
                if(qprObj.Top_Property_1__c!=null){
                    listOfProperty.add(qprObj.Top_Property_1__c);
                    setOfProperty.add(qprObj.Top_Property_1__c);
                }
                if(qprObj.Bottom_Property_1__c!=null){
                    listOfProperty.add(qprObj.Bottom_Property_1__c);
                    setOfProperty.add(qprObj.Bottom_Property_1__c);
                }
                if(qprObj.Top_Property_2__c!=null){
                    listOfProperty.add(qprObj.Top_Property_2__c);
                    setOfProperty.add(qprObj.Top_Property_2__c);
                }
                if(qprObj.Bottom_Property_2__c!=null){
                    listOfProperty.add(qprObj.Bottom_Property_2__c);
                    setOfProperty.add(qprObj.Bottom_Property_2__c);
                }
                if(qprObj.Top_Property_3__c!=null){
                    listOfProperty.add(qprObj.Top_Property_3__c);
                    setOfProperty.add(qprObj.Top_Property_3__c);
                }
                if(qprObj.Bottom_Property_3__c!=null){
                    listOfProperty.add(qprObj.Bottom_Property_3__c);
                    setOfProperty.add(qprObj.Bottom_Property_3__c);
                }
                if(qprObj.Top_Property_4__c!=null){
                    listOfProperty.add(qprObj.Top_Property_4__c);
                    setOfProperty.add(qprObj.Top_Property_4__c);
                }
                if(qprObj.Bottom_Property_4__c!=null){
                    listOfProperty.add(qprObj.Bottom_Property_4__c);
                    setOfProperty.add(qprObj.Bottom_Property_4__c);
                }
                if(qprObj.Top_Property_5__c!=null){
                    listOfProperty.add(qprObj.Top_Property_5__c);
                    setOfProperty.add(qprObj.Top_Property_5__c);
                }
                if(qprObj.Bottom_Property_5__c!=null){
                    listOfProperty.add(qprObj.Bottom_Property_5__c);
                    setOfProperty.add(qprObj.Bottom_Property_5__c);
                }           
                if(setOfProperty.size() != listOfProperty.size()){
                    qprObj.addError('You can not add duplicate property. All 10 Properties should be unique');
                }
                setOfProperty.clear();
                listOfProperty.clear();
            }
            
        }catch(Exception ex){
            system.debug('***Following exception has occurred***'+ex.getMessage());
        }     
    }
    
    /**
    * @Description: This method is for CAR and CAR Manager.They can only create one QPR record per CAR per fiscal quarter   
    * @Author: Suchita Sharma, Accenture
    * @Date: 07-February-2017
    * @Param: Trigger.New
    * @Return: void
    */
    
    
    public static void validationOnQPRPerFiscalYear(List<Quarterly_Portfolio_Review__c> newQPRList){
    
    Set<String> coachingIdSet = new Set<String>();
    Map<Id, List<Quarterly_Portfolio_Review__c>> coachingIdQPRListMap = new Map<Id, List<Quarterly_Portfolio_Review__c>>();
    Set<Id> existingCoachingIdSet = new Set<Id>();
    Boolean setVar = false;
    List<Quarterly_Portfolio_Review__c> qprTempList;
    String quater= 'Q1';
    Date d = System.now().date();
    String year = String.valueOf(d.year());
    String quaterYear;
    
    for(Quarterly_Portfolio_Review__c QPRList : newQPRList){
            if(QPRList.Coaching__c != null){                
                coachingIdSet.add(QPRList.Coaching__c);
                
            }
     }
   

    If(d>= date.newinstance(d.year(),3,22) && d<= date.newinstance(d.year(),6,21)){
    quater = 'Q2';  
    }
    else If(d>= date.newinstance(d.year(),6,22) && d <= date.newinstance(d.year(),9,21)){
    quater = 'Q3';
    }
    else If(d>= date.newinstance(d.year(),9,22) && d <= date.newinstance(d.year(),12,21)){
    quater = 'Q4';
    }

    if(d.month()==12 && d>= date.newinstance(d.year(),12,22) ){
    year = String.valueOf(d.year()+1);
    }

    quaterYear= quater+year;        
    
    for (Quarterly_Portfolio_Review__c existingQPR : [SELECT  Id, QuarterYear__c ,Coaching__c FROM Quarterly_Portfolio_Review__c WHERE Coaching__c =: coachingIdSet LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())] ) {     
    setVar = existingCoachingIdSet.add(existingQPR.Coaching__c);  
    if(setVar){
        qprTempList = new List<Quarterly_Portfolio_Review__c>();               
    }else{
        qprTempList = coachingIdQPRListMap.get(existingQPR.Coaching__c);
    }
    qprTempList.add(existingQPR);
    coachingIdQPRListMap.put(existingQPR.Coaching__c ,qprTempList ); 
    }
    
    for(Quarterly_Portfolio_Review__c qpr : newQPRList){
        if(coachingIdQPRListMap.containsKey(qpr.Coaching__c)){
            for(Quarterly_Portfolio_Review__c QPRList :coachingIdQPRListMap.get(qpr.Coaching__c)){
                if(QPRList.QuarterYear__c == quaterYear && QPRList.Coaching__c==qpr.Coaching__c ){                   
                    qpr.addError(Label.QPRErrorMessageOnCreateSameFiscalQuarter);
                    
                }
            }
        }
    }
    }
}