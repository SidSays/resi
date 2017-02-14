/************************************************************************************************************************************************************
Name: MDU_ValidateOpptyPropertyWS
Description: This class holds the logic for validation of Portfolio Opportunity. 
    Portfolio name is required and required to be unique when an opportunity is a portfolio opportunity.
    A portfolio opportunity is an opportunity record with more than one property on it. 
    User needs to save the record with a unique portfolio name before being able to add more than one property to the opportunity.
Author: Ritesh Saxena
Date PRJ/DFCT/ENHC# Summary of Changes 
*************************************************************************************************************************************************************/
global class MDU_ValidateOpptyPropertyWS{
     
    /*
    * Static variable declaration
    */
    private static String statusMsg='';
    private static final String ERROR_STR = 'Error: ';
    
    /**
    * Name: validateOpptyProperty
    * Description: This method is used to let User save the record with a unique portfolio name before being able to add more than one property to the opportunity. 
    * @parameters: Id
    * @return: String
    **/
    webService static String validateOpptyProperty(Id opportunityId){
       
        for(Opportunity_Property__c opptyProperty : [Select Id , Opportunity__c, Opportunity__r.Sales_Portfolio_Name__c
                                                     FROM Opportunity_Property__c  WHERE Primary_Property__c = true AND Opportunity__c =: opportunityId
                                                     LIMIT : 1]){                                                 
           if(String.isBlank(opptyProperty.Opportunity__r.Sales_Portfolio_Name__c)){               
                statusMsg = ERROR_STR + System.Label.Portfolio_Name_Require_Validation_Message;
            }
        }       
        return statusMsg;
    }
}