/*************************************************************************************
    Name             : ApplicationLogPurgeBatch.cls
    Description      : Batch class to delete the Application log record based on the query passed in constructor
    Created By       : Accenture
    Created Date     : 06/25/2017
    User Story		 : US1026408: Create a trigger exception logging framework
 
************************************************************************************/
global class ApplicationLogPurgeBatch implements  Database.Batchable<sObject>, Database.Stateful{
    //Set the Variables ******************** START**********************************
    private String query = ConstantHandler.APPLOGDELETEBATCHQUERY;
    private Id jobStatusId = null;
    private Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
    public final static String STR_SNIPPET_NAME = 'ApplicationLogPurgeBatch';
    public final static String STR_APPLOGOBJECTNAME = 'Application Log';
    public final static String STR_JOBOBJECTNAME = 'Job Status';
    public static Id nonintegrationRTypeId = Schema.SObjectType.Application_Log__c.getRecordTypeInfosByName().get(ConstantHandler.APPLOGNONINTEGRATION).getRecordTypeId();
    //Set the Variables ******************** START**********************************
    /*
    *Constructor to pass query for batch execution
    */
    global ApplicationLogPurgeBatch(String query){ 
        this.query = query;	
    }
    /************************************************************************************************************
        @Name       :   start
        @Description:   Method to create the Job record and get the data for deletion
        @Parameters :   Batchable context
        @Returns    :   void
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc){
    	
    	//Create the Job status record
    	Job_Status__c job = new Job_Status__c();
        job.Name = ConstantHandler.APPBATCHCLASSNAME + PL_Constants.JOB_NAME_SPACE  + Datetime.now(); //Set the Job Name
        job.Status__c = PL_Constants.JOB_STATUS_NEW; //Job Status
        job.Total_Records_Processed__c = 0;  //Intializing the value to 0
        job.Total_RGU_Activations_Processed__c = 0;  //Intializing the value to 0
        job.Total_RGU_Orders_Processed__c = 0;  //Intializing the value to 0
        job.Total_RGU_ORders_Upserted_Today__c = 0;  //Intializing the value to 0
        job.Batch_Start_Time__c = Datetime.now();  //Set the Batch Start Time
        job.Comments__c = PL_Constants.JOB_COMMENT;  
        job.Number_Of_Fallouts__c = 0;
        insert job;
        
        jobStatusId = job.Id;      
        return Database.getQueryLocator(query);
    }
    
    /************************************************************************************************************
        @Name       :   Execute
        @Description:   Method to perform the delete of Application log records.
        @Parameters :   Batchable context and list of Application log records
        @Returns    :   void
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<Application_Log__c> scope){
    	
    	
    	List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); //get the job rcord
    	List<Id> hardDeleteLocList = new List<Id>();
    	
    	try{
    		   Database.DeleteResult[] dr = Database.delete(scope, false); //Delete the Log record
		        executeJob(dr, jobStatus); //Capture the count on same job record
		        for(Database.DeleteResult delLoc : dr){
		        	
	                  if(delLoc.isSuccess()){ //if records gets deleted the perform a hard delete on the records
	                      hardDeleteLocList.add(delLoc.getId());
	                  }
		        }
		        Database.emptyRecycleBin(hardDeleteLocList); //Empty the recycle bin
    	}catch(Exception e){if(!jobStatus.isEmpty()){ String tempMsg = String.IsBlank(jobStatus[0].Comments__c) ? PL_Constants.SYSTEM_EXCEPTION + e.getMessage() + PL_Constants.NEW_LINE : jobStatus[0].Comments__c + PL_Constants.SYSTEM_EXCEPTION + e.getMessage() +PL_Constants.NEW_LINE; jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; Database.update(jobStatus[0],false); 
             } 
    	}
    }
    /************************************************************************************************************
        @Name       :   Finish
        @Description:   Method to perform the final update on the Job status record..
        @Parameters :   Batchable context 
        @Returns    :   void
    ************************************************************************************************************/
    global void finish(Database.BatchableContext bc){
        Job_Status__c objjob = new Job_Status__c();
        try{ 
            List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
            objjob = jobStatus[0]; 
            if(!jobStatus.isEmpty()){ 
                jobStatus[0].Batch_End_Time__c = Datetime.now(); 
                
                jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? PL_Constants.BATCH_COMPLETE_WITH_SUCCESS : PL_Constants.BATCH_COMPLETE_WITH_FAIL ; 
                update(jobStatus[0]);
            } 
            
        }catch(Exception e){ ApplicationLogUtil.insertApplogforexceptions(e,ConstantHandler.STR_BATCHCLASS_CODE,STR_SNIPPET_NAME,STR_JOBOBJECTNAME,false,objjob.id,nonintegrationRTypeId);
        }   
    }
    
    /************************************************************************************************************
        @Name       :   getJobStatus
        @Description:   Method to fetch the Job status record based on the record inserted in the Start method.
        @Parameters :   Job Status Id 
        @Returns    :   void
    ************************************************************************************************************/  
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
        try{
            return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c,Batch_Start_Time__c, Batch_End_Time__c, 
               Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c, Total_RGU_ORders_Upserted_Today__c 
                     FROM Job_Status__c WHERE Status__c =: PL_Constants.JOB_STATUS_NEW 
                     AND ID= :jobStatusId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
        }catch(Exception e){return null;
        }
    }
    
     /************************************************************************************************************
        @Name       :   executeJob
        @Description:   Method to update the count of fallout on the Job status record..
        @Parameters :   Delete result, List of Job status 
        @Returns    :   void
    ************************************************************************************************************/
    public void executeJob(Database.DeleteResult[] deleteLocations, List<Job_Status__c> jobStatus){
        try{
            if(!jobStatus.isEmpty()){
                for(Database.DeleteResult result : deleteLocations) {
                    jobStatus[0].Total_Records_Processed__c ++;
                    if(!result.isSuccess()){                                                 
                        for(Database.Error error : result.getErrors()){ jobStatus[0].Number_Of_Fallouts__c  ++; String tempMsg = String.IsBlank(jobStatus[0].Comments__c) ? error.getMessage() + PL_Constants.NEW_LINE :jobStatus[0].Comments__c + error.getMessage() + PL_Constants.NEW_LINE;  jobStatus[0].Comments__c=(tempMsg.length()>len)?tempMsg.substring(0,len):tempMsg;                                                                 
                         }
                    }       
                }
                 Database.update(jobStatus[0]);
            } 
        }catch(Exception e){
        }
    }
}