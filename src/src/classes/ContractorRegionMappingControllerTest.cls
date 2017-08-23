/*
Test Class for ContractorRegionMappingController
@Author: Shalaka Kadwade
@Date: 08-Nov-2016
*/
  
@isTest
public class ContractorRegionMappingControllerTest {
    
    static testMethod void controllerRegionMappingTest(){
        
        //Declare Variables
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        List<User> usrList = new List<User>();
        //Creating Custom Settings Trigger Setting Datta
        TriggerSettings__c userTrigger = new TriggerSettings__c();
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
        
        TriggerSettings__c oppTrigger = new TriggerSettings__c() ;
        oppTrigger.Name = 'OpportunityTrigger';
        oppTrigger.isActive__c = true;
        triggerSettingsList.add(oppTrigger);
        
        TriggerSettings__c xfinityOppTrigger = new TriggerSettings__c() ;
        xfinityOppTrigger.Name = 'XfinityOpportunityTrigger';
        xfinityOppTrigger.isActive__c = true;
        triggerSettingsList.add(xfinityOppTrigger);
        //insert custom setting records
        if(!triggerSettingsList.isEmpty()){
            Database.insert(triggerSettingsList,false); 
        }
        
        
        // Creating common test Users
        Profile profile1 = [Select Id, Name From Profile where Name = 'XC Manager' limit 1];
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User aeContMag = new User(Alias = 'DSR_' + randomstr.substring(0,4),
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
        usrList.add(aeContMag);
        
        String randomstr3 = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';         
        User aeContMag1 = new User(Alias = 'DSR_' + randomstr.substring(0,4),
                    Email = randomstr + 'userTest1@SampleTest.com',
                    FirstName='Testing2',
                    LastName='Testing2',
                    EmailEncodingKey='UTF-8', 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    TimeZoneSidKey='America/Los_Angeles',
                    ProfileId = profile1.Id,
                    Username = 'userTest12' + randomstr3 + '@SampleTest.com',
                    Region__c = 'Freedom Market',
                    FederationIdentifier = 'FedId21'+randomstr,
                    UserPermissionsWorkDotComUserFeature = true,
                    EmployeeNumber = 'Emp1' + randomstr3.substring(0,4), 
                    Sales_Rep_Type__c='RepType',
                    IsActive =True,
                    Level__c='Level',                
                    Terms_and_Conditions_Accepted__c = system.today());
        usrList.add(aeContMag1);
        
        Profile profile2 = [Select Id, Name From Profile where Name = 'XC AE Contractors' limit 1];
        //generate Random String 
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User aeCont = new User(Alias = 'DSR_' + randomstr1.substring(0,4),
                    Email = randomstr1 + 'userTest1@SampleTest.com',
                    FirstName='Testing3',
                    LastName='Testing3',
                    EmailEncodingKey='UTF-8', 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    TimeZoneSidKey='America/Los_Angeles',
                    ProfileId = profile2.Id,
                    Username = 'userTest13' + randomstr1 + '@SampleTest.com',
                    Region__c = 'Multiple',
                    FederationIdentifier = 'FedId1'+randomstr1,
                    UserPermissionsWorkDotComUserFeature = true,
                    EmployeeNumber = 'Emp1' + randomstr1.substring(0,4), 
                    Sales_Rep_Type__c='RepType',
                    IsActive =True,
                    Level__c='Level', 
                    Managerid = aeContMag.id,
                    Terms_and_Conditions_Accepted__c = system.today());
        usrList.add(aeCont);  
        
        User aeCont1 = new User(Alias = 'DSR_' + randomstr1.substring(0,4),
                    Email = randomstr1 + 'userTest12@SampleTest.com',
                    FirstName='Testing3',
                    LastName='Testing3',
                    EmailEncodingKey='UTF-8', 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    TimeZoneSidKey='America/Los_Angeles',
                    ProfileId = profile2.Id,
                    Username = 'userTest16' + randomstr1 + '@SampleTest.com',
                    Region__c = 'Multiple',
                    FederationIdentifier = 'FedId2'+randomstr1,
                    UserPermissionsWorkDotComUserFeature = true,
                    EmployeeNumber = 'Emp1' + randomstr1.substring(0,4), 
                    Sales_Rep_Type__c='RepType',
                    IsActive =True,
                    Level__c='Level', 
                    Managerid = aeContMag1.id,
                    Terms_and_Conditions_Accepted__c = system.today());
        usrList.add(aeCont1);   

        Database.insert(usrList,false);

        //Create a new Opportunity.
        String XfinityCommunitiesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Xfinity Opportunity Record Type').getRecordTypeId(); 
        Opportunity opportunity = new Opportunity();
        opportunity.RecordTypeId = XfinityCommunitiesRecordTypeId;
        opportunity.Name = 'TestOpportunity';
        opportunity.StageName = 'Open';
        opportunity.CloseDate = System.today();
        opportunity.AssignedAE_ID__c = aeCont.id;
        insert opportunity;
        
		Group grp = [select id, name from Group where Name = 'XC Freedom Region' limit 1];
        PublicGroupRegion__c pgr = new PublicGroupRegion__c();
		pgr.Name = 'Freedom Market';
        pgr.GroupId__c = grp.id;
		pgr.Public_Group_Name__c = grp.Name;
		insert pgr;
		
		GoalTemplateDates__c  goalTemplatedateCS = new GoalTemplateDates__c();
        goalTemplatedateCS.Name = System.Label.QM_AnnualBaselineBatchContractorCusSetData;
        goalTemplatedateCS.Current_Period_Due_Date__c = System.Today().addDays(+2);
        goalTemplatedateCS.Current_Period_Start_Date__c = System.Today().addDays(-2);
        Database.insert(goalTemplatedateCS);

        Contractor_Region_Mapping__c crm = new Contractor_Region_Mapping__c();   
        crm.Reporting_Manager__c = aeContMag.id;
        crm.Region__c = 'Freedom Market';
        crm.AE_Contractor__c= aeCont.id;
        insert crm;
        
        aeCont.Managerid = aeContMag1.id;
        update aeCont;
        
        Goal g = new Goal();
        g.Name = 'Test Goal';
        g.Status = 'Published';
        g.Region__c ='Freedom Market';
        g.StartDate = System.Today().addDays(-2);
        g.DueDate = System.Today().addDays(+2);
        g.recordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.CommunitiesGoalRecordType).getRecordTypeId();
        g.ownerid = aeCont.id;
        insert g;

        System.runAs(new User(Id = UserInfo.getUserId())){
            //Contractor_Region_Mapping__c contRegMap =  new Contractor_Region_Mapping__c();
            //to cover when manager is changed in region mapping record
            crm.Reporting_Manager__c = aeContMag1.Id;
            Update crm;
            
            //to cover when contractor is changed
            crm.AE_Contractor__c = aeCont1.id;
            Update crm;
            
            //to cover delete scenario
            Delete crm;

        } 
    }
}