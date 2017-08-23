/**
 * Name     : GSIMeetingInfoSendEmail
 * Usage    : Send an notification email on GSI_Meeting_Info__c record creation
 *
 *  
 * Created By      : Appirio
 * Modified Date   : November 2016 
 */
public with sharing class GSIMeetingInfoSendEmail {
    
    @future 
    public static void SendNotificationEmail(set<Id> GSImeetingIDs,Set<Id> sendMailToGSIMeetingInfoId){
      
       list<GSI_Meeting_Info__c> lstGSIMeetingInfo =[Select Phone__c, Name, Meeting_Date__c, Last_Name__c, Id, 
                                                     First_Name__c, Email__c, 
                                                     Company__c, CreatedBy.Email, CreatedBy.FirstName, CreatedBy.LastName,
                                                     CreatedById   
                                                     From GSI_Meeting_Info__c where id  in:GSImeetingIDs];
       system.debug('::lstGSIMeetingInfo:::'+lstGSIMeetingInfo);
                                                     
       createLeads(lstGSIMeetingInfo);
       
    } 
    
    
   /*
   * Search are match all the Leads availbale for MeetingInfo where contact not availbale
   */ 
    private static void createLeads(List<GSI_Meeting_Info__c> leadsToCreate){        
        system.debug('::createLeads:::'+leadsToCreate);

        /*
        *  Create New Lead and Put the new create Lead with associated MeetingInfo 
        */  
        if(!leadsToCreate.isEmpty()){
            Map<id,Lead> createNewMeetingInfoLeads = new Map<id,Lead>();  
           
            Id directSalesRecordTypeId = returnRecordTypeId('Direct Sales');
            for(GSI_Meeting_Info__c mt:leadsToCreate){
                Lead newLead = new Lead();
                newLead.FirstName = mt.First_Name__c;
                newLead.email = mt.Email__c;
                newLead.LastName = mt.Last_Name__c;
                newLead.OwnerId = mt.CreatedById;
                newLead.LeadSource = 'Collateral';
                newLead.status = 'Open';
                newLead.Company = 'n/a';
                //newLead.Phone = mt.Phone__c;
                newLead.recordTypeId = directSalesRecordTypeId;
                    
                createNewMeetingInfoLeads.put(mt.Id,newLead); 
                
            }
            system.debug('::createNewMeetingInfoLeads.values():::'+createNewMeetingInfoLeads.values());
          
            insert createNewMeetingInfoLeads.values();

            system.debug(':APPIRIODEBUG:createNewMeetingInfoLeads:::'+createNewMeetingInfoLeads);
            //loop through and send an email to each lead
            for (Id nextMtgID : createNewMeetingInfoLeads.keySet()){
                sendEmailWithAttachments(createNewMeetingInfoLeads.get(nextMtgID), nextMtgID);
            }
            
                        
        }
    }
    
    private static void sendEmailWithAttachments (Lead myLead, Id gsiMeetingInfoId){
    
       //This method will send an email with all selected content.  There are 2 attributes that must be set for the content to be included:
       // 1) ContentVersion.Can_be_sent_to_customer__c = true
       // 2) Content Detail FileType__c = 'PDF' (only attach PDF documents)
       List<GSI_Selected_Content__c> selectedContentCVList = [SELECT Content_Detail__r.Url__c from GSI_Selected_Content__c WHERE GSI_Meeting_Info__c = :gsiMeetingInfoId and Content_Detail__r.FileType__c = 'PDF'];
       system.debug(':APPIRIODEBUG:selectedContentCVList:::'+selectedContentCVList);
       List<Id> cvIdList = new List<Id>();
       for(GSI_Selected_Content__c nextGsiContentV : selectedContentCVList) {
           cvIdList.add(nextGsiContentV.Content_Detail__r.Url__c);
       }
       system.debug(':APPIRIODEBUG:cvIdList:::'+cvIdList);
       List<ContentVersion> cvList = [SELECT Id, PathOnClient, VersionData from ContentVersion WHERE id in :cvIdList AND Can_be_sent_to_customer__c = true];
       system.debug(':APPIRIODEBUG:cvList:::'+cvList);
       
    
       EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Name = 'SalesSpace Collateral' LIMIT 1];
    
       Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId(template.Id);
        msg.setTargetObjectId(myLead.Id); 
        //msg.setWhatId(myLead.Id); // Here you can give if of account ,asset, campaign ,Case , contract if TragetObject is contact
        
    
        List<Messaging.EmailFileattachment> attachmentList = new  List<Messaging.EmailFileattachment>();
        for(ContentVersion nextContentVersion : cvList) {
           Messaging.EmailFileattachment nextAttachment = new Messaging.EmailFileattachment();
           nextAttachment.setFileName(nextContentVersion.PathOnClient);
           nextAttachment.setBody(nextContentVersion.VersionData); // PDFBody is of blob data Type 
           attachmentList.add(nextAttachment);
          
        }
        msg.setFileAttachments(attachmentList);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
    }
        
    
    private static string returnRecordTypeId(String recordTypeName) {
         String recordTypeId ;
         Schema.DescribeSObjectResult tskResult = Schema.SObjectType.Lead;
         Map<String,Schema.RecordTypeInfo> rtMapByName = tskResult.getRecordTypeInfosByName();
         if(rtMapByName.containsKey(recordTypeName))
         recordTypeId = rtMapByName.get(recordTypeName).getRecordTypeId(); 
         return recordTypeId;
    }
    
    
}