@isTest
public class ContractorRegionMappingTest {
    
    @testSetup static void setup() {
             TriggerSettings__c userTrigger = new TriggerSettings__c() ;
             userTrigger.Name = 'UserTrigger';
             userTrigger.isActive__c = false;
             insert userTrigger;
        // Creating common test Users
          Profile profile1 = [Select Id, Name From Profile where Name = 'XC Manager' limit 1];
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User DSRepUser1 = new User(Alias = 'DSR_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = profile1.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom',
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4), 
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level',                
                                   Terms_and_Conditions_Accepted__c = system.today());
                   insert DSRepUser1 ;
          String randomstr3 = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';         
        User DSRepUser4 = new User(Alias = 'DSR_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing2',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = profile1.Id,
                                    Username = 'userTest12' + randomstr3 + '@SampleTest.com',
                                    Region__c = 'Beltway Market',
                                    FederationIdentifier = 'FedId21'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr3.substring(0,4), 
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level',                
                                   Terms_and_Conditions_Accepted__c = system.today());
                   insert DSRepUser4 ;
        Profile profile2 = [Select Id, Name From Profile where Name = 'XC AE Contractors' limit 1];
        //generate Random String 
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User DSRepUser = new User(Alias = 'DSR_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest1@SampleTest.com',
                                    FirstName='Testing3',
                                    LastName='Testing3',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = profile2.Id,
                                    Username = 'userTest13' + randomstr1 + '@SampleTest.com',
                                    Region__c = 'Freedom',
                                    FederationIdentifier = 'FedId1'+randomstr1,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr1.substring(0,4), 
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level',                
                                   Terms_and_Conditions_Accepted__c = system.today());
                    insert DSRepUser ;     
    }
        
        static testMethod void ContractSharingMgtoManagerrGrp()
        {
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
        
         String goalDirectSalesRecordType1 = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.GoalDirectSalesRecordType).getRecordTypeId();
        String goalCommunitiesRecordType1 = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.CommunitiesGoalRecordType).getRecordTypeId();
         
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
         System.runAs(user){
            User DSRepUser3 = [select id,name from user where FirstName='Testing3' limit 1] ;
            User DSRepUser1 = [select id,name from user where FirstName='Testing1' limit 1] ;
            User DSRepUser2 = [select id,name from user where FirstName='Testing2' limit 1] ;
         Contractor_Region_Mapping__c contRegMap =  new Contractor_Region_Mapping__c();
                    contRegMap.Region__c =  'Freedom';
                    contRegMap.Reporting_Manager__c = DSRepUser1.Id;
                    contRegMap.AE_Contractor__c = DSRepUser3.ID ;
                    insert contRegMap;
              Goal g = new Goal();
                 g.Name = 'Test Goal';
                 g.Status = 'Published';
                 g.Region__c ='Freedom';
                 g.StartDate = System.Today().addDays(-2);
                 g.DueDate = System.Today().addDays(+2);
                 g.recordTypeId = goalDirectSalesRecordType1;
                 g.ownerid = DSRepUser3.id;
             insert g;
             Goal g1 = new Goal();
                 g1.Name = 'Test Goal';
                 g1.Status = 'Published';
                 g1.Region__c ='Beltway Market';
                 g1.StartDate = System.Today().addDays(-2);
                 g1.DueDate = System.Today().addDays(+2);
                 g1.recordTypeId = goalDirectSalesRecordType1;
                 g1.ownerid = DSRepUser3.id;
             insert g1;
             
            List<User> listUser = new List<User>();
                 contRegMap.Reporting_Manager__c = DSRepUser2.id;
              contRegMap.Region__c = 'Beltway Market';
                update contRegMap; 
               delete contRegMap;
             // g.Region__c ='Beltway Market';
              // update g;
             // delete contRegMap;
       } 
   }
}