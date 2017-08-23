@isTest
public class AccountsMatchingBatchTest
{
   
    static testmethod void AccountsMatching()
        {    

          Database.BatchableContext BC;
        
             TriggerSettings__c AddressTrigger = new TriggerSettings__c();
             AddressTrigger.Name = 'AddressTrigger';
             AddressTrigger.isActive__c = false;
             Database.insert(AddressTrigger); 
             
            
            
             ConfigurableParameters__c CP = new ConfigurableParameters__c ();
             CP.Name = 'BatchApexJobs';
             CP.NumberValue__c = 5;
             insert CP;
            
             AccountMatchManager__c AMM = new AccountMatchManager__c();
             AMM.Name = 'ALZ';
             AMM.Completed_Total__c = 5;
             AMM.Finished__c = true;
             AMM.Started__c = false;
             insert AMM;
            
             Customer_Address__c CA = new Customer_Address__c();
             CA.PostalCode__c = 'abcdefgh';
             CA.PostalCode_4__c = 'qwerty';
             CA.Address__c = 'test address';
             CA.Is_Account_Linking_Processed__c=false;
             CA.PostalCode__c = 'qwertyuio';
             
             insert CA;
            
            
             Account acc = new Account();
             acc.Name='Test123';
             acc.Zip_Code__c = '12345';
             acc.Description = 'test Desc'; 
             acc.Region__c = 'Beltway Market';
             acc.Billing_Account_Number__c = 'abc';
             acc.Service_Address__c = CA.id;
             insert acc;

         
             Test.startTest(); 
             AccountsMatchingBatch AMB = new AccountsMatchingBatch();
             Database.executeBatch(AMB,200);
             
             AccountMatchManager__c AMM1 = new AccountMatchManager__c();
             AMM1.Name = 'ALZ2';
             AMM1.Completed_Total__c = 5;
             AMM1.Finished__c = false;
             AMM1.Started__c = false;
             insert AMM1;
             AccountMatchManager__c AMM2 = new AccountMatchManager__c();
             AMM2.Name = 'ALZ2*';
             AMM2.Completed_Total__c = 5;
             AMM2.Finished__c = false;
             AMM2.Started__c = false;
             insert AMM2;
             
             AccountsMatchingBatch.kickOffJob(5);
             Test.stopTest();  
        }
}