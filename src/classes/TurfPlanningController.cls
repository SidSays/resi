global with sharing class TurfPlanningController {

    public User currentUser;

    public Territory__c territory { get; set; }
    public Id selectedTerritoryId { get; set; }
    public List<SelectOption> territoryOptions { get; set; }
    public String selectedGrouping { get; set; }
    public List<SelectOption> groupingOptions { get; set; }
    public String groupingHeader {
        get {
            return Schema.SObjectType.Customer_Address__c.fields.getMap().get(selectedGrouping).getDescribe().getLabel();
        }
    }
    public Boolean includeHSIOnly { get; set; }

    public Plan__c turf { get; set; }
    public Boolean turfHasTerritory {
        get {
            return turf.Territory__c != null;
        }
    }

    public Map<String,List<Id>> groupedAddresses { get; set; }
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
    public Boolean searchComplete { get; set; }

    //public Date defaultExpirationDate { get; set; }

    public TurfPlanningController() {
        SystemProperties sysProps = new SystemProperties();
        CHUNK_SIZE = Integer.valueOf(sysProps.getSytemProperty('Turf_Assignment_Chunk_Size','Territory Management'));
        THREAD_COUNT = Integer.valueOf(sysProps.getSytemProperty('Territory_Max_Threads','Territory Management'));
        TURF_SIZE = Integer.valueOf(sysProps.getSytemProperty('Turf_Size_Limit','Territory Management'));


        groupingOptions = new List<SelectOption>();
        groupingOptions.add(new SelectOption('Census_Tract__c', 'Census Tract'));
        groupingOptions.add(new SelectOption('Census_Block_Group__c', 'Census Block Group'));
        groupingOptions.add(new SelectOption('Census_Block_Sub_Block__c', 'Census Block Sub Block'));
        selectedGrouping = 'Census_Tract__c';
        includeHSIOnly = false;

        territoryOptions = new List<SelectOption>();
        Id userId = UserInfo.getUserId();
        currentUser = [SELECT Region__c, Comcast_Division__c, Profile.Name From User WHERE Id = :userId];

        territory = new Territory__c();
        turf = new Plan__c(Plan_Status__c = 'Draft', Plan_Level__c = 'Turf', Assigned_Date__c = Date.today(), Number_of_Addresses_on_Playlists__c = 0);
        if(currentUser.Comcast_Division__c=='West'){
                turf.Expiration_Date__c = Date.today() + 75;
        } else {
                turf.Expiration_Date__c = Date.today() + 60;
        }

        List<Territory__c> territories = [SELECT Id, Name FROM Territory__c WHERE Status__c = 'Published' AND Region__c = :currentUser.Region__c];
        for(Territory__c territory : territories) {
            territoryOptions.add(new SelectOption(territory.Id,territory.Name));
        }
    }

    public void queryAddressesInTerritory() {
        territory.Id = selectedTerritoryId;
        turf.Territory__c = selectedTerritoryId;

        String queryString = 'SELECT Id, ' + selectedGrouping + ' FROM Customer_Address__c';
        queryString += ' WHERE Territory__c = :selectedTerritoryId AND Plan__c = NULL AND Excluded__c = FALSE';
        queryString += ' AND (Targeted__c = TRUE';
        if(includeHSIOnly) {
            queryString += ' OR HSI_Only__c = \'YES\'';
        }
        queryString += ')';

        List<Customer_Address__c> addresses = Database.query(queryString);
        
        countAddressesInTerritory(addresses);
        searchComplete = true;
    }

    private void countAddressesInTerritory(List<Customer_Address__c> addresses) {
        groupedAddresses = new Map<String,List<Id>>();
        for(Customer_Address__c address : addresses) {
            String censusGrouping = (String)address.get(selectedGrouping);
            if(!groupedAddresses.containsKey(censusGrouping)) {
                groupedAddresses.put(censusGrouping,new List<Id>());
            }
            groupedAddresses.get(censusGrouping).add(address.Id);
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

    public void save() {
        try {
            User assignedUser = [SELECT Region__c, Comcast_Division__c, Profile.Name FROM User WHERE Id = :territory.OwnerId];
            String allowedProfiles = [SELECT Value__c FROM System_Property__mdt WHERE DeveloperName='Allowed_Turf_Assigned_Profiles'].Value__c;
            List<String> allowedProfilesList = allowedProfiles.split(',');
            Set<String> allowedProfilesSet = new Set<String>();
            allowedProfilesSet.addAll(allowedProfilesList);
            collectAddresses();

            

            if(currentUser.Region__c != assignedUser.Region__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Assigned User must be in your region!'));
            } else if(!allowedProfilesSet.contains(assignedUser.Profile.Name)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Assigned User must have an allowed profile!'));
            } else {
                update territory;

                turf.OwnerId = UserInfo.getUserId();
                turf.True_count_of_Addresses__c = selectedAddressIds.size();
                turf.Number_of_Addresses_Currently_on_Plan__c = selectedAddressIds.size();
                upsert turf;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }

    public void collectAddresses() {
        selectedAddressIds = new List<Id>();
        for(String grouping : groupingSelections.keySet()) {
            if(groupingSelections.get(grouping) && groupedAddresses.get(grouping) != null && !groupedAddresses.get(grouping).isEmpty()) {
                selectedAddressIds.addAll(groupedAddresses.get(grouping));
            }
        }
        addressIdsJson = JSON.serialize(selectedAddressIds);
    }

    public void reset() {
        turf = new Plan__c(Plan_Status__c = 'Draft', Plan_Level__c = 'Turf');
        queryAddressesInTerritory();
    }

    @RemoteAction
    global static void updateAddresses(List<Customer_Address__c> addresses) {
        update addresses;
    }
}