/* Code Modified on : 27th April 2017
       Developer : Joognu Rao
       Description : DSM - Display Territory and Territory Owner on Address Detail.
       User Story no: US1090379, Sprint 53. */

@RestResource(urlMapping='/GetAddressByIdREST/*')

global without sharing class GetAddressByIdREST {
    
     @HttpGet  
 global static List<Address> getAddressesById()
    {
      String addressId = RestContext.request.params.get('addressId');
      
     /* if(!Test.isRunningTest()){
          UpdateInformationInSalesforce.cAddress wsaddress = new UpdateInformationInSalesforce.cAddress();
          List<Customer_Address__c> addressesForWebService=[SELECT Billing_House_Key__c FROM Customer_Address__c WHERE Id = :addressId];
          wsaddress.billingHouseKey = addressesForWebService.get(0).Billing_House_Key__c;
          String status = UpdateInformationInSalesforce.getUpdateStatus(wsaddress);
        }
        */
        
         List<Address> addressList = new List<Address>();
        List<Customer_Address__c> addList = new List<Customer_Address__c>();
        
       
        List<Account> accList = new List<Account>();
        List<Accounts> accountList = new List<Accounts>(); 
        List<String> accountId = new List<String>();
        List<String> addressids = new List<String>();
        map<Id,List<Accounts>> accountsMap = new map<Id,List<Accounts>>();
        map<Id,List<Order_Line_Item__c>> orderLineItemMap = new map<Id,List<Order_Line_Item__c>>();
        map<Id,List<Orders>> ordersMap = new map<Id,List<Orders>>();
        /*, Rejected_Reason__c,*/
        // Query modified(added 2 more fields Territory_Name__c,Territory_Owner__c) by Joognu Rao to implement US1090379 
        addList.addAll([SELECT Address__c,Id,Account__c,Complex_Office__c, Status__c, Total_Monthly_Rate__c,Last_Knock_Date__c,City__c,PostalCode__c,State__c,
        Video_Active__c,Voice_Active__c,XH_Active__c,XSS_Active__c,Past_Due_Balance__c,Disconnect_Reason__c,Address_2__c,Billing_Account_Key__c,Non_Marketable__c,
        Property_Code__c,Dwelling_Type__c,Do_not_Call__c,Do_not_Email__c,Do_not_Knock__c,Corp__c,Node__c,Route_Code__c,Location_ID__c,HSI_Active__c,
        Installation_Status__c, Active_Inactive__c, Last_Install_Date__c,Disconnect_Days__c,Last_Disconnected_Date__c,Write_Off_Amount__c,Latitude__c,Verizon_Wireless_Active__c,
        Longitude__c,Parent_Address__c,Digital_Serviceable__c,Internet_Serviceable__c,Voice_Serviceable__c,Most_Recent_Disposition__c,Tap_Status__c,
        FormulaTapStatus__c,Sort_Code__c,Renewal_Status_Time__c, Renewal_Status_Timeframe__c, Video_Contract__c, Voice_Contract__c, Internet_Contract__c, 
        Contract_Expiration_Date__c, Plan__c, Rejected_Reason__c, NCLV_Reg_Decile__c,Targeted__c,Non_Marketable_Reason__c,Territory_Name__c,Territory_Owner__c FROM Customer_Address__c WHERE Id = :addressId]);
        
        Set<Id> accId = new Set<Id>();
        for(Customer_Address__c cusAdd: addList){
            accId.add(cusAdd.Account__c);
        }
        RetrieveAllAccounts__c retrieveAccCustomSet = RetrieveAllAccounts__c.getValues('GetPlanServicesREST4');
        if(retrieveAccCustomSet.isActive__c){
        accList.addAll([SELECT Billing_Account_Number__c,Id,Service_Address__c,Phone,BillingStreet,acc.Name,Video_Active__c,Voice_Active__c,Home_Security_Active__c,XSS_Active__c,
        Total_Monthly_Rate__c,Customer__c, Active_Inactive__c, FormulaContactName__c,FormulaPhone__c, Customer_Status__c, Write_Off_Amount__c,CustomerNameForDSM__c, Past_Due_Balance__c, 
        Installation_Status__c, Last_Install_Date__c, Last_Disconnected_Date__c, Disconnect_Reason__c, Disconnect_Days__c,(Select Name From Contacts) from Account acc WHERE Service_Address__c = :addressId]);
        }
        
        if(!retrieveAccCustomSet.isActive__c){
        accList.addAll([SELECT Billing_Account_Number__c,Id,Service_Address__c,Phone,BillingStreet,acc.Name,Video_Active__c,Voice_Active__c,Home_Security_Active__c,XSS_Active__c,
        Total_Monthly_Rate__c,Customer__c, Active_Inactive__c, FormulaContactName__c,FormulaPhone__c, Customer_Status__c, Write_Off_Amount__c,CustomerNameForDSM__c, Past_Due_Balance__c, 
        Installation_Status__c, Last_Install_Date__c, Last_Disconnected_Date__c, Disconnect_Reason__c, Disconnect_Days__c,(Select Name From Contacts) from Account acc WHERE Id IN:accId]);
        }
        
        list<String> accNameList = new List<String>();
           
        for(Account acc :accList)
        {
         accNameList.add(acc.Id);   
        }
        Map<Id,String> contactAccountMap=new Map<Id,String>();
        List<Contact> contactList=[Select Name, AccountId From Contact Where AccountId IN:accNameList];
        for(Contact c:contactList){
          contactAccountMap.put(c.AccountId,c.Name);
        }
         List<Order__c> orderList = new List<Order__c>();
                   
         
          
           List<String> orderIdList = new List<String>();
           orderList.addAll([SELECT Id,Account__c,Salesperson_ID__c,ActivatedBy__c,Order_Number__c,OrderStatus__c,OrderCompletedDate__c,ScheduledInstallationDate__c, ActualMRC__c, ActualNRC__c, Worklisted__c, Install_Date_and_Timeframe__c from Order__c where Account__c in :accNameList]);
           
           
           for(Order__c ord :orderList)
           {
            orderIdList.add(ord.Id);
           }
           
           
           List<Order_Line_Item__c> orderLineItem = new List<Order_Line_Item__c>();
           orderLineItem.addAll([SELECT ol.Order__c,ol.Name from Order_Line_Item__c ol where ol.Order__c in :orderList]);
           
           List<Order_Line_Item__c> tempOrderLineItem = new List<Order_Line_Item__c>();
           for(Order_Line_Item__c orderLine: orderLineItem)
           {
            if(orderLineItemMap.get(orderLine.Order__c) == null)
            {
                tempOrderLineItem = new List<Order_Line_Item__c>();
                tempOrderLineItem.add(orderLine);
            }
            else
            {
                tempOrderLineItem = orderLineItemMap.get(orderLine.Order__c);
                tempOrderLineItem.add(orderLine);
            }
            orderLineItemMap.put(orderLine.Order__c,tempOrderLineItem);
           }
           
           
           
           
           Orders orders;
           List<Orders> tempOrders = new List<Orders>();
           for(Order__c orderC: orderList)
           {
            orders = new Orders();
            orders.custOrder = orderC;
            orders.setorderLineItemList(orderLineItemMap.get(orderC.Id));
            if(ordersMap.get(orderC.Account__c) == null)
            {
                tempOrders = new List<Orders>();
                tempOrders.add(orders);
            }
            else
            {
                tempOrders = ordersMap.get(orderC.Account__c);
                tempOrders.add(orders);
            }
            ordersMap.put(orderC.Account__c,tempOrders);
           }
           
           
         
           
            for(Account acc :accList)
           {
                if(acc.Contacts != null){
                    
                    for(Contact c : acc.Contacts){
                        acc.CustomerNameForDSM__c = c.Name;
                    }   
                }
                
               Accounts account = new Accounts();
              //  account=acc;
                account.custAccount  = acc;  
                
              list<Accounts> tempAccount = new List<Accounts>();
              account.setorderList(ordersMap.get(acc.Id));
                if(accountsMap.get(acc.Service_Address__c) == null)
                {
                    
                    tempAccount.add(account);
                }  
                else
                {
                    tempAccount = accountsMap.get(acc.Service_Address__c);
                    tempAccount.add(account);
                }
         
           
            accountsMap.put(acc.Service_Address__c, tempAccount);
           }
           
           Integer i =1;
           Address address;
           for(Customer_Address__c ca :addList)
            {
                
                address = new Address();
                address.custAddress = ca; 
                address.customerName=contactAccountMap.get(ca.Account__c);
                address.accList = accountsMap.get(ca.Id);
                addressList.add(address);   
            
               
            
            }
      return addressList;
 
        
        
    }
}