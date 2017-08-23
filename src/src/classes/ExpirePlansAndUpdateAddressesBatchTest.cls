@isTest
public class ExpirePlansAndUpdateAddressesBatchTest {
    
	  public static List<Territory__c> territoriesToInsert = new List<Territory__c>();
  public static List<CensusTract__c> censusTractsToInsert = new List<CensusTract__c>();
  public static List<Plan__c> createPlanRecords = new list<Plan__c>();
  public static List<CensusTract__c> lstcensusTractsToInsert = new List<CensusTract__c>();
  public static List<Customer_Address__c> createAddressRecords = new list<Customer_Address__c>();
   public static List<Customer_Address__c> lstaddupdate = new list<Customer_Address__c>();
  public static User usr;
  public static string region;
  public static map<string,CensusTract__c> mapcensusterritory = new map<string,CensusTract__c>();
  public static set<string> setregions;
  	public static list<plan__c> lstregions;
    private static void setup(){
    	
    	VariableSettingTestUtility.variableSettingsData();
        //Follow existing precedence to set up the test Users we will use in our test methods
        usr = [select Id,Region__c from User where Id=:UserInfo.getUserId()];
        SetupTestData.createCustomSettingRecords();
        //Create Territory and Plan records for us to use in our test methods
        territoriesToInsert = SetupTestTerritoryData.createTerritoryRecords(2);
        censusTractsToInsert = [Select id,CensusTractNumber__c,Territory__c,Name from CensusTract__c where Territory__c=: territoriesToInsert[0].id];
        createAddressRecords = SetupTestTerritoryData.createAddressRecords(2,usr.id, territoriesToInsert[0].id,true);
        createPlanRecords = SetupTestTerritoryData.createPlanRecords(2);
    }
    
    static testMethod void addressplanpostivetest() {
        Test.startTest();
        list<Customer_Address__c> lstuaddress = new list<Customer_Address__c>();
        setup();
        lstregions = [Select Region__c,id from plan__c where Id IN:createPlanRecords];
        system.debug('lstregions--->'+lstregions);
        setregions = new set<string>();
        for(Plan__c objadd:lstregions){
        	system.debug('objadd.Region__c--->'+objadd.Region__c);
        	  	setregions.add(objadd.Region__c);
        }
        for(Customer_Address__c objadd:createAddressRecords){
        	objadd.Plan__c = createPlanRecords[0].id;
        	lstaddupdate.add(objadd);
        }
        update lstaddupdate;
        ExpirePlansAndUpdateAddressesBatch lpb = new ExpirePlansAndUpdateAddressesBatch(setregions);
		Database.executeBatch(lpb);
        Test.stopTest();
        
    }
        
}