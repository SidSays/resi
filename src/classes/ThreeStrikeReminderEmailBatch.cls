global class ThreeStrikeReminderEmailBatch implements Database.Batchable<sObject>{
  
  global String queryString='';

    global List<Case> updateCaseList = new List<Case>();
    
  global Database.QueryLocator start(Database.BatchableContext bContext) {   
        if(queryString==''){   
        
            Third_Reminder_Cases_Email__c[] caseReminders2 = [SELECT Name, Status_Check__c, Status2_Check__c, No_of_Reminders__c, Subject__c, Reminder_Check__c FROM Third_Reminder_Cases_Email__c WHERE Status2_Check__c = 'Status'];
            String noReminders2;             
            noReminders2 = caseReminders2[0].No_of_Reminders__c;            
            Boolean finalReminderCheck2;
            finalReminderCheck2 = caseReminders2[0].Reminder_Check__c;            
            List<String> threeReminderCustomSetting = new List<String>();   
    
            for(Third_Reminder_Cases_Email__c newObjThreeReminders : caseReminders2){
                threeReminderCustomSetting.add(newObjThreeReminders.Status_Check__c);
            }
            queryString = 'Select Id, Number_Of_Reminders__c, Status, Final_Time_Reminder_Check__c, Requested_For__c, CaseNumber, Case_URL_Type__c, Requested_For_FirstName__c from Case where  Number_Of_Reminders__c=:noReminders2 AND Status=:threeReminderCustomSetting AND Final_Time_Reminder_Check__c =: finalReminderCheck2' ; 
        }
        system.debug('check 1 '+queryString);
        return Database.getQueryLocator(queryString);
    }
    
  global void execute(Database.BatchableContext bContext, List<Case> listCases){ 
  system.debug('check 2 '+listCases);
   //List<Case> updateCaseList = new List<Case>();
  Database.SaveResult[] saveResult;
        for(Case caseToUpdate : listCases){       
         system.debug('check 3 '+caseToUpdate );   
            Third_Reminder_Cases_Email__c[] caseReminders = [SELECT Name, Status_Check__c,Status2_Check__c, No_of_Reminders__c, Subject__c, Reminder_Check__c FROM Third_Reminder_Cases_Email__c WHERE Status2_Check__c = 'Status' and Status_Check__c =: caseToUpdate.status limit 1];
            if(caseReminders.size()>0){
            system.debug('check 4 '+caseReminders[0]);  
                String noReminders;             
                noReminders = caseReminders[0].No_of_Reminders__c;            
                String requiredStatus;
                requiredStatus = caseReminders[0].Status_Check__c;
                String requiredSubject;
                requiredSubject = caseReminders[0].Subject__c;
                Boolean finalReminderCheck;
                finalReminderCheck = caseReminders[0].Reminder_Check__c;            
                if(caseToUpdate.Number_Of_Reminders__c != null && caseToUpdate.Number_Of_Reminders__c == noReminders && caseToUpdate.Status != null && caseToUpdate.Status.contains(requiredStatus) && caseToUpdate.Final_Time_Reminder_Check__c == finalReminderCheck){
                    // that will send out a single email to the addresses in the To, CC & BCC list.                              
                   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
                    Third_Reminder_Cases_Email__c Support = Third_Reminder_Cases_Email__c.getValues('SupportEmail');          
                   // String[] ccAddresses = new String[] {Support.From_email__c};
                    String[] ccAddresses = Support.From_email__c.split(';');
                    // Assign the addresses CC lists to the mail object.                
                    mail.setCcAddresses(ccAddresses);    
                    // Assign the address of the sender of the email
                    for(OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress]) {
                    Third_Reminder_Cases_Email__c Client = Third_Reminder_Cases_Email__c.getValues('ClientOwnerEmail'); 
                        if(owa.Address.contains(Client.From_email__c)) 
                            mail.setOrgWideEmailAddressId(owa.id);
                            system.debug('check 5 '+owa.id);  
                    }                
                    EmailTemplate reminderTemplate; 
                    try {
                        reminderTemplate = [select id, name,subject,HtmlValue, Body from EmailTemplate where developername = : Support.EmailTemplate__c];}
                    catch (Exception e) {
                    }                
                    mail.setTargetObjectId(caseToUpdate.Requested_For__c);                
                    mail.setSaveAsActivity(false);
                    String subject = reminderTemplate.Subject;
                    subject = subject.replace('{!Case.Status}', requiredSubject);                                                     
                    String plainBody = reminderTemplate.Body;
                    // Sending the values of Case Number and Case URL to the Email Template 
                    plainBody = plainBody.replace('{!Case.CaseNumber}', caseToUpdate.CaseNumber);
                    plainBody = plainBody.replace('{!Case.Case_URL_Type__c}', caseToUpdate.Case_URL_Type__c);
                    plainBody = plainBody.replace('{!Case.Requested_For_FirstName__c}', caseToUpdate.Requested_For_FirstName__c);
                    String htmlBody= reminderTemplate.Body;
                    htmlBody= htmlBody.replace('{!Case.CaseNumber}', caseToUpdate.CaseNumber);
                    htmlBody= htmlBody.replace('{!Case.Case_URL_Type__c}', caseToUpdate.Case_URL_Type__c);
                    htmlBody= htmlBody.replace('{!Case.Requested_For_FirstName__c}', caseToUpdate.Requested_For_FirstName__c);
                    mail.sethtmlBody(htmlBody);
                    // Set to True if you want to BCC yourself on the email.
                    mail.setBccSender(false); 
                    // Setting the subject and text body for the mail to be send
                    mail.setSubject(subject);
                    mail.setPlainTextBody(plainBody);
                    // Send the email you have created.
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                    caseToUpdate.Final_Time_Reminder_Check__c = false;
                    updateCaseList.add(caseToUpdate); 
                    
                }   
                try{
                     saveResult = Database.update(updateCaseList, false);
                     updateCaseList.clear();
                   } catch(Exception ex){                                 
                }

            }   
        }
    }
    
    global void finish(Database.BatchableContext bContext) {
       
     }
    
}