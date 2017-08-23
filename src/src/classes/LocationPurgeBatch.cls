/**************************************************************************************************
Name : LocationPurgeBatch
Description : This batch class deletes all locations that are older than 31 days
User Story : US1042773
Date : 17 April 2017
Author : Anshuman Mohanty 
***************************************************************************************************/
global class LocationPurgeBatch implements  Database.Batchable<sObject>, Database.Stateful{
    
    private String query = System.Label.Location_Purge_Query;
    private Id jobStatusId = null;
    private Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
    
    /*
    *Constructor to pass query for batch execution
    */
    global LocationPurgeBatch(String query){
        if(!Test.isRunningTest()){
        	this.query = query;	
        }else{
        	this.query = 'Select ID FROM Location__c LIMIT 199';
        }
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
    	
    	
    	Job_Status__c job = new Job_Status__c();
        job.Name = 'LocationPurgeBatch' + PL_Constants.JOB_NAME_SPACE  + Datetime.now();
        job.Status__c = PL_Constants.JOB_STATUS_NEW;
        job.Total_Records_Processed__c = 0;
        job.Total_RGU_Activations_Processed__c = 0;
        job.Total_RGU_Orders_Processed__c = 0;
        job.Total_RGU_ORders_Upserted_Today__c = 0;
        job.Batch_Start_Time__c = Datetime.now();
        job.Comments__c = PL_Constants.JOB_COMMENT;
        job.Number_Of_Fallouts__c = 0;
        
        insert(job);  
        jobStatusId = job.Id;      
        return Database.getQueryLocator(query);
    }
    
    /*
    *Performs hard delete on location records obtained
    */
    global void execute(Database.BatchableContext bc, List<Location__c> scope){
    	
    	
    	List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
    	List<Id> hardDeleteLocList = new List<Id>();
    	
    	try{
    		
		        Database.DeleteResult[] dr = Database.delete(scope, false);
		        executeJob(dr, jobStatus);
		        for(Database.DeleteResult delLoc : dr){
		        	
	                  if(delLoc.isSuccess()){
	                      hardDeleteLocList.add(delLoc.getId());
	                  }
		        }
		        Database.emptyRecycleBin(hardDeleteLocList);
    	}catch(Exception e){
    		
    		if(jobStatus!=null && !jobStatus.isEmpty()){
                    String tempMsg = String.IsBlank(jobStatus[0].Comments__c) ? PL_Constants.SYSTEM_EXCEPTION + e.getMessage() + PL_Constants.NEW_LINE : jobStatus[0].Comments__c + PL_Constants.SYSTEM_EXCEPTION + e.getMessage() +PL_Constants.NEW_LINE;                                    
                    jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; 
                    Database.update(jobStatus[0]);   
             } 
    	}
    }
    
    global void finish(Database.BatchableContext bc){
        
       
         try{
            List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
            if(jobStatus!=null && !jobStatus.isEmpty()){ 
                jobStatus[0].Batch_End_Time__c = Datetime.now(); 
                jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? PL_Constants.BATCH_COMPLETE_WITH_SUCCESS : PL_Constants.BATCH_COMPLETE_WITH_FAIL ; 
                Database.update(jobStatus[0]); 
            } 
            
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage());
        }   
    }
    
    //Get job status    
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
        try{
            return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c,Batch_Start_Time__c, Batch_End_Time__c, 
               Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c, Total_RGU_ORders_Upserted_Today__c 
                     FROM Job_Status__c WHERE Status__c =: PL_Constants.JOB_STATUS_NEW 
                     AND ID= :jobStatusId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage());
            return null;
        }
    }
    
    //update jobstatus
    public void executeJob(Database.DeleteResult[] deleteLocations, List<Job_Status__c> jobStatus){
        try{
            if(!jobStatus.isEmpty()){
                for(Database.DeleteResult result : deleteLocations) {
                    jobStatus[0].Total_Records_Processed__c ++;
                    if(!result.isSuccess()){                                                 
                        for(Database.Error error : result.getErrors()){
                            jobStatus[0].Number_Of_Fallouts__c  ++;
                            String tempMsg = String.IsBlank(jobStatus[0].Comments__c) ? error.getMessage() + PL_Constants.NEW_LINE :jobStatus[0].Comments__c + error.getMessage() + PL_Constants.NEW_LINE;                                    
                            jobStatus[0].Comments__c=(tempMsg.length()>len)?tempMsg.substring(0,len):tempMsg;                                                                 
                         }
                    }       
                }
                Database.update(jobStatus[0]);
            } 
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage());
        }
    }
}