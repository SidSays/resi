/***************************************************************************************************************************************
 * Author     : Vivek Patel
 * Date       : 10-May-2013
 * Description: This batch will calculate Address statistics (for Node records) which are related to a Turf Plan.  
 * Requirement: 325 - Turf related statistics on Address Statistics object.
 * History
     Version             : 1.0
     Author Last Updated : Vivek Patel 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/

public class AddressesStatsCalculationNodeBatch implements Database.Batchable<sObject> {

    public String queryString='';

    
    
    /***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 10-May-2013
     * Param      : BatchableContext
     * Return     : Database.querylocator
     * Description: This method is called when the batch process starts and creates a SOQL to fetch existing Addres statistics.
    ************************************************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {   
        if(queryString==''){   
            queryString = 'Select Id, Num_of_Currently_Assigned__c, Percent_Currently_Assigned__c, Currently_Assigned_to_Turf__c, Assigned__c, Worked__c, Percent_Complex_Code__c, Node__c, Region__c from Address_Statistics__c where Node__c!=\'\' AND Node__c!=null AND Region__c!=null'; 
        }
        return Database.getQueryLocator(queryString);
    }
    
    /***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 10-May-2013
     * Param      : Database.BatchableContext, List<sObject>
     * Return     : None
     * Description: This method called after the start method to execute batch task. It calculates Address Statistics for Node records.
    ************************************************************************************************************************************/  
    public void execute(Database.BatchableContext bc, List<sObject>  scope) {       
        // Map to hold Node and number of addresses for that Node.       
        Map<String,Integer> nodeAndTotalAddressesMap = new Map<String,Integer>();
        Map<String,Integer> nodeAndAssignedAddressesMap = new Map<String,Integer>();
        Map<String,Integer> nodeAndAssignedAddressesLastDaysMap = new Map<String,Integer>();
        Map<String,Integer> nodeAndKnockedAddressesLastDaysMap = new Map<String,Integer>();
        Map<String,Integer> nodePropertyCodeMap = new Map<String,Integer>();
        Map<String,Integer> nodeRegionAddrPropertyCodeMap = new Map<String,Integer>();
        //Map<String,Address_Statistics__c> nodeAndAddrsStatsMap = new Map<String,Address_Statistics__c>();
        Map<String,Date> nodeAndLastAssignedDateMap = new Map<String,Date>();
        Map<String,Date> nodeAndLastKnockDateMap = new Map<String,Date>();
        Map<String,Integer> nodeAndWorkedAddressesLastDaysMap = new Map<String,Integer>();
        Set<String> nodeSet = new Set<String>();   
        Set<String> regionSet = new Set<String>();   
        List<String> propertyCodeList = new List<String>(); // List Created to Store the property Codes from the Addresses Object  User Story: US432420 , Sprint 1 Change Author: Lalit Singh date : 5/7/2015     
        List<Address_Statistics__c> addStats = scope;                
        Integer noOfDays;
        Double assignedPercentage;
        Boolean processBatch = true;        
        Integer noOfKnockedDays;
        Double knockedPercentage;
        Double currAssignedPercentage;
        Double currUnassignedPercentage;
        String AssignedStatsColour;
        String CurrentlyAssignedColour;
        String CurrentlyUnassignedColour;
        String DefaultColour;
        String KnockedStatsColour;
        //String Region;
        
        //Fetching configurable values from custom setting.
        try {
            noOfDays = (Integer) ConfigurableParameters__c.getValues('Config_ZipOrNodeAssignedDays').NumberValue__c;
            assignedPercentage = (Double) ConfigurableParameters__c.getValues('Config_PrevAssignedAddressPercentage').NumberValue__c;
            noOfKnockedDays = (Integer) ConfigurableParameters__c.getValues('Config_ZipOrNodeKnockedDays').NumberValue__c;
            knockedPercentage = (Double) ConfigurableParameters__c.getValues('Config_PrevKnockedAddressPercentage').NumberValue__c;
            currAssignedPercentage = (Double) ConfigurableParameters__c.getValues('Config_CurrAssignedPercentageCutOff').NumberValue__c;
            currUnassignedPercentage = (Double) ConfigurableParameters__c.getValues('Config_CurrUnassignedPercentageCutOff').NumberValue__c;
            AssignedStatsColour = Planning_Statistics_Colours__c.getValues('AssignedStatsColour').Colour__c;
            CurrentlyAssignedColour = Planning_Statistics_Colours__c.getValues('CurrentlyAssignedColour').Colour__c;
            CurrentlyUnassignedColour = Planning_Statistics_Colours__c.getValues('CurrentlyUnassignedColour').Colour__c;
            DefaultColour = Planning_Statistics_Colours__c.getValues('DefaultColour').Colour__c;
            KnockedStatsColour = Planning_Statistics_Colours__c.getValues('KnockedStatsColour').Colour__c;
        }catch(Exception ex) {
            processBatch = false;
            System.debug('No data found in custom setting:'+ex);
        }
    
        
        // Address Stats calculation will only be done if configurable values are set in Custom setting.
        if(processBatch) {
            String regionString = '';
            //Initializing different maps which will contain Node and number of addresses for that Node.
            for(Address_Statistics__c addStatObj : addStats){               
                regionString = addStatObj.Region__c.toLowerCase();//Added by Amit(US944455)                             
                nodeSet.add(addStatObj.Node__c);
                //nodeAndAddrsStatsMap.put(addStatObj.Node__c, addStatObj);
                nodeAndTotalAddressesMap.put(addStatObj.Node__c+':'+regionString, 0);
                nodeAndAssignedAddressesMap.put(addStatObj.Node__c+':'+regionString, 0);
                nodeAndKnockedAddressesLastDaysMap.put(addStatObj.Node__c+':'+regionString, 0);
                nodeAndAssignedAddressesLastDaysMap.put(addStatObj.Node__c+':'+regionString, 0);
                nodePropertyCodeMap.put(addStatObj.Node__c+':'+regionString,0);
                nodeRegionAddrPropertyCodeMap.put(addStatObj.Node__c+':'+regionString,0);
                regionSet.add(regionString);
            }
          
            //User Story: US432413 , Sprint 1 Change, Date : 5/12/2015, Author : Sucheta Verma
            //Remove The List and passed the query directly into the for Loop (Sucheta).           
            //Populate Maps which contains Node and number of Addresses in that Node.           
            for(Customer_Address__c addrsObj : [Select Id, Node__c, Assigned_Date__c, Plan__c, Last_Knock_Date__c, OwnerId, Region__c, Property_Code__c, Worked__c, WorkedDate__c from Customer_Address__c where Node__c in :nodeSet AND Region__c in :regionSet]){    
                regionString = addrsObj.Region__c.toLowerCase();//Added by Amit(US944455)
                propertyCodeList.add(addrsObj.Property_Code__c);            
                if(nodeRegionAddrPropertyCodeMap.get(addrsObj.Node__c+':'+regionString)!=null){
                    nodeRegionAddrPropertyCodeMap.put(addrsObj.Node__c+':'+regionString,nodeRegionAddrPropertyCodeMap.get(addrsObj.Node__c+':'+regionString) + 1);
                }else{
                    nodeRegionAddrPropertyCodeMap.put(addrsObj.Node__c+':'+regionString, 1);
                }
            
                if(nodeAndTotalAddressesMap.get(addrsObj.Node__c+':'+regionString)!=null){
                    nodeAndTotalAddressesMap.put(addrsObj.Node__c+':'+regionString,nodeAndTotalAddressesMap.get(addrsObj.Node__c+':'+regionString) + 1);
                }else{
                    nodeAndTotalAddressesMap.put(addrsObj.Node__c+':'+regionString, 1);
                }
               
               
                if(addrsObj.Plan__c != null) {
                    if(nodeAndAssignedAddressesMap.get(addrsObj.Node__c+':'+regionString)!=null){
                        nodeAndAssignedAddressesMap.put(addrsObj.Node__c+':'+regionString,nodeAndAssignedAddressesMap.get(addrsObj.Node__c+':'+regionString) + 1);                  
                    }else{
                        nodeAndAssignedAddressesMap.put(addrsObj.Node__c+':'+regionString, 1); 
                    }
                }
               
                if(addrsObj.Assigned_Date__c!= null) {
                    Date dateObj= Date.newinstance(addrsObj.Assigned_Date__c.year(), addrsObj.Assigned_Date__c.month(), addrsObj.Assigned_Date__c.day());       
                    if(dateObj+noOfDays >= System.Today()) {
                        if(nodeAndAssignedAddressesLastDaysMap.get(addrsObj.Node__c+':'+regionString)!=null){
                            nodeAndAssignedAddressesLastDaysMap.put(addrsObj.Node__c+':'+regionString,nodeAndAssignedAddressesLastDaysMap.get(addrsObj.Node__c+':'+regionString) + 1);
                        }
                        else{
                            nodeAndAssignedAddressesLastDaysMap.put(addrsObj.Node__c+':'+regionString,1);
                        }
                    }
                    if(nodeAndLastAssignedDateMap.get(addrsObj.Node__c+':'+regionString)!=null){
                        if(dateObj >= nodeAndLastAssignedDateMap.get(addrsObj.Node__c+':'+regionString)){
                            nodeAndLastAssignedDateMap.put(addrsObj.Node__c+':'+regionString,dateObj);
                        }
                    } else {
                        nodeAndLastAssignedDateMap.put(addrsObj.Node__c+':'+regionString,dateObj);
                    }
                }
                if(addrsObj.Last_Knock_Date__c!= null) {
                    Date dateObj1= Date.newinstance(addrsObj.Last_Knock_Date__c.year(), addrsObj.Last_Knock_Date__c.month(), addrsObj.Last_Knock_Date__c.day());       
                    if(dateObj1+noOfKnockedDays >= System.Today()) {  
                        if(nodeAndKnockedAddressesLastDaysMap.get(addrsObj.Node__c+':'+regionString)!=null){                             
                            nodeAndKnockedAddressesLastDaysMap.put(addrsObj.Node__c+':'+regionString,nodeAndKnockedAddressesLastDaysMap.get(addrsObj.Node__c+':'+regionString) + 1);
                        }
                        else{
                            nodeAndKnockedAddressesLastDaysMap.put(addrsObj.Node__c+':'+regionString,1);
                        }
                    }
                    if(nodeAndLastKnockDateMap.get(addrsObj.Node__c+':'+regionString)!=null){
                        if(dateObj1 >= nodeAndLastKnockDateMap.get(addrsObj.Node__c+':'+regionString)){
                            nodeAndLastKnockDateMap.put(addrsObj.Node__c+':'+regionString,dateObj1);
                        }
                    } else {
                        nodeAndLastKnockDateMap.put(addrsObj.Node__c+':'+regionString,dateObj1);
                    }
                }
                if(addrsObj.WorkedDate__c!=null){
                    Date dateObj2 = Date.newInstance(addrsObj.WorkedDate__c.year(), addrsObj.WorkedDate__c.month(), addrsObj.WorkedDate__c.day());
                    if(dateObj2+noOfKnockedDays >= System.today()){
                        if(nodeAndWorkedAddressesLastDaysMap.get(addrsObj.Node__c+':'+regionString)!=null){
                            nodeAndWorkedAddressesLastDaysMap.put(addrsObj.Node__c+':'+regionString, nodeAndWorkedAddressesLastDaysMap.get(addrsObj.Node__c+':'+regionString)+1);
                        }
                        else {
                            nodeAndWorkedAddressesLastDaysMap.put(addrsObj.Node__c+':'+regionString, 1);
                        }
                    }
                }
            }
                        
            //Set Last_Assigned_Date__c and Last_Knock_Date__c
            for(Address_Statistics__c addStatObj : addStats){
                regionString = addStatObj.Region__c.toLowerCase();//Added by Amit(US944455)
                if(nodeAndLastAssignedDateMap.get(addStatObj.Node__c+':'+regionString)!=null){
                    addStatObj.Last_Assigned_Date__c = nodeAndLastAssignedDateMap.get(addStatObj.Node__c+':'+regionString);
                }
                if(nodeAndLastKnockDateMap.get(addStatObj.Node__c+':'+regionString)!=null){
                    addStatObj.Last_Knock_Date__c = nodeAndLastKnockDateMap.get(addStatObj.Node__c+':'+regionString);
                }
            }

          
            //User Story: US432413, Sprint 1 Change, Date : 5/12/2015, Author :Sucheta Verma
            // Plan Name code Move to the New Batch : AddressesStatsToPlanCalculationNodeBatch                
            //set AddressPropertyCodes
                
            for(Address_Statistics__c addStatObj : addStats){
                regionString = addStatObj.Region__c.toLowerCase();//Added by Amit(US944455)
                String propertyCodes='';
                Integer noOfPropertyCodesOnNode=0;
                for(String pCode : propertyCodeList){
                    if(pCode != null && pCode != ''){
                        if(!propertyCodes.contains(pCode)){
                            propertyCodes += pCode + ',';
                        }
                        noOfPropertyCodesOnNode++;
                    }
                }
                
                nodePropertyCodeMap.put(addStatObj.Node__c+':'+regionString, noOfPropertyCodesOnNode);
                if(propertyCodes!=''){
                    String propertyCodes1='';
                    String propertyCodes2='';
                    String propertyCodes3='';
                    String propertyCodes4='';
                    String propertyCodes5='';

                    for(String name:propertyCodes.split(',')){
                         if (propertyCodes1.length() < 255 && propertyCodes1.length() + (name.length() + 1) <= 255)
                            {
                                propertyCodes1 += name + ',';
                            }
                            else if (propertyCodes2.length() < 255 && propertyCodes2.length() + (name.length() + 1) <= 255)
                            {
                                propertyCodes2 += name + ',';
                            }
                            else if (propertyCodes3.length() < 255 && propertyCodes3.length() + (name.length() + 1) <= 255)
                            {
                                propertyCodes3 += name + ',';
                            }
                            else if (propertyCodes4.length() < 255 && propertyCodes4.length() + (name.length() + 1) <= 255)
                            {
                                propertyCodes4 += name + ',';
                            }
                            else if (propertyCodes5.length() < 255 && propertyCodes5.length() + (name.length() + 1) <= 255)
                            {
                                propertyCodes5 += name + ',';
                            }
                    }
                    if(propertyCodes1 != ''){
                        addStatObj.AddressPropertyCodes1__c = propertyCodes1.substring(0,propertyCodes1.length()-1);
                    }else{
                        addStatObj.AddressPropertyCodes1__c=propertyCodes1;
                    }
                    if(propertyCodes2 != ''){
                        addStatObj.AddressPropertyCodes2__c = propertyCodes2.substring(0,propertyCodes2.length()-1);
                    }else{
                        addStatObj.AddressPropertyCodes2__c=propertyCodes2;
                    }
                     if(propertyCodes3 != ''){
                        addStatObj.AddressPropertyCodes3__c = propertyCodes3.substring(0,propertyCodes3.length()-1);
                    }else{
                        addStatObj.AddressPropertyCodes3__c=propertyCodes3;
                    }
                    if(propertyCodes4 != ''){
                        addStatObj.AddressPropertyCodes4__c = propertyCodes4.substring(0,propertyCodes4.length()-1);
                    }else{
                        addStatObj.AddressPropertyCodes4__c=propertyCodes4;
                    }
                     if(propertyCodes5 != ''){
                        addStatObj.AddressPropertyCodes5__c = propertyCodes5.substring(0,propertyCodes5.length()-1);
                    }else{
                        addStatObj.AddressPropertyCodes5__c=propertyCodes5;
                    }
                }
            }
            
            // User Story: US432413,Sprint 1 Change, Date : 5/12/2015, Author : Sucheta Verma
            // Plan User Code Move to the New Batch : AddressesStatsToPlanCalculationNodeBatch
            
            // Set value of 4 fields on Address stats records based on number and percentage of addresses assigned.
            for(Address_Statistics__c addStatObj : addStats ) {
                regionString = addStatObj.Region__c.toLowerCase();//Added by Amit(US944455)
                //Calculate Number of Currently Assigned/Unassigned
                addStatObj.Num_of_Currently_Assigned__c = nodeAndAssignedAddressesMap.get(addStatObj.Node__c+':'+regionString);
                addStatObj.Num_of_Currently_Unassigned__c =  nodeAndTotalAddressesMap.get(addStatObj.Node__c+':'+regionString) - nodeAndAssignedAddressesMap.get(addStatObj.Node__c+':'+regionString);
                
                Double lastDaysAssignedPercentage = 0;
                Double lastDaysKnockedPercentage = 0;
                Double lastDaysWorkedPercentage = 0;
                if(nodeAndTotalAddressesMap.get(addStatObj.Node__c+':'+regionString) != 0){

                    //Calculate Percentage of Currently Assigned/Unassigned
                    addStatObj.Percent_Currently_Assigned__c = (nodeAndAssignedAddressesMap.get(addStatObj.Node__c+':'+regionString) /(Double) nodeAndTotalAddressesMap.get(addStatObj.Node__c+':'+regionString)) * 100;
                    addStatObj.Percent_Currently_Unassigned__c = 100 - addStatObj.Percent_Currently_Assigned__c;

                    if(addStatObj.Percent_Currently_Assigned__c >= assignedPercentage){
                        addStatObj.Currently_Assigned_to_Turf__c = true;
                    }
                    else{
                        addStatObj.Currently_Assigned_to_Turf__c = false;
                    }             

                    //Calculate Percentage Of Addresses In Node that contain a Property Code
                    addStatObj.Percent_Complex_Code__c=(nodeRegionAddrPropertyCodeMap.get(addStatObj.Node__c+':'+regionString)/(Double) nodeAndTotalAddressesMap.get(addStatObj.Node__c+':'+regionString)) * 100;
                    
                    lastDaysAssignedPercentage = (nodeAndAssignedAddressesLastDaysMap.get(addStatObj.Node__c+':'+regionString) /(Double) nodeAndTotalAddressesMap.get(addStatObj.Node__c+':'+regionString)) * 100;
                        
                    addStatObj.Assigned_in_last__c = String.valueOf(noOfDays) + 'Days : ' +  String.valueOf(lastDaysAssignedPercentage) + '%';
                        
                    lastDaysKnockedPercentage = (nodeAndKnockedAddressesLastDaysMap.get(addStatObj.Node__c+':'+regionString) /(Double) nodeAndTotalAddressesMap.get(addStatObj.Node__c+':'+regionString)) * 100;
                            
                    addStatObj.Knocked_in_last__c = String.valueOf(noOfKnockedDays) + 'Days : ' + String.valueOf(lastDaysKnockedPercentage) + '%';
                    
                    if(nodeAndWorkedAddressesLastDaysMap.containsKey(addStatObj.Node__c+':'+regionString)){
                        lastDaysWorkedPercentage = (nodeAndWorkedAddressesLastDaysMap.get(addStatObj.Node__c+':'+regionString) / (Double) nodeAndTotalAddressesMap.get(addStatObj.Node__c+':'+regionString)) * 100;
                    }

                    if(lastDaysAssignedPercentage >= assignedPercentage){
                        addStatObj.Assigned__c = true;
                    }
                    else{
                        addStatObj.Assigned__c = false;
                    }   
                    // Validate if knocked percentage greater than threshold
                    if(lastDaysKnockedPercentage != null && knockedPercentage != null){
                        if(lastDaysKnockedPercentage >= knockedPercentage){
                            addStatObj.Knocked__c = true;
                        } else {
                            addStatObj.Knocked__c = false; 
                        }
                    }
                    if(lastDaysWorkedPercentage != null && knockedPercentage != null){
                        if(lastDaysWorkedPercentage >= knockedPercentage){
                            addStatObj.Worked__c = true;
                        } else {
                            addStatObj.Worked__c = false;
                        }
                    }
                }
                // Logic to comeup with Colour Code for Map Pin Point ;
                if(addStatObj.Worked__c == true){
                    addStatObj.Colour__c = KnockedStatsColour; 
                } else if(addStatObj.Assigned__c == true){
                    addStatObj.Colour__c = AssignedStatsColour; 
                } else if(addStatObj.Percent_Currently_Assigned__c >=  currAssignedPercentage){
                    addStatObj.Colour__c = CurrentlyAssignedColour; 
                } else if(addStatObj.Percent_Currently_Unassigned__c >=  currUnassignedPercentage){
                    addStatObj.Colour__c = CurrentlyUnassignedColour; 
                }else {
                    addStatObj.Colour__c = DefaultColour;
                }
            }
            try {                
                Database.update(addStats,false);                
            } catch(Exception ex) {
                System.debug('Following exception occurred :'+ex.getMessage());
            }
        }
    }
    
    /***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 10-May-2013
     * Param      : Database.BatchableContext
     * Return     : None
     * Description: This method is called at the end after execute method completes for any notification etc. This method is not used in this class but because of Interface which this class implements this methods is present here.
    ************************************************************************************************************************************/ 
    public void finish(Database.BatchableContext bc) {
        //User Story: US432413, Sprint 1 Change, Date : 5/12/2015, Author : Sucheta Verma
        // Calling the Second Batch.
        AddressesStatsToPlanCalculationNodeBatch AddressesStatsToPlanCalculationNodeBatchobj = new AddressesStatsToPlanCalculationNodeBatch();
        Database.executeBatch(AddressesStatsToPlanCalculationNodeBatchobj , 1);
    }
}