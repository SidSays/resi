/**
* Class Name: CaseTriggerController 
* Author: Amitkumar Bangad, Accenture
* Date: 10-January-2013 
* Requirement # Request Id: 067
* Description: Contains supporting Actions for Case Triggers (Giving access to Affiliate public group on Owner change)
* Modified By : Ashish Srivastava - US735966(Implemented NSO Record Type check for Case Trigger)
* Last Modified :
*/
public class CaseTriggerController {
    /**
    * @Description: This method handles below requests:
                 443 - Updates Case's Order field based on the order number
                 446 - Update Case's Account field based on the account number
                 442 - update the affiliate account with partner portal user's account
                 Note : This functionality should only work for Post & Pre Order Escalations disputes Cases
    * @Author: Sneha Rathi, Accenture
    * @Date: 20 Nov, 2013
    * @Param: Trigger.New
    * @Return: void.
    */
    private static final string LABEL_NAME_SPLIT = ';';
      
    public static void updateCases(Map<Id, Case> caseOldMap, List<Case> lstCases){
        //Fetching the recordtype info for Pre-order & Post-order Case object recordtypes
        set<String> setCaseRecordTypesName = new Set<String>{'Pre-Order Escalation','Post-Order Escalation'};
        Map<String,Schema.RecordTypeInfo> caseRecordTypeInfos = Case.SObjectType.getDescribe().getRecordTypeInfosByName();
        set<Id> caseRecordtypeIds = new set<Id>();
        Boolean isInternalUser = false;
        for(String s: setCaseRecordTypesName)
        {
            if(caseRecordTypeInfos.get(s) != null)
                caseRecordtypeIds.add(caseRecordTypeInfos.get(s).getRecordTypeId());
        }  
        
        Set<String> setOrderNumber = new Set<String>();
        Set<String> setAccountNumber = new Set<String>();
        //collect the order & account numbers for the new cases
                for(Case cs: lstCases)
                {
                    if(!caseRecordtypeIds.isEmpty() && caseRecordtypeIds.contains(cs.RecordTypeId))
                    {
                        if(cs.OrderID__c != '' && cs.OrderID__c != null)
                           setOrderNumber.add(cs.OrderID__c);
                        if(cs.AccountNumber__c != '' && cs.AccountNumber__c != null)
                           setAccountNumber.add(cs.AccountNumber__c); 
                    } 
                }
        //fetch the corresponding order details
        Map<String, Order__c> mapOrders = new Map<String, Order__c>();
        if(setOrderNumber.size() > 0)
        {
            for(Order__c ord: [Select id, Order_Number__c from Order__c where Order_Number__c in :setOrderNumber limit 50000])
            {
                 mapOrders.put(ord.Order_Number__c, ord);   
            }
        }    
        //fetch the corresponding Account details
        Map<String, Account> mapAccounts = new Map<String, Account>();
        if(setAccountNumber.size() > 0)
        {
            for(Account acc: [Select id, Billing_Account_Number__c from Account where Billing_Account_Number__c in :setAccountNumber])
            {
                mapAccounts.put(acc.Billing_Account_Number__c, acc);
            }
        }    
        
        //Determining if the current user is an partner portal user and fetching its user
        Id affiliateAccount = null;
        for(Profile p :[Select Name from Profile where Id=: UserInfo.getProfileId()])
        {
            if(p.Name != label.Affiliate_User_Profile){
                isInternalUser = true;
            }
        }
        if(!isInternalUser){
            User usr = [Select Id, AccountId from User where Id =: UserInfo.getUserId()];
            if(usr.AccountId != null){
                affiliateAccount = usr.AccountId;
            }
        }
        
        //Update the cases with the order details, account details and Affiliate account details
                for(Case cs: lstCases)
                {
                    if(!caseRecordtypeIds.isEmpty() && caseRecordtypeIds.contains(cs.RecordTypeId))
                    {
                        //DRice 3/13 - If the owner changes, don't set it to EscaalationDispute
                        if(caseOldMap == null){
                            //cs.OwnerId = EnvironmentSpecificIds__c.getValues('EscalationDispute').Id__c;
                        } else if((caseOldMap.get(cs.Id).OwnerId != cs.OwnerId) && (caseOldMap.get(cs.Id).Status == 'Submitted')){
                            cs.Status = 'Open';
                        }
                        
                        cs.EscalationDisputes__c = True;
                        if(cs.OrderID__c != '' && mapOrders.get(cs.OrderID__c) != null){
                            cs.OrderName__c = mapOrders.get(cs.OrderID__c).id;
                        }
                        
                        if(cs.AccountNumber__c != '' && mapAccounts.get(cs.AccountNumber__c) != null){
                            cs.Customer_Account__c = mapAccounts.get(cs.AccountNumber__c).id;
                        }
                        if(affiliateAccount != null){
                            cs.Affiliate_Account__c = affiliateAccount;
                        }
                    }
                }
    }
    
    /**
    * @Description: This method will give edit access to 
    *               the user who has created the record 
    *               in case of owner change to add attachments.                 
    * @Author: Mandeep Singh, Accenture
    * @Modified: Mangesh Wanjari, Accenture-11 July 2016.
    * @Date: 15 June, 2016
    * @Return: void.
    */
    public static void caseRecordAccess(Map<id,case> caseOldMap,List<Case> caseList){
        List<CaseShare> sharesToCase = new List<CaseShare>();
        CaseShare csShare = new CaseShare();
        CaseShare csShareRequestedFor = new CaseShare();
        Id caseId;
        Id createdBy;
        Id requestedFor;
        Set<String> recordTypeSet = getCaseRecordTypes();
        try{
            for(Case cs : caseList){
                if(!recordTypeSet.isEmpty() && recordTypeSet.contains(cs.RecordTypeId)){
                        caseId = cs.Id;
                        if(caseOldMap.get(cs.Id).OwnerId != cs.OwnerId){
                            createdBy= cs.CreatedById;
                            // Creating CaseShare record                  
                            csShare.CaseID= caseId;
                            csShare.UserOrGroupId = createdBy ;
                            csShare.CaseAccessLevel= label.EditLabel; 
                            sharesToCase.add(csShare);       
                        }
                        // Share the case record with the "Requested For" user(Enhancement in US729143)
                        if(cs.Requested_For__c != null){
                            requestedFor= cs.Requested_For__c ;
                            csShareRequestedFor.CaseID= caseId;
                            csShareRequestedFor.UserOrGroupId= requestedFor;
                            csShareRequestedFor.CaseAccessLevel= label.EditLabel;
                            sharesToCase.add(csShareRequestedFor); 
                        }
                }
            }
            if(!sharesToCase.isEmpty()){  
                database.insert(sharesToCase); 
            }
        }catch(Exception ex){
            system.debug('****Following error occurred****'+ex.getMessage());
        }
    }
   
    
    /**
    * @Description: Assingment rules are not fired from SF1.
                    This method will make sure, the assingment rules
                    are always fired, be it from browser or SF1.
                                     
    * @Author: Malay Desai, Accenture
    * @Date: 27 June, 2016
    * @Return: void.
    */
    public static void fireAssignmentRule(List<Case> newCases){
        List<Id> caseIds = new List<Id>();

        for (Case theCase:newCases) 
            caseIds.add(theCase.Id);
        
        List<Case> cases = new List<Case>();
        Set<String> recordTypeSet = getCaseRecordTypes();   
        for(Case c : [Select Id,RecordTypeId from Case where Id in :caseIds])
        {
            if(!recordTypeSet.isEmpty() && recordTypeSet.contains(c.RecordTypeId)){
                    Database.DMLOptions dmo = new Database.DMLOptions();
         
                    dmo.assignmentRuleHeader.useDefaultRule = true;
                    c.setOptions(dmo);
                    
                    cases.add(c);
            }
        }
        
        Database.upsert(cases);
    }
    
    
    /**
    * @Description: This method will perform a Record Type check
    *               on Case for NSO Record Types 
    * @Author: Ashish Srivastava, Accenture
    * @Date: 30 September, 2016
    * @Return: Set of String containing recordType Ids.
    */
    public static Set<String> getCaseRecordTypes(){
        String labelName = System.Label.CaseRecordType;
        Set<String> recordTypeIdSet = new Set<String>();
        
        if(!String.isBlank(labelName)){
            for(String str: labelName.split(LABEL_NAME_SPLIT )){
                if(str != null){
                    recordTypeIdSet.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get(str).getRecordTypeId());                
                }
            }
        }
        return recordTypeIdSet;
    }
}