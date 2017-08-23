/*********************************************************************************************
Name : TerritorySmoothingBatchTest
Description : Test class for TerritorySmoothingBatch
User Story : US1103983
Date : 14 May 2017
Author : Amit Kumar -  Accenture 
***************************************************************************************************/
@isTest
public class TerritorySmoothingBatchTest {
  public static List<Territory__c> territoriesToInsert = new List<Territory__c>();
  public static List<CensusTract__c> censusTractsToInsert = new List<CensusTract__c>();
  public static List<Plan__c> createPlanRecords = new list<Plan__c>();
  public static List<CensusTract__c> lstcensusTractsToInsert = new List<CensusTract__c>();
  public static List<Customer_Address__c> createAddressRecords = new list<Customer_Address__c>();
  public static User usr;
  public static string region;
  public static map<string,CensusTract__c> mapcensusterritory = new map<string,CensusTract__c>();
    private static void setup(){
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
        for(CensusTract__c objtract:[SELECT id, Territory__c, CensusTractNumber__c, Territory__r.Territory_Region__c, Territory_Changed__c FROM CensusTract__c where id IN:censusTractsToInsert]){
        	mapcensusterritory.put(objtract.CensusTractNumber__c,objtract);	
        	region = objtract.Territory__r.Territory_Region__c;
        }
        for(Customer_Address__c objaddress:createAddressRecords){
        	objaddress.Plan__c = createPlanRecords[0].id;
        	lstuaddress.add(objaddress);
        }
        update lstuaddress;
        TerritorySmoothingBatch lpb = new TerritorySmoothingBatch(region,mapcensusterritory);
		Database.executeBatch(lpb);
        Test.stopTest();
        
    }
    
}