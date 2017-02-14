/****************************************************************************************************************************************************
Name: MDU_ParentAccountHierarchyController 
Description: This class is used as controller for creating Hierarchy for MDU parent account
Author: Ashish Sonawane
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
2 Jun 2015 
***************************************************************************************************************************************************/

public class MDU_ParentAccountHierarchyController{
     
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
    public MDU_ParentAccountHierarchyController(ApexPages.StandardController controller) {
        queryStringAccountId = apexpages.currentpage().getparameters().get(QUERY_STRING_ACCOUNT);                  
    }
    
   /*
    * Fetch all child accounts of parent account and property records of associated child accounts
    */  
    public static List<ParentAccountWrapper> getParentAccountData(){
        List<ParentAccountWrapper> parentAccountWrapperList = new List<ParentAccountWrapper>();  
        Map<Id,Map<Id,String>> accountIdPropIdAssocMap = new  Map<Id,Map<Id,String>>();
        Map<Id,Account> parentIdAccountMap = new Map<Id,Account>(); 
        Map<Id,List<Account>> parntIdChildAccountMap = new Map<Id,List<Account>>(); 
        Map<Id,List<Mdu_Property__c>> childIdPropertyMap = new Map<Id,List<Mdu_Property__c>>();         
        Map<Id,String> propIdOpenOpptyMap = new  Map<Id,String>();
        Set<Id> childAccountIdSet = new Set<Id>();                      
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
        For(Account accountTemp :  [SELECT Id ,Name  FROM Account                                      
                                    WHERE Is_Parent_Organization__c = true AND Id =: queryStringAccountId AND RecordTypeId IN: recordTypeIds
                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ]){ 
            parentIdAccountMap.put(accountTemp.Id,accountTemp);         
        }            
        //If account Id is not parent account id then find parent account for account id in query string  
        if(parentIdAccountMap.keyset().isEmpty()){
            //get Parent account for selected account
            List<Account> parentAccountList = [SELECT Id ,Name, Parent.Id, Parent.Name FROM Account 
                                  WHERE RecordTypeId IN: recordTypeIds AND Is_Parent_Organization__c = false AND Id =: queryStringAccountId
                                  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];                                                       
            if(!parentAccountList.isEmpty()){
                if(parentAccountList[0].Parent != null){
                    parentIdAccountMap.put(parentAccountList[0].Parent.Id, parentAccountList[0].Parent);   
                }                
            }                                                         
        }   
        //select all child account for selected parent account      
        For(Account childAccountTemp : [SELECT Id ,Name, Parent.Id FROM Account 
                                          WHERE RecordTypeId IN: recordTypeIds AND Is_Parent_Organization__c = false AND Parent.Id IN :parentIdAccountMap.keyset() LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                         
            List<Account> tempAccountList = new List<Account>();
            if(parntIdChildAccountMap.containsKey(childAccountTemp.Parent.Id)){
                tempAccountList = parntIdChildAccountMap.get(childAccountTemp.Parent.Id) ;               
            }
            
            tempAccountList.add(childAccountTemp);          
            parntIdChildAccountMap.put(childAccountTemp.Parent.Id, tempAccountList);
            childAccountIdSet.add(childAccountTemp.Id);
        }               
        //Select Property for child account         
        For(Mdu_Property__c propertyTemp : [SELECT Id, Name, Owner_Account__c, Management_Company__c, Developer__c, Address__c,
                                              City__c, MDU_State__c, Number_of_Units__c   
                                              FROM MDU_Property__c 
                                              WHERE (Owner_Account__c IN: childAccountIdSet 
                                              OR Management_Company__c IN: childAccountIdSet
                                              OR Developer__c IN: childAccountIdSet) LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ]){
            //For Owner Account            
            if(childAccountIdSet.contains(propertyTemp.Owner_Account__c)){
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
            if(childAccountIdSet.contains(propertyTemp.Management_Company__c) && propertyTemp.Owner_Account__c != propertyTemp.Management_Company__c){
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
            if(childAccountIdSet.contains(propertyTemp.Developer__c) && (propertyTemp.Management_Company__c != propertyTemp.Developer__c 
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
        //Flush unused set
        childAccountIdSet = null;
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
       
         //Generate ChildAcountPropertyWrapp List data        
        for(Id parentAccntIdTemp : parentIdAccountMap.keySet()){
            ParentAccountWrapper wrapperObject = new ParentAccountWrapper();    
            List<Account> childAccountsList = new List<Account>();
            wrapperObject.parentAccount = parentIdAccountMap.get(parentAccntIdTemp); 
            childAccountsList = parntIdChildAccountMap.get(parentAccntIdTemp); 
            //Grand total for Accounts, Property and Units
            Integer accountCount = 0;   
            Integer propertyCount = 0;  
            Integer unitsCount = 0; 
            //Check for Child account
            if(childAccountsList != null){
                wrapperObject.childAccountList = childAccountsList;
                List<ChildAcountPropertyWrapp> childAcountPropertyWrappList = new List<ChildAcountPropertyWrapp>();
                for(Account childAccountObj : wrapperObject.childAccountList){
                    //Generate wrapper for child
                    Map<Id,String> propIdAssocMap = accountIdPropIdAssocMap.get(childAccountObj.Id);
                    List<Mdu_Property__c> propertyListNew = new List<Mdu_Property__c>(); 
                    propertyListNew = childIdPropertyMap.get(childAccountObj.Id);
                    ChildAcountPropertyWrapp childWrapper = new ChildAcountPropertyWrapp();
                    
                    childWrapper.childPropertyList = new List<ChildPropertyWrapp>();
                    childWrapper.childAccount = childAccountObj;              
                    //Check for property
                    if(propertyListNew != null){
                        Decimal totalInits = 0;                                                                                 
                        //Generate ChildPropertyWrapp list data
                        List<ChildPropertyWrapp> childPropertyWrappList = new List<ChildPropertyWrapp>();
                        for(Mdu_Property__c propertyObj :  propertyListNew){
                            ChildPropertyWrapp childPropWrap = new ChildPropertyWrapp();
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
                        childWrapper.childPropertyList.addAll(childPropertyWrappList);                       
                        childWrapper.totalProperty = propertyListNew.size().format();
                        childWrapper.totalUnits = Integer.valueOf(totalInits).format();
                        unitsCount += Integer.valueOf(totalInits);
                        propertyCount += propertyListNew.size();
                    } 
                    childAcountPropertyWrappList.add(childWrapper);  
                    accountCount ++;    
                }
                wrapperObject.childAccountWrapperList = childAcountPropertyWrappList;  
                wrapperObject.accountGrandTotal = accountCount.format();
                wrapperObject.propertyGrandTotal = propertyCount.format();
                wrapperObject.unitsGrandTotal = unitsCount.format();
            }           
           
            parentAccountWrapperList.add(wrapperObject);
        }        
        return parentAccountWrapperList;       
    }
    
   /*
    * Wrapper class holding Account, Property details
    */
    public class ParentAccountWrapper{
        public Account parentAccount{get;set;}      
        public List<Account> childAccountList{get;set;}       
        public List<ChildAcountPropertyWrapp> childAccountWrapperList{get;set;}      
        public String accountGrandTotal {get;set;}
        public String propertyGrandTotal {get;set;}
        public String unitsGrandTotal {get;set;}
    }
    
    /*
    * Wrapper class holding child Account and child Property details
    */
    public class ChildAcountPropertyWrapp{
            public Account childAccount {get;set;}
            public List<ChildPropertyWrapp> childPropertyList{get;set;}
            public String totalProperty {get;set;}
            public String totalUnits {get;set;}
    }
    
   /*
    * Wrapper class holding property record and Association(Account) string for that property, we are adding Association as extra field on VF page
    */
    public class ChildPropertyWrapp{
        public Mdu_Property__c property{get;set;}
        public string opptyOwner{get;set;}
        public string opptyStage{get;set;}
        public List<Contract__c> contractList{get;set;}
        public string association{get;set;}
    }
    
  

      
}