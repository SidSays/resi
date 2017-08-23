/**************************************************************************************************
Name : ExpirePlansAndUpdateAddressesBatch
Description :  This batch class will be use to expire all plans in Regions and update Addresses.
User Story : US1103983
Date : 19 May 2017
Author : Sagarika/Deepika - Accenture 
***************************************************************************************************/
global class ExpirePlansAndUpdateAddressesBatch implements  Database.Batchable<sObject>, Database.Stateful{
    
    private String query;
    private Id jobStatusId = null;
    private Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
    private static final string NEW_LINE = '\n';
    private set<string> setregion = new set<string>();
    List<Plan__c> plans = null;
    Set<String> planIds = new set<String>();
    
    /*  
    *Constructor to process the region passed from scheduler or developer console
    */
    global ExpirePlansAndUpdateAddressesBatch (set<string> setregions){
      if(!setregions.Isempty()){
        for(string strregion:setregions){
          if(strregion != ''){
            this.setregion.add(strregion);
          }
        } 
        string planquery = Label.ExpirePlanQuery;
        system.debug('planquery-->'+planquery);
        this.plans = database.query(planquery);
        system.debug('plans-->'+plans);
        if(!plans.isEmpty()){
            for(Plan__c plan : plans)
            {
                this.planIds.add(plan.Id);
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
        job.Name = 'ExpirePlansAndUpdateAddressesBatch' + PL_Constants.JOB_NAME_SPACE  + Datetime.now();
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
        string addquery = Variable_Setting__c.getInstance('ExpireAddressQuery').Value__c;
        return Database.getQueryLocator(addquery); //Query the records
    }//End of start method
    
    /*
    *Performs the Address, Plan and Census tract recrods.
    *@Param:bachable conteaxt and list of address records
    *@return: None
    */
    global void execute(Database.BatchableContext bc, List<Customer_Address__c> addressOnPlan){
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        List<Customer_Address__c> addressToUpdate = new list<Customer_Address__c>();
        Set<String> plannIds = new Set<String>();
        for(Customer_Address__c objaddress:addressOnPlan){
            plannIds.add(objaddress.Plan__c);
        }
        
        list<plan__c> lstplan = [Select Id, Plan_Status__c From Plan__c where Plan_Status__c != 'Expired' AND Id IN:plannIds];
            
        //Expire all plans and update all addresses on plan
        try{
            //Method End to Expire Plan
            if(!lstplan.IsEmpty()){
                TerritorySmoothingUtil.expireplans(lstplan,jobStatus,true);
            }
            
            string strsharddatauser = Variable_Setting__c.getInstance('ShareDataUser') != null ? Variable_Setting__c.getInstance('ShareDataUser').Value__c : '' ;
            User sharedData = [Select Id, Name from User where Name=:strsharddatauser LIMIT 1];
            for(Customer_Address__c address :addressOnPlan){  
                    address.Plan__c = null;   
                    address.ownerId = sharedData.id; 
                    address.Team__c = null;
                    
                    addressToUpdate.add(address);    
            }
            
            Database.SaveResult[] updatedAddresses = Database.update(addressToUpdate,false);
            if(jobStatus!=null && !jobStatus.isEmpty()){
                for(Database.SaveResult result : updatedAddresses) {
                    jobStatus[0].Total_Records_Processed__c ++;
                    if(!result.isSuccess()){                                                 
                        for(Database.Error error : result.getErrors()){   jobStatus[0].Number_Of_Fallouts__c  ++;   String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  error.getMessage() + NEW_LINE : jobStatus[0].Comments__c + error.getMessage() + NEW_LINE;         jobStatus[0].Comments__c=(tempMsg.length()>len)?tempMsg.substring(0,len):tempMsg;                                                                 
                        }
                    }      
                }
                Database.update(jobStatus[0]);
            }
        }catch(exception e){if(jobStatus!=null && !jobStatus.isEmpty()){ String tempMsg = String.IsBlank(jobStatus[0].Comments__c) ? PL_Constants.SYSTEM_EXCEPTION + e.getMessage() + PL_Constants.NEW_LINE : jobStatus[0].Comments__c + PL_Constants.SYSTEM_EXCEPTION + e.getMessage() +PL_Constants.NEW_LINE;   Database.update(jobStatus[0]);   
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
    
}