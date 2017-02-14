@isTest
public class BillingAccountNumberUtilityTest{
   
    public static testMethod void generateAccountTest(){        
        String billingaccountnumber = '12345678908';
        BillingAccountNumberUtility billngUtilClassObj = new BillingAccountNumberUtility();
        BillingAccountNumberUtility.generateAccount(billingaccountnumber);
    }
}