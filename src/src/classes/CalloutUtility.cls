public class CalloutUtility
{
    // Generate Nonce as random number base64 encoded
    public static String generateNonce()
    {
        String nonce = Datetime.now().format('yyyyMMddHHmmssSSS');
        try
        {
            String dtStr = Datetime.now().format('ssSSS');
            String randomStr = String.valueOf(Crypto.getRandomInteger());
      
            nonce = EncodingUtil.base64Encode(Blob.valueOf(dtStr + randomStr ));
            // System.debug('*** NONCE: ' + nonce);
        }    
        catch(Exception e)
        {
            nonce = Datetime.now().format('yyyyMMddHHmmssSSS');
            System.debug('*** Exception occurred while generating NONCE: '+ e.getMessage());
        }
        return nonce;
    } 
    // Generate tracking id
    public static String generateTrackingId()
    {
        String returnTrackingId = Datetime.now().format('yyyyMMddHHmmssSSS');
        try
        {
            Long trackingId = Crypto.getRandomLong();
            if(trackingId < 0)
            {
                trackingId = trackingId * -1;
            }
    
            String trackingIdPrefix = Datetime.now().format('ssSSS');
    
            returnTrackingId = trackingIdPrefix + trackingId;
            //System.debug('*** returnTrackingId: ' + returnTrackingId);
        }    
        catch(Exception e)
        {
            returnTrackingId= Datetime.now().format('yyyyMMddHHmmssSSS');
            System.debug('*** Exception occurred while generating TRACKING ID: '+ e.getMessage());
        }
        
        return returnTrackingId;
    } 
    
    // generate timestamp
    public static String generateTimestamp()
    {
        return Datetime.now().format('yyyy-MM-dd\'T\'hh:mm:ss.SSS');
    }
}