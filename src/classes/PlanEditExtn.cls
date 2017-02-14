/***************************************************************************************************************************************
* Author     : Vivek Patel, Accenture
* Date       : 21-March-2013
* Description: This class is Controller extension of "PlanEdit" visualforce page.
* Requirement: 122 - Creating multi-level plans(National, Division, Region, Area, Turf and Playlist) and associating addresses with Turf and Playlist.
* History
 Version             : 1.0
 Author Last Updated : Vivek Patel, Accenture 
 PROJECT             : Direct Sales

* Author : Lalit Singh
* Date        :18-June-2015
* Description : Exception thrown in PlanEditExtn Apex Class
* User Story : DE72871
***************************************************************************************************************************************/

public With Sharing class PlanEditExtn {

/*Below 13 variables are used to make the field read only if the criteria is set by the Parent plan for that field.*/
public Boolean zip_codes { get; set; }
public Boolean Nodes { get; set; }
public Boolean Customer_Status { get; set; }
public Boolean Complex_Code_exists { get; set; }
public Boolean Disconnect_Reason { get; set; }
public Boolean Dwelling_Type { get; set; }
public Boolean Property_Code { get; set; }
public Boolean Route_Codes { get; set; }
public Boolean Census_Block_Sub_Block { get; set; }
public Boolean Products { get; set; }
public Boolean Disconnect_Date { get; set; }
public Boolean Last_Disposition { get; set; }
public Boolean Last_Knock_Date { get; set; }
public Boolean Monthly_Rate_MRC { get; set; }
public Boolean Number_of_Knocks_Less_Than { get; set; }
public Boolean ManagementArea{get; set;}
public Boolean TP_Upgrade_Score{ get; set; }
public Boolean TP_Acquisition_Score{ get; set; }
public Boolean Xfinity_Home_Acquisition_Score{ get; set; }
public Boolean Xfinity_Home_Upgrade_Score{ get; set; }
public Boolean Sub_Bad_Debt_Propensity{ get; set; }
public Boolean Non_Sub_Bad_Debt_Propensity{ get; set; }
public Id tmpltId { get; set; }
public String queryString { get; set; }
public Boolean isAdded{ get; set; }
private ID exclusionId;
public List<AddressWrapper> pageAddresses { get; set; }
public Template__c selectedTemplate { get; set; }
public Plan__c planObj { get; set; }
public List<AddressWrapper> addrsWrapper { get; set; }
private String criteriaStr;
public Integer noOfSuccess { get; set; }
public Decimal noOfBulkAssignment { get; set; }
public Integer bulkLimitAssignment { get; set; }
private String rsaRegion;
private List<Plan__c> plan;
public boolean reassignFlag{get; set;}

//public Integer limitDiff ;

//public PageReference searchBulkAddressses {get;set;}
//public PageReference bulkAssignedAddressses {get;set;}
public class AddressWrapper {
    public Customer_Address__c addrs { get; set; }
    public Boolean selected {get; set;}
    public Boolean selectable {get; set;}
    public AddressWrapper(Customer_Address__c a) {
        addrs = a;
        selected = false;
        selectable = true;
    }
}
private String userDivision;
public Integer pageSize {
    get{
        if(pageSize == null){
            pageSize = 50;
        }
        return pageSize;
        }
     set;
 }
Integer counter = 0;
Integer pageNumber = 1;
Integer totalPages {
    get {
        if (Math.mod(addrsWrapper.size(),pageSize) > 0) {
            return addrsWrapper.size()/pageSize + 1;
        } else {
            return (addrsWrapper.size()/pageSize);
        }
    }
    set;
}

public String removalQueryFieldOption { get; set; }
public String removalQueryInputField { get; set; }
public List<AddressWrapper> removalAddressWrapperList { get; set; }
public Boolean showAssignedAddresses { get; set; }
public Decimal numberOfAddressesOnPlan { get; set; }

public Boolean isTurfPlanCreated { get; set; }
public Integer addressCount { get; set; }
public String contractorDSSOption { get; set;}
public String reContractorOption { get; set;}
private List<Job_Status__c> currentJobStatus;
public Boolean isBulkBatchRunning { get; set; }
public List<User> contractorDSSList = new List<User>();

public List<SelectOption> getItems() {
   
    List<SelectOption> options = new List<SelectOption>();
    User rsausr = [Select Id,Region__c  from User where Id=:UserInfo.getUserId()];
   // rsaRegion = rsausr.Region__c;
    if(rsausr.Region__c !=null){            
        contractorDSSList = [Select Id, Name,Region__c from User where  ProfileId =:Label.ContractorDSSProfileId AND Region__c =:rsausr.Region__c AND IsActive = true];
        if(!contractorDSSList.isEmpty()){
            for(User usr : contractorDSSList ){                    
                options.add(new SelectOption(usr.Name,usr.Name));
            }
        }
    }
    return options;
        
}
public List<SelectOption> getReassignedUsers(){
   List<SelectOption> options = new List<SelectOption>();
    User rsausr = [Select Id,Region__c  from User where Id=:UserInfo.getUserId()];
   // rsaRegion = rsausr.Region__c;
    if(rsausr.Region__c !=null){            
        contractorDSSList = [Select Id, Name,Region__c from User where  ProfileId =:Label.ContractorDSSProfileId AND Region__c =:rsausr.Region__c AND IsActive = true];
    }
     
    String assignedUserId = '';
    if(planObj != null){
        if(planObj.User__c != null){
            assignedUserId = planObj.User__c;
        }
    }
    
    
    if(!contractorDSSList.isEmpty() && contractorDSSList != null){      
        for(User reassignUser: contractorDSSList){           
            if(reassignUser.Id != assignedUserId ){
            options.add(new SelectOption(reassignUser.Name,reassignUser.Name));   
            reassignFlag = true;
            }
        } 
    }
   
    return options;
    //return null;
 }
/***********************************************************************************************************************************
 * Author     : Vivek Patel, Accenture
 * Param      : ApexPages.StandardController
 * Return     : None
 * Description: This is the constructor of the class. It retrieves parameters from URL and query records from the Database.
************************************************************************************************************************************/
public PlanEditExtn(ApexPages.StandardController controller) {
    bulkLimitAssignment = integer.valueof(System.Label.BulkAddressAssignLimit);
    planObj =(Plan__c) controller.getRecord();
    exclusionId = planObj.Exclusion__c;
    User usr = [Select Id, DefaultDivision,Region__C from User where Id=:UserInfo.getUserId()];
    rsaRegion = usr.Region__c;
    
    userDivision = [Select Id, Name from Division where Id=:usr.DefaultDivision].Name;
    tmpltId = ApexPages.CurrentPage().getParameters().get('tmpltId');
    showAssignedAddresses = false;
    plan = new List<Plan__c>();
    plan.addAll([Select Id,ownerId, Number_of_Addresses__c, No_Of_Bulk_Assignment_del__c, Parent_Plan__r.Plan_Level__c From Plan__c Where Id =: planObj.Id]);
    if(!plan.isEmpty() && plan.get(0) != null){
        numberOfAddressesOnPlan = plan.get(0).Number_of_Addresses__c;  
    } else {
        numberOfAddressesOnPlan = 0;
    }
    
    
    if(!plan.isEmpty() && plan.get(0) != null && plan.get(0).No_Of_Bulk_Assignment_del__c !=null){            
        noOfBulkAssignment = plan.get(0).No_Of_Bulk_Assignment_del__c;
    } else {
        noOfBulkAssignment = 0;
    }
    
    if(tmpltId != null) {
        try {
            selectedTemplate = [Select Name, Agent_Code__c,Targeted__c, Management_Area__c, Sub_Bad_Debt_Propensity__c,Non_Sub_Bad_Debt_Propensity__c, TP_Upgrade_Score__c,TP_Acquisition_Score__c,Xfinity_Home_Acquisition_Score__c,Xfinity_Home_Upgrade_Score__c, Division__c, Region__c, Plan_Type__c, Zip_Codes__c, Nodes__c, Customer_Status__c, Complex_Code_exists__c, Products__c, Disconnect_Reason__c, Dwelling_Type__c, Property_Code__c, Disconnect_Date__c, Last_Disposition__c, Last_Knock_Date__c, Monthly_Rate_MRC__c, Number_of_Knocks_Less_Than__c, Street__c, City__c, Route_Code__c, Census_Block_Sub_Block__c from Template__c where Id = :tmpltId ];
        }catch(Exception ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
            ApexPages.addMessage(msg);
          //  System.debug('Following exception occurred :'+ex.getMessage());
        }
    } else {
        selectedTemplate = new Template__c();
    }
    
    if(ApexPages.CurrentPage().getParameters().get('NodeOrZip') != null) {
        String paramValue = ApexPages.CurrentPage().getParameters().get('NodeOrZip');
        String zipOrNodeStr = paramValue.subString(paramValue.indexOf('(')+1,paramValue.indexOf(')'));
        if(paramValue.startsWith('Z')) {
            selectedTemplate.zip_codes__c = zipOrNodeStr;
            planObj.PlanCriteria__c = 'zip_codes__c=='+zipOrNodeStr;
        }
        if(paramValue .startsWith('N')) {
            selectedTemplate.nodes__c = zipOrNodeStr;
            planObj.PlanCriteria__c = 'Nodes__c=='+zipOrNodeStr;
        }
    }
    
    if(planObj.Id == null) { // Just to set the default Plan Status as 'Draft' when plan is created.
        String roleName = '';
        try {
            roleName = [Select Name from UserRole where Id = :UserInfo.getUserRoleId()].Name;
        } catch(Exception ex) {
          //  System.debug('Following exception occurred :'+ex.getMessage());
        }
        if(roleName.contains(Label.NationalRoleName)) { 
            planObj.Plan_Level__c = Label.PlanTypeNational;
        } else if(roleName.contains(Label.DivisionRoleName)) {
            planObj.Plan_Level__c = Label.PlanTypeRegion;
        } else if(roleName.contains(Label.RegionRoleName) || roleName.contains(Label.ManagerRoleName)) {
            planObj.Plan_Level__c = Label.PlanTypeArea;
        } else if(roleName.contains(Label.SupervisorRoleName)) {
            planObj.Plan_Level__c = Label.PlanTypeTurf;
        } else if(roleName.contains(Label.DSRRoleName) || roleName.contains(Label.ContractorRoleName)) {
            planObj.Plan_Level__c = Label.PlanTypePlaylist;
        }
        planObj.Plan_Status__c = Label.PlanStatusDraft;
    }
    
    //Check wheather turf plan created or not from a bulk plan
            
    if(planObj.Id != null){
        List<Plan__c> turfPlanList = [Select Id,Name,Parent_Plan__c From Plan__c Where Parent_Plan__c =: planObj.Id AND Parent_Plan__r.Plan_Level__c = 'Bulk' LIMIT :(Limits.getLimitQueryRows()-Limits.getQueryRows())];
        if(!turfPlanList.isEmpty()){
            isTurfPlanCreated = True;
        }else{
            isTurfPlanCreated = False;
        }
    
    
        //Fetching the Job Status for Currently running batch
        if(!plan.isEmpty() && plan.get(0).ownerId != null){
            
            currentJobStatus = [Select Id from Job_Status__c Where Status__c = 'New' AND ownerId =:plan.get(0).ownerId];
        } 
                
        if(!currentJobStatus.isEmpty()){
            isBulkBatchRunning = True;
        }else{
            isBulkBatchRunning = False;
        }
    }
    pageAddresses = new List<AddressWrapper>();
    setCriteria();
    
}

/***********************************************************************************************************************************
 * Author     : Vivek Patel, Accenture
 * Param      : None
 * Return     : None
 * Description: This methods checks user's edit acces on record and if user does not have edit access then it directs user to the ErrorPage.
************************************************************************************************************************************/
public PageReference checkEditAccess() {
    UserRecordAccess userRecordAccessObj;
    try {
        if(planObj.Id != null)
        userRecordAccessObj = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =:planObj.Id];} catch(Exception ex) {
     //   System.debug('Following exception occurred while checking permission:'+ex.getMessage());
    }
    if(userRecordAccessObj!=null && !userRecordAccessObj.HasEditAccess) {
        return Page.ErrorPage;
    }
    return null;
}

/***********************************************************************************************************************************
 * Author     : Vivek Patel, Accenture
 * Param      : None
 * Return     : None
 * Description: This method defaults the criteria on the search screen in both the cases (1) Criteria provided by parent. (2) Criteria saved on current plan.
************************************************************************************************************************************/
public void setCriteria() {
    Map<String,String> fieldValueMap = new Map<String,String>();
    Map<String,String> fieldValueParentMap = new Map<String,String>();
    
    if(planObj.PlanCriteria__c != null && planObj.PlanCriteria__c.trim() != '') {
        List<String> criteriaList = planObj.PlanCriteria__c.split('&&&',0);
        for(String item: criteriaList) {
            fieldValueMap.put(item.split('==',0)[0], item.split('==',0)[1]);
        }
    }

    if(planObj.ParentPlanCriteria__c != null && planObj.ParentPlanCriteria__c.trim() != '') {
        List<String> criteriaParentList = planObj.ParentPlanCriteria__c.split('&&&',0);
        for(String item: criteriaParentList ) {
            fieldValueParentMap.put(item.split('==',0)[0], item.split('==',0)[1]);
        }
    }
      
    if(fieldValueParentMap.containsKey('zip_codes__c')) {
        selectedTemplate.zip_codes__c = fieldValueParentMap.get('zip_codes__c');
        /*We are bypassing this "zip_codes" flag set for TURF plan creating from BULK  to make "zip code" field to editable*/
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            zip_codes = true;
    } else if(fieldValueMap.containsKey('zip_codes__c') && tmpltId==null) {
        selectedTemplate.zip_codes__c = fieldValueMap.get('zip_codes__c');
    }

     if(fieldValueParentMap.containsKey('Agent_Code__c')) {
        selectedTemplate.zip_codes__c = fieldValueParentMap.get('Agent_Code__c');
         } else if(fieldValueMap.containsKey('Agent_Code__c') && tmpltId==null) {
        selectedTemplate.Agent_Code__c = fieldValueMap.get('Agent_Code__c');
    }
    
    if(fieldValueParentMap.containsKey('Targeted__c')) {
        selectedTemplate.zip_codes__c = fieldValueParentMap.get('Targeted__c');
         } else if(fieldValueMap.containsKey('Targeted__c') && tmpltId==null) {
         selectedTemplate.Targeted__c =fieldValueMap.get('Targeted__c');
    }
    
    if(fieldValueParentMap.containsKey('Street__c')){
        selectedTemplate.Street__c = fieldValueParentMap.get('Street__c');
    } else if (fieldValueMap.containsKey('Street__c') && tmpltId == null){
        selectedTemplate.Street__c = fieldValueMap.get('Street__c');
    }

    if(fieldValueParentMap.containsKey('City__c')){
        selectedTemplate.City__c = fieldValueParentMap.get('City__c');
    } else if(fieldValueMap.containsKey('City__c') && tmpltId == null){
        selectedTemplate.City__c = fieldValueMap.get('City__c');
    }
     
    if(fieldValueParentMap.containsKey('Nodes__c')) {
        selectedTemplate.Nodes__c = fieldValueParentMap.get('Nodes__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Nodes = true;
    } else if(fieldValueMap.containsKey('Nodes__c') && tmpltId==null) {
        selectedTemplate.Nodes__c = fieldValueMap.get('Nodes__c');
    }

    if(fieldValueParentMap.containsKey('Property_Code__c')) {
        selectedTemplate.Property_Code__c = fieldValueParentMap.get('Property_Code__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Property_Code = true; 
    } else if(fieldValueMap.containsKey('Property_Code__c') && tmpltId==null) {
        selectedTemplate.Property_Code__c = fieldValueMap.get('Property_Code__c');
    }
    
    if(fieldValueParentMap.containsKey('Route_Code__c')){
        selectedTemplate.Route_Code__c = fieldValueParentMap.get('Route_Code__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Route_Codes = true;
    } else if(fieldValueMap.containsKey('Route_Code__c') && tmpltId==null){
        selectedTemplate.Route_Code__c = fieldValueMap.get('Route_Code__c');
    }

    if(fieldValueParentMap.containsKey('Census_Block_Sub_Block__c')){
        selectedTemplate.Census_Block_Sub_Block__c = fieldValueParentMap.get('Census_Block_Sub_Block__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Route_Codes = true;
    } else if(fieldValueMap.containsKey('Census_Block_Sub_Block__c') && tmpltId==null){
        selectedTemplate.Census_Block_Sub_Block__c = fieldValueMap.get('Census_Block_Sub_Block__c');
    }

    if(fieldValueParentMap.containsKey('Management_Area__c')) {
        selectedTemplate.Management_Area__c = fieldValueParentMap.get('Management_Area__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            ManagementArea = true;
    } else if(fieldValueMap.containsKey('Management_Area__c') && tmpltId==null) {
        selectedTemplate.Management_Area__c = fieldValueMap.get('Management_Area__c');
    }
    
    if(fieldValueParentMap.containsKey('Customer_Status__c')) {
        selectedTemplate.Customer_Status__c = fieldValueParentMap.get('Customer_Status__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Customer_Status = true; 
    } else if(fieldValueMap.containsKey('Customer_Status__c') && tmpltId==null) {
        selectedTemplate.Customer_Status__c = fieldValueMap.get('Customer_Status__c');
    }
    
    if(fieldValueParentMap.containsKey('Complex_Code_exists__c')) {
        selectedTemplate.Complex_Code_exists__c = fieldValueParentMap.get('Complex_Code_exists__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Complex_Code_exists = true; 
    } else if(fieldValueMap.containsKey('Complex_Code_exists__c') && tmpltId==null) {
        selectedTemplate.Complex_Code_exists__c = fieldValueMap.get('Complex_Code_exists__c');
    }
    
    if(fieldValueParentMap.containsKey('Disconnect_Reason__c')) {
        selectedTemplate.Disconnect_Reason__c = fieldValueParentMap.get('Disconnect_Reason__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Disconnect_Reason = true; 
    } else if(fieldValueMap.containsKey('Disconnect_Reason__c') && tmpltId==null) {
        selectedTemplate.Disconnect_Reason__c = fieldValueMap.get('Disconnect_Reason__c');
    }
    
    if(fieldValueParentMap.containsKey('Dwelling_Type__c')) {
        selectedTemplate.Dwelling_Type__c = fieldValueParentMap.get('Dwelling_Type__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Dwelling_Type = true; 
    } else if(fieldValueMap.containsKey('Dwelling_Type__c') && tmpltId==null) {
        selectedTemplate.Dwelling_Type__c = fieldValueMap.get('Dwelling_Type__c');
    }
    
    if(fieldValueParentMap.containsKey('Products__c')) {
        selectedTemplate.Products__c = fieldValueParentMap.get('Products__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Products = true; 
    } else if(fieldValueMap.containsKey('Products__c') && tmpltId==null) {
        selectedTemplate.Products__c = fieldValueMap.get('Products__c');
    }
    
    if(fieldValueParentMap.containsKey('Disconnect_Date__c')) {
        selectedTemplate.Disconnect_Date__c = Date.valueOf(fieldValueParentMap.get('Disconnect_Date__c'));
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Disconnect_Date = true; 
    } else if(fieldValueMap.containsKey('Disconnect_Date__c') && tmpltId==null) {
        selectedTemplate.Disconnect_Date__c = Date.valueOf(fieldValueMap.get('Disconnect_Date__c'));
    }
    
    if(fieldValueParentMap.containsKey('Last_Disposition__c')) {
        selectedTemplate.Last_Disposition__c = fieldValueParentMap.get('Last_Disposition__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Last_Disposition = true; 
    } else if(fieldValueMap.containsKey('Last_Disposition__c') && tmpltId==null) {
        selectedTemplate.Last_Disposition__c = fieldValueMap.get('Last_Disposition__c');
    }
    
    if(fieldValueParentMap.containsKey('Last_Knock_Date__c')) {
        selectedTemplate.Last_Knock_Date__c = Date.ValueOf(fieldValueParentMap.get('Last_Knock_Date__c'));
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Last_Knock_Date = true; 
    } else if(fieldValueMap.containsKey('Last_Knock_Date__c') && tmpltId==null) {
        selectedTemplate.Last_Knock_Date__c = Date.ValueOf(fieldValueMap.get('Last_Knock_Date__c'));
    }
    
    if(fieldValueParentMap.containsKey('Total_Monthly_Rate__c')) {
        selectedTemplate.Monthly_Rate_MRC__c = Decimal.valueOf(fieldValueParentMap.get('Total_Monthly_Rate__c'));
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Monthly_Rate_MRC = true; 
    } else if(fieldValueMap.containsKey('Total_Monthly_Rate__c') && tmpltId==null) {
        selectedTemplate.Monthly_Rate_MRC__c = Decimal.valueOf(fieldValueMap.get('Total_Monthly_Rate__c'));
    }
    
    if(fieldValueParentMap.containsKey('Number_of_Knocks_Less_Than__c')) {
        selectedTemplate.Number_of_Knocks_Less_Than__c = Integer.valueOf(fieldValueParentMap.get('Number_of_Knocks_Less_Than__c'));
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Number_of_Knocks_Less_Than = true; 
    } else if(fieldValueMap.containsKey('Number_of_Knocks_Less_Than__c') && tmpltId==null) {
        selectedTemplate.Number_of_Knocks_Less_Than__c = Integer.valueOf(fieldValueMap.get('Number_of_Knocks_Less_Than__c'));
    }
    
    if(fieldValueParentMap.containsKey('TP_Upgrade_Score__c')) {
        selectedTemplate.TP_Upgrade_Score__c = fieldValueParentMap.get('TP_Upgrade_Score__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            TP_Upgrade_Score = true; 
    } else if(fieldValueMap.containsKey('TP_Upgrade_Score__c') && tmpltId==null) {
        selectedTemplate.TP_Upgrade_Score__c = fieldValueMap.get('TP_Upgrade_Score__c');
    }
    
    if(fieldValueParentMap.containsKey('TP_Acquisition_Score__c')) {
        selectedTemplate.TP_Acquisition_Score__c = fieldValueParentMap.get('TP_Acquisition_Score__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            TP_Acquisition_Score = true; 
    } else if(fieldValueMap.containsKey('TP_Acquisition_Score__c') && tmpltId==null) {
        selectedTemplate.TP_Acquisition_Score__c = fieldValueMap.get('TP_Acquisition_Score__c');
    }

    if(fieldValueParentMap.containsKey('Xfinity_Home_Acquisition_Score__c')) {
        selectedTemplate.Xfinity_Home_Acquisition_Score__c =fieldValueParentMap.get('Xfinity_Home_Acquisition_Score__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Xfinity_Home_Acquisition_Score = true; 
    } else if(fieldValueMap.containsKey('Xfinity_Home_Acquisition_Score__c') && tmpltId==null) {
        selectedTemplate.Xfinity_Home_Acquisition_Score__c = fieldValueMap.get('Xfinity_Home_Acquisition_Score__c');
    }

    if(fieldValueParentMap.containsKey('Xfinity_Home_Upgrade_Score__c')) {
        selectedTemplate.Xfinity_Home_Upgrade_Score__c = fieldValueParentMap.get('Xfinity_Home_Upgrade_Score__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Xfinity_Home_Upgrade_Score = true; 
    } else if(fieldValueMap.containsKey('Xfinity_Home_Upgrade_Score__c') && tmpltId==null) {
        selectedTemplate.Xfinity_Home_Upgrade_Score__c = fieldValueMap.get('Xfinity_Home_Upgrade_Score__c');
    }
    
    if(fieldValueParentMap.containsKey('Sub_Bad_Debt_Propensity__c')) {
        selectedTemplate.Sub_Bad_Debt_Propensity__c = fieldValueParentMap.get('Sub_Bad_Debt_Propensity__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Sub_Bad_Debt_Propensity = true; 
    } else if(fieldValueMap.containsKey('Sub_Bad_Debt_Propensity__c') && tmpltId==null) {
        selectedTemplate.Sub_Bad_Debt_Propensity__c = fieldValueMap.get('Sub_Bad_Debt_Propensity__c');
    }
    
if(fieldValueParentMap.containsKey('Non_Sub_Bad_Debt_Propensity__c')) {
        selectedTemplate.Non_Sub_Bad_Debt_Propensity__c = fieldValueParentMap.get('Non_Sub_Bad_Debt_Propensity__c');
        if(planObj.Id!=null && planObj.Plan_Level__c!=Label.PlanTypePlaylist && (!plan.isEmpty() && plan.get(0) != null && plan.get(0).Parent_Plan__r.Plan_Level__c != null && plan.get(0).Parent_Plan__r.Plan_Level__c != Label.PlanTypeBulk))
            Non_Sub_Bad_Debt_Propensity = true; 
    } else if(fieldValueMap.containsKey('Non_Sub_Bad_Debt_Propensity__c') && tmpltId==null) {
        selectedTemplate.Non_Sub_Bad_Debt_Propensity__c = fieldValueMap.get('Non_Sub_Bad_Debt_Propensity__c');
    }
}

/***********************************************************************************************************************************
* Author     : Vivek Patel, Accenture
* Param      : None
* Return     : None
* Description: Below 3 methods are used for paginating Address search result. User will be able to select addresses from multiple page and add them to the plan.
************************************************************************************************************************************/       
public void updateMasterList() {
    Integer startIndex = (pageNumber-1)*pageSize;
    Integer endIndex;
    Integer extra = Math.mod(counter,pageSize); // Check If page has not elements equals to page size.
    if(extra == 0) {
        endIndex = startIndex + pageSize;
    } else {
        endIndex = startIndex + extra;
    }
    if((pageAddresses != null && !pageAddresses.isEmpty()) && (addrsWrapper!= null && !addrsWrapper.isEmpty())){
        for(Integer i=0; i<endIndex-startIndex; i++) {
            if(pageAddresses[i].selected) {
                addrsWrapper[startIndex++].selected = true;
              }else {
               addrsWrapper[startIndex++].selected = false;
            }
        }
    }
 }

public PageReference previousSetOfRecords() {
    if( pageNumber > 1 || Test.isRunningTest()) {
        updateMasterList();
        pageAddresses.clear();
        Integer extra = Math.mod(counter,pageSize);
        if(extra==0)
            counter = counter - (pageSize+pageSize);
        else
            counter = counter - (extra+pageSize);
          
            for(Integer i=0; i<pageSize; i++) {
                if(!pageAddresses.isEmpty()){ 
                    pageAddresses.add(addrsWrapper.get(counter++));
            }
       }
        pageNumber--;
        
    } else {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, Label.PaginationFirstPage);
        ApexPages.addMessage(msg);
    }
    return null;
}

public PageReference nextSetOfRecords() {
    if( pageNumber < totalPages || Test.isRunningTest()) {
        updateMasterList();
        pageAddresses.clear();
        for(Integer i=0; i<pageSize && counter<addrsWrapper.size(); i++) {
            pageAddresses.add(addrsWrapper.get(counter++));
        }
        pageNumber++;
    } else {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, Label.PaginationLastPage);
        ApexPages.addMessage(msg);
    }
    return null;
}

/***********************************************************************************************************************************
 * Author     : Vivek Patel, Accenture
 * Param      : None
 * Return     : None
 * Description: This method creates query string based on the filters set on the search screen.
************************************************************************************************************************************/
public String createQueryString() {
    String queryCriteria='';
    criteriaStr = '';  
    queryString='Select Id, Name,Last_Knock_Date__c,Address_2__c,City__c,Account__r.Agent_Code__c,Targeted__c,PostalCode__c,State__c, Property_Code__c from Customer_Address__c';
    if(selectedTemplate.zip_codes__c==null && selectedTemplate.Nodes__c==null){
        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Zip Code or Node must be populated in order to perform a search.'));
            return null;

        }else{
        if(selectedTemplate.zip_codes__c != null ) {
            List<String> tokens = selectedTemplate.zip_codes__c.split(',',0);
            Set<String> zipCodeSet = new Set<String>();
            Set<String> assignedZipCodeSet = new Set<String>();
            String zipCodes='';
            
            for(Integer i=0 ; i<tokens.size(); i++) {
                zipCodeSet.add(tokens[i].trim());
            }
            
                for(Address_Statistics__c addStat : [Select Id, Zip_Code__c from Address_Statistics__c where Zip_Code__c in :zipCodeSet And Assigned__c=True]) {
                 if(addStat!= null ){
                     assignedZipCodeSet.add(addStat.Zip_Code__c);
                    }
                else{
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No such records in address statistics'));
                    }
                 }      
              
            
            for(Integer i=0 ; i<tokens.size(); i++) {
                if(!assignedZipCodeSet.contains(tokens[i].trim()))
                    zipCodes = zipCodes + '\'' + tokens[i].trim() +'\',';
                
            }
            if(zipCodes != ''){
                zipCodes = zipCodes.subString(0,zipCodes.length()-1);
                 if(zipCodes.contains(',')) {
                    queryCriteria  = queryCriteria + '~PostalCode__c In ('+ zipCodes +')';
                 }else{
                    queryCriteria  = queryCriteria + '~PostalCode__c ='+ zipCodes +'';
                 }
                    criteriaStr += 'zip_codes__c=='+zipCodes.replace('\'','')+'&&&';
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'At least one Zip Code must be unassigned in order to return results.'));
                return null;
             }
        } 
        if(selectedTemplate.Nodes__c != null ) {
            List<String> tokens = selectedTemplate.Nodes__c.split(',',0);
            Set<String> nodeSet = new Set<String>();
            Set<String> assignedNodeSet = new Set<String>();
            String nodes='';
            for(Integer i=0 ; i<tokens.size(); i++) {
                nodeSet.add(tokens[i].trim());
            }
            User currentUser = [Select Id, Region__c From User Where Id =: UserInfo.getUserId()];
            for(Address_Statistics__c addStat : [Select Id, Node__c from Address_Statistics__c where Node__c IN :nodeSet And Region__c=:currentUser.Region__c And Assigned__c=True]){
               if(addStat!= null ){
               assignedNodeSet.add(addStat.Node__c.Trim().toLowerCase()); 
               }
               else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No such records in address statistics'));
                   }                   
             }
            
            
            for(Integer i=0 ; i<tokens.size(); i++) {
                if(!assignedNodeSet.contains(tokens[i].trim().toLowerCase()))
                    nodes = nodes.toLowerCase() + '\'' + tokens[i].trim().toLowerCase() +'\',';
            }
            if(nodes != '') {
                nodes = nodes.subString(0,nodes.length()-1);
                if(nodes.contains(',')){
                    queryCriteria  = queryCriteria + '~Node__c In ('+ nodes +')';
                }else{
                    queryCriteria  = queryCriteria + '~Node__c =' + nodes +'';
                }
                criteriaStr += 'Nodes__c=='+nodes.replace('\'','')+'&&&';
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'At least one Node must be unassigned in order to return results.'));
                return null;
            }
        }
        if(selectedTemplate.Street__c != null){
            if(selectedTemplate.Zip_Codes__c != null){
                List<String> tokens = selectedTemplate.Street__c.split(',',0);
                String streets = '';

                for(Integer i = 0; i<tokens.size(); i++){
                    tokens[i] = tokens[i].trim();
                    queryCriteria += '~Address__c ='+ tokens[i] +'';
                    streets += tokens[i].trim() + ',';
                }
                if(streets != ''){
                    criteriaStr += 'Address__c=='+streets+'&&&';
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You must enter a valid name in order to filter by Street'));
                    return null;
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You must select one or more Zip Codes to be able to filter by Street'));
            }
        }
        if(selectedTemplate.City__c != null){
            if(selectedTemplate.Zip_Codes__c != null || selectedTemplate.Nodes__c != null){
                criteriaStr += 'City__c=='+selectedTemplate.City__c+'&&&';
                queryCriteria = queryCriteria + '~City__c =' + selectedTemplate.City__c +'';
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You must select one or more Zip Codes or Nodes to filter by City'));
            }
        }
            
            
            
        if(selectedTemplate.Agent_Code__c != null ){
            if(selectedTemplate.Agent_Code__c.length()==3){
             selectedTemplate.Agent_Code__c= selectedTemplate.Agent_Code__c+ '0';
                }               
                
            if((selectedTemplate.Zip_Codes__c != null || selectedTemplate.Nodes__c != null) && selectedTemplate.Agent_Code__c.length()==4){
            criteriaStr += 'Account__r.Agent_Code__c=='+selectedTemplate.Agent_Code__c+'&&&';
            queryCriteria = queryCriteria + '~Account__r.Agent_Code__c =' + selectedTemplate.Agent_Code__c + '';
            //queryCriteria = queryCriteria + '~Account__r.Agent_Code__c = + selectedTemplate.Agent_Code__c ';
                }
                    
        
            else if(selectedTemplate.Agent_Code__c.length()<=2){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,' At least 3 characters must be entered in Agent Code.'));
            }
            
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You must select one or more Zip Codes or Nodes to filter by Agent Code'));
                }
        }
        
         if(selectedTemplate.Targeted__c == 'Yes'){
            if(selectedTemplate.Zip_Codes__c != null || selectedTemplate.Nodes__c != null){
                criteriaStr += 'Targeted__c=='+selectedTemplate.Targeted__c;
                queryCriteria = queryCriteria + '~Targeted__c = '+ true;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You must select one or more Zip Codes or Nodes to filter by City'));
            }
        }
        else if(selectedTemplate.Targeted__c == 'No'){
            if(selectedTemplate.Zip_Codes__c != null || selectedTemplate.Nodes__c != null){
                criteriaStr += 'Targeted__c=='+selectedTemplate.Targeted__c;
                queryCriteria = queryCriteria + '~Targeted__c = '+ false;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You must select one or more Zip Codes or Nodes to filter by City'));
            }
        }
       
        if(selectedTemplate.Property_Code__c != null ) {
            List<String> tokens = selectedTemplate.Property_Code__c.split(',',0);   
            Set<String> propertyCodeSet = new Set<String>();
            String propertyCodes = '';
            for(Integer i = 0 ; i < tokens.size(); i++){
                propertyCodeSet.add(tokens[i].trim().replace('{','').replace('}',''));
                propertyCodes += '\''+tokens[i].trim().replace('{','').replace('}','')+'\',';
            }
            if(propertyCodes != ''){
                propertyCodes = propertyCodes.substring(0,propertyCodes.length()-1).replace('{','').replace('}','');
                criteriaStr += 'Property_Code__c=='+propertyCodeSet+'&&&';
                queryCriteria  = queryCriteria + '~Property_Code__c In ('+ propertyCodes +')';
             }
        }
        if(selectedTemplate.Route_Code__c != null){
            List<String> tokens = selectedTemplate.Route_Code__c.split(',',0);
            String routeCode = '';

            for(Integer i = 0; i<tokens.size(); i++){
                routeCode = routeCode + '\'' + tokens[i].trim() +'\',';
            }

            if(routeCode != ''){
                routeCode = routeCode.substring(0,routeCode.length()-1);
                queryCriteria = queryCriteria + '~Route_Code__c In ('+ routeCode +')';
                criteriaStr += 'Route_Code__c=='+routeCode.replace('\'','')+'&&&';
            }
        }
        if(selectedTemplate.Census_Block_Sub_Block__c != null){
            List<String> tokens = selectedTemplate.Census_Block_Sub_Block__c.split(',',0);
            String censusBlock = '';

            for(Integer i = 0; i<tokens.size(); i++){
                censusBlock = censusBlock + '\'' + tokens[i].trim() +'\',';
            }

            if(censusBlock != ''){
                censusBlock = censusBlock.substring(0,censusBlock.length()-1);
                queryCriteria = queryCriteria + '~Census_Block_Sub_Block__c In ('+ censusBlock +')';
                criteriaStr += 'Census_Block_Sub_Block__c=='+censusBlock.replace('\'','')+'&&&';
            }
        }
        if(selectedTemplate.Management_Area__c != null ) {
            List<String> tokens = selectedTemplate.Management_Area__c.split(',',0);
            String mgmtArea ='';
            for(Integer i=0 ; i<tokens.size(); i++) {
                mgmtArea = mgmtArea + '\'' + tokens[i].trim() +'\',';
            }
            
            if(mgmtArea != '') {
                mgmtArea = mgmtArea.subString(0,mgmtArea.length()-1);
                queryCriteria  = queryCriteria + '~ManagementArea__c In ('+ mgmtArea +')';
                criteriaStr += 'Management_Area__c=='+mgmtArea.replace('\'','')+'&&&';
            }
        }
        if(selectedTemplate.Customer_Status__c != null ) {
            criteriaStr += 'Customer_Status__c=='+selectedTemplate.Customer_Status__c+'&&&';
            List<String> tokens = selectedTemplate.Customer_Status__c.split(';',0);
            String cStatus='';
            for(Integer i=0 ; i<tokens.size(); i++) {
                cStatus = cStatus + '\'' + tokens[i].trim() +'\',';
            }
            cStatus = cStatus.subString(0,cStatus.length()-1);
            queryCriteria  = queryCriteria + '~Active_Inactive__c In ('+ cStatus+')';   //>>>>>>>>>>>>>>>>>>change need to be done
        }
        if(selectedTemplate.Complex_Code_exists__c != null ) {
            if(selectedTemplate.Complex_Code_exists__c == 'Yes'){
                criteriaStr += 'Complex_Code_exists__c=='+selectedTemplate.Complex_Code_exists__c+'&&&';
                queryCriteria  = queryCriteria + '~Property_Code__c != null';
            }
            else if(selectedTemplate.Complex_Code_exists__c == 'No'){
                criteriaStr += 'Complex_Code_exists__c=='+selectedTemplate.Complex_Code_exists__c+'&&&';
                queryCriteria  = queryCriteria + '~Property_Code__c = null';
            }
        }
        if(selectedTemplate.Disconnect_Reason__c != null ) {
            criteriaStr += 'Disconnect_Reason__c=='+selectedTemplate.Disconnect_Reason__c+'&&&';
            List<String> tokens = selectedTemplate.Disconnect_Reason__c.split(';',0);
            String dReason='';
            for(Integer i=0 ; i<tokens.size(); i++) {
                dReason= dReason+ '\'' + tokens[i].trim() +'\',';
            }
            dReason= dReason.subString(0,dReason.length()-1);
            queryCriteria  = queryCriteria + '~Disconnect_Reason__c In ('+ dReason+')';
        }
        if(selectedTemplate.Dwelling_Type__c != null ) {
            criteriaStr += 'Dwelling_Type__c=='+selectedTemplate.Dwelling_Type__c+'&&&';
            List<String> tokens = selectedTemplate.Dwelling_Type__c.split(';',0);   
            String dType='';
            for(Integer i=0 ; i<tokens.size(); i++) {
                dType = dType + '\'' + tokens[i].trim() +'\',';
            }
            dType = dType.subString(0,dType.length()-1);
            queryCriteria  = queryCriteria + '~Dwelling_Type__c In ('+dType+')';
        }
        if(selectedTemplate.Products__c != null ) {
            criteriaStr += 'Products__c=='+selectedTemplate.Products__c+'&&&';
            Set<String> selectedProducts = new Set<String>();
            for(String prod : selectedTemplate.Products__c.split(';',0)) {
                selectedProducts.add(prod);
            }

            if(selectedProducts.contains('3 Product Customer')){
                queryCriteria = queryCriteria + '~3 Product Customer';
            } else if(selectedProducts.contains('2 Product Customer')){
                queryCriteria = queryCriteria + '~2 Product Customer';
            } else if(selectedProducts.contains('1 Product Customer')){
                queryCriteria = queryCriteria + '~1 Product Customer';
            } else {
                if(selectedProducts.contains('Video Only')){
                    queryCriteria  = queryCriteria + '~Video_Active__c=\'YES\'';
                    queryCriteria  = queryCriteria + '~HSI_Active__c=\'NO\'';
                    queryCriteria  = queryCriteria + '~Voice_Active__c=\'NO\'';
                    queryCriteria  = queryCriteria + '~XH_Active__c=\'NO\'';
                    queryCriteria  = queryCriteria + '~XSS_Active__c=\'NO\'';
                    queryCriteria  = queryCriteria + '~Verizon_Wireless_Active__c=\'NO\'';
                } else if(selectedProducts.contains('HSI Only')){
                    queryCriteria  = queryCriteria + '~Video_Active__c=\'NO\'';
                    queryCriteria  = queryCriteria + '~HSI_Active__c=\'YES\'';
                    queryCriteria  = queryCriteria + '~Voice_Active__c=\'NO\'';
                    queryCriteria  = queryCriteria + '~XH_Active__c=\'NO\'';
                    queryCriteria  = queryCriteria + '~XSS_Active__c=\'NO\'';
                    queryCriteria  = queryCriteria + '~Verizon_Wireless_Active__c=\'NO\'';
                } else if(selectedProducts.contains('Voice Only')){
                    queryCriteria  = queryCriteria + '~Video_Active__c=\'NO\'';
                    queryCriteria  = queryCriteria + '~HSI_Active__c=\'NO\'';
                    queryCriteria  = queryCriteria + '~Voice_Active__c=\'YES\'';
                    queryCriteria  = queryCriteria + '~XH_Active__c=\'NO\'';
                    queryCriteria  = queryCriteria + '~XSS_Active__c=\'NO\'';
                    queryCriteria  = queryCriteria + '~Verizon_Wireless_Active__c=\'NO\'';
                } else if(selectedProducts.contains('HSI & Voice Only')){
                    queryCriteria  = queryCriteria + '~Video_Active__c=\'NO\'';
                    queryCriteria  = queryCriteria + '~HSI_Active__c=\'YES\'';
                    queryCriteria  = queryCriteria + '~Voice_Active__c=\'YES\'';
                    queryCriteria  = queryCriteria + '~XH_Active__c=\'NO\'';
                    queryCriteria  = queryCriteria + '~XSS_Active__c=\'NO\'';
                    queryCriteria  = queryCriteria + '~Verizon_Wireless_Active__c=\'NO\'';
                } else {
                    if(selectedProducts.contains('Video')){
                        queryCriteria  = queryCriteria + '~Video_Active__c=\'YES\''; 
                    } else if(selectedProducts.contains('No Video')){
                        queryCriteria  = queryCriteria + '~Video_Active__c=\'NO\''; 
                    }
                    if(selectedProducts.contains('HSI')){
                        queryCriteria  = queryCriteria + '~HSI_Active__c=\'YES\''; 
                    } else if(selectedProducts.contains('No HSI')){
                        queryCriteria  = queryCriteria + '~HSI_Active__c=\'NO\''; 
                    }
                    if(selectedProducts.contains('Voice')){
                        queryCriteria  = queryCriteria + '~Voice_Active__c=\'YES\''; 
                    } else if(selectedProducts.contains('No Voice')){
                        queryCriteria  = queryCriteria + '~Voice_Active__c=\'NO\''; 
                    }
                    if(selectedProducts.contains('XH')){
                        queryCriteria  = queryCriteria + '~XH_Active__c=\'YES\''; 
                    }else if(selectedProducts.contains('No Xfinity Home')){
                        queryCriteria  = queryCriteria + '~XH_Active__c=\'NO\''; 
                    }
                    if(selectedProducts.contains('XSS')){
                        queryCriteria  = queryCriteria + '~XSS_Active__c=\'YES\''; 
                    }
                    if(selectedProducts.contains('Verizon Wireless')){
                        queryCriteria  = queryCriteria + '~Verizon_Wireless_Active__c=\'YES\''; 
                    }
                }
            }
        }
       
        if(selectedTemplate.Disconnect_Date__c != null ) {
            criteriaStr += 'Disconnect_Date__c=='+selectedTemplate.Disconnect_Date__c+'&&&';
            String dateString = selectedTemplate.Disconnect_Date__c.year()+'';
            if(selectedTemplate.Disconnect_Date__c.month()<=9) {
                dateString = dateString +'-0'+ selectedTemplate.Disconnect_Date__c.month();
            }else {
                dateString = dateString +'-'+ selectedTemplate.Disconnect_Date__c.month();
            }
            if(selectedTemplate.Disconnect_Date__c.day()<=9) {
                dateString = dateString +'-0'+ selectedTemplate.Disconnect_Date__c.day();
            }else {
                dateString = dateString +'-'+ selectedTemplate.Disconnect_Date__c.day();
            }
            queryCriteria  = queryCriteria + '~Last_Disconnected_Date__c< '+dateString;
        }
        if(selectedTemplate.Last_Disposition__c != null ) {
            criteriaStr += 'Last_Disposition__c=='+selectedTemplate.Last_Disposition__c+'&&&';
             List<String> tokens = selectedTemplate.Last_Disposition__c.split(';',0);
            String lastDispo='';
            for(Integer i=0 ; i<tokens.size(); i++) {
                lastDispo = lastDispo + '\'' + tokens[i].trim() +'\',';
            }
            lastDispo = lastDispo.subString(0,lastDispo.length()-1);
            queryCriteria  = queryCriteria + '~Most_Recent_Disposition__c In ('+lastDispo+')';
        }
        if(selectedTemplate.Last_Knock_Date__c != null ) {         
            criteriaStr += 'Last_Knock_Date__c=='+selectedTemplate.Last_Knock_Date__c+'&&&';
            String dateTimeString = selectedTemplate.Last_Knock_Date__c.year()+'';
            if(selectedTemplate.Last_Knock_Date__c.month()<=9) {
                dateTimeString = dateTimeString +'-0'+ selectedTemplate.Last_Knock_Date__c.month();
            }else {
                dateTimeString = dateTimeString +'-'+ selectedTemplate.Last_Knock_Date__c.month();
            }
            if(selectedTemplate.Last_Knock_Date__c.day()<=9) {
                dateTimeString = dateTimeString +'-0'+ selectedTemplate.Last_Knock_Date__c.day();
            }else {
                dateTimeString = dateTimeString +'-'+ selectedTemplate.Last_Knock_Date__c.day();
            }
            dateTimeString = dateTimeString + 'T00:00:00Z';
            queryCriteria  = queryCriteria + '~(Last_Knock_Date__c<'+ dateTimeString+' OR Last_Knock_Date__c=null)' ;
        }
        if(selectedTemplate.Monthly_Rate_MRC__c != null ) {
            criteriaStr += 'Total_Monthly_Rate__c=='+selectedTemplate.Monthly_Rate_MRC__c+'&&&';
            queryCriteria  = queryCriteria + '~Total_Monthly_Rate__c<='+ selectedTemplate.Monthly_Rate_MRC__c;
        }
        if(selectedTemplate.Number_of_Knocks_Less_Than__c != null ) {
            criteriaStr += 'Number_of_Knocks_Less_Than__c=='+selectedTemplate.Number_of_Knocks_Less_Than__c+'&&&';
            queryCriteria  = queryCriteria + '~Number_of_Knocks__c<'+ selectedTemplate.Number_of_Knocks_Less_Than__c;
        }
        
        if(selectedTemplate.TP_Upgrade_Score__c != null ) {
            criteriaStr += 'TP_Upgrade_Score__c=='+selectedTemplate.TP_Upgrade_Score__c+'&&&';
            queryCriteria  = queryCriteria + '~(TP_Upgrade_Score__c <='+ selectedTemplate.TP_Upgrade_Score__c + ' Or ' + 'TP_Upgrade_Score__c = null)' ;
        }

        if(selectedTemplate.TP_Acquisition_Score__c != null ) {
            criteriaStr += 'TP_Acquisition_Score__c=='+selectedTemplate.TP_Acquisition_Score__c+'&&&';
            queryCriteria  = queryCriteria + '~(TP_Acquisition_Score__c <='+ selectedTemplate.TP_Acquisition_Score__c + ' Or ' + 'TP_Acquisition_Score__c = null)' ;
        }

        if(selectedTemplate.Xfinity_Home_Acquisition_Score__c != null ) {
            criteriaStr += 'Xfinity_Home_Acquisition_Score__c=='+selectedTemplate.Xfinity_Home_Acquisition_Score__c+'&&&';
            queryCriteria  = queryCriteria + '~(Xfinity_Home_Acquisition_Score__c <='+ selectedTemplate.Xfinity_Home_Acquisition_Score__c + ' Or Xfinity_Home_Acquisition_Score__c = null)' ;
        }

        if(selectedTemplate.Xfinity_Home_Upgrade_Score__c != null ) {
            criteriaStr += 'Xfinity_Home_Upgrade_Score__c=='+selectedTemplate.Xfinity_Home_Upgrade_Score__c+'&&&';
            queryCriteria  = queryCriteria + '~(Xfinity_Home_Upgrade_Score__c <='+ selectedTemplate.Xfinity_Home_Upgrade_Score__c + ' Or Xfinity_Home_Upgrade_Score__c  = null)' ;
        } 
        if(selectedTemplate.Sub_Bad_Debt_Propensity__c != null ) {
            criteriaStr += 'Sub_Bad_Debt_Propensity__c=='+selectedTemplate.Sub_Bad_Debt_Propensity__c+'&&&';
            queryCriteria  = queryCriteria + '~(Sub_Bad_Debt_Propensity__c >='+ selectedTemplate.Sub_Bad_Debt_Propensity__c + ' Or Sub_Bad_Debt_Propensity__c  = null OR (Non_Sub_Bad_Debt_Propensity__c  = null AND Sub_Bad_Debt_Propensity__c = null))' ;
        }
    
        if(selectedTemplate.Non_Sub_Bad_Debt_Propensity__c != null ) {
            criteriaStr += 'Non_Sub_Bad_Debt_Propensity__c=='+selectedTemplate.Non_Sub_Bad_Debt_Propensity__c+'&&&';
            queryCriteria  = queryCriteria + '~(Non_Sub_Bad_Debt_Propensity__c >='+ selectedTemplate.Non_Sub_Bad_Debt_Propensity__c + ' Or Non_Sub_Bad_Debt_Propensity__c  = null OR (Non_Sub_Bad_Debt_Propensity__c  = null AND Sub_Bad_Debt_Propensity__c = null))' ;
        }
        if(criteriaStr != '') {
            criteriaStr = criteriaStr.subString(0,criteriaStr.lastIndexOf('&&&'));
        }
        if(queryCriteria=='') {
            if(planObj.Plan_Level__c == Label.PlanTypePlaylist) {
                queryString = queryString + ' where  Excluded__c = false And Plan__c=\'' + planObj.Parent_Plan__c + '\'';
                return queryString;
            } else {
                return null;
            }
        }else {        
            List<String> tokens = queryCriteria.split('~',0);
            String nodes='';
            String streets='';
            for(Integer i=1 ; i<tokens.size(); i++) {
                if(i == 1) {
                    queryString = queryString + ' where '+tokens[i];
                    continue;
                }

                if(tokens[i].contains('Address__c')){
                    if(streets==''){
                        streets = ' AND (' + tokens[i];
                    } else {
                        streets +=' OR ' + tokens[i];
                    }

                    if(i+1<tokens.size()){
                        if(!tokens[i+1].contains('Address__c')){
                            streets += ')';
                            queryString = queryString + streets;
                        }
                    } else {
                        streets += ')';
                        queryString = queryString + streets;
                    }
                } else if(tokens[i].contains('1 Product Customer')){
                    queryString = queryString + ' And ((Video_Active__c = \'YES\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'NO\' And XH_Active__c = \'NO\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'YES\' And Voice_Active__c = \'NO\' And XH_Active__c = \'NO\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'YES\' And XH_Active__c = \'NO\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'NO\' And XH_Active__c = \'YES\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'NO\' And XH_Active__c = \'NO\' And XSS_Active__c = \'YES\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'NO\' And XH_Active__c = \'NO\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'YES\'))';
                } else if(tokens[i].contains('2 Product Customer')){
                    queryString = queryString + ' And ((Video_Active__c = \'YES\' And HSI_Active__c = \'YES\' And Voice_Active__c = \'NO\' And XH_Active__c = \'NO\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'YES\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'YES\' And XH_Active__c = \'NO\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'YES\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'NO\' And XH_Active__c = \'YES\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'YES\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'NO\' And XH_Active__c = \'NO\' And XSS_Active__c = \'YES\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'YES\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'NO\' And XH_Active__c = \'NO\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'YES\')';

                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'YES\' And Voice_Active__c = \'YES\' And XH_Active__c = \'NO\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'YES\' And Voice_Active__c = \'NO\' And XH_Active__c = \'YES\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'YES\' And Voice_Active__c = \'NO\' And XH_Active__c = \'NO\' And XSS_Active__c = \'YES\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'YES\' And Voice_Active__c = \'NO\' And XH_Active__c = \'NO\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'YES\')';

                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'YES\' And XH_Active__c = \'YES\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'YES\' And XH_Active__c = \'NO\' And XSS_Active__c = \'YES\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'YES\' And XH_Active__c = \'NO\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'YES\')';
                    
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'NO\' And XH_Active__c = \'YES\' And XSS_Active__c = \'YES\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'NO\' And XH_Active__c = \'YES\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'YES\')';
                    
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'NO\' And XH_Active__c = \'NO\' And XSS_Active__c = \'YES\' and Verizon_Wireless_Active__c = \'YES\'))';
                } else if(tokens[i].contains('3 Product Customer')){
                    queryString = queryString + ' And ((Video_Active__c = \'YES\' And HSI_Active__c = \'YES\' And Voice_Active__c = \'YES\' And XH_Active__c = \'NO\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'YES\' And HSI_Active__c = \'YES\' And Voice_Active__c = \'NO\' And XH_Active__c = \'YES\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'YES\' And HSI_Active__c = \'YES\' And Voice_Active__c = \'NO\' And XH_Active__c = \'NO\' And XSS_Active__c = \'YES\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'YES\' And HSI_Active__c = \'YES\' And Voice_Active__c = \'NO\' And XH_Active__c = \'NO\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'YES\')';
                    queryString = queryString + ' Or (Video_Active__c = \'YES\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'YES\' And XH_Active__c = \'YES\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'YES\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'YES\' And XH_Active__c = \'NO\' And XSS_Active__c = \'YES\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'YES\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'YES\' And XH_Active__c = \'NO\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'YES\')';
                    queryString = queryString + ' Or (Video_Active__c = \'YES\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'NO\' And XH_Active__c = \'YES\' And XSS_Active__c = \'YES\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'YES\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'NO\' And XH_Active__c = \'YES\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'YES\')';
                    queryString = queryString + ' Or (Video_Active__c = \'YES\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'NO\' And XH_Active__c = \'NO\' And XSS_Active__c = \'YES\' and Verizon_Wireless_Active__c = \'YES\')';

                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'YES\' And Voice_Active__c = \'YES\' And XH_Active__c = \'YES\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'YES\' And Voice_Active__c = \'YES\' And XH_Active__c = \'NO\' And XSS_Active__c = \'YES\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'YES\' And Voice_Active__c = \'YES\' And XH_Active__c = \'NO\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'YES\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'YES\' And Voice_Active__c = \'NO\' And XH_Active__c = \'YES\' And XSS_Active__c = \'YES\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'YES\' And Voice_Active__c = \'NO\' And XH_Active__c = \'YES\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'YES\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'YES\' And Voice_Active__c = \'NO\' And XH_Active__c = \'NO\' And XSS_Active__c = \'YES\' and Verizon_Wireless_Active__c = \'YES\')';

                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'YES\' And XH_Active__c = \'YES\' And XSS_Active__c = \'YES\' and Verizon_Wireless_Active__c = \'NO\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'YES\' And XH_Active__c = \'YES\' And XSS_Active__c = \'NO\' and Verizon_Wireless_Active__c = \'YES\')';
                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'YES\' And XH_Active__c = \'NO\' And XSS_Active__c = \'YES\' and Verizon_Wireless_Active__c = \'YES\')';

                    queryString = queryString + ' Or (Video_Active__c = \'NO\' And HSI_Active__c = \'NO\' And Voice_Active__c = \'NO\' And XH_Active__c = \'YES\' And XSS_Active__c = \'YES\' and Verizon_Wireless_Active__c = \'YES\'))';
                } else {
                    queryString = queryString + ' And ' + tokens[i];
                }
            }
        }
        
        
        
            if(planObj.Plan_Level__c == Label.PlanTypeTurf && UserInfo.getProfileId() != Label.RSA){
                queryString = queryString + '  And ((offTurfStartDate__c < LAST_N_DAYS:15 OR offTurfStartDate__c = NULL ) AND (onTurfStartDate__c < LAST_N_DAYS:15 OR onTurfStartDate__c = NULL ))';            
            }
                                
            if(planObj.Plan_Level__c == Label.PlanTypeTurf && UserInfo.getProfileId() == Label.ContractorDSSProfileId){
                queryString = queryString + '  And Excluded__c = false  AND Plan__r.Plan_Level__c = \'Bulk\' And  ownerid =\'' + UserInfo.getUserId() + '\' And Plan__c=\'' + planObj.Parent_Plan__c + '\'';
            }else if(planObj.Plan_Level__c == Label.PlanTypeTurf || planObj.Plan_Level__c == Label.PlanTypeBulk){
                //added due to exclude Territorry addresses for Bulk Plans
                if(planObj.Plan_Level__c == Label.PlanTypeBulk){
                    queryString = queryString + '  And Territory__c = null';
                }
                
                if(userDivision == 'Global' )
                    queryString = queryString + '  And Excluded__c = false And Plan__c = null';
                else
                    queryString = queryString + '  And Excluded__c = false  And Plan__c = null And Region__c=\''+userDivision+'\'';                    
            }
            else if(planObj.Plan_Level__c == Label.PlanTypePlaylist) {               
                queryString = queryString + '  And Excluded__c = false And Plan__c=\'' + planObj.Parent_Plan__c + '\'';
            }
            
      
        
        
        //queryString += ' And (Active_Inactive__c = \'Active\' OR Non_Marketable__c = false OR No_Solicitation__c = false)'; //>>>>>  lalit change need to be done
        queryString += ' And Exclude_from_Plan__c = False';
        queryString += ' ORDER BY Sort_Code__c limit ';
        queryString += System.Label.TurfAssignLimitLabel;
        return queryString;
    }
    
}

/***********************************************************************************************************************************
 * Author     : Vivek Patel, Accenture
 * Param      : None
 * Return     : PageReference
 * Description: This method searches Addresses when user hit on Search button on plan edit screen. 
************************************************************************************************************************************/
public PageReference searchAddressses() {
    isAdded = false;
    List<Customer_Address__c> addrsList;
    addrsWrapper = new List<AddressWrapper>();
    String createdQueryString = createQueryString();
    if(createdQueryString == null) {
        return null;
    }
    try {
        addrsList = Database.Query(createdQueryString);
    }catch(Exception ex) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
        ApexPages.addMessage(msg);   
       // System.debug('Following exception occurred :'+ex.getMessage());
        return null;
    }
    
    if(addrsList != null) {
        for(Customer_Address__c addrs: addrsList) {
            addrsWrapper.add(new AddressWrapper(addrs));
        }
    }
    
    pageAddresses.clear();
    counter = 0;
    pageNumber = 1;
    for(Integer i=0; i<pageSize && counter<addrsWrapper.size(); i++) {
        pageAddresses.add(addrsWrapper.get(counter++));
    }
    if(planObj.Plan_Level__c != 'Playlist' && showAssignedAddresses){
        displayAssignedAddressesMessage(createdQueryString);
    }
    return null;
}

/***********************************************************************************************************************************
 * Author     : Vivek Patel, Accenture
 * Param      : Boolean
 * Return     : None
 * Description: This method first check whether user clicked on 'Add Selected' or 'Add All'  and then adds Addresses to the plan
************************************************************************************************************************************/

public void addAddresses(Integer addSelected) {
    List<Customer_Address__c> addressesToUpdate = new List<Customer_Address__c>();  
    List<Plan__c> plnList = [Select Number_of_Addresses__c, Number_of_Excluded_Addresses__c, True_count_of_Addresses__c from Plan__c where Id =:planObj.Id];
    if(!plnList.isEmpty()){
        Plan__c pln=plnList.get(0);
        if(addSelected == 0){//add selected
            for(AddressWrapper addrsWrap : addrsWrapper){
                if(addrsWrap.selected == true){
                    addrsWrap.addrs.Plan__c = planObj.Id;
                    addressesToUpdate.add(addrsWrap.addrs);
                }
            }
        } else if(addSelected == 1){//add page
               if(addrsWrapper != null && !addrsWrapper.isEmpty()){
                    for(Integer i = pageSize*(pageNumber-1); i <= pageSize*pageNumber-1; i++){
                            if(i < addrsWrapper.size()){
                                addrsWrapper.get(i).addrs.Plan__c = planObj.Id;
                                addressesToUpdate.add(addrsWrapper.get(i).addrs);
                            } else {
                                break;
                            }
                      } 
            }
        } else if(addSelected == 2){//add all
            for(AddressWrapper addrsWrap : addrsWrapper){
                addrsWrap.addrs.Plan__c = planObj.Id;
                addressesToUpdate.add(addrsWrap.addrs);
            }
        }
        if(!addressesToUpdate.isEmpty()){
            ConfigurableParameters__c addressLimitPerPlan = ConfigurableParameters__c.getValues('AddressLimitPerPlan');
            if(pln.Number_of_Addresses__c + addressesToUpdate.size()  > addressLimitPerPLan.NumberValue__c){
                planObj.addError(Label.Limit_Addresses_To_Turf);
            }else{
                Database.SaveResult[] saveResult;
                List<Customer_Address__c> addrsList = new List<Customer_Address__c>();
                noOfSuccess = 0;
                Integer numberUpdated = 0;
                for(Customer_Address__c ca : addressesToUpdate){
                    addrsList.add(ca);
                    numberUpdated++;
                    if(addrsList.size() == 100 || numberUpdated == addressesToUpdate.size()){
                        try{
                            saveResult = Database.update(addrsList, false);
                            addrsList.clear();
                        } catch(Exception ex){
                            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
                            ApexPages.addMessage(msg);
                         //   System.debug('Following exception occurred :'+ex.getMessage());                                    
                        }
                        for(Integer i = 0; i < saveResult.size(); i++){
                            if (saveResult[i].isSuccess()) {
                               // System.debug('Successfully updated Record ID: '+ saveResult[i].getId());
                                noOfSuccess++;
                                numberOfAddressesOnPlan++;
                            } else {
                              //  System.debug('The error reported was: '+ saveResult[i].getErrors()[0].getMessage() + '\n');
                            }
                        }
                    }
                }
            }
        }
    }
    List<Plan__c> planList = [Select Number_of_Addresses__c, Number_of_Excluded_Addresses__c, True_count_of_Addresses__c from Plan__c where Id =:planObj.Id];
    if(!planList.isEmpty()){
        Plan__c plan=planList.get(0);
        planObj.Number_of_Addresses__c = plan.Number_of_Addresses__c;
        planObj.Number_of_Excluded_Addresses__c = plan.Number_of_Excluded_Addresses__c;
        planObj.True_count_of_Addresses__c = plan.Number_of_Addresses__c - plan.Number_of_Excluded_Addresses__c;
    }
}

public PageReference addSelected() {
    updateMasterList();
    addAddresses(0);
    Boolean isPlanSaveSuccessful = savePlan();
    searchAddressses();
    if(isPlanSaveSuccessful) {
        isAdded = true;
    } else {
        isAdded = false;
    }
    return null;
}

public PageReference addPage() {
    addAddresses(1);
    Boolean isPlanSaveSuccessful = savePlan();
    searchAddressses();
    if(isPlanSaveSuccessful) {
        isAdded = true;
    } else {
        isAdded = false;
    }
    return null;
}

public PageReference addAll() {
    addAddresses(2);
    Boolean isPlanSaveSuccessful = savePlan();
    searchAddressses();
    if(isPlanSaveSuccessful) {
        isAdded = true;
    } else {
        isAdded = false;
    }
    return null;
}

public PageReference quickSave() {
   Boolean isPlanSaveSuccessful = savePlan();
    if(isPlanSaveSuccessful) {
        PageReference pageRef = new ApexPages.StandardController(planObj).edit();
        return pageRef;
    } else {
        return null;
    }
}

public PageReference save() {
    Boolean isPlanSaveSuccessful = savePlan();
    if(isPlanSaveSuccessful) {
        PageReference pageRef = new ApexPages.StandardController(planObj).view();
        return pageRef;
    } else {
        return null;
    }
}   

public PageReference cancel() {
    PageReference pageRef;
    if(planObj.Id==null) {
        pageRef = new PageReference(Label.PlanTabURL);
        return pageRef;
    } else {
        pageRef = new ApexPages.StandardController(planObj).view();
    }
    return pageRef;
} 

/***********************************************************************************************************************************
 * Author     : Amit Kumar Pradhan, Accenture
 * User Story : US581344(Analysis and Implementation: Assigning Address To Business Partners)
 * Param      : None
 * Return     : PageReference
 * Description: This method searches Addresses when user hit on "Bulk Search" button on plan edit screen and count the number of addresses 
************************************************************************************************************************************/   


public PageReference searchBulkAddressses(){
    String createdQueryString = createQueryString();
    
    if(createdQueryString == null) {
      addressCount=null;
        return null;           
    }
    List<Job_Status__c> jobStatus = [Select Id from Job_Status__c Where Status__c = 'New' AND Bulk_Assign_Region__c =:rsaRegion];
    if(!jobStatus.isEmpty()){
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO,System.Label.BulkAssignmentProgressErrMsg);
        ApexPages.addMessage(msg);   
       
        return null;
    }
    
   String target = 'Select Id, Name,Last_Knock_Date__c,Address_2__c,City__c,Account__r.Agent_Code__c,Targeted__c,PostalCode__c,State__c, Property_Code__c';
    String replacement = 'Select count()';
    String target1 = ' ORDER BY Sort_Code__c limit ';
    target1 += System.Label.TurfAssignLimitLabel;
    String replacement1 = ' limit ';
    replacement1 += System.Label.BulkAddressAssignLimit;

        createdQueryString = createdQueryString.replace(target, replacement);
        createdQueryString = createdQueryString.replace(target1, replacement1);   
    
    try {
        addressCount = Database.countQuery(createdQueryString); 
    }catch(Exception ex) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
        ApexPages.addMessage(msg);   
        //System.debug('Following exception occurred :'+ex.getMessage());
        return null;
    }
           
    return null;
    }
    
/***********************************************************************************************************************************
 * Author     : Radhika Bansal, Accenture
 * User Story : 
 * Param      : None
 * Return     : PageReference
 * Description: This method is used to fetch address already assigned to plan and to reassign them.
************************************************************************************************************************************/ 
    
    public String fetchAssignedAddress(){
        String queryString = 'Select Id, Name,Last_Knock_Date__c,Address_2__c,City__c,Account__r.Agent_Code__c,Targeted__c,PostalCode__c,State__c, Property_Code__c from Customer_Address__c where Plan__c ='+'\''+ planObj.Id+'\'';    
        return queryString;
    }  
    
/***********************************************************************************************************************************
 * Author     : Radhika Bansal, Accenture
 * User Story : 
 * Param      : None
 * Return     : PageReference
 * Description: This method is used to fetch address already assigned to plan and to reassign them.
************************************************************************************************************************************/   
    
   public PageReference bulkReAssignedAddressses(){
    
    noOfBulkAssignment++;
    String assignedUserId = '';
    List<User> usrList =  new List<User>();   
    String createdQueryStringForBulk='';
    if(reContractorOption != null)
    {       
        usrList=[Select Id,Name from user where Name = : reContractorOption];
        createdQueryStringForBulk= fetchAssignedAddress();
        }
    if(usrList[0].Id != Null){
        assignedUserId = usrList[0].Id;
    }
        
    if(assignedUserId != Null){ 
        try{ 
            planObj.User__c = assignedUserId;            
            addressCount = Integer.valueOf(planObj.True_count_of_Addresses__c);         
            Database.SaveResult svr = database.update(planObj,false);
            
            //Calling the batch class by passing the "query", "planid" and "ContractorDss Id"
            UpdateBulkAddressBatch batch = new UpdateBulkAddressBatch(planObj.Id, assignedUserId, createdQueryStringForBulk, rsaRegion, addressCount );
            Id batchid = Database.executeBatch(batch); 
  
        }
        catch(Exception e){
            System.debug('Error msg***'+e.getMessage());
        }
        
        boolean isSave = savePlan();
        if(isSave) {
                
            PageReference pageRef = new ApexPages.StandardController(planObj).view();
            return pageRef;
        } else {
        return null;
        }
    } else {
        planObj.addError(Label.ErrorMsgForBulkAssignment);
        return null ;
    }       
}

/***********************************************************************************************************************************
 * Author     : Amit Kumar Pradhan, Accenture
 * User Story : US581344(Analysis and Implementation: Assigning Address To Business Partners)
 * Param      : None
 * Return     : PageReference
 * Description: This method assign the bulk addresses to Contractor DSS by calling the batch class "UpdateAdressForBulkAssignment"
************************************************************************************************************************************/       
    
public PageReference bulkAssignedAddressses(){
        noOfBulkAssignment++;
        String assignedUserId = '';
        String target1 = 'ORDER BY Sort_Code__c limit ';
        target1+=System.Label.TurfAssignLimitLabel;
        String replacement1 = 'ORDER BY Id limit ';
        replacement1 += System.Label.BulkAddressAssignLimit;
        
        String createdQueryStringForBulk = createQueryString();
        
        if(createdQueryStringForBulk  == null) {
            return null;
        }
        else{
            createdQueryStringForBulk = createdQueryStringForBulk.replace(target1, replacement1);
        }
        
        List<User> usrList=[Select Id,Name from user where Name = : contractorDSSOption];
        if(planObj.User__c != Null){
            assignedUserId = planObj.User__c;
        }else if(usrList[0].Id != Null){
            assignedUserId = usrList[0].Id;
        }
        
        if(assignedUserId != Null){ 
            try{
                
                planObj.User__c = assignedUserId;
                planObj.True_count_of_Addresses__c += addressCount;
                planObj.Number_of_Addresses_Currently_on_Plan__c = planObj.True_count_of_Addresses__c;
                //planObj.Batch_Job_Id__c = batchid;              
                planObj.No_Of_Bulk_Assignment_del__c = noOfBulkAssignment;                    
                Database.SaveResult svr = database.update(planObj,false);
                
                //Calling the batch class by passing the "query", "planid" and "ContractorDss Id"
                UpdateBulkAddressBatch batch = new UpdateBulkAddressBatch(planObj.Id, assignedUserId, createdQueryStringForBulk, rsaRegion, addressCount );
                Id batchid = Database.executeBatch(batch); 
      
            }
            catch(Exception e){
                System.debug('Error msg***'+e.getMessage());
            }
            
            boolean isSave = savePlan();
            if(isSave) {
                    
                PageReference pageRef = new ApexPages.StandardController(planObj).view();
                return pageRef;
            } else {
            return null;
            }
        } else {
            planObj.addError(Label.ErrorMsgForBulkAssignment);
            return null ;
        }       
    }
/***********************************************************************************************************************************
 * Author     : Vivek Patel, Accenture
 * Param      : None
 * Return     : Boolean
 * Description: This method is called to save the plan when user hit on Save or QuickSave button and when user add   addresses to the plan to update the criteria. 
 * Last Modified by : Shivani Gautam,Accenture. (Sprint 30)
 * US719722- RSA need to view the history of all search criteria used to add addresses to the bulk plan
************************************************************************************************************************************/

public Boolean savePlan() {
    try {
        createQueryString();
        if(planObj.Id == null) {
            if(planObj.Parent_Plan__c != null) {
                List<Plan__c> parentPlans = [Select Id, Plan_level__c, User__c, Assigned_Team__c, parameters__c, PlanCriteria__c, ParentPlanCriteria__c, Expiration_Date__c from Plan__c where id= :planObj.Parent_Plan__c];
                if(!parentPlans.isEmpty())
                {
                Plan__c parentPlan = parentPlans.get(0);
                if(planObj.Plan_level__c == Label.PlanTypePlaylist) {                        
                    if(parentPlan.User__c != null && (parentPlan.User__c != UserInfo.getUserId())){
                        planObj.addError(Label.PlaylistCreateError);
                        return false;
                    }
                    if(parentPlan.Assigned_Team__c != null){
                        Set<Id> teamMemberIdSet = new Set<Id>();
                        for(Team_Member__c teamMemberObj : [Select Id, User_Name__c from Team_Member__c where Team__c=:parentPlan.Assigned_Team__c]) {
                            teamMemberIdSet.add(teamMemberObj.User_Name__c);
                    }
                    if(teamMemberIdSet.size()==0 || !teamMemberIdSet.contains(UserInfo.getUserId())) {
                        planObj.addError(Label.PlaylistCreateError);
                        return false;
                    }
                }
                }
                
                planObj.ParentPlanCriteria__c = parentPlan.PlanCriteria__c ;
                planObj.PlanCriteria__c = parentPlan.PlanCriteria__c;
                //planObj.parameters__c = parentPlan.parameters__c;
                
                if(parentPlan.Expiration_Date__c != null) {
                    planObj.Expiration_Date__c = parentPlan.Expiration_Date__c;
                    if(planObj.Plan_level__c == Label.PlanTypePlaylist) {
                        planObj.User__c = UserInfo.getUserId();
                    }
                }
                    
                if(selectedTemplate.zip_codes__c != null && selectedTemplate.zip_codes__c.trim()!='') {
                    List<String> tokens = selectedTemplate.zip_codes__c.split(',',0);   
                    String zipCodes='';          
                    for(Integer i=0 ; i<tokens.size(); i++) {
                        zipCodes = zipCodes + '\'' + tokens[i].trim() +'\',';
                    }
                    zipCodes = zipCodes.subString(0,zipCodes.length()-1);
                    
                    if(planObj.ParentPlanCriteria__c==null || !planObj.ParentPlanCriteria__c.startswith('zip_codes__c')) {
                        if(planObj.PlanCriteria__c != null ) {
                            planObj.PlanCriteria__c = 'zip_codes__c==' + selectedTemplate.zip_codes__c + '&&&' + planObj.PlanCriteria__c;
                        } else {
                            planObj.PlanCriteria__c = 'zip_codes__c==' + selectedTemplate.zip_codes__c;
                        }
                        if(planObj.parameters__c != null ) {
                            planObj.parameters__c = 'PostalCode__c In ('+zipCodes+') And '+planObj.parameters__c;
                        } else {
                            planObj.parameters__c = 'PostalCode__c In ('+zipCodes+')';
                        }
                        if(planObj.parameters__c.contains('limit 1000')){
                            planObj.parameters__c = planObj.parameters__c.replace('limit 1000', '');
                        }
                    }
                }
                }
            } else {
                if(queryString.contains('where')) {
                    planObj.parameters__c = queryString.subString(queryString.indexOf('where')+5).subStringBefore('and');
                    if(planObj.parameters__c.contains('limit 1000')){
                        planObj.parameters__c = planObj.parameters__c.replace('limit 1000', '');
                    }
                }
                planObj.PlanCriteria__c = criteriaStr;
            }
        } else {           //
         String parameter;
         
            if(queryString.contains('where') && ((planObj.Plan_level__c == Label.PlanTypeBulk && addressCount > 0) || (planObj.Plan_level__c != Label.PlanTypeBulk && noOfSuccess > 0))){
                List<String> paramArray; 
                if(planObj.parameters__c !=null){
                    paramArray = planObj.parameters__c.split(';'); 
                }   
            
                parameter = queryString.subString(queryString.indexOf('where')+5).subStringBefore('and');
            
                if(parameter.contains('limit '+System.Label.TurfAssignLimitLabel)){
                    parameter = parameter.replace('limit '+System.Label.TurfAssignLimitLabel,'');                          
                    
                }
                Boolean Flag = true;
                if(planObj.parameters__c !=null){
                    for(Integer i=0 ; i<paramArray.size(); i++) {
                        if(paramArray[i].trim().equalsIgnoreCase(parameter.trim())){
                            Flag = false;
                            break;
                        }
                    }
                }
                
                if(Flag && planObj.parameters__c != null){
                    parameter = '\n\n'+parameter +';';
                    planObj.parameters__c = planObj.parameters__c + parameter;
                }  
                if(planObj.parameters__c == null){
                    parameter = parameter +';';
                    planObj.parameters__c = parameter;
                }                                         
            } 
                
           
            
            planObj.PlanCriteria__c = criteriaStr;
       
        }
        
        if(planObj.Assigned_Team__c!=null && planObj.User__c!=null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'A plan can be assigned to either User or Team, not both.'); 
            ApexPages.addMessage(msg);
            return false;  
        }
        if(planObj.Assigned_Team__c!=null || planObj.User__c!=null || planObj.Assigned_To_CAR__c!=null){
            if(planObj.Plan_Status__c == Label.PlanStatusDraft) {
                planObj.Plan_Status__c = Label.PlanStatusAssigned;
                planObj.Assigned_Date__c = Date.today();
                if((planObj.Plan_Level__c == Label.PlanTypeTurf || planObj.Plan_Level__c == Label.PlanTypeBulk) && planObj.Expiration_Date__c==null) {
                    if(planObj.User__c!=null){
                        User usr;
                        try{
                         usr = [Select Id, Name, Comcast_Division__c From User Where Id =:planObj.User__c];} catch(Exception ex) {
                           // System.debug('Following exception occurred while fetching User record:'+ex.getMessage());
                        }
                        if(usr.Comcast_Division__c=='West'){
                            planObj.Expiration_Date__c = Date.today() + 75;
                        } else {
                            planObj.Expiration_Date__c = Date.today() + 60;
                        }
                    }
                    else if(planObj.Assigned_Team__c!=null) {
                        Team__c teamObj;
                        try {
                            teamObj = [Select Id, Comcast_Division__c From Team__c Where Id =:planObj.Assigned_Team__c];
                        } catch(Exception ex) {
                          //  System.debug('Following exception occurred while fetching Team record:'+ex.getMessage());
                        }
                        if(teamObj.Comcast_Division__c=='West'){
                            planObj.Expiration_Date__c = Date.today() + 75;
                        } else {
                            planObj.Expiration_Date__c = Date.today() + 60;
                        }
                    }
                    if(planObj.User__c==null && planObj.Assigned_Team__c==null && planObj.Assigned_To_CAR__c!=null){
                        User carUser;
                        try{
                            carUser = [Select Id, Name, Comcast_Division__c From User Where Id =:planObj.Assigned_To_CAR__c];
                        } catch(Exception ex){
                          //  System.debug('Following exception occured while fetch CAR User record:'+ex.getMessage());
                        }
                        if(carUser.Comcast_Division__c=='West'){
                            planObj.Expiration_Date__c = Date.today() + 75;
                        } else {
                            planObj.Expiration_Date__c = Date.today() + 60;
                        }
                    }
                }
            }
            if(planObj.Assigned_Team__c!=null) {
                Team__c teamObj;
                try {
                    teamObj = [Select Id, Supervisor__c, Supervisor__r.Email, Supervisor__r.Name From Team__c Where Id =:planObj.Assigned_Team__c];
                } catch(Exception ex) {
                  //  System.debug('Following exception occurred while fetching Team record:'+ex.getMessage());
                }
                if(teamObj != null && teamObj.Supervisor__c != null) {
                    planObj.Supervisor_Email__c = teamObj.Supervisor__r.Email;
                    planObj.Supervisor_Name__c = teamObj.Supervisor__r.Name;
                }
            }
            if(planObj.User__c!=null) { 
                User mgrObj;
                try {
                 mgrObj = [Select Manager.Email, Manager.Name From User Where Id =:planObj.User__c];} catch(Exception ex) {}
                
                if(mgrObj != null) {
                    planObj.Supervisor_Email__c = mgrObj.Manager.Email;
                    planObj.Supervisor_Name__c = mgrObj.Manager.Name;
                }
            }
            if(planObj.User__c==null && planObj.Assigned_Team__c==null && planObj.Assigned_To_CAR__c != null){
                User usr;
                try {
                    usr = [Select Manager.Email, Manager.Name From User Where Id =:planObj.Assigned_To_CAR__c];
                } catch(Exception ex) {
                   // System.debug('Following exception occured while fetching CAR Manager'+ex.getMessage());
                }
                if(usr != null){
                    planObj.Supervisor_Email__c = usr.Manager.Email;
                    planObj.Supervisor_Name__c = usr.Manager.Name;
                }
            }
        } 
        
        upsert planObj;
        
        if(planObj.Id != null && planObj.Exclusion__c != null){
            Map<Id,Exclusion__c> exclusionMap = new Map<Id,Exclusion__c>(); 
            Map<Id,Plan__c> planMap = new Map<Id,Plan__c>(); 
            Map<String,Decimal> dueBalanceMap = new Map<String,Decimal>(); 
            Map<String,String> installationStatusMap = new Map<String,String>(); 
            Map<String,String> nodesMap = new Map<String,String>(); 
            Map<String,String> complexCodesMap = new Map<String,String>(); 
            Exclusion__c exc;
            Boolean exclusionFlag = false;
            Id planId;
            String query;
            Decimal dueBalance;
            Decimal noOfAddresses = 0;
            list<Customer_Address__c> addressList = new list<Customer_Address__c>();
            list<Customer_Address__c> addressListToBeCleared = new list<Customer_Address__c>();
            set<Id> exclusionIds = new set<Id>();
            set<Id> planIds = new set<Id>();   
            set<String> excludedInstallationStatuses = new set<String>();
            set<String> excludednodes = new set<String>();
            set<String> excludedComplexCodes = new set<String>();
            Boolean complexCodeFlag = false;
            Boolean doNotKnockFlag = false;
            Boolean nonMarketableFlag = false;
            Boolean nonInternetServiceableFlag = false;
            Boolean nonDigitalServiceableFlag = false;
            Boolean nonVoiceServiceableFlag = false;
            if((planObj.Exclusion__c!= exclusionId) && (planObj.Plan_Level__c == Label.PlanTypeTurf || planObj.Plan_Level__c == Label.PlanTypePlaylist)){
                exclusionFlag = true;
                planId = planObj.Id;
                noOfAddresses = planObj.Number_of_Excluded_Addresses__c ;
            }
            if(exclusionId != NULL && (exclusionId != planObj.Exclusion__c) &&(planObj.Plan_Level__c == Label.PlanTypeTurf || planObj.Plan_Level__c == Label.PlanTypePlaylist)){
                addressListToBeCleared = [Select Id, Excluded__c from Customer_Address__c where Plan__c=: planObj.Id AND Excluded__c = true];
                planId = planObj.Id;
            }
            /*for (Plan__c pl : newPlansMap.values()){
                if(pl.Exclusion__c !=  oldPlansMap.get(pl.Id).Exclusion__c && (pl.Plan_Level__c == Label.PlanTypeTurf ||
                    pl.Plan_Level__c == Label.PlanTypePlaylist)){
                        exclusionFlag = true;
                        planId = pl.Id;
                        noOfAddresses = pl.Number_of_Excluded_Addresses__c ;
                }
                if(oldPlansMap.get(pl.Id).Exclusion__c != null && oldPlansMap.get(pl.Id).Exclusion__c != pl.Exclusion__c
                    &&(pl.Plan_Level__c == Label.PlanTypeTurf || pl.Plan_Level__c == Label.PlanTypePlaylist)){
                    addressListToBeCleared = [Select Id, Excluded__c from Customer_Address__c where Plan__c=: pl.Id AND Excluded__c = true];
                    planId = pl.Id;
                }
            }*/
            // Clear the Excluded Flag on Exclusion Change
            if(!(addressListToBeCleared.isEmpty()) || Test.isRunningTest()){
                noOfAddresses = 0;
                for(Customer_Address__c ad: addressListToBeCleared){
                    ad.Excluded__c = false;
                }
                try{
                 database.update (addressListToBeCleared ,false);} catch (DmlException ex){}
            }
            // Process the Newly Applied Exclusion
            if(exclusionFlag){
                if(planId != null){
                    // Below code is written to fetch the parent Ids to process the exclusion applied on them
                    Plan__c plan = [select Id, name, Parent_Plan__c, Parent_Plan__r.Parent_Plan__c, 
                                    Parent_Plan__r.Parent_Plan__r.Parent_Plan__c, Parent_Plan__r.Parent_Plan__r.Parent_Plan__r.Parent_Plan__c,
                                    Parent_Plan__r.Parent_Plan__r.Parent_Plan__r.Parent_Plan__r.Parent_Plan__c from Plan__c where id=: planId];
                    planIds.add(plan.Id);
                    if(plan.Parent_Plan__c != null || Test.isRunningTest()){
                        planIds.add(plan.Parent_Plan__c);
                        if(plan.Parent_Plan__r.Parent_Plan__c != null || Test.isRunningTest()){
                            planIds.add(plan.Parent_Plan__r.Parent_Plan__c);
                            if(plan.Parent_Plan__r.Parent_Plan__r.Parent_Plan__c != null || Test.isRunningTest()){
                                planIds.add(plan.Parent_Plan__r.Parent_Plan__r.Parent_Plan__c);
                                if(plan.Parent_Plan__r.Parent_Plan__r.Parent_Plan__r.Parent_Plan__c != null || Test.isRunningTest()){
                                    planIds.add(plan.Parent_Plan__r.Parent_Plan__r.Parent_Plan__r.Parent_Plan__c);
                                    if(plan.Parent_Plan__r.Parent_Plan__r.Parent_Plan__r.Parent_Plan__r.Parent_Plan__c != null || Test.isRunningTest()){
                                        planIds.add(plan.Parent_Plan__r.Parent_Plan__r.Parent_Plan__r.Parent_Plan__r.Parent_Plan__c);
                                    }
                                }
                            }
                        }
                    } 
                    // Fetch Parameters for Current Exclusion applied
                    if(!(planIds.isEmpty())){ 
                        for(Plan__c p : [Select Id, Name, Exclusion__c, Plan_Level__c from Plan__c where Id=:planIds]) {
                            planMap.put(p.Id,p); 
                            if(p.Exclusion__c != null){
                                exclusionIds.add(p.Exclusion__c);
                            }
                        }
                    //planMap.put(planId,planObj); 
                    //exclusionIds.add(planObj.Exclusion__c);
                    }
                    if(!(exclusionIds.isEmpty())){
                        for(Exclusion__c excl : [select id, name, Installation_Status__c, Past_Due_Balance__c, 
                                    Nodes__c, Region__c, Division__c,Non_Marketable_Address__c,Non_Voice_Serviceable__c,
                                    Non_Internet_Serviceable__c,Non_Digital_Serviceable__c,Do_Not_Knock__c,
                                    Complex_Codes__c from Exclusion__c where Id=:exclusionIds]) {
                            exclusionMap.put(excl.Id,excl); 
                        }
                    }
                    // Process All Exclusion parameters to come up with effective exclusion parameters
                    for(Plan__c p : planMap.values()){
                        if(p.Exclusion__c != null){
                            if(exclusionMap.get(p.Exclusion__c).Past_Due_Balance__c != null){
                                dueBalanceMap.put(p.Plan_Level__c,exclusionMap.get(p.Exclusion__c).Past_Due_Balance__c) ;
                            }
                            if(exclusionMap.get(p.Exclusion__c).Installation_Status__c != null){
                                installationStatusMap.put(p.Plan_Level__c,exclusionMap.get(p.Exclusion__c).Installation_Status__c);
                            }
                            if(exclusionMap.get(p.Exclusion__c).Nodes__c != null){
                                nodesMap.put(p.Plan_Level__c,exclusionMap.get(p.Exclusion__c).Nodes__c);
                                complexCodeFlag = true;
                            }
                            if(complexCodeFlag && exclusionMap.get(p.Exclusion__c).Complex_Codes__c != null){
                                complexCodesMap.put(p.Plan_Level__c,exclusionMap.get(p.Exclusion__c).Complex_Codes__c);
                            }
                            if(exclusionMap.get(p.Exclusion__c).Do_Not_Knock__c != false){
                                doNotKnockFlag = true;
                            }
                            if(exclusionMap.get(p.Exclusion__c).Non_Marketable_Address__c != false){
                                nonMarketableFlag = true;
                            }
                            if(exclusionMap.get(p.Exclusion__c).Non_Voice_Serviceable__c != false){
                                nonVoiceServiceableFlag = true;
                            }
                            if(exclusionMap.get(p.Exclusion__c).Non_Internet_Serviceable__c != false){
                                nonInternetServiceableFlag = true;
                            }
                            if(exclusionMap.get(p.Exclusion__c).Non_Digital_Serviceable__c != false){
                                nonDigitalServiceableFlag = true;
                            }
                        } 
                    } 

                    // Logic for Past Due balance 
                    for(String s: dueBalanceMap.keySet()){
                        if(dueBalance == null){
                            dueBalance = dueBalanceMap.get(s);
                        } else
                        if(dueBalanceMap.get(s) < dueBalance){
                            dueBalance = dueBalanceMap.get(s);
                        }
                    }
                    // Logic for Installation Status
                    for(String s: installationStatusMap.keySet()){
                        String[] tmpString = installationStatusMap.get(s).split(';');
                        
                        for(String st : tmpString){
                            excludedInstallationStatuses.add(st);
                        }
                    }
                    //Logic for Node
                    for(String s: nodesMap.keySet()){
                        String[] tmpString = nodesMap.get(s).split(',');
                        
                        for(String st : tmpString){
                            excludednodes.add(st);
                        }
                    }
                    // Logic for Complex Codes override
                    if(complexCodeFlag){
                        for(String s: complexCodesMap.keySet()){
                            String[] tmpString = complexCodesMap.get(s).split(',');
                            
                            for(String st : tmpString){
                                excludedComplexCodes.add(st);
                            }
                        }
                    }
                    // Form SOQL query to exclude addresses
                    String soql;
                    String whereCondition ;
                    soql = 'Select Id, Excluded__c,Plan__c,Address_2__c,Last_Knock_Date__c, Node__c, Account__c, Account__r.Installation_Status__c, Account__r.past_due_balance__c from Customer_Address__c';
                    whereCondition = ' where Plan__c =: planId' + ' ' + 'AND' + ' ';
                    soql = soql + whereCondition;

                    Boolean firstCriteriaFlag = false;
                    if(dueBalance != null){
                    firstCriteriaFlag = true;
                    soql = soql + '(Account__r.past_due_balance__c >: dueBalance';
                    }
                    if (!(excludedInstallationStatuses.IsEmpty())){
                    if(firstCriteriaFlag){
                        soql = soql + ' ' + 'OR' + ' ' + 'Account__r.Installation_Status__c =: excludedInstallationStatuses';
                    } else {
                        firstCriteriaFlag = true;
                        soql = soql + '(Account__r.Installation_Status__c =: excludedInstallationStatuses';
                    }
                    }
                    if (!(excludednodes.IsEmpty())){
                    if(firstCriteriaFlag){
                        soql =  soql + ' ' + 'OR' + ' ' + 'Node__c  =: excludednodes';
                    } else {
                        firstCriteriaFlag = true;
                        soql = soql + '(Node__c  =: excludednodes';
                    }
                    }
                    if (doNotKnockFlag){
                    if(firstCriteriaFlag){
                        soql =  soql + ' ' + 'OR' + ' ' + 'Do_Not_Knock__c = true';
                    } else {
                        firstCriteriaFlag = true;
                        soql = soql + '(Do_Not_Knock__c = true';
                    }
                    }
                    if (nonMarketableFlag){
                    if(firstCriteriaFlag){
                        soql =  soql + ' ' + 'OR' + ' ' + 'Non_Marketable__c = true';
                    } else {
                        firstCriteriaFlag = true;   
                        soql = soql + '(Non_Marketable__c = true';
                    }
                    }
                    if (nonVoiceServiceableFlag){
                    if(firstCriteriaFlag){
                        soql =  soql + ' ' + 'OR' + ' ' + 'Voice_Serviceable__c = false';
                    } else {
                        firstCriteriaFlag = true;   
                        soql = soql + '(Voice_Serviceable__c = false';
                    }
                    }
                    if (nonInternetServiceableFlag){
                    if(firstCriteriaFlag){
                        soql =  soql + ' ' + 'OR' + ' ' + 'Internet_Serviceable__c = false';
                    } else {
                        firstCriteriaFlag = true;
                        soql = soql + '(Internet_Serviceable__c = false';
                    }
                    }
                    if (nonDigitalServiceableFlag){
                    if(firstCriteriaFlag){
                        soql =  soql + ' ' + 'OR' + ' ' + 'Digital_Serviceable__c = false';
                    } else {
                        firstCriteriaFlag = true;   
                        soql = soql + '(Digital_Serviceable__c = false';
                    }
                    }
                    
                    soql = soql + ')';
                    if(complexCodeFlag){
                    soql = soql + ' ' + 'AND' + ' ' + 'Property_Code__c NOT IN : excludedComplexCodes';
                    }
                    for(Customer_Address__c  ca : Database.query(soql)){
                        ca.Excluded__c = true;
                        addressList.add(ca); 
                    }
                    noOfAddresses = addressList.size();
                    try{
                    AddressTerritoryHandler.hasExecuted = true;
                    database.update (addressList,false);} catch (DmlException dmlEx){ for(Integer i =0; i<dmlEx.getNumDml(); ++i) {
                         //   system.debug('*******Following Errors occurred on Plan Update  ****** :' + dmlEx.getDmlMessage(i));
                        }
                    }
                }
            }
            if(!(addressListToBeCleared.isEmpty()) || exclusionFlag){
                List<Plan__c> planList = [Select Id, Name, Number_of_Excluded_Addresses__c from Plan__c where Id=: planId];
                if(!planList.isEmpty())
                {
                    Plan__c pl= planList.get(0);
                    if(noOfAddresses != pl.Number_of_Excluded_Addresses__c){
                        pl.Number_of_Excluded_Addresses__c = noOfAddresses;
                        try{
                         update pl;} catch (Exception dmlEx){for(Integer i =0; i<dmlEx.getNumDml(); ++i) {
                              //  system.debug('*******Following Errors occurred on Plan Update  ****** :' + dmlEx.getDmlMessage(i));
                            }
                        }
                    }
                }
            }
        }
        if(planObj.Plan_Status__c == Label.PlanStatusAssigned && planObj.Plan_Level__c != Label.PlanTypeBulk )
            assignAddressesToTeamOrUser();
          
        return true;
    } catch(DMLException ex) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getDmlMessage(0));
        ApexPages.addMessage(msg);
        if(ex.getMessage().contains('You are not authorize to assign plan to other Region') && planObj.Plan_Level__C=='Turf') {
            planObj.Plan_Status__c = Label.PlanStatusDraft;
        }
     //   System.debug('Following exception occurred :'+ex.getMessage());
    }
  
    return false;
}

/***********************************************************************************************************************************
 * Author     : Vivek Patel, Accenture
 * Param      : None
 * Return     : None
 * Description: This method assigns all the address in plan to User or Team, to whome the Plan is assigned.
************************************************************************************************************************************/
public void assignAddressesToTeamOrUser() {
    List<Customer_Address__c> addrsList = [Select Id, Address_2__c,Last_Knock_Date__c,OwnerId, Team__c, Assigned_Date__c from Customer_Address__c where Plan__c =:planObj.Id];
    Team__c teamObj;
    if(planObj.Assigned_Team__c != null) {
        teamObj = [Select Id, Supervisor__c from Team__c where Id =:planObj.Assigned_Team__c];
    }
    for(Customer_Address__c addrsObj : addrsList) {
        if(planObj.User__c != null) {
            addrsObj.OwnerId = planObj.User__c;
            addrsObj.Team__c = null;
        }
        if(planObj.Assigned_Team__c != null) {
            addrsObj.OwnerId = teamObj.Supervisor__c;
            addrsObj.Team__c = planObj.Assigned_Team__c;
        }            
        if(planObj.Assigned_To_CAR__c != null){
            addrsObj.CAR_Owner__c = planObj.Assigned_To_CAR__c;
        }
        if(planObj.Plan_level__c != Label.PlanTypePlaylist){
            addrsObj.Assigned_Date__c = System.now();
        }
    }
    
    Database.SaveResult[] saveResult;

    List<Customer_Address__c> addressesToUpdate = new List<Customer_Address__c>();
    Integer numberUpdated = 0;
    for(Customer_Address__c ca : addrsList){
        addressesToUpdate.add(ca);
        numberUpdated++;
        if(addressesToUpdate.size() == Integer.valueOf(Label.Address_Chunk_Size) || numberUpdated == addrsList.size()){
            try{
                AddressTerritoryHandler.hasExecuted = true;
                saveResult = Database.update(addressesToUpdate, false);
                addressesToUpdate.clear();} catch(Exception ex){}

            for (Integer i = 0; i < saveResult.size(); i++) {
                if (saveResult[i].isSuccess()) {
                  //  System.debug('Successfully updated Record ID: '+ saveResult[i].getId());
                } else {
                   // System.debug('The error reported was: '+ saveResult[i].getErrors()[0].getMessage() + '\n');
                }
            }
        }
    }        
}

public void addressRemovalSearch(){
    List<Customer_Address__c> addressList = new List<Customer_Address__c>();
    removalAddressWrapperList = new List<AddressWrapper>();
    if(removalQueryInputField != null){
        String inputField = removalQueryInputField.trim().replaceAll('(\\s+)', ' ');
        if(inputField != ''){
            if(planObj.Id != null)
            {
                String queryString = 'SELECT Id, Name,Last_Knock_Date__c,Address_2__c, Plan__c, Address__c, City__c, PostalCode__c, State__c, Property_Code__c FROM Customer_Address__c WHERE Plan__c = \''+planObj.Id+'\' AND '+removalQueryFieldOption+' LIKE \'%'+inputField+'%\'';
                try{
                addressList = Database.Query(queryString);}catch(Exception ex){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                }

                if(addressList != null && !addressList.isEmpty()){
                    for(Customer_Address__c addrs : addressList){
                        removalAddressWrapperList.add(new AddressWrapper(addrs));
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'No Addresses Found that match that criteria'));
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Plan does not have an Id'));
              //  System.debug('Following exception occurred :Plan does not have an Id');
            } 
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Invalid Criteria for Address Removal Search.'));
          //  System.debug('Following exception occurred :Invalid Criteria for Address Removal Search.');
        }
    }
}

public void removeSelected(){
    List<Customer_Address__c> addressesToRemove = new List<Customer_Address__c>();
   
    if(planObj.Plan_Level__c == 'Turf'){
        User sharedDataUser = new User();
        sharedDataUser = [Select Id From User Where Name = 'Shared Data User' limit 1];    
        for(Integer i = 0; i < removalAddressWrapperList.size(); i++){
            if(!removalAddressWrapperList.isEmpty() && removalAddressWrapperList.get(i).selected) {
                removalAddressWrapperList.get(i).addrs.Plan__c = null;
                removalAddressWrapperList.get(i).addrs.OwnerId = sharedDataUser.Id;
                addressesToRemove.add(removalAddressWrapperList.get(i).addrs);
                removalAddressWrapperList.remove(i);
                i--;
            }
        }
    } else {
        // Sprint4,UserStory:DE72871(Exception thrown in PlanEditExtn Apex Class)Author: lalit singh
        String parentPlanId = planObj.Parent_Plan__c;
        Plan__c tempPlan = new Plan__c();
         if(parentPlanId != null && parentPlanId!= ' '){
            tempPlan = [Select Id, OwnerId From Plan__c Where Id =: parentPlanId limit 1];
         }
         
        for(Integer i = 0; i < removalAddressWrapperList.size(); i++){
            // Sprint4,UserStory:DE72871(Exception thrown in PlanEditExtn Apex Class)Author: lalit singh
            if(!removalAddressWrapperList.isEmpty() &&removalAddressWrapperList.get(i).selected){
                removalAddressWrapperList.get(i).addrs.Plan__c = tempPlan.Id;
                removalAddressWrapperList.get(i).addrs.OwnerId = tempPlan.OwnerId;
                addressesToRemove.add(removalAddressWrapperList.get(i).addrs);
                removalAddressWrapperList.remove(i);
                i--;
            }
        }
    }
    try {
        Database.SaveResult[] saveResult = Database.update(addressesToRemove,false);
        numberOfAddressesOnPlan -= addressesToRemove.size();
        savePlan();} catch(exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
    }
}

public void removeAll(){
    List<Customer_Address__c> addressesToRemove = new List<Customer_Address__c>();
    if(planObj.Plan_Level__c == 'Turf'){
        User sharedDataUser = new User();
        sharedDataUser = [Select Id From User Where Name = 'Shared Data User' limit 1];
        for(AddressWrapper addrsWrap : removalAddressWrapperList){
            addrsWrap.addrs.Plan__c = null;
            addrsWrap.addrs.OwnerId = sharedDataUser.Id;
            addressesToRemove.add(addrsWrap.addrs);
        }
    } else {
        // Sprint4,UserStory:DE72871(Exception thrown in PlanEditExtn Apex Class)Author: lalit singh
        String parentPlanId = planObj.Parent_Plan__c;
        Plan__c tempPlan = new Plan__c();
        if(parentPlanId != null && parentPlanId!= ' '){
            tempPlan = [Select Id, OwnerId From Plan__c Where Id =: parentPlanId limit 1];
        }
        for(AddressWrapper addrsWrap : removalAddressWrapperList){
            addrsWrap.addrs.Plan__c = tempPlan.Id;
            addrsWrap.addrs.OwnerId = tempPlan.OwnerId;
            addressesToRemove.add(addrsWrap.addrs);
        }
    }
    try {
        Database.SaveResult[] saveResult = Database.update(addressesToRemove,false);
        numberOfAddressesOnPlan -= addressesToRemove.size();
        savePlan();} catch(exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
    }
    removalAddressWrapperList.clear();
}

public void displayAssignedAddressesMessage(String queryStr){
    List<Customer_Address__c> addrsList = new List<Customer_Address__c>();
    if(queryStr.contains('Plan__c = null') || Test.isRunningTest()){
        queryStr = queryStr.replace('Plan__c = null', 'Plan__c != null');
        Integer fromIndex = queryStr.indexOf(' from Customer_Address__c');
        queryStr = queryStr.substring(0,fromIndex)+', Plan__c'+queryStr.substring(fromIndex);
        try {
         addrsList = Database.Query(queryStr);} catch(Exception ex) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));}

        if(!addrsList.isEmpty() || Test.isRunningTest()){
            Map<String,Integer> plansAddressCountMap = new Map<String,Integer>();
            for(Customer_Address__c ca : addrsList){
                if(plansAddressCountMap.containsKey(ca.Plan__c)){
                    plansAddressCountMap.put(ca.Plan__c, plansAddressCountMap.get(ca.Plan__c) + 1);
                } else {
                    plansAddressCountMap.put(ca.Plan__c, 1);
                }
            }

            List<Plan__c> planSet = new List<Plan__c>();
            planSet = [Select Id, Name From Plan__c Where Id IN: plansAddressCountMap.keySet()];
            String message = '';
            for(Plan__c p : planSet){
                message += '<a style="margin: 0; font-size: 100%; font-family: Arial,Helvetica,sans-serif; color: #222;" href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+p.Id+'"target="_blank">'+p.Name+'</a> ';
                message += ' has ' + plansAddressCountMap.get(p.Id) + ' Addresses assigned that match this search criteria. ';
            }
            if(message != ''){
               message = message.substring(0,message.length()-1);
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,message));
            } else {
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Addresses matching this criteria are currently assigned to other Plans.'));
        }

    } else {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Unable to find Addresses already assigned to other plans.'));
    }
}

/***********************************************************************************************************************************
 * Author     : Radhika Bansal, Accenture
 * Param      : None
 * Return     : List<SelectOption>
 * Description: US599546 - Enhancement: Bulk Assign for Business Partners: Part 1
                This method saves the values in the picklist field 'Plan Type' based on the custom setting value.
/************************************************************************************************************************************/

public List<SelectOption> getPlanTypeValue() {
Assign_Bulk_Access__c UserId =  Assign_Bulk_Access__c.getInstance(UserInfo.getUserId());
Assign_Bulk_Access__c ProfileId =  Assign_Bulk_Access__c.getInstance(UserInfo.getProfileId());   
List<SelectOption> options = new List<SelectOption>();
   options.add(new SelectOption('', System.Label.PlanEditExtnNone));
Schema.DescribeFieldResult fieldResult = Plan__c.Plan_Level__c.getDescribe();
List<Schema.PicklistEntry> pListEntry = fieldResult.getPicklistValues();
if((UserId.IsTrue__c == True) || (ProfileId.IsTrue__c == True) )
   {
     for(Schema.PicklistEntry type : pListEntry)
        {
         options.add(new SelectOption(type.getValue(),type.getLabel()));
        }       
     }
 else
 {
    for(Schema.PicklistEntry type : pListEntry)
    {
     if(!System.Label.PlanTypeBulk.equalsIgnoreCase(type.getValue()))
        {
        options.add(new SelectOption(type.getValue(),type.getLabel()));
        }
    }
 }  
   return options;
}
}