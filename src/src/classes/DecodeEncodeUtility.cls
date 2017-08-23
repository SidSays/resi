/**************************************************************************************************
* Name : DecodeEncodeUtility
* Description : Decode encrypted data
* User Story : US1024537(Indirect - Coach for Indirect - Retail Sales Rep - RGU Goal - Metric Targets and Actuals)
* Date : 21 April 2017
* Author : Animesh Datta
***************************************************************************************************/
public class DecodeEncodeUtility{
    
    //Provide encrypted Data as input value
    //Method will return decrypted String value
    public static String decodeData(String inputValue){
    
        Blob afterblob = EncodingUtil.base64Decode(inputValue);
        return afterblob.toString();  
    }
}