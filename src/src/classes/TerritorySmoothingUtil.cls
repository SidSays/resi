/**
    * @Description: This class will have all the utilites methods for Territory Smoothing batch. This mainly include methods for Address update, plan update, Census tract update and Job status update.
    * @Author: Amit Kumar - Accenture
    * @Date: 11 May 2017 
    * @Param: NA
    * @return: NA
*/    
public class TerritorySmoothingUtil {
    public FINAL static Integer len= Job_Status__c.Comments__c.getDescribe().getLength();  //Get the Length of Comment field of Job Status object
    
/**
    * Name: updateaddresses
    * @Description: This method will be use to update the address with new territory. Following are the main objective:
                    1. Update the new territory
                    2. Plan needs to be set to null so that this gets expires. 
                    3. Method will  have boolean variable which define whether plan needs to be expires or not   
    * @Author: Accenture
    * @Date: 11 May 2017 
    * @Param: list of address record, map of censustract id and their object,list of Job status and boolen to signify batch or trigger
    * @return: NA
*/  
    public static void updateaddresses(list<Customer_Address__c> lstaddresses,map<string,CensusTract__c> mapcensustoterritory,List<Job_Status__c> jobStatus,boolean isbatch){
        list<Customer_Address__c> lstupdateaddress = new list<Customer_Address__c>();
        string strsharddatauser = Variable_Setting__c.getInstance('ShareDataUser') != null ? Variable_Setting__c.getInstance('ShareDataUser').Value__c : '' ;
        User sharedData = [Select Id, Name from User where Name=:strsharddatauser LIMIT 1];
        for(Customer_Address__c objaddress:lstaddresses){   //Iterate the customer address 
            if(mapcensustoterritory.containskey(objaddress.Census_Tract__c)){   // check the address falls under changed census tract
                objaddress.Territory__c = mapcensustoterritory.get(objaddress.Census_Tract__c).Territory__c;   // update the territory based on census tract and territory.
                objaddress.Plan__c = null;   // update the plan to null.
                objaddress.ownerId = sharedData.id; //update the owener id
                objaddress.Team__c = null;
                   
                lstupdateaddress.add(objaddress);   //add the updated address on the address list 
            }
        }
        if(!lstupdateaddress.Isempty()){
            Database.saveResult[] ur = database.update(lstupdateaddress,false);
            if(isbatch){
                TerritorySmoothingUtil.executeJob(ur, jobStatus);
            }
        }
    }
/**
    * Name: expireplans
    * @Description: This method will be use to Expire the plans Following values will be updated
    				Plan status
    				Number of Address
    				Number of Excluded Address
    				True count of Address
    				Expiration Date                  
    * @Author: Accenture
    * @Date: 11 May 2017 
    * @Param: list of Plan record, list of Job status and boolen to signify batch or trigger
    * @return: NA
*/  
    public static void expireplans(list<Plan__c> lstplan,List<Job_Status__c> jobStatus,boolean isbatch){
        map<Id,Plan__c> mapplans = new map<Id,Plan__c>();  //Create a map of Updateting the Plan
        for(Plan__c objplan:lstplan){
            objplan.Plan_Status__c = Label.PlanStatusExpired;
            objplan.Number_of_Addresses__c=0;
            objplan.Number_of_Excluded_Addresses__c=0;
            objplan.True_count_of_Addresses__c=0;
            objplan.Expiration_Date__c = system.today();
            mapplans.put(objplan.id,objplan);  //Add the modified record in map to remove the duplicate plan. This is added to safeguard. Ideally duplicate might not come.
        }
        if(!(mapplans.values().Isempty())){
            
            Database.saveResult[] ur = database.update(mapplans.values(),false);//Update the Plan records
            if(isbatch){
                TerritorySmoothingUtil.executeJob(ur, jobStatus);
            }
        }    
    }
/**
    * Name: updatecensustract
    * @Description: This method will be use to update the Census Tract record. This method will set the Territory Changed Processed to false once batch processing is comppleted                  
    * @Author: Accenture
    * @Date: 11 May 2017  
    * @Param: list of Census tract record, list of Job status and boolen to signify batch or trigger
    * @return: NA
*/  
    public static void updatecensustract(list<CensusTract__c> lstcensus,List<Job_Status__c> jobStatus,boolean isbatch){
        map<Id,CensusTract__c> mapcensus = new map<Id,CensusTract__c>();
        for(CensusTract__c objcensus:lstcensus){
            objcensus.Territory_Changed__c = false;
            mapcensus.put(objcensus.id,objcensus);  //Add the modified record in map to remove the duplicate Census Tract record. This is added to safeguard. Ideally duplicate might not come.
        }
        if(!(mapcensus.values().Isempty())){
            
            Database.saveResult[] ur = database.update(mapcensus.values(),false);
            if(isbatch){
                TerritorySmoothingUtil.executeJob(ur, jobStatus);
            }
        }    
    }    
/**
    * Name: executeJob
    * @Description: This method will be use update the Job status records once processing for a particular batch is completed.                 
    * @Author: Accenture
    * @Date: 11 May 2017  
    * @Param: list of saveresult, list of Job status 
    * @return: NA
*/  

//update jobstatus
    public static void executeJob(Database.saveresult[] lstupdateresult, List<Job_Status__c> jobStatus){
        try{
            if(!jobStatus.isEmpty()){
                for(Database.saveresult result : lstupdateresult) {
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