/***************************************************************************************************************************************
 * Author     : Anil Singh
 * Date       : 1-April-2015
 * Description: Class UpdateFederationIdPilotUser that checks federation ID is populated for pilot users , This cannot be performed by using a validation rule.Since, the standard field 'FederationIdentifier'cannot be used inside a validation rule
 * Requirement: 00014929
***************************************************************************************************************************************/
// Class that checks federation ID is populated for pilot users
public Class UpdateFederationIdPilotUser{

    //Method that checks federation ID is populated for pilot users
    public static void UpdateFederationId(List<user> userList){
        for(user userObj: userList){
            if(userObj.Pilot_User__c == True && userObj.FederationIdentifier == null){
                
                //Error thrown on user object federation ID is not populated for pilot users
                userObj.FederationIdentifier.addError('Pilot User should have a federation ID');
                //userObj.adderror('Pilot User should have a federation ID');
            }
        }
    }
}