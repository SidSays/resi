@isTest
private class MapMyPropertiesControllerTest {
    private static MDU_Property__c propertyForTest;
	private static MapMyPropertiesController controllerInstance;

    public static testMethod void testGetTypeOptions(){        
 		propertyForTest = TestDataUtility.createProperty();
        propertyForTest.Property_Location__Latitude__s = 39.952583;
        propertyForTest.Property_Location__Longitude__s = -75.165222;
        propertyForTest.Assigned_CAR__c= UserInfo.getUserId();
        database.insert(propertyForTest);     
        //controllerInstance = new MapMyPropertiesController();
        Test.startTest();
	  	controllerInstance = new MapMyPropertiesController();
        List<String> lstStr= controllerInstance.location;
        String a=controllerInstance.locationsJson;
        Test.stopTest();
     }

}