/***************************************************************************************************************************************
 * Author     : Vivek Patel, Accenture
 * Date       : 29-March-2013
 * Description: This class is Controller of "SelectTemplate" visualforce page.
 * Requirement: 122, 301 - User should be able to apply saved Template to the plan.
 * History
     Version             : 1.0
     Author Last Updated : Vivek Patel, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/

public class SearchTemplateController {

    public Template__c selectedTemplate { get; set; }        
    public Plan__c planObj { get; set; }
    public String searchString { get; set; }    
    public String userDivision;

/***********************************************************************************************************************************
     * Author     : Vivek Patel, Accenture
     * Param      : None
     * Return     : None
     * Description: This is contructor of the class and it retrieves Parmeters passed in URL and query some records.
************************************************************************************************************************************/                          
    public SearchTemplateController() {
        if( ApexPages.CurrentPage().getParameters().get('PlanId') != null  && ApexPages.CurrentPage().getParameters().get('PlanId') != '') {
            try {
                planObj = [Select Id, Plan_Level__c from Plan__c where Id = :ApexPages.CurrentPage().getParameters().get('PlanId')];
                Id divisionId = [Select Id, DefaultDivision from User where Id = :UserInfo.getUserId() ].DefaultDivision;
                userDivision = [Select Name from Division where Id =:divisionId].Name;
            } catch(Exception ex) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
                ApexPages.addMessage(msg); 
                System.debug('Following exception occurred:'+ex.getMessage());
            }
        }
    }    
    
    public List<Template__c> templates { 
        get {
            if(templates == null && ApexPages.CurrentPage().getParameters().get('PlanId') != '') {            
                try {      
                    if(userDivision == Label.DivisionGlobal)
                        templates = [Select Name, Plan_Type__c, Zip_Codes__c, Nodes__c, Customer_Status__c, Complex_Code_exists__c, Products__c, Disconnect_Reason__c, Dwelling_Type__c, Property_Code__c, Street__c  from Template__c where Plan_Type__c=:planObj.Plan_Level__c And Status__c=:Label.StatusActive];
                    else
                        templates = [Select Name, Plan_Type__c, Zip_Codes__c, Nodes__c, Customer_Status__c, Complex_Code_exists__c, Products__c, Disconnect_Reason__c, Dwelling_Type__c, Property_Code__c, Street__c  from Template__c where Plan_Type__c=:planObj.Plan_Level__c And Status__c=:Label.StatusActive And Region__c includes(:userDivision)];
                }catch(Exception ex) {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
                    ApexPages.addMessage(msg);   
                    System.debug('Following exception occurred :'+ex.getMessage());
                }
            }
            return templates;
        }
        set; 
    }
    
/***********************************************************************************************************************************
     * Author     : Vivek Patel, Accenture
     * Param      : None
     * Return     : PageReference
     * Description: This method is called to search Templates with user specified string on template lookup. 
************************************************************************************************************************************/                      
    public PageReference searchTemplates() {
        searchString  = '%' + searchString + '%';
        try {
            if(ApexPages.CurrentPage().getParameters().get('PlanId') != '') {
                if(userDivision == Label.DivisionGlobal)
                    templates = [Select Name, Division__c, Region__c, Plan_Type__c, Zip_Codes__c, Nodes__c, Customer_Status__c, Complex_Code_exists__c, Products__c, Disconnect_Reason__c, Dwelling_Type__c, Property_Code__c, Street__c from Template__c where Name like :searchString And Plan_Type__c=:planObj.Plan_Level__c And Status__c=:Label.StatusActive];
                else
                    templates = [Select Name, Division__c, Region__c, Plan_Type__c, Zip_Codes__c, Nodes__c, Customer_Status__c, Complex_Code_exists__c, Products__c, Disconnect_Reason__c, Dwelling_Type__c, Property_Code__c, Street__c from Template__c where Name like :searchString And Plan_Type__c=:planObj.Plan_Level__c And Status__c=:Label.StatusActive And Region__c includes(:userDivision)];
            }
        }catch(Exception ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
            ApexPages.addMessage(msg);   
            System.debug('Following exception occurred :'+ex.getMessage());
        }
        return null;
    }            
}