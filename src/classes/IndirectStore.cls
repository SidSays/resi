/**
* Controller for the Lightning StoreVisit page
*
* @author  Radhika Bansal
*/


public class IndirectStore {
    
   // @AuraEnabled 
   // public Boolean IsProspectVisit{get; set;}
    
    @AuraEnabled
    public static List<StoreVisitWrapper2> getStoreVisitWrapper2(List<Store_Visit_Activity_Category__c> categories){
        List<StoreVisitWrapper2> listOfWrapper = new List<StoreVisitWrapper2>();
        for(Store_Visit_Activity_Category__c ct: categories)
        {
            StoreVisitWrapper2 classObj = new StoreVisitWrapper2();
            classObj.check = false;
            classObj.stc = ct;
            //classObj.sta = Null;
            listOfWrapper.add(classObj);
        }
        return listOfWrapper;
    }
    
    // Class created to show control the toggle arrows properly on store visit page   
    public class StoreVisitWrapper2
    {
        @AuraEnabled
        public Boolean check {get;set;}        
        @AuraEnabled
        public Store_Visit_Activity_Category__c stc {get;set;}
        @AuraEnabled
        public Store_Activity__c sta {get;set;}
    }
    
    
    
    @AuraEnabled
    public static Store_Visit__c queryActiveStoreVisit(Id storeId, Decimal lat, Decimal longi) {
        Id userId = UserInfo.getUserId();
        try {
            Store_Visit__c oldVisit =[SELECT Id, Store__c, Start_Date_Time__c, End_Date_Time__c, Notes__c,
                                      OwnerId, Prospect_Store_Name__c,Time_Spent__c, Owner.Name,Owner_Full_Name__c,Store_Name__c,
                                      Visit_Type__c,Completed_all_required_activities__c
                                      FROM Store_Visit__c
                                      WHERE Store__c = :storeId 
                                      AND Store_Visit_Status__c = 'Active'
                                      AND OwnerId = :userId
                                      LIMIT 1];
            
            oldVisit.Start_Location__Latitude__s = lat;
            oldVisit.Start_Location__Longitude__s = longi;
            update oldVisit;
            return oldVisit;
            
        } catch (QueryException ex) {
           /* Store_visit__c obj = new Store_visit__c(Store__c = storeId);
            obj.Start_Date_Time__c = Datetime.now();
            obj.Start_Location__Latitude__s = lat;
            obj.Start_Location__Longitude__s = longi;
            obj.End_Date_Time__c = null;
            obj.RecordTypeId= Schema.SObjectType.Store_Visit__c.getRecordTypeInfosByName().get('Store Visit New').getRecordTypeId();
            insert obj;            
            return obj;*/
            Store_Visit__c oldCompletedVisit =[SELECT Id, Store__c, Start_Date_Time__c, End_Date_Time__c, Notes__c,
                                      OwnerId, Prospect_Store_Name__c,Time_Spent__c, Owner.Name,Owner_Full_Name__c,Store_Name__c,
                                      Visit_Type__c,Completed_all_required_activities__c 
                                      FROM Store_Visit__c
                                      WHERE Store__c = :storeId                                       
                                      AND OwnerId = :userId
                                      ORDER by LastModifiedDate Desc
                                      LIMIT 1];
            return oldCompletedVisit;
        }
    }
    
    @AuraEnabled
    public static void insertStoreVisit(Id storeId)
    {
        try{       Store_visit__c obj = new Store_visit__c(Store__c = storeId);
            obj.Start_Date_Time__c = Datetime.now();            
            obj.RecordTypeId= Schema.SObjectType.Store_Visit__c.getRecordTypeInfosByName().get('Store Visit New').getRecordTypeId();
            insert obj;
            }catch(DmlException e)
            {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }

    }
    
    @AuraEnabled
    public static String getActiveVisit(Id StoreId){       
        String activeStoreName ;
        try{
       List<Store_Visit__c> activeVisitList = [
            SELECT Id, Store__c,Prospect_Store_Name__c,Store__r.Name ,Start_Date_Time__c,Visit_Type__c
            FROM Store_Visit__c
            WHERE Store_Visit_Status__c = 'Active'                
            AND Store__c != null
            AND OwnerId = :UserInfo.getUserId()
            LIMIT 1];
            
        if(activeVisitList.size() == 0){
            insertStoreVisit(StoreId);
        }
        if(activeVisitList.size() > 0){
            for(Store_Visit__c actvisit : activeVisitList){
                if(actvisit.Store__c != StoreId)
                {          
                    activeStoreName = actvisit.Store__r.Name;            
                }
            }  
        }
    }catch(Exception e)
    {
                System.debug('The following exception has occurred: ' + e.getMessage());
    }
        return activeStoreName;
    }
    
    @AuraEnabled
    public static void setCompletedStatus(Id storeId){
        try{
        List<Store_Visit__c> storeVisitMarkAsComplete = new List<Store_Visit__c>();
        for(Store_Visit__c activeVisit : [
            SELECT Id, Store__c,End_Date_Time__c 
            FROM Store_Visit__c
            WHERE Store__c <> :storeId 
            AND Store_Visit_Status__c = 'Active'
            AND OwnerId = :UserInfo.getUserId()            
            LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows()) 
        ]){
            activeVisit.End_Date_Time__c = System.Now();
            activeVisit.Is_Auto_Check_Out__c=true;
            storeVisitMarkAsComplete.add(activeVisit);                
        }  
        Database.update(storeVisitMarkAsComplete);
        insertStoreVisit(StoreId);
        }catch(Exception e)
            {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
    }
    
    @AuraEnabled
    public static UserRole getRole()
    {
        try{
        UserRole role = StoreQueryUtilityLight.queryUserRole(UserInfo.getUserRoleId());
        return role;
        }catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }
    
    /* This method will send email to rep and manager on ending store visit*/
    @AuraEnabled
    public static VisitAndActivitiesWrapper stopVisitAndGetInCompletedActivities(User userDetail, String storeId, String storeAddress, Store_Visit__c 
                                        StoreVisit,Decimal lat, Decimal longi , List<Store_Visit_Activity_Category__c> categories, Account storeDetail){    
         
        try{
            List<String> sendTo = new List<String>();
            List<Store_Activity__c> StoreActivityList = [SELECT Id, Name ,Activity_Type__c,Notes__c,Is_Activity_Completed_New__c,
                                                         RecordTypeId         
                                                         FROM Store_Activity__c WHERE Store_Visit__c =:StoreVisit.Id 
                                                         AND Is_Activity_Completed_New__c= true ORDER BY CreatedDate 
                                                         LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                Integer completedNumber = 0;
                List<Store_Visit_Activity_Category__c> reqAct = new List<Store_Visit_Activity_Category__c>();                                
                for(Store_Visit_Activity_Category__c Cate: categories)
                {
                    if(Cate.Number_Required__c > 0)
                    {
                        reqAct.add(Cate);
                    }
                }
                for(Store_Visit_Activity_Category__c allCate: reqAct)
                {
                    for(Store_Activity__c sta: StoreActivityList)
                    {
                        if(sta.RecordTypeId == allCate.Record_Type_Id__c)
                        {
                            completedNumber++;
                        }
                    }
                }                             
                if(completedNumber == reqAct.size())
                {
                    StoreVisit.Completed_all_required_activities__c =  true;
                } 
            StoreVisit.End_Date_Time__c = Datetime.now();    
            Long msInStore =  StoreVisit.End_Date_Time__c.getTime() - StoreVisit.Start_Date_Time__c.getTime();        
            StoreVisit.Time_Spent__c = StoreVisitUtility.convertMsToTimeDisplay(msInStore);
            StoreVisit.Stop_Location__Latitude__s = lat;
            StoreVisit.Stop_Location__Longitude__s = longi;
            update StoreVisit;
           
             if(userDetail.Manager.Email != null){           
                sendTo.add(userDetail.Email);
                sendTo.add(userDetail.Manager.Email);
                }
                else{
                sendTo.add(userDetail.Email);       
                }   
                
            sendEmail(StoreVisit,categories,storeDetail,sendTo,StoreActivityList);                            
        
        return (new VisitAndActivitiesWrapper(StoreVisit,StoreActivityList));   
        }catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }   
    }
    
   public class VisitAndActivitiesWrapper{
        @AuraEnabled
        public  Store_Visit__c storeVisit;
        @AuraEnabled
        public List<Store_Activity__c> storeActivityList;
        
        public VisitAndActivitiesWrapper(Store_Visit__c storeVisitParam, List<Store_Activity__c> storeActivityListParam){
            this.storeVisit = storeVisitParam;
            this.storeActivityList = storeActivityListParam;
        }
    }
    
    @AuraEnabled
    public static List<Store_Activity__c> getCompletedActivities(String storeVisitId ){
    try{    
       List<Store_Activity__c> StoreActivityList = [SELECT Id, Name ,Activity_Type__c
                                                     FROM Store_Activity__c WHERE Store_Visit__c =:storeVisitId 
                                                     AND  Is_Activity_Completed__c = true 
                                                     ORDER BY CreatedDate
                                                     LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ];
                                                    
        return StoreActivityList;
        }catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }
        
    // To udpate the store visit with notes
    @AuraEnabled
    public static Store_Visit__c updateStoreVisit(Store_Visit__c storeVisit, String Notes){
        try{
        storeVisit.Notes__c = Notes;
        update storeVisit;     
        }catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        return storeVisit;
    }
    
    @AuraEnabled
    public static StoreDetails getStoreDetails(String storeType, String userRoleName) {
        try{
        Id userId = UserInfo.getUserId();
        List<Store_Visit_Activity_Category__c> categories = new List<Store_Visit_Activity_Category__c>([
            SELECT Id, Number_Required__c,Record_Type_Name__c,Record_Type_Id__c, Store_Activity_Category__c,New_Records__c,Lookup_field_value__c
            FROM Store_Visit_Activity_Category__c
            WHERE Store_Type__c = :storeType AND User_Role__c = :userRoleName AND New_Records__c = true
            ORDER BY Number_Required__c DESC, Record_Type_Name__c asc
            LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())
        ]);
        
        Map<Id,Account> storeMap = new Map<Id,Account>([SELECT Id, Name,AccountNumber,Store_Nickname__c,Required_Visit_Frequency_Days__c,
                                   In_Store_Competitors__c,Parent_Account_Dropdown__c,Visit_By_Date__c,
                                   BillingStreet,BillingCity,BillingState,Monthly_RGU_Order_Goal__c,Monthly_RGU_Activations_Goal__c,
                                   BillingPostalCode,BillingCountry,Billing_Address__c,Store_Visit_Status__c, Last_Visit_Date__c,Store_Type__c,Region__c,Owner.Name,Is_Parent_Store__c,
                                   Store_Location__Latitude__s,Store_Location__Longitude__s , Phone, Parent.Name,Store_Designation__c, Last_Visit_Date_Text__c  
                                    FROM Account WHERE OwnerId =:userId AND RecordType.Name= 'Store' ORDER BY Name
                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
                                        
        return new StoreDetails(storeMap,categories);
        }catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }
    
    public class StoreDetails{
        @AuraEnabled
        public Map<Id,Account> storeMap;
        @AuraEnabled
        public List<Store_Visit_Activity_Category__c> categories;
                
        public StoreDetails(Map<Id,Account> storeMap, List<Store_Visit_Activity_Category__c> categories){
            this.storeMap = storeMap;
            this.categories = categories;
        }
    }
    
    @AuraEnabled
    public static List<Store_Visit_Activity_Category__c> queryActivityCategoriesForHistory(String storeType, String userRoleName) {  
        try{
        List<Store_Visit_Activity_Category__c> historyCategories = [SELECT Id, Number_Required__c,Record_Type_Name__c,
                                                                    Record_Type_Id__c, Store_Activity_Category__c,
                                                                    New_Records__c,Lookup_field_value__c  
                                                                    FROM Store_Visit_Activity_Category__c
                                                                    WHERE Store_Type__c = :storeType 
                                                                    AND User_Role__c = :userRoleName
                                                                    ORDER BY Number_Required__c DESC,
                                                                    Record_Type_Name__c asc
                                                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                                                                     
            return historyCategories;
        }catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }  
    }
    
    @AuraEnabled   
    public static Store_Activity__c createStoreActivity(String storevisitCategoryRecordTypeId, Store_Visit__c storeVisit)
    { 
    try{
   
        List<Store_Activity__c> existingObj =  [Select Id, Name,Store_Visit__c,RecordTypeId,
                                                RecordType.Name,RecordType.DeveloperName, Store_Type__c 
                                                from Store_Activity__c where Store_Visit__c = :storeVisit.Id                                                 
                                                and recordTypeId = :storevisitCategoryRecordTypeId LIMIT 1];
        
      
        if(existingObj.size() == 0){
            Store_Activity__c obj = new Store_Activity__c();
            obj.RecordTypeId = storevisitCategoryRecordTypeId;
            obj.Store_Visit__c = storeVisit.Id;
            insert  obj;
            
            Store_Activity__c newObj = [Select Id, Name,Store_Visit__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName,
                                        Store_Type__c   From Store_Activity__c where Store_Visit__c = :storeVisit.Id 
                                        and recordTypeId = :storevisitCategoryRecordTypeId LIMIT 1];            
    
        return newobj;            
        }
        else
            {
                return existingObj[0];
            }
        }catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled
    public static List<IndirectAddContactWrapper> displayContacts(String storeId, String storeVisitId)
    {
        List<IndirectAddContactWrapper> listOfWrapper = IndirectAddContactWrapper.getContacts(storeId,storeVisitId);
        
        return listOfWrapper;
        
    }
    
    //Method to get the latest record of Store Activity
    @AuraEnabled
    public static Store_Activity__c getLatestStoreActivity(String loggedInUser, String store)
    {
    try{    
      Store_Activity__c storeActivityObj = [Select Id, Name,Store_Visit__c,RecordTypeId,
                                              RecordType.Name,RecordType.DeveloperName, Store_Type__c
                                              From Store_Activity__c 
                                              where LastModifiedById = :loggedInUser AND
                                              Store__c = :store order by LastModifiedDate DESC LIMIT 1];

     return storeActivityObj;
         }catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        } 
    }
    
    //Method for getting the recommended Activity
    @AuraEnabled
    public static List<String> getRecommendedCategories(String storeId, List<Store_Visit_Activity_Category__c> categories,
                                                        String loggedInUserId)
    {   
        List<String> messageList = new List<String>();
        List<String> recordTypeList = new List<String>();
        List<Store_Visit__c> storeVisit = new List<Store_Visit__c>();
        List<Store_Activity__c> storeActList = new List<Store_Activity__c>();
        Map<Id,String> result = new Map<Id,String>();
        String Msg='You have completed all recommended activities';
      
        for(Store_Visit_Activity_Category__c ct: categories){
            if(ct.Number_Required__c > 0)          
                recordTypeList.add(ct.Record_Type_Id__c);       
        }
        try{
            storeVisit=[Select Id from Store_visit__c where store__c =:storeId AND Store_Visit_Status__c = 'Active' 
                        AND OwnerId = :loggedInUserId ORDER BY LastModifiedDate DESC LIMIT 1];
            
            Set<Id> setStoreVisitId = new  Set<Id>(); 
            
            if(storeVisit!=null){
                for(Store_Visit__c sv : storeVisit){
                    setStoreVisitId.add(sv.Id);
                }
            }
            
            if(setStoreVisitId != null){            
                storeActList =  [Select Id, Name,Store_Visit__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName,
                                 Store_Type__c,Is_Activity_Completed_New__c from Store_Activity__c where  Store_Visit__c In :setStoreVisitId 
                                 and recordTypeId In :recordTypeList and Store__c != null
                                 LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                
                integer size = storeActList.size();            
                for(Store_Visit_Activity_Category__c ct: categories){
                    if(ct.Number_Required__c > 0){
                        result.put(ct.Record_Type_Id__c, ct.Store_Activity_Category__c);
                        for(integer i=0; i<size ; i++){
                            if(storeActList[i].recordTypeId == ct.Record_Type_Id__c  && storeActList[i].Is_Activity_Completed_New__c == true){
                                if(result.size()>0){
                                    result.remove(ct.Record_Type_Id__c);                                
                                }
                            }
                        }
                    }
                }
            }
        }catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        if(!result.isEmpty()){
            return result.values();
        }else{
            messageList.add(Msg);           
            return messageList;
        }        
        
    } 
    
    //Method for getting the Required Activities on Overview
    @AuraEnabled
    public static List<String> getCategories(String storeId,List<Store_Visit_Activity_Category__c> categories,
                                             String loggedInUserId){
        Map<Id,String> result = new Map<Id,String>();
        try{ 
            Store_Visit__c storeVisit = [Select Id from Store_visit__c where store__c =:storeId 
                                         AND Store_Visit_Status__c = 'Active' 
                                         AND OwnerId = :loggedInUserId ORDER BY LastModifiedDate DESC LIMIT 1];

            List<String> recordTypeList = new List<String>();
            for(Store_Visit_Activity_Category__c ct: categories)
            {
                if(ct.Number_Required__c > 0)
                    recordTypeList.add(ct.Record_Type_Id__c);                
            }
            
            
            List<Store_Activity__c> storeActList =  [Select Id,Is_Activity_Completed_New__c,RecordTypeId from Store_Activity__c where Store_Visit__c = :storeVisit.Id and recordTypeId In :recordTypeList LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            
            for(Store_Visit_Activity_Category__c ct: categories){
                if(ct.Number_Required__c > 0){
                    result.put(ct.Record_Type_Id__c, ct.Store_Activity_Category__c);
                    for(integer i=0; i<storeActList.size(); i++){
                        if(storeActList[i].recordTypeId == ct.Record_Type_Id__c  && storeActList[i].Is_Activity_Completed_New__c == true){
                            if(result.size()>0){
                                result.remove(ct.Record_Type_Id__c);                                
                            }
                        }
                    }
                }
            }
            
            if(!result.isEmpty()){
                return result.values();
            }      
            else
                return null;
        }catch(Exception e)
        {return null;}
    }
    
    /* Method for sending email summary logic */  
    public static void sendEmail(Store_Visit__c StoreVisit,List<Store_Visit_Activity_Category__c> categories,
                      Account storeDetail, List<String> sendingTo,List<Store_Activity__c> StoreActivityList){
                                                                 
        String owner = storeDetail.Owner.name;
        String storeName = storeDetail.Name;
        DateTime endDate = StoreVisit.End_Date_Time__c;  
        Date myDate = date.newinstance(endDate.year(), endDate.month(), endDate.day());
                          String dy = string.valueof(myDate.day());
                            if(dy.length()==1){dy ='0'+dy;}
                                       
                          String mt = string.valueof(myDate.month());
                          if(mt .length()==1){mt = '0' + mt;} 
                          String yr = string.valueof(myDate.year());       
        String notes = StoreVisit.Notes__c;
        String billingStreet = storeDetail.BillingStreet;
        String billingCity = storeDetail.BillingCity;
        String billingState = storeDetail.BillingState;
        String billingPostalCode = storeDetail.BillingPostalCode;
        String billingCountry = storeDetail.BillingCountry;
        String body;
        List<String> mailBodyString = new List<String>();
        Integer x=0;
        Integer y;
        Integer z;
        //List<String> sendingTo = new List<String>();
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
        String summaryNotes = '';
        String storeVisitNotes = '';
        String mailBody = openTableTag;
        Map<String,String> activityNotesMap = new Map<String,String>();
         
        try{
            EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate 
                                           WHERE Name = 'Send Summary Email Template' LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            for(Store_Activity__c storeActivityObj: StoreActivityList){
                if(storeActivityObj.Activity_Type__c !=null ){
                    body += storeActivityObj.Activity_Type__c+' ';
                    activityNotesMap.put(storeActivityObj.Activity_Type__c,storeActivityObj.Notes__c);
                }
            }
            
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
                                  summaryNotes = activityNotesMap.get(s).replace('\r\n', '<br/>');
                                  mailBodyString.add('<tr><td style="padding-left:10px" valign="top" width="17%">' +activity.Store_Activity_Category__c + ' Notes: ' + '</td>' +
                                                      '<td valign="top" width="83%">'+ ' ' +summaryNotes+'</td></tr>');
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
        String finalEndDate = mt+'/'+dy+'/'+yr;
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
            '{!Store_Visit__c.Notes__c}'=> storeVisitNotes ,
            '{!myCustomString}' => mailBody
        };
         
        mail.setToAddresses(sendingTo); 
        
        String subject = emailTemplate.Subject;
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
        }catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        } 
    } 
    @AuraEnabled
    public static IsAutoCheckOutANDActivitiesWrapper isAutoCompletedStoreVisit(String storeVisitId){
        Store_Visit__c storeVisit = [Select Id,Is_Auto_Check_Out__c from Store_Visit__c where Id=: storeVisitId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        List<Store_Activity__c> StoreActivityList = [SELECT Id, Name ,Activity_Type__c,Is_Activity_Completed_New__c,
                                                     RecordTypeId         
                                                     FROM Store_Activity__c WHERE Store_Visit__c =:storeVisitId 
                                                     AND Is_Activity_Completed_New__c= true ORDER BY CreatedDate LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        return (new IsAutoCheckOutANDActivitiesWrapper(storeVisit,StoreActivityList));
    }

    public class IsAutoCheckOutANDActivitiesWrapper{
        @AuraEnabled
        public  boolean isAutoCheckOut;
        @AuraEnabled
        public List<Store_Activity__c> storeActivityList;
        
        public IsAutoCheckOutANDActivitiesWrapper(Store_Visit__c storeVisitParam, List<Store_Activity__c> storeActivityListParam){
            this.isAutoCheckOut = storeVisitParam.Is_Auto_Check_Out__c;
            this.storeActivityList = storeActivityListParam;
        }
    }
    //method for add multiple contact to store activity
    @AuraEnabled
    public static Boolean DoActivityContactsExist(Id activityId, List<String> lookUpFieldValue){
        Boolean flag = true;
        Set<String> allLookUpFieldValue = new Set<String>();
        Set<String> newStringSet = new Set<String>();
        String nonMandetoryLookUpValue = 'Name of Rgnl Mgr. and what was reviewed?';
        
        for(String stringVar : lookUpFieldValue){
            if(!stringVar.contains(nonMandetoryLookUpValue)){
                newStringSet.add(stringVar);
            }
        }
        try{
        List<Activity_Contacts__c> activityContactList = [SELECT Id, Contact__c, Store_Activity__c, Type_of_contact__c 
                                                          FROM Activity_Contacts__c WHERE Store_Activity__r.Id =:activityId
                                                          LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ];
                                                      
        for(Activity_Contacts__c actContObj: activityContactList){
            List<String> tempList = new List<String>();
            if(actContObj.Type_of_contact__c.contains(';')){
                tempList = actContObj.Type_of_contact__c.split(';');
                
            }else{
                tempList.add(actContObj.Type_of_contact__c);
            }
            allLookUpFieldValue.addAll(tempList);           
        }        
        if(activityContactList.isEmpty()){
            flag = false;
        }else{
            if(newStringSet.isEmpty()){
                flag = true;
            }
            else{
                if(allLookUpFieldValue.containsAll(newStringSet)){                  
                    flag = true;
                }else{
                    flag = false;
                }
            }
        }     
        return flag;
        }catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }   
    }
    
    @AuraEnabled
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) { 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = new Attachment();
        a.parentId = parentId;
        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;
        try{
        insert a;
        }catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

        return a.Id;
    }
    
    
    /**
    * @Description: This method will be called to initiate file attachment to store visit.
    * @UserStory: US700738(Indirect - Add ability to add attachment to a store visit)
    * @Author: Mandeep , Accenture
    * @Date: 21-Oct-2016    
    */
    @AuraEnabled
    public static Id saveTheChunk(Store_Visit__c parentId, String fileName, String base64Data, String contentType, Id fileId) { 
        if (fileId == null) {
           fileid = saveTheFile(parentId.id, fileName, base64Data, contentType);
        } else {
            system.debug('appendToFile called');
            appendToFile(fileId, base64Data);
        }
        return fileId;
        
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [SELECT Id, Body FROM Attachment WHERE Id =:fileId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        
        String existingBody = EncodingUtil.base64Encode(a.body);
        system.debug('!!existingBody'+existingBody);
        a.body  = EncodingUtil.base64Decode(existingBody + base64Data);
        try{
        update a;
        }catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static boolean activeVisitCheck(Store_Visit__c storeVisit){
        try{
       storeVisit = [SELECT id,Store_Visit_Status__c FROM Store_Visit__c WHERE ID=:storeVisit.id LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        }catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        if(storeVisit.Store_Visit_Status__c == 'Active'){
        return false;
        }
        else{
        return true;
        }
    }
    
    /**
    * @Description: This method will return attachment name to display on storevisit.
    * @UserStory: US827355(Indirect - Display Name of Attachment in Visit)
    * @Author: Mandeep , Accenture
    * @Date: 2-Nov-2016    
    */
     @AuraEnabled
    public static List<String> getAttachmentName(Store_Visit__c parentId){
        try{
       List<Attachment> attachmentList = [SELECT Id,Name,Body FROM Attachment WHERE parentId =:parentId.Id LIMIT 1];
        
       List<String> attachmentName = new List<String>();
       if (!attachmentList.isEmpty()){
           for(Attachment a:attachmentList ){
              attachmentName.add(a.name);
           }
       }
       return attachmentName ;
       }catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }
}