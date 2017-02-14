public class VerifyAccessForBusinessPartners
{
    @InvocableMethod
    public static List<String> hasBPAccessToSFDC(List<VerifyAccessFlowData> flowData) 
    {
        String valid_login_type = 'false';
        String login_application = '';
        
        List<String> retStr = new List<String>();
        try
        {
            System.debug('*** User Id: '+ UserInfo.getUserId());
            String userid = UserInfo.getUserId();
            
            if(String.isNotBlank(userId))
            {
                if(!flowData.isEmpty())
                {
                    VerifyAccessFlowData data = (VerifyAccessFlowData) flowData.get(0);
                    if(data != null)
                    {
                        String loginType = (String) data.loginType;
                        String loginApplication = (String) data.loginApplication;
                        String loginPlatform = (String) data.loginPlatform;
                        String loginUserAgent = (String) data.loginUserAgent;
                
                        if(String.isNotBlank(loginType) && String.isNotBlank(loginPlatform) 
                            && String.isNotBlank(loginUserAgent))
                        {    
                            // ipad, bundle = Direct Sales xx.xx, 
                            if(loginPlatform.contains('iPad') 
                                && loginUserAgent.contains('Direct Sales')
                                && (loginType.contains('SSO') || 
                                    (loginType.contains('Remote') && loginApplication.contains('Direct Sales Mobile'))))
                            {
                                if(loginUserAgent.contains('WebKit') && loginUserAgent.contains('Mobile') 
                                    && !loginUserAgent.contains('Safari'))
                                {
                                    valid_login_type = 'true';
                                }
                            }
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
        
        system.debug('*** Login_Type:' +loginType + '; Login_Application:' +loginApplication+'; Login_Platform:' 
        + loginPlatform + '; Login_UserAgent:' + loginUserAgent );
                
        LoginFlow_LoginType: Application 
        LoginFlow_Platform:Mac OSX 
        
        LoginFlow_LoginType: Remote Access Client
        LoginFlow_Platform:iPad
    
    */
}