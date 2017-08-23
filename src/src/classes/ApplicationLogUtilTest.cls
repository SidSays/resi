/***************************************************************************************************************************************
 * Author     : Amit Kumar, Accenture
 * Date       : 28-June-2017
 * Description: This is Test class for "ApplicationLogUtil" class.
 
***************************************************************************************************************************************/

@isTest
public class ApplicationLogUtilTest{
    
   public static testmethod void insertApplogforexceptionsTest(){ 
   	VariableSettingTestUtility.variableSettingsData();
   	Id nonintegrationRTypeId = Schema.SObjectType.Application_Log__c.getRecordTypeInfosByName().get(ConstantHandler.APPLOGNONINTEGRATION).getRecordTypeId();
    
    TriggerSettings__c AccountTrigger = new TriggerSettings__c();
    AccountTrigger.Name = 'AccountTrigger';
    AccountTrigger.isActive__c = False;
    insert AccountTrigger;
    Account Acc= TestDataUtility.createAccount();
    insert acc;
    acc.House_Key__c = '123456789987654321123456';
    try{
    	update acc;
    }catch (Exception ex){
    	ApplicationLogUtil.insertApplogforexceptions(ex, 'Class','ApplicationLogUtilTest','Account', false,acc.id,nonintegrationRTypeId);
    }
      	
   }
   public static testmethod void insertApplogforsaveresultTest(){
   	  VariableSettingTestUtility.variableSettingsData();
   	Id nonintegrationRTypeId = Schema.SObjectType.Application_Log__c.getRecordTypeInfosByName().get(ConstantHandler.APPLOGNONINTEGRATION).getRecordTypeId(); 
   
     TriggerSettings__c AccountTrigger = new TriggerSettings__c();
    AccountTrigger.Name = 'AccountTrigger';
    AccountTrigger.isActive__c = False;
    insert AccountTrigger;
    Account Acc= TestDataUtility.createAccount();
    insert acc;
    acc.House_Key__c = '123456789987654321123456';
    list<Account> lstaccount = new list<Account>();
    lstaccount.add(acc);
    database.saveresult[] lsr = database.update(lstaccount,false);
   
    	ApplicationLogUtil.insertApplogforsaveresult(lsr, 'Class','ApplicationLogUtilTest','Account', false,lstaccount,nonintegrationRTypeId);
     
      	
   }
   public static testmethod void insertApplogfordeleteresultTest(){ 
   	 VariableSettingTestUtility.variableSettingsData();
    Id nonintegrationRTypeId = Schema.SObjectType.Application_Log__c.getRecordTypeInfosByName().get(ConstantHandler.APPLOGNONINTEGRATION).getRecordTypeId(); 
    
     TriggerSettings__c AccountTrigger = new TriggerSettings__c();
    AccountTrigger.Name = 'AccountTrigger';
    AccountTrigger.isActive__c = False;
    insert AccountTrigger;
    Account Acc= TestDataUtility.createAccount();
    insert acc;
    list<Account> lstaccount = new list<Account>();
    lstaccount.add(acc);
    delete lstaccount;
    database.deleteresult[] ldr = database.delete(lstaccount,false);
    ApplicationLogUtil.insertApplogfordeleteresult(ldr, 'Class','ApplicationLogUtilTest','Account', false,lstaccount,nonintegrationRTypeId); 
      	
   }
   public static testmethod void insertApplogforupsertresultTest(){
   	VariableSettingTestUtility.variableSettingsData(); 
    Id nonintegrationRTypeId = Schema.SObjectType.Application_Log__c.getRecordTypeInfosByName().get(ConstantHandler.APPLOGNONINTEGRATION).getRecordTypeId(); 
     
    TriggerSettings__c AccountTrigger = new TriggerSettings__c();
    AccountTrigger.Name = 'AccountTrigger';
    AccountTrigger.isActive__c = False;
    insert AccountTrigger;
    Account Acc= TestDataUtility.createAccount();
    insert acc;
    acc.House_Key__c = '123456789987654321123456';
    list<Account> lstaccount = new list<Account>();
    lstaccount.add(acc);
    database.upsertresult[] lur = database.upsert(lstaccount,false);
    ApplicationLogUtil.insertApplogforupsertresult(lur, 'Class','ApplicationLogUtilTest','Account', false,lstaccount,nonintegrationRTypeId);
   }
   public static testmethod void insertApplogforemailresultTest(){ 
   	VariableSettingTestUtility.variableSettingsData(); 
    Id nonintegrationRTypeId = Schema.SObjectType.Application_Log__c.getRecordTypeInfosByName().get(ConstantHandler.APPLOGNONINTEGRATION).getRecordTypeId(); 
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setToAddresses(new String[] { 'a677676@434343.com' });
		email.setSubject('my subject');
		email.setPlainTextBody('plain text body');
		email.setTemplateId('a01000000000bad');
		Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.Email[] { email });
	ApplicationLogUtil.insertApplogforemailresult(results, 'Class','ApplicationLogUtilTest','Account', false,nonintegrationRTypeId);
	 	
   }
        
    
}