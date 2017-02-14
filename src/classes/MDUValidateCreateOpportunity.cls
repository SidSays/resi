/**
* Class Name: MDUValidateCreateOpportunity
* Author: Abhishek Mathur, Accenture
* Date: 29 January  
* Requirement # Request Id(user story id): 089
* Description: Validate Open Opportunity.
*/

global class MDUValidateCreateOpportunity{
    
    private static final string WON_OPPORTUNITY = 'Closed Won';
    private static final string LOST_OPPORTUNITY = 'Closed Lost';
    //Use to show javascript validation when we create new Opportunity
    webservice static boolean validateOpenOppty(String propertyId) 
    { 
        boolean openOppty = false;
        //Check for Open Opportunity - Uncomment code Below
        for(Opportunity_Property__c p: [SELECT Id, Property__c, Opportunity__c , Opportunity__r.StageName 
                                          FROM Opportunity_Property__c  where Property__c =: propertyId
                                          LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){ 
            if(null!= p.Opportunity__r.StageName 
                && !WON_OPPORTUNITY.equalsIgnoreCase(p.Opportunity__r.StageName.trim()) 
                && !LOST_OPPORTUNITY.equalsIgnoreCase(p.Opportunity__r.StageName.trim())){   
                openOppty = true;
            }
        }
        
        return openOppty;
    }
}