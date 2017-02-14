@isTest
public class OpportunityValidationTest {

    static testMethod void AEvalidation() {
        
        //create test data
        TestDataUtility.createCustomSettingRecords();

        TriggerSettings__c mduPropertyTrigger = new TriggerSettings__c();
        mduPropertyTrigger.Name = 'OpportunityTrigger';
        mduPropertyTrigger.isActive__c = True;
        database.insert(mduPropertyTrigger);
        
        TriggerSettings__c cptrg = new TriggerSettings__c();
        cptrg.Name = 'ContractorRegionMappingTrigger';
        cptrg.isActive__c = false;
        database.insert(cptrg);
        
        Account acc = TestDataUtility.createAccount();
        Database.insert(acc);     

        User Manager = new User();
        Manager.City='Test City';
        Manager.Username = 'testash21@gmail.com';
        Manager.LastName = 'First Last21';       
        Manager.Email = 'storehomeuser121@test1.com';
        Manager.Alias = 'Te21';
        Manager.CommunityNickname = 'te21';
        Manager.TimeZoneSidKey = 'America/Panama';
        Manager.LocaleSidKey = 'en_US';
        Manager.EmailEncodingKey = 'ISO-8859-1';
        Manager.LanguageLocaleKey = 'en_US';
        Manager.profileId = [select id from profile where name='XC Manager'].id;
        Manager.DefaultDivision = '02dG0000000007HIAQ';
        Manager.FederationIdentifier = 'asd21';
        Manager.Region__c= 'Beltway Market';
        Manager.isactive=true;
        insert Manager; 
        
        User Manager1 = new User();
        Manager1.City='Test City';
        Manager1.Username = 'testash212@gmail.com';
        Manager1.LastName = 'First Last212';       
        Manager1.Email = 'storehomeuser1212@test1.com';
        Manager1.Alias = 'Te212';
        Manager1.CommunityNickname = 'te212';
        Manager1.TimeZoneSidKey = 'America/Panama';
        Manager1.LocaleSidKey = 'en_US';
        Manager1.EmailEncodingKey = 'ISO-8859-1';
        Manager1.LanguageLocaleKey = 'en_US';
        Manager1.profileId = [select id from profile where name='XC Manager'].id;
        Manager1.DefaultDivision = '02dG0000000007HIAQ';
        Manager1.FederationIdentifier = 'asd212';
        Manager1.Region__c= 'Houston Market';
        Manager1.isactive=true;
        insert Manager1;
        
              
        User AEUser1 = new User();
        AEUser1.City='Test City23';
        AEUser1.Username = 'testash23@gmail.com';
        AEUser1.LastName = 'First Last23';       
        AEUser1.Email = 'storehomeuser23@test1.com';
        AEUser1.Alias = 'Te23';
        AEUser1.CommunityNickname = 'test23';
        AEUser1.TimeZoneSidKey = 'America/Panama';
        AEUser1.LocaleSidKey = 'en_US';
        AEUser1.EmailEncodingKey = 'ISO-8859-1';
        AEUser1.LanguageLocaleKey = 'en_US';
        AEUser1.profileId = [select id from profile where name='XC AE Contractors'].id;
        AEUser1.DefaultDivision = '02dG0000000007HIAQ';
        AEUser1.FederationIdentifier = 'asd23';
        AEUser1.Region__c= 'Multiple';
        AEUser1.isactive=true;
        insert AEUser1;   
        
        Contractor_Region_Mapping__c pg1 = new Contractor_Region_Mapping__c();
        pg1.Reporting_Manager__c = Manager1.id;
        pg1.Region__c = 'Houston Market';
        pg1.AE_Contractor__c = AEUser1.id;
        insert pg1;
        
        Opportunity opp11 = New Opportunity();
        opp11.StageName = 'Closed Won';    
        opp11.ContractTermUnit__c = 'months';
        opp11.ContractTerm__c = 2;
        opp11.AccountId = acc.id;
        opp11.Contract_Type__c = 'Bulk';
        opp11.Fiber_To_The_Unit__c = 'Fiber to the Building';
        opp11.Name='SIDd';
        opp11.CloseDate=system.today();
        opp11.AssignedAE_ID__c=Manager.id;
        opp11.OwnerId=Manager.id;
        opp11.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Xfinity Opportunity Record Type').getRecordTypeId();
        insert(opp11); 
        
        string label1='Contractor AE doesn\'t report in the region of logged in user';
        string label2='System Administrator';
        
        Test.startTest();
        System.runAs(Manager){ 
            opp11.AssignedAE_ID__c=AEUser1.id;
            try{ update Opp11;
                }catch(Exception e)
                { Boolean expectedExceptionThrown =  e.getMessage().contains(System.label.Opportunity_AE_Change_Validation) ? true : false;
                  System.AssertEquals(expectedExceptionThrown, true);
                }
              
            
        }
        User user2 = [Select Id from User where Profile.Name='System Administrator' and isactive=true LIMIT 1];           
        System.runAs(user2){ 
            opp11.AssignedAE_ID__c=AEUser1.id;
            update Opp11;   
            System.AssertEquals(Opp11.AssignedAE_ID__c,AEUser1.id);
            //System.AssertEquals(bypass,true);                                    
            }                   
        Test.stopTest();
        }
}