@RestResource(urlMapping = '/SearchServicesREST/*')
/**
 * SearchServicesREST.cls
 * Created on: 10/12/2011
 * Author: Priyanka Pallepati
 * Contains various webservice methods for the global search.
 */
global without sharing class SearchServicesREST {
    /**
     * This is the entry point to access the @HttpPost services within this class.
     */
    @HttpPost
    global static List < Customer_Address__c > searchAddressAccount(searchObject searchObj) {

        String userId = searchObj.userId;
        String searchParam = searchObj.searchParam;
        String onOff = searchObj.onOffTurf;
        String planId = searchObj.planId;
        
       
    List < String > retAccount = new List < String > ();
        String QueryParam = '';
        String phone_number = '';
        QueryParam = searchParam;
        List < String > addressids = new List < String > ();
        List < String > accountids = new List < String > ();
        List < Account > tempAcc = new List < Account > ();
        List < Contact > tempCon = new List < Contact > ();
        List < Customer_Address__c > addresses = new List < Customer_Address__c > ();
        List < Plan__c > planList = new List < Plan__c > ();
        Pattern isnumbers = Pattern.Compile('^[0-9]+$');
        Matcher searchMatch = isnumbers.matcher(searchParam);
        List < String > planIds = new List < String > ();
        map < Id, List < Customer_Address__c >> addressMap = new map < Id, List < Customer_Address__c >> ();
        
        

            List < String > regionList = new List < String > ();
            List < User > user = new List < User > ();
            user.addAll([Select Region__c from User where Id = : searchObj.userId]);
            for (User us: user) {
                regionList.add(us.Region__c);
               
            }
            
            Set<Id> contactAccountIds = new Set<Id>(); 
            if(searchMatch.Matches())
        {
          contactAccountIds = getContactAccountIds(QueryParam);
          
        }
        if(searchMatch.Matches())
        { 
        
         List<List<SObject>> addAccounts= [FIND :QueryParam IN ALL FIELDS RETURNING Account(id,Billing_Account_Number__c) limit 100];
          List<Account> tempAcc1 = new List<Account>();
          tempAcc1.addAll((List<Account>)addAccounts[0]);
         
         
          for(Account accId: tempAcc1)
          {
              retAccount.add(accId.Billing_Account_Number__c);
          }
          
        }
         
            
         
              // List<Contact> conList = [Select id,Phone,accountId from contact];
             // List<Customer_Address__c> AddressList = [Select id , Region__c ,Address__c ,Account__c from Customer_Address__c where Region__c IN :regionList  AND Account__c IN :ids];
        // List<id> ids1 = new List<id>();
      //  for(Customer_Address__c addressId: AddressList){
        //    ids1.add(addressId.id);
       // }
        
        //turf or playlist..
        if (onOff.equalsIgnoreCase('on')) {
           
            if (planId != null) {
               
                if (searchMatch.Matches()) {
                   
                    //has only numbers

                    //search addresses
                    // Sprint 4 DE70545 : (DSM - Analysis of Unexpected crash (defect story))Rahul Prabhakar
                    
                    
                    List<List<SObject>> addAddresses=[FIND :QueryParam IN ALL FIELDS  RETURNING Customer_Address__c (Address__c, Id, 
                    Account__c, Tap_Status__c, FormulaTapStatus__c, Parent_Address__c, Complex_Office__c, City__c, Plan__c, Latitude__c, 
                    Video_Active__c, Voice_Active__c, XH_Active__c, HSI_Active__c, longitude__c, Most_Recent_Disposition__c, Address_2__c, 
                    Status__c, Active_Inactive__c, State__c, PostalCode__c, Plan__r.User__r.Name, Digital_Serviceable__c, Internet_Serviceable__c, 
                    Voice_Serviceable__c, Dwelling_Type__c, Last_Disconnected_Date__c, Total_Monthly_Rate__c, Rejected_Reason__c ,
                    Account__r.Billing_Account_Number__c,Account__r.Phone__c,Account__r.Phone, Node__c where Plan__c = : planId ORDER BY Sort_Code__c limit 100)];
                    addresses.addAll((List<Customer_Address__c>)addAddresses[0]);
                    
                    
                    
                    List<Customer_Address__c> addAddresses2 = [select Address__c, Id, Account__c, Tap_Status__c, FormulaTapStatus__c, Parent_Address__c, 
                    Complex_Office__c, City__c, Plan__c, Latitude__c, Video_Active__c, Voice_Active__c, XH_Active__c, HSI_Active__c, longitude__c, 
                    Most_Recent_Disposition__c, Address_2__c, Status__c, Active_Inactive__c, State__c, PostalCode__c, Plan__r.User__r.Name, Digital_Serviceable__c, 
                    Internet_Serviceable__c, Voice_Serviceable__c, Dwelling_Type__c, Last_Disconnected_Date__c, Total_Monthly_Rate__c, Rejected_Reason__c 
                    ,Account__r.Billing_Account_Number__c,Account__r.Phone__c,Account__r.Phone, Node__c from customer_address__C 
                    where Plan__c = : planId and (Account__c IN: contactAccountIds OR Account__r.Billing_Account_Number__c IN :retAccount) and Region__c IN :regionList    ORDER BY Sort_Code__c limit 100];
            
                    addresses.addAll(addAddresses2 );
                    

                   

                } else {
                    
                    // Sprint 4 DE70545 : (DSM - Analysis of Unexpected crash (defect story))Rahul Prabhakar
                    List<List<SObject>> addAddresses=[FIND :QueryParam IN ALL FIELDS  RETURNING Customer_Address__c (Address__c, Id, Account__c, Tap_Status__c, FormulaTapStatus__c, Parent_Address__c, Complex_Office__c, City__c, Plan__c, Latitude__c, Video_Active__c, Voice_Active__c, XH_Active__c, HSI_Active__c, longitude__c, Most_Recent_Disposition__c, Address_2__c, Status__c, Active_Inactive__c, State__c, PostalCode__c, Plan__r.User__r.Name, Digital_Serviceable__c, Internet_Serviceable__c, Voice_Serviceable__c,Dwelling_Type__c, Last_Disconnected_Date__c, Total_Monthly_Rate__c, Rejected_Reason__c ,Account__r.Billing_Account_Number__c,Account__r.Phone__c ,Account__r.Phone, Node__c where Plan__c = : planId ORDER BY Sort_Code__c limit 100)];
                    addresses.addAll((List<Customer_Address__c>)addAddresses[0]);
                   
                }
            } else {
                planList.addAll([Select Id from Plan__c where User__c = : userId]);
                 
                for (Plan__c pln: planList) {
                    planIds.add(pln.Id);
                   
                }
               
                
               

                if (searchMatch.Matches()) {
                   
                    //has only numbers

                    //search addresses
                    // Sprint 4 DE70545 : (DSM - Analysis of Unexpected crash (defect story))Rahul Prabhakar
                    List<List<SObject>> addAddresses=[FIND :QueryParam IN ALL FIELDS  RETURNING Customer_Address__c (Address__c, Id, Account__c, Tap_Status__c, FormulaTapStatus__c, Parent_Address__c, Complex_Office__c, City__c, Plan__c, Latitude__c, Video_Active__c, Voice_Active__c, XH_Active__c, HSI_Active__c, longitude__c, Most_Recent_Disposition__c, Address_2__c, Status__c, Active_Inactive__c, State__c, PostalCode__c, Plan__r.User__r.Name, Digital_Serviceable__c, Internet_Serviceable__c, Voice_Serviceable__c,Dwelling_Type__c, Last_Disconnected_Date__c, Total_Monthly_Rate__c, Rejected_Reason__c ,Account__r.Billing_Account_Number__c,Account__r.Phone__c ,Account__r.Phone, Node__c where Plan__c IN: planIds ORDER BY Sort_Code__c limit 100)];
                    addresses.addAll((List<Customer_Address__c>)addAddresses[0]);
                    
                    List<Customer_Address__c> addAddresses2 = [select Address__c, Id, Account__c, Tap_Status__c, FormulaTapStatus__c, Parent_Address__c, 
                    Complex_Office__c, City__c, Plan__c, Latitude__c, Video_Active__c, Voice_Active__c, XH_Active__c, HSI_Active__c, longitude__c, 
                    Most_Recent_Disposition__c, Address_2__c, Status__c, Active_Inactive__c, State__c, PostalCode__c, Plan__r.User__r.Name, Digital_Serviceable__c, 
                    Internet_Serviceable__c, Voice_Serviceable__c, Dwelling_Type__c, Last_Disconnected_Date__c, Total_Monthly_Rate__c, Rejected_Reason__c 
                    ,Account__r.Billing_Account_Number__c,Account__r.Phone__c,Account__r.Phone, Node__c from customer_address__C 
                    where Plan__c IN: planIds and (Account__c IN: contactAccountIds OR Account__r.Billing_Account_Number__c IN :retAccount) and Region__c IN :regionList ORDER BY Sort_Code__c limit 100];
            
                    addresses.addAll(addAddresses2 );
                    

                    
                    
                } else {
                   
                    // Sprint 4 DE70545 : (DSM - Analysis of Unexpected crash (defect story))Rahul Prabhakar
                    List<List<SObject>> addAddresses=[FIND :QueryParam IN ALL FIELDS  RETURNING Customer_Address__c (Address__c, Id, Account__c, Tap_Status__c, FormulaTapStatus__c, Parent_Address__c, Complex_Office__c, City__c, Plan__c, Latitude__c, Video_Active__c, Voice_Active__c, XH_Active__c, HSI_Active__c, longitude__c, Most_Recent_Disposition__c, Address_2__c, Status__c, Active_Inactive__c, State__c, PostalCode__c, Plan__r.User__r.Name, Digital_Serviceable__c, Internet_Serviceable__c, Voice_Serviceable__c,Dwelling_Type__c, Last_Disconnected_Date__c, Total_Monthly_Rate__c, Rejected_Reason__c ,Account__r.Billing_Account_Number__c,Account__r.Phone__c ,Account__r.Phone, Node__c where Plan__c IN: planIds ORDER BY Sort_Code__c limit 100)];
                    addresses.addAll((List<Customer_Address__c>)addAddresses[0]);
                }
            }

        } else {
            planList.addAll([Select Id from Plan__c where User__c = : userId]);
             
            for (Plan__c pln: planList) {
                planIds.add(pln.Id);
               
            }
          

            if (searchMatch.Matches()) {
                 
                //has only numbers
                // Sprint 4 DE70545 : (DSM - Analysis of Unexpected crash (defect story))Rahul Prabhakar
                List<List<SObject>> addAddresses=[FIND :QueryParam IN ALL FIELDS  RETURNING Customer_Address__c (Address__c, Id, Account__c, Tap_Status__c, FormulaTapStatus__c, Parent_Address__c, Complex_Office__c, City__c, Plan__c, Latitude__c, Video_Active__c, Voice_Active__c, XH_Active__c, HSI_Active__c, longitude__c, Most_Recent_Disposition__c, Address_2__c, Status__c, Active_Inactive__c, State__c, PostalCode__c, Plan__r.User__r.Name, Digital_Serviceable__c, Internet_Serviceable__c, Voice_Serviceable__c,Dwelling_Type__c, Last_Disconnected_Date__c, Total_Monthly_Rate__c, Rejected_Reason__c ,Account__r.Billing_Account_Number__c,Account__r.Phone__c ,Account__r.Phone, Node__c where Region__c in : regionList and Plan__c NOT in : planIds  ORDER BY Sort_Code__c limit 100)];
                addresses.addAll((List<Customer_Address__c>)addAddresses[0]);
               
                
                List<Customer_Address__c> addAddresses2 = [select Address__c, Id, Account__c, Tap_Status__c, FormulaTapStatus__c, Parent_Address__c, 
                    Complex_Office__c, City__c, Plan__c, Latitude__c, Video_Active__c, Voice_Active__c, XH_Active__c, HSI_Active__c, longitude__c, 
                    Most_Recent_Disposition__c, Address_2__c, Status__c, Active_Inactive__c, State__c, PostalCode__c, Plan__r.User__r.Name, Digital_Serviceable__c, 
                    Internet_Serviceable__c, Voice_Serviceable__c, Dwelling_Type__c, Last_Disconnected_Date__c, Total_Monthly_Rate__c, Rejected_Reason__c 
                    ,Account__r.Billing_Account_Number__c,Account__r.Phone__c,Account__r.Phone, Node__c from customer_address__C 
                    where Plan__c NOT IN: planIds and (Account__c IN: contactAccountIds OR Account__r.Billing_Account_Number__c IN :retAccount) and Region__c IN :regionList ORDER BY Sort_Code__c limit 100];
            
                    addresses.addAll(addAddresses2 );
                
                

               
            } else {
               
                // Sprint 4 DE70545 : (DSM - Analysis of Unexpected crash (defect story))Rahul Prabhakar
                List<List<SObject>> addAddresses=[FIND :QueryParam IN ALL FIELDS  RETURNING Customer_Address__c (Address__c, Id, Account__c, Tap_Status__c, FormulaTapStatus__c, Parent_Address__c, Complex_Office__c, City__c, Plan__c, Latitude__c, Video_Active__c, Voice_Active__c, XH_Active__c, HSI_Active__c, longitude__c, Most_Recent_Disposition__c, Address_2__c, Status__c, Active_Inactive__c, State__c, PostalCode__c, Plan__r.User__r.Name, Digital_Serviceable__c, Internet_Serviceable__c, Voice_Serviceable__c,Dwelling_Type__c, Last_Disconnected_Date__c, Total_Monthly_Rate__c, Rejected_Reason__c ,Account__r.Billing_Account_Number__c,Account__r.Phone__c , Account__r.Phone, Node__c where Region__c in : regionList and Plan__c NOT in : planIds ORDER BY Sort_Code__c limit 100)];
                addresses.addAll((List<Customer_Address__c>)addAddresses[0]);

                
            }
        }

        Set < Customer_Address__c > myset = new Set < Customer_Address__c > ();
        List < Customer_Address__c > result = new List < Customer_Address__c > ();
        for (Customer_Address__c s: addresses) {
            if (myset.add(s)) {
                result.add(s);
            }
        }
       
         
        return modifySearchResult(result);
      

    }
    global static List < Customer_Address__c > modifySearchResult(List < Customer_Address__c > resultToBeModified) {
       
        List < ID > parentAddressId = new List < ID > ();
        List < Customer_Address__c > parentAddress = new List < Customer_Address__c > ();
        for (Customer_Address__c ca: resultToBeModified) {
            if (ca.Parent_Address__c != null) {
                
                parentAddressId.add(ca.Parent_Address__c);
                
            }
            
         

        }
    
        // Sprint 4 DE70545 : (DSM - Analysis of Unexpected crash (defect story))Rahul Prabhakar
        parentAddress.addAll([Select Address__c, Id, Account__c, Complex_Office__c, Tap_Status__c, FormulaTapStatus__c, City__c, ca.Plan__c, latitude__c, longitude__c, Video_Active__c, Voice_Active__c, XH_Active__c, HSI_Active__c, Most_Recent_Disposition__c, Address_2__c, Status__c, Active_Inactive__c, State__c, PostalCode__c, Plan__r.User__r.Name, Digital_Serviceable__c,Internet_Serviceable__c,Voice_Serviceable__c,Dwelling_Type__c, Last_Disconnected_Date__c, Total_Monthly_Rate__c, Rejected_Reason__c ,Account__r.Billing_Account_Number__c,Account__r.Phone__c ,Account__r.Phone, Node__c FROM Customer_Address__c ca WHERE Id in : parentAddressId ORDER BY Sort_Code__c]);
        List < Customer_Address__c > finalResult = new List < Customer_Address__c > ();
        finalResult.addAll(resultToBeModified);
        finalResult.addAll(parentAddress);
       
        return finalResult;
        
    }
    public static Set<Id> getContactAccountIds(String phoneParam)
    {
        
    Set<id> retAccountIds = new Set<Id>();
    
    try
    {     
          List<List<SObject>> addContacts= [FIND :phoneParam IN PHONE FIELDS RETURNING contact(id, AccountId) limit 100];
          List<Contact> tempCon = new List<Contact>();
          tempCon.addAll((List<Contact>)addContacts[0]);
         
         
          for(Contact accId: tempCon)
          {
              retAccountIds.add(accId.AccountId);
          }
         
          
    }
    catch (Exception e)
    {
      // ignore
    }
    return retAccountIds;
   }
    

    global class searchObject {


        global String searchParam;
        global String onOffTurf;
        global String userId;
        global String planId;
        
     
    

    }
}