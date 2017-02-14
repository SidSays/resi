/**
* Class Name: CancelClaimController 
* Author: Amitkumar Bangad, Accenture
* Date: 04-December-2012 
* Requirement # Request Id: 085
* Description: Contains supporting Actions for Case Triggers (Giving access to Affiliate public group on Owner change)
* Last Modified :
*/
public class CancelClaimController {
    
    public Case claimToCancel{get;set;}
    public Boolean isInvalidClaim {get;set;}
    public String caseId {get;set;}
    public String reason {get;set;}
    
    /**
    * @Description: Constructor for CancelClaimController class
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 04-December-2012
    */
    public CancelClaimController(ApexPages.StandardController controller) {
        caseId = ApexPages.currentPage().getParameters().get('Id');
        reason = '';
        try {
            claimToCancel = [Select Id,Case_Name__c, CaseNumber, Status, Claimed_Amount__c, Claim_Cancelled_Date__c,
                             Claim_Cancellation_Reason__c, Approved_Amount__c, Claim_Reason_Description__c, Claim_Result__c  from Case where Id =: caseId AND Status != 'Cancelled' AND Status != 'Closed'];
        } catch (QueryException QryEx){
        }
        if(claimToCancel != null){
            isInvalidClaim = true;
        } else{
            isInvalidClaim = false;
        }
    }
    /**
    * Description: This method navigates the user back to case record. 
    * Author: Amitkumar Bangad, Accenture
    * Date: 04-December-2012
    * Param: None.
    * Return: Page Reference of Case record.
    */
    public pageReference Exit() {
        PageReference pageRef1 = new PageReference('/'+ caseId); 
        return pageRef1;
        
    }
    
    /**
    * Description: This method sets the case cancellation reason from VF Page
    *                 to cancel & autopopulates status, cancellation date, etc
    * Author: Amitkumar Bangad, Accenture
    * Date: 04-December-2012
    * Param: None.
    * Return: Page Reference of Case record.
    */
    public pageReference CancelClaim(){
        Database.SaveResult result;
        PageReference pageRef;
        List<Order__c> orderList;
        if(reason != null && reason.replaceAll('\\s+', '') != ''){
            claimToCancel.Claim_Cancellation_Reason__c  = reason;
            claimToCancel.Claim_Cancelled_Date__c = system.today();
            claimToCancel.Status = label.Claim_Cancelled_Status;
            claimToCancel.Approved_Amount__c = 0;
            claimToCancel.Claim_Result__c = '';
            claimToCancel.Claim_Reason_Description__c = '';
            orderList = new List<Order__c>();
            orderList = [Select Id, Claim__c from Order__c where Claim__c =: caseId];
            for (order__c ord : orderList){
                ord.Claim__c = null;
            }
        } else {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.Claim_Cancellation_Reason_Required));   
            return null;
        }
        try{
            if (!orderList.isEmpty()){
                Database.SaveResult[] results = database.update(orderList,false);
            }
            result = database.update(claimToCancel, true);    
        } catch (DMLException dmlEx){
            for(Integer i =0; i<dmlEx.getNumDml(); ++i) { 
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,dmlEx.getDmlMessage(i)));
            }
            return null;
        }
        pageRef = new PageReference('/'+ result.getId());
        return pageRef;
    }
}