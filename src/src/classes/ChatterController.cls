public with sharing class ChatterController {

    public Terms_and_Conditions__c tandc {get; set;}
    public User currentUser {get; set;}
    public boolean displayPopup {get; set;}  
    public boolean acceptTandC {get; set;}
    public Boolean isSF1 {get; set;} 

    public ChatterController() {
        isSF1=checkIsSF1();
    }

    public pageReference redirect()
    {
        PageReference pr;
        currentUser=[Select Terms_and_Conditions_Accepted__c From User Where Id=:UserInfo.getUserId()];
        if(currentUser.Terms_and_Conditions_Accepted__c==null)
        {
            List<Terms_and_Conditions__c> tandcList=[Select Terms_and_Conditions_Text__c From Terms_and_Conditions__c Where Active__c=true];
            if(!tandcList.isEmpty())
            {
                tandc=tandcList.get(0);
                system.debug(tandc);
                displayPopup=true;
            }
            else
            {
                pr = new PageReference ('/_ui/core/chatter/ui/ChatterPage');
                pr.setRedirect(true);
            }
        }
        else
        {
            pr = new PageReference ('/_ui/core/chatter/ui/ChatterPage');
            pr.setRedirect(true);
        }
        
        return pr;
    }   
    
    public PageReference acceptTandCRedirect() {      
        PageReference pr;  
        if(acceptTandC)
        {
            currentUser.Terms_and_Conditions_Accepted__c=Date.Today();
            update currentUser; 
            pr = new PageReference ('/_ui/core/chatter/ui/ChatterPage');
            pr.setRedirect(true);
        }
        else
        {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please check the "I Accept the Terms and Conditions" checkbox.'));
        }
        return pr;
    }  

    public PageReference cancel() {      
        PageReference pr;  
        pr = new PageReference ('/home/home.jsp');
        pr.setRedirect(true);
        return pr;
    } 

    //Determine if this is SF1 app
public Boolean checkIsSF1(){
    if(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')!=null ||
        ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')!=null ||
        ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
        (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
    ){
        return true;
    }else{
        return false;
    }
}  
}