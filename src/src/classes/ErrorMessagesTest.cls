/***************************************************************************************************************************************
 * Author     : Malay Desai, Accenture
 * Date       : 24-July-2017
 * Description: Test class for ErrorMessages
  
***************************************************************************************************************************************/
@isTest
public class ErrorMessagesTest {
	private static final String NO_RECORDS_FOUND = 'No_records_found';
    private static final String DUMMY = 'Dummy';
    private static final String COACHING_TIMELINE = 'CoachingTimeline';
    private static final String LIGHTNING_COMPONENT = 'Lightning Component';
    
    @isTest
    public static void getErrorMessageTest(){
        
        Error_Message__mdt em = [SELECT Value__c FROM Error_Message__mdt 
                                 WHERE DeveloperName = :NO_RECORDS_FOUND LIMIT 1];
        System.assertNotEquals(null, ErrorMessages.getErrorMessage(NO_RECORDS_FOUND));
        System.assertEquals(null, ErrorMessages.getErrorMessage(DUMMY));
        System.assertNotEquals(null, 
                            ErrorMessages.getErrorMessage(NO_RECORDS_FOUND,COACHING_TIMELINE, LIGHTNING_COMPONENT)); 
        System.assertEquals(null, 
                            ErrorMessages.getErrorMessage(DUMMY,DUMMY,DUMMY));
    }
    
    @isTest
    public static void getErrorMessagesTest(){
        List<String> str ;
        List<Error_Message__mdt> ems = [SELECT Value__c FROM Error_Message__mdt 
                                 WHERE Where_is_it_used__c=:COACHING_TIMELINE
                              	 AND Type_of_component__c=:LIGHTNING_COMPONENT];
        str = ErrorMessages.getErrorMessages(COACHING_TIMELINE,LIGHTNING_COMPONENT);
        System.assertEquals(str.size(),ems.size());       
        str = ErrorMessages.getErrorMessages(DUMMY,DUMMY);
        
        System.assertEquals(str,null);   
    }
}