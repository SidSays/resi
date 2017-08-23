public class IndirectOtherVisitsController {
    
    public static final string EVENT_VAL = 'Event';
    /*  Author     : Ashish
* Date       : 28-7-2016
* Description: To get the Status of the Visit
*/
    @AuraEnabled
    public static Store_Visit__c getVisitStatus(User usr){
        Store_Visit__c storeVisit = [SELECT Id,Name,Start_Date_Time__c,Visit_Type__c,Store_Visit_Status__c                                     
                                     FROM Store_Visit__c WHERE Visit_Type__c = 'Event' AND Store_Visit_Status__c = 'Active' AND OwnerId = :usr.Id LIMIT 1];
        if(storeVisit != null){
            return storeVisit;
        }
        else{
            return null;
        }
        
    }
    /*  Author     : Ashish
* Date       : 1-8-2016
* Description: To create an Event Visit
*/
    @AuraEnabled
    public static Store_Visit__c createEventVisit(Decimal lat,Decimal longi){
       
        try{
            Store_Visit__c storeVisit = [SELECT Id,Name,Start_Date_Time__c,Visit_Type__c,Store_Visit_Status__c
                                         FROM Store_Visit__c WHERE Visit_Type__c = 'Event' AND Store_Visit_Status__c = 'Active' AND OwnerId = :UserInfo.getUserId() LIMIT 1];
           
            storeVisit.Start_Location__Latitude__s = lat;
                storeVisit.Start_Location__Longitude__s = longi;
            update storeVisit;
            return storeVisit;
            
        }
            catch(QueryException ex){
                Store_Visit__c sv = new Store_Visit__c();
                sv.Start_Date_Time__c = System.now();
                sv.Visit_Type__c = 'Event';
                sv.Start_Location__Latitude__s = lat;
                sv.Start_Location__Longitude__s = longi;
                insert sv;
                return sv;
            }
        }
    
    /*  Author     : Ashish
* Date       : 1-8-2016
* Description: To save an Event Visit and send the email summary
*/
    @AuraEnabled
    public static String saveEventVisitAndSendEmail(String visitId,String notes, String title, Decimal lat,
                                                    Decimal longi,User repUser){
       
        String emailSummary ='';
        Store_Visit__c visit = [SELECT Name,Notes__c,Owner_Full_Name__c,Visit_Type__c,Title__c,
                                Store_Visit_Status__c,Start_Date_Time__c,End_Date_Time__c FROM Store_Visit__c WHERE Id =:visitId];        
            visit.Stop_Location__Latitude__s = lat;
            visit.Stop_Location__Longitude__s = longi;
            visit.Notes__c = notes;
            visit.Title__c = title;
            visit.Visit_Type__c = 'Event';
            visit.End_Date_Time__c = System.now(); 
            try{
                update visit;
                emailSummary = sendEmailSummary(visit,repUser,notes, title);
            } catch(DMLException ex){
                System.debug('Failure Reason : ' + ex.getMessage());
                return 'Error' + '##' + ex.getMessage().substringAfterLast(',').substringBefore('.');
            }
            return 'Success' + '##' + emailSummary;
    }
    
    /* Author     : Malay
     * Date       : 28-7-2016
     * Description: To save Prospect, Training and Other Visit and send email
     */
    @AuraEnabled
    public static String saveOtherVisitAndSendEmail(DateTime startDateTime, DateTime endDateTime, String notes,
                                                    Decimal lat, Decimal longi, String type, User repUser){
                                                        String emailSummary ='';
                                                        Store_Visit__c sv = new Store_Visit__c();
                                                        // Save Visit
                                                        sv.Start_Location__Latitude__s = lat;
                                                        sv.Start_Location__Longitude__s = longi;
                                                        sv.Stop_Location__Latitude__s = lat;
                                                        sv.Stop_Location__Longitude__s = longi;
                                                        sv.Notes__c = notes;
                                                        sv.Visit_Type__c = type;
                                                        sv.Start_Date_Time__c = startDateTime;
                                                        sv.End_Date_Time__c = endDateTime;  
                                                        
                                                        try{
                                                            insert sv; 
                                                            emailSummary = sendEmailSummary(sv,repUser,notes,'');  
                                                        } catch(DMLException ex){
                                                            System.debug('Failure Reason : ' + ex.getMessage());
                                                            return 'Error' + '##' + ex.getMessage().substringAfterLast(',').substringBefore('.');
                                                        }
                                                        return 'Success' + '##' + emailSummary;
                                                    }
    
    /*  Author     : Gafoor
* Date       : 21-7-2016
* Description: This method is for getting the picklist values of 'VisitType
*/  
    
    @AuraEnabled
    public static List<String> getVisitTypeValue(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult pickValue = Store_Visit__c.Visit_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = pickValue.getPicklistValues();
        for( Schema.PicklistEntry pickList : picklistValues)
        {
            options.add(pickList.getValue());
        }  
        return options;
    }
    
    /*  Author    : Gafoor
* Date       : 21-7-2016
* Description: This method is for getting the other visit details
*/ 
    
    @AuraEnabled
    public static List<StoreOtherVisitWrapper> getOtherVisitHistory(String selectedvisit, String loggedInUserId){
        if(selectedvisit == '')
        {
            selectedvisit = EVENT_VAL ;
        }
        List<StoreOtherVisitWrapper> otherVisitList = new List<StoreOtherVisitWrapper>();
        List<Store_Visit__c> otherStoreVisitList = [SELECT Id,Name,Notes__c,End_Date_Time__c,Store_Visit_Name__c,
                                                    Start_Date_Time__c, Title__c, Visit_Type__c FROM Store_Visit__c 
                                                    where store__c = null AND Visit_Type__c = :selectedvisit
                                                    AND Owner.Id = :loggedInUserId
                                                    AND Store_Visit_Status__c = 'Complete'
                                                    order by createdDate DESC];         
        for(Store_Visit__c osv : otherStoreVisitList){
            StoreOtherVisitWrapper obj = new StoreOtherVisitWrapper();
            obj.check = false;
            obj.stv = osv;
            otherVisitList.add(obj);
        }     
        
        return otherVisitList;
    }
    
   /* Author     : Ashish
    * Date       : 1-8-2016
    * Description: Helper method for sending email summary
    */
    @AuraEnabled
    public static String sendEmailSummary(Store_Visit__c sv, User repUser, String notes, String title){
        String emailSummary =''; 
        // Send Summary Email            
        sv = [SELECT Name,Store__c,End_Date_Time__c,Owner_Full_Name__c,Visit_Type__c,Start_Date_Time__c,Notes__c 
              FROM Store_Visit__c WHERE Id =:sv.Id];
        
        if(sv != null){
            String startDateStr ='';
            String endDateStr = '';
            String[] sendingTo;
            String summaryNotes = '';
            notes = sv.Notes__c != null ? sv.Notes__c: '';
            summaryNotes = notes.replace('\r\n', '<br/>');

            if(sv.End_Date_Time__c !=null){
                
                /*DateTime startDate = DateTime.newInstance(sv.Start_Date_Time__c.year(), sv.Start_Date_Time__c.month(), sv.Start_Date_Time__c.day(),sv.Start_Date_Time__c.hour());
                String dy = string.valueof(startDate.day());
                String mt = string.valueof(startDate.month());
                Integer yr = startDate.year(); 
                
                if(dy.length()==1){dy ='0'+dy;}
                if(mt.length()==1){mt = '0' + mt;}    
                
                startDateStr = mt +'/'+dy+'/'+yr ;*/
                startDateStr = sv.Start_Date_Time__c.format('MM/dd/yyyy h:mm a');
                endDateStr = sv.End_Date_Time__c.format('MM/dd/yyyy h:mm a');
            }
            
            Messaging.SingleEmailMessage sEmail = new Messaging.SingleEmailMessage();
            
            if(repUser.Managerid == null){
                sendingTo = new String[]{repUser.Email};
                    }                 
            else{
                sendingTo = new String[]{repuser.Email,repuser.Manager.Email};
                    }
            sEmail.setToAddresses(sendingTo);
            sEmail.setSubject('Visit Completion -' + ' ' + sv.Owner_Full_Name__c);
            String plainTitle = '';
            String htmlTitle = '';
            if(title != ''){
                plainTitle = 'Title:' + ' ' + title + '\n';
                htmlTitle  = 'Title:' + ' ' + title + '<br/>';
            } 
            
            emailSummary = 'Please find a summary of the recent visit completed by' + ' ' +  sv.Owner_Full_Name__c +  +'\n\n'+ 
                'Start Date/Time of Visit:'+ ' ' + startDateStr + '\n' +
                'End Date/Time of Visit:'+ ' ' + endDateStr + '\n' +
                'Type of Visit:'+ ' '+ sv.Visit_Type__c + '\n' + plainTitle + 
                'Notes:'+' ' +summaryNotes; 
            sEmail.setPlainTextBody(emailSummary);
            
            emailSummary = '<br/>Please find a summary of the recent visit completed by' + ' ' +  sv.Owner_Full_Name__c +  +'<br/><br/>'+ 
                'Start Date/Time of Visit:'+ ' ' + startDateStr + '<br/>' +
                'End Date/Time of Visit:'+ ' ' + endDateStr + '<br/>' +
                'Type of Visit:'+ ' '+ sv.Visit_Type__c + '<br/>' + htmlTitle +'<table><tr><td style="display:inline" valign="top" width="2%">'+
                'Notes:'+'</td>'+' ' +'<td style="padding-left:2px" width="98%">'+ ' '+summaryNotes+'</td></tr></table>';        
            sEmail.setHtmlBody(emailSummary);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sEmail});
        }
        return emailSummary;
    }
    /*  Author    : Gafoor
* Date       : 21-7-2016
* Description: This method is a wrapper class
*/ 
    
    public class StoreOtherVisitWrapper{
        @AuraEnabled
        public Store_Visit__c stv {get;set;}
        @AuraEnabled
        public Boolean check {get;set;}
    }
    
    @AuraEnabled
    public static String isAutoCompletedANDEmailSummary(String visitId,User repUser){
        String emailSummary = '';
        String isTrueString ='';
        Store_Visit__c autoCompleteVisit = [SELECT Name,Store__c,Is_Auto_Check_Out__c,End_Date_Time__c,Owner_Full_Name__c,Visit_Type__c,Start_Date_Time__c, 
                                            Title__c, Notes__c FROM Store_Visit__c WHERE Id =:visitId];
        
        String startDateStr ='';
        String endDateStr = '';
        String summaryNotes = '';
        String notes = autoCompleteVisit.Notes__c != null ? autoCompleteVisit.Notes__c: '';
        String title = ((autoCompleteVisit.Title__c != null) || (autoCompleteVisit.Title__c == '')) ? 'Title: '+ autoCompleteVisit.Title__c +'<br/>': '';
        summaryNotes = notes.replace('\r\n', '<br/>');
        if(autoCompleteVisit.End_Date_Time__c !=null){
            
            /*Date startDate = Date.newinstance(autoCompleteVisit.Start_Date_Time__c.year(), autoCompleteVisit.Start_Date_Time__c.month(), autoCompleteVisit.Start_Date_Time__c.day());
            String dy = string.valueof(startDate.day());
            String mt = string.valueof(startDate.month());
            Integer yr = startDate.year(); 
            
            if(dy.length()==1){dy ='0'+dy;}
            if(mt.length()==1){mt = '0' + mt;}    
            
            startDateStr = mt +'/'+dy+'/'+yr ;*/
            
            startDateStr = autoCompleteVisit.Start_Date_Time__c.format('MM/dd/yyyy h:mm a');
            endDateStr = autoCompleteVisit.End_Date_Time__c.format('MM/dd/yyyy h:mm a'); 
        }
            
        emailSummary = '<br/>Please find a summary of the recent visit completed by' + ' ' +  
                autoCompleteVisit.Owner_Full_Name__c +  +'<br/><br/>'+ 
                'Start Date/Time of Visit:'+ ' ' + startDateStr + '<br/>' +
                'End Date/Time of Visit:'+ ' ' + endDateStr + '<br/>' +
                'Type of Visit:'+ ' '+ autoCompleteVisit.Visit_Type__c + '<br/>'+ title + '<table><tr><td style="display:inline" valign="top" width="2%">'+
                'Notes:'+'</td>'+' ' +'<td style="padding-left:2px" width="98%">'+ ' '+summaryNotes+'</td></tr></table>';
        
        isTrueString = String.valueOf(autoCompleteVisit.Is_Auto_Check_Out__c);
        return isTrueString + '##' + emailSummary;      
        
    }
}