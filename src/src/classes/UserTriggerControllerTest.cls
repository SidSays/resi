/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal, Accenture
 * Date       : 28-May-2013
 * Description: This is Test class for "UserTriggerController" class.
 * History
     Version             : 1.0
     Author Last Updated : Gaurav Aggarwal, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest(seeAllData = false)
public class UserTriggerControllerTest{
    public static testMethod void testUserTriggerController(){
        
        WorkTestDataUtility.createCustomSettingRecords();
        
        User dsrUser = WorkTestDataUtility.createDSRepUser();
        User dssUser = WorkTestDataUtility.createDSSupervisorUser();
        User dssUser1 = WorkTestDataUtility.createDSSupervisorUser();
        User dsmUser1 = WorkTestDataUtility.createDSManagerUser();
        User dsmUser2 = WorkTestDataUtility.createDSManagerUser();
        VariableSettingTestUtility.variableSettingsData();
        
        Test.startTest();        
        System.runAs(dssUser){
        
            // Create Plan
            Plan__c pln = new Plan__c();
            pln.Name = 'TestPlan';
            pln.Plan_Level__c = 'Turf';
            ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
            extnObj1.quickSave();
            pln.User__c = dsrUser.Id;
            extnObj1.Save();
            System.assert(pln.Plan_Status__c == 'Assigned');
            
            Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
            
            // Create Address
            Customer_Address__c addr = new Customer_Address__c();
            addr.Address__c = 'Test Address';
            addr.State__c = 'Test State';
            addr.City__c = 'Test City';
            addr.Country__c = 'Test Country';
            addr.PostalCode__c = '12345';
            addr.Node__c = '1111';
            addr.Corp__c = '11111111';
            addr.Route_Code__c = '1111111111';
            addr.Division = freedomRegion.Id;
            addr.Region__c = 'Freedom Market';
            insert addr;
            addr.Plan__c = pln.Id;
            addr.OwnerId = dsrUser.Id;
            update addr;
            
            // Deactivate the User
            //dsrUser.ManagerId = dssUser1.id;
            //dsrUser.IsActive = false;
            // update dssUser;
           // update dsrUser;
            
                                 
            List<User> users = [Select id,ProfileId,UserRoleId,Email,alias from User where Profile.Name IN ('Affiliate Claims User','Affiliate Escalation User','Claims User','Claims Manager','Escalation User')];
            UserTriggerController.addClaimsUsersToGroups(users);
            
             

            Test.stopTest();
        }
        
        
        
     /*   Id p = [select id from profile where name='Escalation User'].id;
       
            Account ac = new Account(name ='Grazitti') ;
            insert ac; 
           
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
            insert con;  
                      
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = con.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com', FederationIdentifier = 'test123@noemail.com');
  
            insert user;
            
            Test.startTest();
            System.runAs(user){
            
            List<User> users = [Select id,ProfileId,UserRoleId,Email,alias from User where Profile.Name IN ('Affiliate Claims User','Affiliate Escalation User','Claims User','Claims Manager','Escalation User')];
            UserTriggerController.addClaimsUsersToGroups(users);
            
             

            Test.stopTest();
            }*/
            
   }  
   
  
   //Test for federation Id is a mandatory field
   public static testMethod void fedIdValMessageTest(){
       
        Profile p = [Select Id, Name From Profile where Name = 'XC Manager' limit 1];
            
                String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
            User XCManagerUser1 = new User(Alias = 'DSR_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = NULL,
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
                                    );
                                    
        database.insert(XCManagerUser1,false);  
        
        String valMessage = 'Please enter the NT Login or BP ID of the user in Federation ID. If the user has not been assigned an NT Login or BP ID then please enter the email address of the user';
           
        WorkTestDataUtility.createCustomSettingRecords();
       
        Test.startTest();   
            User userWithFedId = WorkTestDataUtility.createDSRepUser(); 
            //Set Federation Id to Empty        
            userWithFedId.FederationIdentifier = '';        
            try{
                Database.update(userWithFedId);
            }catch(Exception e){
                String errMsg = e.getMessage();                            
                Boolean boolVal = errMsg.containsAny(valMessage);                            
                System.assertEquals(true,boolVal);
            }
        Test.stopTest();
        
    }
   //Test for groups associated with a region
        public static testMethod void regionGroupTest1(){

            WorkTestDataUtility.createCustomSettingRecords();
            //Create a User with System Admin Profile
            Profile systemAdministratorProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User testUser1 = new User(Alias = 'standt24', Email='standarduser22211@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing111322', LanguageLocaleKey='en_US',NTLogin__c='as2d11122',FederationIdentifier='as9d11122',
            LocaleSidKey='en_US', ProfileId = systemAdministratorProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1ww1122@testorgg.com');
            
             Region_Profile_PublicGroups__c regionProfilePublicGroup = new Region_Profile_PublicGroups__c();
            regionProfilePublicGroup.Name = '33';
            regionProfilePublicGroup.Region__c = 'Global';
            regionProfilePublicGroup.Profile_Channel__c = 'XC';
            regionProfilePublicGroup.Public_Group_Name__c = 'XC Beltway Region';
            insert regionProfilePublicGroup;
            
             /*GroupMember groupMemberTobeAdded = new GroupMember();
                    groupMemberTobeAdded.GroupId = regionProfilePublicGroup.id;
                    //groupMemberTobeAdded.Name = regionProfilePublicGroup.Name; 
                    groupMemberTobeAdded.UserOrGroupId = UserInfo.getUserId();
                    insert groupMemberTobeAdded;*/
            
             GoalTemplateDates__c  gt = new GoalTemplateDates__c();
            gt.Name = 'Regional Baseline Quota for Contractor';
            gt.Current_Period_Start_Date__c = System.Today().addDays(-2);
            gt.Current_Period_Due_Date__c = System.Today().addDays(+2); 
            insert gt;  
            //Profile xcAEProfile = [Select Id, Name From Profile where Name = 'XC Account Executive' limit 1];
             String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
       
                 
            Profile p = [Select Id, Name From Profile where Name = 'XC Manager' limit 1];
            
                String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
            User XCManagerUser = new User(Alias = 'DSR_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Global',
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
                                    );
                                    
        database.insert(XCManagerUser,false);  
            
           
      
             System.runas(testUser1){ 
                    Group testGroup1 = new Group();                      
                    testGroup1.Name = 'Global';
                    Insert testGroup1;
                    
                    GroupMember groupMemberTobeAdded1 = new GroupMember();
                    groupMemberTobeAdded1.GroupId = testGroup1.id;
                    groupMemberTobeAdded1.UserOrGroupId = UserInfo.getUserId();
                    insert groupMemberTobeAdded1;
                //Create a User with System Admin Profile               
                                               
                Profile directSales= [SELECT Id FROM Profile WHERE Name=:system.label.DSRProfileName]; 
                User testUser2 = new User(Alias = 'standt21', Email='standaraduser2321@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing11122aa', LanguageLocaleKey='en_US',NTLogin__c='as45122',PERNR__c='10254424',FederationIdentifier='as12d11122',
                LocaleSidKey='en_US', ProfileId = directSales.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standarduser11122@testorgg.com',Region__c = 'Big South Region');
                Insert testUser2;
                
                Group testGroup = new Group();                      
                testGroup.Name = 'Big South Region';
                Insert testGroup;
                
                Profile directSales2= [SELECT Id FROM Profile WHERE Name=:system.label.DSRProfileName]; 
                User testUser3 = new User(Alias = 'standt21', Email='standaraduser232111@testorg.com',PERNR__c='10254424', 
                EmailEncodingKey='UTF-8', LastName='Testing11122aaa', LanguageLocaleKey='en_US',NTLogin__c='as4512233',FederationIdentifier='as12d1112233',
                LocaleSidKey='en_US', ProfileId = directSales2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standarduser11122@testorggg.com',Region__c = 'Big South Region');
                Insert testUser3;
                
                testUser3.region__c=testGroup.name;
                update testUser3;
                
                
                }
           }   

      public static testMethod void regionGroupTest2(){
		WorkTestDataUtility.createCustomSettingRecords();
		//SetupTestData.createCustomSettingRecords();
	
		List<User> testUserList = new List<User>();
		Set<Id> userSet = new Set<Id>();
	
		Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User testUser3 = new User(Alias = 'stt24', Email='stand2ardu2ser22211@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testi2ng1113222', LanguageLocaleKey='en_US',NTLogin__c='as2d1212122',FederationIdentifier='as9d2211122',
		LocaleSidKey='en_US', ProfileId = systemAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='st22andarduser1ww1122@testorgg.com');
		Insert testUser3;
	
		Profile systemAdministratorProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User testUser1 = new User(Alias = 'stt24', Email='standardu2ser22211@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testi2ng111322', LanguageLocaleKey='en_US',NTLogin__c='as2d121122',FederationIdentifier='as9d211122',
		LocaleSidKey='en_US', ProfileId = systemAdministratorProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='st2andarduser1ww1122@testorgg.com');
		List<Region_Profile_PublicGroups__c> regionProfilePublicGroupList = new List<Region_Profile_PublicGroups__c>();
		Region_Profile_PublicGroups__c regionProfilePublicGroup1 = new Region_Profile_PublicGroups__c();
		regionProfilePublicGroup1.Name = '35';
		regionProfilePublicGroup1.Region__c = 'Beltway Market';
		regionProfilePublicGroup1.Profile_Channel__c = 'XC';
		regionProfilePublicGroup1.Public_Group_Name__c = 'XC Beltway Region';
		regionProfilePublicGroupList.add(regionProfilePublicGroup1);
	
		Region_Profile_PublicGroups__c regionProfilePublicGroup2 = new Region_Profile_PublicGroups__c();
		regionProfilePublicGroup2.Name = '1';
		regionProfilePublicGroup2.Region__c = 'Beltway Market';
		regionProfilePublicGroup2.Profile_Channel__c = 'CAR Manager';
		regionProfilePublicGroup2.Public_Group_Name__c = 'CAR Managers - Beltway';
		regionProfilePublicGroupList.add(regionProfilePublicGroup2);
	
		Region_Profile_PublicGroups__c regionProfilePublicGroup3 = new Region_Profile_PublicGroups__c();
		regionProfilePublicGroup3.Name = '2';
		regionProfilePublicGroup3.Region__c = 'Beltway Market';
		regionProfilePublicGroup3.Profile_Channel__c = 'Direct Sales';
		regionProfilePublicGroup3.Public_Group_Name__c = 'Beltway Market';
		regionProfilePublicGroupList.add(regionProfilePublicGroup3);
		
		Database.insert(regionProfilePublicGroupList,false);
	
		Profile p = [Select Id, Name From Profile where Name = 'XC Manager' limit 1];
	
		String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
		User XCManagerUser1 = new User(Alias = 'DSR_' + randomstr.substring(0,4),
										Email = randomstr + 'userTest1@SampleTest.com',
										FirstName='Testing1',
										LastName='Testing2',
										EmailEncodingKey='UTF-8', 
										LanguageLocaleKey='en_US', 
										LocaleSidKey='en_US', 
										TimeZoneSidKey='America/Los_Angeles',
										ProfileId = p.Id,
										Username = 'userTest1' + randomstr + '@SampleTest.com',
										Region__c = 'Beltway Market',
										Sales_Rep_Type__c='RepType',
										IsActive =True,
										Level__c='Level', 
										FederationIdentifier = 'FedId1'+randomstr,
										UserPermissionsWorkDotComUserFeature = true,
										EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
										Terms_and_Conditions_Accepted__c = system.today()
									);
	
		database.insert(XCManagerUser1,false);  
		System.runas(testUser1){ 
			Group testGroup = new Group();                      
			testGroup.Name = 'Beltway Market';
			Insert testGroup;
	
			GroupMember groupMemberTobeAdded = new GroupMember();
			groupMemberTobeAdded.GroupId = testGroup.id;
			groupMemberTobeAdded.UserOrGroupId = UserInfo.getUserId();
			insert groupMemberTobeAdded;
	
			Profile directSales= [SELECT Id FROM Profile WHERE Name=:system.label.DSRProfileName]; 
			User testUser = new User(Alias = 's2211', Email='stan1da2raduser232111@testorg.com', PERNR__c='10254424',
			EmailEncodingKey='UTF-8', LastName='Testi1ng11122aaa', LanguageLocaleKey='en_US',NTLogin__c='as1425112233',FederationIdentifier='as1122d11122133',
			LocaleSidKey='en_US', ProfileId = directSales.Id, TimeZoneSidKey='America/Los_Angeles', UserName='stan2dard1user11122@testorggg.com',Region__c = 'Global');
			testUser.ManagerId = testUser3.Id;
			insert testUser;
	
			//Cross Channel Lead
			Profile crossChannelProfile = [SELECT Id FROM Profile WHERE Name=:system.label.XC_Direct_Regional_Lead limit 1]; 
			String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1155)+'';
			User crossChannelUser1 = new User(Alias = 's2551',
											Email = randomstr + 'userTest1@SampleTest.com',
											FirstName='Testing2',
											LastName='Testing3',
											EmailEncodingKey='UTF-8', 
											LanguageLocaleKey='en_US', 
											LocaleSidKey='en_US', 
											TimeZoneSidKey='America/Los_Angeles',
											ProfileId = crossChannelProfile.Id,
											Username = 'userTest3' + randomstr1+ '@SampleTest.com',
											Region__c = 'Beltway Market',                                    
											IsActive =True,
											Level__c='Level', 
											FederationIdentifier = 'FedId1'+randomstr1,
											UserPermissionsWorkDotComUserFeature = true,
											EmployeeNumber = 'Emp1' + randomstr1.substring(0,4),
											Terms_and_Conditions_Accepted__c = system.today()
											);
	
			database.insert(crossChannelUser1,true);  
	
			//Cross Channel Lead
			Profile crossChannelProfile1 = [SELECT Id FROM Profile WHERE Name=:system.label.CrossCARXCLeadProfileName limit 1]; 
			String randomstr2 = Math.round(Math.random()*Math.pow(10, 7)+1155)+'';
			User crossChannelUser2 = new User(Alias = 's2551',
											Email = randomstr + 'userTest1@SampleTest.com',
											FirstName='Testing2',
											LastName='Testing4',
											EmailEncodingKey='UTF-8', 
											LanguageLocaleKey='en_US', 
											LocaleSidKey='en_US', 
											TimeZoneSidKey='America/Los_Angeles',
											ProfileId = crossChannelProfile1.Id,
											Username = 'userTest3' + randomstr2+ '@SampleTest.com',
											Region__c = 'Beltway Market',                                    
											IsActive =True,
											Level__c='Level', 
											FederationIdentifier = 'FedId1'+randomstr2,
											UserPermissionsWorkDotComUserFeature = true,
											EmployeeNumber = 'Emp1' + randomstr2.substring(0,4),
											Terms_and_Conditions_Accepted__c = system.today()
											);
	
			database.insert(crossChannelUser2,true);  
	
			//Find Rep Lead
			Profile findMangerProfile = [SELECT Id FROM Profile WHERE Name=:system.label.XC_FIND_Manager limit 1]; 
			String randomstr3 = Math.round(Math.random()*Math.pow(10, 7)+1155)+'';
			User findMangerProfileUser = new User(Alias = 's2561',
											Email = randomstr + 'userTest1@SampleTest.com',
											FirstName='Testing2',
											LastName='Testing5',
											EmailEncodingKey='UTF-8', 
											LanguageLocaleKey='en_US', 
											LocaleSidKey='en_US', 
											TimeZoneSidKey='America/Los_Angeles',
											ProfileId = findMangerProfile.Id,
											Username = 'userTest3' + randomstr3+ '@SampleTest.com',
											Region__c = 'Beltway Market',                                    
											IsActive =True,
											Level__c='Level', 
											FederationIdentifier = 'FedId1'+randomstr3,
											UserPermissionsWorkDotComUserFeature = true,
											EmployeeNumber = 'Emp1' + randomstr3.substring(0,4),
											Terms_and_Conditions_Accepted__c = system.today()
											);
	
			database.insert(findMangerProfileUser,true);  

	}
}  

        //Test for change of manager of XSP/SDM
            
        public static testMethod void changeManagerForCoachingTest(){
           
            WorkTestDataUtility.createCustomSettingRecords();
           
            //  DSR - Supervisor
            User userObj2 = WorkTestDataUtility.createDSSupervisorUserForCoaching();          
            insert userObj2;
           
            //  DSR REP
            User userObj1 = WorkTestDataUtility.createDSRepUserForCoaching();             
            userObj1.ManagerId = userObj2.id;
            insert userObj1;
            
            //  DSR - Supervisor
            User userObj = WorkTestDataUtility.createDSSupervisorUserForCoaching();           
            insert userObj;
            
            // Assign PermissionSet to Coresponding Profile user 
            System.runAs(new User(Id=UserInfo.getUserId())){            
                //assignPermissionSet('SalesSpace_Coach_Access_ASM',userObj3.Id);   
                assignPermissionSet('SalesSpace_Coach_Access_SDM',userObj.Id);
                assignPermissionSet('SalesSpace_Coach_Access_SDM',userObj2.Id);
                assignPermissionSet('SalesSpace_Coach_Access_XSP',userObj1.Id);
            }      
        
           
            
            System.runAs(userObj1) {               
                WorkCoaching wcRecord = new WorkCoaching();
                wcRecord.CoachId = userObj2.Id;
                wcRecord.CoachedId = userObj1.Id;
                insert wcRecord;
            }
           
            Test.StartTest();                
                userObj1.ManagerId = userObj.Id;
                update userObj1; 
            Test.StopTest();
             
        }
            
    /*  This method set permission set to user base on permissionSetName
    */ 
    static void assignPermissionSet(String permissionSetName, Id userId){
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;        
        Database.insert(psa,false);
       
    }    
    
    public static testMethod void testaddCARUserToAllCarPublicGroup(){
      
    WorkTestDataUtility.createCustomSettingRecords();
    
    Profile systemAdministratorProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
    User testUser1 = new User(Alias = 'standt24', Email='standarduser22211@testorg.com', 
    EmailEncodingKey='UTF-8', LastName='Testing111322', LanguageLocaleKey='en_US',NTLogin__c='as2d11122',FederationIdentifier='as9d11122',
    LocaleSidKey='en_US', ProfileId = systemAdministratorProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1ww1122@testorgg.com');
            
        System.runas(testUser1){ 
        Group testGroup = new Group();                      
        testGroup.Name = 'All CAR';
        insert testGroup;
  
      
        Profile profile = [Select Id, Name From Profile where Name = 'Xfinity Car' limit 1];
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User xfinityCarUser = new User(Alias = 'C_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = profile.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom',
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
                                    );
        insert xfinityCarUser;
        }
    }   
    
    /*public static testMethod void assignPermissionSet(){
        TestDataUtility.createTrainingRegionCSRecords();
        TestDataUtility.createTrainingRegionCSRecords1();
        //TestDataUtility.createTrainingRegionCMTRecords();
        TestDataUtility.createCustomSettingRecords();
        TestDataUtility.createXCIntegrationUser();
        // User carManagerUser = TestDataUtility.createXfinityCARManagerUser();
        User carManagerUser = [select id from user where id =: userinfo.getUserId()];
        Test.startTest();        
        
        System.runas(carManagerUser){
            AssignPermissionSet('Training_Tab_Access', carManagerUser.id);
        }
        carManagerUser.region__c = 'Beltway Market';
        update carManagerUser;
        Test.stopTest();
    }*/
    
    
    public static testMethod void waveAccessToNewXCUsersTest(){
        WorkTestDataUtility.createCustomSettingRecords();
        
        GoalTemplateDates__c  goalTemplateDateCS = new GoalTemplateDates__c();
        goalTemplateDateCS.Name = 'Default_Communities';
        goalTemplateDateCS.Current_Period_Due_Date__c = System.Today().addDays(+2);
        goalTemplateDateCS.Current_Period_Start_Date__c = System.Today().addDays(-2);
        Database.insert(goalTemplateDateCS);
        
        Profile xcAEProfile = [Select Id, Name From Profile where Name = 'XC Account Executive' limit 1];
        Profile xcMgrProfile = [Select Id, Name From Profile where Name = 'XC Manager' limit 1];
        Profile systemProfile = [Select Id, Name From Profile where Name = 'System Administrator' limit 1];
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User xcAE = new User(Alias = 'C_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = xcAEProfile.Id,
                                    Username = 'userTest1' + randomstr1 + '@SampleTest.com',
                                    Region__c = 'Global',
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level',             
                                    FederationIdentifier = 'FedId1'+randomstr1,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr1.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
          
                          );
        System.runAs(new User(Id=UserInfo.getUserId())){
            database.insert(xcAE,false);
            xcAE.ProfileId = xcMgrProfile.Id;
            database.update(xcAE,true);
            xcAE.ProfileId = systemProfile.Id;
            database.update(xcAE,true);
        }               
    }
    
    public static testMethod void manageChangeFeedbackRequestforSDMTest(){
        WorkTestDataUtility.createCustomSettingRecords();
        VariableSettingTestUtility.variableSettingsData();
        List<User> userList = new List<User>();
        
         //DS - Manager
        User dsmUser1 = WorkTestDataUtility.createDSManagerUserForCoaching();           
        userList.add(dsmUser1); 
        
        //DS - Supervisor
        User dssUser = WorkTestDataUtility.createDSSupervisorUserForCoaching();
        dssUser.managerId = dsmUser1.Id;
        userList.add(dssUser);
            
        //DS - Rep
        User dsrUser = WorkTestDataUtility.createDSRepUserForCoaching();
        dsrUser.managerId = dssUser.Id;
        userList.add(dsrUser);
        
        //DS - Manager
        User dsmUser2 = WorkTestDataUtility.createDSManagerUserForCoaching();           
        userList.add(dsmUser2);     
        database.insert(userList,true);
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            assignPermissionSet('SalesSpace_Coach_Access_ASM',dsmUser2.Id);
            assignPermissionSet('SalesSpace_Coach_Access_ASM',dsmUser1.Id);
            assignPermissionSet('SalesSpace_Coach_Access_SDM',dssUser.Id);
            assignPermissionSet('SalesSpace_Coach_Access_XSP',dsrUser.Id);
        }
        
        RecordType xspRecType = [SELECT Id,Name FROM RecordType WHERE SObjectType='WorkPerformanceCycle' AND Name =:Label.XSP_Ridealong LIMIT 1];
        
        WorkPerformanceCycle wperformance = new WorkPerformanceCycle();
        wperformance.Name = 'Performance1';
        wperformance.ActivityFrom = System.Today();
        wperformance.ActivityTo = System.Today();
        wperformance.RecordTypeId = xspRecType.Id;
        insert wperformance ;
        
        WorkFeedbackQuestionSet wquestion = new WorkFeedbackQuestionSet ();
        wquestion.Name = 'Test Name';
        wquestion.PerformanceCycleId = wperformance.Id;
        wquestion.FeedbackType = 'CycleManager';
        wquestion.duedate = System.Today()+30;
        insert wquestion;
        
        WorkFeedbackQuestion wquest = new WorkFeedbackQuestion ();
        wquest.QuestionSetId = wquestion.Id;
        wquest.Name = 'Overall Notes';
        wquest.Text = 'Overall Notes';
        wquest.detail = 'Test Detail';
        wquest.Number = 1;
        wquest.Type = 'Freetext';
        wquest.Category__c = 'Prepare - Energy';
        wquest.Section__c = 'Observations';
        wquest.Weight__c = 20;
        insert wquest;
        
        
        WorkFeedBackRequest wfr = new WorkFeedBackRequest();
        wfr.RecipientId = dssUser.Id; 
        wfr.SubjectId = dsrUser.Id;
        wfr.Type__c= 'Walkalong';       
        wfr.Score__c = 10;
        wfr.FeedbackRequestState='Submitted';
        wfr.QuestionSetId=wquestion.Id;
        insert wfr;
        
        
        dsrUser.managerId = dsmUser2.Id;
        update dsrUser;
        
    }
    public static testMethod void assignPermissionSetTest(){
        WorkTestDataUtility.createCustomSettingRecords();
        Profile xcCarMgrProfile = [Select Id, Name From Profile where Name = 'Xfinity CAR Manager' limit 1];
        
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User xcCarMgr = new User(Alias = 'C_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = xcCarMgrProfile.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'California Market',
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
          
                          );
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            database.insert(xcCarMgr,true);
            xcCarMgr.Region__c = 'Houston Market';
            database.update(xcCarMgr,true);
            xcCarMgr.Region__c = 'Florida Region';
            database.update(xcCarMgr,true);         
        }
    }
    public static testMethod void addRemoveFromChatterGroupTest(){
        WorkTestDataUtility.createCustomSettingRecords();
        CollaborationGroup collaborationGroup1 = new CollaborationGroup();
        collaborationGroup1.Name = 'test Indirect Sales';
        collaborationGroup1.CollaborationType = 'Public';
        insert collaborationGroup1;
        
        String temp1 = collaborationGroup1.id;
        
        CollaborationGroup collaborationGroup2 = new CollaborationGroup();
        collaborationGroup2.Name = 'test Indirect Sales Leader';
        collaborationGroup2.CollaborationType = 'Public';
        insert collaborationGroup2;
        String temp2 = collaborationGroup2.id;
        String groupIds = temp1 + ',' + temp2;
        ProfileVsChatterGroup__c custSetData = new ProfileVsChatterGroup__c();
        custSetData.Name = 'Retail Sales Manager';
        custSetData.Chatter_Group_Ids__c = groupIds;
        insert custSetData;
        
        Profile retailSalesMgr = [Select Id, Name From Profile where Name = 'Retail Sales Manager' limit 1];
        
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User retailMgr = new User(Alias = 'C_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest19879@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = retailSalesMgr.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'California Market',
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'FedId187897'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp10980' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
          
                          );
        insert retailMgr;
        
        Profile systemAdminProfile = [Select Id, Name From Profile where Name = 'Retail Sales Executive' limit 1];
        System.runAs(new User(Id=UserInfo.getUserId())){
            retailMgr.ProfileId = systemAdminProfile.Id;
            update retailMgr;
        }
    }
    
    /*public static testMethod void escalationGroupTest(){
        WorkTestDataUtility.createCustomSettingRecords();
        Group escalationGroup = new Group();                      
        escalationGroup.Name = 'Escalation Group';
        Insert escalationGroup;

        Profile escalationProf = [SELECT Name, Id FROM Profile WHERE Name='Escalation User' limit 1];
        User escalationUser = new User(Alias = 'Ctafz',
                        Email = 'userTest19879@SampleTest.com',
                        FirstName='Testing1',
                        LastName='Testing2',
                        EmailEncodingKey='UTF-8', 
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', 
                        TimeZoneSidKey='America/Los_Angeles',
                        ProfileId = escalationProf.Id,
                        Username = 'userTest1@SamTest.com',
                        Region__c = 'California Market',
                        Sales_Rep_Type__c='RepType',
                        IsActive =True,
                        Level__c='Level', 
                        FederationIdentifier = 'FedId187897123',
                        UserPermissionsWorkDotComUserFeature = true,
                        EmployeeNumber = 'Emp101110',
                        Terms_and_Conditions_Accepted__c = system.today());
        insert escalationUser;
    }*/
    
    
    public static testMethod void createNewAEGoalFutureTest(){
        WorkTestDataUtility.createCustomSettingRecords();
        
        GoalTemplateDates__c  goalTemplateDateCS = new GoalTemplateDates__c();
        goalTemplateDateCS.Name = 'Default_Communities';
        goalTemplateDateCS.Current_Period_Start_Date__c = System.Today().addDays(+65);
        goalTemplateDateCS.Current_Period_Due_Date__c = System.Today().addDays(+177);       
        Database.insert(goalTemplateDateCS);
        
        //User aeUser = WorkTestDataUtility.createAEUser();
        //insert aeUser;
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            // Create New Goal Template records for AE 
            Goal goalTemp = new Goal(); // Standard obj
            goalTemp.Name = 'Test Goal Template';
            goalTemp.Status = 'Draft';
            goalTemp.Profile_Name__c = 'XC Account Executive';          
            goalTemp.Template_Type__c = system.label.Goal_Template_Type_Communities;
            goalTemp.OwnerId = UserInfo.getUserId();
            goalTemp.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Goal Template').getRecordTypeId();
            //goalTemp.StartDate = System.Today().addDays(-15);
            //goalTemp.DueDate = System.Today().addDays(+15); 
            goalTemp.Region__c = 'Freedom Market';        
            insert goalTemp;
            
            Metric MetricObj = new Metric();
            MetricObj.OwnerId = goalTemp.OwnerId;
            MetricObj.GoalId  = goalTemp.Id;
            MetricObj.Name = 'Units';                               
            MetricObj.TargetValue = 100;
            insert MetricObj;
            
            Goal goalTemp1 = new Goal(); // Standard obj
            goalTemp1.Name = 'Test Goal Template';
            goalTemp1.Status = 'Draft';
            goalTemp1.Profile_Name__c = 'XC Account Executive';          
            goalTemp1.Template_Type__c = system.label.Goal_Template_Type_Communities;
            goalTemp1.OwnerId = UserInfo.getUserId();
            goalTemp1.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Goal Template').getRecordTypeId();
            //goalTemp1.StartDate = System.Today().addDays(-16);
            //goalTemp1.DueDate = System.Today().addDays(+16); 
            goalTemp1.Region__c = 'Beltway Market';        
            insert goalTemp1;
            
            Metric MetricObj1 = new Metric();
            MetricObj1.OwnerId = goalTemp1.OwnerId;
            MetricObj1.GoalId  = goalTemp1.Id;
            MetricObj1.Name = 'Units';                               
            MetricObj1.TargetValue = 100;
            insert MetricObj1;
            
            User aeUser = WorkTestDataUtility.createAEUser();
            insert aeUser;
            /*Goal aeGoal = new Goal(); // Standard obj
            aeGoal.Name = 'Test AE Goal';
            aeGoal.Status = 'Draft';
            aeGoal.Profile_Name__c = 'XC Account Executive';            
            aeGoal.Template_Type__c = system.label.Goal_Template_Type_Communities;
            aeGoal.OwnerId = aeUser.Id;
            aeGoal.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
            aeGoal.StartDate = System.Today().addDays(-16);
            aeGoal.DueDate = System.Today().addDays(+16); 
            aeGoal.Region__c = 'Freedom Market';        
            insert aeGoal;
            
            Metric aeMetricObj = new Metric();
            aeMetricObj.OwnerId = aeGoal.OwnerId;
            aeMetricObj.GoalId  = aeGoal.Id;
            aeMetricObj.Name = 'Units';                               
            aeMetricObj.TargetValue = 100;
            insert aeMetricObj;*/
            
             /*Goal aeGoal1 = new Goal(); // Standard obj
            aeGoal1.Name = 'Test AE Goal1';
            aeGoal1.Status = 'Published';
            aeGoal1.Profile_Name__c = 'XC Account Executive';            
            aeGoal1.Template_Type__c = system.label.Goal_Template_Type_Communities;
            aeGoal1.OwnerId = aeUser.Id;
            aeGoal1.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
            aeGoal1.StartDate = System.Today().addDays(-15);
            aeGoal1.DueDate = System.Today().addDays(+15); 
            aeGoal1.Region__c = 'Freedom Market';        
            insert aeGoal1;
            
            Metric aeMetricObj1 = new Metric();
            aeMetricObj1.OwnerId = aeGoal1.OwnerId;
            aeMetricObj1.GoalId  = aeGoal1.Id;
            aeMetricObj1.Name = 'Units';                               
            aeMetricObj1.TargetValue = 100;
            insert aeMetricObj1;*/
            //System.debug('InTest Class aeUser****'+aeUser);
            //System.debug('InTest Class aeGoal.recordTypeId****'+aeGoal.recordTypeId);
            //System.debug('InTest Class aeGoal.StartDate****'+aeGoal.StartDate);
            //System.debug('InTest Class aeGoal.DueDate****'+aeGoal.DueDate);
            goalTemplateDateCS.Current_Period_Start_Date__c = System.Today().addDays(+367);
            goalTemplateDateCS.Current_Period_Due_Date__c = System.Today().addDays(+379);
            update  goalTemplateDateCS;
            aeUser.Region__c = 'Beltway Market';
            //update aeUser;
        }
        
        Test.startTest();
            
        Test.stopTest();
    }
    public static testMethod void createNewAEGoalFutureTest1(){
        
        WorkTestDataUtility.createCustomSettingRecords();
        
        GoalTemplateDates__c  goalTemplateDateCS = new GoalTemplateDates__c();
        goalTemplateDateCS.Name = 'Default_Communities';
        goalTemplateDateCS.Current_Period_Start_Date__c = System.Today().addDays(+65);
        goalTemplateDateCS.Current_Period_Due_Date__c = System.Today().addDays(+177);       
        Database.insert(goalTemplateDateCS);
        
        //User aeUser = WorkTestDataUtility.createAEUser();
        //insert aeUser;
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            // Create New Goal Template records for AE 
            /*Goal goalTemp = new Goal(); // Standard obj
            goalTemp.Name = 'Test Goal Template';
            goalTemp.Status = 'Draft';
            goalTemp.Profile_Name__c = 'XC Account Executive';          
            goalTemp.Template_Type__c = system.label.Goal_Template_Type_Communities;
            goalTemp.OwnerId = UserInfo.getUserId();
            goalTemp.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Goal Template').getRecordTypeId();
            //goalTemp.StartDate = System.Today().addDays(-15);
            //goalTemp.DueDate = System.Today().addDays(+15); 
            goalTemp.Region__c = 'Freedom Market';        
            insert goalTemp;
            
            Metric MetricObj = new Metric();
            MetricObj.OwnerId = goalTemp.OwnerId;
            MetricObj.GoalId  = goalTemp.Id;
            MetricObj.Name = 'Units';                               
            MetricObj.TargetValue = 100;
            insert MetricObj;*/
            User aeUser = WorkTestDataUtility.createAEUser();
            insert aeUser;
            /*Goal goalTemp1 = new Goal(); // Standard obj
            goalTemp1.Name = 'Test Goal Template';
            goalTemp1.Status = 'Draft';
            goalTemp1.Profile_Name__c = 'XC Account Executive';          
            goalTemp1.Template_Type__c = system.label.Goal_Template_Type_Communities;
            goalTemp1.OwnerId = UserInfo.getUserId();
            goalTemp1.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Goal Template').getRecordTypeId();
            //goalTemp1.StartDate = System.Today().addDays(-16);
            //goalTemp1.DueDate = System.Today().addDays(+16); 
            goalTemp1.Region__c = 'Beltway Market';        
            insert goalTemp1;
            
            Metric MetricObj1 = new Metric();
            MetricObj1.OwnerId = goalTemp1.OwnerId;
            MetricObj1.GoalId  = goalTemp1.Id;
            MetricObj1.Name = 'Units';                               
            MetricObj1.TargetValue = 100;
            insert MetricObj1;*/
            
            
            /*Goal aeGoal = new Goal(); // Standard obj
            aeGoal.Name = 'Test AE Goal';
            aeGoal.Status = 'Draft';
            aeGoal.Profile_Name__c = 'XC Account Executive';            
            aeGoal.Template_Type__c = system.label.Goal_Template_Type_Communities;
            aeGoal.OwnerId = aeUser.Id;
            aeGoal.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
            aeGoal.StartDate = System.Today().addDays(-16);
            aeGoal.DueDate = System.Today().addDays(+16); 
            aeGoal.Region__c = 'Freedom Market';        
            insert aeGoal;
            
            Metric aeMetricObj = new Metric();
            aeMetricObj.OwnerId = aeGoal.OwnerId;
            aeMetricObj.GoalId  = aeGoal.Id;
            aeMetricObj.Name = 'Units';                               
            aeMetricObj.TargetValue = 100;
            insert aeMetricObj;*/
            
             Goal aeGoal1 = new Goal(); // Standard obj
            aeGoal1.Name = 'Test AE Goal1';
            aeGoal1.Status = 'Published';
            aeGoal1.Profile_Name__c = 'XC Account Executive';            
            aeGoal1.Template_Type__c = system.label.Goal_Template_Type_Communities;
            aeGoal1.OwnerId = aeUser.Id;
            aeGoal1.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
            aeGoal1.StartDate = System.Today().addDays(-15);
            aeGoal1.DueDate = System.Today().addDays(+15); 
            aeGoal1.Region__c = 'Freedom Market';        
            insert aeGoal1;
            
            Metric aeMetricObj1 = new Metric();
            aeMetricObj1.OwnerId = aeGoal1.OwnerId;
            aeMetricObj1.GoalId  = aeGoal1.Id;
            aeMetricObj1.Name = 'Units';                               
            aeMetricObj1.TargetValue = 100;
            insert aeMetricObj1;
            //System.debug('InTest Class aeUser****'+aeUser);
            //System.debug('InTest Class aeGoal.recordTypeId****'+aeGoal.recordTypeId);
            //System.debug('InTest Class aeGoal.StartDate****'+aeGoal.StartDate);
            //System.debug('InTest Class aeGoal.DueDate****'+aeGoal.DueDate);
            goalTemplateDateCS.Current_Period_Start_Date__c = System.Today().addDays(+367);
            goalTemplateDateCS.Current_Period_Due_Date__c = System.Today().addDays(+379);
            update  goalTemplateDateCS;
            Test.startTest();
            aeUser.Region__c = 'Beltway Market';
            update aeUser;
            Test.stopTest();
        } 
    }
    public static testMethod void updateNTIDTest(){
        WorkTestDataUtility.createCustomSettingRecords();
        
        
               
        Profile retailSalesMgr = [Select Id, Name From Profile where Name = 'Retail Sales Manager' limit 1];
        
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User retailMgr = new User(Alias = 'C_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest19879@SampleerTest.com',
                                    FirstName='Testfing1',
                                    LastName='Testifng2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = retailSalesMgr.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTreest.com',
                                    Region__c = 'California Market',
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'FedId187897'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp10980' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
          
                          );
        insert retailMgr;
        User retailMgr1 = new User(Alias = 'C_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest19879@SampleTerest.com',
                                    FirstName='Testifng1',
                                    LastName='Testifng2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = retailSalesMgr.Id,
                                    Username = 'userTest1' + randomstr + '@SamerplerTest.com',
                                    Region__c = 'California Market',
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'hghghghghhghggeeeeeeeee',
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp10980' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
          
                          );
        insert retailMgr1;
        
        Profile systemAdminProfile = [Select Id, Name From Profile where Name = 'System Administrator' limit 1];
        System.runAs(new User(Id=UserInfo.getUserId())){
            retailMgr.FederationIdentifier = 'sfjsfskffsjfskfskjfskjfskfjsfkjsfkjsfkjsff';
            update retailMgr;
            retailMgr1.FederationIdentifier = 'tetstetstetstet';
             update retailMgr1;
        }
    }
    public static testMethod void createCoachingSharingForReactivedUserTest(){
        WorkTestDataUtility.createCustomSettingRecords();
        VariableSettingTestUtility.variableSettingsData();
        List<User> userList = new List<User>();
        List<User> userList1 = new List<User>();
        List<User> userList2 = new List<User>();
        
        //DS - Supervisor
        User dssUser = WorkTestDataUtility.createDSSupervisorUserForCoaching();
        insert dssUser;
        //userList.add(dssUser);
            
        //DS - Rep
        User dsrUser = WorkTestDataUtility.createDSRepUserForCoaching();
        dsrUser.managerId = dssUser.Id;
        insert dsrUser;
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            assignPermissionSet('SalesSpace_Coach_Access_SDM',dssUser.Id);
            assignPermissionSet('SalesSpace_Coach_Access_XSP',dsrUser.Id);
        }
        System.runAs(dssUser){
            WorkCoaching coachingRecord= new WorkCoaching();
            coachingRecord.CoachId = dssUser.Id;
            coachingRecord.CoachedId = dsrUser.Id;
            insert coachingRecord;
        }
        System.runAs(new User(Id=UserInfo.getUserId())){
            dsrUser.isActive = false;
            userList1.add(dsrUser);
            update userList1;
            userList2.add(dsrUser);
            dsrUser.isActive = true;
            update userList2;
        }
    }
    
    public static testMethod void updateMonthlyCARGoalsTest() {
        WorkTestDataUtility.createCustomSettingRecords();
        Profile profile1 = [Select Id, Name From Profile where Name = 'Xfinity CAR' limit 1];
        List<User> userList = new List<User>();
        List<User> userList1 = new List<User>();
        List<User> userList2 = new List<User>();
        
        Profile profile2 = [Select Id, Name From Profile where Name = 'Xfinity CAR Manager' limit 1];
        
        //generate Random String 
        String randomstr2 = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User CARmanager1 = new User(Alias = 'CAR_' + randomstr2.substring(0,4),
            Email = randomstr2 + 'userTest1@SampleTest.com',
            FirstName='Testing2',
            LastName='Testing2',
            EmailEncodingKey='UTF-8', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = profile2.Id,
            Username = 'userTest1' + randomstr2 + '@SampleTest.com',
            Region__c = 'Freedom Market',
            FederationIdentifier = 'FedId1'+randomstr2,
            EmployeeNumber = 'Emp1' + randomstr2.substring(0,4), 
            IsActive =True,
            Level__c='Level',
            UserPermissionsWorkDotComUserFeature = true,                                    
            Terms_and_Conditions_Accepted__c = system.today());
        userList1.add(CARmanager1);
        
        String randomstr3 = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User CARmanager2 = new User(Alias = 'CAR_' + randomstr3.substring(0,4),
            Email = randomstr3 + 'userTest1@SampleTest.com',
            FirstName='Testing2',
            LastName='Testing2',
            EmailEncodingKey='UTF-8', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = profile2.Id,
            Username = 'userTest1' + randomstr3 + '@SampleTest.com',
            Region__c = 'Freedom Market',
            FederationIdentifier = 'FedId1'+randomstr3,
            EmployeeNumber = 'Emp1' + randomstr3.substring(0,4), 
            IsActive =True,
            Level__c='Level',
            UserPermissionsWorkDotComUserFeature = true,                                    
            Terms_and_Conditions_Accepted__c = system.today());
            userList1.add(CARmanager2);
            insert userList1;
        
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User CARuser1 = new User(Alias = 'CAR_' + randomstr.substring(0,4),
            Email = randomstr + 'userTest1@SampleTest.com',
            FirstName='Testing1',
            LastName='Testing2',
            EmailEncodingKey='UTF-8', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = profile1.Id,
            Username = 'userTest1' + randomstr + '@SampleTest.com',
            Region__c = 'Freedom Market',
            FederationIdentifier = 'FedId1'+randomstr,
            EmployeeNumber = 'Emp1' + randomstr.substring(0,4), 
            IsActive =True,
            Level__c='Level',
            ManagerId = CARmanager1.Id,
            UserPermissionsWorkDotComUserFeature = true,                                    
            Terms_and_Conditions_Accepted__c = system.today());
        userList.add(CARuser1);
        //generate Random String 
       String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User CARuser2 = new User(Alias = 'CAR_' + randomstr1.substring(0,4),
            Email = randomstr1 + 'userTest1@SampleTest.com',
            FirstName='Testing1',
            LastName='Testing2',
            EmailEncodingKey='UTF-8', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = profile1.Id,
            Username = 'userTest1' + randomstr1 + '@SampleTest.com',
            Region__c = 'Freedom Market',
            FederationIdentifier = 'FedId1'+randomstr1,
            EmployeeNumber = 'Emp1' + randomstr1.substring(0,4), 
            IsActive =True,
            Level__c='Level',
            ManagerId = CARmanager1.Id,     
            UserPermissionsWorkDotComUserFeature = true,                                    
            Terms_and_Conditions_Accepted__c = system.today());
        userList.add(CARuser2);
        insert userList;
        
        List<Goal> goalList = new List<Goal>();
        List<Metric> metricList = new List<Metric>();
            //CAR1 Goal
            Goal car1Goal = new Goal(); // Standard obj
            car1Goal.Name = 'Test CAR1 Goal1';
            car1Goal.Status = 'Published';
            car1Goal.Profile_Name__c = 'Xfinity CAR';            
            car1Goal.Template_Type__c = 'Property Lab';
            car1Goal.OwnerId = CARuser1.Id;
            car1Goal.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Property Lab').getRecordTypeId();
            car1Goal.StartDate = System.Today().addDays(-15);
            car1Goal.DueDate = System.Today().addDays(+15); 
            car1Goal.Region__c = 'Freedom Market';        
            goalList.add(car1Goal);
            
            //CAR2 Goal
            Goal car2Goal = new Goal(); // Standard obj
            car2Goal.Name = 'Test CAR1 Goal1';
            car2Goal.Status = 'Published';
            car2Goal.Profile_Name__c = 'Xfinity CAR';            
            car2Goal.Template_Type__c = 'Property Lab';
            car2Goal.OwnerId = CARuser2.Id;
            car2Goal.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Property Lab').getRecordTypeId();
            car2Goal.StartDate = System.Today().addDays(-15);
            car2Goal.DueDate = System.Today().addDays(+15); 
            car2Goal.Region__c = 'Freedom Market';        
            goalList.add(car2Goal);
            
            //Manager1 Goal
            Goal carMgr1Goal = new Goal(); // Standard obj
            carMgr1Goal.Name = 'Test CAR Manager1 Goal1';
            carMgr1Goal.Status = 'Published';
            carMgr1Goal.Profile_Name__c = 'Xfinity CAR Manager';            
            carMgr1Goal.Template_Type__c = 'Property Lab';
            carMgr1Goal.OwnerId = CARmanager1.Id;
            carMgr1Goal.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Property Lab').getRecordTypeId();
            carMgr1Goal.StartDate = System.Today().addDays(-15);
            carMgr1Goal.DueDate = System.Today().addDays(+15); 
            carMgr1Goal.Region__c = 'Freedom Market';        
            goalList.add(carMgr1Goal);
            
            //Manager2 Goal
            Goal carMgr2Goal = new Goal(); // Standard obj
            carMgr2Goal.Name = 'Test CAR1 Goal1';
            carMgr2Goal.Status = 'Published';
            carMgr2Goal.Profile_Name__c = 'Xfinity CAR Manager';            
            carMgr2Goal.Template_Type__c = 'Property Lab';
            carMgr2Goal.OwnerId = CARmanager2.Id;
            carMgr2Goal.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Property Lab').getRecordTypeId();
            carMgr2Goal.StartDate = System.Today().addDays(-15);
            carMgr2Goal.DueDate = System.Today().addDays(+15); 
            carMgr2Goal.Region__c = 'Freedom Market';        
            goalList.add(carMgr2Goal);
            
            system.runAs(new User(Id = Userinfo.getUserId())){
                assignPermissionSet('SalesSpace_Coach_Access_CAR',CARuser1.Id);
                assignPermissionSet('SalesSpace_Coach_Access_CAR',CARuser2.Id);
                assignPermissionSet('SalesSpace_Coach_Access_CAR_Manager',CARmanager1.Id);
                assignPermissionSet('SalesSpace_Coach_Access_CAR_Manager',CARmanager2.Id);
                insert goalList;
            }
            
            //CAR1 Metrics
            Metric car1Metric1 = new Metric();
            car1Metric1.OwnerId = CARuser1.Id;
            car1Metric1.GoalId  = car1Goal.Id;
            car1Metric1.Name = System.Label.Metric_Name_TotalPropertyVisitsperMonth;                               
            car1Metric1.TargetValue = 100;
            metricList.add(car1Metric1);
            
            Metric car1Metric2 = new Metric();
            car1Metric2.OwnerId = CARuser1.Id;
            car1Metric2.GoalId  = car1Goal.Id;
            car1Metric2.Name = System.Label.Metric_Name_AveragePropertyVisitsperDay;                               
            car1Metric2.TargetValue = 100;
            metricList.add(car1Metric2);
            
            Metric car1Metric3 = new Metric();
            car1Metric3.OwnerId = CARuser1.Id;
            car1Metric3.GoalId  = car1Goal.Id;
            car1Metric3.Name = System.Label.Metric_Name_Events;                               
            car1Metric3.TargetValue = 100;
            metricList.add(car1Metric3);
            //
            
            //CAR2 Metrics
            Metric car2Metric1 = new Metric();
            car2Metric1.OwnerId = CARuser2.Id;
            car2Metric1.GoalId  = car2Goal.Id;
            car2Metric1.Name = System.Label.Metric_Name_TotalPropertyVisitsperMonth;                               
            car2Metric1.TargetValue = 100;
            metricList.add(car2Metric1);
            
            Metric car2Metric2 = new Metric();
            car2Metric2.OwnerId = CARuser2.Id;
            car2Metric2.GoalId  = car2Goal.Id;
            car2Metric2.Name = System.Label.Metric_Name_AveragePropertyVisitsperDay;                               
            car2Metric2.TargetValue = 100;
            metricList.add(car2Metric2);
            
            Metric car2Metric3 = new Metric();
            car2Metric3.OwnerId = CARuser2.Id;
            car2Metric3.GoalId  = car2Goal.Id;
            car2Metric3.Name = System.Label.Metric_Name_Events;                               
            car2Metric3.TargetValue = 100;
            metricList.add(car2Metric3);
            //
            
            
            ////Manager1 Metrics
            Metric carMgr1Metric1 = new Metric();
            carMgr1Metric1.OwnerId = CARmanager1.Id;
            carMgr1Metric1.GoalId  = carMgr1Goal.Id;
            carMgr1Metric1.Name = System.Label.Metric_Name_TotalPropertyVisitsperMonth;                               
            carMgr1Metric1.TargetValue = 100;
            metricList.add(carMgr1Metric1);
            
            Metric carMgr1Metric2 = new Metric();
            carMgr1Metric2.OwnerId = CARmanager1.Id;
            carMgr1Metric2.GoalId  = carMgr1Goal.Id;
            carMgr1Metric2.Name = System.Label.Metric_Name_AveragePropertyVisitsperDay;                               
            carMgr1Metric2.TargetValue = 100;
            metricList.add(carMgr1Metric2);
            
            Metric carMgr1Metric3 = new Metric();
            carMgr1Metric3.OwnerId = CARmanager1.Id;
            carMgr1Metric3.GoalId  = carMgr1Goal.Id;
            carMgr1Metric3.Name = System.Label.Metric_Name_Events;                               
            carMgr1Metric3.TargetValue = 100;
            metricList.add(carMgr1Metric3);
            //
            
            
            ////Manager2 Metrics
            Metric carMgr2Metric1 = new Metric();
            carMgr2Metric1.OwnerId = CARmanager2.Id;
            carMgr2Metric1.GoalId  = carMgr2Goal.Id;
            carMgr2Metric1.Name = System.Label.Metric_Name_TotalPropertyVisitsperMonth;                               
            carMgr2Metric1.TargetValue = 100;
            metricList.add(carMgr2Metric1);
            
            Metric carMgr2Metric2 = new Metric();
            carMgr2Metric2.OwnerId = CARmanager2.Id;
            carMgr2Metric2.GoalId  = carMgr2Goal.Id;
            carMgr2Metric2.Name = System.Label.Metric_Name_AveragePropertyVisitsperDay;                               
            carMgr2Metric2.TargetValue = 100;
            metricList.add(carMgr2Metric2);
            
            Metric carMgr2Metric3 = new Metric();
            carMgr2Metric3.OwnerId = CARmanager2.Id;
            carMgr2Metric3.GoalId  = carMgr2Goal.Id;
            carMgr2Metric3.Name = System.Label.Metric_Name_Events;                               
            carMgr2Metric3.TargetValue = 100;
            metricList.add(carMgr2Metric3);
        //
        system.runAs(new User(Id = Userinfo.getUserId())){
            insert metricList;
        }
        
        CARuser1.ManagerId = CARmanager2.Id;
        CARuser2.ManagerId = CARmanager2.Id;
        userList2.add(CARuser1);
        userList2.add(CARuser2);
        update userList2;
    }
}