/***************************************************************************************************************************************
 * Author     : Vivek Patel
 * Date       : 19-Dec-2012
 * Description: This class is Standard Controller extension of Opportunity object and this is referred in "ChangeOpportunityOwner" visualforce page.
 * Requirement: 89 - Lead and Opportunity reassignment.
 * History
     Version             : 1.0
     Author Last Updated : Vivek Patel 
     PROJECT             : Turnpike
***************************************************************************************************************************************/

public class ExtnOptyOwner {

    public Boolean isEmailNotification{get;set;}
    public List<Opportunity> listOpty = new List<Opportunity>();
    public Integer size{get;set;}  
    
    // Class Constructor    
    public ExtnOptyOwner(ApexPages.StandardSetController controller) {
        listOpty = controller.getSelected();
        size=listOpty.size();
    }

/***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 19-Dec-2012
     * Param      : None
     * Return     : PageReference of first Opportunity record.
     * Description: This method is called from "ChangeOpportunityOwner" page to update the Opportunity owner.
************************************************************************************************************************************/

    public PageReference saveOpty() {
        Boolean isUpdated = true;
        try {
            update listOpty;
        }catch(Exception ex) {
            isUpdated = false;            
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDMLMessage(0));
            ApexPages.addMessage(errorMsg);
            System.debug('Following exception occured while updating Opportunities:'+ex);
        }
               
        // Sending emails to new owners if Owner is updated successfully.       
        if(isUpdated == true && isEmailNotification == true) {
            listOpty = [Select Id, Name, OwnerId from Opportunity where Id in :listOpty];
            try {
                Messaging.SingleEmailMessage mailObj = new Messaging.SingleEmailMessage();
                mailObj.setTargetObjectId(listOpty[0].OwnerId);
                mailObj.setSubject('Opportunity transferred to you.');
                mailObj.saveAsActivity=false;
                String msg;

                for(Opportunity oppObj : listOpty) {
                    msg = 'Opportunity '+oppObj.name+' has been assigned to you. Please click on the link below to view the record.';
                    mailObj.setHtmlBody('<html><body>'+msg+'<br/>'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppObj.Id+'</body></html>');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailObj });
                }
            }catch(Exception ex) {
                System.debug('Following exception occured while sending email:'+ex);
            }
            
        }   
        
        // Redirecting to first Opportunity detail page when Opportunities are reassigned.        
        PageReference pageRef = ApexPages.currentPage();
        if(isUpdated == true) {
            pageRef = new ApexPages.StandardController(listOpty[0]).view();
        }
        return pageRef;
    }
}