public class VerifyFlowRetrieveContractor
{
    @InvocableMethod
    public static List<String> getContractorAccessToSFDC(List<VerifyFlowRetrieveData> flowData) 
    {
        String valid_login_type = 'false';
        String login_application = '';
        
        List<String> retStr = new List<String>();
        try
        {
            System.debug('*** userId: '+ UserInfo.getUserId());
            String userid = UserInfo.getUserId();
            
            if(String.isNotBlank(userId))
            {
                if(!flowData.isEmpty())
                {
                    VerifyFlowRetrieveData data = (VerifyFlowRetrieveData) flowData.get(0);
                    if(data != null)
                    {
                        String loginType = (String) data.loginType;
                        String loginApplication = (String) data.loginApplication;
                        
                        system.debug('loginType:' +loginType);
                         system.debug('loginApplication:' +loginApplication);
                        
                        if(String.isNotBlank(loginType) && loginType.contains('Remote Access') && 
                            ('Browser' == loginApplication || 'Direct Sales Mobile'==loginApplication))
                        {
                            valid_login_type = 'true';
                        }
                    }
                }
            }
        }
        catch(Exception e)
        {
            //
            valid_login_type = 'false';
        }
        
        retStr.add(valid_login_type);
        return retStr;
    }

    /*
    
        LoginFlow_LoginType: Application 
        LoginFlow_Platform:Mac OSX 
        
        LoginFlow_LoginType: Remote Access Client
        LoginFlow_Platform:iPad
    
    */
}