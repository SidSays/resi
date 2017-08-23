@isTest
private class TargetedFlagupdateBatchTest {
	public static List<Territory__c> territoriesToInsert = new List<Territory__c>();
  	public static List<CensusTract__c> censusTractsToInsert = new List<CensusTract__c>();
  	public static List<Plan__c> createPlanRecords = new list<Plan__c>();
  	public static List<CensusTract__c> lstcensusTractsToInsert = new List<CensusTract__c>();
  	public static List<Customer_Address__c> createAddressRecords = new list<Customer_Address__c>();
  	public static User usr;
  	public static set<string> setregions;
  	public static list<Customer_Address__c> lstregions;
  	static testMethod void updatetargetedflagtest() {
    	List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
    	List<Customer_Address__c> lstupdatedaddress = new List<Customer_Address__c>();
        TriggerSettings__c addressTrigger = new TriggerSettings__c();
         addressTrigger.Name = 'AddressTrigger';
         addressTrigger.isActive__c = false;
         triggerSettingsList.add(addressTrigger);
         
          TriggerSettings__c planTrigger = new TriggerSettings__c();
            planTrigger.Name = 'PlanTrigger';
            planTrigger.isActive__c = false;
            triggerSettingsList.add(planTrigger);
            insert triggerSettingsList;
            list<Variable_Setting__c> lstvariable = new list<Variable_Setting__c>();
        		Variable_Setting__c objvariable;
       			 objvariable = new Variable_Setting__c();
        		 objvariable.Name ='Targeted _flag_Query' ;
       			 objvariable.Description__c = 'Targeted flag Update';
                 objvariable.Value__c = 'Select Id, Name, Targeted__c from Customer_Address__c where Region__c IN:setregion and Targeted__c = true';
    	         lstvariable.add(objvariable);
             insert lstvariable;
          usr = [select Id,Region__c from User where Id=:UserInfo.getUserId()];
        Test.startTest();
        list<Customer_Address__c> lstuaddress = new list<Customer_Address__c>();
        territoriesToInsert = SetupTestTerritoryData.createTerritoryRecords(2);
        createAddressRecords = SetupTestTerritoryData.createAddressRecords(2,usr.id, territoriesToInsert[0].id,true);
        lstregions = [Select Region__c,id from Customer_Address__c where Id IN:createAddressRecords];
        system.debug('lstregions--->'+lstregions);
        setregions = new set<string>();
        for(Customer_Address__c objadd:lstregions){
        	system.debug('objadd.Region__c--->'+objadd.Region__c);
        	  	setregions.add(objadd.Region__c);
        }
        TargetedFlagupdateBatch lpb = new TargetedFlagupdateBatch(setregions);
		Database.executeBatch(lpb);
        Test.stopTest();
        
    }
    
    
}