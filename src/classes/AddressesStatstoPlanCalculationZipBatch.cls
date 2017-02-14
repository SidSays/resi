/***************************************************************************************************************************************
 * Author     : Lalit Singh
 * Date       : 05-May-2015
 * Description: Batch Created to calculate the Plan Names,Plan Users based on the Zip Code and Region Of the Address Statistics, It will Run After the AddressStatsCalculationZipBatch User Story Number : US432420 .  
 * Requirement: 325 - Plan related statistics on Address Statistics object.
 * History
     Version             : 1.0
     Author Last Updated : Lalit Singh
     PROJECT             : Residential
***************************************************************************************************************************************/
public class AddressesStatstoPlanCalculationZipBatch implements Database.Batchable<sObject>{
	public String queryString='';
	
	public Database.QueryLocator start(Database.BatchableContext bc) {
        if(queryString==''){
            queryString = 'Select Id, Num_of_Currently_Assigned__c, Percent_Currently_Unassigned__c , Num_of_Currently_Unassigned__c , Knocked__c, Worked__c, Percent_Currently_Assigned__c, Latitude__c, Longitude__c, Colour__c, Currently_Assigned_to_Turf__c, Assigned__c, Assigned_in_last__c, Knocked_in_last__c, Percent_Complex_Code__c, Zip_Code__c, Region__c from Address_Statistics__c where Zip_Code__c!=\'\''; 
        }
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject>  scope) { 
    	List<Address_Statistics__c> addStats = scope; 
    	
    	String planQuery = 'Select Id, Name, User__c, Assigned_To_CAR__c, Assigned_Team__c, Assigned_Team__r.All_Team_Members__c, Region__c, Address_Zip_Codes__c From Plan__c Where Plan_Status__c IN (\'Assigned\',\'Draft\') AND ';
            for(Address_Statistics__c addStatObj : addStats){
                planQuery += '(Region__c = \''+ addStatObj.Region__c +'\' AND (Address_Zip_Codes__c LIKE \'%'+ addStatObj.Zip_Code__c +'%\' OR Address_Zip_Codes__c LIKE \''+ addStatObj.Zip_Code__c +'%\' OR Address_Zip_Codes__c = \''+ addStatObj.Zip_Code__c +'\')) OR ';
            }
            System.debug(planQuery);
            planQuery = planQuery.substring(0,planQuery.length()-4);
            System.debug(planQuery);
            List<Plan__c> plans = new List<Plan__c>();
            plans = Database.Query(planQuery);

            String planNames = '';
            Map<String,Set<String>> addStatIdToAssigneeIds = new Map<String,Set<String>>();
            
            for(Address_Statistics__c addStatObj : addStats){
                Set<String> planUserIds = new Set<String>();
                for(Plan__c plan : plans){
                    system.debug(plan.Region__c);
                    system.debug(addStatObj.Region__c);
                    system.debug(plan.Address_Zip_Codes__c);
                    system.debug(addStatObj.Zip_Code__c);
                    if(plan.Region__c == addStatObj.Region__c && plan.Address_Zip_Codes__c.contains(addStatObj.Zip_Code__c)){
                        planNames += plan.Name + ',';
                    }
                    if(plan.User__c != null){
                        if(addStatIdToAssigneeIds.containsKey(addStatObj.Id)){
                            planUserIds = addStatIdToAssigneeIds.get(addStatObj.Id);
                            planUserIds.add(plan.User__c);
                            addStatIdToAssigneeIds.put(addStatObj.Id, planUserIds);
                        } else {
                            planUserIds = new Set<String>();
                            planUserIds.add(plan.User__c);
                            addStatIdToAssigneeIds.put(addStatObj.Id, planUserIds);
                        }
                    }
                    if(plan.Assigned_To_CAR__c != null){
                        if(addStatIdToAssigneeIds.containsKey(addStatObj.Id)){
                            planUserIds = addStatIdToAssigneeIds.get(addStatObj.Id);
                            planUserIds.add(plan.Assigned_To_CAR__c);
                            addStatIdToAssigneeIds.put(addStatObj.Id, planUserIds);
                        } else {
                            planUserIds = new Set<String>();
                            planUserIds.add(plan.Assigned_To_CAR__c);
                            addStatIdToAssigneeIds.put(addStatObj.Id, planUserIds);
                        }
                    }
                    if(plan.Assigned_Team__c != null && plan.Assigned_Team__r.All_Team_Members__c!=null){
                        if(addStatIdToAssigneeIds.containsKey(addStatObj.Id)){
                            planUserIds = addStatIdToAssigneeIds.get(addStatObj.Id);
                            for(String str : plan.Assigned_Team__r.All_Team_Members__c.split(',',0)){
                                if(str != ''){
                                    planUserIds.add(str);
                                }
                            }
                            addStatIdToAssigneeIds.put(addStatObj.Id, planUserIds);
                        } else {
                            planUserIds = new Set<String>();
                            for(String str : plan.Assigned_Team__r.All_Team_Members__c.split(',',0)){
                                if(str != ''){
                                    planUserIds.add(str);
                                }
                            }
                            addStatIdToAssigneeIds.put(addStatObj.Id, planUserIds);
                        }
                        if(!planUserIds.isEmpty() && addStatIdToAssigneeIds.containsKey(addStatObj.Id)){
                            Set<String> tempSet = new Set<String>();
                            tempSet = addStatIdToAssigneeIds.get(addStatObj.Id);
                            planUserIds.addAll(tempSet);
                            addStatIdToAssigneeIds.put(addStatObj.Id, planUserIds);
                        } else if(!planUserIds.isEmpty()){
                            addStatIdToAssigneeIds.put(addStatObj.Id, planUserIds);
                        }
                    }
                }
                if(planNames!=''){
                    String planNames1='';
                    String planNames2='';
                    String planNames3='';
                    String planNames4='';
                    String planNames5='';

                    for(String name:planNames.split(',')){
                         if (planNames1.length() < 255 && planNames1.length() + (name.length() + 1) <= 255)
                            {
                                planNames1 += name + ',';
                            }
                            else if (planNames2.length() < 255 && planNames2.length() + (name.length() + 1) <= 255)
                            {
                                planNames2 += name + ',';
                            }
                            else if (planNames3.length() < 255 && planNames3.length() + (name.length() + 1) <= 255)
                            {
                                planNames3 += name + ',';
                            }
                            else if (planNames4.length() < 255 && planNames4.length() + (name.length() + 1) <= 255)
                            {
                                planNames4 += name + ',';
                            }
                            else if (planNames5.length() < 255 && planNames5.length() + (name.length() + 1) <= 255)
                            {
                                planNames5 += name + ',';
                            }
                    }
                    if(planNames1 != ''){
                        addStatObj.PlanNames1__c = planNames1.substring(0,planNames1.length()-1);
                    }else{
                        addStatObj.PlanNames1__c=planNames1;
                    }
                    if(planNames2 != ''){
                        addStatObj.PlanNames2__c = planNames2.substring(0,planNames2.length()-1);
                    }else{
                        addStatObj.PlanNames2__c=planNames2;
                    }
                    if(planNames3 != ''){
                        addStatObj.PlanNames3__c = planNames3.substring(0,planNames3.length()-1);
                    }else{
                        addStatObj.PlanNames3__c=planNames3;
                    }
                    if(planNames4 != ''){
                        addStatObj.PlanNames4__c = planNames4.substring(0,planNames4.length()-1);
                    }else{
                        addStatObj.PlanNames4__c=planNames4;
                    }
                    if(planNames5 != ''){
                        addStatObj.PlanNames5__c = planNames5.substring(0,planNames5.length()-1);
                    }else{
                        addStatObj.PlanNames5__c=planNames5;
                    }
                }
            }
            
            
            
            Set<String> userIds = new Set<String>();
            for(String addStatId : addStatIdToAssigneeIds.keySet()){
                userIds.addAll(addStatIdToAssigneeIds.get(addStatId));
            }
            List<User> users = new List<User>();
            if(!userIds.isEmpty()){
                users = [Select Id, Name From User Where Id IN: userIds];
            }
            String planUsers='';
            for(Address_Statistics__c addStatObj : addStats){
                for(User u : users){
                    if(addStatIdToAssigneeIds.containsKey(addStatObj.Id) && addStatIdToAssigneeIds.get(addStatObj.Id).contains(u.Id)){
                        planUsers += u.Name + ',';
                    }
                }
                if(planUsers!=''){
                    String planUsers1='';
                    String planUsers2='';
                    String planUsers3='';
                    String planUsers4='';
                    String planUsers5='';

                    for(String name:planUsers.split(',')){
                         if (planUsers1.length() < 255 && planUsers1.length() + (name.length() + 1) <= 255)
                            {
                                planUsers1 += name + ',';
                            }
                            else if (planUsers2.length() < 255 && planUsers2.length() + (name.length() + 1) <= 255)
                            {
                                planUsers2 += name + ',';
                            }
                            else if (planUsers3.length() < 255 && planUsers3.length() + (name.length() + 1) <= 255)
                            {
                                planUsers3 += name + ',';
                            }
                            else if (planUsers4.length() < 255 && planUsers4.length() + (name.length() + 1) <= 255)
                            {
                                planUsers4 += name + ',';
                            }
                            else if (planUsers5.length() < 255 && planUsers5.length() + (name.length() + 1) <= 255)
                            {
                                planUsers5 += name + ',';
                            }
                    }
                    if(planUsers1 != ''){
                        addStatObj.PlanAssignees1__c = planUsers1.substring(0,planUsers1.length()-1);
                    }else{
                        addStatObj.PlanAssignees1__c=planUsers1;
                    }
                    if(planUsers2 != ''){
                        addStatObj.PlanAssignees2__c = planUsers2.substring(0,planUsers2.length()-1);
                    }else{
                        addStatObj.PlanAssignees2__c=planUsers2;
                    }
                     if(planUsers3 != ''){
                        addStatObj.PlanAssignees3__c = planUsers3.substring(0,planUsers3.length()-1);
                    }else{
                        addStatObj.PlanAssignees3__c=planUsers3;
                    } if(planUsers4 != ''){
                        addStatObj.PlanAssignees4__c = planUsers4.substring(0,planUsers4.length()-1);
                    }else{
                        addStatObj.PlanAssignees4__c=planUsers4;
                    }
                    if(planUsers5 != ''){
                        addStatObj.PlanAssignees5__c = planUsers5.substring(0,planUsers5.length()-1);
                    }else{
                        addStatObj.PlanAssignees5__c=planUsers5;
                    }
                }
            }
            
            try {
		            Database.update(addStats, false);
	        } 
	        
	        catch(Exception ex) {
		            System.debug('Following exception occurred :'+ex.getMessage());
	        }
    }
    
     public void finish(Database.BatchableContext bc) {
     	
     }
}