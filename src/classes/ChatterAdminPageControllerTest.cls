@isTest
public class ChatterAdminPageControllerTest {
    Public static User user,user1;
    Public static CollaborationGroup gp;
    Public static CollaborationGroupMember gm;
    Public static String groupID;
    Public static List<ID> userIDList ;

    public static void SetData() {
        TriggerSettings__c userTrigger = new TriggerSettings__c() ;
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = false;
        insert userTrigger;
        User u1 = [Select id FROM User WHERE id =: UserInfo.getUserId()]; 
        System.runas(u1){
            user = WorkTestDataUtility.createDSSupervisorUser();
            
            //User user1= WorkTestDataUtility.createDSRepUser();
            userIDList = new List<ID>();
            userIDList.add(user.ID);
            gp = new CollaborationGroup();
            gp.name = 'tests';
            //gp.OwnerId = user.id;
            gp.CollaborationType = 'Public';
            insert gp;
            gm = new CollaborationGroupMember();
            gm.CollaborationGroupId = gp.id;
            gm.MemberId = user.id;
            gm.CollaborationRole = 'Standard';
            insert gm;
            groupID = [Select id,CollaborationGroupId FROM CollaborationGroupMember WHERE CollaborationRole = 'Standard' limit 1].CollaborationGroupId ;
        }
    }
           
    static testMethod void ChatterAdminPageTest3() {
        SetData();
        TriggerSettings__c userTrigger = new TriggerSettings__c() ;
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = false;
        insert userTrigger;
        Profile p = [Select Id, Name From Profile where Name = 'Business Administrator' limit 1];
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        user1 = new User(Alias = 'DSR_' + randomstr.substring(0,4),
        Email = randomstr + 'userTest1@SampleTest.com',
        FirstName='Testing1',
        LastName='Testing2',
        EmailEncodingKey='UTF-8', 
        LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', 
        TimeZoneSidKey='America/Los_Angeles',
        ProfileId = p.Id,
        Username = 'userTest1' + randomstr + '@SampleTest.com',
        Region__c = 'Freedom',
        FederationIdentifier = 'FedId1'+randomstr,
        UserPermissionsWorkDotComUserFeature = true,
        EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
        Terms_and_Conditions_Accepted__c = system.today());            
        insert user1;
        System.runAs(new User(Id = Userinfo.getUserId())){
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Chatter_Group_Page_Access'];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = user1.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }
            List<CollaborationGroup> colGrpList = new List<CollaborationGroup>();
            CollaborationGroup gp1 = new CollaborationGroup();
            gp1.name = 'tests test';
            gp1.CollaborationType = 'Public';
            insert gp1; 
        System.runAs(user1){
            PageReference tpageRef = Page.ChatterAdminPage;
            Test.setCurrentPage(tpageRef);
            ApexPages.StandardController controller = new ApexPages.StandardController(user1);
            ChatterAdminPageController cac = new ChatterAdminPageController(controller);
            cac.searchGrpString ='';
            cac.searchGroup();
            cac.getGroupList();
            cac.addToGroup();
            cac.getUsers();
            cac.addUsersToGroup(gp1.id , userIDList , user.Id);
            cac.removeUsersFromGroup();
            cac.doNext();
            cac.doPrevious();
            cac.doFirst();
            cac.doLast();
            cac.searchGrpString ='tests testing';
            cac.searchGroup();
        
            cac.searchGrpString = 'tests';
            cac.searchGroup();
            cac.selectedGroup = gp.id;
            cac.userId = user.id;
            cac.getGroupList();
            cac.addToGroup();
    
            cac.getUsers();
            cac.addUsersToGroup(groupID , userIDList , user.Id);
            cac.getUsers();
            cac.removeUsersFromGroup();
            cac.searchGrpString = 'ttt';
            cac.searchGroup();
        }
    }
}