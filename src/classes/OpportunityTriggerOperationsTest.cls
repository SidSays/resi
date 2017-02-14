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
            system.assertEquals(OpportunityDate[0].Date_in_Stage__c,system.today());
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
            propList.add(propertyObj1);
            MDU_Property__c propertyObj2  =  TestDataUtility.createProperty();
            propList.add(propertyObj2);
            Database.insert(propList);
            Test.stopTest();
            List<Opportunity> oppList = TestDataUtility.createOpportunity(2);
            oppList[0].Property__c = propList[0].id; 
            oppList[1].Property__c = propList[1].id; 
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
            Database.Insert(PropObj2);  
            Test.stopTest();
            List<Opportunity> oppList = TestDataUtility.createOpportunity(1);
            oppList[0].Property__c = PropObj2.id; 
            Database.insert(oppList);
            
            List<Opportunity> oppUpdated = [Select id, StageName from opportunity where id in: oppList];
            oppUpdated[0].AccountId = accObj.Id;
            oppUpdated[0].StageName= 'Closed Won';
            oppUpdated[0].ContractTerm__c = 10;
            oppUpdated[0].ContractTermUnit__c = 'months';
            oppUpdated[0].Contract_Type__c = 'Retail';
            oppUpdated[0].Fiber_To_The_Unit__c = 'None';
            Database.update(oppUpdated);
            
            MDU_Property__c PropTemp2 = [Select Id, Active_Opportunity__c from MDU_Property__c where Id = :PropObj2.Id];
            System.assertEquals(PropTemp2.Active_Opportunity__c,false);       
            
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
            Database.Insert(PropObj) ;
             Test.stopTest();
             
            Account accObj = TestDataUtility.createAccount();
            Insert accObj; 
        
            List<Opportunity> oppList = TestDataUtility.createOpportunity(2);
            oppList[0].Property__c = PropObj.id; 
            oppList[1].Property__c = PropObj.id; 
            oppList[1].ContractTerm__c = 10;
            oppList[1].ContractTermUnit__c = 'months';
            oppList[1].StageName = 'Closed Won';
            oppList[1].AccountId = accObj.id;
            oppList[1].Contract_Type__c = 'Retail';
            oppList[1].Fiber_To_The_Unit__c = 'None';
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
        System.runAs(xcIntegrationUser) {
       
            MDU_Property__c PropObj = TestDataUtility.createProperty();
            Database.Insert(PropObj) ;
            
             Test.stopTest();
            List<Opportunity> oppList = TestDataUtility.createOpportunity(2);
            oppList[0].Property__c = PropObj.id; 
            oppList[1].Property__c = PropObj.id; 
            oppList[1].StageName = 'Closed Lost';
            oppList[1].ReasonLost_ID__c = 'Other...';
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
        
        
        String Communities_RecordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
        //User AdminUser = WorkTestDataUtility.createSAdminUser();
        User currentUser = [Select Id,Region__c, username from User where Id =: userInfo.getUserId()];
        
        List<Opportunity> oppList = TestDataUtility.createOpportunity(1);
        MDU_property__c propObj = TestDataUtility.createProperty();
        
        System.runAs(currentUser){
            TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = false;
            insert userTrigger;
            
            xcDSRUser.Region__c=currentUser.Region__c;
            insert xcDSRUser;
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
            insert goalObj1;

            Metric metricUnits = new Metric();
            metricUnits.name = 'Units';
            metricUnits.CurrentValue = 0;
            metricUnits.TargetValue = 100;
            metricUnits.ownerId = goalObj1.OwnerId;
            metricUnits.goalId = goalObj1.id;
            MetricList.add(metricUnits);
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
            oppList[0].StageName = 'ContactMade';
            oppList[0].recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Xfinity Opportunity Record Type').getRecordTypeId();
            
            Database.Insert(oppList,true);
            Opportunity_Property__c oppPropObj = TestDataUtility.createOppProperty(oppList[0].id,propObj.id);
            //oppPropObj.Primary_Property__c = true;
            //Database.Insert(oppPropObj,true);
        } 
       
        Test.startTest();
        System.runAs(currentUser){          
            oppList[0].StageName = 'ClosedOwn';            
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
            oppList.add(opp);
            
            insert oppList;
               
        List<Opportunity> updateOppList = new List<Opportunity>();
        for(Opportunity updateopp : oppList){
            updateopp.Incremental_Subs_Added__c=5678;
            updateOppList.add(updateopp);  
        }
        update updateOppList;
        
        List<Opportunity> updateOppList1 = new List<Opportunity>();
        for(Opportunity oppo : updateOppList){
            oppo.IPTV__c = false;
            updateOppList1.add(oppo);
        }
        update updateOppList1;
        test.stoptest();
        }       
    }
    
    
    Private Static testmethod void oppContractorSharingMgrGrpTest(){
        
    }
}