/**************************************************************************************************
* Name : OpportunityTriggerOperations
* Description : Business logic to Set Date AE and Date Stage based on Assigned AE and Stage on Opportunity
* User Story : 
* Date : 15 Jan 2015
* Author : Ashish Sonawane
***************************************************************************************************/
public class OpportunityTriggerOperations{
//Data Member
    public static final String UPDATE_OPERATION = 'Update';
    public static final String INSERT_OPERATION = 'Insert';
    private static final string LABEL_NAME_SPLIT = ';';
    private static final string OBJECT_TYPE = 'Opportunity'; 
    private static final string CLOSE_WON_STAGE = 'Closed Won';
    private static final string CLOSE_LOST_STAGE = 'Closed Lost';
    private static final string New_Build = 'New Build';
    private static final string Win_Back = 'Win Back';                  
    private static final string Renewal = 'Renewal';
    private static final string UNITS = 'Units';
    private static final string TOTALUNITS = 'Total Units';
    private static final string New_Business = 'New Business';
    private static final string INDUSTRY_TYPE_EDUCATION = 'Education';
    private static final string REGION_SALES_REP_TYPE = 'Region';
    private static final string XC_PORTFOLIO_AE = 'XC Portfolio AE';
    private static final string XC_MANAGER = 'XC Manager';
    private static final string XFINITY_OPPORTUNITY_RECORDTYPE = 'Xfinity Opportunity Record Type';
    private static final String XC_ACCOUNT_EXECUTIVE = 'XC Account Executive'; 
    private static final String XC_AE_CONTRACTOR = System.Label.XC_AE_Contractors;
    
    //Metric ND Goal Status constants
    private static final String ONTRACK_STATUS = 'OnTrack';
    private static final String BEHIND_STATUS = 'Behind';
    private static final String CRITICAL_STATUS = 'Critical';
    private static final String PUBLISHED_GOAL_STATUS = 'Published';
    
    
    //Initialize opportunity stage     
    private static final Set<string> OPPORTUNITY_STAGES_TO_SHOW_MESSAGE = new set<string> 
                                       {'Contact Made','Negotiating','Contract Document Review','Final Contract Sent','Closed Won','Closed Lost'};    
    
    private static final Set<string> closeOpportunitySet =  new set<string> {'Closed Won','Closed Lost'};
    private static final Set<string> openOpportunitySet =  new set<string> {'Assigned','Contact Made','Negotiating','Contract Document Review','Final Contract Sent'};
    
    private static final Set<String> SMALL_BUSINESS_SALES_REP_TYPE = new Set<String>{'NAM','NED','Division'};
    public static final String xfinityOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(System.Label.XfinityOpportunityRecordType).getRecordTypeId();
    public static final String xfinityGoalRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(System.Label.Goal_Xfinity_Communities_Recordtype).getRecordTypeId();
    
      
   /*
   * Description : Method execute logic to set AE Assigned Date and Stage Date
   * Date : 15 Jan 2015
   * Author : Ashish Sonawane
   * Updated By : Malay Desai 28/10/16
   */
    public static void beforeUpdateOrInsertOperation(){     

        Map<id,Opportunity> oldOpportunityMap = new Map<id,Opportunity>();
        string operation = Trigger.IsInsert ? INSERT_OPERATION : UPDATE_OPERATION;
        if(UPDATE_OPERATION.equalsIgnoreCase(operation)){
            oldOpportunityMap  = (Map<id,Opportunity>) Trigger.OldMap;
        }
        
        for(Opportunity tempOpportunity : (List<Opportunity>) Trigger.New){
            if(xfinityOpportunityRecordTypeId != null && 
               xfinityOpportunityRecordTypeId.equalsIgnoreCase(tempOpportunity.RecordTypeId)){ 
                if(!UPDATE_OPERATION.equalsIgnoreCase(operation)){  
                    
                    //Set Assigned AE As Opportunity Owner 
                    if(tempOpportunity.AssignedAE_ID__c!=null){                  
                        tempOpportunity.ownerId = tempOpportunity.AssignedAE_ID__c ;
                        tempOpportunity.DateAEAssigned__c = System.today();    
                    }                       
                    if(tempOpportunity.StageName != null){
                        tempOpportunity.Date_in_Stage__c = System.today();
                    } 
                } 
                else if(UPDATE_OPERATION.equalsIgnoreCase(operation)){
                    //Set Date AE Assigned only if AE Assigned Changed and Set Assigned AE user to Owner of record 
                    if(oldOpportunityMap.get(tempOpportunity.id)!=null && tempOpportunity.AssignedAE_ID__c!=null && 
                       oldOpportunityMap.get(tempOpportunity.id).AssignedAE_ID__c != tempOpportunity.AssignedAE_ID__c ){
                        
                        tempOpportunity.ownerId = tempOpportunity.AssignedAE_ID__c ;
                        tempOpportunity.DateAEAssigned__c = System.today();                                                               
                    }
                    if(oldOpportunityMap.get(tempOpportunity.id).StageName != tempOpportunity.StageName){
                        tempOpportunity.Date_in_Stage__c = System.today();
                    }  
                }
            }  
        }      
    }
   
    /*
    Name : setOpportunityStagValidation
    Description : Use to show validation message if opportunity stage above 'Contact Made' for opportunity (having no related property in sale portfolio).
    Author : Ashish G. Sonawane
    Updated By : Malay Desai 28/10/16
    Parameters : None
    Return : void      
    */ 
    public static void setOpportunityStagValidation() {
         
        Set<id> setOpportunityId = new set<id>();
        Set<id> newOpportunityIdSet = new Set<id>();
        Map<Id,Opportunity> oldOpportunityMap = new Map<Id,Opportunity>();
        
        oldOpportunityMap = (Map<Id, Opportunity>) Trigger.oldMap;   
        for(Opportunity instantOpportunity :(List<Opportunity>) Trigger.New) {
            newOpportunityIdSet.add(instantOpportunity.id);
        }
            
        //Uncomment below code   
        if(!newOpportunityIdSet.isEmpty()) {        
            for (Opportunity_Property__c instantOptyProperty : [SELECT id, Opportunity__c 
                                                                 FROM Opportunity_Property__c 
                                                                 WHERE Opportunity__c =: newOpportunityIdSet
                                                                 LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())] ) {      
                setOpportunityId.add(instantOptyProperty.Opportunity__c) ;
            }
            string sOpportunityStageValidationMessage = System.Label.Opportunity_Stage_Validation_Message;
            for(Opportunity instantOpportunity :(List<Opportunity>) Trigger.New)  {     
                if(!oldOpportunityMap.isEmpty() && xfinityOpportunityRecordTypeId != null   
                    && xfinityOpportunityRecordTypeId.equalsIgnoreCase(instantOpportunity.RecordTypeId) 
                    && oldOpportunityMap.get(instantOpportunity.Id).StageName != instantOpportunity.StageName){
                    if(!setOpportunityId.contains(instantOpportunity.id) 
                        && OPPORTUNITY_STAGES_TO_SHOW_MESSAGE.contains(instantOpportunity.StageName) 
                       ){
                        instantOpportunity.addError(sOpportunityStageValidationMessage);
                    }                    
                }        
            } 
        }                     
    } 

    /*
    * Name : createOpptyPropertyRecord
    * Description : Create a OpportunityProperty Record if the Property details are passed from the Property object. 
    * Also, set the property as Primary property on Opportunity property record
    * Parameters : None
    * Return : void    
    * Author : Abhishek Mathur    
    * Updated By : Malay Desai 28/10/16
    */ 
    public static void createOpptyPropertyRecord() {
     
        list<Opportunity_Property__c> opptyPropertyList = new list<Opportunity_Property__c>();
               
        for(Opportunity instantOpportunity :(List<Opportunity>) Trigger.New)  {
            if(xfinityOpportunityRecordTypeId != null &&  
               xfinityOpportunityRecordTypeId.equalsIgnoreCase(instantOpportunity.RecordTypeId)){
                if(instantOpportunity.Property__c != null){                 
                    Opportunity_Property__c opptyPropertyRecord = new Opportunity_Property__c();
                    opptyPropertyRecord.Opportunity__c = instantOpportunity.ID;
                    opptyPropertyRecord.Property__c = instantOpportunity.Property__c;                  
                    opptyPropertyList.add(opptyPropertyRecord);
                }                 
            }         
        } 
               
         //Insert DML Opearation        
        if(!opptyPropertyList.IsEmpty()){                                     
            Database.SaveResult[] saveresultInsert = Database.insert(opptyPropertyList, false);                  
        } 
     
    }
      
    /*
    Name : propertyActiveOpportunityCheck
    Description : Set active opportunity check box check if property has any open opportunity 
    Parameters : None
    Return : void    
    Author : Ashish Sonawane   
    Updated By : Malay Desai 28/10/16
    */ 
    /*public static void propertyActiveOpportunityCheck(List<Opportunity> opportunityList){
        Set<String> opportunityIdSet = new Set<String>();
        Set<String> propertyIdSet = new Set<String>();
        
        List<MDU_Property__c> propertyObjectList = new List<MDU_Property__c>(); 
        List<MDU_Property__c> propertyTempList = new List<MDU_Property__c>();
        List<Opportunity_Property__c> opportunityPropertyTempList;
        Map<Id,Opportunity> oldOpportunityMap = new Map<Id,Opportunity>();
        Map<Id, List<Opportunity_Property__c>> opportunityPropertyMap =  new Map<Id, List<Opportunity_Property__c>>();
        Boolean setVar;
        if(Trigger.isUpdate){
            oldOpportunityMap = (Map<Id, Opportunity>) Trigger.oldMap; 
        }
        
        for(Opportunity opportunityObj : opportunityList){
            if(Trigger.isUpdate){
                    if(opportunityObj.StageName != oldOpportunityMap.get(opportunityObj.Id).StageName){                
                opportunityIdSet.add(opportunityObj.Id);  
                }               
            }else if(Trigger.isInsert){                
                opportunityIdSet.add(opportunityObj.Id); 
            } 
        }   
        for (Opportunity_Property__c instantOptyProperty : [SELECT id, Opportunity__c ,Property__c, Opportunity__r.StageName,
                                                            Property__r.Active_Opportunity__c
                                                             FROM Opportunity_Property__c 
                                                             WHERE Opportunity__c =: opportunityIdSet                                                
                                                             LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())] ) {      
            
            setVar = propertyIdSet.add(instantOptyProperty.Property__c);  
            if(setVar){
                opportunityPropertyTempList = new List<Opportunity_Property__c>();
                MDU_Property__c tempProperty = new MDU_Property__c(Id = instantOptyProperty.Property__c, 
                                                    Active_Opportunity__c = instantOptyProperty.Property__r.Active_Opportunity__c);
                propertyTempList.add(tempProperty);
            }else{
                opportunityPropertyTempList = opportunityPropertyMap.get(instantOptyProperty.Property__c);
            }
            opportunityPropertyTempList.add(instantOptyProperty);
            opportunityPropertyMap.put(instantOptyProperty.Property__c ,opportunityPropertyTempList ); 
        }
        
        for(MDU_Property__c propertyObject : propertyTempList){
                            
                boolean checkActive = false;
                for(Opportunity_Property__c optyPropetty : opportunityPropertyMap.get(propertyObject.Id)){  
                    if(!CLOSE_WON_STAGE.equalsIgnoreCase(optyPropetty.Opportunity__r.StageName) 
                        && !CLOSE_LOST_STAGE.equalsIgnoreCase(optyPropetty.Opportunity__r.StageName)) {                                       
                        checkActive = true;                                              
                    }
                }
            
            if(propertyObject.Active_Opportunity__c != checkActive){
                propertyObject.Active_Opportunity__c = checkActive;
                propertyObjectList.add(propertyObject);
            }                               
        }      
        
        if(!propertyObjectList.isEmpty()){  
            Database.update(propertyObjectList,false);
        }                        
    }*/
    
    /*
    Name : setActiveOpportunityAndUpdateClosedFields
    Description :   This method update the Closed date, Closed Property Rating and Closed Risk Status of the Property related to 
                    opportunity with Stage "Closed Won". It also sets Active_Opportunity checkbox on Property if the Property 
                    has any opportunity which is not Closed Won or Closed Lost.
    Note: This method is combined to accomplish 2 different updates on Property to save DML and Multiple Trigger execution on Property. 
    Original Authors : Ashish Sonawne(Active Opportunity), Akanksha Singhal(US683252-Closed date, Property Rating and Risk Status)
    User Story : US683252(Upload data for 3 property fields)
    Updated By : Malay Desai 30/10/16 (Merging)
    */
    public static void setActiveOpportunityAndUpdateClosedFields(List<Opportunity> newOpptyList, Map<Id,Opportunity> oldOpptyMap){
        
        Set<ID> OpptyStageUpdateSet= new Set<ID>();   
        Map<Id,List<Opportunity_Property__c>> opportunityPropertyMap = new Map<Id,List<Opportunity_Property__c>>();
        List<MDU_Property__c> propertyTempList = new List<MDU_Property__c>();
        List<MDU_Property__c> propertyUpdateList = new List<MDU_Property__c>();
        Set<Id> propertyIdSet =  new Set<Id>();
        List<Opportunity_Property__c> opportunityPropertyTempList; 
        List<Date> dateInStageForAllOppty = new List<Date>();
        Boolean setVar, addProperty; 
        
        for(Opportunity oppTemp : newOpptyList){
            if(oppTemp.RecordtypeId.equals(xfinityOpportunityRecordTypeId)){            
                if(oldOpptyMap != null){ // Update
                    if(oppTemp.StageName != oldOpptyMap.get(oppTemp.Id).StageName){                
                    OpptyStageUpdateSet.add(oppTemp.Id);  
                  }               
              }else { // Insert               
                  OpptyStageUpdateSet.add(oppTemp.Id); 
              }
            } 
        }
        
        if(!OpptyStageUpdateSet.isEmpty()){
            
            for (Opportunity_Property__c instantOptyProperty : [SELECT id, Opportunity__c ,Property__c,Opportunity__r.Date_in_Stage__c,
                                                                Property__r.Risk_Status__c, Property__r.Property_Rating__c,
                                                                Property__r.Active_Opportunity__c,Opportunity__r.StageName
                                                                FROM Opportunity_Property__c 
                                                                WHERE Opportunity__c IN: OpptyStageUpdateSet                                                
                                                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())] ) {      
            
                setVar = propertyIdSet.add(instantOptyProperty.Property__c);  
                if(setVar){
                    opportunityPropertyTempList = new List<Opportunity_Property__c>();
                    MDU_Property__c tempProperty = new MDU_Property__c(Id = instantOptyProperty.Property__c, 
                                                        Risk_Status__c = instantOptyProperty.Property__r.Risk_Status__c,
                                                        Property_Rating__c = instantOptyProperty.Property__r.Property_Rating__c,
                                                        Active_Opportunity__c = instantOptyProperty.Property__r.Active_Opportunity__c);
                    propertyTempList.add(tempProperty);
                }else{
                    opportunityPropertyTempList = opportunityPropertyMap.get(instantOptyProperty.Property__c);
                }
                opportunityPropertyTempList.add(instantOptyProperty);
                opportunityPropertyMap.put(instantOptyProperty.Property__c ,opportunityPropertyTempList ); 
            }
            
            for(MDU_Property__c propertyObject : propertyTempList){
                /* Update Closed Date, Closed Risk Status and Closed Property Rating*/
                dateInStageForAllOppty = new List<Date>();
                addProperty = false;         
                for(Opportunity_Property__c optyPropetty : opportunityPropertyMap.get(propertyObject.Id)){
                    if(optyPropetty.Opportunity__r.StageName.equals(CLOSE_WON_STAGE)){
                        if(optyPropetty.Opportunity__r.Date_in_Stage__c != null){  
                            dateInStageForAllOppty.add(optyPropetty.Opportunity__r.Date_in_Stage__c);
                        }
                    }
                }
                
                if(dateInStageForAllOppty.size() > 0){
                    dateInStageForAllOppty.sort();
                    Date highestDate = dateInStageForAllOppty[dateInStageForAllOppty.size()-1];
                    //Date dt = Date.newInstance(highestDate.year(), highestDate.month(),highestDate.day());
                    propertyObject.Closed_Date__c = highestDate;
                    propertyObject.Closed_Risk_Status__c = propertyObject.Risk_Status__c;
                    propertyObject.Closed_Property_Rating__c = propertyObject.Property_Rating__c;
                    
                    addProperty = true;
                }
                
                /* Update Active Opportunity */
                
                boolean checkActive = false;
                for(Opportunity_Property__c optyPropetty : opportunityPropertyMap.get(propertyObject.Id)){  
                    if(!CLOSE_WON_STAGE.equalsIgnoreCase(optyPropetty.Opportunity__r.StageName) 
                        && !CLOSE_LOST_STAGE.equalsIgnoreCase(optyPropetty.Opportunity__r.StageName)) {                                       
                        checkActive = true;                                              
                    }
                }
            
                if(propertyObject.Active_Opportunity__c != checkActive){
                    propertyObject.Active_Opportunity__c = checkActive;
                    addProperty = true;
                }
                
                if(addProperty){
                  propertyUpdateList.add(propertyObject);
                }
            }     
            
            if(!propertyUpdateList.isEmpty()){
                Database.update(propertyUpdateList,false);
            }
        }
    }
    
   /*
    *  Update Active opportunity flag on property before deleting Opportunity
    */
    public static void propertyActiveOpptySetkOnDel(){
        
        Map<Id, MDU_Property__c> propertyMap = new Map<Id, MDU_Property__c>();  
        Set<String> propertyIdSet = new Set<String>();
        List<MDU_Property__c> propertyObjectList = new List<MDU_Property__c>(); 
        
        for (Opportunity_Property__c instantOptyProperty : [SELECT id, Opportunity__c ,Property__C
                                                             FROM Opportunity_Property__c 
                                                             WHERE Opportunity__c IN :Trigger.Old Order by Opportunity__r.Date_In_Stage__c DESC                                              
                                                             LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())] ) {      
            
            propertyIdSet.add(instantOptyProperty.Property__C);                   
        }
        
        for(MDU_Property__c propertyObject : [  SELECT Id,Active_Opportunity__c,Current_Opportunity__c, (SELECT Id,Property__C,Opportunity__c, Opportunity__r.StageName,
                                                                                          Opportunity__r.Name
                                                                                    FROM Opportunity_Properties__r 
                                                                                   WHERE Opportunity__c NOT IN :Trigger.Old Order by Opportunity__r.Date_In_Stage__c DESC ) 
                                                FROM MDU_Property__c                                                      
                                                WHERE ID  IN:propertyIdSet
                                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){      
            boolean checkActive = false;
            for(Opportunity_Property__c optyPropetty : propertyObject.Opportunity_Properties__r){                                              
                if(!CLOSE_WON_STAGE.equalsIgnoreCase(optyPropetty.Opportunity__r.StageName) 
                    && !CLOSE_LOST_STAGE.equalsIgnoreCase(optyPropetty.Opportunity__r.StageName)) {                    
                    checkActive = true;                                              
                }
                
                if(propertyMap.get(optyPropetty.Property__c)==null){
                    propertyMap.put(optyPropetty.Property__c, new MDU_Property__c(Id=optyPropetty.Property__c, Current_Opportunity__c = optyPropetty.Opportunity__c));
                }
            }
           
            if(propertyObject.Active_Opportunity__c != checkActive){
                if(propertyMap.get(propertyObject.Id) != null){
                propertyObject = propertyMap.get(propertyObject.Id);
                propertyObject.Active_Opportunity__c = checkActive;
                propertyMap.put(propertyObject.Id, propertyObject);
                }
                else
                {
                    propertyObject.Active_Opportunity__c = checkActive;
                    propertyMap.put(propertyObject.Id, propertyObject);
                }
            }                              
        }
        //Added for US560432
         if(!propertyMap.isEmpty()){
         propertyObjectList.addAll(propertyMap.values()); 
         }
        //End
        Database.update(propertyObjectList,false);      
    }
    
    /*
     *  Name : updateGoalOnClosedWoncheck
     *  Description : Set total number of units when an opportunity Closed Won on the metric record of the assigned AE and its subsequent manager and Manager.Manager.
     *  Parameters : None
     *  Return : void
     *  User Story : US516886 (Quota Template for AE & Mgr)
     *  Author : Lalit Singh
     *  Modified By : Sucheta Verma
     *  User Story : US527614 (Goal association to Opportunity and Quota update)    
     *  Description : On change of Opportunity Stage from 'Closed Won' to earlier stage OR to again 'Closed won' - actual in Metric for Assigned AE Goal record should be subtracted/added accordingly.
                      Relationship between Oppty and Goal should exist when stage of Opportunity is 'Closed Won'.
     *  Modified By : Amit Kumar Pradhan
     *  User Story : US610408(XC Quota: Update to Quota records)
     *  Description : 1. AE is NOT a Portfolio AE (Profile) or National Account Manager (User/Profile to be configured in a custom setting), then update the AE manager’s quota
                      2. “Contractor AE” owned opportunity, update the Contractor’s quota for that month and then look up the manager they roll up to in the region and update that manager’s quota
                      3. opportunity is closed by a manager, update only the manager’s quota for that month
     */
     
    public static void updateGoalOnClosedWoncheck(List<Opportunity> oppList){
        System.debug('*****inside updateGoalOnClosedWoncheck*****');
        
        Map<String,Decimal> assignedAETotalUnitsMap = new Map<String,Decimal>(); 
        Map<String,Decimal> assignedAENewBusinessUnitsMap = new Map<String,Decimal>();

        Map<String,String> userIdManagerIdMap = new Map<String,String>();
        Map<String,String> reportingMgrAndManagerIdMap = new Map<String,String>();

        Map<String,Decimal> reportingMgrTotalUnitsMap = new Map<String,Decimal>(); 
        Map<String,Decimal> reportingMgrNewBusinessUnitsMap = new Map<String,Decimal>();

        Map<String,Decimal> reportingMgrMgrTotalUnitsMap = new Map<String,Decimal>(); 
        Map<String,Decimal> reportingMgrMgrNewBusinessUnitsMap = new Map<String,Decimal>();

        Map<String,String> userIdRegionMap = new Map<String,String>();

        Map<String,Decimal> regionalLeadTotalUnitsMap = new Map<String,Decimal>(); 
        Map<String,Decimal> regionalLeadNewBusinessUnitsMap = new Map<String,Decimal>();

        Map<String,Metric> updateToMetricMap = new Map<String,Metric>();
        Set<String> regionalLeadIdSet = new Set<String>();
        Set<String> assignAEIdSet = new Set<String>();
        List<Opportunity> xfinityOppList = new List<Opportunity>();
        Set<String> setContractAEUserId = new Set<String>();
        Map<String,User> userIdAndUserMap = new Map<String,User>();
        Map<String,String> oppRegionMap = new Map<String,String>();
        Map<String,User> namNedDivisionUserMap = new Map<String,User>();
        //MetricTriggerController.allowValidation = false;  

        //Fetch RecordType for Xfinity Community
        String Xfinity_Communities_RecordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.Goal_Xfinity_Communities_Recordtype).getRecordTypeId();


        //Get NumberOfUnits for Assigned AE//(Need to check for OldMap and trigger.new)
        for(Opportunity OppObj: oppList){
            
            if(OppObj.RecordTypeid == xfinityOpportunityRecordTypeId && (OppObj.Type == New_Build || OppObj.Type == Win_Back || OppObj.Type == Renewal)){
                Opportunity oldOpp = new Opportunity();
                if(trigger.isUpdate){
                    oldOpp = (Opportunity)trigger.oldMap.get(OppObj.Id);
                }
                
                if((trigger.isInsert && OppObj.StageName == CLOSE_WON_STAGE) || 
                    (trigger.isUpdate && ((OppObj.StageName == CLOSE_WON_STAGE  && oldOpp.StageName != CLOSE_WON_STAGE ) 
                                            || (OppObj.StageName != CLOSE_WON_STAGE  && oldOpp.StageName == CLOSE_WON_STAGE)))){
                
                    if(OppObj.AssignedAE_ID__c != null || OppObj.AssignedAE_ID__c != ''){
                        xfinityOppList.add(OppObj);
                        assignAEIdSet.add(OppObj.AssignedAE_ID__c);                     
                    }
                }
            }
        }
        
        System.debug('*****xfinityOppList*****'+xfinityOppList);
        System.debug('*****assignAEIdSet*****'+assignAEIdSet);
        if(!assignAEIdSet.isEmpty()){    
            for(User userObject : [SELECT Id, Profile_Name_Text__c, Region__c, Sales_Rep_Type__c FROM User 
                                              WHERE UserPermissionsWorkDotComUserFeature = true AND Id IN : assignAEIdSet LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                
               
                if(userObject.Profile_Name_Text__c == System.Label.XC_AE_Contractors){
                    setContractAEUserId.add(userObject.Id);                                     
                }else{
                    if(userObject.Sales_Rep_Type__c != null && SMALL_BUSINESS_SALES_REP_TYPE.contains(userObject.Sales_Rep_Type__c)){
                        namNedDivisionUserMap.put(userObject.Id,userObject); //For NAM, NED, Divisin, Region User
                    }else if(userObject.Profile_Name_Text__c == XC_ACCOUNT_EXECUTIVE 
                            || userObject.Profile_Name_Text__c == XC_PORTFOLIO_AE 
                            || userObject.Profile_Name_Text__c == XC_MANAGER){
                        userIdAndUserMap.put(userObject.Id,userObject);
                    }                   
                }   
            }
        }   
        
        
        System.debug('*****setContractAEUserId*****'+setContractAEUserId);
        System.debug('*****userIdAndUserMap*****'+userIdAndUserMap);
        
        if(!setContractAEUserId.isEmpty()){  
            /*Fetching the Opportunity which has Primary Property For All AE Contractor*/
            for(Opportunity_Property__c oppPrimaryProperty : [SELECT ID, Property_Type__c, Name, Property_Region__c, Opportunity__c, Primary_Property__c, Opportunity__r.AssignedAE_ID__c 
                                                FROM Opportunity_Property__c WHERE Primary_Property__c = true AND Opportunity__r.AssignedAE_ID__c IN : setContractAEUserId AND Opportunity__c IN : xfinityOppList]){
                    String oppAssignedAEStr = '';                                                                                           
                    if(oppPrimaryProperty.Opportunity__c != Null && oppPrimaryProperty.Opportunity__r.AssignedAE_ID__c != Null){
                        oppAssignedAEStr = String.valueOf(oppPrimaryProperty.Opportunity__c)+String.valueOf(oppPrimaryProperty.Opportunity__r.AssignedAE_ID__c);
                        oppRegionMap.put(oppAssignedAEStr, oppPrimaryProperty.Property_Region__c );
                    }               
            }       
            
        }

        //Get NumberOfUnits for Assigned AE
        for(Opportunity OppObj : xfinityOppList){
                
                Opportunity oldOpp = new Opportunity();
                if(trigger.isUpdate){
                    oldOpp = (Opportunity)trigger.oldMap.get(OppObj.Id);
                }
                
                String keyString = '';
                Decimal totalTempCount = 0;
                Decimal totalNBTempCount = 0;
                
                
                if(setContractAEUserId.contains(OppObj.AssignedAE_ID__c)){
                    String oppIdAEIdString = String.valueOf(OppObj.Id)+String.valueOf(OppObj.AssignedAE_ID__c);
                    if(!oppRegionMap.isEmpty() && oppRegionMap.get(oppIdAEIdString) != null){
                        //Key String For Contractor Users
                        keyString = String.valueOf(OppObj.AssignedAE_ID__c)+oppRegionMap.get(oppIdAEIdString);
                    }                   
                }else if(!userIdAndUserMap.isEmpty() && userIdAndUserMap.get(OppObj.AssignedAE_ID__c) != null){
                    //Key String For AE, Portfolio AE, Normal XC mgr Users 
                    keyString = String.valueOf(OppObj.AssignedAE_ID__c)+userIdAndUserMap.get(OppObj.AssignedAE_ID__c).Region__c;
                }else if(!namNedDivisionUserMap.isEmpty() && namNedDivisionUserMap.get(OppObj.AssignedAE_ID__c) != null){
                    //Key String For NAM, NED, Division Users
                    keyString = String.valueOf(OppObj.AssignedAE_ID__c)+namNedDivisionUserMap.get(OppObj.AssignedAE_ID__c).Sales_Rep_Type__c;
                }
                
                
                
                //For Total Units Count For All Users
                if(!assignedAETotalUnitsMap.isEmpty() && assignedAETotalUnitsMap.get(keyString) != null){
                    totalTempCount = assignedAETotalUnitsMap.get(keyString);
                }
                
                if((trigger.isInsert && OppObj.StageName == CLOSE_WON_STAGE) 
                    || (trigger.isUpdate && (OppObj.StageName == CLOSE_WON_STAGE  && oldOpp.StageName != CLOSE_WON_STAGE ))){                       
                    totalTempCount += OppObj.Number_of_Units__c;
                }else if(trigger.isUpdate && (OppObj.StageName != CLOSE_WON_STAGE  && oldOpp.StageName == CLOSE_WON_STAGE)){
                    totalTempCount -= OppObj.Number_of_Units__c;
                }
                
                assignedAETotalUnitsMap.put(keyString,totalTempCount);
                
                
                //For NewBusiness Units Count For All Users
                if(OppObj.Type == Win_Back || OppObj.Type == New_Build){                
                    if(!assignedAENewBusinessUnitsMap.isEmpty() && assignedAENewBusinessUnitsMap.get(keyString) != null){
                        totalNBTempCount = assignedAENewBusinessUnitsMap.get(keyString);
                    }
                    
                    if((trigger.isInsert && OppObj.StageName == CLOSE_WON_STAGE) 
                        || (trigger.isUpdate && (OppObj.StageName == CLOSE_WON_STAGE  && oldOpp.StageName != CLOSE_WON_STAGE ))){
                            
                        totalNBTempCount += OppObj.Number_of_Units__c;
                    }else if(trigger.isUpdate && (OppObj.StageName != CLOSE_WON_STAGE  && oldOpp.StageName == CLOSE_WON_STAGE)){
                        totalNBTempCount -= OppObj.Number_of_Units__c;
                    }                   
                    assignedAENewBusinessUnitsMap.put(keyString,totalTempCount);
                } 
                
        }
        
        System.debug('*****assignedAETotalUnitsMap*****'+assignedAETotalUnitsMap);
        System.debug('*****assignedAENewBusinessUnitsMap*****'+assignedAENewBusinessUnitsMap);

        if(!assignAEIdSet.isEmpty()){
            /* Getting Managers and AE from the goal */ // Need to add user Region check
            for(Goal goal : [SELECT Id, OwnerID, Region__c, Sales_Rep_Type__c, Profile_Name__c, Reporting_Manager__c, Reporting_Manager__r.ManagerId,
                                    Reporting_Manager__r.Profile_Name_Text__c, Reporting_Manager__r.Manager.Profile_Name_Text__c, 
                                    (SELECT Id, CurrentValue, TargetValue, Name, OwnerId FROM Metrics) FROM Goal WHERE StartDate <= :System.Today() AND DueDate >= :System.Today() 
                                    AND RecordtypeId =: xfinityGoalRecordTypeId AND OwnerID IN : assignAEIdSet  AND Status =: PUBLISHED_GOAL_STATUS 
                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            
                System.debug('*****goal*****'+goal);
                
                String keyString = '';
                if(goal.OwnerID != null){
                    if(goal.Sales_Rep_Type__c != null && SMALL_BUSINESS_SALES_REP_TYPE.contains(goal.Sales_Rep_Type__c)){
                        keyString = String.valueOf(goal.OwnerID)+goal.Sales_Rep_Type__c;
                    }else if(goal.Region__c != null){                         
                        keyString = String.valueOf(goal.OwnerID)+goal.Region__c;         
                    } 
                }   
                            
                /*Updating Metric for Assigned AE User()*/
                if(keyString !=''){
                    if(!assignedAETotalUnitsMap.isEmpty() && assignedAETotalUnitsMap.get(keyString) != null){
                            
                        if(!SMALL_BUSINESS_SALES_REP_TYPE.contains(goal.Sales_Rep_Type__c) && goal.Profile_Name__c != XC_PORTFOLIO_AE){
                            userIdRegionMap.put(keyString, goal.Region__c);//For Regional Lead Goal
                        }
                        
                        if(goal.Profile_Name__c == XC_Manager){
                            System.debug('*****inside if*****');
                            //IF XC Mgr Close Won the Opportunity
                            Decimal totalUnitsTempCountReportingMgr = 0;
                            if(!reportingMgrTotalUnitsMap.isEmpty() && reportingMgrTotalUnitsMap.get(goal.OwnerID) != null){
                                totalUnitsTempCountReportingMgr = reportingMgrTotalUnitsMap.get(goal.OwnerID);
                            }
                            totalUnitsTempCountReportingMgr += assignedAETotalUnitsMap.get(keyString);
                            reportingMgrTotalUnitsMap.put(goal.OwnerID, totalUnitsTempCountReportingMgr);
                            
                            if(!assignedAENewBusinessUnitsMap.isEmpty() && assignedAENewBusinessUnitsMap.get(keyString) != null){
                                Decimal totalNBUnitsTempCountReportingMgr = 0;
                                if(!reportingMgrNewBusinessUnitsMap.isEmpty() && reportingMgrNewBusinessUnitsMap.get(goal.OwnerID) != null){
                                    totalNBUnitsTempCountReportingMgr = reportingMgrNewBusinessUnitsMap.get(goal.OwnerID);
                                }
                                totalNBUnitsTempCountReportingMgr += assignedAENewBusinessUnitsMap.get(keyString);
                                reportingMgrNewBusinessUnitsMap.put(goal.OwnerID, totalNBUnitsTempCountReportingMgr);
                            }
                            
                        }else{
                            System.debug('*****inside else*****');                                                  
                            /* Get Owner And Its Manager */ 
                            if(goal.Reporting_Manager__c != null && keyString !=''){
                                userIdManagerIdMap.put(keyString, goal.Reporting_Manager__c);
                                                    
                                /* Get Manager And his Manager */ 
                                if(goal.Profile_Name__c != 'XC Portfolio AE' && !SMALL_BUSINESS_SALES_REP_TYPE.contains(goal.Sales_Rep_Type__c) 
                                    && goal.Reporting_Manager__r.ManagerId != null){
                                    reportingMgrAndManagerIdMap.put(goal.Reporting_Manager__c, goal.Reporting_Manager__r.ManagerId);
                                }
                            }
                            
                            
                            for(Metric metricsTemp : goal.Metrics){ 
                                System.debug('*****metricsTemp*****'+metricsTemp);  
                                if(metricsTemp.Name == UNITS){//Add new Busineess logic for mgr
                                    if(metricsTemp.CurrentValue != null){
                                        metricsTemp.CurrentValue = metricsTemp.CurrentValue + assignedAETotalUnitsMap.get(keyString);
                                        
                                        if(metricsTemp.CurrentValue < 0){
                                            metricsTemp.CurrentValue=0;
                                        }                                                
                                        updateToMetricMap.put(metricsTemp.Id, updateMetricStatus(metricsTemp));
                                    }
                                }   
                            }
                        }
                            
                    }
                }
            }   
            
        }
        System.debug('updateToMetricMap*****'+updateToMetricMap);
        
        System.debug('userIdManagerIdMap*****'+userIdManagerIdMap);
        System.debug('reportingMgrAndManagerIdMap*****'+reportingMgrAndManagerIdMap);

        //Fetching all regional leads having work.com access        
        if(!userIdRegionMap.isEmpty()){
            for(User userObj : [SELECT Id, Name, Sales_Rep_Type__c, Region__c FROM User WHERE Region__c IN:userIdRegionMap.values() 
                                AND Sales_Rep_Type__c =: REGION_SALES_REP_TYPE AND UserPermissionsWorkDotComUserFeature = true AND isActive = True]){
                regionalLeadIdSet.add(userObj.Id);           
            }
        }
        System.debug('regionalLeadIdSet*****'+regionalLeadIdSet);

        if(!userIdManagerIdMap.isEmpty()){
            for(String keyString : userIdManagerIdMap.keyset()){
                
                //Total Units And NewBusiness Calculation Logic For Reporting Manager                       
                String reportingMgr = '';
                if(userIdManagerIdMap.get(keyString) != null || userIdManagerIdMap.get(keyString) != ''){
                    reportingMgr = userIdManagerIdMap.get(keyString);
                }
                
                if(reportingMgr != '' && !regionalLeadIdSet.contains(reportingMgr)){
                    /* Get Total Units for Reporting manager */
                    String reportingMgrMgr = '';
                    if(!reportingMgrAndManagerIdMap.isEmpty() && reportingMgrAndManagerIdMap.get(reportingMgr) != null || reportingMgrAndManagerIdMap.get(reportingMgr) != ''){
                        reportingMgrMgr = reportingMgrAndManagerIdMap.get(reportingMgr);
                    }
                    
                    Decimal totalUnitsTempCountReportingMgr = 0;
                    if(!reportingMgrTotalUnitsMap.isEmpty() && reportingMgrTotalUnitsMap.get(reportingMgr) != null){
                        totalUnitsTempCountReportingMgr = reportingMgrTotalUnitsMap.get(reportingMgr);
                    }
                    totalUnitsTempCountReportingMgr += assignedAETotalUnitsMap.get(keyString);
                    reportingMgrTotalUnitsMap.put(reportingMgr, totalUnitsTempCountReportingMgr);
                    
                    if(!assignedAENewBusinessUnitsMap.isEmpty() && assignedAENewBusinessUnitsMap.get(keyString) != null){                
                        /* Get New Business Units for Reporting manager */
                        Decimal totalNBUnitsTempCountReportingMgr = 0;
                        if(!reportingMgrNewBusinessUnitsMap.isEmpty() && reportingMgrNewBusinessUnitsMap.get(reportingMgr) != null){
                            totalNBUnitsTempCountReportingMgr = reportingMgrNewBusinessUnitsMap.get(reportingMgr);
                        }
                        totalNBUnitsTempCountReportingMgr += assignedAENewBusinessUnitsMap.get(keyString);
                        reportingMgrNewBusinessUnitsMap.put(reportingMgr, totalNBUnitsTempCountReportingMgr);
                    }
                    
                    System.debug('reportingMgrTotalUnitsMap*****'+reportingMgrTotalUnitsMap);
                    System.debug('reportingMgrNewBusinessUnitsMap*****'+reportingMgrNewBusinessUnitsMap);
                    
                    //Total Units And NewBusiness Calculation Logic For Reporting Manager's Manger                          
                    if(reportingMgrMgr != '' && !regionalLeadIdSet.contains(reportingMgrMgr)){
                        /* Get Total Units for Reporting manager's manager*/
                        Decimal totalUnitsTempCountReportingMgrMgr = 0;
                        if(!reportingMgrMgrTotalUnitsMap.isEmpty() && reportingMgrMgrTotalUnitsMap.get(reportingMgrMgr) != null){
                            totalUnitsTempCountReportingMgrMgr = reportingMgrMgrTotalUnitsMap.get(reportingMgrMgr);
                        }
                        totalUnitsTempCountReportingMgrMgr += assignedAETotalUnitsMap.get(keyString);
                        reportingMgrMgrTotalUnitsMap.put(reportingMgrMgr, totalUnitsTempCountReportingMgrMgr);
                        
                        if(!assignedAENewBusinessUnitsMap.isEmpty() && assignedAENewBusinessUnitsMap.get(keyString) != null ){   
                            /* Get New Business Units for Reporting manager's manager */
                            Decimal totalNBUnitsTempCountReportingMgrMgr = 0;
                            if(!reportingMgrMgrNewBusinessUnitsMap.isEmpty() && reportingMgrMgrNewBusinessUnitsMap.get(reportingMgrMgr) != null){
                                totalNBUnitsTempCountReportingMgrMgr = reportingMgrMgrNewBusinessUnitsMap.get(reportingMgrMgr);
                            }
                            totalNBUnitsTempCountReportingMgrMgr += assignedAENewBusinessUnitsMap.get(keyString);
                            reportingMgrMgrNewBusinessUnitsMap.put(reportingMgrMgr, totalNBUnitsTempCountReportingMgrMgr);
                        }
                        
                        System.debug('reportingMgrMgrTotalUnitsMap*****'+reportingMgrMgrTotalUnitsMap);
                        System.debug('reportingMgrMgrNewBusinessUnitsMap*****'+reportingMgrMgrNewBusinessUnitsMap);
                    }
                    
                }
                
            }
        }




        //Total Units And NewBusiness Calculation Logic For Regional Lead   
        if(!userIdRegionMap.isEmpty()){         
            for(String assignedAERegion : userIdRegionMap.keyset()){
                
                /* Get Total Units for Regional Lead */
                Decimal totalUnitsTempCountRegionalLead = 0;
                if(!regionalLeadTotalUnitsMap.isEmpty() && regionalLeadTotalUnitsMap.get(userIdRegionMap.get(assignedAERegion)) != null){
                    totalUnitsTempCountRegionalLead = regionalLeadTotalUnitsMap.get(userIdRegionMap.get(assignedAERegion));
                }
                totalUnitsTempCountRegionalLead += assignedAETotalUnitsMap.get(assignedAERegion);
                regionalLeadTotalUnitsMap.put(userIdRegionMap.get(assignedAERegion),totalUnitsTempCountRegionalLead);
                
                if(!assignedAENewBusinessUnitsMap.isEmpty() && assignedAENewBusinessUnitsMap.get(assignedAERegion) != null ){
                    /* Get New Business Units for Regional Lead */
                    Decimal totalNBUnitsTempCountRegionalLead = 0;
                    if(!regionalLeadNewBusinessUnitsMap.isEmpty() && regionalLeadNewBusinessUnitsMap.get(userIdRegionMap.get(assignedAERegion)) != null){
                        totalNBUnitsTempCountRegionalLead = regionalLeadNewBusinessUnitsMap.get(userIdRegionMap.get(assignedAERegion));
                    }
                    totalNBUnitsTempCountRegionalLead += assignedAENewBusinessUnitsMap.get(assignedAERegion);
                    regionalLeadNewBusinessUnitsMap.put(userIdRegionMap.get(assignedAERegion),totalNBUnitsTempCountRegionalLead);
                }
            }
                    
        }
        System.debug('regionalLeadTotalUnitsMap*****'+regionalLeadTotalUnitsMap);
        System.debug('regionalLeadNewBusinessUnitsMap*****'+regionalLeadNewBusinessUnitsMap);

        if(!reportingMgrTotalUnitsMap.isEmpty() || regionalLeadIdSet.isEmpty() || !reportingMgrMgrTotalUnitsMap.isEmpty()){
            /* Getting Managers and Regional from the goal */ // Need to add user Region check
            for(Goal goal : [SELECT Id, OwnerID, Region__c, Sales_Rep_Type__c, Profile_Name__c, ( SELECT Id, CurrentValue, TargetValue, Name, OwnerId FROM Metrics) 
                                        FROM Goal WHERE StartDate <= :System.Today()  AND DueDate >= :System.Today() 
                                        AND RecordtypeId =: Xfinity_Communities_RecordtypeId 
                                        AND (OwnerID IN : reportingMgrTotalUnitsMap.keySet() OR OwnerID IN : regionalLeadIdSet OR OwnerID IN : reportingMgrMgrTotalUnitsMap.keySet()) 
                                        AND Status =: PUBLISHED_GOAL_STATUS LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                                                        
                if(regionalLeadIdSet.contains(goal.OwnerID) && goal.Sales_Rep_Type__c == REGION_SALES_REP_TYPE){
                    System.debug('inside if for Regional Lead*****');
                    for(Metric metricsTemp : goal.Metrics){ 
                        //Updating Total Units Metric for Regional Lead
                        if(metricsTemp.Name ==  TOTALUNITS ){
                            if(metricsTemp.CurrentValue != null){
                                metricsTemp.CurrentValue = metricsTemp.CurrentValue + regionalLeadTotalUnitsMap.get(goal.Region__c);                        
                            }
                        }
                        
                        if(!regionalLeadNewBusinessUnitsMap.isEmpty() && regionalLeadNewBusinessUnitsMap.get(goal.Region__c) != null){
                            //Updating New Business Metric for Regional Lead
                            if(metricsTemp.Name== New_Business ){
                                if(metricsTemp.CurrentValue != null){
                                    metricsTemp.CurrentValue = metricsTemp.CurrentValue + regionalLeadNewBusinessUnitsMap.get(goal.Region__c);
                                }
                            }
                        }   
                        
                        if(metricsTemp.CurrentValue < 0){
                            metricsTemp.CurrentValue = 0;
                        }                                                
                        updateToMetricMap.put(metricsTemp.Id, updateMetricStatus(metricsTemp));
                    }
                }
                
                if(!reportingMgrTotalUnitsMap.isEmpty() && reportingMgrTotalUnitsMap.get(goal.OwnerID) != null){
                    System.debug('inside else if for Reporting Mgr*****');
                    for(Metric metricsTemp : goal.Metrics){
                        //Updating Total Units Metric for Reporting Manager
                        if(metricsTemp.Name ==  TOTALUNITS ){
                            if(metricsTemp.CurrentValue != null){
                                metricsTemp.CurrentValue = metricsTemp.CurrentValue + reportingMgrTotalUnitsMap.get(goal.OwnerID);
                            }
                        }
                        
                        if(!reportingMgrNewBusinessUnitsMap.isEmpty() && reportingMgrNewBusinessUnitsMap.get(goal.OwnerID) != null){
                            //Updating New Business Metric for Reporting Manager
                            if(metricsTemp.Name== New_Business ){
                                if(metricsTemp.CurrentValue != null){
                                    metricsTemp.CurrentValue = metricsTemp.CurrentValue + reportingMgrNewBusinessUnitsMap.get(goal.OwnerID);
                                }
                            }
                        }
                        
                        if(metricsTemp.CurrentValue < 0){
                            metricsTemp.CurrentValue = 0;
                        }                                                
                        updateToMetricMap.put(metricsTemp.Id, updateMetricStatus(metricsTemp));
                    }
                }
                
                if(!reportingMgrMgrTotalUnitsMap.isEmpty() && reportingMgrMgrTotalUnitsMap.get(goal.OwnerID) != null){
                    System.debug('inside else if for Reporting Mgr Mgr*****');
                    for(Metric metricsTemp : goal.Metrics){
                        //Updating Total Units Metric for Reporting Manager's Manager
                        if(metricsTemp.Name ==  TOTALUNITS ){
                            if(metricsTemp.CurrentValue != null){
                                metricsTemp.CurrentValue = metricsTemp.CurrentValue + reportingMgrMgrTotalUnitsMap.get(goal.OwnerID);
                            }
                        }
                        
                        if(!reportingMgrMgrNewBusinessUnitsMap.isEmpty() && reportingMgrMgrNewBusinessUnitsMap.get(goal.OwnerID) != null){
                            //Updating New Business Metric for Reporting Manager's Manager
                            if(metricsTemp.Name== New_Business ){
                                if(metricsTemp.CurrentValue != null){
                                    metricsTemp.CurrentValue = metricsTemp.CurrentValue + reportingMgrMgrNewBusinessUnitsMap.get(goal.OwnerID);                     
                                }
                            }
                        
                        }
                        
                        if(metricsTemp.CurrentValue < 0){
                            metricsTemp.CurrentValue = 0;
                        }                                                
                        updateToMetricMap.put(metricsTemp.Id, updateMetricStatus(metricsTemp));
                    }
                }                           
            }
        }   
        
        
        System.debug('******newoppList*****'+oppList);
    
        System.debug('updateToMetricMap*****'+updateToMetricMap.values());
        //Updating the metric records
        Database.saveResult[] result;
        if(!updateToMetricMap.isEmpty()){
            result = database.update(updateToMetricMap.values(),false);
        }
        for (Database.SaveResult sr : result) {
            if (sr.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed
            System.debug('Successfully inserted metric. Metric ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Metric fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    /*
    Name : updateIncrementalFieldValidation
    Description : This method update Incremental Subs Added field based 
    on IPTV field on opportunity and organisation type field on property 
    Parameters : opplist and oldOppMap
    Return : void
    Author : Shalaka Kadwade
    User Story : US689317 (SalesSpace Communties: New field on Opportunity)
    */
    public static void updateIncrementalFieldValidation(List<Opportunity> opplist,Map<Id, Opportunity> oldOppMap) {
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> oppIdPropIdSet = new Set<Id>();
        List<Opportunity_Property__c> opptyPropPropertyList = new List<Opportunity_Property__c>();
        try{
            for(Opportunity opp : opplist){
                if(xfinityOpportunityRecordTypeId.equalsIgnoreCase(String.valueOf(opp.RecordtypeId))){
                    Opportunity oldOpp = oldOppMap.get(opp.Id);
                      if(opp.Incremental_Subs_Added__c!=oldOpp.Incremental_Subs_Added__c){
                        if(opp.IPTV__c!= oldOpp.IPTV__c){
                            if(!opp.IPTV__c){
                                opp.addError(Label.IncrementalSubsAddedValidationMsg);
                            }
                        }
                        else{
                            oppIdSet.add(opp.Id);
                        }
                    }
                }   
            }    
        
            if(oppIdSet.size()>0){         
            opptyPropPropertyList = new List<Opportunity_Property__c>();
                opptyPropPropertyList = [SELECT Id,Opportunity__c,Opportunity__r.IPTV__c,Property__c,Property__r.Industry_Type__c 
                                        FROM Opportunity_Property__c WHERE Opportunity__c IN : oppIdSet AND Primary_Property__c = true];
            }
            if(opptyPropPropertyList.size()>0){
                for(Opportunity_Property__c oppProp: opptyPropPropertyList){
                    if(!oppProp.Opportunity__r.IPTV__c || (!INDUSTRY_TYPE_EDUCATION.equalsIgnoreCase(oppProp.Property__r.Industry_Type__c))){
                        oppIdPropIdSet.add(oppProp.Opportunity__c);   
                    }
                }
            }
            for(Opportunity op: opplist){
                if(oppIdPropIdSet.contains(op.Id)){
                    op.addError(Label.IncrementalSubsAddedValidationMsg);
                }
            }
        }catch(Exception ex){
            system.debug('****Following error occurred****'+ex.getMessage());
        }   
    }
    
     /*
    Author : Shivani Gautam
    Return : void
    Sprint : 34
    User Story : US745492-SalesSpace Communities: Opportunity Edit access for 'AE Contractor' Managers
     
    Description: Methods for sharing opportunity to reporting manager(Contractor_Region_Mapping) when opportunity assigned to Contractor AE
    */
    public static void oppContractorSharingMgrGrp(List<Opportunity> newOppList)
    {
        List<OpportunityShare> oppShareList = new List<OpportunityShare>();
        Set<String> assignedAESet = new Set<String>();
        Set<String> contractorAESet = new Set<String>();
        Map<String,Set<String>> contractorManagerMap = new Map<String,Set<String>>();
        
        
        for(Opportunity opp : newOppList){
            assignedAESet.add(opp.AssignedAE_ID__c);
        }
        
        for(User userObj : [SELECT Id,ProfileId,Profile.Name FROM User WHERE Id IN :assignedAESet 
                            AND Profile.Name =: Label.XC_AE_Contractors]){
            contractorAESet.add(userObj.Id);
        }
        
        
        if(!contractorAESet.isEmpty()){                      
            for(Contractor_Region_Mapping__c contRegionMappingObj: [SELECT AE_Contractor__c,Reporting_Manager__c 
                                                                    FROM Contractor_Region_Mapping__c 
                                                                    WHERE AE_Contractor__c IN :contractorAESet]){
                Set<String> tempMgrSet = new Set<String>();             
                if(contractorManagerMap.containsKey(contRegionMappingObj.AE_Contractor__c)){
                    tempMgrSet = contractorManagerMap.get(contRegionMappingObj.AE_Contractor__c);
                }
                tempMgrSet.add(contRegionMappingObj.Reporting_Manager__c);
                contractorManagerMap.put(contRegionMappingObj.AE_Contractor__c,tempMgrSet); 
            }
        }
            
            
        // Below loop is for manager sharing access
        If(!contractorManagerMap.isEmpty()){ 
            for(Opportunity oppTemp : newOppList){
                if(contractorManagerMap.containsKey(oppTemp.AssignedAE_ID__c)){
                    Set<String> mgrString = contractorManagerMap.get(oppTemp.AssignedAE_ID__c);                 
                    for(String mgrId : mgrString){
                        OpportunityShare oppShareRecord = new OpportunityShare();
                        oppShareRecord.OpportunityId = oppTemp.Id;
                        oppShareRecord.userorgroupId = mgrId; 
                        oppShareRecord.OpportunityAccessLevel = system.label.OpportunityEditAccess;                
                        oppShareRecord.rowCause = Schema.OpportunityShare.rowCause.Manual;
                        oppShareList.add(oppShareRecord);
                    }   
                }
            }           
        }
        
        
        
        if(!oppShareList.isEmpty()){
            Database.insert(oppShareList,false);
        }
    }
    
    
    /*
    Author : Shivani Gautam
    Return : void
    Sprint : 34
    User Story : US745492-SalesSpace Communities: Opportunity Edit access for 'AE Contractor' Managers
    Updated By : Malay Desai 28/10/16
    Description:  Method for recalculate the opportunity sharing when assigned AE (Only for Contractor AE) changes
    */
    public static void recalculateOpportunityShares(Map<Id,Opportunity> oldOppMap,List<Opportunity> newOppList){
       
        List<String> oppIdList = new List<String>();
        List<Opportunity> oppList = new List<Opportunity>();
        Set<String> assignedAESet = new Set<String>();
        Set<String> contractorAESet = new Set<String>();
        Set<String> contractorAEMgrSet = new Set<String>();
     
        //OneTimeUpdateOppForCont__c updateOpp = OneTimeUpdateOppForCont__c.getValues('Opportunity Update');
       //Remove opportunity share records for the old assigned AE(only For Contractor) from OpportunityShare   

        for(Opportunity opp : newOppList){
            if(opp.AssignedAE_ID__c != oldOppMap.get(opp.Id).AssignedAE_ID__c){
                assignedAESet.add(opp.AssignedAE_ID__c);
            }
        }
        
        if(!assignedAESet.isEmpty()){
            for(User userObj : [SELECT Id,ProfileId,Profile.Name FROM User WHERE Id IN :assignedAESet and Profile.Name =: Label.XC_AE_Contractors]){
                contractorAESet.add(userObj.Id);
            }
            
            if(!contractorAESet.isEmpty()){ 
                for(Opportunity oppObj: newOppList){           
                    if(contractorAESet.contains(oppObj.AssignedAE_ID__c)){ 
                        oppIdList.add(oppObj.Id);
                        oppList.add(oppObj);
                    }   
                }   
                
                if(!oppIdList.isEmpty()){
                                         
                    for(Contractor_Region_Mapping__c contRegionMappingObj: [SELECT AE_Contractor__c,Reporting_Manager__c FROM Contractor_Region_Mapping__c 
                                                                            WHERE AE_Contractor__c IN :contractorAESet]){
                       contractorAEMgrSet.add(contRegionMappingObj.Reporting_Manager__c);
                    }
                
                    List<OpportunityShare> deleteAllOppShare = [SELECT Id,OpportunityId,RowCause,UserOrGroupId FROM OpportunityShare 
                                                            WHERE OpportunityId IN : oppIdList AND UserOrGroupId IN : contractorAEMgrSet 
                                                            AND RowCause =:'manual' AND OpportunityAccessLevel =: system.label.OpportunityEditAccess ];
                
                    //Delete old sharing
                    if(!deleteAllOppShare.isEmpty()){
                       Database.deleteResult[] drList = database.delete(deleteAllOppShare,false);
                       // create new sharing
                       if(!drList.isEmpty())
                            oppContractorSharingMgrGrp(oppList);
                    } 
                    
                }
            }
        }
    }

    /***********  
     * Author : Amit Kumar Pradhan
     * Return : Metric
     * Description:  This method use to set Metric status 
     * Date : 06 Jan 2017 (Hot fix for Quota Management)
    ************/
    public static Metric updateMetricStatus(Metric metricObj){
        Decimal progessPercVal = 0;                
        if(metricObj.targetvalue >0 && metricObj.currentvalue!=null){
            Integer roundCurrentVal = Math.round(metricObj.currentValue);
            progessPercVal = roundCurrentVal*100/metricObj.targetvalue;
        }
               
        if(progessPercVal>=100){                   
            metricObj.Status = ONTRACK_STATUS;
        }else if(75<=progessPercVal && progessPercVal<100){
            metricObj.Status = BEHIND_STATUS;
        }else if(progessPercVal<75){
            metricObj.Status = CRITICAL_STATUS;
        }       
        return metricObj;
    }
    
    /*
     *  Name : validateOpportunityOnClosedWon
     *  Description : Validate opportunity on Closed Won for Assigned AE and AE contractors and associate with Goal
     *  Parameters : None
     *  Return : void
     *  Author : Suchita Sharma
     *  User Story : US527614 (Goal association to Opportunity and Quota update)    
     *  Description : 1. Error message for contractor while working with diff Region and "" is not Created on Contractor Region Mapping
                      2. Error message when quota records is not "published" while closing opportunity
                      3. Relationship between Opportunity and Goal should exist when stage of  is 'Closed Won'.
     */
public static void validateOpportunityOnClosedWon(List<Opportunity> oppList, Map<Id,Opportunity> oldMap){
    system.debug('####In side validateOpportunityOnClosedWon method####');
    
    List<Opportunity> xfinityOppList = new List<Opportunity>();
    Set<String> assignAEIdSet = new Set<String>();
    Set<String> setContractAEUserId;
    Map<String, Goal> assignedAERegionVsGoal;
    Map<String,Contractor_Region_Mapping__c> contratorAERegionVsConractorRegionalMappingMap;
    Map<String, String> oppIdUserIdVsRegionMap;
    Map<String,String> aeManagerRegionVsGoalStatus;
    Set<String> reportingMgrSet = new Set<String>();
    Map<String, User> userIdAndUserMap;
    Map<String, User> namNedDivisionUserMap;
    Map<String, String> reportingMgrVsRegionMap;
    Map<String, String> aeVsReportingMgrMap;
    
    for(Opportunity oppTemp : oppList){
        Opportunity oldOpp = new Opportunity();
        if(oppTemp.RecordTypeid == xfinityOpportunityRecordTypeId){
            if(trigger.isUpdate){
                oldOpp = (Opportunity)oldMap.get(oppTemp.Id);
            }
            /* For New Build, Winback and Renewal type of opportunity,check for the stage name from other stage to closed won and vice versa, only for the update and insert operation */
            if((oppTemp.Type == New_Build || oppTemp.Type == Win_Back || oppTemp.Type == Renewal)){
                if((    trigger.isInsert && oppTemp.StageName == CLOSE_WON_STAGE && oppTemp.AssignedAE_ID__c != null)
                    || (trigger.isUpdate && oppTemp.AssignedAE_ID__c != null && ((oppTemp.StageName == CLOSE_WON_STAGE  && oldOpp.StageName != CLOSE_WON_STAGE ) 
                    || (oppTemp.StageName != CLOSE_WON_STAGE  && oldOpp.StageName == CLOSE_WON_STAGE)))){           
                        xfinityOppList.add(oppTemp);                
                        assignAEIdSet.add(oppTemp.AssignedAE_ID__c);                            
                }           
            }                   
        }
    }
    
    system.debug('####xfinityOppList####'+xfinityOppList);
    system.debug('####assignAEIdSet####'+assignAEIdSet);
    /* For contractor create a set of Ids. For non contractors create a map of Id vs User*/
    if(!assignAEIdSet.isEmpty()){   
        setContractAEUserId = new Set<String>();
        userIdAndUserMap = new Map<String, User>();
        namNedDivisionUserMap = new Map<String, User>();
        
        for(User userObject : [SELECT Id, Profile_Name_Text__c,  Region__c, Sales_Rep_Type__c FROM User 
                                          WHERE UserPermissionsWorkDotComUserFeature = true AND Id IN : assignAEIdSet]){
                        
            if(userObject.Profile_Name_Text__c == XC_AE_CONTRACTOR){
                setContractAEUserId.add(userObject.Id);                                     
            }else{ 
                if(userObject.Sales_Rep_Type__c != null && SMALL_BUSINESS_SALES_REP_TYPE.contains(userObject.Sales_Rep_Type__c)){
                    namNedDivisionUserMap.put(userObject.Id,userObject);
                }else if(userObject.Profile_Name_Text__c == XC_ACCOUNT_EXECUTIVE 
                        || userObject.Profile_Name_Text__c ==  XC_PORTFOLIO_AE 
                        || userObject.Profile_Name_Text__c ==  XC_MANAGER){
                    userIdAndUserMap.put(userObject.Id,userObject);
                }
            }                
        }
    }  
     system.debug('####namNedDivisionUserMap####'+namNedDivisionUserMap);
    system.debug('####userIdAndUserMap####'+userIdAndUserMap);
    system.debug('####setContractAEUserId####'+setContractAEUserId);
    
    /* For Contractors */ 
    if(!setContractAEUserId.isEmpty()){  
        oppIdUserIdVsRegionMap  = new Map<String, String>();
        contratorAERegionVsConractorRegionalMappingMap = new Map<String,Contractor_Region_Mapping__c>();
        /*Create a map of OppId+UserId vs Primary Property Region */
        for(Opportunity_Property__c oppProperty : [SELECT Id, Property_Type__c, Property_Region__c, Opportunity__c,
                              Opportunity__r.AssignedAE_ID__c FROM Opportunity_Property__c 
                              WHERE Primary_Property__c = true 
                              AND Opportunity__r.AssignedAE_ID__c IN : setContractAEUserId 
                              AND Opportunity__c IN : xfinityOppList]){ 
        
            if(oppProperty.Opportunity__c != null && oppProperty.Opportunity__r.AssignedAE_ID__c != null){
                    oppIdUserIdVsRegionMap.put(oppProperty.Opportunity__c+''+oppProperty.Opportunity__r.AssignedAE_ID__c, oppProperty.Property_Region__c );
            }               
        }           
    
        /*Create a map of UserId+Region vs CRM record from CRM object */          
        for(Contractor_Region_Mapping__c crm :[ SELECT Id, AE_Contractor__c, Region__c, Reporting_Manager__c 
                                                             FROM Contractor_Region_Mapping__c 
                                                             WHERE AE_Contractor__c IN :setContractAEUserId  
                                                             LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){              
            contratorAERegionVsConractorRegionalMappingMap.put(crm.AE_Contractor__c + crm.Region__c, crm);
        }
    }
        
    system.debug('####oppIdUserIdVsRegionMap####'+oppIdUserIdVsRegionMap);
    system.debug('####contratorAERegionVsConractorRegionalMappingMap####'+contratorAERegionVsConractorRegionalMappingMap);
    
    /* Getting Managers and AE from the goal and goal is published */
    if(!assignAEIdSet.isEmpty()){
        String userRegion;
        assignedAERegionVsGoal = new Map<String, Goal>();
        reportingMgrVsRegionMap = new Map<String, String>();
        aeVsReportingMgrMap = new Map<String, String>();
        
        for(Goal goal :[SELECT Id, OwnerID, Sales_Rep_Type__c, Region__c, Profile_Name__c, 
                        Reporting_Manager__c, Reporting_Manager__r.Region__c, Status  
                        FROM Goal WHERE StartDate <= :System.Today()  AND DueDate >= :System.Today() 
                        AND RecordtypeId =: xfinityGoalRecordTypeId AND OwnerID IN :assignAEIdSet 
                        ORDER BY CreatedDate LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            //Fetching Reporting mgr for AE,Portfolio AE,Managers
            if(goal.Status!= null){
                if(goal.Reporting_Manager__c != null && (goal.Profile_Name__c == XC_ACCOUNT_EXECUTIVE ||
                    goal.Profile_Name__c == XC_PORTFOLIO_AE ||
                    goal.Profile_Name__c == XC_AE_CONTRACTOR)){                      
                        reportingMgrSet.add(goal.Reporting_Manager__c);
                        if(goal.Reporting_Manager__r.Region__c != null){
                            reportingMgrVsRegionMap.put(goal.Reporting_Manager__c,goal.Reporting_Manager__r.Region__c);
                        }
                        
                }
                
                
                
                if(goal.Sales_Rep_Type__c != null && SMALL_BUSINESS_SALES_REP_TYPE.contains(goal.Sales_Rep_Type__c)){
                        assignedAERegionVsGoal.put(goal.OwnerID + goal.Sales_Rep_Type__c, goal);
                        aeVsReportingMgrMap.put(goal.OwnerId,goal.Reporting_Manager__c);                        
                }else{
                    if(goal.Profile_Name__c == XC_ACCOUNT_EXECUTIVE ||
                        goal.Profile_Name__c == XC_PORTFOLIO_AE ||
                        goal.Profile_Name__c == XC_MANAGER ){
                            
                        userRegion = userIdAndUserMap.get(goal.OwnerID).Region__c;
                        if(goal.Profile_Name__c != XC_MANAGER){
                            aeVsReportingMgrMap.put(goal.OwnerId,goal.Reporting_Manager__c);
                        }
                        
                    }else{
                        if(goal.Profile_Name__c == XC_AE_CONTRACTOR){
                            userRegion = goal.Region__c;
                        }
                    }
                    
                    
                    if(userRegion != null){
                        assignedAERegionVsGoal.put(goal.OwnerID + userRegion, goal);
                    }   
                }
            }
        }       
    } 
    system.debug('####aeVsReportingMgrMap####'+aeVsReportingMgrMap);
    system.debug('####reportingMgrSet####'+reportingMgrSet);
    system.debug('####assignedAERegionVsGoal####'+assignedAERegionVsGoal);
    
    
    /* Create a map of Manager's goal vs Goal status*/
    if(!reportingMgrSet.isEmpty()){
        aeManagerRegionVsGoalStatus  = new Map<String,String>();
        for(Goal goal :[SELECT Id, OwnerID, Region__c,Status
                        FROM Goal WHERE StartDate <= :System.Today()  AND DueDate >= :System.Today() 
                        AND RecordtypeId =: xfinityGoalRecordTypeId  AND OwnerID IN :reportingMgrSet ORDER BY CreatedDate 
                        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){           
                if(goal.Status != null){
                    if(!reportingMgrVsRegionMap.isEmpty() && reportingMgrVsRegionMap.get(goal.OwnerID) != null){
                        aeManagerRegionVsGoalStatus.put(goal.OwnerID+reportingMgrVsRegionMap.get(goal.OwnerID), goal.Status);
                    }                                   
                }
                                                        
        }
    }
     
    system.debug('####aeManagerRegionVsGoalStatus####'+aeManagerRegionVsGoalStatus);
    
    if(!xfinityOppList.isEmpty()){
        final String MDU_OPPORTUNITY_TRIGGER_VALIDATIONS = 'Opportunity CLOSED WON Validations'; 
        final String OPPORTUNITY_QUOTA_ASSOCIATION_ERROR = 'Error occurred while linking Quota record with Opportunity ID : ';
        final String COLON_NL = ' :\n ' ;        
        String aeRegionOrSalesRepType,mgrRegion,goalStatusAE,mgrGoalStatusAE,goalStatusAEContractor,mgrGoalStatusAEContractor,primaryPropertyRegion,reportingMgr;
        Contractor_Region_Mapping__c crm;
        Opportunity oldOpp;
        Boolean isEligibleForAppLog = MDU_EmptorisUtility.setEligibilityForApplicationLogging(); 
        String executionLog = '',requestName = '',initialLog; 
        DateTime startTime = System.Now(); 
        executionLog = Mdu_ApplicationLogger.logStart(MDU_OPPORTUNITY_TRIGGER_VALIDATIONS, executionLog, isEligibleForAppLog);
        initialLog = executionLog;
            
        for(Opportunity opp : xfinityOppList){
            oldOpp = (Opportunity)oldMap.get(opp.Id);
            
            goalStatusAE = null;
            goalStatusAEContractor = null;
            mgrGoalStatusAE = null;
            mgrGoalStatusAEContractor = null;
            reportingMgr = null;
            mgrRegion = null;
            
            /*Logic for contractor opportunity when opportunity is closed won*/
            if(setContractAEUserId.contains(opp.AssignedAE_ID__c)){
                system.debug('####For Contractor Region add error####');
                
                primaryPropertyRegion = oppIdUserIdVsRegionMap.get(opp.Id+''+ opp.AssignedAE_ID__c);
                if(contratorAERegionVsConractorRegionalMappingMap.get(opp.AssignedAE_ID__c + primaryPropertyRegion) == null 
                    && opp.StageName == CLOSE_WON_STAGE){
                        if(!System.isBatch()){
                            opp.addError(Label.RegionAssignForContractorAE); //Error message when quota records for AE or his Manager is not "published" while closing opportunity
                        } else{
                        if(isEligibleForAppLog){
                            requestName = OPPORTUNITY_QUOTA_ASSOCIATION_ERROR + opp.Id + COLON_NL;
                            executionLog = Mdu_ApplicationLogger.logMessage(requestName + Label.RegionAssignForContractorAE ,executionLog, isEligibleForAppLog );
                        }
                        opp.StageName = ((Opportunity)oldMap.get(opp.Id)).Stagename; 
                    }
                }else{
                                        
                    crm = contratorAERegionVsConractorRegionalMappingMap.get(opp.AssignedAE_ID__c  + primaryPropertyRegion); 
                    if(!assignedAERegionVsGoal.isEmpty() && assignedAERegionVsGoal.get(opp.AssignedAE_ID__c + crm.region__c) != null ){
                        goalStatusAEContractor = assignedAERegionVsGoal.get(opp.AssignedAE_ID__c + crm.region__c).Status;
                        
                        if(!aeManagerRegionVsGoalStatus.isEmpty() && aeManagerRegionVsGoalStatus.get(assignedAERegionVsGoal.get(opp.AssignedAE_ID__c+crm.region__c).Reporting_Manager__c + crm.region__c) != null){
                            mgrGoalStatusAEContractor = aeManagerRegionVsGoalStatus.get(assignedAERegionVsGoal.get(opp.AssignedAE_ID__c+crm.region__c).Reporting_Manager__c + crm.region__c);
                        }   
                    }
                    
                    
                }           
            }else{
                system.debug('#### else ####');
                
                if(!aeVsReportingMgrMap.isEmpty() && aeVsReportingMgrMap.get(opp.AssignedAE_ID__c) != null){
                    reportingMgr = aeVsReportingMgrMap.get(opp.AssignedAE_ID__c);
                }
                
                if(!userIdAndUserMap.isEmpty() && userIdAndUserMap.get(opp.AssignedAE_ID__c) != null){
                                        
                    aeRegionOrSalesRepType = userIdAndUserMap.get(opp.AssignedAE_ID__c).Region__c;
                                                            
                }else if(!namNedDivisionUserMap.isEmpty() && namNedDivisionUserMap.get(opp.AssignedAE_ID__c) != null){                  

                    aeRegionOrSalesRepType = namNedDivisionUserMap.get(opp.AssignedAE_ID__c).Sales_Rep_Type__c;
                    
                }
                system.debug('#### else ####'+aeRegionOrSalesRepType);
                
                if(!assignedAERegionVsGoal.isEmpty() && assignedAERegionVsGoal.get(opp.AssignedAE_ID__c+aeRegionOrSalesRepType) != null ){
                    goalStatusAE = assignedAERegionVsGoal.get(opp.AssignedAE_ID__c+aeRegionOrSalesRepType).Status;
                
                    if(!reportingMgrSet.isEmpty() && reportingMgrSet.contains(assignedAERegionVsGoal.get(opp.AssignedAE_ID__c+aeRegionOrSalesRepType).Reporting_Manager__c)){
                        if(reportingMgr != null && !reportingMgrVsRegionMap.isEmpty() && reportingMgrVsRegionMap.get(reportingMgr) != null){
                            mgrRegion = reportingMgrVsRegionMap.get(reportingMgr);
                        }
                        
                        if(mgrRegion != null && !aeManagerRegionVsGoalStatus.isEmpty()){
                            mgrGoalStatusAE = aeManagerRegionVsGoalStatus.get(assignedAERegionVsGoal.get(opp.AssignedAE_ID__c+aeRegionOrSalesRepType).Reporting_Manager__c + mgrRegion);
                        }
                    }
                }   
            } 
            system.debug('#### goalStatusAE ####'+goalStatusAE);
            system.debug('#### mgrRegion ####'+mgrRegion);
            /*Link the correct Goal to opportunity when opportunity is closed won  for Non-Contractors or throw error*/
            
            
            if(goalStatusAE != null) {
                if(opp.StageName == CLOSE_WON_STAGE && (goalStatusAE != PUBLISHED_GOAL_STATUS || (mgrGoalStatusAE != null && mgrGoalStatusAE != PUBLISHED_GOAL_STATUS))){
                    system.debug('#### add error for AE ####');
                    if(!System.isBatch()){
                        opp.addError(Label.ErrMsgForClosedWonNotPublished); //Error message when quota records for AE or his Manager is not "published" while closing opportunity
                    } else{
                        if(isEligibleForAppLog){
                            requestName = OPPORTUNITY_QUOTA_ASSOCIATION_ERROR + opp.Id + COLON_NL;
                            executionLog = Mdu_ApplicationLogger.logMessage(requestName + Label.ErrMsgForClosedWonNotPublished, executionLog, isEligibleForAppLog );
                        }
                    }
                    opp.StageName = ((Opportunity)oldMap.get(opp.Id)).Stagename;            
                } else{
                    system.debug('#### inside else for AE ####');
                    if(opp.StageName == CLOSE_WON_STAGE){
                        opp.Goal__c = assignedAERegionVsGoal.get(opp.AssignedAE_ID__c + aeRegionOrSalesRepType).Id;
                    }else{
                        if(opp.StageName != CLOSE_WON_STAGE  && oldOpp.StageName == CLOSE_WON_STAGE){
                            opp.Goal__c = null;  
                        }
                    }
                    system.debug('#### opp.Goal__c ####'+opp.Goal__c);
                }
            }
                
            /*Link the correct Goal to opportunity when opportunity is closed won  for Contractors or throw error*/
            if(goalStatusAEContractor != null) {
                if(opp.StageName == CLOSE_WON_STAGE && 
                            (goalStatusAEContractor != PUBLISHED_GOAL_STATUS || (mgrGoalStatusAEContractor  != null && mgrGoalStatusAEContractor != PUBLISHED_GOAL_STATUS))){
                    if(!System.isBatch()){
                        opp.addError(Label.ErrMsgForClosedWonNotPublished); //Error message when quota records for AE or his Manager is not "published" while closing opportunity
                    } else{
                        if(isEligibleForAppLog){
                            requestName = OPPORTUNITY_QUOTA_ASSOCIATION_ERROR + opp.Id + COLON_NL;
                            executionLog = Mdu_ApplicationLogger.logMessage(requestName + Label.ErrMsgForClosedWonNotPublished, executionLog, isEligibleForAppLog );
                        }
                    }
                    opp.StageName = ((Opportunity)oldMap.get(opp.Id)).Stagename;                      
                } else{
                    if(opp.StageName == CLOSE_WON_STAGE ){
                        opp.Goal__c = assignedAERegionVsGoal.get(opp.AssignedAE_ID__c + crm.Region__c).Id;
                    }else{
                        if(opp.StageName != CLOSE_WON_STAGE  && oldOpp.StageName == CLOSE_WON_STAGE){
                            opp.Goal__c = null;  
                        }
                    }
                    system.debug('####For Cont opp.Goal__c ####'+opp.Goal__c);
                }
            }
                        
        }
        
        if(executionLog != null && executionLog != initialLog){
            Mdu_ApplicationLogger.createLog(executionLog,isEligibleForAppLog,startTime,System.Now());
        }
    }
}
}