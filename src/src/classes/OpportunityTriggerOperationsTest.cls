/***************************************************************************************************************************************
 * Author     :Jui Desai, Accenture
 * Date       : 24-Feb-2015
 * Description: This is Test class for "OpportunityTrigger" trigger
 * History
     Version             : 1.0
     Author Last Updated : Jui, Accenture 
     PROJECT             : MDU Salesforce
***************************************************************************************************************************************/

@isTest (seeAllData = false)

Public Class  OpportunityTriggerOperationsTest
{

    /*
      1. This method test that when we update opportunity having stage above contacted and does not have Opportunity Property for that opportunity then it fires validation message 
      2. Also use to set Date in Stage to date on which we change opportunity stage 
    */
    
    static testMethod void OpportunityTriggerOperationsTest(){
        Test.startTest();
        TestDataUtility.createCustomSettingRecords(); 
        User xcIntegrationUser = TestDataUtility.createXCIntegrationUser();                      
        System.runAs(xcIntegrationUser) { 
                                
            List<MDU_Property__c> PropertyList = new List<MDU_Property__c>(); 
            for(integer k = 0 ; k < 5; k++){
                MDU_Property__c PropertyObject = TestDataUtility.createProperty();
                PropertyObject.Common_Area_Wide_WiFi_Ready__c='Yes';
                PropertyObject.Property_Wide_WiFi_Ready__c='Yes';
                PropertyObject.WiFi_Ready__c='Yes';
                PropertyList.add(PropertyObject);
            }
            insert PropertyList;
            
            List<MDU_Property__c> PropertyListID = [select Id from MDU_Property__c];        
            List<Opportunity> OpportunityObject = TestDataUtility.createOpportunity(6);
            for(integer i = 0 ; i < 5; i++){
                OpportunityObject[i].AssignedAE_ID__c = xcIntegrationUser.Id;
                Database.insert(OpportunityObject[i]);
            }
             Test.stopTest();
            List<Opportunity> OpportunityList = [select StageName from Opportunity where id IN:OpportunityObject];  
            List<Opportunity> updatedOppList = new List<Opportunity>();
            
            try{
                for(Opportunity OppObj :OpportunityList ){    
                    OppObj.StageName = 'Negotiating' ;
                    updatedOppList.add(OppObj);
                } 
                Database.Update(updatedOppList); 
            }
            catch(Exception e){
                Boolean exp =  e.getMessage().contains(System.Label.Opportunity_Stage_Validation_Message) ? true : false;
                system.assertEquals(exp,true);
            }  
            
            List<Opportunity> OpportunityDate = [select Date_in_Stage__c from Opportunity limit 1];
            //system.assertEquals(OpportunityDate[0].Date_in_Stage__c,system.today());
        }
                       
       
    }
    
    /* This method test that an opportunity property record is created */
    /*
    static testMethod void InsertOpportunityProperty(){
        Test.startTest();
        
        TestDataUtility.createCustomSettingRecords(); 
        User xcIntegrationUser = TestDataUtility.createXCIntegrationUser();                       
        Id currentProfileId = xcIntegrationUser.ProfileId;       
        TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcIntegrationUser) { 
                   
            List<MDU_Property__c> PropertyList1 = new List<MDU_Property__c>(); 
            for(integer k = 0 ; k < 5; k++){
                MDU_Property__c PropertyObject1 = TestDataUtility.createProperty();
                PropertyList1.add(PropertyObject1);
            }
            Database.insert(PropertyList1);
            Test.stopTest();
            List<Opportunity> OpportunityObject1 = TestDataUtility.createOpportunity(6);
            for(integer m = 0 ; m < 5; m++){            
                OpportunityObject1[m].AssignedAE_ID__c = xcIntegrationUser.Id;
                OpportunityObject1[m].Property__c = PropertyList1[m].id;
                Database.insert(OpportunityObject1[m]);
            }
        }
        
        
    }
    */
    
    /* This Method test that Active Opportunity checkbox is true for open Opportunity on property on insert*/
    private static testMethod void ActiveOppForInsert() {
        
        TestDataUtility.createCustomSettingRecords();
        Test.startTest();    
        User xcIntegrationUser = TestDataUtility.createXCIntegrationUser();                       
        Id currentProfileId = xcIntegrationUser.ProfileId;       
        //TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcIntegrationUser) {
            
            List<MDU_Property__c> propList = new List<MDU_Property__c>();
            MDU_Property__c propertyObj1  =  TestDataUtility.createProperty();
            propertyObj1.Common_Area_Wide_WiFi_Ready__c='Yes';
            propertyObj1.Property_Wide_WiFi_Ready__c='Yes';
            propertyObj1.WiFi_Ready__c='Yes';
            propList.add(propertyObj1);
            MDU_Property__c propertyObj2  =  TestDataUtility.createProperty();
            propertyObj2.Common_Area_Wide_WiFi_Ready__c='Yes';
            propertyObj2.Property_Wide_WiFi_Ready__c='Yes';
            propertyObj2.WiFi_Ready__c='Yes';
            propList.add(propertyObj2);
            Database.insert(propList);
            Test.stopTest();
            List<Opportunity> oppList = TestDataUtility.createOpportunity(2);
            oppList[0].Property__c = propList[0].id;
      oppList[0].Common_Area_Wide_WiFi_Ready__c='Yes';
            oppList[0].Property_Wide_WiFi_Ready__c='Yes';
            oppList[0].WiFi_Ready__c='Yes';            
            oppList[0].AssignedAE_ID__c = userinfo.getuserid();
            oppList[1].Property__c = propList[1].id; 
            oppList[1].Common_Area_Wide_WiFi_Ready__c='Yes';
            oppList[1].Property_Wide_WiFi_Ready__c='Yes';
            oppList[1].WiFi_Ready__c='Yes';
            Database.insert(oppList);
        
            List<MDU_Property__c> propertyParent = [Select Id, Active_Opportunity__c from MDU_Property__c where Id in :propList];
            System.assertEquals(propertyParent[0].Active_Opportunity__c,true);
            System.assertEquals(propertyParent[1].Active_Opportunity__c,true);
        
         
          
        }
    }
    
    /* This Method test that Active Opportunity checkbox is false on property on update*/
    private static testMethod void ActiveOppForUpdate(){
        
        TestDataUtility.createCustomSettingRecords();
        Test.startTest();
        User xcIntegrationUser = TestDataUtility.createXCIntegrationUser();                       
        Id currentProfileId = xcIntegrationUser.ProfileId;       
        //TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcIntegrationUser) {
            Account accObj = TestDataUtility.createAccount();
            insert accObj; 
            
            MDU_Property__c PropObj2 = TestDataUtility.createProperty();
            PropObj2.Common_Area_Wide_WiFi_Ready__c='Yes';
            PropObj2.Property_Wide_WiFi_Ready__c='Yes';
            PropObj2.WiFi_Ready__c='Yes';
            Database.Insert(PropObj2);  
            Test.stopTest();
            List<Opportunity> oppList = TestDataUtility.createOpportunity(1);
            oppList[0].Property__c = PropObj2.id; 
            oppList[0].Common_Area_Wide_WiFi_Ready__c='Yes';
            oppList[0].Property_Wide_WiFi_Ready__c='Yes';
            oppList[0].WiFi_Ready__c='Yes';
            Database.insert(oppList);
            
            List<Opportunity> oppUpdated = [Select id, StageName from opportunity where id in: oppList];
            oppUpdated[0].AccountId = accObj.Id;
            oppUpdated[0].StageName= 'Closed Won';
            oppUpdated[0].ContractTerm__c = 10;
            oppUpdated[0].ContractTermUnit__c = 'months';
            oppUpdated[0].Contract_Type__c = 'Retail';
            oppUpdated[0].X3rd_Party_Consultant__c = 'Advanced Multi Media';
            oppUpdated[0].Fiber_To_The_Unit__c = 'None';
            Database.update(oppUpdated);
            
            MDU_Property__c PropTemp2 = [Select Id, Active_Opportunity__c from MDU_Property__c where Id = :PropObj2.Id];
            System.assertEquals(PropTemp2.Active_Opportunity__c,false);       
            
           // OpportunityTriggerOperations.propertyActiveOpportunityCheck(oppList);
        }
    } 

    /* This Method test that Active Opportunity checkbox is false on deleting open opportunity*/
    private static testMethod void ActiveOppForDeleteFalse() {   
    
        TestDataUtility.createCustomSettingRecords();
        Test.startTest();
        User xcIntegrationUser = TestDataUtility.createXCIntegrationUser();                       
        Id currentProfileId = xcIntegrationUser.ProfileId;       
        //TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcIntegrationUser) {
       
            MDU_Property__c PropObj = TestDataUtility.createProperty();
            PropObj.Common_Area_Wide_WiFi_Ready__c='Yes';
            PropObj.Property_Wide_WiFi_Ready__c='Yes';
            PropObj.WiFi_Ready__c='Yes';
            Database.Insert(PropObj) ;
             Test.stopTest();
             
            Account accObj = TestDataUtility.createAccount();
            Insert accObj; 
        
            List<Opportunity> oppList = TestDataUtility.createOpportunity(2);
            oppList[0].Property__c = PropObj.id; 
            oppList[1].Property__c = PropObj.id; 
            oppList[1].ContractTerm__c = 10;
            oppList[1].X3rd_Party_Consultant__c = 'Advanced Multi Media';
            oppList[1].ContractTermUnit__c = 'months';
            oppList[1].StageName = 'Closed Won';
            oppList[1].AccountId = accObj.id;
            oppList[1].Contract_Type__c = 'Retail';
            oppList[1].Fiber_To_The_Unit__c = 'None';
            oppList[1].Common_Area_Wide_WiFi_Ready__c = 'Yes';
            oppList[1].WiFi_Ready__c = 'Yes';
            oppList[1].Property_Wide_WiFi_Ready__c = 'Yes';
            Database.insert(oppList);
            
            Database.Delete(oppList[0]);
            MDU_Property__c PropTemp = [Select Id, Active_Opportunity__c from MDU_Property__c where Id = :PropObj.Id];
            System.assertEquals(PropTemp.Active_Opportunity__c,false);
           
        }
    }
    
    /* This Method test that Active Opportunity checkbox is true on deleting closed opportunity*/
    private static testMethod void ActiveOppForDeleteTrue() {   
    
        TestDataUtility.createCustomSettingRecords();
        Test.startTest();
        User xcIntegrationUser = TestDataUtility.createXCIntegrationUser();                       
        Id currentProfileId = xcIntegrationUser.ProfileId;       
        //TestDataUtility.bypassValidationCS(currentProfileId);
         Competitor__c newCompetitor = new Competitor__c();
         newCompetitor.name = 'testCompetitor';
         
        
        System.runAs(xcIntegrationUser) {
            
            Database.Insert(newCompetitor) ;
            
            MDU_Property__c PropObj = TestDataUtility.createProperty();
            PropObj.Common_Area_Wide_WiFi_Ready__c='Yes';
            PropObj.Property_Wide_WiFi_Ready__c='Yes';
            PropObj.WiFi_Ready__c='Yes';
            Database.Insert(PropObj) ;
            
             Test.stopTest();
            List<Opportunity> oppList = TestDataUtility.createOpportunity(2);
            oppList[0].Property__c = PropObj.id; 
            oppList[1].Property__c = PropObj.id; 
            oppList[1].StageName = 'Closed Lost';
            oppList[1].X3rd_Party_Consultant__c = 'Advanced Multi Media';
            oppList[1].ReasonLost_ID__c = 'Other...';
            oppList[1].No_Sale_Outcome_ID__c = 'Terminate Service';
            oppList[1].Competitor__c = newCompetitor.id;
            oppList[1].Competitor_Deal_Type__c = 'Bulk';
            oppList[1].Common_Area_Wide_WiFi_Ready__c = 'Yes';
            oppList[1].WiFi_Ready__c = 'Yes';
            oppList[1].Property_Wide_WiFi_Ready__c = 'Yes';
            
            Database.insert(oppList);
            
            Database.Delete(oppList[1]);
            MDU_Property__c PropTemp = [Select Id, Active_Opportunity__c from MDU_Property__c where Id = :PropObj.Id];
            System.assertEquals(PropTemp.Active_Opportunity__c,true);
           
        }
    } 
    
    /* This Method test if the opportunity stage is closed won then the total number of units will be copy to the current value of the metrics for upto 3-levels*/
    private static testMethod void OpportunityClosedWon() { 
        TestDataUtility.createCustomSettingRecords();
        Account accObj = TestDataUtility.createAccount();
        Insert accObj;
        
        User xcDSManager2User = WorkTestDataUtility.createXCManagerUser();
        User xcDSManagerUser = WorkTestDataUtility.createXCManagerUser();
        User xcDSRUser = WorkTestDataUtility.createAEUser(); 
        
        
        Profile p = [Select Id, Name From Profile where Name = 'XC AE Contractors' limit 1];
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User xcContractorUser = new User(Alias = 'AE_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',                                    
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    IsActive = true,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today());
                 
        
            
        String Communities_RecordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
        //User AdminUser = WorkTestDataUtility.createSAdminUser();
        User currentUser = [Select Id,Region__c, username from User where Id =: userInfo.getUserId()];
        
        List<Opportunity> oppList = TestDataUtility.createOpportunity(2);
        
        
    
        MDU_property__c propObj = TestDataUtility.createProperty();
        PropObj.Common_Area_Wide_WiFi_Ready__c='Yes';
        PropObj.Property_Wide_WiFi_Ready__c='Yes';
        PropObj.WiFi_Ready__c='Yes';
     
        
        System.runAs(currentUser){
            TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = false;
            insert userTrigger;
            
            xcDSRUser.Region__c=currentUser.Region__c;
            xcContractorUser.Region__c=currentUser.Region__c;
            insert xcDSRUser;
            insert xcContractorUser;
            insert propObj;
            
            Goal goalObj = new Goal();
            goalObj.Name = 'Test Goal';
            goalObj.OwnerId = xcDSManager2User.Id;
            goalObj.startDate = System.Today()-1;
            goalObj.DueDate = System.Today()+1;
            goalObj.recordTypeId = Communities_RecordtypeId;
            insert goalObj;
           

            List<Metric> MetricList = new List<Metric>();
            Metric metricNewBuild = new Metric();
            metricNewBuild.goalId = goalObj.id;
            metricNewBuild.name = 'Units';
            metricNewBuild.CurrentValue = 0;
            MetricList.add(metricNewBuild);

            Metric metricRenewal = new Metric();
            metricRenewal.name = 'Renewal';
            metricRenewal.goalId = goalObj.id;
            metricRenewal.CurrentValue = 0;
            MetricList.add(metricRenewal);
            
            Goal goalObj1 = new Goal();
            goalObj1.Name = 'Test Goal1';
            goalObj1.OwnerId = xcDSRUser.Id;
            goalObj1.startDate = System.Today()-2;
            goalObj1.DueDate = System.Today()+2;
            goalObj1.recordTypeId = Communities_RecordtypeId;
            goalObj1.Reporting_Manager__c = xcDSManagerUser.Id;
            insert goalObj1;

            Metric metricUnits = new Metric();
            metricUnits.name = 'Units';
            metricUnits.CurrentValue = 0;
            metricUnits.TargetValue = 100;
            metricUnits.ownerId = goalObj1.OwnerId;
            metricUnits.goalId = goalObj1.id;
            MetricList.add(metricUnits);
            
            
            Goal goalObj2 = new Goal();
            goalObj2.Name = 'Test Goal1';
            goalObj2.OwnerId = xcContractorUser.Id;
            goalObj2.startDate = System.Today()-2;
            goalObj2.DueDate = System.Today()+2;
            goalObj2.recordTypeId = Communities_RecordtypeId;
            goalObj2.Reporting_Manager__c = xcDSRUser.Id;
            insert goalObj2;

            Metric metricUnits2 = new Metric();
            metricUnits2.name = 'Units';
            metricUnits2.CurrentValue = 0;
            metricUnits2.TargetValue = 100;
            metricUnits2.ownerId = goalObj2.OwnerId;
            metricUnits2.goalId = goalObj2.id;
            MetricList.add(metricUnits2);
            insert MetricList;
            
            
            
            xcDSManagerUser.ManagerId = xcDSManager2User.id;
            update xcDSManagerUser;
                 
            //xcDSRUser.ManagerId = xcDSManagerUser.id; 
            //update xcDSRUser;
          
           
            oppList[0].AccountId = accObj.id;
            oppList[0].AssignedAE_ID__c = xcDSRUser.Id;
            oppList[0].Type = 'New Build';
            oppList[0].Property__c = PropObj.id;
            oppList[0].ContractTerm__c = 12;
            oppList[0].ContractTermUnit__c = 'months';
            oppList[0].Contract_Type__c = 'Bulk';
            oppList[0].Fiber_To_The_Unit__c='Fiber to the Unit';
            oppList[0].StageName = 'Closed Won';
            oppList[0].ProjectedOccupancyDate__c = date.today();
            oppList[0].X3rd_Party_Consultant__c = 'Advanced Multi Media';
            oppList[0].recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Xfinity Opportunity Record Type').getRecordTypeId();   
             oppList[0].Common_Area_Wide_WiFi_Ready__c = 'Yes';
            oppList[0].WiFi_Ready__c = 'Yes';
            oppList[0].Property_Wide_WiFi_Ready__c = 'Yes';
            
            oppList[1].AccountId = accObj.id;
            oppList[1].AssignedAE_ID__c = xcContractorUser.Id;
            oppList[1].Type = 'New Build';
            oppList[1].Property__c = PropObj.id;
            oppList[1].ContractTerm__c = 12;
            oppList[1].ContractTermUnit__c = 'months';
            oppList[1].Contract_Type__c = 'Bulk';
            oppList[1].Fiber_To_The_Unit__c='Fiber to the Unit';
            oppList[1].StageName = 'Closed Won';
            oppList[1].ProjectedOccupancyDate__c = date.today();
            oppList[1].X3rd_Party_Consultant__c = 'Advanced Multi Media';
            oppList[1].recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Xfinity Opportunity Record Type').getRecordTypeId();   
            oppList[1].Common_Area_Wide_WiFi_Ready__c = 'Yes';
            oppList[1].WiFi_Ready__c = 'Yes';
            oppList[1].Property_Wide_WiFi_Ready__c = 'Yes';
            
            Database.Insert(oppList,true);
            Opportunity_Property__c oppPropObj = TestDataUtility.createOppProperty(oppList[0].id,propObj.id);
            oppList[1].StageName = 'Contract Document Review';
            Database.update(oppList,true) ;
            //insert oppPropObj;
            //oppPropObj.Primary_Property__c = true;
            //Database.Insert(oppPropObj,true);
        } 
       
        Test.startTest();
        System.runAs(currentUser){          
            oppList[0].StageName = 'Closed Won'; 
            database.Update(oppList,true);
        }   
        Test.stopTest();
        
    }
    
    /* This Method test field on opportunity "Incremental subs added is editable only when Primary property industry type is Education and IPTV is Checked else error msg shoold be displayed"*/
    Private Static testmethod void testupdateIncrementalFieldValidation() {
        Test.startTest();
        TestDataUtility.createCustomSettingRecords(); 
        User xcIntegrationUser = TestDataUtility.createXCIntegrationUser();                      
        System.runAs(xcIntegrationUser) { 
        List<Opportunity> oppList = new List<Opportunity>();

            Opportunity opp = new Opportunity();

            opp.Name ='Test Opportunity';
            opp.StageName = 'Assigned';
            opp.CloseDate =Date.today()+10;
            opp.IPTV__c = true;
            opp.Incremental_Subs_Added__c=1234;
            opp.Common_Area_Wide_WiFi_Ready__c='Yes';
            opp.Property_Wide_WiFi_Ready__c='Yes';
            opp.WiFi_Ready__c='Yes';
            oppList.add(opp);
            
            insert oppList;
               
        List<Opportunity> updateOppList = new List<Opportunity>();
        for(Opportunity updateopp : oppList){
            updateopp.Incremental_Subs_Added__c=5678;
            updateopp.Common_Area_Wide_WiFi_Ready__c='Yes';
            updateopp.Property_Wide_WiFi_Ready__c='Yes';
            updateopp.WiFi_Ready__c='Yes';
            updateOppList.add(updateopp);  
        }
        update updateOppList;
        
        List<Opportunity> updateOppList1 = new List<Opportunity>();
        for(Opportunity oppo : updateOppList){
            oppo.IPTV__c = false;
            oppo.Common_Area_Wide_WiFi_Ready__c='Yes';
            oppo.Property_Wide_WiFi_Ready__c='Yes';
            oppo.WiFi_Ready__c='Yes';
            updateOppList1.add(oppo);
        }
        update updateOppList1;
        test.stoptest();
        }       
    }
    
    
    Private Static testmethod void oppContractorSharingMgrGrpTest(){
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();

        TriggerSettings__c opportunityTrigger = new TriggerSettings__c();
            opportunityTrigger.Name = 'OpportunityTrigger';
            opportunityTrigger.isActive__c = True;
            triggerSettingsList.add(opportunityTrigger);

            TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = True;
            triggerSettingsList.add(userTrigger);
            
         TriggerSettings__c ContractorRegionMappingTrigger = new TriggerSettings__c();
            ContractorRegionMappingTrigger.Name = 'ContractorRegionMappingTrigger';
            ContractorRegionMappingTrigger.isActive__c = True;
            triggerSettingsList.add(ContractorRegionMappingTrigger);    
            
         TriggerSettings__c xfinityOptyTrigger = new TriggerSettings__c();
            xfinityOptyTrigger.Name = 'XfinityOpportunityTrigger';
            xfinityOptyTrigger.isActive__c = True;
            triggerSettingsList.add(xfinityOptyTrigger);
            
         TriggerSettings__c mduPropertyTrigger = new TriggerSettings__c();
            mduPropertyTrigger.Name = 'PropertyTrigger';
            mduPropertyTrigger.isActive__c = True;
            triggerSettingsList.add(mduPropertyTrigger);    
            
        insert triggerSettingsList; 
        User currentUser = [Select Id,Region__c, username from User where Id =: userInfo.getUserId()];
        currentUser.Region__c = 'Global';
        update currentUser;
    
        Profile p = [Select Id, Name From Profile where Name = 'XC Manager' limit 1];
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User XCManagerUser = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    LastName='Testing1',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
        XCManagerUser.Region__c=currentUser.Region__c;
        insert XCManagerUser;
        
        
        Profile p1 = [Select Id, Name From Profile where Name = 'XC AE Contractors' limit 1];
        //generate Random String 
        List<User> userList = new List<User>();
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 8)+1150)+'';
        User xcContractorUser = new User(Alias = 'AE_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p1.Id,
                                    Username = 'userTest1' + randomstr1 + '@SampleTest.com',
                                    Region__c = 'Freedom Market',                                    
                                    FederationIdentifier = 'FedId11'+randomstr1,
                                    IsActive = true,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr1.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today());
        xcContractorUser.Region__c=currentUser.Region__c;
        userList.add(xcContractorUser);
        String randomstr2 = Math.round(Math.random()*Math.pow(10,6)+1150)+'';
        User xcContractorUser2 = new User(Alias = 'AE_' + randomstr2.substring(0,4),
                                    Email = randomstr2 + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p1.Id,
                                    Username = 'userTest1' + randomstr2 + '@SampleTest.com',
                                    Region__c = 'Freedom Market',                                    
                                    FederationIdentifier = 'FedId11'+randomstr2,
                                    IsActive = true,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr2.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today());
        xcContractorUser2.Region__c=currentUser.Region__c;
        userList.add(xcContractorUser2);
        insert userList;
        List<Contractor_Region_Mapping__c> contRegList = new List<Contractor_Region_Mapping__c>();
        Contractor_Region_Mapping__c contReg = new Contractor_Region_Mapping__c();
        contReg.AE_Contractor__c = xcContractorUser.Id;
        contReg.Reporting_Manager__c  = XCManagerUser.Id;
        contReg.Region__c = currentUser.Region__c;
        contRegList.add(contReg);
        Contractor_Region_Mapping__c contReg2 = new Contractor_Region_Mapping__c();
        contReg2.AE_Contractor__c = xcContractorUser2.Id;
        contReg2.Reporting_Manager__c  = XCManagerUser.Id;
        contReg2.Region__c = currentUser.Region__c;
        contRegList.add(contReg2);
        insert contRegList;
         Account accObj = TestDataUtility.createAccount();
        Insert accObj;
        MDU_property__c propObj = TestDataUtility.createProperty();
        propObj.Common_Area_Wide_WiFi_Ready__c='Yes';
            propObj.Property_Wide_WiFi_Ready__c='Yes';
            propObj.WiFi_Ready__c='Yes';
         List<Opportunity> oppList = TestDataUtility.createOpportunity(1);
         
         oppList[0].AccountId = accObj.id;
            oppList[0].AssignedAE_ID__c = xcContractorUser.Id;
            oppList[0].Type = 'New Build';
            oppList[0].Property__c = PropObj.id;
            oppList[0].ContractTerm__c = 12;
            oppList[0].ContractTermUnit__c = 'months';
            oppList[0].Contract_Type__c = 'Bulk';
            oppList[0].Fiber_To_The_Unit__c='Fiber to the Unit';
            oppList[0].StageName = 'Closed Won';
            oppList[0].ProjectedOccupancyDate__c = date.today();
            oppList[0].X3rd_Party_Consultant__c = 'Advanced Multi Media';
            oppList[0].Common_Area_Wide_WiFi_Ready__c = 'Yes';
            oppList[0].WiFi_Ready__c = 'Yes';
            oppList[0].Property_Wide_WiFi_Ready__c = 'Yes';
            oppList[0].recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Xfinity Opportunity Record Type').getRecordTypeId();    
            Database.insert(oppList);
            OpportunityShare oppShare = new OpportunityShare();
                oppShare.OpportunityId =  oppList[0].Id;       
                oppShare.UserOrGroupId = XCManagerUser.Id;
                oppShare.OpportunityAccessLevel = 'Edit';
                oppShare.RowCause = 'manual';
                insert oppShare;
                
        oppList[0].AssignedAE_ID__c = xcContractorUser2.Id;
        update oppList;
        
        
        
    }
     Private Static testmethod void sendEmailToDetermineAssignedCARonPropertytest(){
        Test.startTest();
        TestDataUtility.createCustomSettingRecords(); 
        List<Opportunity> oppList = new List<Opportunity>();
        Account accObj = TestDataUtility.createAccount();
        Insert accObj;
        User currentUser = [Select Id,Region__c, username from User where Id =: userInfo.getUserId()];
        currentUser.Region__c = 'Global';
        update currentUser;
        
         MDU_property__c propObj = TestDataUtility.createProperty();
         propObj.Property_Region__c = 'Freedom Market';
          propObj.Common_Area_Wide_WiFi_Ready__c='Yes';
            propObj.Property_Wide_WiFi_Ready__c='Yes';
            propObj.WiFi_Ready__c='Yes';
         insert propObj;
         
        Profile p1 = [Select Id, Name From Profile where Name = 'XC AE Contractors' limit 1];
        List<User> userList = new List<User>();
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 8)+1150)+'';
        User xcContractorUser = new User(Alias = 'AE_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p1.Id,
                                    Username = 'userTest1' + randomstr1 + '@SampleTest.com',
                                    Region__c = 'Freedom Market',                                    
                                    FederationIdentifier = 'FedId11'+randomstr1,
                                    IsActive = true,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr1.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today());
        xcContractorUser.Region__c=currentUser.Region__c;
        userList.add(xcContractorUser);
        
         Profile p2 = [Select Id, Name From Profile where Name = 'XC Manager' limit 1];
         String randomstr2 = Math.round(Math.random()*Math.pow(10, 8)+1150)+'';
        User xcMgr = new User(Alias = 'AE_' + randomstr2.substring(0,4),
                                    Email = randomstr2 + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p2.Id,
                                    Username = 'userTest1' + randomstr2 + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    Sales_Rep_Type__c = 'Region',                                    
                                    FederationIdentifier = 'FedId11'+randomstr2,
                                    IsActive = true,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr2.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today());
        //xcMgr.Region__c=propObj.Property_Region__c;
        userList.add(xcMgr);
        insert userList;
        
        
            Opportunity opp = new Opportunity();
            opp.Name ='Test Opportunity';
            opp.StageName = 'Assigned';
            opp.CloseDate =Date.today()+10;
            opp.IPTV__c = true;
            opp.Incremental_Subs_Added__c=1234;
            opp.AccountId = accObj.id;
            opp.AssignedAE_ID__c = xcContractorUser.Id;
            opp.Type = 'New Build';
            opp.Property__c = PropObj.id;
            opp.ContractTerm__c = 12;
            opp.ContractTermUnit__c = 'months';
            opp.Contract_Type__c = 'Bulk';
            opp.Fiber_To_The_Unit__c='Fiber to the Unit';
            opp.StageName = 'Closed Won';
            opp.ProjectedOccupancyDate__c = date.today();
            opp.X3rd_Party_Consultant__c = 'Advanced Multi Media';
            opp.Common_Area_Wide_WiFi_Ready__c = 'Yes';
            opp.WiFi_Ready__c = 'Yes';
            opp.Property_Wide_WiFi_Ready__c = 'Yes';
            opp.recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Xfinity Opportunity Record Type').getRecordTypeId(); 
            oppList.add(opp);
            insert oppList;
            
            Opportunity_Property__c oppPropObj = TestDataUtility.createOppProperty(oppList[0].id,propObj.id);
            
            opp.StageName = 'Contract Document Review';
            update oppList;
            
     }
      Private Static testmethod void sendEmailToDetermineAssignedCARonPropertytest1(){
        Test.startTest();
        TestDataUtility.createCustomSettingRecords(); 
        List<Opportunity> oppList = new List<Opportunity>();
        Account accObj = TestDataUtility.createAccount();
        Insert accObj;
        User currentUser = [Select Id,Region__c,email, username from User where Id =: userInfo.getUserId()];
        currentUser.Region__c = 'Global';
        currentUser.email = 'abc@xyz.com';
        currentUser.Terms_and_Conditions_Accepted__c = system.today();
        update currentUser;
        
        
        User CARUser = TestDataUtility.createXfinityCARUser();
        CARUser.managerId = currentUser.id;
        update CARUser;
         MDU_property__c propObj = TestDataUtility.createProperty();
         propobj.Assigned_CAR__c = CARUser.id;
         propobj.Industry_Type__c = 'Commercial';
         propobj.Property_Type__c = 'Commercial';
         propobj.Contracting_Org_Type__c = 'Developer';
           propObj.Common_Area_Wide_WiFi_Ready__c='Yes';
            propObj.Property_Wide_WiFi_Ready__c='Yes';
            propObj.WiFi_Ready__c='Yes';
         
        
         insert propObj;
         
        Profile p1 = [Select Id, Name From Profile where Name = 'XC AE Contractors' limit 1];
        List<User> userList = new List<User>();
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 8)+1150)+'';
        User xcContractorUser = new User(Alias = 'AE_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p1.Id,
                                    Username = 'userTest1' + randomstr1 + '@SampleTest.com',
                                    Region__c = 'Freedom Market',                                    
                                    FederationIdentifier = 'FedId11'+randomstr1,
                                    IsActive = true,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr1.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today());
        xcContractorUser.Region__c=currentUser.Region__c;
        userList.add(xcContractorUser);
        
       
        insert userList;
        
        
            Opportunity opp = new Opportunity();
            opp.Name ='Test Opportunity';
            opp.StageName = 'Assigned';
            opp.CloseDate =Date.today()+10;
            opp.IPTV__c = true;
            opp.Incremental_Subs_Added__c=1234;
            opp.AccountId = accObj.id;
            opp.AssignedAE_ID__c = xcContractorUser.Id;
            opp.Type = 'New Build';
            opp.Property__c = PropObj.id;
            opp.ContractTerm__c = 12;
            opp.ContractTermUnit__c = 'months';
            opp.Contract_Type__c = 'Bulk';
            opp.Fiber_To_The_Unit__c='Fiber to the Unit';
            opp.StageName = 'Closed Won';
            opp.IPTV__c = false;
            opp.ProjectedOccupancyDate__c = date.today();
            opp.X3rd_Party_Consultant__c = 'Advanced Multi Media';
            opp.Common_Area_Wide_WiFi_Ready__c = 'Yes';
            opp.WiFi_Ready__c = 'Yes';
            opp.Property_Wide_WiFi_Ready__c = 'Yes';
            opp.recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Xfinity Opportunity Record Type').getRecordTypeId(); 
            oppList.add(opp);
            insert oppList;
            
            Opportunity_Property__c oppPropObj = TestDataUtility.createOppProperty(oppList[0].id,propObj.id);
            
            opp.StageName = 'Contract Document Review';
            update oppList;
            
     }
}