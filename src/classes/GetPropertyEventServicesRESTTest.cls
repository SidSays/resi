@isTest
private class GetPropertyEventServicesRESTTest{
    
    private static testMethod void getPropertyEventTest(){
        TestDataUtility.createCustomSettingRecords();
        User xspUser = WorkTestDataUtility.createDSRepUser();
        User xspUser1 = WorkTestDataUtility.createDSRepUser();
        
        TriggerSettings__c teamMemberTrigger = new TriggerSettings__c();
        teamMemberTrigger.Name = 'PropertyEventTeamMemberTrigger';
        teamMemberTrigger.isActive__c = True;
        insert teamMemberTrigger;
            
        MDU_Property__c property = TestDataUtility.createProperty();
        insert property;
        Property_Events__c propertyEvent = new Property_Events__c();
        propertyEvent.name = 'TestPropertyEvent';
        propertyEvent.Type__c = 'Other';
        propertyEvent.Property__c = property.id;
        insert propertyEvent;
        
        Property_Event_Team_Member__c teamMember = new Property_Event_Team_Member__c();
        teamMember.Name = 'Test Team1';
        teamMember.Team_Member__c = xspUser.Id;
        teamMember.Property_Event__c = propertyEvent.Id;
        insert teamMember;
        
        Test.startTest();
            runRESTService(xspUser.Id);
            runRESTService(xspUser1.Id);
        Test.stopTest();
    }
    
    private static void runRESTService(String xspUserId){
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/GetPropertyEventServicesREST';
        request.httpMethod = 'GET';
        request.addParameter('userId',xspUserId);
       
        RestContext.request = request;
        try{
            GetPropertyEventServicesREST.getPropertyEvent();
        }
        catch(Exception e){
            System.debug('Exception occured');
        }
    }
}