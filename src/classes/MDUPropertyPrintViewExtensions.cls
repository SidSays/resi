/**************************************************************************************************
Name : MDUPropertyPrintViewExtensions
Description : This page will display the printable view for Property based on the contract IDs 
User Story : 
Date : 19 January 2015
Author : Accenture
***************************************************************************************************/
public with sharing class MDUPropertyPrintViewExtensions{
    
    public static Map<String, Schema.SobjectType> schemaMap = Schema.getGlobalDescribe();
    public MDU_Property__c property{get;set;}
    public List<Contract__c> contractList{get;set;}
    public List<Courtsey_Account__c> courtseyAccountList{get;set;}
    public List<Recorded_Instrument__c> recordedInstrumentList{get;set;}
    Public Service_Change__c currentServiceChange{get;set;}     
    public Contact propertyOwner {get;set;}
    public Contact propertyManagementCompany {get;set;}
    public Contact propertyDeveloper {get;set;}
    
    
    public Account propertyOwnerAcc {get;set;}
    public Account propertyManagementCompanyAcc {get;set;}
    public Account propertyDeveloperAcc {get;set;}
    public List<Task> taskInfolist {get;set;}
    
    private static final string DEFAULT_DATE_FORMAT = 'MM/dd/yyyy hh:mm a';
    private static final string CONTRACT_ID_STRING = 'contractID';
    private static final string PROPERTY_STRING = 'MDU_Property__c';
    private static final string CONTRACT_STRING = 'Contract__c';
    private static final string DOOR_FEE = 'Door';
    private static final string RECURRING_FEE = 'Recurring';
    private static final string INCENTIVE_FEE = 'Incentive';
    private static final string PROPERTY_FEES = 'Property_Fees__c';
    private static final string REPLACEMENT_STRING = 'xxx';
    private static final string ACCOUNT_PROP_VAR = 'accountProperty';
    private static final string ACCOUNT_OBJECT = 'Account';
    private static final string RECO_INSTRUMENT_OBJ = 'Recorded_Instrument__c';
    private static final string SET_CONTRACT_TEMP_VAR = 'setContractIdTemp';
    private static final string SET_CONTRACT_ID_VAR = 'setContractId';
    private static final string CONTACT_OBJECT = 'Contact';
    private static final string MDU_PROP_OBJECT = 'MDU_Property';
    private static final string CONTACT_PROP_VAR = 'contactProperty';
    private static final string SERVICE_CHANGES_OBJECT = 'Service_Change__c';
    private static final string COURTESY_ACCOUNT_OBJ = 'Courtsey_Account__c';
    private static final string SELECT_QRY = 'select Id';
    private static final string FROM_CONST = ' from ';
    private static final string QUERY_STRING = ',Owner_Account__r.Name, Management_Company__r.Name, Developer__r.Name';
    private static final string WHERE_CLAUSE = ' where (';
    private static final string IN_CLAUSE = ' IN: xxx ';
    private static final string END_QUERY = ' )';
    private static final string WHERE2_CLAUSE = ' where ';
    private static final string IN_CLAUSE_CONST = ' IN: xxx';
    private static final string ORDER_BY_CLAUSE = ' ORDER BY Id DESC';
    private static final string COMMA_SEPARATER = ',';
    private static final string QUIT_CONST = '= \'';
    private static final string QUIT_END_CONST = '\'';
    private static final string PROPERTY_FIELD = 'Property__c';
    private static final string EMPTY_STRING = '';
    private static final string ID_COMPARE_FIELD = 'Id';
    private static final string ID_QUERYSTR_FIELD = 'id';
    public Datetime CurrentDate { get { return Datetime.Now(); }}
    public String currDate{get { return  CurrentDate.format(DEFAULT_DATE_FORMAT); }}   
     
    // Wrapper Class for Contract
    Public List<wrapperContract> wrapperContractList{get;set;}
    // define Controller 
    private ApexPages.StandardController controller = null;
     
     
    /* Constructor to initialise controller object */
    public MduPropertyPrintViewExtensions(ApexPages.StandardController controller) {     
        this.controller = controller;  
        //Initializing all the properties 
        property = new MDU_Property__c();
        contractList = new List<Contract__c>();
        courtseyAccountList = new List<Courtsey_Account__c>();
        recordedInstrumentList =  new List<Recorded_Instrument__c>();
        currentServiceChange = new Service_Change__c();
        propertyOwner = new Contact();
        propertyManagementCompany = new Contact();
        propertyDeveloper = new Contact();
        taskInfolist = new List<Task>();
        
        propertyOwnerAcc = new Account();
        propertyManagementCompanyAcc = new Account();
        propertyDeveloperAcc = new Account();
        
        wrapperContractList = new  List<wrapperContract>();

        //Variables
        String propertyID = apexpages.currentpage().getparameters().get(ID_QUERYSTR_FIELD);  
        String contractID = apexpages.currentpage().getparameters().get(CONTRACT_ID_STRING);  
        if(propertyID != Null){        
            fetchPropertyDetails(propertyID, contractID);
        } 
    }  
     
    /* Constructor to initialise controller object */
    /**
        *@Name:fetchPropertyDetails
        *@Description: Initializing the properties for given record ID 
        *@params : String propertyID, String contractID
        *@return type : NA
    **/
    public void fetchPropertyDetails(String propertyID, String contractID){
        String propertyQuery = generateSelectAllQuery(PROPERTY_STRING, ID_QUERYSTR_FIELD, propertyID);
        List<Service_Change__c> serviceChangeList = new List<Service_Change__c>();
        List<MDU_Property__c> propertyList = Database.query(propertyQuery);
        property = propertyList[0];
        string[] contractIdList = new string[]{};
        Map<Id, List<Contracted_Bulk_Service__c>> mapContractBulkServices = new Map<Id, List<Contracted_Bulk_Service__c>>();
        Map<Id, List<Property_Fees__c>> mapPropertyFeeDoorFee = new Map<Id, List<Property_Fees__c>>();
        Map<Id, List<Property_Fees__c>> mapPropertyFeeIncentiveFee = new Map<Id, List<Property_Fees__c>>();
        Map<Id, List<Property_Fees__c>> mapPropertyFeeRecurringFee = new Map<Id, List<Property_Fees__c>>();
        
        
        //Data Retrival Logic
        if(!string.isBlank(contractID)){
          contractIdList = contractID.split(COMMA_SEPARATER);
        }
        set<id> setContractIdTemp = new set<Id>();
        for(string temId:contractIdList){
            setContractIdTemp.add(temId);
        }
        String contractQuery = EMPTY_STRING;//generateSelectAllQuery('Contract', PROPERTY_FIELD, propertyID);
        
        if(!string.isBlank(contractID)){           
            contractQuery = generateSelectAllQuerySet(CONTRACT_STRING, ID_COMPARE_FIELD, setContractIdTemp, EMPTY_STRING);
            contractList = Database.query(contractQuery.replace(REPLACEMENT_STRING, SET_CONTRACT_TEMP_VAR));                     
        }
        else{            
            contractQuery = generateSelectAllQuery(CONTRACT_STRING, PROPERTY_FIELD, propertyID);
            contractList = Database.query(contractQuery);            
        }                                      
        if(! contractList.isEMpty())
        {
            set<id> setContractId = new set<Id>();

            for(Contract__c  contractTemp:contractList){
                setContractId.add(contractTemp.Id);
            }

            List<Contracted_Bulk_Service__c> bulkServiceList = [Select Service_Type__c, Rate_Per_Unit__c, Units__c, Service_Total__c, Contract__c from Contracted_Bulk_Service__c  where Contract__c  In: setContractId];
            for(Contracted_Bulk_Service__c bulkservice:bulkServiceList){
                List<Contracted_Bulk_Service__c> tempBulkServiceList = new  List<Contracted_Bulk_Service__c>();
                if(mapContractBulkServices.containsKey(bulkservice.Contract__c)){
                    tempBulkServiceList = mapContractBulkServices.get(bulkservice.Contract__c);
                }
                tempBulkServiceList.add(bulkservice);
                mapContractBulkServices.put(bulkservice.Contract__c, tempBulkServiceList);
            }

            List<Property_Fees__c> propertyFeeList = new List<Property_Fees__c>();
            String propertyFeeQuery = generateSelectAllQuerySet(PROPERTY_FEES, CONTRACT_STRING, setContractId, EMPTY_STRING);
            propertyFeeList = Database.query(propertyFeeQuery.replace(REPLACEMENT_STRING, SET_CONTRACT_ID_VAR));
            
            for(Property_Fees__c propertyFee:propertyFeeList){
                List<Property_Fees__c> tempPropertyFee = new  List<Property_Fees__c>();
                if(propertyFee.Type__c.containsIgnoreCase(DOOR_FEE)){
                    if(mapPropertyFeeDoorFee.get(propertyFee.Contract__c) != Null){
                        tempPropertyFee = mapPropertyFeeDoorFee.get(propertyFee.Contract__c);
                    }
                    tempPropertyFee.add(propertyFee);
                    mapPropertyFeeDoorFee.put(propertyFee.Contract__c, tempPropertyFee);
                }
                else if(propertyFee.Type__c.containsIgnoreCase(RECURRING_FEE)){
                    if(mapPropertyFeeRecurringFee.get(propertyFee.Contract__c) != Null){
                        tempPropertyFee = mapPropertyFeeRecurringFee.get(propertyFee.Contract__c);
                    }
                    tempPropertyFee.add(propertyFee);
                    mapPropertyFeeRecurringFee.put(propertyFee.Contract__c, tempPropertyFee);
                }
                else if(propertyFee.Type__c.containsIgnoreCase(INCENTIVE_FEE)){
                    if(mapPropertyFeeIncentiveFee.get(propertyFee.Contract__c) != Null){
                        tempPropertyFee = mapPropertyFeeIncentiveFee.get(propertyFee.Contract__c);
                    }
                    tempPropertyFee.add(propertyFee);
                    mapPropertyFeeIncentiveFee.put(propertyFee.Contract__c, tempPropertyFee);
                }

            }
            
        }
        List<wrapperContract> wrapperContractListTemp = new  List<wrapperContract>();
        for(Contract__c contractTemp : contractList){
            wrapperContract tempwrapperContract = new wrapperContract();
            tempwrapperContract.contractValue = contractTemp;
            if(mapContractBulkServices.containsKey(contractTemp.Id)){
                tempwrapperContract.bulkServicesList =  mapContractBulkServices.get(contractTemp.Id);
            }
            if(mapPropertyFeeIncentiveFee.containsKey(contractTemp.Id)){
                tempwrapperContract.propertyIncentive =  mapPropertyFeeIncentiveFee.get(contractTemp.Id);
            }

            if(mapPropertyFeeDoorFee.containsKey(contractTemp.Id)){
                tempwrapperContract.propertyFeeDoor =  mapPropertyFeeDoorFee.get(contractTemp.Id);
            }

            if(mapPropertyFeeRecurringFee.containsKey(contractTemp.Id)){
                tempwrapperContract.propertyRecurring =  mapPropertyFeeRecurringFee.get(contractTemp.Id);
            }

            wrapperContractListTemp.add(tempwrapperContract);
        }
          



        wrapperContractList = wrapperContractListTemp;
        
        String riQuery = generateSelectAllQuery(RECO_INSTRUMENT_OBJ, PROPERTY_FIELD, propertyID);
        recordedInstrumentList = Database.query(riQuery );

        Set<id> accountProperty = new Set<id>();
        accountProperty.add(property.Owner_Account__c);
        accountProperty.add(property.Developer__c);
        accountProperty.add(property.Management_Company__c);
          
        
        List<Account> accountList = new List<Account>();
        String AccountQuery = generateSelectAllQuerySet(ACCOUNT_OBJECT, ID_COMPARE_FIELD, accountProperty, propertyID);

        accountList = Database.query(AccountQuery.replace(REPLACEMENT_STRING, ACCOUNT_PROP_VAR));
           
        for(Account accTemp:accountList){
            if(accTemp.ID  == property.Owner_Account__c){
                propertyOwnerAcc = accTemp;
            }
            if(accTemp.ID  == property.Developer__c){
                propertyDeveloperAcc  = accTemp;
            }
            if(accTemp.ID == property.Management_Company__c){
                propertyManagementCompanyAcc  = accTemp;
            }            
        }
         
        Set<id> contactProperty = new Set<id>();        
        contactProperty.add(property.Contact_Owner__c);
        contactProperty.add(property.Contact_Management_Company__c);
        contactProperty.add(property.Contact_Developer__c);
        List<Contact> contactList = new List<Contact>();
        if(!contactProperty.isEmpty()){
            String contactQuery = generateSelectAllQuerySet(CONTACT_OBJECT, ID_COMPARE_FIELD, contactProperty, propertyID);                                
            contactList = Database.query(contactQuery.replace(REPLACEMENT_STRING, CONTACT_PROP_VAR));           
           
            for(Contact contactTemp:contactList){
                if(contactTemp.Id  == property.Contact_Owner__c){
                    propertyOwner = contactTemp;
                }
                if(contactTemp.Id  == property.Contact_Management_Company__c){
                    propertyManagementCompany  = contactTemp;
                }
                if(contactTemp.Id == property.Contact_Developer__c){
                    propertyDeveloper = contactTemp;
                }
                
            }
        }
        else{
            //TBD
        }
        String serviceChangeQuery = generateSelectAllQuery(SERVICE_CHANGES_OBJECT, PROPERTY_FIELD, propertyID);
        serviceChangeQuery  = serviceChangeQuery + ORDER_BY_CLAUSE;
        serviceChangeList = Database.query(serviceChangeQuery);

        if(!serviceChangeList.isEmpty()){
            currentServiceChange = serviceChangeList[0];
        }

        String courtseyAccountQuery = generateSelectAllQuery(COURTESY_ACCOUNT_OBJ, PROPERTY_FIELD, propertyID);
        courtseyAccountList = Database.query(courtseyAccountQuery);

        taskInfolist  = [Select Id, Status, Owner.Name , Description, CreatedDate from Task where WhatId =: propertyID];
    }
    
    /**
        *@Name:generateSelectAllQuery
        *@Description: Generate Select all query for a give Sobject
        *@params : String objectName, String fieldName, String sourceId
        *@return type : String
    **/
    public String generateSelectAllQuery(String objectName, String fieldName, String sourceId) {               
        String query = SELECT_QRY;
        for(Schema.SObjectField field : schemaMap.get(objectName).getDescribe().fields.getMap().values()) {
            if(!ID_COMPARE_FIELD.equalsIgnoreCase(field.getDescribe().getName())){
                query += COMMA_SEPARATER + field.getDescribe().getName();//Add field names to query            
            }
        }
        if(objectName.containsIgnoreCase(MDU_PROP_OBJECT)){
            query += QUERY_STRING;
        }
        query += FROM_CONST + objectName + WHERE2_CLAUSE + fieldName + QUIT_CONST + sourceId + QUIT_END_CONST;              
        return query;
    }
    
    /**
        *@Name:generateSelectAllQuerySet
        *@Description: Generate Select all query for a give Sobject with Set<> in where clause
        *@params : String objectName, String fieldName, Set<Id> sourceIdSet, string sourceId
        *@return type : String
    **/
    public static String generateSelectAllQuerySet(String objectName, String fieldName, Set<Id> sourceIdSet, string sourceId) {
        String query = SELECT_QRY;
        for(Schema.SObjectField field : schemaMap.get(objectName).getDescribe().fields.getMap().values()) {
           if(!ID_COMPARE_FIELD.equalsIgnoreCase(field.getDescribe().getName())){
                query += COMMA_SEPARATER + field.getDescribe().getName();//Add field names to query
            }
        }  
        if(objectName.containsIgnoreCase(CONTACT_OBJECT)){
            query += FROM_CONST + objectName + WHERE_CLAUSE + fieldName + IN_CLAUSE +' '+ END_QUERY;
        }
        else {
            query += FROM_CONST + objectName + WHERE2_CLAUSE + fieldName + IN_CLAUSE_CONST;   
        }
        return query;
    }

    /**
        *@Name:wrapperContract
        *@Description: Wrapper class to load information of Contract and Related Lists
        *@params : NA
        *@return type : NA
    **/
    public class wrapperContract{
        public Contract__c  contractValue{get;set;}
        public List<Contracted_Bulk_Service__c> bulkServicesList{get;set;}
        public List<Property_Fees__c> propertyFeeDoor{get;set;}
        public List<Property_Fees__c> propertyRecurring{get;set;}
        public List<Property_Fees__c> propertyIncentive{get;set;}
    }

}