public with sharing class CallCenterExportController {
  public static String filename {get; set;}
  public static Boolean renderOppLineItemInfo {get; set;}
  public static Date lastExportDateLimit;
  public static Date mostRecentOrderDateLimit;
  public static Date oppAndLeadCreatedDateLimit;
  public static List<String> divisionStates;

  public CallCenterExportController(){
    filename = 'Export_File_To_Telesales';
    lastExportDateLimit = Date.today() - (Integer.valueOf(Call_Center_Settings__c.getValues('Last Export Threshold In Days').Value__c));
    mostRecentOrderDateLimit = Date.today() - (Integer.valueOf(Call_Center_Settings__c.getValues('Order Created Threshold In Days').Value__c));
    oppAndLeadCreatedDateLimit = Date.today() - (Integer.valueOf(Call_Center_Settings__c.getValues('New Lead Opportunity Threshold').Value__c));
    divisionStates = Call_Center_Settings__c.getValues('Northeast Division').Value__c.split(',');
  }

  public void updateLists(){
    /*List<Lead> leads = new List<Lead>([SELECT Id, Customer_Type__c, LeadSource, Lead_Channel__c, Name, Street__c, City, State, PostalCode, Email, Phone, 
      Exportable_Phone__c, Originating_Affiliate_Account__c, Originating_Lead_Channel__c, Affiliate_Account__c, FirstName, LastName, 
      Affiliate_Account__r.Name, isConverted FROM Lead 
      WHERE isConverted = false 
      AND Status = 'Open' 
      AND Company != 'LastName Home' 
      AND Affiliate_Account__r.Name != 'Verizon Wireless' 
      AND Affiliate_Account__r.Name != 'DOTCOM' 
      AND (Affiliate_Account__r.Name != 'Comcast' OR Lead_Channel__c != 'DIRECT') 
      AND Credit_Check__c = 'GOOD' 
      AND Phone != null 
      AND State IN :divisionStates 
      AND (Last_Export_Date__c < :lastExportDateLimit OR Last_Export_Date__c = null) 
      AND CreatedDate > :oppAndLeadCreatedDateLimit 
      AND (Customer_Debt_Amount__c <= 0 OR Customer_Debt_Amount__c = null)]);*/

    List<Opportunity> opps = new List<Opportunity>([SELECT Name, Id, Account.Phone, Customer_Type__c, LeadSource, ProjectedMRC__c, ProjectedNRC__c, 
      Originating_Affiliate_Account__c, Originating_Opportunity_Channel__c, Affiliate_Account__c,Opportunity_Channel__c, Last_Export_Date__c, 
      Customer_First_Name__c,  Customer_Last_Name__c, Customer_Street__c, Customer_City__c, Customer_State__c, Customer_PostalCode__c, Customer_Phone__c, 
      Customer_Exportable_Phone__c, Customer_Email__c, Account.Customer__c, Account.Billing_Account_Number__c, Affiliate_Account__r.Name, 
      (Select Name, LastModifiedDate, ItemMRC__c, ItemNRC__c From Line_Items__r ORDER BY LastModifiedDate Desc) FROM Opportunity 
      WHERE StageName = 'Open' 
      AND Name != 'LastName HOME' 
      AND Affiliate_Account__r.Name != 'Verizon Wireless' 
      AND Affiliate_Account__r.Name != 'DOTCOM' 
      AND (Affiliate_Account__r.Name != 'Comcast' OR Opportunity_Channel__c != 'DIRECT') 
      AND (Affiliate_Account__r.Name != 'Comcast' OR Opportunity_Channel__c != 'WEB') 
      AND Credit_Check__c = 'GOOD' 
      AND Customer_Phone__c != null 
      AND Customer_State__c IN :divisionStates 
      AND (Last_Export_Date__c < :lastExportDateLimit OR Last_Export_Date__c = null) 
      AND CreatedDate > :oppAndLeadCreatedDateLimit 
      AND (Customer_Debt_Amount__c <= 0 OR Customer_Debt_Amount__c = null)]);

    //updateLeads(removeLeadDuplicates(leads));
    updateOpportunities(removeOppDuplicates(opps));
  }

  /*public static void updateLeads(List<Lead> leads){
    Account affiliate = getAffiliateAccount();
    for(Lead l : leads){
      l.Last_Export_Date__c = Date.today();

      // Retain previous Affiliate and Channel before changing them
      l.Originating_Affiliate_Account__c = l.Affiliate_Account__c;
      l.Originating_Lead_Channel__c = l.Lead_Channel__c;
      
      // Set the Affiliate Account to Comcast and the Channel to TELESALES
      l.Affiliate_Account__c = affiliate.Id;
      l.Lead_Channel__c = 'TELESALES';
    }    
    update leads;
  }*/
  
  public static void updateOpportunities(List<Opportunity> opportunities){
    Account affiliate = getAffiliateAccount();    
    for(Opportunity o : opportunities){
      o.Last_Export_Date__c = Date.today();
      
      // Retain previous Affiliate and Channel before changing them
      o.Originating_Affiliate_Account__c = o.Affiliate_Account__c;
      o.Originating_Opportunity_Channel__c = o.Opportunity_Channel__c;
      
      // Set the Affiliate Account to Comcast and the Channel to TELESALES
      o.Affiliate_Account__c = affiliate.Id;
      o.Opportunity_Channel__c = 'TELESALES';    
    }
    update opportunities;
  }

  public static Account getAffiliateAccount(){
    return [SELECT Id, Name FROM Account WHERE Name = 'Comcast' limit 1];  
  }

  /*public static List<Lead> getLeads(){
    List<Lead> leads = new List<Lead>([SELECT Id, Customer_Type__c, LeadSource, Lead_Channel__c, Name, Street__c, City, State, PostalCode, Email, Phone, 
      Originating_Affiliate_Account__r.Name, Exportable_Phone__c, Originating_Affiliate_Account__c, Originating_Lead_Channel__c, Affiliate_Account__c, 
      FirstName, LastName, Affiliate_Account__r.Name, isConverted FROM Lead 
      WHERE isConverted = false 
      AND Status = 'Open' 
      AND Company != 'LastName Home' 
      AND Originating_Affiliate_Account__r.Name != 'Verizon Wireless' 
      AND Originating_Affiliate_Account__r.Name != 'DOTCOM' 
      AND (Originating_Affiliate_Account__r.Name != 'Comcast' OR Originating_Lead_Channel__c != 'DIRECT') 
      AND Lead_Channel__c = 'TELESALES' 
      AND Credit_Check__c = 'GOOD' 
      AND Phone != null  
      AND State IN :divisionStates 
      AND Last_Export_Date__c = :Date.today() 
      AND CreatedDate > :oppAndLeadCreatedDateLimit 
      AND (Customer_Debt_Amount__c <= 0 OR Customer_Debt_Amount__c = null) limit 1000]);
    
    leads = removeLeadDuplicates(leads);
    for(Lead l : leads){
      l.Exportable_Phone__c = l.Phone;
      if(l.Exportable_Phone__c.contains('(')){
        l.Exportable_Phone__c = l.Exportable_Phone__c.replace('(', '');
      }
      if(l.Exportable_Phone__c.contains(')')){
        l.Exportable_Phone__c = l.Exportable_Phone__c.replace(')', '');
      }
      if(l.Exportable_Phone__c.contains(' ')){
        l.Exportable_Phone__c = l.Exportable_Phone__c.replace(' ', '');
      }
      if(l.Exportable_Phone__c.contains('-')){
        l.Exportable_Phone__c = l.Exportable_Phone__c.replace('-', '');
      }
    }
    return leads;
  }*/
  
  public static List<Opportunity> getOpportunities(){
    List<Opportunity> oppsToReturn = new List<Opportunity>();
    List<Opportunity> opps = new List<Opportunity>([SELECT Name, Id, Account.Phone, Customer_Type__c, LeadSource, ProjectedMRC__c, ProjectedNRC__c, 
      Originating_Affiliate_Account__r.Name, Originating_Affiliate_Account__c, Originating_Opportunity_Channel__c, Affiliate_Account__c, 
      Opportunity_Channel__c, Last_Export_Date__c, Customer_First_Name__c, Customer_Last_Name__c, Customer_Street__c, Customer_City__c, 
      Customer_State__c, Customer_PostalCode__c, Customer_Phone__c, Customer_Exportable_Phone__c, Customer_Email__c, Account.Customer__c, 
      Account.Billing_Account_Number__c, Affiliate_Account__r.Name, Number_Of_Line_Items__c, (Select Name, LastModifiedDate, ItemMRC__c, ItemNRC__c 
      From Line_Items__r ORDER BY LastModifiedDate Desc) FROM Opportunity 
      WHERE StageName = 'Open' 
      AND Name != 'LastName HOME' 
      AND Originating_Affiliate_Account__r.Name != 'Verizon Wireless' 
      AND Originating_Affiliate_Account__r.Name != 'DOTCOM' 
      AND (Originating_Affiliate_Account__r.Name != 'Comcast' OR Originating_Opportunity_Channel__c != 'DIRECT') 
      AND (Originating_Affiliate_Account__r.Name != 'Comcast' OR Originating_Opportunity_Channel__c != 'WEB') 
      AND Opportunity_Channel__c = 'TELESALES' 
      AND Credit_Check__c = 'GOOD' 
      AND Customer_Phone__c != null 
      AND Customer_State__c IN :divisionStates 
      AND Last_Export_Date__c = :Date.today() 
      AND CreatedDate > :oppAndLeadCreatedDateLimit 
      AND (Customer_Debt_Amount__c <= 0 OR Customer_Debt_Amount__c = null) limit 1000]);

    opps = removeOppDuplicates(opps);
    for(Opportunity o : checkOrders(opps)){
      o.Customer_Exportable_Phone__c = o.Customer_Phone__c;
      if(o.Customer_Exportable_Phone__c.contains('(')){
        o.Customer_Exportable_Phone__c = o.Customer_Exportable_Phone__c.replace('(', '');
      }
      if(o.Customer_Exportable_Phone__c.contains(')')){
        o.Customer_Exportable_Phone__c = o.Customer_Exportable_Phone__c.replace(')', '');
      }
      if(o.Customer_Exportable_Phone__c.contains(' ')){
        o.Customer_Exportable_Phone__c = o.Customer_Exportable_Phone__c.replace(' ', '');
      }
      if(o.Customer_Exportable_Phone__c.contains('-')){
        o.Customer_Exportable_Phone__c = o.Customer_Exportable_Phone__c.replace('-', '');
      }
      oppsToReturn.add(o);
    }
 
    for(Opportunity o : oppsToReturn){
      renderOppLineItemInfo = true;
      if(o.Line_Items__r != null && o.Line_Items__r.size() > 0){
        if(o.Line_Items__r[0].Name.contains(',')){
          o.Line_Items__r[0].Name = o.Line_Items__r[0].Name.replace(',', ' ');
        }
      } else {
        renderOppLineItemInfo = false;
      }
    }
    return oppsToReturn;
  }

  public static List<Opportunity> checkOrders(List<Opportunity> opportunities){
    List<Id> oppIds = new List<Id>();    
    for(Opportunity o : opportunities){
      oppIds.add(o.Id);
    }
    
    List<Order__c> orders = new List<Order__c>([SELECT CreatedDate, Opportunity__c FROM Order__c WHERE Opportunity__c IN :oppIds
      AND CreatedDate > :mostRecentOrderDateLimit]);

    Set<Id> oppContainsNewOrders = new Set<Id>();
    for(Order__c o : orders){
      if(!oppContainsNewOrders.contains(o.Opportunity__c)){
        oppContainsNewOrders.add(o.Opportunity__c);
      }
    }  
    
    List<Opportunity> oppsWithNoNewOrders = new List<Opportunity>();
    for(Opportunity o: opportunities){
      if(!(oppContainsNewOrders.contains(o.Id))){
        oppsWithNoNewOrders.add(o);
        System.debug('opp added to return list');
      }
    }
    return oppsWithNoNewOrders;
  }
  
  /*public static List<Lead> removeLeadDuplicates(List<Lead> leads){
    Map<String, Lead> leadMap = new Map<String, Lead>();
    
    Lead currentLead = new Lead();
    for(Integer i = 0; i < leads.size(); i++){
      currentLead = leads.get(i);
      
      if(leadMap.containsKey(currentLead.Phone + currentLead.Email)){//change to use locationId only?
        leads.remove(i);
      } else{
        leadMap.put(currentLead.Phone + currentLead.Email, currentLead);
      }
    }
    return leads;
  }*/

  public static List<Opportunity> removeOppDuplicates(List<Opportunity> opportunities){
    Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>();
    
    Opportunity currentOpp = new Opportunity();
    for(Integer i = 0; i < opportunities.size(); i++){
      currentOpp = opportunities.get(i);
      
      if(opportunityMap.containsKey(currentOpp.Customer_Phone__c + currentOpp.Customer_Email__c)){
        opportunities.remove(i);
      } else{
        opportunityMap.put(currentOpp.Customer_Phone__c + currentOpp.Customer_Email__c, currentOpp);
      }
    }
    return opportunities;
  }
}