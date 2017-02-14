@RestResource(urlMapping='/GetPlanServicesREST4/*')
/**
* GetPlanServices.cls
*Mangesh Godse  09/28/2015 : Optimized code as part of performance improvement : US564420
*/
global without sharing class GetPlanServicesREST4 {
  
    /**
     * This is the entry point to access the @HttpGet services within this class.
     */   
    @HttpGet   
    global static List<Address> getAddresses(){
List<Address> addressList = new List<Address>();
      try
      {
        String parentPlanId = RestContext.request.params.get('parentPlanId');
        Integer page = Integer.valueOf( RestContext.request.params.get('page') );
        Boolean hasUpdatedResults = false;
        Integer MAX_RETURN = 2000;
        Integer RECORD_LIMIT = 250;
        Integer offSet = Math.min( (page-1) * RECORD_LIMIT, MAX_RETURN );
        Decimal totalAddressRecords = 0;
        Set<id> parentAddressIds = new Set<id>();
        
        
        Set<Id> addressIDs=new Set<Id>();
        for(Task userTask: [SELECT id, WhatId FROM Task WHERE Type__c!='Knock' AND (ActivityDate >=TODAY OR Status!='Completed') AND CreatedById=:UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 3]){
            addressIDs.add(userTask.WhatId);
        }
        for(Event userEvent: [SELECT id, WhatId FROM Event WHERE StartDateTime>=TODAY AND CreatedById=:UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 3]){
            addressIDs.add(userEvent.WhatId);
        }
        
        
        Set<Plan__c> planSet = new Set<Plan__c>();
        planSet.add(new Plan__c(Id = parentPlanId));

        //Get any parent addresses from the addresses in the Plan. Later we will return the parent addresses as well.
        for(AggregateResult r : [SELECT COUNT_DISTINCT(id), Parent_Address__c FROM Customer_Address__c WHERE Plan__c IN :planSet AND Parent_Address__c != null GROUP BY Parent_Address__c] ){
            parentAddressIds.add( (ID)r.get('Parent_Address__c') );
        }
        
        Map<id,Customer_Address__c> addressMap = new Map<id,Customer_Address__c>( 
                            [SELECT Account_Name__c,Address__c, Id, Account__c, Complex_Office__c, Status__c, Active_Inactive__c, Total_Monthly_Rate__c, Last_Knock_Date__c,
                                    City__c, PostalCode__c, State__c, Video_Active__c, Voice_Active__c, XH_Active__c, XSS_Active__c, 
                                    Past_Due_Balance__c, Disconnect_Reason__c, Address_2__c, Billing_Account_Key__c, Non_Marketable__c,
                                    Property_Code__c, Dwelling_Type__c, Do_not_Call__c, Do_not_Email__c, Do_not_Knock__c, Corp__c,Node__c,
                                    Route_Code__c, Location_ID__c, HSI_Active__c, Installation_Status__c, Last_Install_Date__c, Disconnect_Days__c,
                                    Last_Disconnected_Date__c, Write_Off_Amount__c, Latitude__c, Verizon_Wireless_Active__c, Longitude__c, 
                                    Most_Recent_Disposition__c, Parent_Address__c, Tap_Status__c, FormulaTapStatus__c, Sort_Code__c, Renewal_Status_Time__c,
                                    Renewal_Status_Timeframe__c, Video_Contract__c, Voice_Contract__c, Internet_Contract__c, Contract_Expiration_Date__c, Customer_Name__c, Digital_Serviceable__c,Internet_Serviceable__c,Voice_Serviceable__c, OwnerId, Plan__c, Rejected_Reason__c, NCLV_Reg_Decile__c, Targeted__c,Non_Marketable_Reason__c 
                                    FROM Customer_Address__c WHERE (Plan__c IN :planSet OR id IN :parentAddressIds OR Id IN: addressIDs)] );
                              
        if(addressMap != null && addressMap.size() > 0){
            totalAddressRecords = addressMap.size();
        }
        Set<Id> accId = new Set<Id>();
        for(Customer_Address__c cusAdd: addressMap.values()){
            accId.add(cusAdd.Account__c);
        }
 
        RetrieveAllAccounts__c retrieveAccCustomSet = RetrieveAllAccounts__c.getValues('GetPlanServicesREST4');

        Map<id,Account> accountMap;
        // Added the Field In the Account Query CustomerNameForDSM. Sprint15.6.1 sprint 2.
        if(retrieveAccCustomSet.isActive__c){
            accountMap = new Map<id,Account>( [SELECT Billing_Account_Number__c, Id, Service_Address__c, Phone, BillingStreet, Name, Customer__c, FormulaContactName__c, FormulaPhone__c, LastModifiedDate, Total_Monthly_Rate__c, Customer_Status__c, Active_Inactive__c, Write_Off_Amount__c, Past_Due_Balance__c, Installation_Status__c, Last_Install_Date__c, Last_Disconnected_Date__c, Disconnect_Reason__c, Disconnect_Days__c,CustomerNameForDSM__c,
                                                              (SELECT AccountId, Product2.name, Name, InstallDate, Status, LastModifiedDate FROM Assets),
                                                              (Select Name, AccountId From Contacts)
                                                            FROM Account WHERE Service_Address__c IN :addressMap.keySet()] );
        }
        if(!retrieveAccCustomSet.isActive__c){
            accountMap = new Map<id,Account>( [SELECT Billing_Account_Number__c, Id, Service_Address__c, Phone, BillingStreet, Name, Customer__c, FormulaContactName__c, FormulaPhone__c, LastModifiedDate, Total_Monthly_Rate__c, Customer_Status__c, Active_Inactive__c, Write_Off_Amount__c, Past_Due_Balance__c, Installation_Status__c, Last_Install_Date__c, Last_Disconnected_Date__c, Disconnect_Reason__c, Disconnect_Days__c,CustomerNameForDSM__c,
                                                              (SELECT AccountId, Product2.name, Name, InstallDate, Status, LastModifiedDate FROM Assets),
                                                              (Select Name, AccountId From Contacts)
                                                            FROM Account WHERE ID IN :accId] );
       
        }
        

        Map<Id,String> contactAccountMap=new Map<Id,String>();
        
        Map<id,List<Accounts>> addressIdToAccountMap = new Map<id,List<Accounts>>();
        for(Account acct : accountMap.values()){
            //adding the contact names to the field to show the customer Name From contacts sprint 15.6.1 sprint 2.
             if(acct.Contacts != null){
                for(Contact c : acct.Contacts){
                    acct.CustomerNameForDSM__c = c.Name;
                    contactAccountMap.put(c.AccountId,c.Name);
                }
            }
            
            Accounts a = new Accounts();
            a.custAccount = acct;
           
            List<Accounts> tempAccounts = new List<Accounts>();
            if( addressIdToAccountMap.get(acct.Service_Address__c) == null ){
                tempAccounts.add( a );
            }else{
                tempAccounts = addressIdToAccountMap.get( acct.Service_Address__c );
                tempAccounts.add( a );
            }
            addressIdToAccountMap.put( acct.Service_Address__c, tempAccounts );
        }

        //List<Address> addressList = new List<Address>();
        for(Customer_Address__c address : addressMap.values()){
            Address a = new Address();
            a.custAddress = address;
            a.customerName=contactAccountMap.get(address.Account__c);
            a.accList = addressIdToAccountMap.get( address.id );
            addressList.add( a );
        }
        if( totalAddressRecords != 0 ){//Need this to prevent index out of bounds error
            addressList[0].ExceedsAddressLimit =  totalAddressRecords > MAX_RETURN;
            addressList[0].hasNext = offset + RECORD_LIMIT < Math.Min( totalAddressRecords, MAX_RETURN );//(page == (MAX_RETURN/RECORD_LIMIT)) ? false : (
        }
        
}
catch(Exception e)
{
system.debug('Error Received=' +e.getmessage());
}
      return addressList;
      
    }
    
       
}