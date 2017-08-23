/**
* Class Name: ExpireAddressesBatch 
* Author: Amitkumar Bangad, Accenture
* Date: 02-May-2013 
* Requirement # Request Id: 218  
* Description: This batch apex process the addresses & clear plan specific attributes 
*              It will pass address ownership to Shared Pool.
* Last Modified : Amit kumar Pradhan
* Date: 01-Jan-2016
* User Story : US597299(Assign Bulk Plan Addresses to Shared Data pool)
* Description: RSA's should update the expiration date to release the addresses associated with the bulk plan. 
*              The addresses will be assigned back to the pool the following day
*/
global class ExpireAddressesBatch implements Database.Batchable<sObject>{
    global String query;
    global Date checkDate;
    global String queryString;
    Set<Id> PlanIds = new Set<Id>();
    Set<Plan__c> PlanDuplicateRemoval = new Set<Plan__c>();
    List<Plan__c> PlanList = new List<Plan__c>();
    Map<Id,Plan__c> planMapObj = new Map<Id,Plan__c>();
    User sharedData;
    List<Plan__c> assignAndDraftPlanList = new List<Plan__c>();
    
    /**
    * @description - This method initalises the field set in querystring 
    */    
    //global void initialiseQuery(){
     //   query = 'Select Id, Number_of_Addresses__c, Number_of_Excluded_Addresses__c, True_count_of_Addresses__c, Plan_Status__c From Plan__c';
    //}
    /**
     * @description - Un-Parameterised constructor, this is used when scheduler calls the batch process.
     *                It appends the where to querystring to pick all relevant records.
     */    
    global ExpireAddressesBatch() {      
        sharedData = [Select Id, Name from User where Name='Shared Data User'];
        //initialiseQuery();
        checkDate = System.Today();
        
        queryString = 'Select Id,Plan_Level__c, Number_of_Addresses__c, Number_of_Excluded_Addresses__c,True_count_of_Addresses__c, Plan_Status__c From Plan__c ';
        if(Test.isRunningTest()){
             queryString += 'where Plan_Status__c != \'Expired\' AND Plan_Level__c != \'Playlist\'';
        }
        else{
            queryString += ' where Expiration_Date__c <: checkDate';
            queryString += ' AND Plan_Status__c != \'Expired\' AND Plan_Level__c != \'Playlist\'';
        }
        
        assignAndDraftPlanList = database.query(queryString);
        
        for (Plan__c planObj : assignAndDraftPlanList) {           
            planObj.Plan_Status__c = Label.PlanStatusExpired;           
            /** 
              * Not clearing the values in Number_of_Addresses__c, Number_of_Excluded_Addresses__c, and  True_count_of_Addresses__c for bulk plans.
              * This can be used in reports to understand how bulk plans are used.
              */
            if(planObj.Plan_Level__c != Label.PlanTypeBulk){            
                planObj.Number_of_Addresses__c=0;
                planObj.Number_of_Excluded_Addresses__c=0;
                planObj.True_count_of_Addresses__c=0;
            }
            PlanIds.add(planObj.Id);
            PlanDuplicateRemoval.add(planObj);
            planMapObj.put(planObj.Id,planObj);
        }
        
        for(Plan__c playlist:[Select Id From Plan__c WHERE Parent_Plan__c IN:PlanIds AND Plan_Status__c != 'Expired']){
            playlist.Plan_Status__c = Label.PlanStatusExpired;
            playlist.Number_of_Addresses__c=0;
            playlist.Number_of_Excluded_Addresses__c=0;
            playlist.True_count_of_Addresses__c=0;
            PlanIds.add(playlist.Id);
            PlanDuplicateRemoval.add(playlist);
            planMapObj.put(playlist.Id,playlist);
        }
        //PlanList.addAll(PlanDuplicateRemoval);
        for(Plan__c pln : planMapObj.values()){
            PlanList.add(pln);
        }
        query = 'Select Id, Team__c, Excluded__c, Off_Turf__c, Plan__c, Number_of_Knocks__c, OwnerId, Most_Recent_Disposition__c,Plan__r.Parent_Plan__r.Parent_Plan__r.Expiration_Date__c, Plan__r.Parent_Plan__r.Expiration_Date__c,Plan__r.Plan_Level__c,Plan__r.Parent_Plan__r.Plan_Level__c,Plan__r.Parent_Plan__r.Parent_Plan__r.Plan_Level__c,Plan__r.Parent_Plan__r.User__c,Plan__r.Parent_Plan__r.Parent_Plan__r.User__c, Plan__r.Parent_Plan__r.Parent_Plan__r.Plan_Status__c,Plan__r.Parent_Plan__r.Plan_Status__c from Customer_Address__c where Plan__c =: PlanIds';
    }
    /**
     * @description - It fetches the query Locator for the provided query.
     * @param Database.BatchableContext batchContext
     * @return Database.QueryLocator
     */
    global Database.QueryLocator start(Database.BatchableContext batchContext){
        Database.QueryLocator queryLocator;
        if (query != '') {
            queryLocator = Database.getQueryLocator(query);
        }
        return queryLocator;
    }
    /**
     * @description - It identifies the addresses to be expired & clears the Plan specific paramenters from address.  
     * @param Database.BatchableContext batchContext, List<sObject> scope   
     */    
    global void execute(Database.BatchableContext batchContext, List<Customer_Address__c> scope){        
        /** 
          * We have commented this and written the logic inside constructor because 
          * for Plan Type "Bulk", It may have upto 40k addresses and we can't update more then 10k in one trasaction
          */
          
    /*
        Set<Id> AddressIds = new Set<Id>();        
        // User Story: US448962 , Sprint 2 Change, Date : 5/19/2015, Author : Pranjal Singh
        //used set for duplicate plans removal
        
        List<Customer_Address__c> AddressList = new List<Customer_Address__c>();
        List<Plan__c> PlanList = new List<Plan__c>();
        for (sObject sObj : scope) {
            Plan__c p = (Plan__c)sObj;
            //if(p.id == 'a0Iq00000053a7rEAA'){
                p.Plan_Status__c = Label.PlanStatusExpired;
                //if(p.Plan_Level__c != Label.PlanTypeBulk){
                    p.Number_of_Addresses__c=0;
                    p.Number_of_Excluded_Addresses__c=0;
                    p.True_count_of_Addresses__c=0;
                //}
                PlanIds.add(p.Id);
                PlanDuplicateRemoval.add(p);
            //} 
        }
      
       for(Plan__c playlist:[Select Id From Plan__c WHERE Parent_Plan__c IN:PlanIds AND Plan_Status__c != 'Expired']){
            
            Plan__c p = (Plan__c)playlist;
            p.Plan_Status__c = Label.PlanStatusExpired;
            p.Number_of_Addresses__c=0;
            p.Number_of_Excluded_Addresses__c=0;
            p.True_count_of_Addresses__c=0;
            PlanIds.add(p.Id);
            PlanDuplicateRemoval.add(p);
        }
        PlanList.addAll(PlanDuplicateRemoval);
        // User Story: US448962 , Sprint 2 Change, Date : 5/19/2015, Author : Pranjal Singh
        // Added PlanDuplicateRemoval set into PlanList list for database query
        User sharedData = [Select Id, Name from User where Name='Shared Data User'];
        for (Customer_Address__c add: [Select Id, Team__c, Excluded__c, Off_Turf__c, Plan__c, Number_of_Knocks__c, OwnerId, Most_Recent_Disposition__c
                                        from Customer_Address__c where Plan__c =: PlanIds]){
            add.Plan__c = null;
            add.Team__c = null;
            add.Off_Turf__c = false;
            add.Excluded__c = false;
            add.Number_of_Knocks__c = 0;   
            add.Most_Recent_Disposition__c = Label.DispositionTypeNoKnock;   
            add.OwnerId = sharedData.Id;
            AddressList.add(add);                            
        }        
    */
        List<Customer_Address__c> AddressList = new List<Customer_Address__c>();        
        for (Customer_Address__c add : scope){
            if(add.Plan__r.Plan_Level__c == 'Turf' && add.Plan__r.Parent_Plan__r.Plan_Level__c == 'Bulk' && add.Plan__r.Parent_Plan__r.Expiration_Date__c >= System.Today()){
                add.Plan__c = add.Plan__r.Parent_Plan__c;
                add.OwnerId = add.Plan__r.Parent_Plan__r.User__c;
            }
            else if(add.Plan__r.Plan_Level__c == 'Playlist' && add.Plan__r.Parent_Plan__r.Plan_Level__c == 'Turf' && add.Plan__r.Parent_Plan__r.Parent_Plan__r.Plan_Level__c == 'Bulk' && add.Plan__r.Parent_Plan__r.Parent_Plan__r.Expiration_Date__c >= System.Today()){
                add.Plan__c = add.Plan__r.Parent_Plan__r.Parent_Plan__c;
                add.OwnerId = add.Plan__r.Parent_Plan__r.Parent_Plan__r.User__c;
            }
            else{
                add.Plan__c = null;  
                add.OwnerId = sharedData.Id;
            }
            add.Team__c = null;
            add.Off_Turf__c = false;
            add.Excluded__c = false;
            add.Number_of_Knocks__c = 0;   
            add.Most_Recent_Disposition__c = Label.DispositionTypeNoKnock;   
            AddressList.add(add);
        }
        if(!(AddressList.isEmpty())){
            try{
                Database.SaveResult[] res = Database.update(AddressList,false);                 
            }catch (Exception ex){
                System.debug('Following exception occurred :'+ex.getMessage()); 
            }       
        }
        /**
          *Commented here because we are updating the PlanList inside finish method
          */
          
        /*if(!(PlanList.isEmpty())){
            try{
                
                Database.SaveResult[] rest = Database.update(PlanList,false);              
            }catch (Exception ex){
                System.debug('Following exception occurred :'+ex.getMessage()); 
            }       
        } */      
    }
    /**
     * @description - Performing No action here. For Future use if required.  
     * @param Database.BatchableContext batchContext   
     */ 
    global void finish(Database.BatchableContext batchContext){
        if(!(PlanList.isEmpty())){
            try{
                RecursiveTriggerHandler.isFirstTimePlanTriggerBeforeUpdate = false;
                Database.SaveResult[] rest = Database.update(PlanList,false); 
            }catch (Exception ex){
                System.debug('Following exception occurred :'+ex.getMessage()); 
            }       
        }       
        
    }
}