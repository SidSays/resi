/**
 * Helper class for Account trigger to delete store visits associated to a Store when
 * the Account object is deleted
 *
 * @Author Ryan Sayles <rsayles@acumensolutions.com>
 * @Date 9/26/14
 * Updated By: Animesh Datta, Date - 3-Nov-2016, Method - endActiveStoreVisitOwnerChage, mark active store visit as completed if store owner is changed.
 */
/*
* MDU Implementation - Method added to accommodate Parent Account assignment functionality.
* Method added to validate the access to modify the parent account.
*/
public with sharing class AccountTriggerHelper {
    
    /* String - PARENT */
    private static final String PARENT_NM = ' [PARENT]';
    private static final string LABEL_NAME_SPLIT = ';';
    /* 
    * deleteRelatedStoreVisits call
    */
    public static void deleteRelatedStoreVisits(Map<Id, Account> triggerOldMap) {
        Set<Id> storeIds = new Set<Id>();
        Set<String> recordTypeSet = getAllAccountRecordTypes();
        if(triggerOldMap != null){
            for(Id accountId : triggerOldMap.keySet()){
                Account acc= triggerOldMap.get(accountId);
                if(!recordTypeSet.isEmpty() && recordTypeSet.contains(acc.RecordTypeId)){
                    if(acc.type != null && acc.type.equalsIgnoreCase('Store')){
                        storeIds.add(accountId);
                    }
                }
            }
        }
        if(storeIds.size() > 0) delete getStoreVisits(storeIds);
    }

    /* getStoreVisits call*/
    public static List<Store_Visit__c> getStoreVisits(Set<Id> storeIds) {
        return new List<Store_Visit__c>([
            SELECT Id
            FROM Store_Visit__c
            WHERE Store__c IN: storeIds]);
    }
    
    /*
    *  Add [PARENT] to the Parent account Name on creation.
    */
    public static void suffixParentAccountName(List<Account> triggerNew){
        Set<String> recordTypeIdSet = getAccountRecordType();
        for(Account acc: triggerNew){
            if(!recordTypeIdSet.isEmpty() && recordTypeIdSet.contains(acc.RecordTypeId)){
                if(acc.Is_Parent_Organization__c){
                    acc.Name = acc.Name + PARENT_NM;
                }
            }
        }
    }
    
    
    /*
    *  Assign Parent Account based on selected Parent picklist value
    */
    public static void assignParentBeforeInsert(List<Account> triggerNew){
        
        Set<String> parentAccountSelectSet = new Set<String>();
        String labelName = System.Label.XfinityAccountRecordType;  
        Set<String> recordTypeIdSet = getAccountRecordType(); 
        
        if(Trigger.isBefore && Trigger.isInsert){   
            for(Account acc: TriggerNew){
                if(!recordTypeIdSet.isEmpty() && recordTypeIdSet.contains(acc.RecordTypeId)){
                    if(acc.ParentId!=null){
                        acc.addError(System.Label.ParentAccountAssignErr);
                    } else if(acc.ParentAccountSelection__c!=null){
                        parentAccountSelectSet.add(acc.ParentAccountSelection__c);           
                    }
                }
            }
        }
        if(!parentAccountSelectSet.isEmpty()){
            parentAccountAssignment(parentAccountSelectSet, triggerNew);
        }
    }
    
    
    
    /*
    *  Update Parent Account based on selected Parent picklist value
    */
    public static void assignParentBeforeUpdate(List<Account> triggerNew, Map<Id, Account> triggerOldMap){
        Set<String> parentAccountSelectSet = new Set<String>();
        Set<String> recordTypeIdSet = getAccountRecordType();
        
        for(Account acc: TriggerNew){ 
            if(!recordTypeIdSet.isEmpty() && recordTypeIdSet.contains(acc.RecordTypeId)){
                if(acc.Is_Parent_Organization__c && acc.Name!=triggerOldMap.get(acc.Id).Name && !acc.Name.contains(PARENT_NM)){
                    acc.Name = acc.Name+PARENT_NM;
                }
                if(acc.Is_Parent_Organization__c && acc.Is_Parent_Organization__c!=triggerOldMap.get(acc.Id).Is_Parent_Organization__c && !acc.Name.contains(PARENT_NM)){
                    acc.Name = acc.Name+PARENT_NM;
                }
                if(acc.ParentId!=null && acc.ParentId!= triggerOldMap.get(acc.Id).ParentId){
                    acc.addError(System.Label.ParentAccountAssignErr);
                } else if(acc.ParentAccountSelection__c!=null && acc.ParentAccountSelection__c!= triggerOldMap.get(acc.Id).ParentAccountSelection__c){
                    parentAccountSelectSet.add(acc.ParentAccountSelection__c);           
                } else if(acc.ParentAccountSelection__c==null){
                    acc.ParentId= null;
                } else if(acc.ParentId==null && acc.ParentId!= triggerOldMap.get(acc.Id).ParentId && acc.ParentAccountSelection__c!=null){
                    parentAccountSelectSet.add(acc.ParentAccountSelection__c);
                }
            } 
        }
        if(!parentAccountSelectSet.isEmpty()){
            parentAccountAssignment(parentAccountSelectSet, triggerNew);
        }
    }
    
    /*
    * Assign Parent account call
    */
    @TestVisible
    private static void parentAccountAssignment(Set<String> parentAccountSelectSet, List<Account> triggerNew){
        
        if(!parentAccountSelectSet.isEmpty()){
            Map<String, Id> accMap = new Map<String, Id>();
            for(Account accObj:  [Select Id, Name, Is_Parent_Organization__c from Account where Name IN: parentAccountSelectSet AND Is_Parent_Organization__c=true ]){
                accMap.put(accObj.Name, accObj.Id);
            }
            
            for(Account a: triggerNew){
                if(a.ParentAccountSelection__c!=null && accMap.get(a.ParentAccountSelection__c)!=null){
                    a.ParentId = accMap.get(a.ParentAccountSelection__c);
                } else{
                    a.addError(System.Label.ParentAccountDoesNotExists);
                }
            }
        } 
    }
    
    /*
    *  Validate Parent Account update access
    */
    public static void validateAccessBeforeUpdate(List<Account> triggerNew, Map<Id, Account> triggerOldMap){
        
        Set<String> recordTypeIdSet = getAccountRecordType();
        boolean bypassValidation=false;
        /* For all other users- They should not be able to make any changes to account */
        if((MDU_AllowParentAccChange__c.getValues(UserInfo.getProfileId()) != null && MDU_AllowParentAccChange__c.getValues(UserInfo.getProfileId()).Disable_Validation__c) || (MDU_AllowParentAccChange__c.getValues(UserInfo.getUserId()) != null && MDU_AllowParentAccChange__c.getValues(UserInfo.getUserId()).Disable_Validation__c)){
            bypassValidation = true;
        }
        
        if(!bypassValidation){
        Map<String, Schema.SobjectField> accFieldMap = Schema.SObjectType.Account.fields.getMap();
            for (Account accObj : triggerNew) {
                if(!recordTypeIdSet.isEmpty() && recordTypeIdSet.contains(accObj.RecordTypeId)){
                    if(accObj.Is_Parent_Organization__c){
                        for (String accFName: accFieldMap.keySet()) {
                            // Check if any field value on Parent Account is getting modified by user.If yes- then throw an error message.
                            if (accObj.get(accFName)!=Trigger.oldMap.get(accObj.Id).get(accFName)) {
                                accObj.addError(System.Label.NO_ACCESS_TO_MODIFY_ACOOUNT);
                            } 
                        }
                    }
                }
            }
        }
    }
    
    /*
    * Fetch Account Record Type set for Xfinity.
    */
    @TestVisible
    private static Set<String> getAccountRecordType(){
        
        String labelName = System.Label.XfinityAccountRecordType;  
        Set<String> recordTypeIdSet= new Set<String>();
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(';')){
                recordTypeIdSet.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }
        return recordTypeIdSet;
    }
    
    public static void populateParentAccount(List<Account> storeAccntLst){
         List<Account> storeAccntsToUpdate = new List<Account>();
         Map<String, Parent_Account__c> parentAccountMapping = Parent_Account__c.getAll();
         Set<String> recordTypeSet = getAllAccountRecordTypes();
         for(Account acc: storeAccntLst){
            if(acc.type != null && acc.type.equalsIgnoreCase('Store')){
                if(!recordTypeSet.isEmpty() && recordTypeSet.contains(acc.RecordTypeId)){
                    storeAccntsToUpdate.add(acc);
                }
            }
        } 
        if(!storeAccntsToUpdate.IsEmpty()){           
            for(Account childStore : storeAccntsToUpdate ){
                if(parentAccountMapping.containsKey(childStore.Parent_Account_Dropdown__c)){
                    childStore.ParentId = parentAccountMapping.get(childStore.Parent_Account_Dropdown__c).Parent_Store_Id__c;
                }
            }
        }        
    }
     /**    
    * @Description: US1033704 & US1033585--> Logic to set Targeted flag to "True" when account and territory are assigned to Address and the   status of Address is "Inactive" else Targeted flag will be set to "False"  
    * @Author: Tejaswini Kasar, Accenture    
    * @Date: 7-Mar-2017 
    * @Param:  Trigger.New, Trigger.OldMap    
    * @Return: None 
    * @Modified By : Sagarika - US1090084(Direct - Update to Inactive Customers become Targeted Logic)
    * @Modification Description : When a account status updates from Active to Inactive, change Targeted flag on Address to true (excluding conditions related to Dwelling Type, Acct Disconnect Reason & Address Excluded Flag) 
    * @Modified By : Kiran - US1097310(Direct - Dynamically Add HSI Only Address to Turf)
    * @Modification Description : when an Address in Territory becomes HSI Only and meets the parameters of an “Assigned” Turf add the Address to Assigned Turf 
    */
    public static void addressOrangeFieldUpdate(List<Account> NewAcc, Map<Id,Account> oldAcc) {
        Set<Id> setId = new Set<Id>();
        set<id> setaccountids = new set<id>();
        set<id> setaccountnewids = new set<id>();
        Set<Id> setAcctFlippedFromActiveToInactive = new Set<Id>();
        Set<String> recordTypeSet = getAllAccountRecordTypes();
        List<Customer_Address__c>addrList = new List<Customer_Address__c> ();
        List<Customer_Address__c>addressList = new List<Customer_Address__c> ();
        List<Customer_Address__c>addressupdateList = new List<Customer_Address__c> ();
        for(Account acc : NewAcc) {
          if(oldAcc!=null){
                if(acc.Customer_Status__c != null && acc.Customer_Status__c != oldAcc.get(acc.Id).Customer_Status__c){
                 setId.add(acc.id); 
                } 
                //US1090084 (Sagarika): Start
               if(acc.Customer_Status__c != null && oldAcc.get(acc.Id).Customer_Status__c == 'Active' && acc.Customer_Status__c != 'Active'){ 
                    setId.add(acc.id); 
                    setAcctFlippedFromActiveToInactive.add(acc.id);
                }
                //US1090084 (Sagarika): End
                //US1097310 - Kiran Starts
                if((acc.HSI_Active__c && !(acc.Home_Security_Active__c || acc.Voice_Active__c || acc.Video_Active__c))){
                    setaccountids.add(acc.id);
                }if((acc.Home_Security_Active__c || acc.Voice_Active__c || acc.Video_Active__c)){
                    setaccountnewids.add(acc.id);
                }
                setaccountids.addall(setaccountnewids);
                 //US1097310 - Kiran Ends
          }else{
            if(acc.Customer_Status__c != null){
              setId.add(acc.id);
            }
          }
        }
        if(!setId.Isempty()){
          addressList = [SELECT Id,Targeted__c,Territory__c,Account__r.Customer_Status__c, Dwelling_Type__c, Excluded_from_Territory__c, Disconnect_Reason__c, Account__c FROM Customer_Address__c WHERE Account__r.Id IN : setId];
        }
        //US1097310 - Kiran Starts
        if(!setaccountids.IsEmpty()){
            addressupdateList = [SELECT Id, Name, HSI_Only_Address__c,Account__c from Customer_Address__c where Account__c IN:setaccountids];
        }
        if(!addressupdateList.Isempty()){
            for(Customer_Address__c add : addressupdateList){
                if(!add.HSI_Only_Address__c && !setaccountnewids.contains(add.Account__c)){
                    add.HSI_Only_Address__c = true;
                    addrList.add(add);
                }else if(setaccountnewids.contains(add.Account__c)){
                    add.HSI_Only_Address__c = false;
                    addrList.add(add);
                    //US1097310 - Kiran Ends
                }
            }
            
        }
        if(!addressList.isEmpty()){
          for(Customer_Address__c add : addressList) {
                    if(add.Territory__c != NULL){
                        if(add.Account__r.Customer_Status__c == 'Active'){
                            if(add.Targeted__c){
                                add.Targeted__c = false;
                            }
                        }else if(add.Account__r.Customer_Status__c != 'Active'){
                            if(add.Targeted__c == false){
                                //US1090084 (Sagarika): Start
                                if(setAcctFlippedFromActiveToInactive.contains(add.Account__c) && !(add.Dwelling_Type__c == ConstantHandler.mduDwellingType ||  add.Dwelling_Type__c == ConstantHandler.multipleDwellingUnitDwellingType ||  add.Excluded_from_Territory__c || add.Disconnect_Reason__c == ConstantHandler.nonPayAcctDisconnReason))
                                {
                                //US1090084 (Sagarika): End
                                    add.Targeted__c = true;
                                }
                            }
                        }
                    }else{
                        if(add.Account__r.Customer_Status__c != 'Active'){
                            if(add.Targeted__c == false || add.Targeted__c == true)
                                    add.Targeted__c = false;
                        }
                        
                    }
                        addrList.add(add);
          }
        }
        
        if(!addrList.isEmpty()) {
            Database.Update(addrList,false);
        }
    }
  
    
    /**    
    * @Description: Business logic to mark active store visit as completed when store owner is changed - calling controller method.
    * @Author: Animesh Datta, Accenture    
    * @Date: 3-Nov-2015 
    * @Param:  Trigger.New, Trigger.OldMap    
    * @Return: None */
    
    public static void endActiveStoreVisitOwnerChage(List<Account> triggerNew, Map<Id, Account> triggerOldMap){
        AccountTriggerController.endActiveStoreVisitOwnerChage(triggerNew , triggerOldMap);
    }
    
    /*
    * Fetch Record Type Set for Account.
    */
    public static Set<String> getAllAccountRecordTypes(){
        
        String labelName = System.Label.AccountRecordType;
        Set<String> recordTypeIdSet= new Set<String>();
        if(!String.IsBlank(labelName)){
            for(String str : labelName.split(LABEL_NAME_SPLIT)){
                if(str != null){
                    recordTypeIdSet.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId());
                }
            }
        }
        return recordTypeIdSet;
    }
}