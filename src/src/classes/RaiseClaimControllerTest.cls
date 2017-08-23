@isTest
public class RaiseClaimControllerTest{

    private static testMethod void testValidRaiseClaimController(){
        SetupTestData.createCustomSettingRecords();
        String id;
        String accountId;
        Case case1;
        Test.startTest();

        Profile profile = [Select Id From Profile Where Name = 'Affiliate Claims User' LIMIT 1];
        Profile bizAdminProfile = [Select Id From Profile Where Name = 'Business Administrator' LIMIT 1];
        User user = new User(Email = 'Test@Test.com',
        LastName='Testing',
        Alias = 'DA_' + 12345,
        EmailEncodingKey='UTF-8', 
        LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', 
        TimeZoneSidKey='America/Los_Angeles',
        ProfileId = profile.Id,
        Username = 'userTest' + 12345 + '@SampleclassTest.com',
        Region__c = 'Freedom Market',
        FederationIdentifier = 'FedId12222',
        EmployeeNumber = 'Emp' + 12345);
        
        User businessAdminUser = new User(Alias = 'badm',
                                    Email = 'badmuserTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = bizAdminProfile.Id,
                                    Username = 'userTestbadm@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    FederationIdentifier = 'FedId1',
                                    EmployeeNumber = 'Empbadm');

        User currentUser = [Select Id,FederationIdentifier,userroleId From User Where Id =: UserInfo.getUserId()];
        UserRole role1=[Select Id From UserRole WHERE Name='Comcast: Residential'];
        
        System.runAs(currentUser){

            Account account = new Account();
            account.Name = 'Affiliate';
            account.ClaimWaitDuration__c=1;
            account.ClaimEligibilityDuration__c=10;
            insert account;
    
            account.IsPartner = true;
            update account;
            
            Contact contact1 = new Contact();
            contact1.Email = 'test@test.com';
            contact1.LastName = 'Rice';
            contact1.AccountId = account.Id;
            insert contact1;
            
            id = contact1.Id;   
            accountId = account.Id;
            user.ContactId = id;
            user.FederationIdentifier = 'FedId125';
            businessAdminUser.UserRoleId = role1.Id;
                                        
            insert new List<User>{user,businessAdminUser};
            
            
            System.runAs(user){
                
                Opportunity opp1 = new Opportunity();
                opp1.Name = 'Good Test Opportunity';
                opp1.Affiliate_Account__c = account.Id;
                opp1.StageName='Closed Won';
                opp1.CloseDate=Date.today().addDays(-4);
                insert opp1;

                Order__c ordr = new Order__c();
                ordr.Name = 'Test Order';
                ordr.Opportunity__c=opp1.Id;
                ordr.OrderCompletedDate__c=Date.today().addDays(-3);
                insert ordr;
    
                Order__c order = [Select Id, Name, Claim_Eligibility__c From Order__c Where Name = 'Test Order'];
    
                ApexPages.StandardController stdController = new ApexPages.StandardController(order);
                RaiseClaimController claimController = new RaiseClaimController(stdController);
                claimController.description = '456Some %3 desc 5 Desc ___47';
                claimController.displayOrder();
                case1= new Case();
                case1.RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName()  .get(Label.Default_Claim_Record_Type).getRecordTypeId();
                case1.ContactId = id;
                case1.Region__c = 'Freedom Market';
                case1.Claimed_Amount__c = 1000;
                case1.OrderName__c=order.Id;
                
                insert case1;
                
                claimController.claimAmount = 100;
                
                PageReference pageRef = claimController.cancelOperation();
            
                pageRef = claimController.submitClaim();
                
                claimController.claimAmount = 0;
                claimController.isInternalUser = false;
                pageRef = claimController.submitClaim();
                
                System.runAs(businessAdminUser){
                    case1.OwnerId = businessAdminUser.Id; 
                    case1.Status='Cancelled';
                    update case1;
                    claimController.displayOrder();
                }
            }
        }
        Test.stopTest();
    }
}