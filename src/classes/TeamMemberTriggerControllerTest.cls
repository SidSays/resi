/***************************************************************************************************************************************
 * Author     : Apurva Gandhi, Accenture
 * Date       : 20/12/2013
 * Description: This class is test class for TeamMemberTriggerController
 * History
     Version             : 1.0
     Author Last Updated : Apurva Gandhi, Accenture
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class TeamMemberTriggerControllerTest{
    public static testmethod void testteammember(){
        SetupTestData.createCustomSettingRecords();
        SetupTestData.createUsers();
        User usr = SetupTestData.supervisorUser;
        System.runas(SetupTestData.supervisorUser){
            test.startTest();
            Team__C team1=new Team__C();
            team1.Name='testteam1';
            team1.Region__c=usr.Region__c;
            team1.Supervisor__c=((String)(SetupTestData.supervisorUser.id));
            insert team1;
            Team_Member__c  TeamMember1= new Team_Member__c ();
            TeamMember1.User_Name__c=((String)(SetupTestData.dsrUser.id));
            TeamMember1.Team__c=((String)(team1.id));
            insert TeamMember1;
            Team_Member__c  TeamMember2= new Team_Member__c();
            TeamMember2.User_Name__c=((String)(SetupTestData.dsrUser2.id));
            TeamMember2.Team__c=((String)(team1.id));
            insert TeamMember2;
            delete TeamMember1;
            TeamMember2.User_Name__c=((String)(SetupTestData.dsrUser.id));
            update TeamMember2;
            undelete TeamMember1;
            test.stopTest();
        }
    }
}