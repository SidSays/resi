/************************************************************************************************************************************************************
Name: MDU_ViewContractPageCtrl 
Description: This class is a control for View Contract page
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
-------------- ------------------ ------------------------------
20 Feb 2015 Comcast  
*************************************************************************************************************************************************************/

public with sharing class MDU_ViewContractPageCtrl {
    @RemoteAction
    public static string viewContract(String opptyPropId){
        String finalResult = '';
        try{
            String opptyPropertyId = opptyPropId; 
            if(opptyPropertyId != '' && opptyPropertyId != null){
                finalResult = MDU_ContractServices.viewContractProcess(opptyPropertyId);
                
            }
        }catch(Exception e){
            finalResult = MDU_Constants.ERROR ;
        }
        return finalResult;
    }
}