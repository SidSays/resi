/************************************************************************************************************************************************************
Name: RallyWsCallout 
Description: This class contains the logic for callouts to Rally.
Author: Vikram Tummala
Date 02 March 2017
Last Modified By : Animesh, Date : 15-May-2017, Added check for Business Administrator Profile US1099361
Modification History:
Amit Kumar: 11-JULY-2017 - US1141978: Modified the code to bring the Blocked and blocked reason for a Case which is associated with a Rally US
*************************************************************************************************************************************************************/
global class RallyWsCallout{

    public Case cas {get;set;}
    public string iteration{get; set;}
    public string release{get; set;}
    public string kanban{get; set;}
    public string scheduleState{get; set;}
    public string rallyId {get; set;}
    public string rallyName{get; set;}
    public string cNum{get; set;}
    public string cId{get; set;}
    public string project{get; set;}
    public string priority{get; set;}
    public string formattedId{get; set;}
    public string usName{get; set;}
    public string caseNum {get; set;}
    public string description {get; set;}
    public string url {get; set;}
    public Boolean refreshPage {get; set;}
    public string reload {get; set;}
    public string response {get; set;}
    private final Id SYS_ADMIN_PROFILE_ID {get; set;}
    rally_url__c settings = rally_url__c.getValues('Rally');
    private final string BUSINESS_ADMIN_PROFILE_ID;
    public boolean isBlocked{get; set;} //Added by AK for US1141978  to captured the blocked
    public string blockedreason{get; set;} //Added by AK for US1141978 to captured the blocked reason
    public static final String STR_BLOCKEDREASON = 'BlockedReason';  //Added by AK for US1141978 to captured the blocked reason
    public static final string STR_BLOCKED = 'Blocked';  //Added by AK for US1141978 to captured the blocked reason
    public static final string STR_TRUE = 'True';  //Added by AK for US1141978 to captured the blocked reason
    public static final string STR_FALSE = 'False';  //Added by AK for US1141978 to captured the blocked reason
    
    /**
    * Name: rallyWsCallout
    * Description: This is constructor. 
    * @parameters: None
    * @return: None
    **/
    public rallyWsCallout(ApexPages.StandardController stdController) {
        this.cas = (Case)stdController.getRecord();
        cas = [Select Id, caseNumber, Priority, Name_For_Rally__c, Rally_Project__c, Rally_ID__c, Iteration__c, Schedule_state__c, Release__c, Status, Description from Case where Id =: cas.Id];        
        description = cas.description;
        cId = cas.Id;
        cNum = cas.caseNumber;
        priority = cas.priority;
        project = cas.rally_project__c;
        rallyName = cas.Name_For_Rally__c;       
        string urlsf = settings.SF_URL__c;
        string urlol = settings.Order_Lab_URL__c;
        if(cas.Rally_ID__c == null || cas.Status == 'Closed'){
            refreshPage = false;
        }
        else{
            caseNum = cas.Rally_ID__c;
            if(project != 'Order Lab'){
                url=urlsf+caseNum;
            }
            else{
                url=urlol+caseNum;
            }
            refreshPage = true;
            SYS_ADMIN_PROFILE_ID = [select ProfileId from User where Profile.Name = 'System Administrator' LIMIT 1].ProfileId;
            //Start - US1099361 - SP54 - Animesh
            BUSINESS_ADMIN_PROFILE_ID = [SELECT ID 
                                            FROM Profile 
                                                WHERE Name = : ConstantHandler.BUSINESS_ADMIN_PROFILE_NAME LIMIT 1].Id;//US1099361 - get Business Administrator Profile Id
            //End - US1099361 - SP54 - Animesh
        }
    }

    /**
    * Name: getFromRally
    * Description: This method is used to get real time values from Rally User Story by GET callout to Rally  
    * @parameters: None
    * @return: None
    **/   
    public void getFromRally(){
        if(refreshPage == true && (UserInfo.getProfileId() == SYS_ADMIN_PROFILE_ID ||  (BUSINESS_ADMIN_PROFILE_ID != null && BUSINESS_ADMIN_PROFILE_ID.equalsIgnoreCase(UserInfo.getProfileId())))){//US1099361 - SP54 - Animesh. Added check for Business Administrator 
            string method = 'GET';
            HttpResponse res = rallyCallout(method, null);
            if(res != null){
                response = res.getBody();
            }
            //system.debug(res.getBody());
            if(response == null || response.startsWith('<')){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'ERROR: There is an issue with the Webservice. Contact Admin for more Information.');
                ApexPages.addMessage(myMsg);
                //system.debug(res.getBody());
            }
            else{
                Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(response);
            if(rawObj.get('HierarchicalRequirement') == null){
                refreshPage = false;
                removeRally();
            }
            else{
                Map<String,Object> responseObj = (Map<String,Object>)rawObj.get('HierarchicalRequirement');
                //system.debug(responseObj);
                parseJsonObj(responseObj);        
            }
            }
        }      
    }
 
    /**
    * Name: postToRally
    * Description: This method is used to create a Rally User Story from a Case by POST callout to Rally  
    * @parameters: None
    * @return: None
    **/    
    public void postToRally(){ 
        if (refreshPage == true){
            reload = 'This Case is already associated to a Rally User Story.';
        }     
        else{
            if(cas.Status == 'Closed'){
                reload = 'This Case is Closed.';
            } 
            else if(priority == null || priority == '-' || description == null || description == ''){
                reload = 'Priority value of - or null is not valid. Description is required.';
            }
            else{
                string r;
                string proj;
                string olproj = settings.Order_Lab_Proj__c;
                string sfproj = settings.SF_Proj__c;
                if(project != 'Order Lab'){
                    proj = sfproj;
                }
                else{
                    proj = olproj;
                } 
                User usr = [select id, rallyId__c from User where id = :UserInfo.getUserId()];
                if(usr.rallyId__c != null){
                    r = '/user/'+usr.rallyId__c;
                }
                string method = 'POST';   
                JSONGenerator gen=JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeFieldName('HierarchicalRequirement');
                gen.writeStartObject();
                gen.writeStringField('Project',proj);
                gen.writeStringField('Name',rallyName);
                gen.writeStringField('Description',description);
                gen.writeFieldName('c_SalesforceCase');
                gen.writeStartObject();
                gen.writeStringField('LinkID',cId); 
                gen.writeStringField('DisplayString',cNum);
                gen.writeEndObject(); 
                gen.writeStringField('c_TeamPriority',priority);
                if(r != null){   
                    gen.writeFieldName('Owner');
                    gen.writeStartObject();
                    gen.writeStringField('_ref',r); 
                    gen.writeStringField('_type','User');
                    gen.writeEndObject();
                }
                gen.writeEndObject();
                gen.writeEndObject();
                string body = gen.getAsString();
                //System.debug(body);        
                HttpResponse res = rallyCallout(method, body);
                if(res != null){
                    response = res.getBody();
                }
                if(response == null || response.startsWith('<')){
                    reload='There was an issue creating the User Story. Please contact the System Administrator.';
                    //system.debug(res.getBody());
                }
                else{
                    Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(response);
                    if(rawObj.get('CreateResult') != null){
                        Map<String,Object> rObj = (Map<String,Object>)rawObj.get('CreateResult');
                        Map<String,Object> responseObj = (Map<String,Object>)rObj.get('Object');
                        //system.debug(responseObj);
                        if(responseObj != null){
                            parseJsonObj(responseObj);
                            refreshPage = true;
                        }
                    }
                    else{
                        reload='There was an issue creating the User Story. Please contact the System Administrator.';
                    }
                } 
            }
        }
    }
  
  /**
  * Name: parseJsonObj
  * Description: This method is used to parse JSON response from the POST callout.  
  * @parameters: map<string, object>
  * @return: None
  **/  
    public void parseJsonObj(map<String,Object> responseObj){
        if(responseObj.get('Iteration') != null){
            Map<String,Object> iterObj = (Map<String,Object>) responseObj.get('Iteration');
            for (String field : iterObj.keySet()){
                if(field == 'Name'){
                    iteration = (string)iterobj.get(field);
                }
            }
        }else{
            iteration = 'Unscheduled';
        }
        if(responseObj.get('Release') != null){  
            Map<String,Object> releaseObj = (Map<String,Object>) responseObj.get('Release');
            for (String field : releaseObj.keySet()){
                if(field == 'Name'){
                    release = (string)releaseobj.get(field);
                }
            }
        }else{
            release = 'Unscheduled';
        }                
        if(responseObj.get('c_KanbanState') != null){
            kanban = (string)responseobj.get('c_KanbanState');
        }
        if(responseObj.get('FormattedID') != null){
            formattedId = (string)responseobj.get('FormattedID');
        }
        if(responseObj.get('ScheduleState') != null){
            scheduleState = (string)responseobj.get('ScheduleState');
        }
        if(responseObj.get('Name') != null){
            usName = (string)responseobj.get('Name');
        }
        if(responseObj.get('ObjectID') != null){
            rallyId = string.valueOf(responseobj.get('ObjectID'));
        }
         /**********  Added by AK for US1141978 to add the blocked and blocked Reason *************   START   *********/
        if(responseobj.get(STR_BLOCKEDREASON)!=null){
           blockedreason = string.valueOf(responseobj.get(STR_BLOCKEDREASON));
        }
        if(responseobj.get(STR_BLOCKED)!=null && string.valueof(responseobj.get(STR_BLOCKED)).equalsIgnoreCase(STR_TRUE) ){
           isBlocked = true;
        }else if(responseobj.get(STR_BLOCKED)!=null && string.valueof(responseobj.get(STR_BLOCKED)).equalsIgnoreCase(STR_FALSE)){
           isBlocked = false;
        }
        
         /**********  Added by AK for US1141978 to add the blocked and blocked Reason *************   END   *********/
        caseUpdate();
    }

  
  /**
  * Name: caseUpdate
  * Description: This method is used to update Case fields based on updates to Rally fields.  
  * @parameters: None
  * @return: None
  **/    
    public void caseUpdate(){
        try{
            if(cas.Iteration__c != iteration || cas.Release__c != release || cas.Schedule_State__c != scheduleState){
                cas.Iteration__c = iteration;
                cas.Release__c = release;
                cas.Schedule_State__c = scheduleState; 
                if(rallyId != null){
                    cas.Rally_ID__c = rallyId;
                }
                if(scheduleState == 'Backlog' || scheduleState == 'Defined'){          
                    cas.Status = 'Approved and Added to Backlog';
                }
                else if(scheduleState == 'In-Progress' || scheduleState == 'Completed'){          
                    cas.Status = 'In Progress';
                }
                else if(scheduleState == 'Accepted'){          
                    cas.Status = 'Added to Release Plan';
                }
            }                    
            if(kanban != null && kanban == 'Deployed'){
                cas.Kanban_State__c = kanban;
                cas.Status = 'Closed';
                cas.Resolution_Categories__c = 'User Story';
                cas.Resolution_Notes__c = 'Released';
            }
            /**********  Added by AK for US1141978 to add the blocked and blocked Reason *************   START   *********/
            if(isBlocked !=null && isBlocked){  //Is US has been blocked
                cas.Blocked__c = true;  //update the case field
                if(!string.isBlank(blockedreason)){  //Check for Blocked reason
                    cas.Blocked_Reason__c = blockedreason;   //Populate the Reason for Blocked reason
                }else if (string.isBlank(blockedreason)){
                	cas.Blocked_Reason__c = null;
                }
            }else if(isBlocked !=null && !isBlocked){
                cas.Blocked__c = false;  //update the case field
                cas.Blocked_Reason__c = null;   //Populate the Reason for Blocked reason
            }
            /**********  Added by AK for US1141978 to add the blocked and blocked Reason *************   END   *********/
            
            update cas;
            
        }catch(DMLException e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'ERROR: '+e);
            ApexPages.addMessage(myMsg);
            System.debug('ERROR:' + e);
        }
    }
  
  
/**
  * Name: removeRally
  * Description: This method is used to update Case fields, US fields when a related User Story is disassociated.  
  * @parameters: None
  * @return: None
  **/     
    public void removeRally(){
        string method = 'UPDATE';
        JSONGenerator gen=JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('HierarchicalRequirement');
        gen.writeStartObject();
        gen.writeFieldName('c_SalesforceCase');
        gen.writeStartObject();
        gen.writeStringField('LinkID',''); 
        gen.writeStringField('DisplayString','');
        gen.writeEndObject();
        gen.writeEndObject(); 
        gen.writeEndObject();
        string body = gen.getAsString();
        //System.debug(body);        
        HttpResponse res = rallyCallout(method, body);
        if(res != null){
            response = res.getBody();
        }
        if(response == null || response.startsWith('<')){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'ERROR: There is an issue with the Webservice. Contact Admin for more Information.');
            ApexPages.addMessage(myMsg);
            //system.debug(res.getBody());
        }
        else{     
            try{
                cas.Rally_ID__c = null;
                cas.Kanban_State__c = null;
                cas.Iteration__c = null;
                cas.Release__c = null;
                cas.Schedule_State__c = null;
                cas.Blocked__c = false;  //  Added by AK for US1141978 to add the blocked and blocked Reason
                cas.Blocked_Reason__c = null;  //  Added by AK for US1141978 to add the blocked and blocked Reason
                refreshPage = false;
                
                update cas;
            }catch (DMLException e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'ERROR: '+e);
                ApexPages.addMessage(myMsg);
                System.debug('ERROR:' + e);
            }
        }
    }

/**
  * Name: rallyCallout
  * Description: This method is used for the actual callout to Rally.  
  * @parameters: string method, string body
  * @return: HttpResponse
  **/   
    public HttpResponse rallyCallout(string s, string body){
        HttpRequest req = new HttpRequest();
        string endpoint;
        string key = settings.key__c;
        string getEP = settings.GET_EP__c;
        if(s == 'GET'){
            req.setMethod(s);
            req.setHeader('ZSESSIONID', key);
            endpoint = 'callout:Rally/'+caseNum+getEP;
        }
        else if(s == 'POST'){
            req.setBody(body);
            req.setMethod(s);
            req.setHeader('ZSESSIONID', key);
            req.setHeader('Content-Type', 'application/json');
            endpoint = 'callout:Rally/create';
        }
        else if(s == 'UPDATE'){
            req.setBody(body);
            req.setMethod('POST');
            req.setHeader('ZSESSIONID', key);
            req.setHeader('Content-Type', 'application/json');
            endpoint = 'callout:Rally/'+caseNum;
        }              
        req.setEndpoint(endpoint);
        Http http = new Http();
        HTTPResponse res;
        try{
            res = http.send(req);
        }catch (System.CalloutException e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'ERROR: '+e);
            ApexPages.addMessage(myMsg);
            System.debug('ERROR:' + e);
        }
        return res; 
    }
}