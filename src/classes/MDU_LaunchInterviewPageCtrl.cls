/************************************************************************************************************************************************************
Name: MDU_LaunchInterviewPageCtrl 
Description: This class holds the Launch Interview Button Request.
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
16 Feb 2015 Comcast  
*************************************************************************************************************************************************************/
global class MDU_LaunchInterviewPageCtrl{
    
    //Variable Declaration
    ApexPages.StandardController controller;
    Opportunity objOpportunity = new Opportunity();
    public boolean isDisableLaunchBtn {get;set;}
    public boolean isDisableResumeBtn {get;set;}
    public boolean isDisableDeleteBtn {get;set;}
    public String opptyId;
    public static String finalResult;
    public boolean isError{get;set;}
    public boolean isValid{get;set;}
    public string errorMessage{get;set;}
    public string URL {get;set;}
    public List<String> errorMessageList{get;set;}
    
    /**
    * Name: MDU_LaunchInterviewPageCtrl
    * Description: This is constructor. 
    * @parameters: None
    * @return: None
    **/
    public MDU_LaunchInterviewPageCtrl(ApexPages.StandardController controller) {
        errorMessageList = new List<String>();
        isDisableLaunchBtn = false;
        isDisableResumeBtn = false;
        isDisableDeleteBtn = false;
        isError = false;
        isValid = false;
        finalResult = '';
        URL='';
        //getting the Opportunity Record
        objOpportunity = (Opportunity)controller.getRecord();
        
        if(objOpportunity != null){
            opptyId = objOpportunity.Id;
            disableLaunchButton(opptyId);
        }
    }
    
    
    /**
    * Name: launchInterviewProcessCustom
    * Description: This method is used to invoke the Launch Interview Process. 
    * @parameters: None
    * @return: PageReference
    **/
    public PageReference launchInterviewProcessCustom(){
        isValid = false;
        errorMessageList= new List<String>();
        if(opptyId != null && opptyId != ''){
            List<Opportunity_Property__c> opportunityPropertyData = getOpptyPropertyDetail(opptyId);                      
            if(opportunityPropertyData !=null && !opportunityPropertyData.isEmpty() && opportunityPropertyData[0].Opportunity__r.ECM_Interview_Instance_Name__c!= null 
                && opportunityPropertyData[0].Opportunity__r.ECM_Interview_Instance_Name__c != ''){
                finalResult = System.Label.InterviewAlreadyLaunchedError;
            } else {                
                finalResult = MDU_LaunchInterviewProcess.processInterview(opptyId);
                disableLaunchButton(opptyId);
            }   
        }
        
        if(!String.IsBlank(finalResult) ){
            if(!finalResult.startsWith(MDU_Constants.ERROR)){
                isValid = true;
                URL = finalResult;
                if(MDU_LaunchInterviewProcess.isUpdateOpportunity){
                    MDU_EmptorisUtility.updateOpportunity(opptyId,MDU_LaunchInterviewProcess.interviewInstanceNameFinal,MDU_LaunchInterviewProcess.dtTimeStr);
                    MDU_LaunchInterviewProcess.isUpdateOpportunity = false;
                }
            }else{
                errorMessage = finalResult;
                for(String objStr: finalResult.split(MDU_Constants.SEMICOLON)){
                    errorMessageList.add(objStr);
                }
                isError = true;
                return null;
            }   
        }
        return null;
    }
    
    
    /**
    * Name: resumeInterviewProcess
    * Description: This method is used to invoke the Resume Interview Process. 
    * @parameters: None
    * @return: None
    **/
    public void resumeInterviewProcess(){
        isValid = false;
        errorMessageList= new List<String>(); 
        if(opptyId != null && opptyId != ''){
            
            List<Opportunity_Property__c> opportunityPropertyData = getOpptyPropertyDetail(opptyId);                      
            if(opportunityPropertyData !=null && !opportunityPropertyData.isEmpty()){
                if(opportunityPropertyData[0].ECM__c != null && opportunityPropertyData[0].ECM__c != ''){ 
                    finalResult = MDU_Constants.RESUME_ERR_MESSAGE;
                } else {                
                    finalResult = MDU_LaunchInterviewProcess.processInterview(opptyId);
                }
            }
        }
        if(!String.IsBlank(finalResult) ){
            if(!finalResult.startsWith(MDU_Constants.ERROR)){
                isValid = true;
                URL = finalResult;
            }else{
                isError = true;
                errorMessage = finalResult;
                for(String objStr: finalResult.split(MDU_Constants.SEMICOLON)){
                    errorMessageList.add(objStr);
                }               
            }   
        }
    }
    
    
    /**
    * Name: disableLaunchButton
    * Description: This method is used to enable/disable the buttons. 
    * @parameters: opptyId
    * @return: None
    **/
    public void disableLaunchButton(String opptyId){

        if(opptyId != null){

            List<Opportunity_Property__c> opportunityPropertyData = getOpptyPropertyDetail(opptyId);            
           
            if(opportunityPropertyData !=null && !opportunityPropertyData.isEmpty() && opportunityPropertyData[0].Opportunity__r.StageName.equalsIgnoreCase(MDU_Constants.CONTRACT_DOCUMENT_REVIEW)){
                if(opportunityPropertyData[0].ECM__c != null && opportunityPropertyData[0].ECM__c != ''){                           
                    isDisableLaunchBtn = true;
                    isDisableResumeBtn = true;
                    isDisableDeleteBtn = true;                          
                } else if(opportunityPropertyData[0] != null && opportunityPropertyData[0].Opportunity__r.ECM_Interview_Instance_Name__c != null && opportunityPropertyData[0].Opportunity__r.ECM_Interview_Instance_Name__c != '' ){
                    isDisableLaunchBtn = true;
                    isDisableResumeBtn = false;
                    isDisableDeleteBtn = false;
                } else {
                    isDisableLaunchBtn = false;
                    isDisableResumeBtn = true;
                    isDisableDeleteBtn = true;                       
                }
            } else{
                isDisableLaunchBtn = true;
                isDisableResumeBtn = true;
                isDisableDeleteBtn = true;
            }
        }
    }
    
    
    /**
    * Name: deleteInterview
    * Description: This method is used to invoke the Delete Interview Process. 
    * @parameters: None
    * @return: PageReference
    **/
    public PageReference deleteInterview(){
        
        isValid = false;
        errorMessageList= new List<String>(); 
        
        if(opptyId != null){            
            List<Opportunity_Property__c> opportunityPropertyData = getOpptyPropertyDetail(opptyId);                      
            if(opportunityPropertyData !=null && !opportunityPropertyData.isEmpty()){
                if(opportunityPropertyData[0].ECM__c != null && opportunityPropertyData[0].ECM__c != ''){ 
                    finalResult = MDU_Constants.DELETE_ERR_MESSAGE ;
                } else {                
                    Opportunity objOpportunity = new Opportunity();
                    objOpportunity.Id = opptyId;
                    objOpportunity.ECM_Interview_Instance_Name__c = '';
                    objOpportunity.Interview_Created_Date__c = '';
            
                    try{
                        update objOpportunity;
                        isValid = true;
                    }catch(Exception ex){finalResult = MDU_Constants.ERROR + ex.getMessage();}
                }
            }
            if(!String.IsBlank(finalResult) && finalResult.startsWith(MDU_Constants.ERROR)){
                errorMessage = finalResult;
                for(String objStr: finalResult.split(MDU_Constants.SEMICOLON)){
                    errorMessageList.add(objStr);
                }
                isError = true;
            }               
        }
        return null;
    }
    
    /**
    * Name: getOpptyPropertyDetail
    * Description: This method is used to get Opportunity Property Details. 
    * @parameters: Opportunity Id
    * @return: List<Opportunity_Property__c>
    **/
    public  List<Opportunity_Property__c> getOpptyPropertyDetail(String opptyId){
         return [Select Id, ECM__c, Opportunity__r.ECM_Interview_Instance_Name__c, Opportunity__r.stageName from Opportunity_Property__c where Opportunity__c =: opptyId AND Opportunity__c != null limit 1];
    }
}