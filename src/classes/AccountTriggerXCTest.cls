/***************************************************************************************************************************************
 * Author     : Jui Desai, Accenture
 * Date       : 02-June-2015
 * Description: This is Test class for "AccountTrigger" trigger
 * History
     Version             : 1.0
     Author Last Updated : Jui, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class AccountTriggerXCTest{

    private static final string RECORD_TYPE_SEPERATION = ';';
    
   /*
    *Method to Create an Account record with xfinity record type
    */
    public static Account createTestAccount() {   
        List<Id> recordTypeIds = new List<Id>();      
        String labelName = System.Label.XfinityAccountRecordType;  
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(RECORD_TYPE_SEPERATION)){
                recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }       
        Account acc = new Account();
        acc.RecordTypeId = recordTypeIds[0];
        acc.Name='Hometown America';
        acc.Zip_Code__c = '12345';
        acc.Description = 'test Desc';
        acc.Is_Parent_Organization__c= true;        
        return acc;
    }

   /*
    *Method to add parent account on update
    */
    static testmethod void UpdateParentAcc(){ 

        TestDataUtility.createCustomSettingRecords();

        User xcUser = TestDataUtility.createXCIntegrationUser();  
        Id currentProfileId = xcUser.ProfileId;
        System.runAs(xcUser){
            TestDataUtility.setAllowParentAccChange(currentProfileId);         
            Test.startTest();

            Account ParentAccountObject= createTestAccount();
            Database.insert(ParentAccountObject);
            Account account = [Select Name, id from Account];

            Account AccountObject = TestDataUtility.createAccount();
            Database.insert(AccountObject);
            AccountObject.ParentAccountSelection__c= 'Hometown America [PARENT]';
            Database.update(AccountObject);

            List<Account> acc= [select id, name, ParentId from Account where id=: AccountObject.id];
            System.assertEquals(acc[0].ParentId, account.id);     
            Test.stopTest();

        }
    }

   /*
    *Method to add parent account using invalid user
    */
    static testmethod void insertUsingInvalidUser(){

        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCAccountExecUser();  
        Id currentProfileId = xcUser.ProfileId;
        System.runAs(xcUser){
            //TestDataUtility.setAllowParentAccChange(currentProfileId);
            Test.startTest();
            try{              

                Account ParentAccountObject= TestDataUtility.createAccount();
                Database.insert(ParentAccountObject);
                ParentAccountObject.Is_Parent_Organization__c= true;
                Database.update(ParentAccountObject);
                List<Account> acc = [Select id, name from Account where id =: ParentAccountObject.id];
            }

            catch(Exception e){
                Boolean exp =  e.getMessage().contains(System.Label.NO_ACCESS_TO_MODIFY_ACOOUNT) ? true : false;
                system.assertEquals(exp,true);
            }
          Test.stopTest(); 
        }  
    }
    
   /*
    *Method to add Parent account from picklist but the record is not present
    */
    static testmethod void InvalidPicklist(){
        
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        Id currentProfileId = xcUser.ProfileId;
        System.runAs(xcUser){
            TestDataUtility.setAllowParentAccChange(currentProfileId);          
            Test.startTest();
            try{
                Account ParentAccountObject= createTestAccount();
                Database.insert(ParentAccountObject);
                Account account = [Select Name, id from Account];

                Account AccountObject = TestDataUtility.createAccount();
                Database.insert(AccountObject);
                AccountObject.ParentAccountSelection__c= 'Land and Co. [PARENT]';
                Database.update(AccountObject);

                List<Account> acc= [select id, name, Account.Parent.Name from Account where id =:AccountObject.id];
            }
            catch(Exception e){
                Boolean exp =  e.getMessage().contains(System.Label.ParentAccountDoesNotExists) ? true : false;
                system.assertEquals(exp,true);
            }     
            Test.stopTest();
        }
    }
    
   /*
    *Method to add parent account directly through the lookup field on Update
    */
    static testmethod void ParentIdNotNullUpdate(){
        
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        Id currentProfileId = xcUser.ProfileId;
        System.runAs(xcUser){
            TestDataUtility.setAllowParentAccChange(currentProfileId);          
            Test.startTest();
            try{
                Account ParentAccountObject= createTestAccount();
                Database.insert(ParentAccountObject);
                Account account = [Select Name, id from Account];

                Account AccountObject = TestDataUtility.createAccount();
                Database.insert(AccountObject);
                AccountObject.ParentId = ParentAccountObject.id;
                Database.update(AccountObject);

                List<Account> acc= [select id, name, Account.Parent.Name from Account where id =:AccountObject.id];
            }
            catch(Exception e){
                Boolean exp =  e.getMessage().contains(System.Label.ParentAccountAssignErr) ? true : false;
                system.assertEquals(exp,true);
            }     
            Test.stopTest();
        }
    }  
    
   /*
    *Method to add parent account directly through the lookup field on Insert
    */
    static testmethod void ParentIdNotNullInsert(){
        
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        Id currentProfileId = xcUser.ProfileId;
        System.runAs(xcUser){
            TestDataUtility.setAllowParentAccChange(currentProfileId);          
            Test.startTest();
            try{
                Account ParentAccountObject= createTestAccount();
                Database.insert(ParentAccountObject);
                Account account = [Select Name, id from Account];

                List<Id> recordTypeIds = new List<Id>();      
                String labelName = System.Label.XfinityAccountRecordType;  
                if(!string.IsBlank(labelName)){
                    for(String str : labelName.split(RECORD_TYPE_SEPERATION)){
                        recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId());
                    }
                }       
                Account acc = new Account();
                acc.RecordTypeId = recordTypeIds[0];
                acc.Name='abctest';
                acc.Zip_Code__c = '12345';
                acc.Description = 'test Desc';
                acc.Is_Parent_Organization__c= true;        
                acc.ParentId= account.id;        
                Database.insert(acc);

                List<Account> accList= [select id, name, Account.Parent.Name from Account where id =:acc.id];
            }
            catch(Exception e){
                Boolean exp =  e.getMessage().contains(System.Label.ParentAccountAssignErr) ? true : false;
                system.assertEquals(exp,true);
            }   
            Test.stopTest();
        }
    }
    
   /*
    *Method to add Parent Account on insert
    */
    static testmethod void InsertParentAcc(){ 

        TestDataUtility.createCustomSettingRecords();

        User xcUser = TestDataUtility.createXCIntegrationUser();  
        Id currentProfileId = xcUser.ProfileId;
        System.runAs(xcUser){
            TestDataUtility.setAllowParentAccChange(currentProfileId);          
            Test.startTest();

            Account ParentAccountObject= createTestAccount();
            Database.insert(ParentAccountObject);
            Account account = [Select Name, id from Account];

            List<Id> recordTypeIds = new List<Id>();      
            String labelName = System.Label.XfinityAccountRecordType;  
            if(!string.IsBlank(labelName)){
                for(String str : labelName.split(RECORD_TYPE_SEPERATION)){
                    recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId());
                }
            }       
            Account acc = new Account();
            acc.RecordTypeId = recordTypeIds[0];
            acc.Name='abctest';
            acc.Zip_Code__c = '12345';
            acc.Description = 'test Desc';
            acc.Is_Parent_Organization__c= true;              
            acc.ParentAccountSelection__c= 'Hometown America [PARENT]';
            Database.insert(acc);

            List<Account> accList= [select id, name, ParentId from Account where id=: acc.id];
            System.assertEquals(accList[0].ParentId, account.id);     
            Test.stopTest();

        }
    }
    
    /*
    *Method to Create Parent Account on Update
    */
    static testmethod void ParentAccUpdate(){ 

        TestDataUtility.createCustomSettingRecords();

        User xcUser = TestDataUtility.createXCIntegrationUser();  
        Id currentProfileId = xcUser.ProfileId;
        System.runAs(xcUser){
            TestDataUtility.setAllowParentAccChange(currentProfileId);          
            Test.startTest();

            List<Id> recordTypeIds = new List<Id>();      
            String labelName = System.Label.XfinityAccountRecordType;  
            if(!string.IsBlank(labelName)){
                for(String str : labelName.split(RECORD_TYPE_SEPERATION)){
                    recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId());
                }
            }       
            Account acc = new Account();
            acc.RecordTypeId = recordTypeIds[0];
            acc.Name='abctest';
            acc.Zip_Code__c = '12345';
            acc.Description = 'test Desc';
            acc.Is_Parent_Organization__c= true;              
            Database.insert(acc);
            
            List<Account> accList= [select id, name from Account where id=: acc.id];   
            accList[0].name = 'abc';
            Database.Update(accList);
            
            List<Account> accListUpdated= [select id, name from Account where id=: accList[0].id];
            system.assertEquals(accListUpdated[0].name, 'abc [PARENT]');   
            Test.stopTest();

        }
    }
    
    
    
}