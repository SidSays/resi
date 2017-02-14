global class ChatterProfilePictureUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
	 /*
    * Data Member 
    */     
	private final Static String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final string BATCH_JOB_NAME = 'ChatterProfilePictureUpdateBatch';
    private static final string JOB_STATUS = 'New';
    private static final string NEW_LINE = '\n';
    private static final string SYSTEM_EXCEPTION = 'System Exception - ';    
    private static final string RECORD_TYPE_SEPERATION = ';';
    private static final string JOB_COMMENT = ' ';
    private static final string JOB_NAME_SPACE =  ' - ';
    private static final string DATE_STRINGS =  '-';
    private list<user> userList = new list<user>();
    private Id jobStatusId = null;    
    private static final string PROFILE_ID_SEPERATION = ';';  
    private static final string QUERY_INITIAL = '';
    private static final Set<string> profileNameSet  = new Set<string>();  
	integer count = 0; 
    public String query;
	private final Static String HTML_HEAD ='<html><head></head><body>';
	private final Static String HI_STRING = 'Hi,';
	private final Static String HTML_DESCRIPTION ='<br><br>It has been over 60 days since the following users have been created but have not updated their chatter profile picture.<br><br></body></html>';
	private final Static String SUBJECT_STRING ='Chatter Profile picture has not been updated ';
	private final Static String HREF = '<a href=';
	private final Static String BODY_END ='</a><br><br> \n\n </body></html>';
	private final Static String REGARDS = 'With best regards';
    
    //Public String query= QUERY_INITIAL;
     //public String query='Select Id,CreatedDate,Name,ProfileId,Region__c,FullPhotoUrl from User where  IsActive = True AND CreatedDate < LAST_N_DAYS:60 AND FullPhotoUrl like \'%/profilephoto/005/F%\' AND SmallPhotoUrl like \'%/profilephoto/005/T%\' limit 10' ;
	 
	 /* Sample query :-  'Select Id,CreatedDate,Name,ProfileId,Region__c,FullPhotoUrl from User where  IsActive = True AND CreatedDate < LAST_N_DAYS:60' ' 
     */
	global ChatterProfilePictureUpdateBatch(String query)
    {
        this.query=query;
    }
	 global Database.QueryLocator start(Database.BatchableContext BC){
        //Create Job Status Object
        Job_Status__c jobStatus = new Job_Status__c();
        jobStatus.Name = BATCH_JOB_NAME + JOB_NAME_SPACE  + Datetime.now();
        jobStatus.Status__c = JOB_STATUS;
        jobStatus.Total_Records_Processed__c = 0;
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = JOB_COMMENT;
        jobStatus.Number_Of_Fallouts__c = 0;
        Database.insert(jobStatus);  
        jobStatusId = jobStatus.Id; 
        return Database.getQueryLocator(query);  
    } 
global void execute(Database.BatchableContext BC, List<user> scopeList){    
      List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
       //list<user> listUser =  new list<user>();
       for(User users:scopeList){
           userList.add(users);
           //listUser.add(users);
            count++;
          } 
        if(jobStatus!=null && !jobStatus.isEmpty()){ 
          jobStatus[0].Total_Records_Processed__c = count;
          Database.update(jobStatus[0]); 
        } 
	} 
global void finish(Database.BatchableContext BC){
 List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
        if(jobStatus!=null && !jobStatus.isEmpty()){ 
			jobStatus[0].Total_Records_Processed__c = count;
            jobStatus[0].Batch_End_Time__c = Datetime.now(); 
            jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ; 
            Database.update(jobStatus[0]); 
        } 
		String subject; 
        string emailId = label.ChatterProfilePictureUpdateEmail;
        String Description = HTML_HEAD;
    if(count!=0)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toadd=new String[]{emailId};
        String baseurl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        mail.setToAddresses(toadd); 
        Description += HI_STRING + HTML_DESCRIPTION;
        subject = SUBJECT_STRING;
		for(user obj : userList){
			Description += HREF  + baseurl+  obj.id +'>' + obj.name+ + BODY_END;
		}  
         Description += REGARDS;
        mail.setSubject(subject);
        mail.setHtmlBody(Description);
        Messaging.sendEmail(new Messaging.Email[] {mail}); 
    }   
}
    //Get job status    
   public List<Job_Status__c> getJobStatus(Id jobStatusId) {
           return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                   Batch_Start_Time__c, Batch_End_Time__c 
                   FROM Job_Status__c WHERE Status__c =: JOB_STATUS AND ID=: jobStatusId]);
       //system.debug('jobstatus>>>>' + getJobStatus());
}
	
}