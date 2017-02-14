@isTest
public class ClaimEligibleSubmissionControllerTest{
    private static testMethod void testClaimEligibleSubmissionController(){
        SetupTestData.createCustomSettingRecords();
        //SetupTestData.createUsers();
        User usr = [select Id from User where Id = :userInfo.getUserId() limit 1];
        //User user1 = new User();
        //user1.profileName = 'Affiliate Claims User';
        //insert user1;*/
        //SetupTestData.businessAdminUser.ProfileId =  [Select UserType, UserLicenseId, Name From Profile where Name like ''];
        system.runAs(usr){
        Account affiliateAccount = new Account();
        affiliateAccount.Name = 'Test Affiliate';
        affiliateAccount.Type = 'Partner';
        affiliateAccount.ClaimWaitDuration__c = 60;
        affiliateAccount.ClaimEligibilityDuration__c = 240;
        
        insert affiliateAccount;
         
        Order__c o = new Order__c();
        o.Name = '12345';
        o.Account__c = affiliateAccount.Id;
        //insert o;
        
        List<Order__c> orders = new List<Order__c>();
        orders.add(o);
        
         
            
        Order__c o1 = new Order__c();
        o1.Name = '12345';
        o1.OrderCompletedDate__c = system.today();
        o1.Affiliate_Account__c = affiliateAccount.Id;
        
        insert o1;
        
        insert orders;
        
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(orders);
        ClaimEligibleSubmissionController controller = new ClaimEligibleSubmissionController(stdController );
        
        controller.displayObject.Filter_Start__c = Date.Today();
        controller.displayObject.Filter_End__c = Date.Today() + 1;
        controller.displayObject.ViewOptions__c = 'All Eligible Orders';
        PageReference ref = controller.displayOrders();
        List<Order__c> ordersBeingDisplayed = controller.getEligibleOrders();
        
        // 
        
            controller = new ClaimEligibleSubmissionController(stdController );
            
            controller.displayObject.Filter_Start__c = Date.Today();
            controller.displayObject.Filter_End__c = Date.Today() + 1;
            controller.displayObject.ViewOptions__c = 'All Orders';
            ref = controller.displayOrders();
            ordersBeingDisplayed = controller.getEligibleOrders();
            controller.getAllOrders();
            controller.redirect();
            controller.displayObject.Filter_Start__c = null;
            controller.displayOrders();
            controller.displayObject.Filter_End__c = null;
            controller.displayObject.Filter_Start__c = Date.Today();
            controller.displayOrders();
            controller.displayObject.Filter_Start__c = Date.Today();
            controller.displayObject.Filter_End__c = Date.Today() - 1;
            //controller.displayObject.Filter_Start__c = null;
            controller.displayOrders();
            
            Test.StartTest();
           
            
            ClaimEligibilityBatch sh1 = new ClaimEligibilityBatch ();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test Check', sch, sh1); 
            Test.stopTest(); 
            
        }
    }
    
    private static testMethod void testClaimEligibleBatch(){
        SetupTestData.createCustomSettingRecords();
        //SetupTestData.createUsers();
        User usr = [select Id from User where Id = :userInfo.getUserId()];
        
        system.runAs(usr){
        Order__c o = new Order__c();
        o.Name = 'Test Order 1';
        o.Account__c = null;
        o.OrderCompletedDate__c = System.Today().addDays(-120);
       
        List<Order__c> orders = new List<Order__c>();
        orders.add(o);
        insert orders;

            Test.StartTest();
            ClaimEligibilityBatch ceb = new ClaimEligibilityBatch ();
            String sch = '0 0 23 * * ?';
            delete orders;
            system.schedule('Test for Batch', sch, ceb); 
            Test.stopTest(); 
            
        }
    }
}