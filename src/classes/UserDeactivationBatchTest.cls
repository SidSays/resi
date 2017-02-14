@isTest
private class UserDeactivationBatchTest{
 
   private static testMethod void UserDeactivationBatch() 
   {
   
    List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
    TriggerSettings__c userTrigger = new TriggerSettings__c();
    userTrigger.Name = 'UserTrigger';
    userTrigger.isActive__c = True;
    triggerSettingsList.add(userTrigger);
    
    TriggerSettings__c contactTrigger = new TriggerSettings__c();
    contactTrigger.Name = 'ContactTrigger';
    contactTrigger.isActive__c = True;
    triggerSettingsList.add(contactTrigger);
    
    TriggerSettings__c TaskTrigger = new TriggerSettings__c();
    TaskTrigger.Name = 'TaskTrigger';
    TaskTrigger.isActive__c = True;
    triggerSettingsList.add(TaskTrigger);
    
    
    insert triggerSettingsList ;
    
    Set<Id> userSet = new Set<Id>();
    User currentUser = [Select Id,email from User where Id=:UserInfo.getUserId()];
   // User dsrUser= WorkTestDataUtility.createDSRepUser();    
   // System.debug('dsrUSer>>>'+dsrUser);
    
    User dssUser= WorkTestDataUtility.createDSSupervisorUser();
    System.debug('userSet>>>'+dssUser);
    /* 
    Contact tempContact = new Contact(email = dsrUser.email, firstName = dsrUser.firstName, lastName = dsrUser.lastName);
    insert tempContact;

    EmailTemplate e = new EmailTemplate();
    System.runAs(currentUser)
    {
    
    e.isActive = true;
    e.TemplateType= 'Text';
    e.developerName =dsruser.FirstName;
    e.Name = 'test';
    e.FolderId = UserInfo.getUserId();
    e.Subject ='abc';
    insert e; 
    }   
    
   //system.debug('********Mail alert********* "+mail);
    List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
    List<String> sendTo = new List<String>();
    sendTo.add(dsrUser.email);
    system.debug('********sendto.add user ********* >>'+dsrUser.email);
    mail.setTargetObjectId(tempContact.id); 
    mail.setTemplateId(e.Id);
    mail.setToAddresses(sendTo);
    system.debug('********Mail alert 1*********>> '+mail);
    
    mail.setReplyTo(currentUser.email);
    mail.setSenderDisplayName('User deactivation mail');
    system.debug('********Mail alert 2********* '+mail);
    
    //mail.setSubject('User deactivation mail');
    //String body = 'Dear ' + dsrUser.FirstName + ', ';
    //body += 'Mail regarding user deactivation from past 45 days';
    //mail.setHtmlBody(body);
    //mails.setSubject = e.Subject;
    mails.add(mail);
    Messaging.sendEmail(mails);
    system.debug('********Mail alert send email********* '+mails);
    
    
    Task T = new Task();
    T.Type = 'Email';
    T.Description = 'new test sample'; //string
    T.OwnerId = dsruser.id; //user id
   // T.WhatId = mail.Id; //record id
    insert T;
    */ 
    String q = 'Select Name, Id, LastLoginDate from User WHERE (LastLoginDate < LAST_N_DAYS:45 OR LastLoginDate = NULL) AND ID = \''+ dssUser.ID +'\' AND IsActive = TRUE ORDER BY LastLoginDate DESC NULLS LAST';
    //String q = 'Select Name, Id, LastLoginDate from User WHERE (LastLoginDate < LAST_N_DAYS:45 OR LastLoginDate = NULL) AND ID = \''+ dsrUser.ID +'\' AND IsActive = TRUE ORDER BY LastLoginDate DESC NULLS LAST';
    // String q = 'Select Name, Id, LastLoginDate from User WHERE (LastLoginDate < LAST_N_DAYS:45 OR LastLoginDate = NULL) AND ID IN (\''+ dsrUser.ID +'\',\''+ dssUser.ID +'\',\''+ currentUser.ID +'\') AND IsActive = TRUE ORDER BY LastLoginDate DESC NULLs LAST';       
    // String q = 'Select Name, Id, LastLoginDate from User WHERE (LastLoginDate < LAST_N_DAYS:45 OR LastLoginDate = NULL) AND ID = \''+ currentUser.ID +'\' AND IsActive = TRUE ORDER BY LastLoginDate DESC NULLs LAST';       
    
    UserDeactivationBatch userObj = new UserDeactivationBatch(q);
    //Test.startTest();
    
    //Test.stopTest();
    UserDeactivationBatchSchedulable userObjschedule = new UserDeactivationBatchSchedulable();
    Test.startTest();
        database.executeBatch(userObj, 100);
        datetime currentDateTime = datetime.now();
        String min = String.valueOf(currentDateTime.minute());     
        String schExp = '0 '+min+' * * * ? ';

        
    Test.stopTest();
    system.schedule('Schedular Test 12:'+datetime.now(), '0 5 * * * ?' , userObjschedule );
    //System.debug('user object>>>'+userObj);
    
    /*UserDeactivationBatchSchedulable scheObj = new UserDeactivationBatchSchedulable();
    datetime currentDateTime = datetime.now();
    String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
    String schExp = '0 '+min+' * * * ? ';
    Test.startTest();
    system.schedule('Schedular Test 12:'+datetime.now(), schExp, scheObj);
    Test.stopTest(); */
   // System.debug('dsrUser.isActive>>>'+dsrUser.isActive);
     }
   }