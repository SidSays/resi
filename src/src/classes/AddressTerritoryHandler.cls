/***************************************************************************************************************************************
 * Author              : Salesforce services
 * Date                : 16-Nov-2016
 * Description         : Contains logic to manage the Targeted flag and assigning a new address to an existing territory
 * Modified By: Animesh
 * Modified Date: 25-Jul-2017
 * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details
                        Removed system.debug statements from methods/loops
***************************************************************************************************************************************/
public class AddressTerritoryHandler {

    static SystemProperties systemProperties = new SystemProperties();
    //flag to determine if this code logic has executed to avoid recursive invocation
    public static Boolean hasExecuted;

    /**************************************************************************************************************************
    * Handles the logic when new addresses are inserted into the Customer_Address__c object and assign them to Territories
    * if there are addresses in the same census tracts that are assigned to Territories
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details
                    Removed system.debug statements from methods/loops. Added Try Catch
    **************************************************************************************************************************/
    public static void addAddressToTerritoryOnInsert(List<Customer_Address__c> newAddresses){
        try{
            if(!skipProcessing()){
                updateTerritoryOnAddresses(newAddresses);
            }else{}}catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }

    /**************************************************************************************************************************
    * Handles the logic when new addresses are update into the Customer_Address__c object and assign them to Territories
    * if there are addresses in the same census tracts that are assigned to Territories
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details
                    Removed system.debug statements from methods/loops. Added Try Catch
    **************************************************************************************************************************/
    public static void addAddressToTerritoryOnUpdate(List<Customer_Address__c> newAddresses,List<Customer_Address__c> oldAddresses){
        try{
            if(!skipProcessing()){
                updateTerritoryOnAddresses(getAddressesWithCensusBlockChanges(newAddresses,oldAddresses));
            }else{}}catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }

    /**************************************************************************************************************************
    * Looks at the old and new values and filters down the list of addresses updated that require TerritoryProcessing. It returns
    * those addresses where there is a Census Block in the new list vs. the old list.
     
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details
                    Removed system.debug statements from methods/loops
     **************************************************************************************************************************/
    private static List<Customer_Address__c> getAddressesWithCensusBlockChanges(List<Customer_Address__c> newAddresses,List<Customer_Address__c> oldAddresses){
        List<Customer_Address__c> addressWithCensusChanges = new List<Customer_Address__c>();
        Integer oldAddressSize = oldAddresses.size();//Animesh - US1137083. Instead of calculating oldAddresses.size() in loops, keeping it in a variable
        for(Integer i=0;i<oldAddressSize;i++){
            if((oldAddresses[i].Census_Block__c != newAddresses[i].Census_Block__c) && newAddresses[i].Census_Block__c != null)
            {
                addressWithCensusChanges.add(newAddresses[i]);
            }
        else if((oldAddresses[i].Census_Block__c !=null && oldAddresses[i].Territory__c==null)){
                newAddresses[i].Census_Block__c=oldAddresses[i].Census_Block__c;
                addressWithCensusChanges.add(newAddresses[i]);
            }    
        }
        return addressWithCensusChanges;
    }
    
    /**************************************************************************************************************************
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details
                    Removed system.debug statements from methods/loops
    **************************************************************************************************************************/
    private static void updateTerritoryOnAddresses(List<Customer_Address__c> newAddresses){
        Map<String,String> censusTracts = new Map<String,String>();
        Map<String,String> censusTractsToTerritory = new Map<String,String>();
        //Get list of census tracts in the addresses being inserted
        for(Customer_Address__c addr: newAddresses){
            if( addr.Census_Block__c !=null && 
                addr.Census_Block__c.length()>=11 &&
                !censusTracts.containsKey(addr.Census_Block__c.substring(0,11)))
            {
                censusTracts.put(addr.Census_Block__c.substring(0,11),addr.Census_Block__c.substring(0,11));
            }
        }
        for(CensusTract__c cTract: [select CensusTractNumber__c,Territory__c 
                                    from CensusTract__c
                                    where CensusTractNumber__c in :censusTracts.values() ]){
            //Map the Census Tract to the Territory that it is assigned
            censusTractsToTerritory.put(cTract.CensusTractNumber__c,cTract.Territory__c);
        }
        //Assign the Territory to the new addresses 
        for(Customer_Address__c addr: newAddresses){
            if(addr.Census_Block__c !=null && addr.Census_Block__c.length()>=11 && censusTractsToTerritory.containsKey(addr.Census_Block__c.substring(0,11))){
                addr.Territory__c = censusTractsToTerritory.get(addr.Census_Block__c.substring(0,11));
            }
        }
    }

    /**************************************************************************************************************************
    * Handles the logic to switch the "Targeted__c" flag from true to false depending on the Active_Inactive__c value.
    * 
    * This is to ensure :
    * a. that the XSP knows when knocking that the customer address is no longer a targeted address as 
    *    they may have become a csutomer through a different channel. 
    * b. If the customer disconnects then they revert back to being a targeted address
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details
                    Removed system.debug statements from methods/loops
    * Modified By: Animesh
    * Modified Date: 26-Jul-2017
    *Method is not called from anywhere. Method calling from trigger is commented. So commenting this code as it is impacting in test class coverage
    **************************************************************************************************************************/
    /*public static void updateTargetedIndicator(List<Customer_Address__c> newAddresses,List<Customer_Address__c> oldAddresses){
        if(!skipProcessing()){
            for(Integer i=0;i<newAddresses.size();i++){
                Customer_Address__c addr = newAddresses[i];
                if( (oldAddresses !=null && newAddresses[i].Active_Inactive__c != oldAddresses[i].Active_Inactive__c) ||
                    (oldAddresses !=null && newAddresses[i].Account__c != oldAddresses[i].Account__c) ||
                    oldAddresses == null){
                    if(addr.Active_Inactive__c == 'Active' && addr.Targeted__c && addr.Territory__c !=null){
                        addr.Targeted__c=false;
                    }
                    if(addr.Active_Inactive__c == 'Inactive' && !addr.Targeted__c && addr.Territory__c !=null){
                        addr.Targeted__c=true;
                    }           
                }
            }                
        }       
    }*/

    /**************************************************************************************************************************
     * Helper method that checks if the logic has already run or should be bypassed based on the list of profile names
     * this logic should be bypassed when EBI updates occur on a monthly basis. 
     **************************************************************************************************************************/
     @TestVisible
    private static Boolean skipProcessing(){
        /*
        ## Commented on Jan 6th-2017 by Anand due to an issue in production on how the batching of bulk API works.
        ## Will require to investigate further and uncomment

        System.debug('>>> hasExecuted = '+hasExecuted);

        if(hasExecuted != null){
            //If the logic has already run, just return hasExecuted static flag
            return hasExecuted;
        }else{
            //set the hasExecuted to true so that subsequent invocations bypass this logic
            hasExecuted=true;

            //Get the list of Profile names to skip this logic 
            String profilesToSkip = systemProperties.getSytemProperty('AddressTerritoryHandler_Skip_Profiles','Territory Management');
            
            System.debug('>>> profilesToSkip = '+profilesToSkip);
            //Get the current user's profile name
            String currUserProfile = [select Profile_Name_Text__c from User where Id = :UserInfo.getUserId() limit 1].Profile_Name_Text__c;
            

            if(profilesToSkip !=null){
                //Return if the current users's profile is in the list of profiles to skip;
                return profilesToSkip.contains(currUserProfile);
            }

            //don't skip logic
            return false;
        }*/
        return (hasExecuted!=null?hasExecuted:false);
    }
}