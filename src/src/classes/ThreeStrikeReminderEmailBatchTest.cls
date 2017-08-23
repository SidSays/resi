/***************************************************************************************************************************************
 * Author     : Shivam Mori, Accenture
 * Date       : 05-April-2016
 * Description: This is Test class for "ThreeStrikeReminderEmailBatch"  and "ThreeStrikeReminderEmailBatchSchedulable" classes.
 
 * History
 * Version             : 1.0
 * Author Last Updated : Shivam Mori, Accenture 
 * PROJECT             : Comcast Resi
***************************************************************************************************************************************/

@isTest
global class ThreeStrikeReminderEmailBatchTest {

    //global String caseList;
    public static String CRON_EXPP1 = '0 0 0 3 9 ? 2022';
    global static testMethod void ValidateThreeStrikeReminderEmailBatch(){
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
            TriggerSettings__c caseTrigger = new TriggerSettings__c();
            caseTrigger.Name = 'CaseTrigger';
            caseTrigger.isActive__c = True;
            triggerSettingsList.add(caseTrigger);
            insert triggerSettingsList;

        Third_Reminder_Cases_Email__c thirdreminderList = new Third_Reminder_Cases_Email__c();
        thirdreminderList.Name='test';
        thirdreminderList.Status_Check__c='Pending User Confirmation';
        thirdreminderList.Status2_Check__c='Status';
        thirdreminderList.No_of_Reminders__c='3';
        thirdreminderList.Subject__c='User Confirmation';
        thirdreminderList.Reminder_Check__c=true;
        insert thirdreminderList;
        
        Third_Reminder_Cases_Email__c thirdreminderList2 = new Third_Reminder_Cases_Email__c();
        thirdreminderList2.Name='SupportEmail';
        thirdreminderList2.EmailTemplate__c='Third_Reminder_Case_Email_Template';
        thirdreminderList2.From_email__c='comcast.resi.all@accenture.com';
        thirdreminderList2.Reminder_Check__c=false;
        insert thirdreminderList2;
        
        Third_Reminder_Cases_Email__c thirdreminderList3 = new Third_Reminder_Cases_Email__c();
        thirdreminderList3.Name='ClientOwnerEmail';
        thirdreminderList3.EmailTemplate__c='none';
        thirdreminderList3.From_email__c='shrey.rai.chhabra@accenture.com';
        thirdreminderList3.Reminder_Check__c=false;
        insert thirdreminderList3;
        
        OrgWideEmailAddress owa = new OrgWideEmailAddress();
        owa.Address='shrey.rai.chhabra@accenture.com';
        owa.DisplayName='Shrey Chhabra';
        owa.IsAllowAllProfiles=false;
        
        
        Case CaseToCreate = new Case();
        
        CaseToCreate.Requested_For__c = userinfo.getuserid();
        CaseToCreate.Preferred_Phone__c = '1234567890';
        CaseToCreate.Preferred_Email__c = 'shivam.ajitsinh.mori@accenture.com';
        CaseToCreate.Channel__c = 'Direct Sales';
        CaseToCreate.Status = 'Pending User Confirmation';
        CaseToCreate.Region__c = 'Corporate';
        CaseToCreate.Request_Type__c = 'SalesForce.com';
        CaseToCreate.Description = 'Test Case';
        CaseToCreate.Number_Of_Reminders__c = '3';
        System.debug('Check two '+CaseToCreate);
        insert CaseToCreate;
        System.debug('Check three '+CaseToCreate.id);
        Case newCase = new Case(Id=CaseToCreate.id);
        //insert newCase;

        // List<Case> Caselist = new List<Case>();
         //Case Caseone = new Case();
      
       // caseList = 'SELECT Id FROM Case where id ='+newCase.id
        ThreeStrikeReminderEmailBatchSchedulable ThreeStrikeReminderEmailBatchobj = new ThreeStrikeReminderEmailBatchSchedulable();
        List<Case> caselist=new List<Case>();
        CaseList = [Select Id, Number_Of_Reminders__c, Status, Requested_For__c from Case where id =:newCase.id ]; 
        //System.debug('Check four'+sb);
        Test.startTest();
        String scheduledJobId1 = System.schedule('testScheduledApex1', CRON_EXPP1, ThreeStrikeReminderEmailBatchobj);    
        Test.stopTest();
      
   }
}