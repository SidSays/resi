/************************************************************************************************************************************************************
Name: AccountManagementServiceRest
Description: This class calls the AccountManagementServicecallout Class to get the base 64 encoded string of the pdf.
Author: Lalit Singh Accenture
--------------- ------------------ ------------------------------
10 Oct 2015 Comcast  
Modification History: 02-28-2016 Accenture : Modified to fix the Error keyword from PDF blob 
*************************************************************************************************************************************************************/

@RestResource(urlMapping='/AccountManagementServiceRest/*')
global without sharing class AccountManagementServiceRest
{
        
    @HttpPost
    global static String addBillingAccountNumber(String bilingAccountNumber)
    {
        Boolean hasError = false;
        String errorMessage = 'Unable to retrieve the customers bill';
        String returnData = '';
        try
        {
            AccountManagementServiceCallout obj = new AccountManagementServiceCallout(bilingAccountNumber);
            if(obj.DsmStringErrorMsg.containsIgnoreCase('error')) //Changes the Variable to check the Error.
            {
                hasError = true;
            } else {
                returnData  = obj.DsmStringData;
            }
        }
        catch(Exception e)
        {
            
            hasError = true;   
        }
        
        if(hasError == true)
        {
            return errorMessage;
        }
        return returnData;
    } 
}