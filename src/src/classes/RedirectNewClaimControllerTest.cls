@isTest 
    public class RedirectNewClaimControllerTest
    {
        
        static testMethod void CaseRedirect()
        {
            PageReference pageRef = Page.RedirectNewClaim;
            Test.setCurrentPage(pageRef);
            list<TriggerSettings__c > triggerSettingsList = new List<TriggerSettings__c >();
         
            TriggerSettings__c caseTrigger = new TriggerSettings__c();
            caseTrigger.Name = 'CaseTrigger';
            caseTrigger.isActive__c = True;
            triggerSettingsList.add(caseTrigger);
            insert triggerSettingsList;
        
                   
        
            Case   cases = new Case();
            
            cases.Preferred_Phone__c='8020504010';
            cases.Preferred_Email__c ='abc@accenture.com';
            cases.status='New';
            cases.Channel__c = 'Direct Sales';
            cases.Region__c='Corporate';
            cases.Request_Type__c='AirWatch';
            cases.Description='abcde';
            
            insert cases;    
            
            ApexPages.StandardController controller = new ApexPages.StandardController(cases);   
            RedirectNewClaimController redirectTest = new RedirectNewClaimController(controller);            
            redirectTest.RedirectAffiliateClaimsUsers();
            
            
           
            
      }
      
      
       
  
 }