/**
* Class Name: RaiseClaimController 
* Author: Amitkumar Bangad, Accenture
* Date: 02-December-2012 
* Requirement # Request Id: 082  
* Description: Contains supporting actions for VF page RaiseClaim
* Last Modified :
*/
public class RaiseClaimController {

    public Order__c selectedOrder;
    public Case newClaim {get;set;}
    public Boolean isValid {get;set;}
    public Boolean isInternalUser {get;set;}
    public decimal claimAmount {get;set;}
    public String description {get;set;}
    public String name {get;set;}
    public Account acc;
    public Id orderId;
    public Order__c order {get;set;}
    Apexpages.StandardController controller;
    
    public RaiseClaimController(ApexPages.StandardController con) {
        controller = con;
        orderId = ((Order__c)controller.getRecord()).Id;
        description = '';
        name = '';
    }

    public PageReference displayOrder(){
        claimAmount = 0.00;
        isValid = false;
        isInternalUser = false;
        newClaim = new Case();
        Map <String, Schema.RecordTypeInfo> claimRecordTypes = Case.SObjectType.getDescribe().getRecordTypeInfosByName();
        newClaim.RecordTypeId = claimRecordTypes.get(Label.Default_Claim_Record_Type).getRecordTypeId();

        //Default Contact is current User's Contact(if one exists)
        List<User> user = new List<User>([Select Id, ContactId From User Where Id =: UserInfo.getUserId()]);
        System.debug('user= ' + user);
        if(user.get(0).ContactId != null){
            newClaim.ContactId = user.get(0).ContactId;
        }

        //check if order already has a claim on it
        order = [Select Id, Name, OrderStatus__c, Order_Created_Date__c, OrderCompletedDate__c, Claim_Eligibility__c From Order__c Where Id =: orderId];
        List<Case> cases = new List<Case>([Select Id From Case Where OrderName__c =: order.Id AND Status != 'Cancelled']);
        if(cases.isEmpty()){
            if(order.Claim_Eligibility__c == true){
                isValid = true;
                //set internalUser flag for non-affiliate users
                for(Profile p :[Select Name from Profile where Id=: UserInfo.getProfileId()]){
                    if(p.Name != label.Affiliate_User_Profile){
                        isInternalUser = true;
                    }
                }
            } else {
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR,Label.Order_Not_Eligible_For_Claim));
            }
        } else {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR,Label.Order_Already_Has_Claim));
        }
        return null;
    }

    public PageReference cancelOperation(){
        pageReference pageRef2;
        pageRef2 = new PageReference(label.Eligible_Orders_View);
        return pageRef2;
    }
    
    public PageReference submitClaim(){
        PageReference pageRef; 
        Boolean errorFlag = false;
        
        if(isValid){
            newClaim.OrderName__c = order.Id;
            if(claimAmount != null && claimAmount > 0 && description != null && description.replaceAll('\\s+', '') != ''){
                newClaim.Claimed_Amount__c = claimAmount;
                newClaim.Description = description;
            } else {
                errorFlag = true;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR,Label.Submit_Claim_Requirements_Not_Met));
            }
            if(!isInternalUser){
                for(User usr : [Select Id, AccountId from User where Id =: UserInfo.getUserId()]){
                    if(usr.AccountId != null){
                        newClaim.Affiliate_Account__c = usr.AccountId;
                    }
                }
            } else{
                if(newClaim.ContactId != null){
                    for(User usr : [Select Id, AccountId from User where ContactId =: newClaim.ContactId]){
                        if(usr.AccountId != null){
                            newClaim.Affiliate_Account__c = usr.AccountId;
                        }
                    }
                    if(newClaim.Affiliate_Account__c == null){
                        errorFlag = true;
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Non_Affiliate_Contact));
                    }
                } else {
                    errorFlag = true;
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.Contact_Name_Required));
                }
            }
            for(Account ac : [Select Name from Account where id=: newClaim.Affiliate_Account__c]){
                acc = ac;
            }

            Group genericQueue = [Select Id, Name from Group where Name =: label.Claim_Investigation_Queue];
            newClaim.OwnerId = genericQueue.Id;

            if(errorFlag){
                return null;
            }
            try{
                Database.SaveResult claimResult = database.insert(newClaim,false);
                if(claimResult.isSuccess()) {
                    pageRef = new PageReference('/'+ claimResult.getId());
                    order.Claim__c = claimResult.getId();    
                    
                    Database.SaveResult orderResult = database.update(order,false);
                    
                    for (Group affiliateGroup : [Select Id, Name from Group where Name LIKE :'%'+ acc.Name + '%']){
                        CaseShare newCaseShare = new CaseShare(caseId = claimResult.getId(),
                        UserOrGroupId = affiliateGroup.Id,
                        CaseAccessLevel = 'Read');
                        
                        Database.SaveResult shareResult = database.insert(newCaseShare,false);
                    }
                }
            } 
            catch (DmlException dmlEx){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,dmlEx.getDmlMessage(0)));
                return null;
            }
        }
        return pageRef;
    }
}