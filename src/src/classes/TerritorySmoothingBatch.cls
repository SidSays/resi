/**************************************************************************************************
Name : TerritorySmoothingBatch
Description :  This batch class will be use to update th address and expire the plan if Territory is changed in Census Tract object.
User Story : US1103983
Date : 11 May 2017
Author : Amit Kumar - Accenture 
***************************************************************************************************/
global class TerritorySmoothingBatch implements  Database.Batchable<sObject>, Database.Stateful{
    
    private String query;
    private Id jobStatusId = null;
    private map<string,CensusTract__c> mapcensusterritory = new map<string,CensusTract__c>();
    private set<string> setuniquecenscus = new set<string>();
    private set<id> setplans = new set<id>();
    private set<string> setcensusnumbers = new set<string>();
    private Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
    
    /*  
    *Constructor to pass query for batch execution
    */
    global TerritorySmoothingBatch(String regioncode,map<string,CensusTract__c> mapcensusterritory){
        this.mapcensusterritory = mapcensusterritory;
        list<CensusTract__c> lstcensustract = [SELECT id, Territory__c, CensusTractNumber__c, Territory__r.Territory_Region__c,Old_Territory_Region__c FROM CensusTract__c 
        										where (Territory__r.Territory_Region__c=:regioncode OR  Old_Territory_Region__c =: regioncode) AND 
        										CensusTractNumber__c IN: mapcensusterritory.keyset() ]; //Query to get the Modified Census record based on region and Census number
        if(!lstcensustract.Isempty()){  //Empty check for the list
        	for(CensusTract__c objtract:lstcensustract){ //Iterate through the Census Record
            	if(objtract.CensusTractNumber__c!=null){  //Check if Cencus record is null
                	setuniquecenscus.add(objtract.CensusTractNumber__c);  //Add census tract number if a set.
            	}
        	}
        }//end of Census Isempty check
   }//End of Constructor
    /* Method Name: Start
    * Description: This method will insert a Job status record to capture the records processed in the batch job and this method will also query the address records based on the parmeter passed in the query
    * @Param: Batchable context
    *@Retrun: query locatore of Address records.
    */
    global Database.QueryLocator start(Database.BatchableContext bc){
    	/* Job Status Record Creation**************START***********************/
        Job_Status__c job = new Job_Status__c();
        job.Name = 'TerritorySmoothingBatch' + PL_Constants.JOB_NAME_SPACE  + Datetime.now();
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
        query =  Variable_Setting__c.getInstance('Territorybatchquery') != null ? Variable_Setting__c.getInstance('Territorybatchquery').Value__c : '';//Get the query from custom setting
        return Database.getQueryLocator(query); //Query the records
    }//End of start method
    
    /*
    *Performs the Address, Plan and Census tract recrods.
    *@Param:bachable conteaxt and list of address records
    *@return: None
    */
    global void execute(Database.BatchableContext bc, List<Customer_Address__c> lstaddresses){
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        list<CensusTract__c> lstcensucupdate = new list<CensusTract__c>();
        
        string bexpireplan =  Variable_Setting__c.getInstance('TerritoryExpirePlan') != null ? Variable_Setting__c.getInstance('TerritoryExpirePlan').Value__c : '';
        //call the method to expire plan with territory change
        try{
            for(Customer_Address__c objaddress:lstaddresses){  //Start of for loop to ge the unique plan and Unique census number from Address
            	if(objaddress.plan__c!=null && !(setplans.contains(objaddress.plan__c))){// This if condition will make sure only valid Plan gets added in the set, even if plan comes in different batches
                	setplans.add(objaddress.plan__c);  //Get the unique plan records from Address
                }
                if(objaddress.Census_Tract__c!=null && !(setcensusnumbers.contains(objaddress.Census_Tract__c))){  // This if condition will make sure only valid Census tract gets added in the set, even if plan comes in different batches
                	setcensusnumbers.add(objaddress.Census_Tract__c);   //Get the Census tract  records from Address
                }
           	}//End of for loop to ge the unique plan and Unique census number from Address
                if(bexpireplan.equalsIgnoreCase('True')){ //Check if Plan needs to be expire with Territory smoothing. If this is true then Plan will also expire with Territory update
	                if(!setplans.Isempty()){ //Check if address are linked to a Plan
	                    list<Plan__c> lstplan = [Select id,name,Plan_Status__c,Plan_Level__c,Number_of_Addresses__c,Number_of_Excluded_Addresses__c,True_count_of_Addresses__c,Expiration_Date__c,Number_of_Addresses_Currently_on_Plan__c
	                                            from Plan__c where Id IN:setplans AND Plan_Status__c !=: Label.PlanStatusExpired ];  //Query the plan associated with 
	                    TerritorySmoothingUtil.expireplans(lstplan,jobStatus,true); //Expire all the plan associated with Territory
	                }
            }
            //Method End to Expire Plan
            //Call method to update Territory
            if(!lstaddresses.IsEmpty()){ 
                TerritorySmoothingUtil.updateaddresses(lstaddresses,mapcensusterritory,jobStatus,true); //Call method to change the Address with new territory, plan and Owener Id.
            } 
            //End method to update Territory
            
            //Update the Census tract
            if(!setcensusnumbers.Isempty()){
            	lstcensucupdate= [Select id, Territory_Changed__c  from CensusTract__c where CensusTractNumber__c IN:setcensusnumbers];
            	if(!lstcensucupdate.Isempty()){
            		TerritorySmoothingUtil.updatecensustract(lstcensucupdate,jobStatus,true); //Call method to update the Territory changes flaged 
            	}
            }//End of Census Tract update 
        }catch(exception e){
            if(jobStatus!=null && !jobStatus.isEmpty()){
                    String tempMsg = String.IsBlank(jobStatus[0].Comments__c) ? PL_Constants.SYSTEM_EXCEPTION + e.getMessage() + PL_Constants.NEW_LINE : jobStatus[0].Comments__c + PL_Constants.SYSTEM_EXCEPTION + e.getMessage() +PL_Constants.NEW_LINE;                                    
                    jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; 
                    Database.update(jobStatus[0]);   
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