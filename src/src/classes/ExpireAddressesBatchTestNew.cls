@isTest
public class ExpireAddressesBatchTestNew {
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    public static testMethod void createRecordmethod()
    {
    
    WorkTestDataUtility.createCustomSettingRecords();
     
    User currentUser = [select id from user where  id=:userinfo.getuserid()];
    User sdmUser = WorkTestDataUtility.createDSSupervisorUser();
    User xspUser = WorkTestDataUtility.createDSRepUser();
    User sharedData = [Select Id, Name from User where Name='Shared Data User'];
    
    List<Customer_Address__c> custAddrList = new List<Customer_Address__c>();
    Customer_Address__c custAddr = new Customer_Address__c();
    List<Plan__c> planList = new List<Plan__c>();
    Plan__c plnObj = new Plan__c();
    
    System.runAs(sdmUser)
       {               
                Plan__c planObj1 = new Plan__c();
                planObj1.Name = 'TestPlan1';
                planObj1.Plan_Level__c = 'turf';
                planObj1.Expiration_Date__c = system.today()+14;
                planObj1.User__c =xspUser.id;
                planObj1.Plan_Status__c = 'Assigned';
                planObj1.Number_of_Addresses__c = 2;
                planObj1.Number_of_Excluded_Addresses__c =1;
                planObj1.True_count_of_Addresses__c=1 ;
                insert planObj1;
                planList.add(planObj1);
                
                
                plnObj.Name = 'TestPlaylist';
                plnObj.Plan_Level__c = 'Playlist';
                plnObj.Expiration_Date__c = system.today()+4;
                plnObj.Plan_Status__c = 'draft';
                plnObj.Number_of_Addresses__c=0;
                plnObj.True_count_of_Addresses__c=0;
                plnObj.Number_of_Excluded_Addresses__c=0;
                plnObj.Parent_Plan__c= planObj1.id;
                plnObj.User__c =xspUser.id;
                insert plnObj;
                planList.add(plnObj);
                
                database.insert(planList,false);
                
                custAddr.Address__c = 'Test Address';
                custAddr.City__c = 'Test city';
                custAddr.OwnerId= sharedData.id;
                custAddr.Off_Turf__c= false;
                custAddr.Excluded__c= false;
                custAddr.Number_of_Knocks__c= 0;
                custAddr.Most_Recent_Disposition__c=Label.DispositionTypeNoKnock; 
                custAddr.State__c = 'Test State';
                custAddr.Plan__c = planObj1.Id;  
                custAddr.Country__c = 'Test Country';
                custAddr.Region__c = 'Freedom Market';
                custAddr.PostalCode__c = '91100';
                custAddr.Node__c = '1111';
                custAddr.Route_Code__c = '111111';
                custAddr.Corp__c = '111111';
                custAddrList.add(custAddr);
                
               Customer_Address__c  custAddr1 = new Customer_Address__c();
                custAddr1.Address__c = 'Test Address1';
                custAddr1.City__c = 'Test city1';
                custAddr1.OwnerId= sharedData.id;
                custAddr1.Off_Turf__c= false;
                custAddr1.Excluded__c= false;
                custAddr1.Number_of_Knocks__c= 0;
                custAddr1.Most_Recent_Disposition__c=Label.DispositionTypeNoKnock; 
                custAddr1.State__c = 'Test State1';
                custAddr1.Plan__c = planObj1.Id;  
                custAddr1.Country__c = 'Test Country1';
                custAddr1.Region__c = 'Freedom Market1';
                custAddr1.PostalCode__c = '911001';
                custAddr1.Node__c = '11111';
                custAddr1.Route_Code__c = '1111111';
                custAddr1.Corp__c = '1111111';
                custAddrList.add(custAddr1);
               
                database.insert(custAddrList,false);
                
                /*ApexPages.StandardController controller1 = new ApexPages.StandardController(plnObj);
                PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
                extnObj1.quickSave();
                plnObj.User__c = xspUser.Id;
                extnObj1.Save();*/
    
        }
    
         System.runAs(currentUser)
           { 
                ExpireAddressesBatch expAddObj = new ExpireAddressesBatch();
                database.executebatch(expAddObj); 
            
            }
    
       }
}