/************************************************************************************************************************************************************
Name: Mdu_ApplicationLogger 
Description: This class is used to Capture the Apex Execution Flow.
Author: Ashish Sonawane(Accenture)
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
25 March 2015 Comcast  
*************************************************************************************************************************************************************/
public class MDU_ApplicationLogger{
    
   
    /**
    * Name : logStart
    * Description: : This method is used to create the Request Start execution message . 
    * Parameter : String requestName  , executionLog , isApplicationFlagEnable
    * @return: executionLog Message 
    */  
    public static String  logStart(String requestName , String executionLog,boolean isApplicationFlagEnable){                
        if(isApplicationFlagEnable){
            executionLog += MDU_Constants.NL_NL_REQUEST_NAME + requestName;
            executionLog += MDU_Constants.NL_START_TIME + MDU_EmptorisUtility.SetNow(); 
        }             
        return executionLog ;       
    }
    
      
    /**
    * Name : logMessage
    * Description: : This method is used to create the execution message .
    * Parameter : String requestName  , executionLog , isApplicationFlagEnable
    * @return: executionLog Message 
    */  
    public static String  logMessage(String requestName , String executionLog,boolean isApplicationFlagEnable){                
        if(isApplicationFlagEnable){
            executionLog += MDU_Constants.LOG_MESSAGE + requestName;    
        }             
        return executionLog ;       
    }
    
    /**
    * Name : logEnd
    * Description: : This method is used to create the Request End execution message . 
    * Parameter :  String responseData , executionLog , isApplicationFlagEnable
    * @return: executionLog Message 
    */  
    public static String  logEnd(String responseData, String executionLog, boolean isApplicationFlagEnable){             
        if(isApplicationFlagEnable){
            executionLog += MDU_Constants.NL_END_TIME + MDU_EmptorisUtility.SetNow();
            executionLog += MDU_Constants.NL_RESPONSE + responseData;    
        }          
        return executionLog ;       
    }
    
    /**
    * Name : createLog
    * Description: : Here we are adding application log data for Request Start 
    * Parameter : String requestName  , executionLog , isApplicationFlagEnable
    * @return: String 
    */  
    public static void createLog(String finalLogMessage , boolean isApplicationFlagEnable 
                                 , DateTime startTime , DateTime endTime){                
        if(isApplicationFlagEnable){
            Application_Log__c objApplicationLog = new Application_Log__c();
            objApplicationLog.Start_Time__c = startTime;
            objApplicationLog.End_Time__c = endTime;
           
            Integer len= Application_Log__c.Log_Message__c.getDescribe().getLength();
            if(finalLogMessage.length()>len){
                finalLogMessage =  finalLogMessage.Substring(0, len);
            }
            
            objApplicationLog.Log_Message__c = finalLogMessage;
            objApplicationLog.Elapsed_time__c = String.valueOf(endTime.getTime() - startTime.getTime());
            try{
                Database.insert(objApplicationLog);
            }catch(Exception objEx){
                System.debug('Error Message >>>>'+ objEx.getMessage());
            }
        }                     
    }
}