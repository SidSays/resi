public with Sharing class IndirectStoreController {
    
    @AuraEnabled
    public static UserDetails  getAllUserData(){       
        List<Event> hisEvents = new List<Event>();
        List<Event> upcommingEvents = new List<Event>();
        User loggedInUser = [SELECT id, Name,Email, ManagerId,Sales_Rep_Type__c, Manager.Name,Manager.Email, Profile_Name_Text__c FROM User WHERE id =:UserInfo.getUserId()]; // added Sales_Rep_Type__c for US734514
        Map<Id,Account> hisStores = new Map<Id,Account>([SELECT Id, Name,AccountNumber,Store_Nickname__c,Required_Visit_Frequency_Days__c,
                                   In_Store_Competitors__c,Parent_Account_Dropdown__c,Visit_By_Date__c,
                                   BillingStreet,BillingCity,BillingState,Monthly_RGU_Order_Goal__c,Monthly_RGU_Activations_Goal__c,
                                   BillingPostalCode,BillingCountry,Billing_Address__c,Store_Visit_Status__c, Last_Visit_Date__c,Store_Type__c,Region__c,Owner.Name,Is_Parent_Store__c,
                                   Store_Location__Latitude__s,Store_Location__Longitude__s , Phone, Parent.Name,Store_Designation__c, Last_Visit_Date_Text__c  
                                    FROM Account WHERE OwnerId =:loggedInUser.Id AND RecordType.Name= 'Store' ORDER BY Name]);
        
        List<Event> hisVisits = [SELECT id, Subject, StartDateTime, EndDateTime,What.Name, Visit_Start_Date_And_Duration__c
                                 FROM Event WHERE OwnerId =:loggedInUser.Id AND 
                                 StartDateTime >= TODAY ORDER BY StartDateTime];
        for(Event evt : hisVisits){
            if(evt.WhatId != null){
                hisEvents.add(evt);
            } else{
                Date startDate = evt.StartDateTime.date();
                if( startDate.daysBetween(System.Today()) == 0 || startDate.daysBetween(System.Today()) == -1){
                    upcommingEvents.add(evt); 
                }                
            }
        }
        
        UserRole role = StoreQueryUtilityLight.queryUserRole(UserInfo.getUserRoleId());
        return (new UserDetails(loggedInUser,hisStores,hisEvents,upcommingEvents,role));
    }
    
    @AuraEnabled
    public static CacheDetails setCachedData(String bodyToRender, String storeId, 
                                             List<Store_Visit_Activity_Category__c> categories, String emailSummary, String storeActivityCatagory, String activityId, String currentButtonValue){      
        String concateString = null;
        CacheDetails cacheDetails = new CacheDetails(bodyToRender);
        
        if(storeId != null){
            cacheDetails.storeId = storeId;
        }
                                                 
        if(emailSummary != null){
            cacheDetails.emailSummary = emailSummary;
        }                                         

        if(storeActivityCatagory != null){
            cacheDetails.storeActivityCatagory = storeActivityCatagory;
        } 
        
        if(activityId != null){
            cacheDetails.activityId = activityId;
        } 
        
        if(currentButtonValue != null){
            cacheDetails.currentButtonValue = currentButtonValue;
        } 
        
        if(categories != null){
            cacheDetails.categories = categories;
        }
                                                 
        Cache.Session.put('cacheDetails', cacheDetails);        
        return (CacheDetails)Cache.Session.get('cacheDetails');
    }
    
    @AuraEnabled
    public static CacheDetails getCachedData() {
        if (!Cache.Session.contains('cacheDetails')) {
            CacheDetails cacheDetails = new CacheDetails('visits');
            Cache.Session.put('cacheDetails', cacheDetails);
        }    
        return (CacheDetails) Cache.Session.get('cacheDetails');
    }
    
    public class CacheDetails{
        @AuraEnabled
        public String bodyToRender;
        @AuraEnabled
        public String storeId;
        @AuraEnabled
        public List<Store_Visit_Activity_Category__c> categories; 
        @AuraEnabled
        public String emailSummary; 
        @AuraEnabled
        public String storeActivityCatagory;
        @AuraEnabled
        public String activityId;
        @AuraEnabled
        public String currentButtonValue;
        
        public CacheDetails(String bodyToRender){
            this.bodyToRender = bodyToRender;
        }
    }
        
    public class UserDetails{
        @AuraEnabled
        public User loggedInUser;
        @AuraEnabled
        public Map<Id,Account> assignedStores;
        @AuraEnabled
        public List<Event> scheduledEvents;
        @AuraEnabled
        public List<Event> upcomingEvents;
        @AuraEnabled
        public UserRole userRole;
        
        public UserDetails(User loggedInUser, Map<Id,Account> assignedStores, List<Event> scheduledEvents, 
                           List<Event> upcomingEvents, UserRole userRole){
            this.loggedInUser = loggedInUser;
            this.assignedStores = assignedStores;
            this.scheduledEvents = scheduledEvents;
            this.upcomingEvents = upcomingEvents;
            this.userRole = userRole;
        }
    }
    
    /*
    @AuraEnabled
    public static Account getRelatedStore(String storeId) {
        if(storeId != null){
            return [SELECT id, Name,AccountNumber,Store_Nickname__c,Required_Visit_Frequency_Days__c,
                    In_Store_Competitors__c,Parent_Account_Dropdown__c,Visit_By_Date__c,
                    BillingStreet,BillingCity,BillingState,Monthly_RGU_Order_Goal__c,Monthly_RGU_Activations_Goal__c,
                    BillingPostalCode,BillingCountry,Billing_Address__c, Last_Visit_Date__c,Store_Type__c,Region__c,Owner.Name,Is_Parent_Store__c,
                    Store_Location__Latitude__s,Store_Location__Longitude__s , Phone, Parent.Name,Store_Designation__c, Last_Visit_Date_Text__c  
                    FROM Account WHERE Id =:storeId];
        } else{
            return null;
        }
    }*/
    
    @AuraEnabled
    public static Event saveEvent(String subject,DateTime startDateTime,String whatId) {
        Event newEvents=new Event(); 
        integer EndDateTimeaddHours=integer.valueof(Label.SheduleVisitEndDateDiffrence);
        newEvents.Subject=subject;
        newEvents.StartDateTime=startDateTime;
        newEvents.EndDateTime=startDateTime.addHours(EndDateTimeaddHours);
        newEvents.WhatId=whatId;
        insert newEvents;
        return newEvents;
    }
    @AuraEnabled
    public static Event deleteEventObj(Event eventObj){
        try{
            delete eventObj;                   
            return eventObj;
        }
        catch(DmlException ex){
            System.debug(ex.getMessage());             
            return null;
        }
    }
    @AuraEnabled
    public static UserRole getRole() {
        UserRole role = StoreQueryUtilityLight.queryUserRole(UserInfo.getUserRoleId());
        return role;
    }
    
  /*  @AuraEnabled
    public static List<Store_Activity__c> getCompletedActivities(String storeVisitId ){
        List<Store_Activity__c> StoreActivityList = [Select Id, Name ,Activity_Type__c,Is_Activity_Completed__c From Store_Activity__c where Store_Visit__c =:storeVisitId And Is_Activity_Completed__c = true ORDER BY CreatedDate];
        return StoreActivityList;
    }*/
    
    @AuraEnabled
    public static List<String> getRecommendedCategories(Account store, UserRole role)
    {
        Id userId = UserInfo.getUserId();
        List<Store_Visit_Activity_Category__c> ctList =[SELECT Id, Number_Required__c,Record_Type_Name__c,
                                                        Store_Activity_Category__c, Email_Template__c,
                                                        Send_Mail_Check_Field__c, Store_Type__c,New_Records__c,
                                                        Lookup_field_value__c
                                                        FROM Store_Visit_Activity_Category__c
                                                        WHERE Store_Type__c = :store.Store_Type__c 
                                                        AND User_Role__c = :role.DeveloperName
                                                        AND Number_Required__c > 0];
        List<RecordType> recordTypes = StoreQueryUtilityLight.queryRecordTypes('Store_Activity__c');
        Map<String, RecordType> activityRecordTypeMap = StoreVisitUtility.buildRecordTypeNameMap(recordTypes);
        List<String> recordTypeList = new List<String>();
        for(Store_Visit_Activity_Category__c ct: ctList){
            recordTypeList.add(activityRecordTypeMap.get(ct.Record_Type_Name__c).Id);               
        }
        Store_Visit__c storeVisit = [Select Id from Store_visit__c where store__c =:store.Id AND Store_Visit_Status__c = 'Active' 
                                     AND OwnerId = :userId ORDER BY LastModifiedDate DESC LIMIT 1];
        List<Store_Activity__c> storeActList =  [Select Id, Name,Store_Visit__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName,
                                                 Store_Type__c,Is_Activity_Completed__c from Store_Activity__c where  Store_Visit__c = :storeVisit.Id 
                                                 and recordTypeId In :recordTypeList];
        integer size = storeActList.size();
        List<String> inCompletedAct = new List<String>();
        for(Store_Visit_Activity_Category__c ct: ctList){
            inCompletedAct.add(ct.Store_Activity_Category__c);
            for(integer i=0; i<size ; i++){ 
                if(storeActList[i].recordTypeId == activityRecordTypeMap.get(ct.Record_Type_Name__c).Id  && storeActList[i].Is_Activity_Completed__c == true){
                    inCompletedAct.remove(i);
                }
            }
        } 
        return inCompletedAct;
        
    }
   
       
  /*   @AuraEnabled
    public static String sendMailToUser( User userDetail, String storeId, String storeAddress, Store_Visit__c storeVisitDetail, List<Store_Activity__c> storeActivityDetailList ){
    
        Account updatedStore = [SELECT id, Name,AccountNumber,Store_Nickname__c,Required_Visit_Frequency_Days__c,
                                   In_Store_Competitors__c,Parent_Account_Dropdown__c,Visit_By_Date__c,
                                   BillingStreet,BillingCity,BillingState,Monthly_RGU_Order_Goal__c,Monthly_RGU_Activations_Goal__c,
                                   BillingPostalCode,BillingCountry,Billing_Address__c, Last_Visit_Date__c,Store_Type__c,Region__c,Owner.Name,Is_Parent_Store__c,
                                   Store_Location__Latitude__s,Store_Location__Longitude__s , Phone, Parent.Name,Store_Designation__c, Last_Visit_Date_Text__c  
                                   FROM Account where Id = :storeId];
        String[] sendingTo = null;
        String subject = '';
        String body = '';
        String finaldate;
        List<String> addressList = storeAddress.split(',');
        
        Datetime dateOfVisit = storeVisitDetail.Start_Date_Time__c ;
        if(dateOfVisit != null){
            Date myDate = date.newinstance(dateOfVisit.year(), dateOfVisit.month(), dateOfVisit.day());
            String dy = string.valueof(myDate.day());
            String mnt = string.valueof(myDate.month());
            String yr = string.valueof(myDate.year());                        
            if(dy.length()==1)
            {
                dy ='0'+dy;
            }
            
            if(mnt.length()==1){
                mnt = '0' + mnt ;
            }
              
            finaldate = mnt +'/'+dy+'/'+yr ;
        }
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        if(userDetail.Manager.Email != null){           
           // sendingTo = new String[]{userDetail.Email,userDetail.Manager.Email};
        }else{
           // sendingTo = new String[]{userDetail.Email};       
        }        
        //semail.setToAddresses(sendingTo);
        
        subject = 'Visit Completion -' + ' ' + userDetail.Name ;         
        //semail.setSubject(subject);
        
        body = 'Please find a summary of the recent store visit completed by ' + userDetail.Name +'\n\n'+
               'Date of Visit: '+ finaldate + '\n' +
               'Type of Visit: Store Visit\n';              
        
        body += 'Store Name: ';
        if(updatedStore.Name !=''){
            body += updatedStore.Name +'\n';
        }
        
        body += 'Address of Store: ';
        if(addressList[0] != 'undefined'){ 
            body += ''+ addressList[0] ;
        }
           body +='\n';
        
        if(addressList[1] != 'undefined'){ 
            body += '\t\t    '+ addressList[1] +', ';
        }else{
            body += '\t\t    ';
        }
        
        if(addressList[2] != 'undefined'){ 
            body += addressList[2] +' ';
        }
        if(addressList[3] != 'undefined'){ 
            body += + addressList[3];
        }
            body +='\n';
        
        if(addressList[4] != 'undefined'){ 
            body += '\t\t    '+ addressList[4];
        }
     
        //Code for Activity Completed
        body += '\n Activities Completed:\n';
        
        for(Store_Activity__c storeActivityObj: storeActivityDetailList){
            if(storeActivityObj.Activity_Type__c !=null ){
                body += '  \u2022'+storeActivityObj.Activity_Type__c+'\n';
            }
        }
        
        if(storeVisitDetail.Time_Spent__c !=''){
            body += 'Time Spent During Visit: '+ storeVisitDetail.Time_Spent__c +'\n';
        }
        
        body += 'Notes: ';
        if(storeVisitDetail.Notes__c == null){
            
        }else{
            body += storeVisitDetail.Notes__c;
        }
        
        //semail.setPlainTextBody(body);
        semail.setTemplateId('00Xq0000000EGan');
         sendingTo = new String[]{'005q0000002FV0u','005q00000026Zjq'};
        semail.setTargetObjectId('005q0000002FV0u'); 
        semail.setSaveAsActivity(false);
       
      //  Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
        
        String successMsg = 'Successfully Mail Sent';
        
        return updatedStore.Id;
   
    }*/
    
    @AuraEnabled
    public static Store_Visit__c queryActiveStoreVisit(Id storeId, User loggedInUser) {
       
            Store_Visit__c oldVisit =[SELECT Id, Store__c, Start_Date_Time__c, End_Date_Time__c, Notes__c,
                                      OwnerId, Prospect_Store_Name__c,Time_Spent__c, Owner.Name,
                                      Visit_Type__c 
                                      FROM Store_Visit__c
                                      WHERE Store__c = :storeId 
                                      AND OwnerId = :loggedInUser.Id
                                      Order by LastModifiedDate Desc
                                      LIMIT 1];  
            return oldVisit;    
    }

    
    @AuraEnabled
    public static List<Store_Activity__c> getCompletedActivities(String storeVisitId){ 
        List<Store_Activity__c> StoreActivityList = [SELECT Id, Name ,Activity_Type__c,Notes__c,Is_Activity_Completed_New__c 
                                                     FROM Store_Activity__c WHERE Store_Visit__c =:storeVisitId 
                                                     AND Is_Activity_Completed_New__c = true ORDER BY CreatedDate];        
        return StoreActivityList;
    }
    
    
    /* Method to get contact list */
    @AuraEnabled
    public static List<IndirectContactWrapper> getContacts(String storeId){
         List<IndirectContactWrapper> contactWrapList = new List<IndirectContactWrapper>();         
         for(Contact contactObj : [Select Id, Name, Type__c,  Email, Phone from Contact where AccountId =:storeId AND Active__c=true ORDER BY createddate DESC] ){             
             contactWrapList.add(new IndirectContactWrapper(contactObj));
         }
         return contactWrapList;    
    }
    
    //Wrapper class for sending email to contact list
    public class IndirectContactWrapper {
    
        @AuraEnabled
        public boolean checked{get; set;}
        @AuraEnabled
        public Contact contactObj{get; set;}
        
        public IndirectContactWrapper(Contact con){
            contactObj = con;
            checked = false;
        }
    }
    
    /* Method to send summary details to selected contactList */
    @AuraEnabled
    public static void getContactsWrap(List<Contact> checkedContactList,Store_Visit__c 
                                        StoreVisit,List<Store_Visit_Activity_Category__c> categories, Account storeDetail){
         
         List<String> sendTo = new List<String>();                                    
         List<Store_Activity__c> StoreActivityList = [SELECT Id, Name ,Activity_Type__c,Is_Activity_Completed_New__c,
                                                     RecordTypeId         
                                                     FROM Store_Activity__c WHERE Store_Visit__c =:StoreVisit.Id 
                                                     AND Is_Activity_Completed_New__c= true ORDER BY CreatedDate];
         //Sending the mail to selected contact 
        for(Contact cont : checkedContactList){
            if(cont.Email != null){
                sendTo.add(cont.Email);                   
            }             
        }        
        IndirectStore.sendEmail(StoreVisit,categories,storeDetail,sendTo,StoreActivityList);
          
    }
    
   /*Method to insert record in Activity_Contacts__c junction object*/
    @AuraEnabled
    public static void insertActivityContact(List<Contact> checkedContactList, List<Contact> uncheckedContactList, String activityId, String lookupFieldValue){
        
        List<Activity_Contacts__c> activityContactList = new List<Activity_Contacts__c>();
        List<Activity_Contacts__c> toBeDelActivityCont = new List<Activity_Contacts__c>();
        Map<String,Activity_Contacts__c> checkForActivityContMap = new Map<String,Activity_Contacts__c>();      
        List<String> stringList = new List<String>();
     
        for(Activity_Contacts__c activityContactObj : [SELECT Contact__c, Store_Activity__c, Type_of_contact__c, ActivityIdContact__c FROM Activity_Contacts__c WHERE Store_Activity__c =:activityId]){
            checkForActivityContMap.put(activityContactObj.ActivityIdContact__c, activityContactObj);
        }
        
        //Logic for delete and update Activity Contact
        for(Contact contObj :uncheckedContactList){
            Activity_Contacts__c actContObj = null;
            String newString = null;
            String activityContString = activityId + contObj.Id;
            if(checkForActivityContMap.containsKey(activityContString)){
                actContObj = checkForActivityContMap.get(activityContString);               
                if(actContObj.Type_of_contact__c != null){
                    if(actContObj.Type_of_contact__c == lookupFieldValue){
                        toBeDelActivityCont.add(actContObj);
                    }else if(actContObj.Type_of_contact__c.contains(';') && actContObj.Type_of_contact__c.contains(lookupFieldValue)){
                        //Logic to recalculate the Multipicklist value
                        stringList = actContObj.Type_of_contact__c.split(';');                  
                        if(!stringList.isEmpty()){
                            for(Integer i=0; i<stringList.size(); i++){
                                if( stringList.get(i)==lookupFieldValue){
                                    stringList.remove(i);
                                    break;
                                }
                            }                       
                        }
                        
                        if(stringList.size() == 1){
                            actContObj.Type_of_contact__c = stringList.get(0);
                        }else if(stringList.size() > 1){
                            newString = stringList.get(0);
                            for(Integer i=1; i<stringList.size(); i++){                             
                                newString = newString + ';' + stringList.get(i);
                            }
                            actContObj.Type_of_contact__c = newString;
                        }
                        activityContactList.add(actContObj);
                    }                   
                }
            }
        }
       
        if(!toBeDelActivityCont.isEmpty()){
            database.delete(toBeDelActivityCont,false);
        }
        
        //Logic for upsert Activity Contact
        for( Contact contObj: checkedContactList){
            Activity_Contacts__c actContObj = null;
            String activityContString = activityId + contObj.Id;
            if(checkForActivityContMap.containsKey(activityContString)){
                actContObj = checkForActivityContMap.get(activityContString);
                if(actContObj.Type_of_contact__c != null){
                    if(!actContObj.Type_of_contact__c.contains(lookupFieldValue)){
                        actContObj.Type_of_contact__c = actContObj.Type_of_contact__c + ';' +lookupFieldValue; 
                    }
                }               
            }else{          
                actContObj = new Activity_Contacts__c();
                actContObj.Contact__c = contObj.Id;
                actContObj.Store_Activity__c = activityId;
                actContObj.ActivityIdContact__c = activityContString;
                actContObj.Type_of_contact__c = lookupFieldValue;                       
            }
            activityContactList.add(actContObj);
        }
        
        if(!activityContactList.isEmpty()){
            database.upsert(activityContactList,false);
        }else{}
        
        
    }
    
     /* Method to get contact list */
    @AuraEnabled
    public static List<ContactActivityWrapper> getContactsWithActivity(String storeId, String activityId, String lookupFieldValue){
        
        List<ContactActivityWrapper> contactWrapList = new List<ContactActivityWrapper>(); 
        List<Contact> contactList = [Select Id, Name, Type__c,  Email, Phone from Contact where AccountId =:storeId AND Active__c=true ORDER BY Name];
        Set<String> conIdSet = new Set<String>();
        
        for(Activity_Contacts__c activityContact : [SELECT Contact__c, Type_of_contact__c, Store_Activity__c, ActivityIdContact__c FROM Activity_Contacts__c WHERE Store_Activity__c =:activityId]){
            if(activityContact.Type_of_contact__c != null && activityContact.Type_of_contact__c.contains(lookupFieldValue)){
                conIdSet.add(activityContact.Contact__c);
            }   
        } 
         
         for(Contact contObj : contactList ){
             ContactActivityWrapper conActWrap = new ContactActivityWrapper();
             conActWrap.contactObj = contObj;
             if(!conIdSet.isEmpty() && conIdSet.contains(contObj.Id)){
                 conActWrap.checked = true;
             }else{
                 conActWrap.checked = false;
             }
             contactWrapList.add(conActWrap);
         }
         
         return contactWrapList; 
        
    }
    
    //Wrapper class for sending email to contact list
    public class ContactActivityWrapper {
    
        @AuraEnabled
        public boolean checked{get; set;}
        @AuraEnabled
        public Contact contactObj{get; set;}
       
    }
}