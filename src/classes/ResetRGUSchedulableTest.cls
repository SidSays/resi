/**
 * Test class for the ResetRGUSchedulable
 *
 * @Author Accenture
 * @Date 04/06/15
 */
@isTest
private class ResetRGUSchedulableTest
{
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
     static testMethod void resetRGUFields()
     {
      Test.startTest();
      Account parentaccnt = new Account();
      parentaccnt .Name = 'test';
      parentaccnt .Phone = '1234567890';
      parentaccnt .RGU_Orders_This_Fiscal_Month__c =0;
      parentaccnt .RGU_Activations_This_Fiscal_Month__c = 0;
      //parentaccnt .RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Store').getRecordTypeId(); 
      parentaccnt .Store_Type__c = 'Dealer';
      parentaccnt .Store_Location__Latitude__s = 12;
      parentaccnt .Store_Location__Longitude__s= 12;
      insert parentaccnt ;
      
      Parent_Account__c settng = new Parent_Account__c(Name = 'TestAccnt', Parent_Store_Id__c = parentaccnt.Id);
      insert settng;
      
      Account a = new Account();
      a.Name = 'test';
      a.Phone = '1234567890';
      a.RGU_Orders_This_Fiscal_Month__c =0;
      a.RGU_Activations_This_Fiscal_Month__c = 0;
      a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Store').getRecordTypeId(); 
      a.Store_Type__c = 'Dealer';
      a.Store_Location__Latitude__s = 12;
      a.Store_Location__Longitude__s= 12;
      a.Parent_Account_Dropdown__c = 'TestAccnt';
      insert a;
      
      String jobId = System.schedule('ResetRGUSchedulable',
                        CRON_EXP, 
                        new ResetRGUSchedulable());
                        
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];                  
      
      System.assertEquals(CRON_EXP, ct.CronExpression);
      System.assertEquals(0, ct.TimesTriggered);
     
      Test.stopTest();
     }

}