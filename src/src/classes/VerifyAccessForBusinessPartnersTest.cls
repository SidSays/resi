@isTest
public class VerifyAccessForBusinessPartnersTest
{
    @isTest static void testAccessForBPFlow() 
    {
        List<VerifyAccessFlowData> flowAttributes = new List<VerifyAccessFlowData>();
        
        VerifyAccessFlowData data = new VerifyAccessFlowData();
        data.loginType = 'SAML Sfdc Initiated SSO';
        data.loginApplication = 'Browser';
        data.loginPlatform = 'iPad';
        data.loginUserAgent = 'SalesforceMobileSDK/3.3.1 iPhone OS/9.3.1 Direct Sales/2.0 Hybrid uid_C3652A74-B2D0-43C5-AAEC-439731B5D647 Mozilla/5.0 (iPad; CPU OS 9_3_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13E238';
 
        flowAttributes.add(data);
        
        VerifyAccessForBusinessPartners.hasBPAccessToSFDC(flowAttributes);
    }
}