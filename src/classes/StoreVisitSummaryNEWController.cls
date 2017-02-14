/**
*   Controller extension for inline visit summary page and emailing summary
*   @author Shivani Gautam
*/
public with sharing class StoreVisitSummaryNEWController {
     public Boolean popupFlag {get;set;} 
     public Boolean displayPopup {get;set;}
     public static String strvisitId{get;set;} 
     public static ApexPage  vfPage{get;set;}
     public StoreVisitSummary VisitSummary {get; private set;}
     public Id visitId;
     public Store_Visit__c visit {get;set;}
     public static Date endDate;
     public static String endDay;
     public static String endMonth;
     public static Integer endYear;
     public static String finalEndDate;
     public static Date startDate;
     public static String startDay;
     public static String startMonth;
     public static Integer startYear;
     public static String finalStartDate;
     public static String[] sendingTo;   
     public static String body;   
     public static String subject;     
     public static Map<String,String> activityNotesMap;
     
    public StoreVisitSummaryNEWController (ApexPages.StandardController stdController) {
        visitId = stdController.getId();
        visit = new Store_Visit__c ();
        if(visitId!=null){
            visit = StoreQueryUtility.queryStoreVisit(visitId);
            strvisitId=visitId;
        }
        Account store;
        
        List<Store_Visit_Activity_Category__c> activityCategories; 
        if(visit.Store__c == null){
            store = null;
        }
        else {
            store = StoreQueryUtility.queryStore(visit.Store__c);
        }
        List<Store_Activity__c> activities = StoreQueryUtility.queryStoreActivities(visitId);
        User visitOwner = StoreQueryUtility.queryUser(visit.OwnerId);
        UserRole role = StoreQueryUtility.queryUserRole(visitOwner.UserRoleId);
        
        if(store == null) {
            activityCategories = StoreQueryUtility.queryActivityCategories('Prospect', role.DeveloperName);
        }
        else{
            activityCategories = StoreQueryUtility.queryActivityCategories(store.Store_Type__c, role.DeveloperName);
        }

        RequiredStoreActivityBuilder requiredActivityBuilder = new RequiredStoreActivityBuilder(activityCategories);
        List<RequiredStoreActivity> requiredActivities = requiredActivityBuilder.buildRequiredStoreActivities(activities);
        List<Task> visitTasks = StoreQueryUtility.queryVisitTasks(visitId );
        if(store == null) {
            this.VisitSummary = new ProspectiveStoreVisitSummary(visit, requiredActivities);
        }
        else {
            this.VisitSummary = new StoreVisitSummary(store, visit, requiredActivities, visitTasks);
        }
    }
    
    /**
    * @Description: This method will send email on auto checkout of store visit
    * @UserStory: US764794(Indirect: Email notification for visit completed automatically end of the day)
    * @Author: Mandeep Singh, Accenture
    * @Date: 24-Aug-2016
    * @Return: void.
    */
    public static void automaticEmailAtMidnight(List<Store_Visit__c> storeVisits){
        for(Store_Visit__c visit : storeVisits){
            if(visit.End_Date_Time__c == visit.visit_cutoff_datetime__c || visit.Is_Auto_Check_Out__c == true){
                strvisitId = visit.id;
                ResendEmail();
            }
        }     
    }
    
    public static void ResendEmail(){
        //User repuser = [SELECT id, name ,email ,UserRole.DeveloperName, managerid , manager.email FROM user WHERE id=:userinfo.getuserid()];
        
        //String userRole = repuser.UserRole.DeveloperName;             
                        
        Store_Visit__c stores = [SELECT id,name,Store__c,Store_Address__c, Title__c, End_Date_Time__c,Owner_Full_Name__c,Visit_Type__c,Start_Date_Time__c,Notes__c,Store_Visit_Status__c, OwnerID, Owner.Email, Owner.UserRole.DeveloperName from Store_Visit__c 
                                 WHERE ID =:strvisitId]; 
                                 
        User repuser = [SELECT id, name ,email ,UserRole.DeveloperName, managerid , manager.email FROM user 
                        WHERE id=:stores.OwnerId];
        String userRole = repuser.UserRole.DeveloperName; 
        
        String owner = stores.Owner_Full_Name__c;
        String address=stores.Store_Address__c;
        string notes= (stores.notes__c != null ? stores.notes__c : '');
        string title = ((stores.Title__c != null) || (stores.Title__c == '')) ? 'Title: '+ stores.Title__c +'\n': '';
        Datetime endDateTime = (stores.End_Date_Time__c !=null ?stores.End_Date_Time__c :null);
        String summaryNotes = notes.replace('\r\n', '<br/>');   
            if(endDateTime!=null){
            /*endDate = date.newinstance(endDateTime.year(), endDateTime.month(), endDateTime.day());
            endDay = string.valueof(endDate.day());
            endMonth = string.valueof(endDate.month());
            endYear = endDate.year();    
                    if(endDay.length()==1){endDay ='0'+endDay;}
                    if(endMonth.length()==1){endMonth = '0' + endMonth;}        
            finalEndDate = endMonth +'/'+endDay+'/'+endYear ; */
            finalEndDate = endDateTime.format('MM/dd/yyyy h:mm a');
            }
            else{finalEndDate=' ';}
            
        Datetime startDateTime = (stores.Start_Date_Time__c !=null ?stores.Start_Date_Time__c :null);
            
            if(startDateTime!=null){
            /*startDate = date.newinstance(startDateTime.year(), startDateTime.month(), startDateTime.day());
            startDay = string.valueof(startDate.day());
            startMonth = string.valueof(startDate.month());
            startYear = startDate.year();    
                    if(startDay.length()==1){startDay ='0'+startDay;}
                    if(startMonth.length()==1){startMonth = '0' + startMonth;}        
            finalStartDate = startMonth +'/'+startDay+'/'+startYear ;*/
            finalStartDate = startDateTime.format('MM/dd/yyyy h:mm a');
            }
            else{finalStartDate=' ';}
            
            if(stores.store__c==null && stores.Store_Visit_Status__c == 'Complete'){
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                if(repuser.managerid == null){
                    sendingTo = new String[]{repuser.email};
                }                 
                else{
                    sendingTo = new String[]{repuser.email,repuser.manager.email};
                }
                
                semail.setToAddresses(sendingTo);
                subject = 'Visit Completion -' + ' ' + owner ;  
                semail.setSubject(subject);

                String Visit =(stores.Visit_Type__c!= null ? stores.Visit_Type__c: '');
                    if(Visit == 'Prospect'){Visit = 'Prospect Visit';}

                body = 'Please find a summary of the recent visit completed by' + ' ' +  owner +  +'\n\n'+ 
                    'Start Date/Time of Visit:'+ ' ' + finalStartDate  + '\n' +
                    'End Date/Time of Visit:'+ ' ' + finalEndDate  + '\n' +
                    'Type of Visit:'+ ' '+ Visit + '\n' + title +
                    'Notes:' + ' ' +summaryNotes;        
                semail.setPlainTextBody(body);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
            }
                           
            else if(stores.store__c!=null && stores.Store_Visit_Status__c == 'Complete'){
            
            List<Account> storeDetailList =[SELECT Name,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,Store_Type__c FROM Account
                                  WHERE recordtype.name='store' AND id =: stores.Store__c];              
            Account storeDetail;
            String storeType;
                if(storeDetailList != null && storeDetailList.size() > 0){
                    storeDetail = storeDetailList.get(0);
                    storeType = storeDetail.Store_Type__c;
                                             
                    List<Store_Activity__c> StoreActivityList = [SELECT Id, Name ,Activity_Type__c,Is_Activity_Completed_New__c,RecordTypeId,Store_Type__c,Notes__c         
                                                                 FROM Store_Activity__c WHERE Store_Visit__c =:stores.Id 
                                                                 AND Is_Activity_Completed_New__c= true ORDER BY CreatedDate];   
                         
                         activityNotesMap = new Map<String,String>();
                         
                        for(Store_Activity__c storeActivityObj: StoreActivityList){
                            if(storeActivityObj.Activity_Type__c !=null ){
                                body += storeActivityObj.Activity_Type__c+' ';
                                activityNotesMap.put(storeActivityObj.Activity_Type__c,storeActivityObj.Notes__c);
                            }
                        }                                                                           
                    List<Store_Visit_Activity_Category__c>  categories=  [SELECT Id, Number_Required__c,Record_Type_Name__c,Record_Type_Id__c, Store_Activity_Category__c,New_Records__c FROM Store_Visit_Activity_Category__c
                                                                 WHERE Store_Type__c = :storeType  AND User_Role__c =: userRole  AND New_Records__c = true
                                                                 ORDER BY Number_Required__c DESC];     
                                                                   
            EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate 
                                           WHERE Name = 'Send Summary Email Template'];
                    
                    String storeName = storeDetail.Name;                       
                    String billingStreet = storeDetail.BillingStreet;
                    String billingCity = storeDetail.BillingCity;
                    String billingState = storeDetail.BillingState;
                    String billingPostalCode = storeDetail.BillingPostalCode;
                    String billingCountry = storeDetail.BillingCountry;
                    List<String> mailBodyString = new List<String>();
                    Integer x=0;
                    Integer y;
                    Integer z;
                    String crossUniCode = '\u2718';
                    String tickUniCode = '\u2714';
                    String nbspUniCode = '&nbsp;';
                    String openTableTag = '<table>';
                    String closeTableTag = '</table>';
                    String openTrTag = '<tr>';
                    String closeTrTag = '</tr>';
                    String openTdTag1 = '<td valign="top">';
                    String openTdTag2 = '<td valign="top">';
                    String closeTdTag = '</td>';
                    String activityNotes = '';
                    String storeVisitNotes = '';
                    String mailBody = openTableTag;
            
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            
            
            for(Store_Visit_Activity_Category__c activity:categories){
                if(body != null){
                    Boolean result=body.contains(activity.Store_Activity_Category__c);
                    if(result == false){
                        mailBodyString.add('\u25CB'+ ' ' + activity.Store_Activity_Category__c);
                        mailBodyString.add(' ');
                    }
                    else{
                        mailBodyString.add(tickUniCode + ' ' + activity.Store_Activity_Category__c);
                        for(String s : activityNotesMap.keySet()){
                            if(s == activity.Store_Activity_Category__c){
                                if(activityNotesMap.get(s) != null && activityNotesMap.get(s) != ''){
                                     activityNotes = activityNotesMap.get(s).replace('\r\n', '<br/>');
                                     mailBodyString.add('<tr><td style="padding-left:10px" valign="top" width="17%">' +activity.Store_Activity_Category__c + ' Notes: ' + '</td>' +
                                                  '<td valign="top" width="83%">'+ ' ' +activityNotes+'</td></tr>');
                              }
                                else{
                                    mailBodyString.add(' ');
                                }
                            }
                        }
                    }
                }
                else{
                    mailBodyString.add('\u25CB'+ ' '+activity.Store_Activity_Category__c);
                    mailBodyString.add(' ');
                }
            }
                        
              
            for(String mails :mailBodyString){
                y = x/2;
                z = y * 2;
                If(z == x){
                    mailBody += openTrTag + openTdTag1 + mails + nbspUniCode + nbspUniCode + closeTdTag + closeTrTag;
                    x++;
                }
                else{
                    mailBody +=  openTdTag2 + mails + closeTdTag + closeTrTag;
                    mailBody += openTrTag + openTdTag1 + nbspUniCode + closeTdTag + openTdTag2 + nbspUniCode + closeTdTag + closeTrTag;
                    x++;
                }
            
            }
              mailBody += closeTableTag;      
              
            //Date myDate = date.newinstance(endDate.year(), endDate.month(), endDate.day());
            //String finalEndDate = mt+'/'+dy+'/'+yr;
            if(notes != null && notes != ''){
                storeVisitNotes = notes.replace('\r\n', '<br/>');
            }
            Map<String, String> ParameterBodyMap = new Map<String, String> {           
                '{!Store_Visit__c.OwnerFullName}' => owner,
                '{!Store_Visit__c.Store_Name__c}' => storeName,
                'billingStreet' => billingStreet,
                'billingCity' => billingCity,
                'billingState' => billingState,
                'billingPostalCode' => billingPostalCode,
                'billingCountry' => billingCountry,
                '{!Store_Visit__c.End_Date_Time__c}' => finalEndDate  ,  
                '{!Store_Visit__c.Notes__c}'=>storeVisitNotes ,
                '{!myCustomString}' => mailBody
            };
     
              
                  
            if(repuser.Manager.Email != null){           
                sendingTo = new String[]{repuser.Email,repuser.Manager.Email};
            }
            else{
                sendingTo = new String[]{repuser.Email};       
            }          
            mail.setToAddresses(sendingTo);
                                  
            subject = emailTemplate.Subject;
                if(owner != null){
                    subject = subject.replace('{!Store_Visit__c.OwnerFullName}', owner);
                }else{
                    subject = subject.replace('{!Store_Visit__c.OwnerFullName}', ' ');
                }
              
            mail.setSubject(subject);
                
            String htmlBody = emailTemplate.HtmlValue;
                for (String key : ParameterBodyMap.keySet()){
                    htmlBody = htmlBody.replace(key, (ParameterBodyMap.get(key) == null) ? '' : ParameterBodyMap.get(key));   
                }
            mail.setHtmlBody(htmlBody);
            mail.setSaveAsActivity(false);

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                } 
            }   
            else{
                ApexPages.Message apexMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Mail cannot be sent for active store Visits');
                ApexPages.addMessage(apexMessage);
            }      
    }          
}