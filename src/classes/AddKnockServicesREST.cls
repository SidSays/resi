@RestResource(urlMapping='/AddKnockServicesREST/*')
global without sharing class AddKnockServicesREST{

@HttpPost
    global static returnValues addKnocks(KnockObject knock) {
      returnValues rValue = new returnValues();
       
       Task knockToUpsert = new Task();
       knockToUpsert.Description = knock.description;
       knockToUpsert.Disposition__c = knock.disposition;
       knockToUpsert.Event_Category__c = knock.event_Category;
       knockToUpsert.Event_Name_or_Number__c = knock.event_Name_or_Number;
       if(knock.hsi_Sold == 1){       
           knockToUpsert.HSI_Sold__c = true;
       }
       else{
           knockToUpsert.HSI_Sold__c = false;
       }             
       knockToUpsert.Home_Security_Competitor__c = knock.home_Security_Competitor;
       knockToUpsert.Internet_Competitor__c = knock.internet_Competitor;
       knockToUpsert.Knocked_Date__c = knock.knocked_Date;
       knockToUpsert.Non_Marketable_Reason__c = knock.non_Marketable_Reason;
       if(knock.non_Marketable_Reason!=null){
            knockToUpsert.Vacant_Home_Follow_up_Date__c  = knock.vacantFollowUp_Date;
       }
        knockToUpsert.Property_Event__c  = knock.property_Event;
       if(knock.ownerId != null && knock.ownerId != ''){       
           knockToUpsert.OwnerId = knock.ownerId;
       }       
       knockToUpsert.Phone_Competitor__c = knock.phone_Competitor;
       knockToUpsert.Priority = knock.priority;
       if(knock.recordTypeId != null && knock.recordTypeId != ''){       
           knockToUpsert.RecordTypeId = knock.recordTypeId;
       }              
       knockToUpsert.Rejected_Reason__c = knock.rejected_Reason;
       if(knock.rejected == 1){       
           knockToUpsert.Rejected__c = true;
       }
       else{
           knockToUpsert.Rejected__c = false;
       } 

       knockToUpsert.Sales_Type__c = knock.sales_Type;
       knockToUpsert.Status = knock.status;
       knockToUpsert.Subject = knock.subject;
       knockToUpsert.Type__c = knock.type;
       knockToUpsert.Video_Competitor__c = knock.video_Competitor;
       if(knock.video_Sold== 1){       
           knockToUpsert.Video_Sold__c = true;
       }
       else{
           knockToUpsert.Video_Sold__c = false;
       }        

       if(knock.voice_Sold== 1){       
           knockToUpsert.Voice_Sold__c = true;
       }
       else{
           knockToUpsert.Voice_Sold__c = false;
       }
       if(knock.whatId != null && knock.whatId != ''){
           knockToUpsert.WhatId = knock.whatId;
       }       
       if(knock.xh_Sold== 1){       
           knockToUpsert.XH_Sold__c = true;
       }
       else{
           knockToUpsert.XH_Sold__c = false;
       }       


       knockToUpsert.Knock_External_Id__c = knock.uniqueId;
       knockToUpsert.Internet_Contract_End__c = knock.internet_Contract_End;
       knockToUpsert.Video_Contract_End__c = knock.video_Contract_End;
       knockToUpsert.Phone_Contract_End__c = knock.phone_Contract_End;
       knockToUpsert.Security_Contract_End__c = knock.security_Contract_End;       
       knockToUpsert.Activity__c = knock.activity;
       knockToUpsert.Call_Date__c = knock.call_Date;
       knockToUpsert.Number_Called__c = knock.number_Called;
       knockToUpsert.Purpose_Of_The_Call__c = knock.purpose_Of_The_Call;
       knockToUpsert.Resident_Called__c = knock.resident_Called;
       knockToUpsert.ActivityDate = knock.activityDate;
      try {
              upsert knockToUpsert  Knock_External_Id__c;
              rValue.success = true;
              rValue.knockId = knockToUpsert.Id;              
        }catch(DMLException ex) {
              rValue.success = false;
              System.debug('Following exception occurred :'+ex.getMessage());
              return rValue;
        }
        
        return rValue;
       }

    global class KnockObject {

       global String description;
       global String disposition;
       global String event_Category;
       global String event_Name_or_Number;
       global Integer hsi_Sold;
       global String home_Security_Competitor;
       global String internet_Competitor;
       global DateTime knocked_Date;
       global Date internet_Contract_End; 
       global Date video_Contract_End; 
       global Date phone_Contract_End; 
       global Date security_Contract_End;
       global String non_Marketable_Reason;
       global String ownerId;
       global String phone_Competitor;
       global String priority;
       global String recordTypeId;               
       global String rejected_Reason;
       global Integer rejected;
       global String sales_Type;
       global String status;
       global String subject;
       global String type;
       global String video_Competitor;
       global Integer video_Sold;
       global Integer voice_Sold;
       global String whatId;
       global Integer xh_Sold;
       global String activity;       
       global DateTime call_Date;
       global String number_Called;
       global String purpose_Of_The_Call;
       global String resident_Called;       
       global String uniqueId;
       global Date activityDate;
       global Date vacantFollowUp_Date;
       global String property_Event;
    }
     global class returnValues {

       global Boolean success;
       global String knockId;

    }
}