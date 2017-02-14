/****************************************************************************************************************************************************
Name: MDU_PortfolioAccountHierarchyController
Description: This class is used as controller for creating property hierarchy of account
Author: Ashish Sonawane
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
2 Jun 2015 
***************************************************************************************************************************************************/

public class MDU_PortfolioAccountHierarchyController{
     
   /*
    * Data Member
    */     
    private static final string RECORD_TYPE_SEPERATION = ';';
    private static final string QUERY_STRING_ACCOUNT = 'AccountId'; 
    public static string queryStringAccountId{get;set;}
    private static final string OWNER_ASSOC = 'Owner';
    private static final string MANAGEMENT_ASSOC = 'Management Co.';
    private static final string DEVELOPER_ASSOC = 'Developer';
    private static final string EMPTY_STRING = '';
    private static final string OPPTY_OWNER_STAGE_SEPARATER = '##';
    private static Set<String> closeOpptySaleStageSet = new Set<String>{'Closed Won', 'Closed Lost'}; 
    private static final string ASSOCIATION_SEP = ', ';
    private static final string PORTFOLIO_ONLY = 'true';
    private static string portfolio = '';
         
   
   /*
    * Class constructor 
    */
    public MDU_PortfolioAccountHierarchyController(ApexPages.StandardController controller) {
        queryStringAccountId = apexpages.currentpage().getparameters().get(QUERY_STRING_ACCOUNT);                  
    }
    
   /*
    * Fetch accounts and property records of associated accounts
    */  
    public static AccountPropertyWrapp getAccountData(){
        
        Map<Id,Map<Id,String>> accountIdPropIdAssocMap = new  Map<Id,Map<Id,String>>();
        Map<Id,Account> parentIdAccountMap = new Map<Id,Account>();         
        Map<Id,List<Mdu_Property__c>> childIdPropertyMap = new Map<Id,List<Mdu_Property__c>>();         
        Map<Id,String> propIdOpenOpptyMap = new  Map<Id,String>();                          
        Set<Id> recordTypeIds = new Set<Id>();  
        Set<Id> proeprtyIdSet = new Set<Id>();  
        Map<Id,List<Contract__c>> propIdContractMap = new Map<Id,List<Contract__c>>();
        String labelName = System.Label.XfinityAccountRecordType;                          
                                       
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(RECORD_TYPE_SEPERATION)){
                recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }    
             
        //Check for account Id in query string is parent account id
        Account accountTemp =  [SELECT Id ,Name  FROM Account  
                                    WHERE   Id =: queryStringAccountId AND RecordTypeId IN: recordTypeIds
                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ];
        parentIdAccountMap.put(accountTemp.Id,accountTemp);         
                         
        //Select Property for selected account         
        For(Mdu_Property__c propertyTemp : [SELECT Id, Name, Owner_Account__c, Management_Company__c, Developer__c, Address__c,
                                              City__c, MDU_State__c, Number_of_Units__c   FROM MDU_Property__c 
                                               WHERE (Owner_Account__c IN: parentIdAccountMap.keyset() OR Management_Company__c IN: parentIdAccountMap.keyset()                                                                     
                                              OR Developer__c IN: parentIdAccountMap.keyset()) LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ]){
            //For Owner Account            
            if(parentIdAccountMap.keySet().contains(propertyTemp.Owner_Account__c)){
                List<Mdu_Property__c> tempOwnerAcntPropertyList = new List<Mdu_Property__c>();
                if(childIdPropertyMap.containsKey(propertyTemp.Owner_Account__c)){
                    tempOwnerAcntPropertyList = childIdPropertyMap.get(propertyTemp.Owner_Account__c);  
                    tempOwnerAcntPropertyList.add(propertyTemp);
                }else if(propertyTemp.Owner_Account__c != null){
                    tempOwnerAcntPropertyList.add(propertyTemp);
                }
                if(!tempOwnerAcntPropertyList.isEmpty()){                   
                    childIdPropertyMap.put(propertyTemp.Owner_Account__c, tempOwnerAcntPropertyList);                       
                    Map<Id,String> propertyIdAssocMap = new Map<Id,String>();
                    if(accountIdPropIdAssocMap.containsKey(propertyTemp.Owner_Account__c)){
                        propertyIdAssocMap = accountIdPropIdAssocMap.get(propertyTemp.Owner_Account__c);                        
                    }
                    propertyIdAssocMap.put(propertyTemp.Id,OWNER_ASSOC);
                    accountIdPropIdAssocMap.put(propertyTemp.Owner_Account__c,propertyIdAssocMap);      
                }            
            }
                        
            //For Management Company Account   
            if(parentIdAccountMap.keySet().contains(propertyTemp.Management_Company__c) && propertyTemp.Owner_Account__c != propertyTemp.Management_Company__c){
                List<Mdu_Property__c> tempMangAcntPropertyList = new List<Mdu_Property__c>();
                if(childIdPropertyMap.containsKey(propertyTemp.Management_Company__c)){
                    tempMangAcntPropertyList = childIdPropertyMap.get(propertyTemp.Management_Company__c);  
                    tempMangAcntPropertyList.add(propertyTemp);
                }else if(propertyTemp.Management_Company__c != null){
                    tempMangAcntPropertyList.add(propertyTemp);
                }
                if(!tempMangAcntPropertyList.isEmpty()){                    
                    childIdPropertyMap.put(propertyTemp.Management_Company__c, tempMangAcntPropertyList);
                    Map<Id,String> propertyIdAssocMap = new Map<Id,String>();
                    if(accountIdPropIdAssocMap.containsKey(propertyTemp.Management_Company__c)){
                        propertyIdAssocMap = accountIdPropIdAssocMap.get(propertyTemp.Management_Company__c);   
                    }
                    propertyIdAssocMap.put(propertyTemp.Id,MANAGEMENT_ASSOC);
                    accountIdPropIdAssocMap.put(propertyTemp.Management_Company__c,propertyIdAssocMap);                    
                }
            }else{
                if(propertyTemp.Management_Company__c != null){                   
                    Map<Id,String> propertyIdAssoc = new  Map<Id,String>();
                    propertyIdAssoc.put(propertyTemp.Id,OWNER_ASSOC+ASSOCIATION_SEP+MANAGEMENT_ASSOC);
                    accountIdPropIdAssocMap.put(propertyTemp.Management_Company__c,propertyIdAssoc);                                 
                }                               
            }   
                                  
            //For Developer Company Account    
            if(parentIdAccountMap.keySet().contains(propertyTemp.Developer__c) && (propertyTemp.Management_Company__c != propertyTemp.Developer__c 
            && propertyTemp.Owner_Account__c != propertyTemp.Developer__c)){                
                List<Mdu_Property__c> tempDeveloperAcntPropertyList = new List<Mdu_Property__c>();
                if(childIdPropertyMap.containsKey(propertyTemp.Developer__c)){
                    tempDeveloperAcntPropertyList = childIdPropertyMap.get(propertyTemp.Developer__c);  
                    tempDeveloperAcntPropertyList.add(propertyTemp);
                }else if(propertyTemp.Developer__c != null){
                    tempDeveloperAcntPropertyList.add(propertyTemp);
                }
                if(!tempDeveloperAcntPropertyList.isEmpty()){
                    Map<Id,String> propertyIdAssocMap = new Map<Id,String>();
                    childIdPropertyMap.put(propertyTemp.Developer__c, tempDeveloperAcntPropertyList);
                    if(accountIdPropIdAssocMap.containsKey(propertyTemp.Developer__c)){
                        propertyIdAssocMap = accountIdPropIdAssocMap.get(propertyTemp.Developer__c);    
                    }
                    propertyIdAssocMap.put(propertyTemp.Id,DEVELOPER_ASSOC);
                    accountIdPropIdAssocMap.put(propertyTemp.Developer__c,propertyIdAssocMap);                
                }
            }else{      
                if(propertyTemp.Developer__c != null){
                    String associate = EMPTY_STRING;
                    Map<Id,String> propertyIdAssoc = new  Map<Id,String>();
                    //check for same account set to three owner, management comp, developer comp
                    if(propertyTemp.Developer__c == propertyTemp.Owner_Account__c && propertyTemp.Developer__c == propertyTemp.Management_Company__c){
                        associate = OWNER_ASSOC+ASSOCIATION_SEP+MANAGEMENT_ASSOC+ASSOCIATION_SEP+DEVELOPER_ASSOC;
                    }//check whether Developer and Manage Comp have same account type
                    else if(propertyTemp.Management_Company__c == propertyTemp.Developer__c){
                        associate = MANAGEMENT_ASSOC+ASSOCIATION_SEP+DEVELOPER_ASSOC;
                    }//check whether Developer and Owner have same account type
                    else if(propertyTemp.Owner_Account__c == propertyTemp.Developer__c){
                        associate = OWNER_ASSOC+ASSOCIATION_SEP+DEVELOPER_ASSOC;
                    }                   
                    propertyIdAssoc.put(propertyTemp.Id,associate);
                    accountIdPropIdAssocMap.put(propertyTemp.Developer__c,propertyIdAssoc); 
                }
                
            }    
            proeprtyIdSet.add(propertyTemp.Id);       
        }             
        //Generate property Id and its Contract List Map            
        for(Contract__c contractObj : [Select Id, Expiration_Date__c, Contract_Type__c, Name, Property__c,
                                        Contract_Term__c, Contract_Term_Unit__c 
                                        FROM Contract__c WHERE Archived__c = false AND Property__c IN: proeprtyIdSet LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ]){
            List<Contract__c> contractList = new List<Contract__c>();
            if(propIdContractMap.containsKey(contractObj.Property__c)){
                contractList = propIdContractMap.get(contractObj.Property__c);
            }
            contractList.add(contractObj);
            propIdContractMap.put(contractObj.Property__c,contractList);
        }   
       
        //Generate Property and open opportunity stage, owner details           
        for(MDU_Property__c propertyObject : [SELECT Id, (SELECT Id,Property__C,Opportunity__c, Opportunity__r.Owner.Name , Opportunity__r.StageName FROM Opportunity_Properties__r 
                                  WHERE Opportunity__r.StageName NOT IN : closeOpptySaleStageSet ) 
                                  FROM MDU_Property__c  WHERE ID IN : proeprtyIdSet LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            if(!propertyObject.Opportunity_Properties__r.isEmpty()){                                        
                propIdOpenOpptyMap.put(propertyObject.Id, propertyObject.Opportunity_Properties__r[0].Opportunity__r.Owner.Name +OPPTY_OWNER_STAGE_SEPARATER+ propertyObject.Opportunity_Properties__r[0].Opportunity__r.StageName);
            }
        } 
        
        proeprtyIdSet = null;   
        //Generate wrapper for account
        Account accountObj =  parentIdAccountMap.get(queryStringAccountId); 
        Map<Id,String> propIdAssocMap = accountIdPropIdAssocMap.get(accountObj.Id);
        List<Mdu_Property__c> propertyListNew = new List<Mdu_Property__c>(); 
        propertyListNew = childIdPropertyMap.get(accountObj.Id);
        AccountPropertyWrapp accountPropWrapper = new AccountPropertyWrapp();
        accountPropWrapper.childPropertyList = new List<PropertyWrapp>();
        accountPropWrapper.account = accountObj;              
        //Check for property
        if(propertyListNew != null){
            Decimal totalInits = 0;                                                                                 
            //Generate PropertyWrapp list data
            List<PropertyWrapp> childPropertyWrappList = new List<PropertyWrapp>();
            for(Mdu_Property__c propertyObj :  propertyListNew){
                PropertyWrapp childPropWrap = new PropertyWrapp();
                if(propIdOpenOpptyMap.containsKey(propertyObj.Id)){
                    String opptyOwnerName = propIdOpenOpptyMap.get(propertyObj.Id);
                    List<String> ownerStageList = opptyOwnerName.split(OPPTY_OWNER_STAGE_SEPARATER);
                    childPropWrap.opptyOwner = ownerStageList[0];
                    childPropWrap.opptyStage = ownerStageList[1];
                }                         
                
                List<Contract__c> contractList = new  List<Contract__c>();                                
                if(propIdContractMap.get(propertyObj.Id) != null){                                                             
                    List<Contract__c> propContractList = propIdContractMap.get(propertyObj.Id);                                
                    childPropWrap.contractList = propContractList;
                }
                String assoc = propIdAssocMap.get(propertyObj.Id);
                childPropWrap.property = propertyObj;
                childPropWrap.association = assoc;
                if(propertyObj.Number_of_Units__c != null){
                    totalInits += propertyObj.Number_of_Units__c ;
                }
                childPropertyWrappList.add(childPropWrap);      
            }                         
            accountPropWrapper.childPropertyList.addAll(childPropertyWrappList);                       
            accountPropWrapper.totalProperty = propertyListNew.size().format();
            accountPropWrapper.totalUnits = Integer.valueOf(totalInits).format();
            
        }                                                       
        return accountPropWrapper;       
    }
    
    
    /*
    * Wrapper class holding Account and child Property details
    */
    public class AccountPropertyWrapp{
            public Account account {get;set;}
            public List<PropertyWrapp> childPropertyList{get;set;}
            public String totalProperty {get;set;}
            public String totalUnits {get;set;}
    }
    
   /*
    * Wrapper class holding property record and Association(Account) string for that property, we are adding Association as extra field on VF page
    */
    public class PropertyWrapp{
        public Mdu_Property__c property{get;set;}
        public string opptyOwner{get;set;}
        public string opptyStage{get;set;}
        public List<Contract__c> contractList{get;set;}
        public string association{get;set;}
    }
    
  

      
}