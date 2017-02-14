/**
* Class Name: PropertyTriggerOperations
* Author: Ashish G. Sonawane, Accenture
* Date: 19-December-2014 
* Requirement # Request Id(user story id): 009/042
* Description: Contains action to update data,voice,audio units in contract base on units in address 
*/
/*
* Name: PropertyTriggerOperations
* Description: Operations class for Property Trigger events.
*/
Public class PropertyTriggerOperations{    
    
    private static final String WON_OPPORTUNITY = 'Closed Won';
    private static final String LOST_OPPORTUNITY = 'Closed Lost';
    private static final String LABEL_NAME_SPLIT = ';';
    private static final String OBJECT_TYPE = 'MDU_Property__c';
    private static final String PROFILE_COMPLITION_PERC = '%Profile completion%%';
    private static final String GOAL_STATUS = 'Published';
    private static final String PROPERTY_LAB_GOAL_TEMPLATE = 'Property Lab CAR';
    private static final String XFINITY_CAR = 'Xfinity CAR';
    private static List<Region_Mapping__c> regionList = Region_Mapping__c.getAll().values();
    
   
    /**
    * @Description: This method performs task to update status.
    * @Author: Ashish G. Sonawane, Accenture
    * @Date: 19-December-2014 
    * @Param: none   
    * @Return: void.
    */   
    public static void changeContractUnitOnAddressUpdate() { 
        String labelName = System.Label.XfinityPropertyRecordType;  
        Set<String> recordTypeSet = new Set<String>();
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(LABEL_NAME_SPLIT)){
                recordTypeSet.add(Schema.SObjectType.MDU_Property__c.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }        

        List<MDU_Property__c> listOfNewAddress = (List<MDU_Property__c>)Trigger.New;             
        Set<Id> addressIdSet = new Set<Id>();
        Map<id,MDU_Property__c> mapOfOldAddress =  (Map<id,MDU_Property__c>)Trigger.OldMap;
        Map<Id,MDU_Property__c> mapOfNewAddressWithID = new Map<Id,MDU_Property__c>();
        for(MDU_Property__c address : listOfNewAddress){
            //Check whether Number Of Units Change , add to set and map if unit changed                
            if(recordTypeSet.contains(address.RecordTypeId)){ // Filter record only for MDU Record Type that contain in recordTypeSet              
                if(address.Number_of_Units__c != mapOfOldAddress.get(address.ID).Number_of_Units__c) {                
                    mapOfNewAddressWithID.put(address.ID,address);
                    addressIdSet.add(address.ID);
                }                
            }  
        } 
        //List<Contract__c> listOfContract =  [select Id,Property__c ,Data_Units__c,Voice_Units__c ,Video_Units__c,Archived__c,Voice_All_Units__c,Data_All_Units__c,Video_All_Units__c FROM  Contract__c WHERE Property__c IN: addressIdSet];
        List<Contract__c> listOfAddressToUpdate = new List<Contract__c>();   
        if(!addressIdSet.isEmpty()){         
        for(Contract__c contractInstance : [SELECT Id,Property__c ,Data_Units__c,Voice_Units__c ,Video_Units__c, Archived__c
                                                 , Voice_All_Units__c, Data_All_Units__c, Video_All_Units__c 
                                              FROM  Contract__c WHERE Property__c IN: addressIdSet
                                              LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){ 
            if(!contractInstance.Archived__c){             
                if( contractInstance.Voice_All_Units__c){                             
                    contractInstance.Voice_Units__c = mapOfNewAddressWithID.get(contractInstance.Property__c).Number_of_Units__c; 
                }else{
                    //Future Code
                }
                if( contractInstance.Data_All_Units__c){                
                    contractInstance.Data_Units__c = mapOfNewAddressWithID.get(contractInstance.Property__c).Number_of_Units__c;
                }else{
                    //Future Code
                }
                if( contractInstance.Video_All_Units__c) {               
                    contractInstance.Video_Units__c = mapOfNewAddressWithID.get(contractInstance.Property__c).Number_of_Units__c;
                }else{
                    //Future Code
                }
            }          
            listOfAddressToUpdate.add(contractInstance);         
        }
        }
        if(!listOfAddressToUpdate.isEmpty()) {        
            Database.update(listOfAddressToUpdate,false);
        }else{
            //Future Code
        }
    }

   
    /**
    * @Description: This method use to update number of units field on Opportunity Property Object   
    * @Author: Ashish G. Sonawane, Accenture
    * @Date: 20-April-2014 
    * @Param: none   
    * @Return: void.
    */
    Public static void changeUnitsOnOpportunityProperty(){
        String labelName = System.Label.XfinityPropertyRecordType;  
        Set<String> recordTypeSet = new Set<String>();
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(LABEL_NAME_SPLIT)){
                recordTypeSet.add(Schema.SObjectType.MDU_Property__c.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }
            
        Set<Id> addressIdSet = new Set<Id>();
        Map<Id, MDU_Property__c> oldPropertyMap = new Map<Id, MDU_Property__c>();
        Map<Id, MDU_Property__c> newPropertyMap = new Map<Id, MDU_Property__c>();
        List<Opportunity_Property__c> opportunityPropertyUpdateList = new  List<Opportunity_Property__c>();

        if(Trigger.isUpdate){
            oldPropertyMap = (Map<Id, MDU_Property__c>)Trigger.oldMap;
        }
        List<MDU_Property__c> listOfNewAddress = (List<MDU_Property__c>)Trigger.New;   
        for(MDU_Property__c property : listOfNewAddress){
            if(recordTypeSet.contains(property.RecordTypeId)){ 
                if(Trigger.isUpdate && oldPropertyMap.get(property.Id).Number_of_Units__c != property.Number_of_Units__c){
                    addressIdSet.add(property.Id);
                    newPropertyMap.put(property.Id, property);
                }
            }
        }
        if(!addressIdSet.isEmpty()){
        for(Opportunity_Property__c opportunityPropertyInstance : [SELECT Id , Number_of_Units__c, Property__c
                                              FROM  Opportunity_Property__c WHERE Property__c IN: addressIdSet
                                              LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            
            opportunityPropertyInstance.Number_of_Units__c = newPropertyMap.get(opportunityPropertyInstance.Property__c).Number_of_Units__c;
            opportunityPropertyUpdateList.add(opportunityPropertyInstance); 
        }
        }
        if(!opportunityPropertyUpdateList.isEmpty()) {        
            Database.upsert(opportunityPropertyUpdateList,false);
        }else{
            //Future Code
        }
    }

    /*
    *  US-042 : Call to delete the property record based on conditions -
    * -No Open Opportunities 
    * -No Active New Builds (Based on Status!= Complete) 
    * The system shall require confirmation of deletion and a deleted reason when a user Deletes the record.
    */
    Public static void deleteProperty(){
  
        List<MDU_Property__c> triggerOld = (List<MDU_Property__c>) trigger.old;
        Set<Id> propertyOpptySet = new Set<Id>();
        Set<Id> propertyNewBuildSet = new Set<Id>();
        Set<Id> propertyReasonSet = new Set<Id>();
        List<Deleted_Property__c> deletePropertyLogList = new List<Deleted_Property__c>();
                        
        for(MDU_Property__c prop: triggerOld){
            if(prop.Delete_Reason__c == null) {
                propertyReasonSet.add(prop.Id); 
            }else{
                //Future Code
            }
        }
        
        //Check for Open Opportunity - Uncomment code Below
        for(Opportunity_Property__c p : [SELECT Id, Property__c, Opportunity__c , Opportunity__r.StageName 
                                        FROM Opportunity_Property__c  where Property__c IN: triggerOld
                                        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){ 
            if(null!= p.Opportunity__r.StageName &&                           
                    !WON_OPPORTUNITY.equalsIgnoreCase(p.Opportunity__r.StageName.trim()) && 
                    !LOST_OPPORTUNITY.equalsIgnoreCase(p.Opportunity__r.StageName.trim())){                           
                propertyOpptySet.add(p.Property__c);
            }else{
                //Future Code
            }
        }
                
        //Check for Active New build
        for(New_Build__c nb :[SELECT Id, Property__c, Status__c 
                                FROM New_Build__c WHERE Property__c IN: triggerOld AND Status__c != 'Complete'
                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
         
            propertyNewBuildSet.add(nb.Property__c);
        }
        
        // Add error for the invalid records   
        for(MDU_Property__c prop: triggerOld){
            boolean openOppty = false;
            boolean activeNewBuild = false;
            boolean isReason = false;
            if(propertyReasonSet.contains(prop.Id)){
                isReason =true;
            }else{
                //Future code
            }
            if(propertyOpptySet.contains(prop.Id)){
                openOppty=true;                 
            }else{
                //Future code
            }
            if(propertyNewBuildSet.contains(prop.Id)){
                activeNewBuild=true;
            }else{
                //Future code
            }

            String key = generateKey(isReason, openOppty, activeNewBuild);

            if(key!=null && key.trim()!=''){
                prop.addError(key);         
            } else {
                //Property System, Deleted By, Deletion Date, Property Name, Contract Status, Deleted Reason
                Deleted_Property__c propertyLog = new Deleted_Property__c();
                propertyLog.city__c = prop.City__c;
                propertyLog.Property_Deleted_ID__c = prop.Complex_Id__c==null?String.valueOf(prop.Id): prop.Complex_Id__c;
                propertyLog.Property_Name__c = prop.Name;
                propertyLog.System_ID__c = prop.System__c;
                propertyLog.Deleted_Date__c = System.now();
                propertyLog.Delete_Reason__c = prop.Delete_Reason__c;
                propertyLog.Contract_Type__c= prop.Bulk_Status__c;              
                deletePropertyLogList.add(propertyLog);
            }
                
        }
        if(!deletePropertyLogList.isEmpty()){
            Database.Insert(deletePropertyLogList, false);
        }else{
            //Future Code
        }
    }
    
    /**
    * @description: Method to generate & return error message as concatenation of received parameters 
    * @return: String
    **/
    private static String generateKey(boolean isReason, boolean openOppty, boolean activeNewBuild) {
    
        String errorMsg= System.Label.PropertyDeleteError;
        String delReasonMsg= System.Label.PropertyDeleteReasonErr;
        String openOppMsg= System.Label.PropertyOpenOppErr;
        String activeBuildMsg= System.Label.PropertyActiveBuildErr;
        String key = '';
        
        if(isReason || openOppty || activeNewBuild){
            key= errorMsg+ ((isReason?delReasonMsg:'') + (openOppty?openOppMsg:'') + (activeNewBuild?activeBuildMsg:''));
        }
        return key;
    }
    
     /**
    * @description: This method is used to map Non Standard Region with Standard Region.
    * User Story: US625976 : XC Region Standardization
    * Author: Sucheta Verma.
    **/
    public static void OldNewRegionMapping()
    {
      List<MDU_Property__c> propRegionFieldToUpdate = new List<MDU_Property__c>();
      List<MDU_Property__c> propertyListRegion = (List<MDU_Property__c>)Trigger.new;
      Map<String, String> regionMap = new Map<String, String>();
      for(Region_Mapping__c cs : regionList){
          regionMap.put(cs.Non_Standard_Region__c, cs.Region__c);
         }
      for(MDU_Property__c propinstance : propertyListRegion){
         if(regionmap.containsKey(propinstance.Property_Region__c)){
              propinstance.Property_Region__c = regionMap.get(propinstance.Property_Region__c);
            }
           propRegionFieldToUpdate.add(propinstance);
          } 
      }
    
      /**
    * @description: This method is used to calculate percent profile fields.
    * User Story: US487337 
    * Author: Sagar Gurav.
    * Modified by : Sucheta Verma #US549384 : SalesSpace Property Lab - Property Profile Changes (1st iteration)
    * Modified by : Lalit Singh #US591222 : SalesSpace Property Lab - Property Profile Changes (2nd iteration)
    * Modified by : Suchita Sharma #US851537 : SalesSpace Property Lab - Changes to '% Product Profile Complete'
    **/
    public static void percentProfileCalculation() {
        
        List<MDU_Property__c> propPercentFieldToUpdate = new List<MDU_Property__c>();
        List<MDU_Property__c> propertyList = Trigger.new;
        for(MDU_Property__c prop: propertyList ) {
            
            /*    
            * Marketing profile completeness logic
            */
            Double countFieldsNotBlankMarketing = 0;
            Double totalCountMarketing = 0; 
            if(!String.isBlank(prop.Full_Property_Name__c)) { 
                countFieldsNotBlankMarketing += 1; 
                totalCountMarketing +=1;
            } else {
                totalCountMarketing +=1;
            }
            if(!String.isBlank(prop.Property_Management_Contact_name__c)) {
                countFieldsNotBlankMarketing += 1; 
                totalCountMarketing +=1;
            } else {
                totalCountMarketing +=1;
            } 
            if(!String.isBlank(prop.Website__c)) { 
                countFieldsNotBlankMarketing += 1;
                totalCountMarketing +=1;
            } else {
                totalCountMarketing +=1;
            } 
            if(!String.isBlank(prop.Main_property_phone_number__c)) {
                countFieldsNotBlankMarketing += 1; 
                totalCountMarketing +=1;
            } else {
                totalCountMarketing +=1;
            } 
            if(!String.isBlank(prop.Is_there_an_onsite_daily_contact_for_the__c)) { 
                countFieldsNotBlankMarketing += 1;
                totalCountMarketing +=1;
            } else {
                totalCountMarketing +=1;
            }
            if(!String.isBlank(prop.How_does_the_property_communicate__c)) { 
                countFieldsNotBlankMarketing += 1; 
                totalCountMarketing +=1;
                if(prop.How_does_the_property_communicate__c.containsIgnoreCase('Other')) {
                    if(!String.isBlank(prop.Other_Communication__c)) {
                        countFieldsNotBlankMarketing += 1;
                        totalCountMarketing +=1;
                    }
                    else {
                        totalCountMarketing +=1;
                    }
                }
            } 
            else {
                totalCountMarketing +=1;
            }           
            
            if(!String.isBlank(prop.How_are_residents_billed_for_rent__c)) { 
                countFieldsNotBlankMarketing += 1; 
                totalCountMarketing +=1;
                if('Electronic'.equalsIgnoreCase(prop.How_are_residents_billed_for_rent__c)) {
                    if(!String.isBlank(prop.If_electronic_do_they_have_to_login__c)) {
                        countFieldsNotBlankMarketing += 1;
                        totalCountMarketing +=1;
                    }
                    else {
                        totalCountMarketing +=1;
                    }
                }
            } 
            else {
                totalCountMarketing +=1;
            }
            if(!String.isBlank(prop.Is_online_execution_of_lease_supported__c)) { 
                countFieldsNotBlankMarketing += 1; 
                totalCountMarketing +=1;
                if('Yes'.equalsIgnoreCase(prop.Is_online_execution_of_lease_supported__c)) {
                    if(!String.isBlank(prop.of_residents_executing_leases_online__c)) {
                        countFieldsNotBlankMarketing += 1;
                        totalCountMarketing +=1;
                    }
                    else {
                        totalCountMarketing +=1;
                    }
                }
            } 
            else {
                totalCountMarketing +=1;
            }
            if(!String.isBlank(prop.Marketing_Wiring_Rights_Violation__c)) { 
                countFieldsNotBlankMarketing += 1; 
                totalCountMarketing +=1;
                if('Yes'.equalsIgnoreCase(prop.Marketing_Wiring_Rights_Violation__c)) {
                    if(!String.isBlank(prop.Select_the_type_of_violation__c)) {
                        countFieldsNotBlankMarketing += 1;
                        totalCountMarketing +=1;
                    }
                    else {
                        totalCountMarketing +=1;
                    }
                }
            } 
            else {
                totalCountMarketing +=1;
            }
            
            
            if(!String.isBlank(prop.Property_allow_sponsored_resident_event__c)) {
                countFieldsNotBlankMarketing += 1; 
                totalCountMarketing +=1;
                if('Yes'.equalsIgnoreCase(prop.Property_allow_sponsored_resident_event__c)) {
                    if(!String.isBlank(prop.What_type_of_event__c)) {
                        countFieldsNotBlankMarketing += 1;
                        totalCountMarketing +=1;
                    }
                    else {
                        totalCountMarketing +=1;
                    }
                    
                    if('Other'.equalsIgnoreCase(prop.What_type_of_event__c)){
                        if(!String.isBlank(prop.Other_Event_Types__c)) {
                            countFieldsNotBlankMarketing += 1;
                            totalCountMarketing +=1;
                        }
                        else {
                            totalCountMarketing +=1;
                        }
                    }
                }
            }
            else {
                totalCountMarketing +=1;
            }           
            
            if(!String.isBlank(prop.Can_you_door_knock_at_this_property__c)) { 
                countFieldsNotBlankMarketing += 1;
                totalCountMarketing +=1;
            } else {
                totalCountMarketing +=1;
            }         
            if(!String.isBlank(String.valueOf(prop.Estimated_International_Resident__c))) { 
                countFieldsNotBlankMarketing += 1; 
                totalCountMarketing +=1;
                if(prop.Estimated_International_Resident__c > 25){
                    if(!String.isBlank(prop.If_above_25_what_is_origin_country__c)) {
                        countFieldsNotBlankMarketing += 1;
                        totalCountMarketing +=1;
                    }else {
                        totalCountMarketing +=1;
                    }
                }
            } else {
                totalCountMarketing +=1;
            }
            
            if(!String.isBlank(prop.Language_spoken_most_often_by_tenants__c)) { 
                countFieldsNotBlankMarketing += 1; 
                totalCountMarketing +=1;
            } else {
                totalCountMarketing +=1;
            }  
            if(!String.isBlank(prop.Need_interest_in_International__c)) { 
                countFieldsNotBlankMarketing += 1; 
                totalCountMarketing +=1;
                if('Yes'.equalsIgnoreCase(prop.Need_interest_in_International__c)){
                    if(!String.isBlank(prop.do_they_watch_on_traditional_TV_or_onlin__c)) {
                        countFieldsNotBlankMarketing += 1;
                        totalCountMarketing +=1;
                    }else {
                        totalCountMarketing +=1;
                    }
                }
            } else {
                totalCountMarketing +=1;
            }
            
            if(!String.isBlank(prop.What_is_average_age_of_tenants__c)) { 
                countFieldsNotBlankMarketing += 1;
                totalCountMarketing +=1;
            } else {
                totalCountMarketing +=1;
            } 
            if(!String.isBlank(prop.Lifestyle_alternative_for_the_property__c)) { 
                countFieldsNotBlankMarketing += 1;
                totalCountMarketing +=1;
            } else {
                totalCountMarketing +=1;
            }
            if(!String.isBlank(String.valueOf(prop.What_of_residents_are_students__c))) { 
                countFieldsNotBlankMarketing += 1;
                totalCountMarketing +=1;
            } else {
                totalCountMarketing +=1;
            } 
            if(!String.isBlank(String.valueOf(prop.What_of_residents_have_small_children__c))) { 
                countFieldsNotBlankMarketing += 1; 
                totalCountMarketing +=1;
            } else {
                totalCountMarketing +=1;
            } 
            if(!String.isBlank(prop.Does_property_have_coffee_vendor_onsite__c)) { 
                countFieldsNotBlankMarketing += 1; 
                totalCountMarketing +=1;
            } else {
                totalCountMarketing +=1;
            } 
        
            if(!String.isBlank(prop.Rewards_Incentive_Programs_enrolled__c)) { 
                countFieldsNotBlankMarketing += 1; 
                totalCountMarketing +=1;
                if('Other'.equalsIgnoreCase(prop.Rewards_Incentive_Programs_enrolled__c)){
                    if(!String.isBlank(prop.Other_Reward_Description__c)) {
                        countFieldsNotBlankMarketing += 1;
                        totalCountMarketing +=1;
                    }else {
                        totalCountMarketing +=1;
                    }
                }
            } else {
                totalCountMarketing +=1;
            }
            prop.Marketing_Profile_Complete_Calc__c = countFieldsNotBlankMarketing / totalCountMarketing * 100;

           /*    
            * Merchandise profile completeness logic
            */                                    
            Double countFieldsNotBlankMerchandise = 0;      
            Double totalCountMerchandise = 0; 
            
            if(!String.isBlank(prop.Are_there_TV_s_in_public_view__c)) { 
                countFieldsNotBlankMerchandise += 1;
                totalCountMerchandise +=1;
                if('Yes'.equalsIgnoreCase(prop.Are_there_TV_s_in_public_view__c)){
                    if(!String.isBlank(prop.Select_quantity_of_Televisions__c)){
                        countFieldsNotBlankMerchandise += 1;
                        totalCountMerchandise +=1;
                    }else {
                        totalCountMerchandise +=1;
                    }
                    if(!String.isBlank(prop.Is_the_service_included_in_a_Courtesy_Ac__c)) {
                        countFieldsNotBlankMerchandise += 1;
                        totalCountMerchandise +=1;
                    }else {
                        totalCountMerchandise +=1;
                    }
                }
            }else {
                totalCountMerchandise +=1;
            }  
            if(!String.isBlank(prop.Does_property_have_ability_to_display_Xf__c)) { 
                countFieldsNotBlankMerchandise += 1; 
                totalCountMerchandise +=1;
                if('Yes'.equalsIgnoreCase(prop.Does_property_have_ability_to_display_Xf__c)){
                    if(!String.isBlank(prop.Nbr_of_Large_Standees__c)) {
                        countFieldsNotBlankMerchandise += 1;
                        totalCountMerchandise +=1;
                    }else {
                        totalCountMerchandise +=1;
                    }
                    if(!String.isBlank(prop.Nbr_of_Counter_Standees__c)) {
                        countFieldsNotBlankMerchandise += 1;
                        totalCountMerchandise +=1;
                    } else {
                        totalCountMerchandise +=1;
                    }
                    if(!String.isBlank(prop.Nbr_of_Posters__c)) {
                        countFieldsNotBlankMerchandise += 1;
                        totalCountMerchandise +=1;
                    }else {
                        totalCountMerchandise +=1;
                    }
                    if(!String.isBlank(prop.Nbr_of_Brochures_Sales_Flyers__c)) {
                        countFieldsNotBlankMerchandise += 1;
                        totalCountMerchandise +=1;
                    }else {
                        totalCountMerchandise +=1;
                    }
                    
                }
            } else {
                totalCountMerchandise +=1;
            }
             if(!String.isBlank(prop.How_many_Xfinity_Clings__c)) { 
                countFieldsNotBlankMerchandise += 1;
                totalCountMerchandise +=1;
                 
            } else {
                totalCountMerchandise +=1;
            } 
            
            if(!String.isBlank(prop.Is_competitor_merchandising_visible__c)) { 
                countFieldsNotBlankMerchandise += 1; 
                totalCountMerchandise +=1;
                if('Yes'.equalsIgnoreCase(prop.Is_competitor_merchandising_visible__c)){
                    if(!String.isBlank(prop.Who_is_the_Competitor__c)) {
                        countFieldsNotBlankMerchandise += 1;
                        totalCountMerchandise +=1;  
                      if(prop.Who_is_the_Competitor__c.containsIgnoreCase('Other')){
                        if(!String.isBlank(prop.Other_Competitor__c)) {
                            countFieldsNotBlankMerchandise += 1;
                            totalCountMerchandise +=1;
                        }else {
                            totalCountMerchandise +=1;
                         }
                       }
                     } else {
                     totalCountMerchandise +=1;
                    }
                    
                    if(!String.isBlank(prop.what_is_competitor_merchandising__c)) {
                        countFieldsNotBlankMerchandise += 1;
                        totalCountMerchandise +=1;                                          
                    } else {
                        totalCountMerchandise +=1;
                    }               
                
                } 
            }else{
              totalCountMerchandise +=1;
            }
            
            prop.Merchandise_Profile_Complete_Calc__c = countFieldsNotBlankMerchandise / totalCountMerchandise * 100;

            /*    
            * Product profile completeness logic
            */
            Double countFieldsNotBlankProduct = 0;  
            Double totalCountProduct = 0;
            if(!String.isBlank(prop.When_was_property_built__c)) { 
                countFieldsNotBlankProduct += 1; 
                totalCountProduct +=1;
            } else {
                totalCountProduct +=1;
            }
            if(!String.isBlank(prop.What_type_of_wiring_is_run_to_the_units__c)) { 
                countFieldsNotBlankProduct += 1;
                totalCountProduct +=1;
                if('Ethernet'.equalsIgnoreCase(prop.What_type_of_wiring_is_run_to_the_units__c)){
                    if(!String.isBlank(prop.What_type_of_Ethernet__c)) {
                        countFieldsNotBlankProduct += 1;
                        totalCountProduct +=1;                  
                    } else {
                    totalCountProduct +=1;
                    }
                } 
               
            } else {
                totalCountProduct +=1;
            }
            if(!String.isBlank(prop.What_type_of_wiring_is_within_the_units__c)) {
                countFieldsNotBlankProduct += 1;
                totalCountProduct +=1;
                if(('Ethernet'.equalsIgnoreCase(prop.What_type_of_wiring_is_within_the_units__c))||('Fiber'.equalsIgnoreCase(prop.What_type_of_wiring_is_within_the_units__c))||('Coax Cable'.equalsIgnoreCase(prop.What_type_of_wiring_is_within_the_units__c)))
                {
                    if(!String.isBlank(prop.Select_the_quantity_of_the_home_wiring__c)) {
                        countFieldsNotBlankProduct += 1;
                        totalCountProduct +=1;                  
                    } else {
                    totalCountProduct +=1;
                    }
                } 
            } else {
                totalCountProduct +=1;
            } 
            if(!String.isBlank(prop.Is_there_conduit_available_to_each_unit__c)) {
                countFieldsNotBlankProduct += 1;
                totalCountProduct +=1;
            } else {
                totalCountProduct +=1;
            } 
            if(!String.isBlank(prop.Current_vacancy_rate_of_property__c)) { 
                countFieldsNotBlankProduct += 1;
                totalCountProduct +=1;
            } else {
                totalCountProduct +=1;
            } 
            if(!String.isBlank(prop.Does_property_have_common_area_WiFi__c)) { 
                countFieldsNotBlankProduct += 1; 
                totalCountProduct +=1;
                if('Yes'.equalsIgnoreCase(prop.Does_property_have_common_area_WiFi__c)){
                    if(!String.isBlank(prop.Who_provides__c)) {
                        countFieldsNotBlankProduct += 1;
                        totalCountProduct +=1;           
                    } else {
                        totalCountProduct +=1;
                    }
                    
                    if('Other'.equalsIgnoreCase(prop.Who_provides__c)){
                        if(!String.isBlank(prop.Other_Wifi_provider__c)) {
                            countFieldsNotBlankProduct += 1;
                            totalCountProduct +=1;
                        } else {
                            totalCountProduct +=1;
                        }
                    }       
                }
            } else {
                totalCountProduct +=1;
            } 
            if(prop.Buildings__c != null) { 
                countFieldsNotBlankProduct += 1;
                totalCountProduct +=1;
            } else {
                totalCountProduct +=1;
            }
            if(prop.How_many_corporate_housing_units__c != null) { 
                countFieldsNotBlankProduct += 1; 
                totalCountProduct +=1;
            } else {
                totalCountProduct +=1;
            }
            if(prop.How_many_floors_per_building__c != null) {
                countFieldsNotBlankProduct += 1; 
                totalCountProduct +=1;
            } else {
                totalCountProduct +=1;
            }
            if(prop.Estimated_average_unit_size_sq_ft__c != null) { 
                countFieldsNotBlankProduct += 1; 
                totalCountProduct +=1;
            } else {
                totalCountProduct +=1;
            }
            if(prop.Does_Property_have_a_Pool__c != null) { 
                countFieldsNotBlankProduct += 1;
                totalCountProduct +=1;
            } else {
                totalCountProduct +=1;
            }
            //US851537 Changes
            if(prop.Are_security_products_currently_offered__c != null) { 
                countFieldsNotBlankProduct += 1; 
                totalCountProduct +=1;  
            } else {
                totalCountProduct +=1;
            }
            
            if(prop.Amenable_to_Xfinity_Home_product_sales__c != null) { 
                countFieldsNotBlankProduct += 1; 
                totalCountProduct +=1;
                if('Yes'.equalsIgnoreCase(prop.Amenable_to_Xfinity_Home_product_sales__c)) {
                    if(prop.Which_monitored_service__c != null) {
                        countFieldsNotBlankProduct += 1;
                        totalCountProduct +=1;
                    } else {
                        totalCountProduct +=1;
                    }
                }
            }  else {
                totalCountProduct +=1;
            }
            
            //US851537 Changes
            if(!String.isBlank(prop.Are_other_telecom_services_provided__c)) { 
                countFieldsNotBlankProduct += 1; 
                totalCountProduct +=1;
            } else{
                totalCountProduct +=1;
            }
       
            if(prop.Number_of_PropertyCompetitor__c != null && prop.Number_of_PropertyCompetitor__c>0) { 
                countFieldsNotBlankProduct += 1; 
                totalCountProduct +=1;
            } else {
                totalCountProduct +=1;
            }
            
            prop.Product_Profile_Complete_Calc__c = countFieldsNotBlankProduct / totalCountProduct * 100;
            propPercentFieldToUpdate.add(prop);
    
        }
    }
    /* @description: This method is used to calculate average percent profile and updates the metric currentvalue.
    * User Story: US636893 
    * Author : gafoor
    * Last Modified By : Amit Kumar Pradhan(Roll up '%Profile completion%' to CAR manager)
    * Last Modified Date : 8-Sept-2016(US760932)
    **/
    public static void profilepercentmetricupdate(List<MDU_Property__c> propertyList ,Map<id,MDU_Property__c> oldMap ) {
        set<Id> carIds= new set<Id>();
        Integer todayDate = Date.Today().Day();
        Date preGoalStartDate = null;
        Date preGoalDueDate = null;      
        Date dueTemplateDate = null;       
        Set<String> carMgrIdSet = new Set<String>();        
        Map<String, List<String>> mgrIdUserListMap = new Map<String, List<String>>();
        Map<String,Decimal> mgrProfileCompletPerc = new Map<String,Decimal>();
        Map<String,Integer> mgrIdANDPropCount = new Map<String,Integer>();
        Map<String,Decimal> carProfileCompletPerc = new Map<String,Decimal>();
        Map<String,Integer> carIdANDPropCount = new Map<String,Integer>();
        List<Metric> metricNewList = new List<Metric>();
        try{
            MetricTriggerController.allowValidation = false;
            for(MDU_Property__c p : propertyList){
             
                 if((trigger.isInsert && p.Assigned_CAR__c != null) || 
                    (trigger.isUpdate && (p.Merchandise_Profile_Complete_Calc__c != oldMap.get(p.Id).Merchandise_Profile_Complete_Calc__c || p.Product_Profile_Complete_Calc__c != oldMap.get(p.Id).Product_Profile_Complete_Calc__c || p.Marketing_Profile_Complete_Calc__c != oldMap.get(p.Id).Marketing_Profile_Complete_Calc__c || p.Assigned_CAR__c != oldMap.get(p.Id).Assigned_CAR__c)) ){
                    carIds.add(p.Assigned_CAR__c); 
                }
                if((p.Assigned_CAR__c != oldMap.get(p.Id).Assigned_CAR__c) && oldMap.get(p.Id).Assigned_CAR__c!= null ){
                    carIds.add(oldMap.get(p.Id).Assigned_CAR__c); 
                }                       
            }
            
            //Extended Actuall roll up for Car manager(US :US760932)
            for(User userObj: [SELECT Id, ManagerId, Manager.isActive FROM User WHERE ID IN:carIds AND Profile.Name =: XFINITY_CAR LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                if(userObj.ManagerId != null && userObj.Manager.isActive){
                    carMgrIdSet.add(userObj.ManagerId);
                }   
            }
            
            //Get the Fiscal Year Date period goal start/due dates            
            GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(PROPERTY_LAB_GOAL_TEMPLATE);
            dueTemplateDate = goalDates.Current_Period_Due_Date__c;
            Integer remainingDays = dueTemplateDate!=null?System.today().daysBetween(dueTemplateDate):0;
            
            if(goalDates != null){               
                if(todayDate>=22){              
                    preGoalStartDate = Date.newInstance(date.today().Year(), date.today().Month(), 22);  
                }else if(todayDate>=1 && todayDate<=21){
                    preGoalStartDate = Date.newInstance(date.today().Year(), date.today().Month()-1, 22); 
                }                       
                preGoalDueDate =  preGoalStartDate.addMonths(1).AddDays(-1);
            }
            
            //Added logic for actual roll up to car and car manager       
            for(MDU_Property__c propObj : [SELECT id, Merchandise_Profile_Complete_Calc__c, Assigned_CAR__r.ManagerId,
                                            Product_Profile_Complete_Calc__c, Marketing_Profile_Complete_Calc__c, Assigned_CAR__c from MDU_Property__c 
                                            WHERE (Assigned_CAR__r.managerId IN : carMgrIdSet OR Assigned_CAR__c IN : carIds) AND LastModifiedDate>=: preGoalStartDate 
                                            AND LastModifiedDate<=: preGoalDueDate LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                //Calcualtion Logic For CAR
                if(carIds.contains(propObj.Assigned_CAR__c)){
                    Integer propCountForCar=0;
                    Decimal netPercForCar = 0.0;
                    Decimal totalOldPropAvgForCar = 0.0;                
                    if(carProfileCompletPerc.containsKey(propObj.Assigned_CAR__c)&& carIdANDPropCount.containsKey(propObj.Assigned_CAR__c)){
                        netPercForCar = carProfileCompletPerc.get(propObj.Assigned_CAR__c);
                        propCountForCar = carIdANDPropCount.get(propObj.Assigned_CAR__c);
                    }else{
                        //Future Code
                    }
                    totalOldPropAvgForCar = netPercForCar*propCountForCar;
                    propCountForCar++;
                    carIdANDPropCount.put(propObj.Assigned_CAR__c, propCountForCar);
                    
                    Decimal avgOfProp = (propObj.Merchandise_Profile_Complete_Calc__c + propObj.Product_Profile_Complete_Calc__c + propObj.Marketing_Profile_Complete_Calc__c ) / 3;
                    netPercForCar =  (totalOldPropAvgForCar + avgOfProp)/propCountForCar;
                    carProfileCompletPerc.put(propObj.Assigned_CAR__c, netPercForCar);
                    
                }else{
                    //Future Code
                }                                
                //Calcualtion Logic For CAR Manager                             
                if(propObj.Assigned_CAR__r.ManagerId !=null){                               
                    Integer count=0;
                    Decimal netPercentage = 0.0;
                    Decimal totalOldPropAvg = 0.0;              
                    if(mgrProfileCompletPerc.containsKey(propObj.Assigned_CAR__r.ManagerId)&& mgrIdANDPropCount.containsKey(propObj.Assigned_CAR__r.ManagerId)){
                        netPercentage = mgrProfileCompletPerc.get(propObj.Assigned_CAR__r.ManagerId);
                        count = mgrIdANDPropCount.get(propObj.Assigned_CAR__r.ManagerId);
                    }else{ 
                    //Future Code
                    }
                    totalOldPropAvg = netPercentage*count;
                    count++;
                    mgrIdANDPropCount.put(propObj.Assigned_CAR__r.ManagerId, count);
                    
                    Decimal avgOfProp = (propObj.Merchandise_Profile_Complete_Calc__c + propObj.Product_Profile_Complete_Calc__c + propObj.Marketing_Profile_Complete_Calc__c ) / 3;
                    netPercentage =  (totalOldPropAvg + avgOfProp)/count;
                    mgrProfileCompletPerc.put(propObj.Assigned_CAR__r.ManagerId, netPercentage);
                }else{ 
                //Future Code
                }                
            }

            //Update the "profile complition%" metric for Car and Car Manager
            for(Metric metricObj : [SELECT Id, CurrentValue, OwnerId, TargetValue, Goal.StartDate, Goal.DueDate, Goal.Status FROM Metric 
                                    WHERE Name like : PROFILE_COMPLITION_PERC AND Goal.Status =: GOAL_STATUS AND Goal.StartDate <=: system.today() 
                                    AND Goal.DueDate >=: system.today() AND (Goal.OwnerId IN : carIds OR Goal.OwnerId IN :carMgrIdSet) 
                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                
                if(carProfileCompletPerc.containsKey(metricObj.ownerId)){
                    metricObj.CurrentValue = metricObj.CurrentValue!=null?carProfileCompletPerc.get(metricObj.ownerId).setscale(2):0;
                }else{ 
                //Future Code
                }
                if(mgrProfileCompletPerc.containsKey(metricObj.ownerId)){
                    metricObj.CurrentValue = metricObj.CurrentValue!=null?mgrProfileCompletPerc.get(metricObj.ownerId).setscale(2):0;
                }else{ 
                //Future Code 
                }
                metricNewList.add(metricObj);               
            }
            
            if(!metricNewList.isEmpty()) {        
                Database.update(metricNewList,false);
            }else{
                //Future Code
            }
        }catch(Exception e){
            System.debug('Exception------'+e.getMessage());
        }             
    }
    /* @description: This method is used to access contacts on property when the Assigned CAR is changed  .
    * User Story: US655398 
    * Author : Tejaswini Kasar
    **/
    Public static void CarChangeOnProperty(List<MDU_Property__c> newPropList, Map<Id,MDU_Property__c>oldPropMap){
     Set<Id> assignedCarIdSet = new Set<Id>();
        Map<Id,Id>assignedCarIdMap  = new Map<Id,Id> ();
        List<Contact> updateList = new List<Contact>();
        try{
            for(MDU_Property__c newProperty : newPropList) {
                if((newProperty.Assigned_CAR__c != oldPropMap.get(newProperty.Id).Assigned_CAR__c) && (newProperty.Assigned_CAR__c!=NULL)) {  
                    assignedCarIdMap.put(newProperty.Id,newProperty.Assigned_CAR__c);
                }
            }
            if(!assignedCarIdMap.isEmpty()){
                List<Contact> conList = [SELECT Id, Property__c, OwnerId FROM Contact WHERE Property__c IN: assignedCarIdMap.keySet()];

                for(Contact propContacts: conList) {
                    if(assignedCarIdMap!=null && assignedCarIdMap.get(propContacts.Property__c)!=null){
                        propContacts.OwnerId = assignedCarIdMap.get(propContacts.Property__c);
                        updateList.add(propContacts);
                    }
                }
            }
            if(!updateList.isEmpty()) {
                Database.update(updateList, false);
            }
        }catch(Exception e){
            system.debug('>>>>>>Exception in carChangeOnProperty: '+e.getMessage()); 
        }   
  }
  
   /*
    *  US-727101: This method is use to check following conditions before 
    *  checking Delete_Property__c for deleting a property record -
    *  ‘Delete Reason’ field populated
    *  No Open Opportunities 
    *  No Active New Builds (Based on Status!= Complete) 
    *  Author-Mandeep Singh
    */
  Public static void deletePropertyCheck(List<MDU_Property__c> propList){
  
        Set<Id> propertyOpptySet = new Set<Id>();
        Set<Id> propertyNewBuildSet = new Set<Id>();
        Set<Id> propertyReasonSet = new Set<Id>();
        List<MDU_Property__c> deletePropList = new List<MDU_Property__c>();
        boolean deleteFlag;
        
        for(MDU_Property__c propCheck: propList){
             if(propCheck.Delete_Property__c == true){
                deletePropList.add(propCheck);
            }
        
        }
        if(deletePropList.size()>0){
        for(MDU_Property__c prop: deletePropList){
            if(prop.Delete_Reason__c == null) {
                propertyReasonSet.add(prop.Id); 
            }else{
                //Future Code
            }
        }
        
        //Check for Open Opportunity - Uncomment code Below
        for(Opportunity_Property__c p : [SELECT Id, Property__c, Opportunity__c , Opportunity__r.StageName 
                                        FROM Opportunity_Property__c  where Property__c IN: deletePropList 
                                        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){ 
            if(null!= p.Opportunity__r.StageName &&                           
                    !WON_OPPORTUNITY.equalsIgnoreCase(p.Opportunity__r.StageName.trim()) && 
                    !LOST_OPPORTUNITY.equalsIgnoreCase(p.Opportunity__r.StageName.trim())){                           
                propertyOpptySet.add(p.Property__c);
            }else{
                //Future Code
            }
        }
                
        //Check for Active New build
        for(New_Build__c nb :[SELECT Id, Property__c, Status__c 
                                FROM New_Build__c WHERE Property__c IN: deletePropList AND Status__c != 'Complete'
                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
         
            propertyNewBuildSet.add(nb.Property__c);
        }
        
        // Add error for the invalid records   
                        
        for(MDU_Property__c prop: deletePropList){
            
            boolean openOppty = false;
            boolean activeNewBuild = false;
            boolean isReason = false;
            if(propertyReasonSet.contains(prop.Id)){
                isReason =true;
            }else{
                //Future code
            }
            if(propertyOpptySet.contains(prop.Id)){
                openOppty=true;                 
            }else{
                //Future code
            }
            if(propertyNewBuildSet.contains(prop.Id)){
                activeNewBuild=true;
            }else{
                //Future code
            }

            String key = generateKey(isReason, openOppty, activeNewBuild);

            if(key!=null && key.trim()!=''){
                prop.addError(key);         
            } 
        } 
        } 
    }   
}