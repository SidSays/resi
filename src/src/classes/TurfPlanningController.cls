/* Code Modified on : 27th march 2017
       Developer : Shivani Gautam
       Description : 1.When ExcludeNonmarketableOnly = false, add addresses where Non_Marketable = true or false and all are targetted
                     2.When ExcludeNonmarketableOnly = true, add addresses where Non_Marketable = false 
       User Story no: US1075742 , Sprint 50.    
*/
/* Code Modified on : 21st April 2017
       Developer : Joognu Rao
       Description : Assign a Team to a Turf from the Territory Turf Planning screen so that it can be used for team selling (blitz), 
                     XSE/XSA partnerships and Back to School Events for West Division.
       User Story no: US1072293 , Sprint 52.  
*/
/* >>>sfdcDebug>>> Comment 20170406 through 20170408 
 *     Code Analyzed with Notes by Salesforce 
*/
global with sharing class TurfPlanningController {

    public User currentUser;
    public static boolean TurfPlanningPlanUpdate = false; //Srini to prevent multiple updates on plan

    public Territory__c territory { get; set; }
    public Id selectedTerritoryId { get; set; }
    public List<SelectOption> territoryOptions { get; set; }
    public String selectedGrouping { get; set; }

    //Previous Grouping holds the Grouping selection last selected. This is so that we retain the correct grouping 
    //in case the user changes the grouping before choosing 'Assign to Turf'
    public String previousTerritoryId { get; set; }
    public String previousGrouping { get; set; }
    public Boolean previousIncludeHSIOnly { get; set; }
    public List<SelectOption> groupingOptions { get; set; }
    public String groupingHeader {
        get {
            return Schema.SObjectType.Customer_Address__c.fields.getMap().get(selectedGrouping).getDescribe().getLabel();
        }
    }
    public Boolean includeHSIOnly { get; set; }   
    //START US1075742
    public Boolean ExcludeNonmarketableOnly { get; set; }
    //END US1075742
    public Plan__c turf { get; set; }
    public Boolean turfHasTerritory {
        get {
            return turf.Territory__c != null;
        }
    }

    public Map<String,Integer> addressCountsByGrouping { get; set; }
    public Boolean tableHasData {
        get {
            return addressCountsByGrouping != null && !addressCountsByGrouping.isEmpty();
        }
    }
    public Map<String,Boolean> groupingSelections { get; set; }

    private List<Id> selectedAddressIds { get; set; }
    public String addressIdsJson { get; set; }
    public Integer CHUNK_SIZE { get; set; }
    public Integer THREAD_COUNT { get; set; }
    public Integer TURF_SIZE { get; set; }
    public Integer ADDRESS_MAXLIMIT_PER_TURF { get; set; }
    public Boolean searchComplete { get; set; }

    public Boolean saveSuccess { get; set; }

    public TurfPlanningController() {
        SystemProperties sysProps = new SystemProperties();
        CHUNK_SIZE = Integer.valueOf(sysProps.getSytemProperty('Turf_Assignment_Chunk_Size','Territory Management'));
        THREAD_COUNT = Integer.valueOf(sysProps.getSytemProperty('Territory_Max_Threads','Territory Management'));
        TURF_SIZE = Integer.valueOf(sysProps.getSytemProperty('Turf_Size_Limit','Territory Management'));
        //Srini Bhattiprolu: Custom Meta Data Type for Address Max Limit Per Turf (US1129121)
        ADDRESS_MAXLIMIT_PER_TURF = Integer.valueOf(sysProps.getSytemProperty('AddressMaxLimitPerTurf','Turf Planning'));

        groupingOptions = new List<SelectOption>();
        groupingOptions.add(new SelectOption('Census_Tract__c', 'Census Tract'));
        groupingOptions.add(new SelectOption('Census_Block_Group__c', 'Census Block Group'));
        groupingOptions.add(new SelectOption('Census_Block_Sub_Block__c', 'Census Block Sub Block'));
        selectedGrouping = 'Census_Tract__c';
        includeHSIOnly = false;
        ExcludeNonmarketableOnly =  false;
        territoryOptions = new List<SelectOption>();
        Id userId = UserInfo.getUserId();
        currentUser = [SELECT Region__c, Comcast_Division__c, Profile.Name From User WHERE Id = :userId];

        territory = new Territory__c();
         //modified line by Joognu Rao:to implement US1045181
        //Changed Plan_Status__c value from 'Draft' to 'Assigned'
        turf = new Plan__c(Plan_Status__c = 'Assigned', Plan_Level__c = 'Turf', Assigned_Date__c = Date.today(), Number_of_Addresses_on_Playlists__c = 0);
        
        if(currentUser.Comcast_Division__c=='West'){
                turf.Expiration_Date__c = Date.today() + 75;
        } else {
                turf.Expiration_Date__c = Date.today() + 60;
        }

        List<Territory__c> territories = [SELECT Id, Name FROM Territory__c WHERE Status__c = 'Published' AND Region__c = :currentUser.Region__c ORDER BY Name ASC ];
        for(Territory__c territory : territories) {
            territoryOptions.add(new SelectOption(territory.Id,territory.Name));
        }
    }

    public void queryAddressesInTerritory() {
        //set the previousSelection values so that we retain them and use them if
        //the user clicks assign turf and selects these flags. The assignment code
        //in save() will ignore the current selections and use the previous selections
        previousGrouping=selectedGrouping;
        previousIncludeHSIOnly=includeHSIOnly;
        previousTerritoryId = selectedTerritoryId;

        territory.Id = selectedTerritoryId;
        turf.Territory__c = selectedTerritoryId;

        String queryString = 'SELECT Id, ' + selectedGrouping + ' FROM Customer_Address__c';
        queryString += ' WHERE Territory__c = :selectedTerritoryId AND Plan__c = NULL AND Excluded_from_Territory__c = FALSE';
        queryString += ' AND (Targeted__c = TRUE';
        if(includeHSIOnly) {
            queryString += ' OR HSI_Only__c = \'YES\'';
        }
        queryString += ')';
           //US1075742 - Start      
            if(ExcludeNonmarketableOnly){
                queryString += ' AND Non_Marketable__c = false ';
            }      
            //US1075742 - End
        List<Customer_Address__c> addresses = Database.query(queryString);

        countAddressesInTerritory(addresses);

        //Set the previous selected grouping to the currently selected grouping
        searchComplete = true;
    }

    private void countAddressesInTerritory(List<Customer_Address__c> addresses) {
        Map<String,List<Id>> groupedAddresses = new Map<String,List<Id>>();
        for(Customer_Address__c address : addresses) {
            String censusGrouping = (String)address.get(previousGrouping);
            if(censusGrouping!=null){
                if(!groupedAddresses.containsKey(censusGrouping)) {
                    groupedAddresses.put(censusGrouping,new List<Id>());
                }
                groupedAddresses.get(censusGrouping).add(address.Id);
            }
        }

        addressCountsByGrouping = new Map<String,Integer>();
        for(String grouping : groupedAddresses.keySet()) {
            addressCountsByGrouping.put(grouping,groupedAddresses.get(grouping).size());
        }

        groupingSelections = new Map<String,Boolean>();
        for(String grouping : groupedAddresses.keySet()) {
            groupingSelections.put(grouping,false);
        }
        
    }
     /* Modification History
      Developer : Joognu Rao
       Description : Assign a Team to a Turf from the Territory Turf Planning screen so that it can be used for team selling (blitz), 
                     XSE/XSA partnerships and Back to School Events for West Division.
       User Story no: US1072293 , Sprint 52.
     */
    public void save() {
        try {
                
            //Modified by Joognu Rao to implement US1072293 *START*
            if(turf.Assigned_Team__c!=null && territory.ownerid!=null){
                saveSuccess= false;  
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.TurfPlanningAssignedTeamUser));
                
            }
            
            if(turf.Assigned_Team__c==null && territory.ownerid==null){
                saveSuccess= false;  
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.TurfPlanningAssignedTeamUserNull));
                
            }
            //Modified by Joognu Rao to implement US1072293 *END*
             String allowedProfiles = [SELECT Value__c FROM System_Property__mdt WHERE DeveloperName='Allowed_Turf_Assigned_Profiles'].Value__c;
                List<String> allowedProfilesList = allowedProfiles.split(',');
                Set<String> allowedProfilesSet = new Set<String>();
                allowedProfilesSet.addAll(allowedProfilesList);
            //Modified by Joognu Rao to implement US1072293 *START*         
            if(territory.ownerid!=null && turf.Assigned_Team__c==null){ 
                
            //Modified by Joognu Rao to implement US1072293 *END*
                User assignedUser = [SELECT Region__c, Comcast_Division__c,email, managerid, manager.name, Manager.email, Profile.Name FROM User WHERE Id = :territory.OwnerId];
                collectAddresses();
                if(currentUser.Region__c != assignedUser.Region__c){
                    saveSuccess = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Assigned User must be in your region!'));
                } else if(!allowedProfilesSet.contains(assignedUser.Profile.Name)){
                    saveSuccess = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Assigned User must have an allowed profile!'));
                } /* else if(territory.OwnerId == null ){
                    saveSuccess = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Assigned To (User) is required!'));
                } */
                else {
                    Id selectedOwnerId = territory.OwnerId;
                    //do a query to get the 'Name' of the Territory to include in the Parameter__c
                    territory = [select Id,Name,OwnerId from Territory__c where Id = :previousTerritoryId];
                    territory.OwnerId = selectedOwnerId;
                    territory.AssignedTo__c  = territory.OwnerId;
                    update territory;

                    turf.OwnerId = UserInfo.getUserId();
                     //modified line by Joognu Rao:to implement US1045181
                    //set 'Assigned User' on turf/Plan as the territory owner
                    turf.user__c = territory.OwnerId;
                    
                    turf.True_count_of_Addresses__c = selectedAddressIds.size();
                    turf.Number_of_Addresses_Currently_on_Plan__c = selectedAddressIds.size();
                    
                    //Modified by Joognu Rao to implement US1072293 *START*
                    turf.Supervisor_Email__c = assignedUser.Manager.email;
                    turf.Supervisor_Name__c = assignedUser.Manager.name;
                    /************************************* US1111650*******Commented the code for Expiration Date
                    if(assignedUser.Comcast_Division__c=='West'){
                        turf.Expiration_Date__c = Date.today() + 75;
                     } else {
                       turf.Expiration_Date__c = Date.today() + 60;
                     }
                     ************************************** US1111650*******Commented the code for Expiration Date*/
                    //Modified by Joognu Rao to implement US1072293 *END*
                    
                    //Set the 'parameters' for easy reference in the Plan object
                    String parameters = 'Territory:'+territory.Name;
                    List<String> censusSelections = new List<String>();
                    for(String grouping : groupingSelections.keySet()) {
                        if(groupingSelections.get(grouping)) {
                            censusSelections.add(grouping);
                        }
                    }
                    //added parameter value for Exclude non marketable addresses -US1075742
                    parameters += +'\nHSI Only Included='+previousIncludeHSIOnly+'\nNon-Marketable Addresses Excluded='+ExcludeNonmarketableOnly+'\n'+previousGrouping+':'+String.join(censusSelections,',');
                    turf.Parameters__c =parameters;

                    upsert turf;
                    saveSuccess = true;
                    selectedGrouping=previousGrouping;
                }
            }
            //Modified by Joognu Rao to implement US1072293 *START*
         else if(turf.Assigned_Team__c!=null && territory.ownerid==null){
              
                
                Team__c teamObj;
                        
                teamObj = [Select Id, Comcast_Division__c,Supervisor__c,Region__c,Supervisor__r.name,Supervisor__r.email,Supervisor__r.Profile.Name From Team__c Where Id =:turf.Assigned_Team__c];
                territory.OwnerId = teamObj.Supervisor__c;
                territory.AssignedTo__c = null;
                
                collectAddresses();
                               
                    update territory;
                    
                    territory = [select Id,Name,OwnerId,AssignedTo__c from Territory__c where Id = :territory.Id];
                    
                    
                    
                    turf.OwnerId = UserInfo.getUserId();                    
                    
                    turf.True_count_of_Addresses__c = selectedAddressIds.size();
                    turf.Number_of_Addresses_Currently_on_Plan__c = selectedAddressIds.size();
                    turf.Supervisor_Email__c = teamObj.Supervisor__r.email;
                    turf.Supervisor_Name__c = teamObj.Supervisor__r.name;
                    /************************************* US1111650*******Commented the code for Expiration Date
                    /*
                     if(teamObj.Comcast_Division__c=='West'){
                        turf.Expiration_Date__c = Date.today() + 75;
                     } else {
                       turf.Expiration_Date__c = Date.today() + 60;
                     }
                    
                    ************************************** US1111650*******Commented the code for Expiration Date*/
                    //Set the 'parameters' for easy reference in the Plan object
                    String parameters = 'Territory:'+territory.Name;
                    List<String> censusSelections = new List<String>();
                    for(String grouping : groupingSelections.keySet()) {
                        if(groupingSelections.get(grouping)) {
                            censusSelections.add(grouping);
                        }
                    }
                               
                    //added parameter value for Exclude non marketable addresses -US1075742
                   
                   // system.debug('parameters -->'+parameters );
                    parameters += +'\nHSI Only Included='+previousIncludeHSIOnly+'\nNon-Marketable Addresses Excluded='+ExcludeNonmarketableOnly+'\n'+previousGrouping+':'+String.join(censusSelections,',');
                     
                    turf.Parameters__c =parameters;
                    upsert turf;
                    saveSuccess = true;
                    selectedGrouping=previousGrouping;
                    System.debug('>>>rbenedetti>>>20170405: EXIT save -> Try');
                       
                
            }
         //Modified by Joognu Rao to implement US1072293 *END*
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            saveSuccess = false;
        }
    }

    public void collectAddresses() {
        List<String> censusSelections = new List<String>();
        for(String grouping : groupingSelections.keySet()) {
            if(groupingSelections.get(grouping)) {
                censusSelections.add(grouping);
            }
        }
        selectedAddressIds = new List<Id>();
        String queryString = 'SELECT Id FROM Customer_Address__c WHERE ' + previousGrouping + ' IN :censusSelections';
        queryString += ' AND Territory__c = :previousTerritoryId AND Plan__c = NULL AND Excluded_from_Territory__c = FALSE';
        queryString += ' AND (Targeted__c = TRUE';
        if(previousIncludeHSIOnly) {
            queryString += ' OR HSI_Only__c = \'YES\'';
        }
        queryString += ')';
            //US1075742- Start
            if(ExcludeNonmarketableOnly){
                queryString += ' AND Non_Marketable__c = false ';
            }
            //US1075742- End      
        List<Customer_Address__c> selectedAddresses = Database.query(queryString);
        for(Customer_Address__c selectedAddress : selectedAddresses) {
            selectedAddressIds.add(selectedAddress.Id);
        }
        System.debug('>>>>>collectAddresses.selectedAddressIds.size = '+selectedAddressIds.size());
        addressIdsJson = JSON.serialize(selectedAddressIds);
    }

    public void reset() {
        
         //modified line by Joognu Rao:to implement US1045181
          //Changed Plan_Status__c value from 'Draft' to 'Assigned'
        turf = new Plan__c(Plan_Status__c = 'Assigned', Plan_Level__c = 'Turf');
        
        if(currentUser.Comcast_Division__c=='West'){
                turf.Expiration_Date__c = Date.today() + 75;
        } else {
                turf.Expiration_Date__c = Date.today() + 60;
        }
        territory.OwnerId = null;
        queryAddressesInTerritory();
    }

    /**    
    * @Description: Method call to update addresses from Turf Planning Page
    * @Author: Accenture    
    * @Param:  List<Customer_Address__c> addresses
    * @Return: None 
    * @Modified By : Sagarika - US1085932 - Territory - # of Address displays as 0 after creating Turf
    * @Modification Description : Fix to address issoe of #of Addresses appears as 0 after creating plans.
    * Added code to update plans with no of addresses after creation.
    * This method is called from the VF page and hence the addresses sent to this method will always be part of the same plan. 
    * The SOQL must return only 1 plan in this case
    **/
    @RemoteAction
    global static void updateAddresses(List<Customer_Address__c> addresses) {
        TurfPlanningController.TurfPlanningPlanUpdate = true;// Added by Srini to avoid multiple updates on plan
        update addresses;
         //US1085932  :Start
        if(addresses != null && addresses.size() > 0)
        {
            Set<String> planIds = new Set<String>();
            Set<String> addressIds = new Set<String>();
            Decimal noOfAddresses = 0;
            set<string> setcensus= new set<string>();
            string strcensustracts = '';
            for(Customer_Address__c address : addresses)
            {
                if(String.isNotBlank(address.Plan__c))
                {
                    planIds.add(address.Plan__c);
                    addressIds.add(address.id);
                    noOfAddresses++;
                }
            } 
            // US1096537 - Starts 
            if(!addressIds.IsEmpty()){
                for(Customer_Address__c  objadress :[Select Id,Census_Tract__c from Customer_Address__c where id IN: addressIds]){
                  setcensus.add(objadress.Census_Tract__c);
                }
            }
            if(!setcensus.IsEmpty()){
               for(string objstr:setcensus){
                   // getting all census tracts seperated by ","
                   strcensustracts +=   ','+objstr;
               }
               // US1085932  :End 
            }
            if(!planIds.isEmpty())
            {
                List<Plan__c> plans = [Select Id, Number_of_Addresses_Currently_on_Plan__c,Census_Tracts__c From Plan__c Where Id IN: planIds];
                for(Plan__c plan : plans)
                {
                    plan.Number_of_Addresses_Currently_on_Plan__c = plan.Number_of_Addresses_Currently_on_Plan__c + noOfAddresses;
                    plan.Census_Tracts__c = strcensustracts;
                }
          update plans;
            }
        } 
        //US1085932 : End
    }
}