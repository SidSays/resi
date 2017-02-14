public class BillingAccountNumberUtility {
    public static List<String> generateAccount(String billingaccountnumber) {
        try{
        List<String> storeBillingAccountNumber = new List<String>();
        Long i;
        i=long.valueof(billingaccountnumber);
        while ( true ) {
            String val=string.valueOf(i);
            for(integer j=0;j<(13-val.length());j++){
         val='0'+val;           
                }
            
           storeBillingAccountNumber.add(val);
             if(math.mod(i,100)==0){
                break;            
            }
            i--;
        }
       
     return storeBillingAccountNumber; 
  }
   
    catch(Exception e){
        system.debug('Following Error Occurred'+e.getMessage());
    return null;  
    }
         
  }
}