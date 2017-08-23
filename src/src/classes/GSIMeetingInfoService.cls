/**
 * Name     : GSIMeetingInfoService
 * Usage    : GSI Application service to handle save meeting info data for GSI application
 *            This service will save GSI_MeetingInfo__c objects and related selections
 *            WIll handle batch porcess several meetings using asynch @future invoke
 *            to leave iPad application responsive and handle all rules of creating
 *              Leads and Contacts.
 *  
 * Created By      : Igor Androsov
 * Modified By     : Igor Androsov
 * Modified Date   : June 18, 2013
 */
@RestResource(urlMapping='/gsimeetinginfo/*') 
global with sharing class GSIMeetingInfoService {

 @HttpPost
    global static List<GSIMeetingInfoResponse> doPost(String meeting) {
        
        List<GSIMeetingInfoResponse> lst = new List<GSIMeetingInfoResponse>();
        //Get Request  from  rest Context 
        //RestRequest req = RestContext.request;
        
        //Get Body atatched with request 
        //Blob body = req.requestBody;
        //String bodyString = body.toString();
        
         String bodyString = meeting;
         
        // Deserialize the list of GSIMetadataWrapper from the JSON string.
        system.debug(':::bodyString :::'+bodyString);
        List<GSIMeetingInfo> MeetingInformations = GSIMeetingInfo.getFullGSIMeetingInfo(System.JSON.createParser(bodyString));
        Set<Id> sendEmailAddedIdsSet = new Set<Id>();
        Set<Id> meetingInfoForFutureCallIds = new Set<Id>();
        GSIMeetingInfoResponse gsiMeetingInfoResponse = new GSIMeetingInfoResponse();
        system.debug('*********** Enter GSI meeting info process '+MeetingInformations.size());
        for(GSIMeetingInfo meetingInfo : MeetingInformations){
            if(meetingInfo!= null){
                // Create a savepoint 
                Savepoint sp = Database.setSavepoint();
                  try{
                    
                    //  Create meeting info Object with relateed List records 
                    GSI_Meeting_Info__c gsi_MeetingInfo = createMeetingInfo(meetingInfo);
                    gsiMeetingInfoResponse.id = gsi_MeetingInfo.id;
                    gsiMeetingInfoResponse.message = 'Meeting Info Created Success';
                    List<GSI_Selected_Content__c> createSelectedContents = createSelectedContent(meetingInfo,gsi_MeetingInfo.id);
                    
                    /*
                     * MeetingInfo service to conditionally send e-mails 
                    */
                    system.debug('*********** added successfully gsi_MeetingInfo.Id ' +gsi_MeetingInfo.Id);
                    meetingInfoForFutureCallIds.add(gsi_MeetingInfo.Id);
                    if(meetingInfo.SendEmail == 'YES'){
                       sendEmailAddedIdsSet.add(gsi_MeetingInfo.Id);
                       system.debug('*********** Send Email for Meeting  ************'+gsi_MeetingInfo.Id); 
                    }
                  }catch(Exception ex){
                    system.debug('*********** Meeting info FAILED Rollback in effect');
                    // Rollback to the previous null value
                    system.debug('::Exception :::'+ex);
                    gsiMeetingInfoResponse.id = null;
                    gsiMeetingInfoResponse.message = 'Meeting Info process Failed';
                    Database.rollback(sp);
                  }
                  lst.add(gsiMeetingInfoResponse);
            }
        }
        //send email separately after all records are added, only send for successful records
        system.debug('::: sendEmailAddedIdsSet :::'+sendEmailAddedIdsSet);
        system.debug('::: meetingInfoForFutureCallIds :::'+meetingInfoForFutureCallIds);
        
        GSIMeetingInfoSendEmail.SendNotificationEmail(meetingInfoForFutureCallIds,sendEmailAddedIdsSet);
        return lst;
    }
    
  
    private static  GSI_Meeting_Info__c createMeetingInfo(GSIMeetingInfo  meetingInfo){
        GSI_Meeting_Info__c gsi_MeetingInfo = new GSI_Meeting_Info__c();
        gsi_MeetingInfo.name = meetingInfo.firstName +  meetingInfo.lastName;  
        gsi_MeetingInfo.Last_Name__c = meetingInfo.lastName;
        gsi_MeetingInfo.First_Name__c = meetingInfo.firstName;
        gsi_MeetingInfo.Email__c = meetingInfo.email;
        gsi_MeetingInfo.Company__c  = meetingInfo.company;
        gsi_MeetingInfo.Notes__c =  meetingInfo.Notes;
        gsi_MeetingInfo.Phone__c = meetingInfo.Phone;
        gsi_MeetingInfo.Country_Text__c = meetingInfo.Country;
        gsi_MeetingInfo.Country_Code__c = meetingInfo.CountryCode;
        gsi_MeetingInfo.State_Code__c = meetingInfo.StateCode;
        gsi_MeetingInfo.State_Text__c = meetingInfo.State;
        gsi_MeetingInfo.Meeting_Contact__c = meetingInfo.sfid;
        
        if(meetingInfo.FollowDate != null && meetingInfo.FollowDate != ''){
            try{
                if(meetingInfo.FollowDate.lastIndexOf(':') != 16){
                    meetingInfo.FollowDate+=':00';
                }           
                gsi_MeetingInfo.Follow_up_Meeting_Date__c = DateTime.valueOf(meetingInfo.FollowDate);
           }catch(Exception ex){}
        }
        
        if(meetingInfo.MeetingDate != null && meetingInfo.MeetingDate.length() > 0) {
            gsi_MeetingInfo.Meeting_Date__c = Date.valueOf(meetingInfo.MeetingDate);
        }   
             
        system.debug('********  createMeetingInfo gsi_MeetingInfo ' +gsi_MeetingInfo);
        insert gsi_MeetingInfo;
        return gsi_MeetingInfo;
    }
    
    
    private  static List<GSI_Selected_Content__c> createSelectedContent(GSIMeetingInfo  meetingInfo,Id meetingInfoId){
        List<GSI_Selected_Content__c> gsi_SelectedContents = new List<GSI_Selected_Content__c>();
        system.debug('************** meetingInfo.selectedContent ' +meetingInfo);
        system.debug('************** meetingInfo.selectedContent ' +meetingInfo.selectedContents);
        if(meetingInfo.selectedContents != null && meetingInfo.selectedContents.size() >0) {
            for(GSIMeetingInfo.SelectedContent contentItem : meetingInfo.selectedContents){
                GSI_Selected_Content__c gsi_SelectedContent = new GSI_Selected_Content__c();
            
            // 1.Content Details Not on Task description
            // 2.Category not Available on Custom Object
            
            //Content Document IDs  will come from our Content REST service and download process.
            if (contentItem.contentId != null && contentItem.contentId.length() > 0){            
                gsi_SelectedContent.Content_Detail__c = contentItem.contentId;
            }
            gsi_SelectedContent.Content_Name__c = contentItem.fileName;
            gsi_SelectedContent.Content_Type__c = contentItem.fileType;
            gsi_SelectedContent.GSI_Meeting_Info__c = meetingInfoId;
            system.debug('********  createSelectedContent gsi_SelectedContent ' +gsi_SelectedContent);
            gsi_SelectedContents.add(gsi_SelectedContent);
            }
        }
        if(gsi_SelectedContents.size() >0) 
            insert gsi_SelectedContents;
            
        return gsi_SelectedContents;
    } 
        
}