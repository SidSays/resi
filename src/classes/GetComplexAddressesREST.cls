@RestResource(urlMapping='/GetComplexAddressesREST/*')

global without sharing class GetComplexAddressesREST {
    
    @HttpGet  
    global static List<Customer_Address__c> getAddressesById(){
        String userId = RestContext.request.params.get('userId');
        return [SELECT Address__c, Id, Account__c, Complex_Office__c, Status__c, Total_Monthly_Rate__c, Last_Knock_Date__c,
                    City__c, PostalCode__c, State__c, Video_Active__c, Voice_Active__c, XH_Active__c, XSS_Active__c, 
                    Past_Due_Balance__c, Disconnect_Reason__c, Address_2__c, Billing_Account_Key__c, Non_Marketable__c,
                    Property_Code__c, Dwelling_Type__c, Do_not_Call__c, Do_not_Email__c, Do_not_Knock__c, Corp__c,Node__c,
                    Route_Code__c, Location_ID__c, HSI_Active__c, Installation_Status__c, Last_Install_Date__c, Disconnect_Days__c,
                    Last_Disconnected_Date__c, Write_Off_Amount__c, Latitude__c, Verizon_Wireless_Active__c, Longitude__c, 
                    Most_Recent_Disposition__c, Parent_Address__c, Tap_Status__c, FormulaTapStatus__c, Sort_Code__c, Renewal_Status_Time__c,
                    Renewal_Status_Timeframe__c, Video_Contract__c, Voice_Contract__c, Internet_Contract__c, Contract_Expiration_Date__c, Digital_Serviceable__c,Internet_Serviceable__c,Voice_Serviceable__c, OwnerId, Plan__c, Rejected_Reason__c, NCLV_Reg_Decile__c 
                FROM Customer_Address__c WHERE ownerid = :userId and complex_office__c = true];
    }

}