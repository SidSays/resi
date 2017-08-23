public class VerifyFlowRetrieve
{
    @InvocableMethod
    public static List<String> getTC() 
    {
        String tc_date = '';
        String user_role = '';
        
        List<String> retStr = new List<String>();
        try
        {
            System.debug('*** userId: '+ UserInfo.getUserId());
            String userid = UserInfo.getUserId();
            
            if(String.isNotBlank(userId))
            {
                User usr = [SELECT Id, terms_and_conditions_accepted__c, userrole.name FROM user WHERE id =:userId];
                tc_date = String.valueOf(usr.terms_and_conditions_accepted__c);
                retStr.add(tc_date);
            }
        }
        catch(Exception e)
        {
            tc_date = '';
            System.debug('*** Exception occurred while retrieving the user T&C data: ' + e.getMessage());
        }
        return retStr;
    }
}