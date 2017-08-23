//Test Class Modified by Animesh Datta
//Last Modified Date: 11-April-2017
//Added test method aeContractorAndMgrValidationTest to increase test coverage

@isTest
public class GoalTriggerControllertest {
           
    static testMethod void goalSharingMgrGrp(){
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        System.runAs(user){ 
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        
        TriggerSettings__c userTrigger = new TriggerSettings__c() ;
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = false;
        triggerSettingsList.add(userTrigger);
        
        TriggerSettings__c goalTrigger= new TriggerSettings__c();
        goalTrigger.Name = 'GoalTrigger';
        goalTrigger.isActive__c = true;
        triggerSettingsList.add(goalTrigger);
        
        TriggerSettings__c contractTrigger = new TriggerSettings__c() ;
        contractTrigger.Name = 'ContractorRegionMappingTrigger';
        contractTrigger.isActive__c = true;
        triggerSettingsList.add(contractTrigger);
        
        insert triggerSettingsList ;  

        // Creating common test Users
        Profile profile1 = [Select Id, Name From Profile where Name = 'XC Manager' limit 1];
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User XCMgrUser = new User(Alias = 'DSR_' + randomstr.substring(0,4),
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
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4), 
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level',                
                                   Terms_and_Conditions_Accepted__c = system.today());
        insert XCMgrUser ;
              
        Profile profile2 = [Select Id, Name From Profile where Name = :system.label.XC_AE_Contractors limit 1];
        //generate Random String 
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User XCAEContractorUser = new User(Alias = 'DSR_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest1@SampleTest.com',
                                    FirstName='Testing2',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = profile2.Id,
                                    Username = 'userTest1' + randomstr1 + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    FederationIdentifier = 'FedId1'+randomstr1,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr1.substring(0,4), 
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level',                                   
                                   Terms_and_Conditions_Accepted__c = system.today());
        insert XCAEContractorUser ; 
            
        //create ContractorRegionMapping record
        Contractor_Region_Mapping__c crm = new Contractor_Region_Mapping__c();   
        crm.Reporting_Manager__c = XCMgrUser.id;
        crm.Region__c = 'Freedom Market';
        crm.AE_Contractor__c= XCAEContractorUser.id;
        insert crm;
            
        

        //Create Direct Sales User's
        User userManager = WorkTestDataUtility.createDSManagerUserForCoaching();
        insert userManager;
        User dsrUser = WorkTestDataUtility.createDSRepUserForCoaching();
        dsrUser.managerid= userManager.id;
        insert dsrUser;
        
        List<Goal> goalList = new List<Goal>();
        
        String goalDirectSalesRecordType = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.GoalDirectSalesRecordType).getRecordTypeId();
        String goalCommunitiesRecordType = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.CommunitiesGoalRecordType).getRecordTypeId();
        
        
        
        
                       
        // Create Goals.
        Goal goal1 = WorkTestDataUtility.createGoal();
        goal1.ownerid = dsrUser.id;
        goal1.Region__c = 'Freedom Market';
        goal1.recordTypeId = goalDirectSalesRecordType;
        goalList.add(goal1);
        
        Goal goal2 = WorkTestDataUtility.createGoal();
        goal2.ownerid = XCAEContractorUser.id;
        goal2.Region__c = 'Freedom Market';
        goal2.Profile_Name__c = Label.XC_AE_Contractors;
        goal2.recordTypeId = goalCommunitiesRecordType;
        goalList.add(goal2);
        
        Goal goal3 = WorkTestDataUtility.createGoal();
        goal3.ownerid = XCMgrUser.id;
        goal3.Region__c = 'Freedom Market';
        goal3.recordTypeId = goalCommunitiesRecordType;
        goalList.add(goal3);
        
        database.update(goalList,false);    
               
        GoalTriggerController.goalContractorSharingMgrGrp(goalList);
        GoalTriggerController.goalSharingMgrGrp(goalList);
        GoalTriggerController.unshareGoal(goalList);
        }
    }
    
    //To test cover method aeContractorAndMgrValidation
    static testMethod void aeContractorAndMgrValidationTest(){
        
        User xcManagerUser = GoalTestDataUtility.xcManager();
        User xcAEContUser = GoalTestDataUtility.xcAEContractor();
        List<Goal> goalList = new List<Goal>();
        Goal goalAECont;
        Goal goalXCManager;
        
        System.runAs(new User(Id = Userinfo.getUserId())){ 
            GoalTestDataUtility.customSettingsRecord();
            List<User> userlist = new List<User>();     
            userlist.add(xcManagerUser);       
            userlist.add(xcAEContUser);         
            //insert xc manager and ae contractor user
            insert userlist;        
            //create ContractorRegionMapping record
            Contractor_Region_Mapping__c mappingObj = new Contractor_Region_Mapping__c();   
            mappingObj.Reporting_Manager__c = xcManagerUser.id;
            mappingObj.Region__c = 'Freedom Market';
            mappingObj.AE_Contractor__c= xcAEContUser.id;
            insert mappingObj;
            //Get Xfinity Communities Goal RecordTypeId
            String goalCommunitiesRecordType = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.CommunitiesGoalRecordType).getRecordTypeId();
            //Create Goal for ontractor
            goalAECont = WorkTestDataUtility.createGoal();
            goalAECont.ownerid = xcAEContUser.id;
            goalAECont.Region__c = 'Freedom Market';
            goalAECont.Profile_Name__c = Label.XC_AE_Contractors;
            goalAECont.recordTypeId = goalCommunitiesRecordType;
            goalList.add(goalAECont);
            //Create Goal for XC Manager
            goalXCManager = WorkTestDataUtility.createGoal();
            goalXCManager.ownerid = xcManagerUser.id;
            goalXCManager.Region__c = 'Freedom Market';
            goalXCManager.recordTypeId = goalCommunitiesRecordType;
            goalList.add(goalXCManager);
            database.update(goalList,false);
        }   
        //When Manager tries to change value    
        System.runAs(xcManagerUser){ 
            goalXCManager.Name = 'Test AE';
            goalXCManager.Assigned_To__c = xcAEContUser.Id;
            goalXCManager.Description = 'test';
            goalXCManager.StartDate = system.today();
            goalXCManager.DueDate = system.today();
            goalXCManager.Profile_Name__c = 'Xfinity Sales Professional';
            goalXCManager.status = 'Completed';
            goalXCManager.Region__c = 'Beltway Market';
            goalXCManager.ImageUrl = 'www.abc.com';
            goalXCManager.CompletionDate = system.today();
            goalXCManager.ownerId = xcAEContUser.Id;
            try{//For adderror validation
                update goalXCManager;
            }catch(Exception e){}
        }
        //When Contractor tries to change value
        System.runAs(xcAEContUser){ 
            goalAECont.Name = 'Test AE';
            goalAECont.Assigned_To__c = xcManagerUser.Id;
            goalAECont.Description = 'test';
            goalAECont.StartDate = system.today();
            goalAECont.DueDate = system.today();
            goalAECont.Profile_Name__c = 'XC Manager';
            goalAECont.status = 'Completed';
            goalAECont.Region__c = 'Beltway Market';
            goalAECont.ImageUrl = 'www.abc.com';
            goalAECont.CompletionDate = system.today();
            goalAECont.ownerId = xcManagerUser.Id;
            try{//For adderror validation
                update goalAECont;
            }catch(Exception e){}
        }
    }
}