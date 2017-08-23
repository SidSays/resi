/***************************************************************************************************************************************
 * Author     : Vivek Patel
 * Date       : 20-Dec-2012
 * Description: This class is TestClass for ExtnOptyOwner class.
 * History
     Version             : 1.0
     Author Last Updated : Vivek Patel 
     PROJECT             : Turnpike
***************************************************************************************************************************************/

@isTest/*(seeAllData = true)*/

public class ExtnOptyOwnerTest {
    public static testMethod void testExtnOptyOwner() {
        SetupTestData.createCustomSettingRecords();
        
        List<Opportunity> optyList = new List<Opportunity>() ;        
        Opportunity oppObj1 = new Opportunity(Name='Test Opty first', StageName='Open', CloseDate=Date.today());
        Opportunity oppObj2 = new Opportunity(Name='Test Opty second', StageName='Open', CloseDate=Date.today());
        User currentUser = [select Id from User where Id = :UserInfo.getUserId()];
        User userObj;
        ExtnOptyOwner extnOptyOwnerObj;
        
        System.runAs(currentUser) {
            insert oppObj1;        
            insert oppObj2;        
            optyList.add(oppObj1);
            optyList.add(oppObj2);
        
            ApexPages.StandardsetController stdSetController = new ApexPages.StandardsetController(optylist);
            stdSetController.setSelected(optylist);
            extnOptyOwnerObj = new ExtnOptyOwner(stdSetController);
            extnOptyOwnerObj.isEmailNotification = true;
            extnOptyOwnerObj.saveOpty();
        
            UserRole userRole = [Select Id from UserRole where Name = 'Indirect Team'];
            Profile userProfile = [Select Id from Profile where Name = 'System Administrator'];
            userObj = new User(LastName='Test User', FederationIdentifier = 'FedId2', UserName='test123456@comcast.com', email='test12345@comcast.com', Alias='tcom', UserRoleId=userRole.Id, ProfileId=userProfile.Id, EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles');
            insert userObj;
        }
        
        System.RunAs(userObj) {
            oppObj1.ownerId = userObj.Id;
            oppObj2.ownerId = userObj.Id;
            extnOptyOwnerObj.saveOpty();
        }
    }
}