@isTest
public class UserInactivePlanUpdateBatchTest {
    //public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    public static String CRON_EXP1 = '0 0 0 3 9 ? 2022';
    
    public static testMethod void UserInactivePlanUpdateBatchTestMethod(){
    
        WorkTestDataUtility.createCustomSettingRecords();
        User currentUser = [select id from user where  id=:userinfo.getuserid()];
        User sdmUser = WorkTestDataUtility.createDSSupervisorUser();
        User xspUser = WorkTestDataUtility.createDSRepUser();
      
       
    //Create Plan
        List<Plan__c> planList = new List<Plan__c>();
        Plan__c testPlanturf = new Plan__c();
        testPlanturf.Name = 'TestPlan1';
        testPlanturf.Plan_Level__c = 'Turf';
        testPlanturf.Plan_Status__c = Label.PlanStatusDraft;
        date ExpireDate = date.today().addDays(2);
        testPlanturf.Expiration_Date__c = ExpireDate;
        testPlanturf.User__c = xspUser.Id;        
        planList.add(testPlanturf);
        database.insert(planList);
        
    //Create a list of Addresses and adding them to the plan 
    
            Customer_Address__c addr = new Customer_Address__c();
            addr.Address__c = 'Test Address';
            addr.State__c = 'Test State';
            addr.City__c = 'Test City';
            addr.Country__c = 'Test Country';
            addr.PostalCode__c = '12345';
            addr.Node__c = '12345';
            addr.Route_Code__c = '1111111111';
            addr.Corp__c = '111111';
            addr.Non_Marketable__c = TRUE;
            addr.Do_Not_Knock__C = TRUE;
            addr.ManagementArea__c = '12345';
            addr.Plan__c = testPlanturf.Id;
            addr.ownerid=xspUser.Id;
            insert addr;  
          
             //Making the user inactive
             xspUser.IsActive = false;
            //update xspUser;                 
            
            //testPlanturf.User__c = sdmUser.Id; 
           // update testPlanturf;            
           
                         
            Test.StartTest();                    
            UserInactivePlanUpdateBatch UserInactivePlanBatchObj = new UserInactivePlanUpdateBatch(); 
            if(UserInactivePlanBatchObj != null){
                id id1= database.executebatch(UserInactivePlanBatchObj);
                UserInactivePlanBatch scheduler = new UserInactivePlanBatch();
                String scheduledJobId1 = System.schedule('testScheduledApex1', CRON_EXP1, scheduler );    
            }        
            Test.StopTest();     
   }
}