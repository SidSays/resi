global class VerifyFlowAction 
{
    @InvocableMethod
    public static void updateTC(List<String> usrIds) {
        try
        {
            System.debug('*** userIds: '+ usrIds);
            if(!usrIds.isEmpty())
            {
                String idstr = usrIds.get(0);
                User usr = [SELECT Id, terms_and_conditions_accepted__c FROM user WHERE id =:idstr];
                usr.terms_and_conditions_accepted__c = System.today();
                update usr;
            }
        }
        catch(Exception e)
        {
            //
        }
        return;
    }
    

}