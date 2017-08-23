public class UniversalCaseOpenId
{

    public static String getToken(String code)
    {
        System.debug('*** VJ OpenId.getToken: ' +code);
        String clientId = 'nsosfdcclient';
        String clientSecret = 'e166481280e74fb4b5ee2a6386e2fa7b';
        String returnToken = '';
        String grant_type='authorization_code';
        
        String redirect_uri='http://uat-onecomcast.cs67.force.com/case' ;
        // code=0KRPeGj3a68Flfi6eUpflzxJVCDLZf_gZjKa_gAD
        
        try
        {
            if(code != null || code !='')
            {
                // make api call and get auth token
                HttpRequest req = new HttpRequest();
                
                req.setEndpoint('https://websec-stg.cable.comcast.com/as/token.oauth2');
                
                String bodyStr = 'code='+EncodingUtil.urlEncode(code,'UTF-8')+'&grant_type='+EncodingUtil.urlEncode('authorization_code','UTF-8')+'&client_id='+EncodingUtil.urlEncode(clientId,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8');
                bodyStr += '&redirect_uri='+redirect_uri;
        
                System.debug('*** VJOpenId.getToken.bodyStr: ' +bodyStr);
                req.setBody(bodyStr);
                req.setMethod('POST');
                req.setHeader('Content-Type','application/x-www-form-urlencoded') ;

                Http http = new Http();
                HTTPResponse res = http.send(req);

                returnToken = res.getBody();   
                
                System.debug('*** HTTP RESPONSE: ' +   returnToken);           
            }
        } catch(Exception e)
        {
            // 
        }
        return returnToken;
    }
    
    public static UniversalToken parseToken(String json) 
    {
        UniversalToken vToken = null;
        try
        {
            vToken = (UniversalToken) System.JSON.deserialize(json, UniversalToken.class);
        }
        catch(Exception e)
        {
            //
        }
        return vToken;
    }

    
    public static UniversalUserToken decodePayload(String tokenValue)
    {
        String dot = '.';
        Integer result = tokenValue.indexOf(dot);
        String firstPart = tokenValue.substring(0,result);

        String middlePart = tokenValue.substring(result+1, tokenValue.length());
        result = middlePart.indexOf(dot);
        middlePart = middlePart.substring(0,result);
        
        String endPart = tokenValue.substring(result+1, tokenValue.length());
        
        System.debug('*** firstPart: '+ firstPart + '; middlepart: '+ middlePart + ';endPart: '+ endPart);

        Blob b = EncodingUtil.base64Decode(middlePart);
        String decodeToken = b.toString();
        
        UniversalUserToken returnToken = UniversalUserToken.parse(decodeToken);
        System.debug('***** decoded: ' + decodeToken);
        return returnToken ;
    }
    
   

}