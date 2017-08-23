/***************************************************************************************************************************************
 * Author     : Malay Desai, Accenture
 * Date       : 24-July-2017
 * Description: For managing Error Messages stored in Error_Message__mdt
  
***************************************************************************************************************************************/
public with sharing class ErrorMessages{
	
    /*
	 * @Author     : Malay Desai, Accenture
     * @Date       : 24-July-2017
     * @param	   : Name,Where is it used?, Component Type
     * @return	   : Error Message
     * @Description: For retrieving Error Messages stored in Error_Message__mdt
     * @User Story : US1112416 (and many more in future)
	*/
    public static String getErrorMessage(String messageName,String whereUsed, String type) {                 
        
        List<Error_Message__mdt> errorMessage = [SELECT Value__c FROM Error_Message__mdt 
                                                 WHERE DeveloperName=:messageName
                              					 AND Where_is_it_used__c=:whereUsed
                              					 AND Type_of_component__c=:type 
                              					 LIMIT 1];
        if(!errorMessage.isEmpty()) {
            return errorMessage.get(0).Value__c;
        }
        return null;
    }
    
    /*
	 * @Author     : Malay Desai, Accenture
     * @Date       : 24-July-2017
     * @param	   : Name,Where is it used?, Component Type
     * @return	   : List of Error Messages
     * @Description: For retrieving Error Messages stored in Error_Message__mdt
	*/
    public static List<String> getErrorMessages(String whereUsed, String type) {                 
        List<String> retValues;
        List<Error_Message__mdt> errorMessages = [SELECT Value__c FROM Error_Message__mdt 
                                                  WHERE Where_is_it_used__c=:whereUsed
                              					  AND Type_of_component__c=:type];
        if(!errorMessages.isEmpty()) {
            retValues = new List<String>();
            for(Error_Message__mdt em : errorMessages){
                retValues.add(em.Value__c);
            }
            return retValues;
        }
        return null;
    }
	
    /*
	 * @Author     : Malay Desai, Accenture
     * @Date       : 24-July-2017
     * @param	   : Name,Where is it used?, Component Type
     * @return	   : Error Message
     * @Description: For retrieving Error Messages stored in Error_Message__mdt
	*/
    public static String getErrorMessage(String messageName) {                 
        List<Error_Message__mdt> errorMessage = [SELECT Value__c FROM Error_Message__mdt 
                                                 WHERE DeveloperName=:messageName
                              					 LIMIT 1];
        if(!errorMessage.isEmpty()) {
            return errorMessage.get(0).Value__c;
        }
        return null;
    }
}