/*********************************************************************************************
Name : TerritorySmoothingBatchScheduleTest
Description : Test class for TerritorySmoothingBatchSchedule
User Story : US1103983
Date : 14 May 2017
Author : Amit Kumar -  Accenture 
***************************************************************************************************/
@isTest
public class TerritorySmoothingBatchScheduleTest {
  public static List<Territory__c> territoriesToInsert = new List<Territory__c>();
  public static List<CensusTract__c> censusTractsToInsert = new List<CensusTract__c>();
  public static List<Plan__c> createPlanRecords = new list<Plan__c>();
  public static List<CensusTract__c> lstcensusTractsToInsert = new List<CensusTract__c>();
  public static List<Customer_Address__c> createAddressRecords = new list<Customer_Address__c>();
  public static User usr;
    private static void setup(){
        //Follow existing precedence to set up the test Users we will use in our test methods
        usr = [select Id,Region__c from User where Id=:UserInfo.getUserId()];
        SetupTestData.createCustomSettingRecords();
        list<Variable_Setting__c> lstvariable = new list<Variable_Setting__c>();
        		Variable_Setting__c objvariable;
       			 objvariable = new Variable_Setting__c();
        		 objvariable.Name ='TerritorySmoothingbatchtime' ;
       			 objvariable.Description__c = 'This value will be used to disable/enable functionality for linking Address with Territory on update operation';
                 objvariable.Value__c = '5';
    	         lstvariable.add(objvariable);
    	         objvariable = new Variable_Setting__c();
        		 objvariable.Name ='TerritorySmoothingRegions' ;
       			 objvariable.Description__c = 'This value will be used to disable/enable functionality for linking Address with Territory on update operation';
                 objvariable.Value__c = 'Ter,PLR,TCR,HOU,SEA,KEY,BSR,CAL,MWR';
    	         lstvariable.add(objvariable);
    	         
    	         
             insert lstvariable;
        //Create Territory and Plan records for us to use in our test methods
        territoriesToInsert = SetupTestTerritoryData.createTerritoryRecords(2);
        censusTractsToInsert = [Select id,CensusTractNumber__c,Territory__c,Name,Territory__r.Territory_Region__c from CensusTract__c where Territory__c=: territoriesToInsert[0].id];
        createAddressRecords = SetupTestTerritoryData.createAddressRecords(2,usr.id, territoriesToInsert[0].id,true);
        createPlanRecords = SetupTestTerritoryData.createPlanRecords(2);
    }
    
    static testMethod void myUnitTest() {
        Test.startTest();
        setup();
        system.debug('censusTractsToInsert'+censusTractsToInsert);
        for(CensusTract__c objcensus:censusTractsToInsert){
            objcensus.Territory__c = territoriesToInsert[1].id;
            lstcensusTractsToInsert.add(objcensus);
        }
        update lstcensusTractsToInsert;
        system.debug('lstcensusTractsToInsert'+lstcensusTractsToInsert);
        TerritorySmoothingBatchSchedule objterritory = new TerritorySmoothingBatchSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Territory Batch', sch, objterritory);
        Test.stopTest();
        
    }
    static testMethod void myUnitTest1() {
        Test.startTest();
        setup();
        system.debug('censusTractsToInsert'+censusTractsToInsert);
        for(CensusTract__c objcensus:censusTractsToInsert){
            objcensus.Territory__c = null;
            lstcensusTractsToInsert.add(objcensus);
        }
        update lstcensusTractsToInsert;
        system.debug('lstcensusTractsToInsert'+lstcensusTractsToInsert);
        TerritorySmoothingBatchSchedule objterritory = new TerritorySmoothingBatchSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Territory Batch', sch, objterritory);
        Test.stopTest();
        
    }
    static testMethod void myUnitTest3() {
        Test.startTest();
        SetupTestData.createCustomSettingRecords();
        list<Variable_Setting__c> lstvariable = new list<Variable_Setting__c>();
        		Variable_Setting__c objvariable;
       			 objvariable = new Variable_Setting__c();
        		 objvariable.Name ='TerritorySmoothingbatchtime' ;
       			 objvariable.Description__c = 'This value will be used to disable/enable functionality for linking Address with Territory on update operation';
                 objvariable.Value__c = '5';
    	         lstvariable.add(objvariable);
    	         objvariable = new Variable_Setting__c();
        		 objvariable.Name ='TerritorySmoothingRegions' ;
       			 objvariable.Description__c = 'This value will be used to disable/enable functionality for linking Address with Territory on update operation';
                 objvariable.Value__c = 'Ter,Per';
    	         lstvariable.add(objvariable);
            Territory__c terr;
            terr = new Territory__c();
            terr.Name = 'Territory'+'1';
            terr.Territory_Code__c = 'Territory'+'1';
            terr.Status__c='Draft';
            territoriesToInsert.add(terr);
            terr = new Territory__c();
            terr.Name = 'Peritory'+'2';
            terr.Territory_Code__c = 'Perritory'+'2';
            terr.Status__c='Draft';
            territoriesToInsert.add(terr);
        
        insert territoriesToInsert;
        Integer censusTractCnt=0;
        for(Territory__c territory:territoriesToInsert){
            censusTractsToInsert.add(new CensusTract__c(Name='AA00356230'+censusTractCnt,
                                                        CensusTractNumber__c='AA00356230'+censusTractCnt,
                                                        Territory__c=territory.Id));
            censusTractCnt++;
        }
        insert censusTractsToInsert;
        system.debug('censusTractsToInsert'+censusTractsToInsert);
            censusTractsToInsert[0].Territory__c = territoriesToInsert[1].id;
            censusTractsToInsert[1].Territory__c = territoriesToInsert[0].id;
            
       
        update censusTractsToInsert;
        censusTractsToInsert = [SELECT id, Territory__c, CensusTractNumber__c, Territory__r.Territory_Region__c, Territory_Changed__c,Old_Territory_Region__c
											FROM CensusTract__c where id IN:censusTractsToInsert];
        system.debug('censusTractsToInsert'+censusTractsToInsert);
        TerritorySmoothingBatchSchedule objterritory = new TerritorySmoothingBatchSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Territory Batch', sch, objterritory);
        Test.stopTest();
        
    }
}