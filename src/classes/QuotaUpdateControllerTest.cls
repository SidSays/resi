@isTest
public class QuotaUpdateControllerTest {
     
   public static testMethod void test1(){
   
     WorkTestDataUtility.createCustomSettingRecords();
     //user usr = [select id , name from user where id =:userInfo.getUserId()];
         Set<Id>UsersetId = new Set<Id> ();
         TriggerSettings__c userTrigger = new TriggerSettings__c();
         userTrigger.Name = 'UserTrigger';
         userTrigger.isActive__c = true;
         Database.insert(userTrigger,false);
         Profile p = [ select id ,name from profile where name = 'XC Manager'  limit 1];
         Profile p1 = [ select id ,name from profile where name = 'XC Portfolio AE'  limit 1];
         User user = new user();
         user.Sales_Rep_Type__c = 'Division';
         user.UserPermissionsWorkDotComUserFeature = true;
         user.ProfileId = p.Id;
         user.Email ='userTest@SampleclassTest.com';
         user.LastName='Testing';
         user.Username = 'userTest@SampleclassTest.com';
         user.FederationIdentifier = 'FedId1';
         user.TimeZoneSidKey='America/Los_Angeles';
         user.LocaleSidKey='en_US';
         user.EmailEncodingKey='UTF-8';
         user.Alias = 'DSR';
         user.Region__c = 'Global';
         user.LanguageLocaleKey='en_US';
         Database.insert(user);
         
         User user1 = new user();
         user1.Sales_Rep_Type__c = 'Region';
         user1.UserPermissionsWorkDotComUserFeature = true;
         user1.ProfileId = p1.Id;
         user1.Email ='userTest@SampleclassTest.com';
         user1.LastName='Testing';
         user1.Username = 'userTest@SampleclassTest.com.xcAEUser';
         user1.FederationIdentifier = 'FedId12';
         user1.TimeZoneSidKey='America/Los_Angeles';
         user1.LocaleSidKey='en_US';
         user1.EmailEncodingKey='UTF-8';
         user1.Alias = 'DSR22';
         user1.Region__c = 'Global';
         user1.managerid = user.id;
         user1.LanguageLocaleKey='en_US';
         Database.insert(user1);
         UsersetId.add(user.Id);
         UsersetId.add(user1.Id);
         User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
         System.runAs (thisUser) {
            Goal goal = new Goal();
            goal.name = 'test';
            goal.status ='Draft';
            goal.ownerId = user.id;
            Database.Insert(goal,false);
            List<Metric>lstMetric = new List<Metric> ();
            Set<Id>setId = new Set<Id> ();
            metric metric=  new metric();
            metric.name = 'test';
            metric.TargetValue = 100.00;
            metric.goalid = goal.id;
            setId.add(metric.OwnerId);
            lstMetric.add(metric); 
            Database.Insert(lstMetric); 
            QuotaUpdateController ctrl = new QuotaUpdateController(new ApexPages.StandardController(lstMetric[0]));
            ctrl.managerid = setId;
            ctrl.metricList = lstMetric;
            ctrl.region = 'Global';
            Map<Id,Decimal> oldMetricMap1 = new Map<Id,Decimal> ();
            oldMetricMap1.put(lstMetric[0].Id, metric.TargetValue);
            ctrl.oldMetricMap = oldMetricMap1;
            ctrl.getregionlist();
            ctrl.getaeManager();
            ctrl.getaeUser();
            ctrl.getMetricList();
            ctrl.getMetricListAe();
            ctrl.getMetricLists();
            ctrl.savemethod();
          }
           
          System.runAs (user) {
            Goal goal = new Goal();
            goal.name = 'test';
            goal.status ='Draft';
            goal.ownerId = user.id;
           
            Database.Insert(goal,false);
            List<Metric>lstMetric = new List<Metric> ();
            Set<Id>setId = new Set<Id> ();
            metric metric=  new metric();
            metric.name = 'test';
            metric.goalid = goal.id;
            metric.TargetValue = 100.00;
            setId.add(metric.OwnerId);
            lstMetric.add(metric); 
            Database.Insert(lstMetric); 
            QuotaUpdateController ctrl = new QuotaUpdateController(new ApexPages.StandardController(lstMetric[0]));
            ctrl.managerid = setId;
            ctrl.metricList = lstMetric;
            ctrl.region = 'Global';
            ctrl.useraemanager = user.Id;
            ctrl.getregionlist(); 
            ctrl.getaeManager();
            ctrl.getaeUser();
            ctrl.getMetricList();
            ctrl.getMetricListAe();
            ctrl.getMetricLists();
            ctrl.savemethod();
          }
          }
   
    public static testMethod void test2(){
        WorkTestDataUtility.createCustomSettingRecords();
     //user usr = [select id , name from user where id =:userInfo.getUserId()];
         Set<Id>UsersetId = new Set<Id> ();
         TriggerSettings__c userTrigger = new TriggerSettings__c();
         userTrigger.Name = 'UserTrigger';
         userTrigger.isActive__c = true;
         Database.insert(userTrigger,false);
         Profile p = [ select id ,name from profile where name = 'XC Manager'  limit 1];
         Profile p1 = [ select id ,name from profile where name = 'XC Portfolio AE'  limit 1];
         User user = new user();
         user.Sales_Rep_Type__c = 'Region';
         user.UserPermissionsWorkDotComUserFeature = true;
         user.ProfileId = p.Id;
         user.Email ='userTest@SampleclassTest.com';
         user.LastName='AE';
         user.Username = 'userTest@SampleclassTest.com';
         user.FederationIdentifier = 'FedId1';
         user.TimeZoneSidKey='America/Los_Angeles';
         user.LocaleSidKey='en_US';
         user.EmailEncodingKey='UTF-8';
         user.Alias = 'DSR';
         user.Region__c = 'Global';
         user.LanguageLocaleKey='en_US';
         Database.insert(user);
         User user1 = new user();
         user1.Sales_Rep_Type__c = 'Division';
         user1.UserPermissionsWorkDotComUserFeature = true;
         user1.ProfileId = p1.Id;
         user1.Email ='userTest@SampleclassTest.com';
         user1.LastName='Testing';
         user1.Username = 'userTest@SampleclassTest.com.xcAEUser';
         user1.FederationIdentifier = 'FedId12';
         user1.TimeZoneSidKey='America/Los_Angeles';
         user1.LocaleSidKey='en_US';
         user1.EmailEncodingKey='UTF-8';
         user1.Alias = 'DSR22';
         user1.Region__c = 'Global';
         user1.LanguageLocaleKey='en_US';
         Database.insert(user1);
         UsersetId.add(user.Id);
         UsersetId.add(user1.Id);
         Group g1;
    List<Group> supGroups=[Select Id From Group Where Name= 'Super User Group'];
    if(!supGroups.isEmpty()){
      g1=supGroups.get(0);
      }else{
        g1 = new Group(Name= 'Super User Group', type='Regular');            
        insert g1;
      }

    GroupMember gm= new GroupMember(GroupId=g1.Id, UserOrGroupId=UserInfo.getUserId()); 
    
          System.runAs(new User(Id = Userinfo.getUserId())) {
              insert gm;
          }
     
         User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
         System.runAs (thisUser) {
            Goal goal = new Goal();
            goal.name = 'test';
            goal.status ='Draft';
            goal.ownerId = user.id;
            Database.Insert(goal,false);
            List<Metric>lstMetric = new List<Metric> ();
            Set<Id>setId = new Set<Id> ();
            metric metric=  new metric();
            metric.name = 'test';
            metric.TargetValue = 100.00;
            metric.goalid = goal.id;
            setId.add(metric.OwnerId);
            lstMetric.add(metric); 
            Database.Insert(lstMetric); 
            
            
            QuotaUpdateController ctrl = new QuotaUpdateController(new ApexPages.StandardController(lstMetric[0]));
            ctrl.managerid = setId;
            ctrl.metricList = lstMetric;
            ctrl.region = 'Beltway Market';
            Map<Id,Decimal> oldMetricMap1 = new Map<Id,Decimal> ();
            oldMetricMap1.put(lstMetric[0].Id, metric.TargetValue);
            ctrl.oldMetricMap = oldMetricMap1;
            ctrl.getregionlist();
            ctrl.getaeManager();
            ctrl.getaeUser();
            ctrl.getMetricList();
            ctrl.getMetricListAe();
            ctrl.getMetricLists();
            ctrl.savemethod();
          }
          System.runAs (user) {
            Goal goal = new Goal();
            goal.name = 'test';
            goal.status ='Draft';
            goal.ownerId = user.id;
            Database.Insert(goal,false);
            List<Metric>lstMetric = new List<Metric> ();
            Set<Id>setId = new Set<Id> ();
            metric metric=  new metric();
            metric.name = 'test';
            metric.goalid = goal.id;
            metric.TargetValue = 100.00;
            setId.add(metric.OwnerId);
            lstMetric.add(metric); 
            Database.Insert(lstMetric); 
             
            
            QuotaUpdateController ctrl = new QuotaUpdateController(new ApexPages.StandardController(lstMetric[0]));
            ctrl.managerid = setId;
            ctrl.metricList = lstMetric;
            ctrl.region = 'Global';
            ctrl.useraemanager = user.Id;
            ctrl.getregionlist(); 
            ctrl.getaeManager();
            ctrl.getaeUser();
            ctrl.getMetricList();
            ctrl.getMetricListAe();
            ctrl.getMetricLists();
            ctrl.savemethod();
          }
   
}
public static testMethod void test3(){
    WorkTestDataUtility.createCustomSettingRecords();
      List<User> usrList = new List<User>();
    //Contractor_Region_Mapping__c crm = new Contractor_Region_Mapping__c();
     //user usr = [select id , name from user where id =:userInfo.getUserId()];
         Set<Id>UsersetId = new Set<Id> ();
         TriggerSettings__c userTrigger = new TriggerSettings__c();
         userTrigger.Name = 'UserTrigger';
         userTrigger.isActive__c = true;
         Database.insert(userTrigger,false);
          TriggerSettings__c ContractorRegionMappingTrigger = new TriggerSettings__c();
         ContractorRegionMappingTrigger.Name = 'ContractorRegionMappingTrigger';
         ContractorRegionMappingTrigger.isActive__c = true;
         Database.insert(ContractorRegionMappingTrigger,false);
         Profile p = [ select id ,name from profile where name = 'XC Manager'  limit 1];
         Profile p1 = [ select id ,name from profile where name = 'XC Portfolio AE'  limit 1];
         User user = new user();
         user.Sales_Rep_Type__c = 'Region';
         user.UserPermissionsWorkDotComUserFeature = true;
         user.ProfileId = p.Id;
         user.Email ='userTest@SampleclassTest.com';
         user.LastName='AE';
         user.Username = 'userTest@SampleclassTest.com';
         user.FederationIdentifier = 'FedId1';
         user.TimeZoneSidKey='America/Los_Angeles';
         user.LocaleSidKey='en_US';
         user.EmailEncodingKey='UTF-8';
         user.Alias = 'DSR';
         user.Region__c = 'Freedom Market';
         user.LanguageLocaleKey='en_US';
         Database.insert(user);
         User user1 = new user();
         user1.Sales_Rep_Type__c = 'Division';
         user1.UserPermissionsWorkDotComUserFeature = true;
         user1.ProfileId = p1.Id;
         user1.Email ='userTest@SampleclassTest.com';
         user1.LastName='Testing';
         user1.Username = 'userTest@SampleclassTest.com.xcAEUser';
         user1.FederationIdentifier = 'FedId12';
         user1.TimeZoneSidKey='America/Los_Angeles';
         user1.LocaleSidKey='en_US';
         user1.EmailEncodingKey='UTF-8';
         user1.Alias = 'DSR22';
         user1.Region__c = user.Region__c;
         user1.LanguageLocaleKey='en_US';
         user1.managerid = user.id;
         Database.insert(user1);
         UsersetId.add(user.Id);
         UsersetId.add(user1.Id);
                 Profile profile2 = [Select Id, Name From Profile where Name = 'XC AE Contractors' limit 1];
            String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
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
                    Sales_Rep_Type__c='Region',
                    IsActive =True,
                    Level__c='Level', 
                    Managerid = user.id,
                    Terms_and_Conditions_Accepted__c = system.today());
                    Database.insert(aeCont1);
        usrList.add(aeCont1);   
         Contractor_Region_Mapping__c crm = new Contractor_Region_Mapping__c();   
        crm.Reporting_Manager__c = user.id;
        crm.Region__c = 'Freedom Market';
        crm.AE_Contractor__c= aeCont1.id;
        insert crm;
        
        
         System.runAs (user1) {
            Goal goal = new Goal();
            goal.name = 'test';
            goal.status ='Draft';
            goal.ownerId = user.id;
            Database.Insert(goal,false);
            List<Metric>lstMetric = new List<Metric> ();
            Set<Id>setId = new Set<Id> ();
            metric metric=  new metric();
            metric.name = 'test';
            metric.goalid = goal.id;
            metric.TargetValue = 100.00;
            setId.add(metric.OwnerId);
            lstMetric.add(metric); 
            Database.Insert(lstMetric); 
             
            
            QuotaUpdateController ctrl = new QuotaUpdateController(new ApexPages.StandardController(lstMetric[0]));
            ctrl.managerid = setId;
            ctrl.metricList = lstMetric;
            ctrl.region = 'Freedom Market';
            ctrl.useraemanager = user.Id;
            ctrl.getregionlist(); 
            ctrl.getaeManager();
            ctrl.getaeUser();
            ctrl.getMetricList();
            ctrl.getMetricListAe();
            ctrl.getMetricLists();
            ctrl.savemethod();
          }
}

}