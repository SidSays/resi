@isTest
public class VerifyFlowRetrieveContractorTest
{
    @isTest static void testContractorFlow() 
    {
        List<VerifyFlowRetrieveData> flowAttributes = new List<VerifyFlowRetrieveData>();
        
        VerifyFlowRetrieveData data = new VerifyFlowRetrieveData();
        data.loginType = 'Remote Access';
        data.loginApplication = 'Direct Sales Mobile';
 
        flowAttributes.add(data);
        
        VerifyFlowRetrieveContractor.getContractorAccessToSFDC(flowAttributes);
    }
}