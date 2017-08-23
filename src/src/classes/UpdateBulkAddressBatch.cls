/**************************************************************************************************
Name : UpdateBulkAddressBatch
Description : This batch class update the addresses that is assigned to contractor DSS (For Bulk Type Plan) 
User Story : US581344(Analysis and Implementation: Assigning Address To Business Partners)
Date : 18 Nov 2015
Author : Amit Kumar Pradhan
***************************************************************************************************/
global class UpdateBulkAddressBatch implements Database.Batchable<SObject>, Database.Stateful {
    /*
     *Data Member
     */
    
    private static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final string BATCH_JOB_NAME = 'UpdateBulkAddressBatch';
    private static final string JOB_STATUS = 'New';
    private static final string NEW_LINE = '\n';
    private static final string SYSTEM_EXCEPTION = 'System Exception - '; 
    private Id jobStatusId = null;
    private static final string JOB_COMMENT = ' ';
    private static final string JOB_NAME_SPACE =  ' - ';
    private String queryString = null;
    private ID contractorSuperviserId = null;
    private Id planObjId = null;
    private String rsaRegion = '';
    private String emailOfUser = '';
    private Plan__c planDetails = null;
    private User userDetails = null;
    private String lastModifiedDate = null;
    private Integer totalRecords = 0;
    
    /*
     * Constructor for initialisation
     */
    global UpdateBulkAddressBatch(Id planObjId, ID contractorSuperviserId, String queryString, String rsaRegion, Integer totalRecords) {           
        this.queryString = queryString;
        this.contractorSuperviserId = contractorSuperviserId;
        this.planObjId = planObjId;   
        this.rsaRegion = rsaRegion;
        this.totalRecords = totalRecords;
        userDetails = [Select id,email,Name From User where Id =:contractorSuperviserId];
        if(userDetails.email != Null){
            emailOfUser = userDetails.email;
        }
        planDetails = [Select id, No_Of_Bulk_Assignment_del__c, True_count_of_Addresses__c, Name, LastModifiedById, LastModifiedDate From Plan__c where Id =:planObjId];
        
         //Create Job Status Object
        Job_Status__c jobStatus = new Job_Status__c();
    
        jobStatus.Name = BATCH_JOB_NAME + JOB_NAME_SPACE  + Datetime.now();
        jobStatus.Status__c = JOB_STATUS;
        jobStatus.Total_Records_Processed__c = 0;        
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = JOB_COMMENT;
        jobStatus.Number_Of_Fallouts__c = 0;
        jobStatus.Total_No_Of_Records__c = totalRecords;
        jobStatus.PlanId__c = planObjId;
        jobStatus.Bulk_Assign_Region__c = rsaRegion;
       
       
        try{
            Database.insert(jobStatus);  
            jobStatusId = jobStatus.Id; 
                
            //update the plan with job status Id
            planDetails.Job_Status_Id__c = jobStatus.Id;
            planDetails.BulkPlanStatus__c = 'InProgress';
            Database.update(planDetails);
        }catch(Exception e){
            System.debug('Following Error Msg'+e.getMessage());
        }
    } 
    /*
     * Query execution to fetch addresses thats need to be updated
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
       return Database.getQueryLocator(queryString);
    }
    
    /*
     * Execute business logic to update ownerId and Plan field for addresses 
     */
    global void execute(Database.BatchableContext bc, List<Customer_Address__c> addressList) {   
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        try{ 
            List<Customer_Address__c> addressListToBeUpdated = new List<Customer_Address__c>();
            for(Customer_Address__c obj: addressList) {
                obj.ownerid = contractorSuperviserId; //Update ownerId to Contractor DSS 
                obj.Plan__c = planObjId; //Update plan field 
                addressListToBeUpdated.add(obj);
            }
        Database.SaveResult[] updateAddresses = Database.Update(addressListToBeUpdated,false);
        executeJob(updateAddresses, jobStatus); 
        }
        catch(Exception e) {
             if(jobStatus!=null && !jobStatus.isEmpty()){
                    Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                    String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  SYSTEM_EXCEPTION + e.getMessage() + NEW_LINE : jobStatus[0].Comments__c + SYSTEM_EXCEPTION + e.getMessage() +NEW_LINE;                                    
                    jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; Database.update(jobStatus[0]);   
             }   
        }
    }
    
    /*
     * Finish method to execute Job Status 
     */    
    global void finish(Database.BatchableContext bc) {
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
    
        if(jobStatus!=null && !jobStatus.isEmpty()){ 
            jobStatus[0].Batch_End_Time__c = Datetime.now(); 
            jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ; 
            Database.update(jobStatus[0]); 
        }
        
        
        
        String[] sendingTo = null;
        String subject = '';
        String body = '';
        String planRecordURL ='';
        String userName = UserInfo.getName();
       
        
        //Send the Email After complition Of Batch when first time batch run
        if(planDetails.No_Of_Bulk_Assignment_del__c < 2){
            Datetime todayDate = Datetime.now(); 
            if(todayDate != null){
                Date myDate = date.newinstance(todayDate.year(), todayDate.month(), todayDate.day());
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
                  
                lastModifiedDate = mnt +'/'+dy+'/'+yr ;
            }
            
            
            planRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
            planRecordURL += planDetails.Id;
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            sendingTo = new String[]{emailOfUser};  
            semail.setToAddresses(sendingTo);
            subject = 'Plan '+ planDetails.Name + ' : Assigned to you';
            semail.setSubject(subject);
            body = 'Hello ' +userDetails.Name +',\n\n';
            body += 'This is an Auto-Generated email. A new bulk record has been assigned \n';
            body += 'to you by ' + userName +' on '+ lastModifiedDate +'.\n\n';
            body += 'To view this bulk record, please click on the following link:\n';
            body += planRecordURL + '.\n\n Best Regards';
            
            semail.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
                        
        } 
        //Mark the BulkPlanStatus as Completed if it has addresses more then 40k
        try{
            //If(planDetails.True_count_of_Addresses__c !=Null && planDetails.True_count_of_Addresses__c > integer.valueof(System.Label.BulkAddressAssignLimit)){ 
                planDetails.BulkPlanStatus__c = 'Completed';
                Database.update(planDetails);
            //}       
        }catch(Exception e){
            System.debug('Following Error Msg'+e.getMessage());
        }   
    }
    
    /*
     *  method to execute Job Status 
     */    
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
        try{
           return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                   Batch_Start_Time__c, Batch_End_Time__c  
                   FROM Job_Status__c WHERE Status__c =: JOB_STATUS AND ID=: jobStatusId]);
        }catch(Exception e){
          //  System.debug('Following Error Msg'+e.getMessage());
            return null;
        }      
    }
    
    /*
     * Finish method to execute Job Status 
     */ 
    public void executeJob(Database.SaveResult[] updateAddresses, List<Job_Status__c> jobStatus)
    {
        try{
            if(jobStatus!=null && !jobStatus.isEmpty()){
                for(Database.SaveResult result : updateAddresses) {
                    jobStatus[0].Total_Records_Processed__c ++;
                    if(!result.isSuccess()){                                                 
                        for(Database.Error error : result.getErrors()){
                            jobStatus[0].Number_Of_Fallouts__c  ++;
                            Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                            String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  error.getMessage() + NEW_LINE : jobStatus[0].Comments__c + error.getMessage() + NEW_LINE;                                    
                            jobStatus[0].Comments__c=(tempMsg.length()>len)?tempMsg.substring(0,len):tempMsg;                                                                 
                         }
                    }       
                }
                Database.update(jobStatus[0]);
            }
        }catch(Exception e){
            System.debug('Following Error Msg'+e.getMessage());
        }           
    }
   
}