global class VerifyAccessFlowData 
{
    @InvocableVariable(required=true)
    public String loginType;

    @InvocableVariable(required=true)
    public String loginApplication;
    
    @InvocableVariable(required=true)
    public String loginPlatform;
    
    @InvocableVariable(required=true)
    public String loginUserAgent;
}