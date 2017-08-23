/***************************************************************************************************************************************
 * Author     : Vivek Patel, Accenture
 * Date       : 07-March-2013
 * Description: This is the controller of Planning page. which queries Address Statistics based on Node or Zip code entered.
 * Requirement: 258, 259, 260, 262, 325 - Ability to search statistics based on Zip code or Node and Color code in red which are assigned within 90 days which is configurable value in custom setting.
 * History
     Version             : 1.0
     Author Last Updated : Vivek Patel, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/

public class PlanningController {
    
    public Boolean searchClicked { get; set; }
    public List<AddressStatsWrapper> addStatWraps { get; set; }
    public String selectedGroup { get; set; }
    public String zipString { get; set; }
    public string mapDataPointsStr {get; set; }
    public String nodeString { get; set; }
    public boolean nextButton { get; set; }
    public boolean previousButton { get; set; }
    Set<String> zipSet;
    Set<String> nodeSet;
    public Integer noOfAssignedDays;
    public Integer noOfKnockedDays;
    Set<String> selectedZipOrNodeSet;
    public Integer noOfRecordsPerPage { get; set; }
    public Integer currentPage=0;
    public String unlocatedZips;
    String queryString;
    /*
    This is a wrapper class which allows selection of Zip code or node on Planning screen by wrapping Address Statistics and their selection.
    */
    public class AddressStatsWrapper {
        public boolean selected { get; set; }
        public Address_Statistics__c addStat { get; set; }
        public AddressStatsWrapper(Address_Statistics__c a, Boolean added) {
            selected = added;
            addStat = a;
        }
    }
    public PlanningController() {
        addStatWraps = new List<AddressStatsWrapper>();
        selectedZipOrNodeSet = new Set<String>();
        noOfRecordsPerPage = 10;
    }
    
/***********************************************************************************************************************************
     * Author     : Vivek Patel, Accenture
     * Param      : None
     * Return     : PageReference
     * Description: Below two methods are used for paginating the Address statistics search results.
************************************************************************************************************************************/
    public PageReference next() {
        updateSelectedValuesSet();
        currentPage++;
        List<Address_Statistics__c> addressStats;
        try {
            addressStats = Database.Query(queryString + ' Offset '+ currentPage*noOfRecordsPerPage);
        } catch(Exception ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
            ApexPages.addMessage(msg); 
            System.debug('Following exception occurred :'+ex.getMessage());
            return null;
        }
        if(addressStats.size() == 0) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, Label.PaginationLastPage);
            ApexPages.addMessage(msg);
            currentPage--;
            return null;
        }
        if(addressStats != null) {
            addStatWraps.clear();
            for(Address_Statistics__c addStatObj :addressStats) {
                if(selectedZipOrNodeSet.contains(addStatObj.Zip_Code__c) || selectedZipOrNodeSet.contains(addStatObj.Node__c)) {
                    addStatWraps.add(new AddressStatsWrapper(addStatObj, true));
                } else {
                    addStatWraps.add(new AddressStatsWrapper(addStatObj, false));
                }
            }
        }
        return null;
    }

    public PageReference previous() {
        updateSelectedValuesSet();
        currentPage--;
        if(currentPage < 0) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, Label.PaginationFirstPage);
            ApexPages.addMessage(msg);
            currentPage++;
            return null;
        }
        List<Address_Statistics__c> addressStats;
        try {
            addressStats = Database.Query(queryString + ' Offset '+ currentPage*noOfRecordsPerPage);
        } catch(Exception ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
            ApexPages.addMessage(msg);
            System.debug('Following exception occurred :'+ex.getMessage());
            return null;
        }
        
        if(addressStats != null) {
            addStatWraps.clear();
            for(Address_Statistics__c addStatObj :addressStats) {
                if(selectedZipOrNodeSet.contains(addStatObj.Zip_Code__c) || selectedZipOrNodeSet.contains(addStatObj.Node__c)) {
                    addStatWraps.add(new AddressStatsWrapper(addStatObj, true));
                } else {
                    addStatWraps.add(new AddressStatsWrapper(addStatObj, false));
                }
            }
        }
        return null;
    }
    
    public void updateSelectedValuesSet() {
        for(AddressStatsWrapper addStatWrap : addStatWraps ) {
            if(addStatWrap.selected) {
                if(selectedGroup == 'ZipCode')
                    selectedZipOrNodeSet.add(addStatWrap.addStat.Zip_Code__c);
                if(selectedGroup == 'Node')
                    selectedZipOrNodeSet.add(addStatWrap.addStat.Node__c);
            } else {
                if(selectedGroup == 'ZipCode')
                    selectedZipOrNodeSet.remove(addStatWrap.addStat.Zip_Code__c);
                if(selectedGroup == 'Node')
                    selectedZipOrNodeSet.remove(addStatWrap.addStat.Node__c);
            }
        }
    }
/***********************************************************************************************************************************
     * Author     : Amitkumar Bangad, Accenture
     * Param      : None
     * Return     : PageReference
     * Description: Below Method navigates to the Map View.
************************************************************************************************************************************/       
    public PageReference navigateToMap() {
        try{
            noOfAssignedDays = (Integer) ConfigurableParameters__c.getValues('Config_ZipOrNodeAssignedDays').NumberValue__c;
            noOfKnockedDays = (Integer) ConfigurableParameters__c.getValues('Config_ZipOrNodeKnockedDays').NumberValue__c;
        } catch(Exception ex) {
            System.debug('No data found in custom setting:'+ex);
        } 
        mapDataPointsStr = '';
        queryString = '';
        unlocatedZips = '';
        List<Address_Statistics__c> addressStats = new List<Address_Statistics__c>();
        zipSet = new Set<String>();
        
        if(zipString != null && zipString.trim().length()!=0) {
            List<String> zipTokens = zipString.split(',',0);
            for(Integer i=0 ; i<zipTokens.size(); i++) {
                zipSet.add(zipTokens[i].trim());
            }
        }
        if((zipSet.IsEmpty())) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, 'Please enter atleast one zipcode');
            ApexPages.addMessage(msg);
            return null;
        }
        User currentUser = [Select Id, Region__c From User Where Id =: UserInfo.getUserId() limit 1];
        queryString='Select Zip_Code__c, Node__c, Assigned__c, Currently_Assigned_to_Turf__c, Assigned_in_last__c, Knocked_in_last__c, Last_Assigned_Date__c, Last_Knock_Date__c, Num_of_Currently_Unassigned__c,  Num_of_Currently_Assigned__c, Percent_Currently_Unassigned__c, Percent_Currently_Assigned__c, Percent_Competitive_Disco_to_Former__c, Knocked__c, Latitude__c, Longitude__c, Disconnect__c, Active__c, Never__c, Former__c, Percent_Nonpay_Disco_to_Former__c, Percent_Complex_Code__c, Percent_Active_Video__c, Percent_Active_CHSI__c, Percent_Active_CDV__c, Percent_Single__c, Percent_Double__c, Percent_Triple__c, TP_Acquisition_Score__c, TP_Upgrade_Score__c, Video_Acquisition_Score__c, HSD_Acquisition_Score__c, CDV_Acquisition_Score__c, Colour__c, Worked__c from Address_Statistics__c';
        if(currentUser.Region__c != null && currentUser.Region__c != 'Global'){
            queryString += ' where Region__c =\''+currentUser.Region__c+'\'';
            if(zipSet.size()>0) {
                queryString = queryString + ' AND Zip_Code__c In :zipSet';
                selectedGroup = 'ZipCode';
            }
        }
        else if(zipSet.size()>0) {
            queryString = queryString + ' where Zip_Code__c In :zipSet';
            selectedGroup = 'ZipCode';
        }
        try {
            system.debug(queryString);
            addressStats = Database.Query(queryString);
        } catch(Exception ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
            ApexPages.addMessage(msg);            
            System.debug('Following exception occurred :'+ex.getMessage());
            return null;
        }
        if(!(addressStats.IsEmpty())) {
            for(Address_Statistics__c addStatObj :addressStats) { 
                if(addStatObj.Latitude__c != null && addStatObj.Latitude__c != 0 && addStatObj.Longitude__c != null && addStatObj.Longitude__c != 0){
                    mapDataPointsStr += addStatObj.Zip_Code__c + '$' + String.ValueOf(addStatObj.Latitude__c) + '$' + String.ValueOf(addStatObj.Longitude__c) + '$' + '% Currently Assigned : '+ String.ValueOf(addStatObj.Percent_Currently_Assigned__c)+'%' + '$' + '% Currently Unassigned : ' + String.ValueOf(addStatObj.Percent_Currently_Unassigned__c)+'%' + '$' + '% Assigned in Last ' + addStatObj.Assigned_in_last__c + '$' + '% Knocked in Last ' +addStatObj.Knocked_in_last__c + '$' +addStatObj.Colour__c + '$' + addStatObj.Id + '@';
                } else {
                    if(unlocatedZips != ''){
                        unlocatedZips += ', ' + addStatObj.Zip_Code__c;
                    }else {
                        unlocatedZips = addStatObj.Zip_Code__c + ' ';
                    }
                }
            }
        } else {
            ApexPages.Message ermsg = new ApexPages.Message(ApexPages.Severity.INFO,'No Latitude/Longitude data available for :' + zipString);
            ApexPages.addMessage(ermsg);
        }
        system.debug('>>>>> mapDataPointSTR'+mapDataPointsStr);
        /*zipString = '22206';
        15636$45.034500$-92.971900$0$100$ 100.0%$ 33.33%$#ffff00@
        22206$38.846$-77.078$% Currently Assigned : 70%$% Currently Unassigned : 30%$% Assigned in Last 90 days : 75%$% Knocked in Last 30 Days : 79%$#ff0000@
        mapDataPointsStr += '22206' + '$' + '38.846' + '$' + '-77.078' + '$' + '% Currently Assigned : 70%' + '$' + '% Currently Unassigned : 30%' + '$' + '% Assigned in Last 90 days : 75%' + '$' + '% Knocked in Last 30 Days : 79%' + '$' +'#ff0000' + '@'; */
        return Page.PlotZipCodeStatistics;
    }
    public PageReference navigatingBackFromMap() {
      return Page.Planning;
   }

/***********************************************************************************************************************************
     * Author     : Vivek Patel, Accenture
     * Param      : None
     * Return     : PageReference
     * Description: This method searches Zip code or Node in Address statistics table based on the user input.
************************************************************************************************************************************/
    public PageReference searchZipOrNode() {
        searchClicked = true; 
        addStatWraps.clear();
        selectedZipOrNodeSet.clear();
        queryString = '';
        zipSet = new Set<String>();
        nodeSet = new Set<String>();
        
        if(zipString != null && zipString.trim().length()!=0) {
            List<String> zipTokens = zipString.split(',',0);
            for(Integer i=0 ; i<zipTokens.size(); i++) {
                zipSet.add(zipTokens[i].trim());
            }
        }
        
        if(nodeString != null && nodeString.trim().length()!=0) {
            List<String> nodeTokens = nodeString.split(',',0);
            for(Integer i=0 ; i<nodeTokens.size(); i++) {
                nodeSet.add(nodeTokens[i].trim());
            }
        }
        
        if(zipSet.size()==0 && nodeSet.size()==0) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, Label.EnterZipOrNode);
            ApexPages.addMessage(msg);
            searchClicked = false; 
            return null;
        }
        User currentUser = new User();
        currentUser = [Select Id, Region__c From User Where Id =: UserInfo.getUserId() limit 1];
        queryString='Select Colour__c, Zip_Code__c, Node__c, Assigned__c, Currently_Assigned_to_Turf__c, Knocked_in_last__c, Last_Assigned_Date__c, Last_Knock_Date__c, Num_of_Currently_Assigned__c, Percent_Currently_Assigned__c, Percent_Competitive_Disco_to_Former__c, Disconnect__c, Active__c, Never__c, Former__c, Percent_Nonpay_Disco_to_Former__c, Percent_Complex_Code__c, Percent_Active_Video__c, Percent_Active_CHSI__c, Percent_Active_CDV__c, Percent_Single__c, Percent_Double__c, Percent_Triple__c, TP_Acquisition_Score__c, TP_Upgrade_Score__c, Video_Acquisition_Score__c, HSD_Acquisition_Score__c, CDV_Acquisition_Score__c, Worked__c from Address_Statistics__c';
        if(currentUser.Region__c != null && currentUser.Region__c != 'Global'){
            queryString += ' where Region__c =\''+currentUser.Region__c+'\'';
            if(nodeSet.size()>0) {
                queryString = queryString + ' AND Node__c In :nodeSet';
                selectedGroup = 'Node';
            } else if(zipSet.size()>0) {
                queryString = queryString + ' AND Zip_Code__c In :zipSet';
                selectedGroup = 'ZipCode';
            }
        } else if(nodeSet.size()>0) {
            queryString = queryString + ' where Node__c In :nodeSet';
            selectedGroup = 'Node';
        } else if(zipSet.size()>0) {
            queryString = queryString + ' where Zip_Code__c In :zipSet';
            selectedGroup = 'ZipCode';
        }
        queryString = queryString + ' Limit '+ noOfRecordsPerPage;
        
        List<Address_Statistics__c> addressStats;
        
        try {
            addressStats = Database.Query(queryString + ' Offset 0');
        } catch(Exception ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
            ApexPages.addMessage(msg);
            System.debug('Following exception occurred :'+ex.getMessage());
            return null;
        }
        if(addressStats != null) {
            for(Address_Statistics__c addStatObj :addressStats) {
                addStatWraps.add(new AddressStatsWrapper(addStatObj,false));
            }
        }
        return null;
    }
    
/***********************************************************************************************************************************
     * Author     : Vivek Patel, Accenture
     * Param      : None
     * Return     : PageReference
     * Description: This method redirects user to Plan edit page and sets the selected Zip code or Node in the URL paramenters.
************************************************************************************************************************************/
    public PageReference toPlanPage() {
        updateSelectedValuesSet();
        String paramValue= '';
        
        if(selectedGroup == 'ZipCode') {
            for(String zipItem : selectedZipOrNodeSet) {
                paramValue = paramValue + zipItem + ',';
            }
        }
        if(selectedGroup == 'Node') { 
            for(String nodeItem : selectedZipOrNodeSet) {
                paramValue = paramValue + nodeItem + ',';
            }
        }

        if(paramValue != '') {
            paramValue = paramValue.subString(0,paramValue.length()-1);
            paramValue = selectedGroup + ' In ('+paramValue+')';
        }
   
        PageReference pageRef;
        pageRef = new PageReference(Label.PlanEditPageURL);
        if(paramValue != '') {
            pageRef.getParameters().put('NodeOrZip',paramvalue);
        }
        return pageRef;
    }
}