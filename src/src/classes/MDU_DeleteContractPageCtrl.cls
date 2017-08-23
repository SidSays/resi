/************************************************************************************************************************************************************
Name: MDU_DeleteContractPageCtrl 
Description: This class is a control for Delete Contract page
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
16 Feb 2015 Comcast  
*************************************************************************************************************************************************************/

public with sharing class MDU_DeleteContractPageCtrl {
    
    
    @RemoteAction
    public static string deleteContract(String contractID){
        
        String finalResult = '';
        try{
            String opptyPropertyId = contractID; 
            if(opptyPropertyId != '' && opptyPropertyId != null){
                finalResult = MDU_ContractServices.deleteContractProcess(opptyPropertyId,true);     //US1107249 - Passing a boolean variable to check if the contract is getting deleted through the delete link or getting deleted whrn opportunity is deleted.           
            }
        }catch(Exception e){
            finalResult = MDU_Constants.ERROR + e.getMEssage();
        }
        return finalResult;
    }
}