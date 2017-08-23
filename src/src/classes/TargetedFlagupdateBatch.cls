/**************************************************************************************************
Name : TerritorySmoothingBatch
Description :  This batch class will be use to update th address and expire the plan if Territory is changed in Census Tract object.
User Story : US1103983
Date : 11 May 2017
Author : Amit Kumar - Accenture 
***************************************************************************************************/
global class TargetedFlagupdateBatch implements  Database.Batchable<sObject>, Database.Stateful{
    
    private String query;
    private Id jobStatusId = null;
    private set<string> setregion = new set<string>();
    private Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
    
    /*  
    *Constructor to process the region passed from scheduler or developer console
    */
    global TargetedFlagupdateBatch (set<string> setregions){
    	if(!setregions.Isempty()){
    		for(string strregion:setregions){
    			if(strregion != ''){
    				this.setregion.add(strregion);
    			}
    		}	
    	}
   }//End of Constructor
    /* Method Name: Start
    * Description: This method will insert a Job status record to capture the records processed in the batch job and this method will also query the address records based on the parmeter passed in the query
    * @Param: Batchable context
    *@Retrun: query locatore of Address records.
    */
    global Database.QueryLocator start(Database.BatchableContext bc){
    	/* Job Status Record Creation**************START***********************/
        Job_Status__c job = new Job_Status__c();
        job.Name = 'TargetedFlagupdateBatch' + PL_Constants.JOB_NAME_SPACE  + Datetime.now();
        job.Status__c = PL_Constants.JOB_STATUS_NEW;
        job.Total_Records_Processed__c = 0;
        job.Total_RGU_Activations_Processed__c = 0;
        job.Total_RGU_Orders_Processed__c = 0;
        job.Total_RGU_ORders_Upserted_Today__c = 0;
        job.Batch_Start_Time__c = Datetime.now();
        job.Comments__c = PL_Constants.JOB_COMMENT;
        job.Number_Of_Fallouts__c = 0;
        
        insert(job); 
        /* Job Status Record Creation**************End***********************/
        jobStatusId = job.Id; 
        query =  Variable_Setting__c.getInstance('Targeted _flag_Query') != null ? Variable_Setting__c.getInstance('Targeted _flag_Query').Value__c : '';//Get the query from custom setting
        return Database.getQueryLocator(query); //Query the records
    }//End of start method
    
    /*
    *Performs the Address, Plan and Census tract recrods.
    *@Param:bachable conteaxt and list of address records
    *@return: None
    */
    global void execute(Database.BatchableContext bc, List<Customer_Address__c> lstaddresses){
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        list<Customer_Address__c> lstaddressupdate = new list<Customer_Address__c>();
        
        //Iterate all the Customer Address and update the Targeted Flag to false
        try{
            for(Customer_Address__c objaddress:lstaddresses){  //Start of for loop to get the address and update the targeted flag.
            	objaddress.Targeted__c  = false;
            	lstaddressupdate.add(objaddress);
            }
            //
            //Call method to update Address
            if(!lstaddressupdate.IsEmpty()){ 
               Database.saveResult[] ur =  database.update(lstaddressupdate,false);
                TerritorySmoothingUtil.executeJob(ur, jobStatus);
            } 
            //End method to update Address
            
        }catch(exception e){            if(jobStatus!=null && !jobStatus.isEmpty()){                    String tempMsg = String.IsBlank(jobStatus[0].Comments__c) ? PL_Constants.SYSTEM_EXCEPTION + e.getMessage() + PL_Constants.NEW_LINE : jobStatus[0].Comments__c + PL_Constants.SYSTEM_EXCEPTION + e.getMessage() +PL_Constants.NEW_LINE;  jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg;                     Database.update(jobStatus[0]);   
             } 
        }//End of Catch
    } //End of Execute method.
    
    global void finish(Database.BatchableContext bc){
         try{
            List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
            if(jobStatus!=null && !jobStatus.isEmpty()){ 
                jobStatus[0].Batch_End_Time__c = Datetime.now(); 
                jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? PL_Constants.BATCH_COMPLETE_WITH_SUCCESS : PL_Constants.BATCH_COMPLETE_WITH_FAIL ; 
                Database.update(jobStatus[0]); 
            } 
            
        }catch(Exception e){ System.debug('Exception : '+e.getMessage());
        }   
    }
    //Get job status    
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
        try{
            return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c,Batch_Start_Time__c, Batch_End_Time__c, 
               Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c, Total_RGU_ORders_Upserted_Today__c 
                     FROM Job_Status__c WHERE Status__c =: PL_Constants.JOB_STATUS_NEW 
                     AND ID= :jobStatusId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
        }catch(Exception e){ System.debug('Exception : '+e.getMessage()); return null;
        }
    }
    
}