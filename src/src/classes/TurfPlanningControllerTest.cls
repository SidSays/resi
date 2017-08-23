@isTest
public class TurfPlanningControllerTest {
  public static User usr;
  private static Id addrOwnerId;
  private static List<Customer_Address__c> listOfAddresses;
  private static List<Territory__c> listOfTerritories;
  private static Profile usrProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
  private static UserRole usrRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Regional_Manager'];

  private static void init() {
    // Creating the custom settings.
    SetupTestData.createCustomSettingRecords();
    VariableSettingTestUtility.variableSettingsData(); 

    TriggerSettings__c trigSttgs = TriggerSettings__c.getValues('UserTrigger');
    String randomstr9 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
    // Get a user object that we can update as necessary for tests
    usr = [select Id,Region__c from User where Id=:UserInfo.getUserId()];

    listOfTerritories = SetupTestTerritoryData.createTerritoryRecords(2);

    //Create sample Customer_Address__c records
    listOfAddresses = SetupTestTerritoryData.createAddressRecordsWithoutTerritory(2, usr.Id);
  }

  // Asserts that the constructor is setting the right values to the variables with
  // Comcast_Division__c set to "West".
  private static testMethod void constructor_West() {
    init();

    usr.Region__c = 'Twin Cities Market';
    update usr;

    // setting the territory values.
    listOfTerritories[0].Status__c = 'Published';
    listOfTerritories[0].Region__c = 'Twin Cities Market';
    listOfTerritories[1].Status__c = 'Published';
    listOfTerritories[1].Region__c = 'Twin Cities Market';
    update listOfTerritories;

    TurfPlanningController controller;
    system.Test.startTest();
      System.runAs(usr) {
        controller = new TurfPlanningController();
      }
    system.Test.stopTest();

    // Asserting that the variables have been set correctly.
    system.assertEquals(Date.today() + 75, controller.turf.Expiration_Date__c);
    system.assertEquals(false, controller.includeHSIOnly);
    System.assertEquals(2, controller.territoryOptions.size());
  }
  // Asserts that the constructor is setting the right values to the variables with
  // Comcast_Division__c set to "Northeast".
  private static testMethod void constructor_not_West() {
    init();

    // Setting a region for the sys admin user.
    usr.Region__c = 'Beltway Market';
    update usr;

    // setting the territory values.
    listOfTerritories[0].Status__c = 'Published';
    listOfTerritories[0].Region__c = 'Beltway Market';
    listOfTerritories[1].Status__c = 'Published';
    listOfTerritories[1].Region__c = 'Beltway Market';
    update listOfTerritories;

    system.Test.startTest();
    TurfPlanningController controller = new TurfPlanningController();
    system.Test.stopTest();

    // Asserting that the variables have been set correctly.
    system.assertEquals(Date.today() + 60, controller.turf.Expiration_Date__c);
    system.assertEquals(false, controller.includeHSIOnly);
    System.assertEquals(2, controller.territoryOptions.size());
  }
  // Testing the queryAddressesInTerritory method.
  private static testMethod void queryAddressesInTerritory_test() {
    init();

      // Setting address values.
      TurfPlanningController controller = new TurfPlanningController();
      controller.includeHSIOnly = true;
      controller.selectedTerritoryId = listOfTerritories[0].Id;
      listOfAddresses[0].Territory__c = listOfTerritories[0].Id;
      listOfAddresses[0].Plan__c = null;
      listOfAddresses[0].Census_Block__c = '420030603104029';
      listOfAddresses[0].Excluded_from_Territory__c = false;
      listOfAddresses[0].Targeted__c = true;

      listOfAddresses[1].Territory__c = listOfTerritories[0].Id;
      listOfAddresses[1].Plan__c = null;
      listOfAddresses[1].Census_Block__c ='420030603104020';
      listOfAddresses[1].Excluded_from_Territory__c = false;
      listOfAddresses[1].Targeted__c = true;

      update listOfAddresses;


      system.Test.startTest();
      controller.queryAddressesInTerritory();
      system.Test.stopTest();

      // Asserting that all values have been set correctly.
      system.assertEquals(true, controller.searchComplete);
      system.assertEquals(true, controller.includeHSIOnly);
      System.assertEquals(true, controller.addressCountsByGrouping.containsKey('42003060310'));
      System.assertEquals(1, controller.addressCountsByGrouping.size());
      System.assertEquals(2, controller.addressCountsByGrouping.values()[0]);
      System.assertEquals(true, controller.groupingSelections.containsKey('42003060310'));
      System.assertEquals(1, controller.groupingSelections.size());
      System.assertEquals(false, controller.groupingSelections.values()[0]);
  }
  // Asserts that the method doesn't retrieve any addresses.
  private static testMethod void queryAddressesInTerritory_fail() {
    init();

      TurfPlanningController controller = new TurfPlanningController();

      system.Test.startTest();
      controller.queryAddressesInTerritory();
      system.Test.stopTest();

      // Asserting that all values have been set correctly.
      system.assertEquals(false, controller.includeHSIOnly);
      system.assertEquals(true, controller.searchComplete);
      System.assertEquals(0, controller.addressCountsByGrouping.size());
      System.assertEquals(0, controller.groupingSelections.size());
  }
  // Asserts that a null pointer exception is thrown when invoking the save method.
  private static testMethod void save_fail() {
    init();

      TurfPlanningController controller = new TurfPlanningController();
      listOfTerritories[0].OwnerId = usr.Id;
      update listOfTerritories;

      controller.territory = listOfTerritories[0];

      system.Test.startTest();
      controller.save();
      system.Test.stopTest();

      // Retrieves the page messages.
      List<Apexpages.Message> pageMessages = ApexPages.getMessages();

      // Asserting that the expected exception has been thrown.
      System.assertNotEquals(0, pageMessages.size());
      System.assertEquals('Attempt to de-reference a null object', pageMessages[0].getDetail());
  }
  // Asserts that the the user regions are the same and tests the collectAddresses method.
  private static testMethod void save_test() {
    init();

      TurfPlanningController controller = new TurfPlanningController();
      listOfTerritories[0].OwnerId = usr.Id;
      update listOfTerritories;

      listOfTerritories[0].Status__c = 'Published';
      controller.territory = listOfTerritories[0];

      // Setting the address values.
      controller.includeHSIOnly = true;
      controller.selectedTerritoryId = listOfTerritories[0].Id;
      listOfAddresses[0].Territory__c = listOfTerritories[0].Id;
      listOfAddresses[0].Plan__c = null;
      listOfAddresses[0].Census_Block__c = '420030603104029';
      listOfAddresses[0].Excluded_from_Territory__c = false;
      listOfAddresses[0].Targeted__c = true;

      listOfAddresses[1].Territory__c = listOfTerritories[0].Id;
      listOfAddresses[1].Plan__c = null;
      listOfAddresses[1].Census_Block__c ='420030603104020';
      listOfAddresses[1].Excluded_from_Territory__c = false;
      listOfAddresses[1].Targeted__c = true;
      update listOfAddresses;

      controller.queryAddressesInTerritory();
      // Changing the Booleanin groupingSelections to true.
      Set<String> setKeys = new Set<String>(controller.groupingSelections.keySet());
      String singleKey = new List<String> ( setKeys )[0];
      controller.groupingSelections.put(singleKey, true);

      system.Test.startTest();
        System.runAs(usr) {
          controller.save();
        }
      system.Test.stopTest();

      // Creating the JSON to assertEquals with the result from collectAddresses.
      List<Id> testIds = new List<Id>();
      /*for(String grouping : controller.groupingSelections.keySet()) {
        testIds.addAll(controller.groupedAddresses.get(grouping));
      }
      String testJSON = JSON.serialize(testIds);

      // Asserting that all values have been set correctly.
      System.assertEquals(testJSON, controller.addressIdsJson);
      */
      System.assertEquals(usr.Id, controller.turf.OwnerId);
      System.assertEquals(2, controller.turf.Number_of_Addresses_Currently_on_Plan__c);
      System.assertEquals(2, controller.turf.True_count_of_Addresses__c);
  }
  
  
   private static testMethod void save_assigning_to_team_test() {
    init();

      TurfPlanningController controller = new TurfPlanningController();
      Team__c team = new Team__c();
      team.Name = 'Test Team';
      team.Region__c = usr.Region__c;
      team.All_Team_Members__c = 'New';
      team.Supervisor__c = usr.id;
      insert team;
      
      controller.turf.Assigned_Team__c = team.id;

      listOfTerritories[0].Status__c = 'Published';
      controller.territory = listOfTerritories[0];

      // Setting the address values.
      controller.includeHSIOnly = true;
      controller.selectedTerritoryId = listOfTerritories[0].Id;
      listOfAddresses[0].Territory__c = listOfTerritories[0].Id;
      listOfAddresses[0].Plan__c = controller.turf.id;
      listOfAddresses[0].Census_Block__c = '420030603104029';
      listOfAddresses[0].Excluded_from_Territory__c = false;
      listOfAddresses[0].Targeted__c = true;

      listOfAddresses[1].Territory__c = listOfTerritories[0].Id;
      listOfAddresses[1].Plan__c = controller.turf.id;
      listOfAddresses[1].Census_Block__c ='420030603104020';
      listOfAddresses[1].Excluded_from_Territory__c = false;
      listOfAddresses[1].Targeted__c = true;
      update listOfAddresses;

      controller.queryAddressesInTerritory();
      // Changing the Booleanin groupingSelections to true.
      Set<String> setKeys = new Set<String>(controller.groupingSelections.keySet());
      String singleKey = new List<String> ( setKeys )[0];
      controller.groupingSelections.put(singleKey, true);

      system.Test.startTest();
        System.runAs(usr) {
          controller.save();
        }
      system.Test.stopTest();

      // Creating the JSON to assertEquals with the result from collectAddresses.
      List<Id> testIds = new List<Id>();
      /*for(String grouping : controller.groupingSelections.keySet()) {
        testIds.addAll(controller.groupedAddresses.get(grouping));
      }
      String testJSON = JSON.serialize(testIds);

      // Asserting that all values have been set correctly.
      System.assertEquals(testJSON, controller.addressIdsJson);
      */
      System.assertEquals(team.Id, controller.turf.Assigned_Team__c);
      System.assertEquals(2, controller.turf.Number_of_Addresses_Currently_on_Plan__c);
      System.assertEquals(2, controller.turf.True_count_of_Addresses__c);
  }
  
  // Asserting that the save method will set an error message when the user regions are different.
  private static testMethod void save_diffRegions() {
    init();

    User testUser = TestDataUtility.createUser(usrProfile.Id, null, null);
    testUser.Region__c = 'Beltway Market';
    testUser.CommunityNickname = 'Tester';
    insert testUser;

    usr.Region__c = 'Twin Cities Market';
    update usr;

    TurfPlanningController controller = new TurfPlanningController();
    listOfTerritories[0].OwnerId = testUser.Id;
    update listOfTerritories;

    listOfTerritories[0].Status__c = 'Published';
    controller.territory = listOfTerritories[0];

    // Setting the address values.
    controller.includeHSIOnly = true;
    controller.selectedTerritoryId = listOfTerritories[0].Id;
    listOfAddresses[0].Territory__c = listOfTerritories[0].Id;
    listOfAddresses[0].Plan__c = null;
    listOfAddresses[0].Census_Block__c = '420030603104029';
    listOfAddresses[0].Excluded_from_Territory__c = false;
    listOfAddresses[0].Targeted__c = true;

    listOfAddresses[1].Territory__c = listOfTerritories[0].Id;
    listOfAddresses[1].Plan__c = null;
    listOfAddresses[1].Census_Block__c ='420030603104020';
    listOfAddresses[1].Excluded_from_Territory__c = false;
    listOfAddresses[1].Targeted__c = true;
    update listOfAddresses;

    controller.queryAddressesInTerritory();
    // Changing the Booleanin groupingSelections to true.
    Set<String> setKeys = new Set<String>(controller.groupingSelections.keySet());
    String singleKey = new List<String> ( setKeys )[0];
    controller.groupingSelections.put(singleKey, true);

    system.Test.startTest();
    System.runAs(usr) {
      controller.save();
    }
    system.Test.stopTest();

    // Creating the JSON to assertEquals with the result from collectAddresses.
    List<Id> testIds = new List<Id>();
    /*for(String grouping : controller.groupingSelections.keySet()) {
      testIds.addAll(controller.groupedAddresses.get(grouping));
    }
    String testJSON = JSON.serialize(testIds);
    */
    // Retrieves the page messages.
    List<Apexpages.Message> pageMessages = ApexPages.getMessages();
    // Asserting that the expected error message has been set.
    System.assertNotEquals(0, pageMessages.size());
    System.assertEquals('Assigned User must be in your region!', pageMessages[0].getDetail());

    // Asserting that all values have been set correctly.
    //System.assertEquals(testJSON, controller.addressIdsJson);
    System.assertNotEquals('Published', [SELECT Status__c FROM territory__c WHERE Id = :listOfTerritories[0].Id].Status__c);
    System.assertNotEquals(usr.Id, controller.turf.OwnerId);
    System.assertNotEquals(2, controller.turf.Number_of_Addresses_Currently_on_Plan__c);
    System.assertNotEquals(2, controller.turf.True_count_of_Addresses__c);
  }
  // Tests the reset method in the controller.
  private static testMethod void reset_test() {
    init();

      TurfPlanningController controller = new TurfPlanningController();

      system.Test.startTest();
      controller.reset();
      system.Test.stopTest();

      // Asserting that all values have been set correctly.
      //system.assertEquals(true, controller.searchComplete);
      //system.assertEquals('Draft', controller.turf.Plan_Status__c);
      //system.assertEquals('Turf', controller.turf.Plan_Level__c);
  }
  // Asserts that the addresses have been updated.
  private static testMethod void updateAddresses_test() {
    init();

      listOfAddresses[0].Territory__c = listOfTerritories[0].Id;
      listOfAddresses[0].Plan__c = null;
      listOfAddresses[0].Census_Block__c = '420030603104029';
      listOfAddresses[0].Excluded_from_Territory__c = false;
      listOfAddresses[0].Targeted__c = true;

      listOfAddresses[1].Territory__c = listOfTerritories[0].Id;
      listOfAddresses[1].Plan__c = null;
      listOfAddresses[1].Census_Block__c ='420030603104020';
      listOfAddresses[1].Excluded_from_Territory__c = false;
      listOfAddresses[1].Targeted__c = true;

      system.Test.startTest();
      TurfPlanningController.updateAddresses(listOfAddresses);
      system.Test.stopTest();

      // Asserting that all values have been set correctly.
      system.assertEquals(false, [SELECT Excluded_from_Territory__c FROM Customer_Address__c WHERE Id = :listOfAddresses[0].Id].Excluded_from_Territory__c);
      system.assertEquals('420030603104029', [SELECT Census_Block__c FROM Customer_Address__c WHERE Id = :listOfAddresses[0].Id].Census_Block__c);
      system.assertEquals('420030603104020', [SELECT Census_Block__c FROM Customer_Address__c WHERE Id = :listOfAddresses[1].Id].Census_Block__c);
      system.assertEquals(true, [SELECT Targeted__c FROM Customer_Address__c WHERE Id = :listOfAddresses[1].Id].Targeted__c);
  }
  private static testMethod void updateAddresseswithPlan_test() {
      init();
      
      Plan__c turf = new Plan__c(Plan_Status__c = 'Assigned', Plan_Level__c = 'Turf', Assigned_Date__c = Date.today(), Number_of_Addresses_on_Playlists__c = 0, User__c = usr.Id);
      turf.Expiration_Date__c = Date.today() + 75;
      insert turf;
      
      listOfAddresses[0].Territory__c = listOfTerritories[0].Id;
      listOfAddresses[0].Plan__c = turf.id;
      listOfAddresses[0].Census_Block__c = '420030603104029';
      listOfAddresses[0].Excluded_from_Territory__c = false;
      listOfAddresses[0].Targeted__c = true;

      listOfAddresses[1].Territory__c = listOfTerritories[0].Id;
      listOfAddresses[1].Plan__c = turf.id;
      listOfAddresses[1].Census_Block__c ='420030603104020';
      listOfAddresses[1].Excluded_from_Territory__c = false;
      listOfAddresses[1].Targeted__c = true;

      system.Test.startTest();
      TurfPlanningController.updateAddresses(listOfAddresses);
      system.Test.stopTest();

      // Asserting that all values have been set correctly.
      system.assertEquals(false, [SELECT Excluded_from_Territory__c FROM Customer_Address__c WHERE Id = :listOfAddresses[0].Id].Excluded_from_Territory__c);
      system.assertEquals('420030603104029', [SELECT Census_Block__c FROM Customer_Address__c WHERE Id = :listOfAddresses[0].Id].Census_Block__c);
      system.assertEquals('420030603104020', [SELECT Census_Block__c FROM Customer_Address__c WHERE Id = :listOfAddresses[1].Id].Census_Block__c);
      system.assertEquals(true, [SELECT Targeted__c FROM Customer_Address__c WHERE Id = :listOfAddresses[1].Id].Targeted__c);
  }

}