/*********************************************************************************************
Name : CensusTractTriggerTest
Description : Test class for CensusTractTrigger
User Story : US1103983
Date : 25 May 2017
Author : Amit Kumar -  Accenture 
***************************************************************************************************/
@isTest
public class CensusTractTriggerTest {
	static testMethod void addressplanpostivetest() {
		List<Territory__c> territoriesToInsert = new List<Territory__c>();
	  List<CensusTract__c> lstcensusTractsToInsert = new List<CensusTract__c>();
	  List<CensusTract__c> censusTractsToInsert = new List<CensusTract__c>();
	SetupTestData.createCustomSettingRecords();
        //Create Territory and Plan records for us to use in our test methods
        territoriesToInsert = SetupTestTerritoryData.createTerritoryRecords(2);
        censusTractsToInsert = [Select id,CensusTractNumber__c,Territory__c,Name from CensusTract__c where Territory__c IN:territoriesToInsert];
        censusTractsToInsert[0].Territory__c = null;
        censusTractsToInsert[1].Territory__c = territoriesToInsert[1].id;
       update  censusTractsToInsert[0];
       update censusTractsToInsert[1];
	}
        
}