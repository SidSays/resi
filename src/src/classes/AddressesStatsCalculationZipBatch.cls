/***************************************************************************************************************************************
 * Author     : Vivek Patel
 * Date       : 09-May-2013
 * Description: This batch will calculate Address statistics (for Zip Code records) which are related to a Turf Plan.  
 * Requirement: 325 - Turf related statistics on Address Statistics object.
 * History
     Version             : 1.0
     Author Last Updated : Amitkumar Bangad
     PROJECT             : Direct Sales
***************************************************************************************************************************************/

public class AddressesStatsCalculationZipBatch implements Database.Batchable<sObject> {

    public String queryString='';
    
    /***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 09-May-2013
     * Param      : BatchableContext
     * Return     : Database.querylocator
     * Description: This method is called when the batch process starts and creates a SOQL to fetch existing Addres statistics.
    ************************************************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Getting Zip Code that has more than 50k addresses from custom setting.
        List<String> ExcludedZipCode=new List<String>();
        List<AddressesStatsExcludedZipCode__c> ListAddressesStatsExcludedZipCode =AddressesStatsExcludedZipCode__c.getAll().values();
            
        for(AddressesStatsExcludedZipCode__c AddStatsExcZipCode:ListAddressesStatsExcludedZipCode){
            ExcludedZipCode.add(AddStatsExcZipCode.Zip_Postal_Code__c);
        }
        if(queryString=='' && ExcludedZipCode !=null ){
            queryString = 'Select Id, Num_of_Currently_Assigned__c, Percent_Currently_Unassigned__c , Num_of_Currently_Unassigned__c , Knocked__c, Worked__c, Percent_Currently_Assigned__c, Latitude__c, Longitude__c, Colour__c, Currently_Assigned_to_Turf__c, Assigned__c, Assigned_in_last__c, Knocked_in_last__c, Percent_Complex_Code__c, Zip_Code__c, Region__c from Address_Statistics__c where Zip_Code__c!=\'\' and Zip_Code__c not in : ExcludedZipCode'; 
        }
        return Database.getQueryLocator(queryString);
    }
    
    /***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 09-May-2013
     * Param      : Database.BatchableContext, List<sObject>
     * Return     : None
     * Description: This method called after the start method to execute batch task. It calculates Address Statistics for Zip Code records.
    ************************************************************************************************************************************/  
    public void execute(Database.BatchableContext bc, List<sObject>  scope) {       
        // Map to hold Zip code and number of addresses for that Zip code.
        Map<String,Integer> zipCodeAndTotalAddressesMap = new Map<String,Integer>();
        Map<String,Integer> zipCodeAndAssignedAddressesMap = new Map<String,Integer>();
        Map<String,Integer> zipCodeAndAssignedAddressesLastDaysMap = new Map<String,Integer>();
        Map<String,Integer> zipCodeAndKnockedAddressesLastDaysMap = new Map<String,Integer>();
        Map<String,Integer> zipCodePropertyCodeMap = new Map<String,Integer>();
        Map<String,Decimal> zipCodeAndLatitudeMap = new Map<String,Decimal>();
        Map<String,Decimal> zipCodeAndLongitudeMap = new Map<String,Decimal>();
        Map<String,Address_Statistics__c> zipCodeAndAddrsStatsMap = new Map<String,Address_Statistics__c>();
        Map<String,Date> zipCodeAndLastAssignedDateMap = new Map<String,Date>();
        Map<String,Date> zipCodeAndLastKnockDateMap = new Map<String,Date>();
        Map<String,Integer> zipCodeAndWorkedAddressesLastDaysMap = new Map<String,Integer>();
        Set<String> zipCodeSet = new Set<String>();
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
        
        
        // Fetching configurable values from custom setting.
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
            
            
        } catch(Exception ex) {
            processBatch = false;
            System.debug('No data found in custom setting:'+ex);
        }
        
        // Address Stats calculation will only be done if configurable values are set in Custom setting.
        if(processBatch){ 
            String regionString = '';
            //Initializing different maps which will contain Zip code and number of addresses for that Zip code.
            for(Address_Statistics__c addStatObj : addStats ) {
                if(addStatObj.Region__c != null){
                    regionString = addStatObj.Region__c.toLowerCase();//Added by Amit(US944455)
                }   
                zipCodeSet.add(addStatObj.Zip_Code__c);
                zipCodeAndAddrsStatsMap.put(addStatObj.Zip_Code__c, addStatObj);
                zipCodeAndTotalAddressesMap.put(addStatObj.Zip_Code__c+':'+regionString, 0);
                zipCodeAndAssignedAddressesMap.put(addStatObj.Zip_Code__c+':'+regionString, 0);
                zipCodeAndKnockedAddressesLastDaysMap.put(addStatObj.Zip_Code__c+':'+regionString, 0);
                zipCodeAndAssignedAddressesLastDaysMap.put(addStatObj.Zip_Code__c+':'+regionString, 0);
                zipCodeAndLatitudeMap.put(addStatObj.Zip_Code__c, 0);
                zipCodeAndLongitudeMap.put(addStatObj.Zip_Code__c, 0);
                zipCodePropertyCodeMap.put(addStatObj.Zip_Code__c+':'+regionString,0);
                regionSet.add(regionString);               
            }
            
            //User Story: US432420 , Sprint 1 Change, Date : 5/7/2015, Author : Lalit Singh
            //Remove The List and passed the query directly into the for Loop (Lalit).
            
            //Populate Maps which contains zipCode and number of Addresses in that zipCode.
            for(Customer_Address__c addrsObj : [Select Id,  PostalCode__c, Assigned_Date__c, Plan__c, Last_Knock_Date__c, OwnerId, Region__c, Latitude__c, Longitude__c, Property_Code__c, Worked__c, WorkedDate__c from Customer_Address__c where PostalCode__c in :zipCodeSet AND Region__c IN:regionSet]) {
                    regionString = '';
                    if(addrsObj.Region__c != null){
                        regionString = addrsObj.Region__c.toLowerCase();//Added by Amit(US944455)
                    }
                    propertyCodeList.add(addrsObj.Property_Code__c);
                    if(zipCodeAndTotalAddressesMap.get(addrsObj.PostalCode__c+':'+regionString)!=null){
                        zipCodeAndTotalAddressesMap.put(addrsObj.PostalCode__c+':'+regionString,zipCodeAndTotalAddressesMap.get(addrsObj.PostalCode__c+':'+regionString) + 1);
                    }else{
                        zipCodeAndTotalAddressesMap.put(addrsObj.PostalCode__c+':'+regionString, 1);
                    }

                    if(addrsObj.Latitude__c != null && addrsObj.Latitude__c != 0){              
                        zipCodeAndLatitudeMap.put(addrsObj.PostalCode__c+':'+regionString, addrsObj.Latitude__c);
                    }
                    
                    if(addrsObj.Longitude__c  != null && addrsObj.Longitude__c  != 0){
                        zipCodeAndLongitudeMap.put(addrsObj.PostalCode__c+':'+regionString, addrsObj.Longitude__c);
                    }
                        
                    if(addrsObj.Plan__c != null) {
                        if(zipCodeAndAssignedAddressesMap.get(addrsObj.PostalCode__c+':'+regionString)!=null){
                            zipCodeAndAssignedAddressesMap.put(addrsObj.PostalCode__c+':'+regionString,zipCodeAndAssignedAddressesMap.get(addrsObj.PostalCode__c+':'+regionString) + 1);                  
                        }else{
                            zipCodeAndAssignedAddressesMap.put(addrsObj.PostalCode__c+':'+regionString, 1); 
                        }
                    }
                    if(addrsObj.Assigned_Date__c!= null) {
                        Date dateObj= Date.newinstance(addrsObj.Assigned_Date__c.year(), addrsObj.Assigned_Date__c.month(), addrsObj.Assigned_Date__c.day());       
                        if(dateObj+noOfDays >= System.Today()) {
                            if(zipCodeAndAssignedAddressesLastDaysMap.get(addrsObj.PostalCode__c+':'+regionString)!=null){
                            zipCodeAndAssignedAddressesLastDaysMap.put(addrsObj.PostalCode__c+':'+regionString,zipCodeAndAssignedAddressesLastDaysMap.get(addrsObj.PostalCode__c+':'+regionString) + 1);
                            }
                            else{
                                zipCodeAndAssignedAddressesLastDaysMap.put(addrsObj.PostalCode__c+':'+regionString,1);
                            }
                        }
                        if(zipCodeAndLastAssignedDateMap.get(addrsObj.PostalCode__c+':'+regionString)!=null){
                            if(dateObj >= zipCodeAndLastAssignedDateMap.get(addrsObj.PostalCode__c+':'+regionString)){
                                zipCodeAndLastAssignedDateMap.put(addrsObj.PostalCode__c+':'+regionString,dateObj);
                            }
                        } else {
                            zipCodeAndLastAssignedDateMap.put(addrsObj.PostalCode__c+':'+regionString,dateObj);
                        }
                    }
                    if(addrsObj.Last_Knock_Date__c!= null) {
                        Date dateObj1= Date.newinstance(addrsObj.Last_Knock_Date__c.year(), addrsObj.Last_Knock_Date__c.month(), addrsObj.Last_Knock_Date__c.day());       
                        if(dateObj1+noOfKnockedDays >= System.Today()) {  
                            if(zipCodeAndKnockedAddressesLastDaysMap.get(addrsObj.PostalCode__c+':'+regionString)!=null){                             
                                zipCodeAndKnockedAddressesLastDaysMap.put(addrsObj.PostalCode__c+':'+regionString,zipCodeAndKnockedAddressesLastDaysMap.get(addrsObj.PostalCode__c+':'+regionString) + 1);
                            }
                            else{
                                zipCodeAndKnockedAddressesLastDaysMap.put(addrsObj.PostalCode__c+':'+regionString,1);
                            }
                        }
                        if(zipCodeAndLastKnockDateMap.get(addrsObj.PostalCode__c+':'+regionString)!=null){
                            if(dateObj1 >= zipCodeAndLastKnockDateMap.get(addrsObj.PostalCode__c+':'+regionString)){
                                zipCodeAndLastKnockDateMap.put(addrsObj.PostalCode__c+':'+regionString,dateObj1);
                            }
                        } else {
                            zipCodeAndLastKnockDateMap.put(addrsObj.PostalCode__c+':'+regionString,dateObj1);
                        }
                    }
                    if(addrsObj.WorkedDate__c!=null){
                        Date dateObj2 = Date.newInstance(addrsObj.WorkedDate__c.year(), addrsObj.WorkedDate__c.month(), addrsObj.WorkedDate__c.day());
                        if(dateObj2+noOfKnockedDays >= System.today()){
                            if(zipCodeAndWorkedAddressesLastDaysMap.get(addrsObj.PostalCode__c+':'+regionString)!=null){
                                zipCodeAndWorkedAddressesLastDaysMap.put(addrsObj.PostalCode__c+':'+regionString, zipCodeAndWorkedAddressesLastDaysMap.get(addrsObj.PostalCode__c+':'+regionString)+1);
                            }
                            else {
                                zipCodeAndWorkedAddressesLastDaysMap.put(addrsObj.PostalCode__c+':'+regionString, 1);
                            }
                        }
                    }
            }

            //Set Last_Assigned_Date__c and Last_Knock_Date__c
            for(Address_Statistics__c addStatObj : addStats){
                regionString = '';
                if(addStatObj.Region__c != null){
                    regionString = addStatObj.Region__c.toLowerCase();//Added by Amit(US944455)
                }
                if(zipCodeAndLastAssignedDateMap.get(addStatObj.Zip_Code__c+':'+regionString)!=null){
                    addStatObj.Last_Assigned_Date__c = zipCodeAndLastAssignedDateMap.get(addStatObj.Zip_Code__c+':'+regionString);
                }
                if(zipCodeAndLastKnockDateMap.get(addStatObj.Zip_Code__c+':'+regionString)!=null){
                    addStatObj.Last_Knock_Date__c = zipCodeAndLastKnockDateMap.get(addStatObj.Zip_Code__c+':'+regionString);
                }
            }
                       
            //User Story: US432420, Sprint 1 Change, Date : 5/7/2015, Author : Lalit Singh
            // Plan Name code Move to the New Batch : AddressesStatstoPlanCalculationZipBatch
            
            for(Address_Statistics__c addStatObj : addStats){
                regionString = '';
                if(addStatObj.Region__c != null){
                    regionString = addStatObj.Region__c.toLowerCase();//Added by Amit(US944455)
                }
                //set AddressPropertyCodes
                String propertyCodes='';
                Integer noOfPropertyCodesOnZipCode=0;
                for(String pCode : propertyCodeList){
                    if(pCode != null && pCode != ''){
                        if(!propertyCodes.contains(pCode)){
                            propertyCodes += pCode + ',';
                        }
                        noOfPropertyCodesOnZipCode++;
                    }
                }
                zipCodePropertyCodeMap.put(addStatObj.Zip_Code__c+':'+regionString, noOfPropertyCodesOnZipCode);
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
            
            // User Story: US432420,Sprint 1 Change, Date : 5/7/2015, Author : Lalit Singh
            // Plan User Code Move to the New Batch : AddressesStatstoPlanCalculationZipBatch
            
            // Set value of 4 fields on Address stats records based on number and percentage of addresses assigned.
            for(Address_Statistics__c addStatObj : addStats ){              
                regionString = '';
                if(addStatObj.Region__c != null){
                    regionString = addStatObj.Region__c.toLowerCase();//Added by Amit(US944455)
                }
                Double lastDaysAssignedPercentage = 0;
                Double lastDaysKnockedPercentage = 0;
                Double lastDaysWorkedPercentage = 0;

                addStatObj.Num_of_Currently_Assigned__c=0;
                addStatObj.Num_of_Currently_Unassigned__c=0;
                addStatObj.Num_of_Currently_Assigned__c = zipCodeAndAssignedAddressesMap.get(addStatObj.Zip_Code__c+':'+regionString);
                addStatObj.Num_of_Currently_Unassigned__c =  zipCodeAndTotalAddressesMap.get(addStatObj.Zip_Code__c+':'+regionString) - zipCodeAndAssignedAddressesMap.get(addStatObj.Zip_Code__c+':'+regionString);
                if(zipCodeAndTotalAddressesMap.get(addStatObj.Zip_Code__c+':'+regionString) != 0){
                    addStatObj.Percent_Currently_Assigned__c = (zipCodeAndAssignedAddressesMap.get(addStatObj.Zip_Code__c+':'+regionString) /(Double) zipCodeAndTotalAddressesMap.get(addStatObj.Zip_Code__c+':'+regionString)) * 100;
                    addStatObj.Percent_Currently_Unassigned__c = 100 - addStatObj.Percent_Currently_Assigned__c;                

                    //Calculate Percentage Of Addresses In Zip Code that contain a Property Code
                    addStatObj.Percent_Complex_Code__c=(zipCodePropertyCodeMap.get(addStatObj.Zip_Code__c+':'+regionString)/(Double) zipCodeAndTotalAddressesMap.get(addStatObj.Zip_Code__c+':'+regionString)) * 100;
                        
                    lastDaysAssignedPercentage = (zipCodeAndAssignedAddressesLastDaysMap.get(addStatObj.Zip_Code__c+':'+regionString) /(Double) zipCodeAndTotalAddressesMap.get(addStatObj.Zip_Code__c+':'+regionString)) * 100;
                            
                    addStatObj.Assigned_in_last__c = String.valueOf(noOfDays) + 'Days : ' +  String.valueOf(lastDaysAssignedPercentage) + '%';
                            
                    lastDaysKnockedPercentage = (zipCodeAndKnockedAddressesLastDaysMap.get(addStatObj.Zip_Code__c+':'+regionString) /(Double) zipCodeAndTotalAddressesMap.get(addStatObj.Zip_Code__c+':'+regionString)) * 100;
                }

                if(zipCodeAndLatitudeMap.containsKey(addStatObj.Zip_Code__c+':'+regionString)){
                    addStatObj.Latitude__c=zipCodeAndLatitudeMap.get(addStatObj.Zip_Code__c+':'+regionString);  
                }

                if(zipCodeAndLongitudeMap.containsKey(addStatObj.Zip_Code__c+':'+regionString)){
                    addStatObj.Longitude__c=zipCodeAndLongitudeMap.get(addStatObj.Zip_Code__c+':'+regionString);  
                }

                if(addStatObj.Percent_Currently_Assigned__c >= assignedPercentage){
                    addStatObj.Currently_Assigned_to_Turf__c = true;
                }
                else{
                    addStatObj.Currently_Assigned_to_Turf__c = false;
                }
                        
                addStatObj.Knocked_in_last__c = String.valueOf(noOfKnockedDays) + 'Days : ' + String.valueOf(lastDaysKnockedPercentage) + '%';

                if(zipCodeAndWorkedAddressesLastDaysMap.containsKey(addStatObj.Zip_Code__c+':'+regionString)){
                    lastDaysWorkedPercentage = (zipCodeAndWorkedAddressesLastDaysMap.get(addStatObj.Zip_Code__c+':'+regionString) / (Double) zipCodeAndTotalAddressesMap.get(addStatObj.Zip_Code__c+':'+regionString)) * 100; 
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
                    }else {
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
        }

        try {
            System.debug('Scope ***' + addStats);
            Database.update(addStats, false);
        } catch(Exception ex) {
            System.debug('Following exception occurred :'+ex.getMessage());
        }
    }
    
    /***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 09-May-2013
     * Param      : Database.BatchableContext
     * Return     : None
     * Description: This method is called at the end after execute method completes for any notification etc. This method is not used in this class but because of Interface which this class implements this methods is present here.
    ************************************************************************************************************************************/ 
    public void finish(Database.BatchableContext bc) {
        //User Story: US432420, Sprint 1 Change, Date : 5/7/2015, Author : Lalit Singh
        /*List<ConfigurableParameters__c> cPara = new List<ConfigurableParameters__c>(); 
        try{
            // Set the New Values of Custom Settings if configuration changes
            ConfigurableParameters__c inst1 = ConfigurableParameters__c.getValues('S_PreviousZipOrzipCodeAssignedDays');
            inst1.NumberValue__c = ConfigurableParameters__c.getValues('Config_ZipOrNodeAssignedDays').NumberValue__c ;
            cPara.add(inst1);
            
            ConfigurableParameters__c inst2 =ConfigurableParameters__c.getValues('S_PreviousZipOrzipCodeKnockedDays');
            inst2.NumberValue__c = ConfigurableParameters__c.getValues('Config_ZipOrNodeKnockedDays').NumberValue__c;
            cPara.add(inst2);
            
            ConfigurableParameters__c inst3 =ConfigurableParameters__c.getValues('S_PreviousAssignedAddressPercentage');
            inst3.NumberValue__c = ConfigurableParameters__c.getValues('Config_PrevAssignedAddressPercentage').NumberValue__c;
            cPara.add(inst3);
            
            ConfigurableParameters__c inst4 =ConfigurableParameters__c.getValues('S_PreviousKnockedAddressPercentage');
            inst4.NumberValue__c = ConfigurableParameters__c.getValues('Config_PrevKnockedAddressPercentage').NumberValue__c;
            cPara.add(inst4);
            
        } catch(Exception ex) {
            System.debug('No data found in custom setting:'+ex);
        }
        try {
            Database.update(cPara, false);
        } catch(Exception ex) {
            System.debug('Following exception occurred :'+ex.getMessage());
        }*/
        
        //User Story: US432420, Sprint 1 Change, Date : 5/7/2015, Author : Lalit Singh
        // Calling the Second Batch.
        AddressesStatstoPlanCalculationZipBatch addressesStatsCalculationZipBatchObj = new AddressesStatstoPlanCalculationZipBatch(); 
        database.executebatch(addressesStatsCalculationZipBatchObj, 1);
        
    }
    
}