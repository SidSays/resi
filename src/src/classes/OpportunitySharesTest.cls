/**
Test Class for OpportunityShares
@Last Modify By : Suchita Sharma 
@Last Modify Date: 01-Aug-2017
*/
@isTest
public class OpportunitySharesTest {
    /**
    Test method for addRegionShareTest
    */
    static testMethod void addRegionShareTest() {
        
        //create test data
        TestDataUtility.createCustomSettingRecords();

        TriggerSettings__c mduPropertyTrigger = new TriggerSettings__c();
        mduPropertyTrigger.Name = 'PropertyInsertUpdateTrigger';
        mduPropertyTrigger.isActive__c = True;
        database.insert(mduPropertyTrigger);
                
        TriggerSettings__c mduPropertyTrigger1 = new TriggerSettings__c();
        mduPropertyTrigger1.Name = 'PropertyTrigger';
        mduPropertyTrigger1.isActive__c = False;
        database.insert(mduPropertyTrigger1);
    
    TriggerSettings__c accountTrigger = new TriggerSettings__c();
        accountTrigger.Name = 'AccountTrigger';
        accountTrigger.isActive__c = False;
        database.insert(accountTrigger);
        
        Account acc = TestDataUtility.createAccount();
        acc.Last_Install_Date__c = system.today();
        acc.type = 'Customer';
        Database.insert(acc);   
        List<Opportunity> oppList = TestDataUtility.createOpportunity(1);         
        
        Group floridaGroup = new Group();
        floridaGroup.Name = 'Florida Region';
        floridaGroup.Type ='Regular';       
        insert floridaGroup;
        
        Group beltwayGroup = new Group();
        beltwayGroup.Name = 'Beltway Market';
        beltwayGroup.Type ='Regular';
        
        insert beltwayGroup;
        
        PublicGroupRegion__c pg = new PublicGroupRegion__c();
        pg.Name = 'Florida Region';
        pg.Public_Group_Name__c = 'Florida Region';
        pg.GroupId__c = floridaGroup.id;
        insert pg;
        
        PublicGroupRegion__c pg1 = new PublicGroupRegion__c();
        pg1.Name = 'Beltway Market';
        pg1.Public_Group_Name__c = 'Beltway Market';
        pg1.GroupId__c = beltwayGroup.id;
        insert pg1;
        
        Test.startTest();   
            /*
            * Handling closed Opportunity conditions.
            */        
            oppList[0].StageName = 'Closed Won';    
            oppList[0].ContractTermUnit__c = 'months';
            oppList[0].ContractTerm__c = 2;
            oppList[0].AccountId = acc.id;
            oppList[0].Contract_Type__c = 'Bulk';
            oppList[0].Fiber_To_The_Unit__c = 'Fiber to the Building';
            oppList[0].WiFi_Ready__c= 'Yes';
            oppList[0].Property_Wide_WiFi_Ready__c= 'Yes';
            oppList[0].Common_Area_Wide_WiFi_Ready__c = 'Yes';
            oppList[0].X3rd_Party_Consultant__c = 'Asset Essentials'; 
            oppList[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Xfinity Opportunity Record Type').getRecordTypeId();
            Database.insert(oppList[0]);     
            /*
            * testing property type & bulk status condition on property
            */
            MDU_Property__c MDUprop1 = TestDataUtility.createProperty();
            MDUprop1.Property_Region__c = 'Florida Region';
            MDUprop1.PostalCode__c = '10541';
            MDUprop1.Bulk_Status__c = 'Bulk';
            MDUprop1.Property_Type__c = 'CONDOMINIUM';
          MDUprop1.WiFi_Ready__c= 'Yes';
            MDUprop1.Property_Wide_WiFi_Ready__c= 'Yes';
            MDUprop1.Common_Area_Wide_WiFi_Ready__c = 'Yes';
            
            MDU_Property__c MDUprop2 = TestDataUtility.createProperty();
            MDUprop2.Property_Region__c = 'Beltway Market';
            MDUprop2.PostalCode__c = '10541';
            MDUprop2.Bulk_Status__c = 'Bulk';
            MDUprop2.Property_Type__c = 'CONDOMINIUM';
          MDUprop2.WiFi_Ready__c= 'Yes';
            MDUprop2.Property_Wide_WiFi_Ready__c= 'Yes';
            MDUprop2.Common_Area_Wide_WiFi_Ready__c = 'Yes';
            List<MDU_Property__c> propList = new List<MDU_Property__c>();
            propList.add(MDUprop2);
            
            Map<Id,MDU_Property__c> oldMap = new Map<Id,MDU_Property__c>();
            Map<Id,MDU_Property__c> newMap = new Map<Id,MDU_Property__c>();
            
            User u = TestDataUtility.createXCIntegrationUser();
            Opportunity_Property__c oppPropInst1 = new Opportunity_Property__c();
            Opportunity_Property__c oppPropInst2 = new Opportunity_Property__c();
            
            User user = [Select Id from User where Id=:UserInfo.getUserId()];
            System.runAs(user){ 
                Database.insert(MDUprop1);
                oldMap.put(MDUprop1.Id,MDUprop1);
                Database.insert(MDUprop2);
                oldMap.put(MDUprop2.Id,MDUprop2);
            }       
        
            System.runAs(u){                                
                system.debug('MDUprop1.Property_Region__c****'+MDUprop1.Property_Region__c);                
                //update Opportunity Property
                oppPropInst1 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop1.id); 
                database.insert(oppPropInst1);
                
                MDUprop1.Property_Region__c = 'Beltway Market';
                database.update(oppPropInst1);
                //database.delete(oppPropInst1);  
                oppPropInst2 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop2.id); 
                database.insert(oppPropInst2);
                
            }  
            OpportunityShares oppshare = new OpportunityShares();
            oppshare.RecalculatePropertyShares(oldMap,newMap);
            
        Test.stopTest();
        }
        
      /**
        Test method for createOppPropTest
        */
        public static testMethod void createOppPropTest(){
            Test.startTest();
      List<User> usrList = new List<User>();
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
                    //Managerid = aeContMag.id,
                    Terms_and_Conditions_Accepted__c = system.today());
      usrList.add(aeCont);
      Database.insert(usrList,false);

            
            Region_Profile_PublicGroups__c rpg = new Region_Profile_PublicGroups__c();
            rpg.name='Test';
            rpg.Profile_Channel__c='CAR Manager';
            rpg.Public_Group_Name__c='CAR Managers - Beltway';
            rpg.Region__c='Beltway Market';
            insert rpg;
      
      TriggerSettings__c mduPropertyTrigger = new TriggerSettings__c();
      mduPropertyTrigger.Name = 'PropertyInsertUpdateTrigger';
      mduPropertyTrigger.isActive__c = True;
      database.insert(mduPropertyTrigger);
          
            TriggerSettings__c oppPropTrigger = new TriggerSettings__c();
            oppPropTrigger.Name = 'OpportunityPropertyTrigger';
            oppPropTrigger.isActive__c = True;
            database.insert(oppPropTrigger);
            
            TriggerSettings__c userTriggerObj = new TriggerSettings__c();
            userTriggerObj.Name = 'UserTrigger';
            userTriggerObj.isActive__c = True;
            database.insert(userTriggerObj);
      
      TriggerSettings__c accountTrigger = new TriggerSettings__c();
      accountTrigger.Name = 'AccountTrigger';
      accountTrigger.isActive__c = False;
      database.insert(accountTrigger);
            
            User carUser = TestDataUtility.createXfinityCARUser();
            
            Account accObj = TestDataUtility.createAccount();
            accObj.Last_Install_Date__c = system.today();
           accObj.type = 'Customer';
            Database.insert(accObj);
            
            MDU_Property__c propObj = new MDU_Property__c();
            propObj.name='test Property';
            propObj.Property_Region__c = 'Florida Region';
            //propObj.PostalCode__c = '411041';
            propObj.City__c='test  city';
            propObj.MDU_State__c= 'California';
            propObj.Property_Division__c= 'Central';
            propObj.Address__c=' test address';
            propObj.Industry_Type__c='Healthcare';
      propObj.Contracting_Org_Type__c='Owner';
            propObj.Number_of_Units__c= 14;
            propObj.Comcast_Video_Serviced__c='no';
            propObj.Comcast_Data_Serviced__c='no';
            propObj.Comcast_Voice_Serviced__c='no';
            propObj.Bulk_Status__c = 'Bulk';
            propObj.Property_Type__c = 'CONDOMINIUM';
            propObj.Assigned_CAR__c= carUser.id;
            propObj.System__c= 'A2';
            propObj.Property_Area__c='Delta';
            propObj.Common_Area_Wide_WiFi_Ready__c = 'Yes';
            propObj.WiFi_Ready__c = 'Yes';
            propObj.Property_Wide_WiFi_Ready__c = 'Yes';
            insert propObj;
            
            Opportunity oppObj = new Opportunity();
            oppObj.StageName = 'Closed Won';
            oppObj.name = 'test Opportunity';
            oppObj.StageName='Assigned';
            oppObj.CloseDate= system.today();
            oppObj.Type='Win Back';
            oppObj.AssignedAE_ID__c=carUser.id;
            oppObj.AccountId = accObj.id;
            oppObj.ContractTermUnit__c = 'months';
            oppObj.ContractTerm__c = 2;
            oppObj.Contract_Type__c = 'Bulk';
            oppObj.Fiber_To_The_Unit__c = 'Fiber to the Building';
            oppObj.Common_Area_Wide_WiFi_Ready__c = 'Yes';
            oppObj.WiFi_Ready__c = 'Yes';
            oppObj.Property_Wide_WiFi_Ready__c = 'Yes';
            oppObj.Property__c = propObj.Id;
            oppObj.X3rd_Party_Consultant__c = 'Asset Essentials'; 
            oppObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Xfinity Opportunity Record Type').getRecordTypeId();            
            Database.insert(oppObj);
            
            oppObj.AssignedAE_ID__c=aeCont.id;
            database.update(oppObj); 
            
            Opportunity_Property__c oppPropObj = new Opportunity_Property__c();
            oppPropObj.Property__c = propObj.Id;
            oppPropObj.Opportunity__c = oppObj.Id;
            Database.insert(oppPropObj);
            
           propObj.Property_Region__c = 'Beltway Market';
            Database.update(PropObj); 
            Test.stopTest();

        }   
}