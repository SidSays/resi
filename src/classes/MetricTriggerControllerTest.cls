@isTest
public class MetricTriggerControllerTest {     
    public static testMethod void testMetricTriggerController(){
        WorkTestDataUtility.createCustomSettingRecords();
        User aeMgrUser = WorkTestDataUtility.createXCManagerUser();
        User aeUser = WorkTestDataUtility.createAEUser();
        
        User aeContUser = WorkTestDataUtility.createAEUser();
        Profile contProfile = [ select Id, Name FROM Profile WHERE Name = 'XC AE Contractors' limit 1];
        
        Goal goalObj = new Goal(); 
        Goal contractorGoal = new Goal();
        Goal goalObj1 = new Goal();
        Metric metr = new Metric();
        Metric metr5 = new Metric();        
        List<Goal> goalList = new List<Goal>();
        List<User> userList = new List<User>();
        List<TriggerSettings__c> TriggerSettingsList = new List<TriggerSettings__c>();
        System.runAs(new User(Id=UserInfo.getUserId())){
            TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = false;
            TriggerSettingsList.add(userTrigger);
                        
            TriggerSettings__c contractTrigger = new TriggerSettings__c() ;
            contractTrigger.Name = 'ContractorRegionMappingTrigger';
            contractTrigger.isActive__c = true;
            TriggerSettingsList.add(contractTrigger);
            insert TriggerSettingsList;
            
            aeUser.managerId=aeMgrUser.Id;
            userList.add(aeUser);
            
            aeContUser.profileId=contProfile.Id;
            userList.add(aeContUser);
            insert userList;
            
            Contractor_Region_Mapping__c contRegMap =  new Contractor_Region_Mapping__c();
            contRegMap.Region__c = aeMgrUser.Region__c;
            contRegMap.Reporting_Manager__c = aeMgrUser.Id;
            contRegMap.AE_Contractor__c = aeContUser.ID ;
            insert contRegMap;
            
            goalObj.Name = 'Test AE Goal';
            goalObj.Status = 'Draft';
            goalObj.Profile_Name__c = 'XC Account Executive';
            goalObj.Sales_Rep_Type__c = 'NAM';
            goalObj.Template_Type__c = system.label.Goal_Template_Type_Communities;
            goalObj.OwnerId = aeUser.id;
            goalObj.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
            goalObj.StartDate = System.Today().addDays(-2);
            goalObj.DueDate = System.Today().addDays(+2); 
            goalObj.Region__c = 'Beltway Market'; 
            goalList.add(goalObj);
            
            contractorGoal.Name = 'Test Contractor Goal';
            contractorGoal.Status = 'Draft';
            contractorGoal.Profile_Name__c = 'XC AE Contractors';           
            contractorGoal.Template_Type__c = system.label.Goal_Template_Type_Communities;
            contractorGoal.OwnerId = aeContUser.id;
            contractorGoal.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
            contractorGoal.StartDate = System.Today().addDays(-2);
            contractorGoal.DueDate = System.Today().addDays(+2); 
            contractorGoal.Region__c = 'Beltway Market'; 
            goalList.add(contractorGoal);
                       
            goalObj1.Name = 'Test AE Goal2';
            goalObj1.Status = 'Draft';
            goalObj1.Profile_Name__c = 'XC Account Executive';
            goalObj1.Sales_Rep_Type__c = 'NAM';
            goalObj1.Template_Type__c = system.label.GoalDirectSalesRecordType;
            goalObj1.OwnerId = aeUser.id;
            goalObj1.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Direct Sales').getRecordTypeId();
            goalObj1.StartDate = System.Today().addDays(-2);
            goalObj1.DueDate = System.Today().addDays(+2); 
            goalObj1.Region__c = 'Beltway Market'; 
            goalList.add(goalObj1);
            insert goalList;
            
            List<Metric> metricsList= new List<Metric>();            
            metr.Name = 'Video';
            metr.GoalId = goalObj.Id;  
            metr.OwnerId = goalObj.OwnerId;
            metr.TargetValue = 100;
            metr.DueDate = System.Today().addDays(+2); 
            metr.LastComment ='new';
            metr.CurrentValue = 10;
            metr.Status = 'Behind';
            metricsList.add(metr);
            
            Metric metr1 = new Metric();
            metr1.Name = 'Voice';
            metr1.GoalId = goalObj1.Id;  
            metr1.OwnerId = goalObj1.OwnerId;
            metr1.TargetValue = 100;
            metr1.DueDate = System.Today().addDays(+2); 
            metr1.LastComment ='new';
            metr1.CurrentValue = 75;
            //metr1.Status = 'On Track';
            metricsList.add(metr1);
            
            Metric metr2 = new Metric();
            metr2.Name = 'Voice';
            metr2.GoalId = goalObj1.Id;  
            metr2.OwnerId = goalObj1.OwnerId;
            metr2.TargetValue = 100;
            metr2.DueDate = System.Today().addDays(+2); 
            metr2.LastComment ='new';
            metr2.CurrentValue = 10;
            //metr1.Status = 'On Track';
            metricsList.add(metr2);
            
            Metric metr3 = new Metric();
            metr3.Name = 'Voice';
            metr3.GoalId = goalObj1.Id;  
            metr3.OwnerId = goalObj1.OwnerId;
            metr3.TargetValue = 100;
            metr3.DueDate = System.Today().addDays(+2); 
            metr3.LastComment ='new';
            metr3.CurrentValue = 80;
            //metr1.Status = 'On Track';
            metricsList.add(metr3);
            
            Metric metr4 = new Metric();
            metr4.Name = 'Voice';
            metr4.GoalId = goalObj1.Id;  
            metr4.OwnerId = goalObj1.OwnerId;
            metr4.TargetValue = 100;
            metr4.DueDate = System.Today().addDays(+2); 
            metr4.LastComment ='new';
            metr4.CurrentValue = 45;
            //metr1.Status = 'On Track';
            metricsList.add(metr4);
            
            
            metr5.Name = 'Voice';
            metr5.GoalId = contractorGoal.Id;  
            metr5.OwnerId = contractorGoal.OwnerId;
            metr5.TargetValue = 100;
            metr5.DueDate = System.Today().addDays(+2); 
            metr5.LastComment ='new';
            metr5.CurrentValue = 0;
            //metr1.Status = 'On Track';
            metricsList.add(metr5);
            
            insert(metricsList);         
        }
        
        Test.startTest();
            System.runAs(aeUser){            
                metr.DueDate = System.Today().addDays(+3);
                try{
                    update metr;
                }catch(Exception e){                

                }
            }
            
            System.runAs(aeMgrUser){            
                metr.TargetValue = 100;
                try{
                    update metr;
                }catch(Exception e){                

                }
            }
            
            System.runAs(aeContUser){            
                metr5.TargetValue = 100;
                try{
                    update metr;
                }catch(Exception e){                

                }
            }
        Test.stopTest();    
    }
}