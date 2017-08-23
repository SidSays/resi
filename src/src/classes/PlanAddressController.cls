/* Description: US728540 DSM to SF1: See Addresses on a map (Analysis + Lightning Components)
   Created Date: March 24, 2017
   Created By: Radhika Bansal  
   Last Updated By: Malay Desai (US728588)
   Last Updated By: Tejaswini Kasar (US1099113)
   Last Updated By: Malay Desai (US1108251)
   Last updated Date : June 20, 2017
   Last updated Date : June 28, 2017
   Last Updated By: Tejaswini Kasar (US946427)
   
   
*/
public class PlanAddressController {
    public PageReference pgRef;
    private static final String PLAN_TYPE_ASSIGNED = 'Assigned';
    private static final String PLAN_EDIT_URL = '/';
    private static final String PLAN_LIST_URL = '/a0I/o';
    private static final String RET_URL = 'retURL';
    private static final String NO_OVERRIDE = 'nooverride';
    private static final String ONE = '1';
    private static final String USER_AGENT = 'USER-AGENT';
    private static final String ID = 'id';
    private static final String IPHONE = 'iPhone';
    private static final String IPAD = 'iPad';
    private static final String ON_TURF = 'on';
    private static final String OFF_TURF = 'off';
    Id loggedInUserId = UserInfo.getUserId();
    private static final String errorMessageToShow = 'You do not have permission to manage door knocking activity from SF1. Please use the DSM app to manage your Turf.';
    private static final String ADDRESS_FILTERING_ACCESS_STRING = 'Address_Filtering_Access';


    
    
    // This method is created as we have used Plan object as standard controller in our apex page PlanAddressPage1
    public PlanAddressController(ApexPages.StandardController controller){}
    
    // This method is used to query related addresses of a plan
    @AuraEnabled
    public static AddressesAndPlans getPlanAddresses(String planId){
        String loggedInUser = UserInfo.getUserId();
        String likeLoggedInUser = '%'+loggedInUser.substring(0, 15)+'%';
        String currentPlanName;
        List<String> teamIds;
        try{
            List<Customer_Address__c>  addresses =  
                [SELECT Id,Name,Latitude__c,Longitude__c,Address_New__c,Last_Knock_Date__c,Last_Disconnected_Date__c,
                 City__c,State__c,PostalCode__c,Customer_Name__c,NCLV_Reg_Decile__c,Targeted__c,
                 Dwelling_Type__c,Status__c,Worked__c,Sort_Code__c,FormulaTapStatus__c,
                 Video_Active1__c,HSI_Active1__c,Voice_Active1__c,XH_Active1__c,HSI_Only__c,
                 Active_Inactive__c,Most_Recent_Disposition__c,Total_Monthly_Rate__c,Comcast_Division__c, 
                 WA_Actives_1_Product__c,WA_Actives_2_Product__c,WA_Actives_3_Product__c,
                 Account__r.AccountNumber,Location_ID__c,Rejected_Reason__c
                 FROM Customer_Address__c WHERE Plan__c = :planId AND
                 Latitude__c != null AND Longitude__c != null ];
            
            List<Team__c> teams = 
                [SELECT Id,All_Team_Members__c FROM Team__c 
                 WHERE All_Team_Members__c LIKE :likeLoggedInUser];
            if(teams != null && !teams.isEmpty()){
                teamIds = new List<String>();
                for(Team__c team : teams){
                    teamIds.add(team.Id);
                }            
            }
            List<Plan__c> assignedPlans;
            if(teamIds != null && !teamIds.isEmpty()){
              assignedPlans = 
                    [SELECT Id, Name,Plan_Level__c,Total_Worked_Addresses__c, Plan_Status__c,
                     Expiration_Date__c,Plan_Created_Date__c,True_count_of_Addresses__c
                     FROM Plan__c WHERE (User__c =: loggedInUser OR Assigned_Team__c IN :teamIds) 
                     AND Plan_Status__c = :PLAN_TYPE_ASSIGNED];
            }else{
                assignedPlans = 
                    [SELECT Id, Name,Plan_Level__c,Total_Worked_Addresses__c, Plan_Status__c,
                     Expiration_Date__c,Plan_Created_Date__c,True_count_of_Addresses__c
                     FROM Plan__c WHERE (User__c =: loggedInUser) 
                     AND Plan_Status__c = :PLAN_TYPE_ASSIGNED];
            }            
            currentPlanName = [SELECT Name FROM Plan__c WHERE Id=:planId LIMIT 1].Name;

            return new AddressesAndPlans(addresses,assignedPlans,currentPlanName);            
        } catch(Exception ex){return null;}
    }        
    
    //US728588 (Malay) - Start
    @AuraEnabled
    public static String createPlaylistFromTurf(List<Customer_Address__c> addresses, String planId,
                                                String playlistName){
        List<Customer_Address__c> addressesTobeUpdated;
        Plan__c currentPlan, playlist;
        String playlistId = null;        
        try{
            if(!addresses.isEmpty() && planId != null){
                 currentPlan = [SELECT Id, Expiration_Date__c,Assigned_Team__c, Plan_Level__c, Parent_Plan__c,User__c 
                                FROM Plan__c WHERE Id =:planId LIMIT 1];
                                
                if(currentPlan != null){
                    playlist = new Plan__c();
                    playlist.Name = playlistName;
                    playlist.Number_of_Addresses__c=addresses.size();
                    playlist.True_count_of_Addresses__c=addresses.size();
                    playlist.OwnerId = UserInfo.getUserId();
                    playlist.User__c = UserInfo.getUserId();
                    playlist.Plan_Status__c = PLAN_TYPE_ASSIGNED;
                    playlist.Plan_Level__c = Label.PlanTypePlaylist;
                    playlist.Expiration_Date__c = currentPlan.Expiration_Date__c;
                    if(currentPlan.Plan_Level__c != Label.PlanTypePlaylist){
                        playlist.Parent_Plan__c = currentPlan.Id; // or planId (both are same)
                    }else{
                        //When creating playlist from the playlist, the parent is turf.
                        playlist.Parent_Plan__c = currentPlan.Parent_Plan__c; 
                    }                    
                    Database.SaveResult sr = Database.insert(playlist,true);
                    if(sr.isSuccess()){
                        addressesTobeUpdated = new List<Customer_Address__c>();
                        playlistId = sr.getId();
                        for(Customer_Address__c address : addresses){
                            address.Plan__c = playlistId; // All addresses will be shifted to newly created playlist
                            addressesTobeUpdated.add(address);
                        }
                        Database.update(addressesTobeUpdated,false);
                    }
                }
            }
            return playlistId;
        }catch(Exception ex){ return ex.getMessage();}
    }     //US728588 (Malay) - End   
    
    /**    
    * @Description: US1108251- Method which returns Addresses based on the Search key user enters on the Search Bar of AddressFiltering page
    * @Author: Malay Desai, Accenture
    * @Date: 14/6/2017
    * @Param: Search Key, On Turf/ Off Turf/Both, Plan Id
    * @Return: List<Customer_Address__c> or null
    */ 
    @AuraEnabled
    public static List<Customer_Address__c> findAddressesBySearchKey(String searchKey, String onOrOff, String planId){
        String userId = UserInfo.getUserId();
        String searchKeyLike = '*'+searchKey+'*';
        List <String> billingAccountNumberList = new List <String> ();
        Set <Customer_Address__c> resultantAddressesSet = new Set<Customer_Address__c>();
         List <Customer_Address__c> resultantAddresses;
        List<Customer_Address__c> addressesMatchingAccountNumber;
            try{
                List<List<SObject>> accounts= [FIND :searchKeyLike IN ALL FIELDS RETURNING Account(id,Billing_Account_Number__c) limit 100];
                if(accounts[0] != null && !accounts[0].isEmpty()){
                      for(Account accId: (List<Account>)accounts[0]){
                          if(accId.Billing_Account_Number__c != null)
                            billingAccountNumberList.add(accId.Billing_Account_Number__c);
                      }
                }
                if(onOrOff.equalsIgnoreCase(ON_TURF)){ // On Turf
                    List<List<SObject>> searchResults=
                        [FIND :searchKeyLike IN ALL FIELDS  
                         RETURNING Customer_Address__c (Name, City__c,State__c,PostalCode__c,
                         Active_Inactive__c,Account__r.Billing_Account_Number__c,Location_ID__c 
                         WHERE (Plan__c = : planId)
                         ORDER BY Sort_Code__c LIMIT 100)]; 
                       
                    addressesMatchingAccountNumber = [SELECT Name, City__c,State__c,PostalCode__c,
                         Active_Inactive__c,Account__r.Billing_Account_Number__c,Location_ID__c
                         FROM customer_address__C
                         WHERE (Plan__c = : planId  AND Account__r.Billing_Account_Number__c IN :billingAccountNumberList) 
                         ORDER BY Sort_Code__c LIMIT 100];
                    resultantAddresses = (List <Customer_Address__c>)searchResults[0];
                    resultantAddresses.addAll(addressesMatchingAccountNumber);
                    
                } else{
                    Set<Id> planIds = new Set<Id>();
                    String region;
                    for(User usr : [SELECT Id, Region__c FROM User WHERE Id = :userId LIMIT 1]){
                            region = usr.Region__c;
                    }
                    
                    for(Plan__c plan : [SELECT Id FROM Plan__c WHERE User__c = :userId]){
                        planIds.add(plan.Id);
                    }
                    
                    if(onOrOff.equalsIgnoreCase(OFF_TURF)){ //Off Turf
                        List<List<SObject>> searchResults=
                            [FIND :searchKeyLike IN ALL FIELDS  
                             RETURNING Customer_Address__c (Name, City__c,State__c,PostalCode__c,
                             Active_Inactive__c,Account__r.Billing_Account_Number__c,Location_ID__c 
                             WHERE Region__c = :region AND 
                             (Plan__c NOT IN : planIds)
                             ORDER BY Sort_Code__c LIMIT 100)]; 
            resultantAddresses = (List <Customer_Address__c>)searchResults[0];
                                                  
                        addressesMatchingAccountNumber = [SELECT Name, City__c,State__c,PostalCode__c,
                           Active_Inactive__c,Account__r.Billing_Account_Number__c,Location_ID__c
                           FROM customer_address__C
                           WHERE (Plan__c NOT IN : planIds  AND Account__r.Billing_Account_Number__c IN :billingAccountNumberList) 
                           ORDER BY Sort_Code__c LIMIT 100];
                            
                        resultantAddresses.addAll(addressesMatchingAccountNumber);
                        
                    } else{ //onOrOff = "both" i.e. On Turf + Off Turf
                       
                        List<List<SObject>> searchResults=
                            [FIND :searchKeyLike IN ALL FIELDS  
                             RETURNING Customer_Address__c (Name, City__c,State__c,PostalCode__c,
                             Active_Inactive__c,Account__r.Billing_Account_Number__c,Location_ID__c 
                             WHERE (Region__c = :region)
                             ORDER BY Sort_Code__c LIMIT 100)]; 
                        resultantAddresses = (List <Customer_Address__c>)searchResults[0];
                        
                        addressesMatchingAccountNumber = [SELECT Name, City__c,State__c,PostalCode__c,
                           Active_Inactive__c,Account__r.Billing_Account_Number__c,Location_ID__c
                           FROM customer_address__C
                           WHERE (Region__c = :region  AND Account__r.Billing_Account_Number__c IN :billingAccountNumberList) 
                           ORDER BY Sort_Code__c LIMIT 100];
                        
                        resultantAddresses.addAll(addressesMatchingAccountNumber);
                    }
                }           
            } catch (Exception ex){return null;}
          //Remove Duplicate
           if(resultantAddresses.size() >0){
             resultantAddressesSet.addAll(resultantAddresses);
                resultantAddresses.clear();
                resultantAddresses.addAll(resultantAddressesSet);
             }
                  
         return (resultantAddresses.size() >0)?resultantAddresses:null;        
    }
        
    public class AddressesAndPlans{
        @AuraEnabled
        public List<Customer_Address__c> addresses;
        @AuraEnabled
        public List<Plan__c> plans;
        @AuraEnabled
        public String currentPlanName;
        
        public AddressesAndPlans(List<Customer_Address__c> addressesList, List<Plan__c> planList, 
                                 String currentPlanName){
            this.addresses = addressesList;
            this.plans = planList;
      this.currentPlanName = currentPlanName;
        }
    }
    
    
    /* Description: US1099113 DSM to SF1: AddressFiltering displays on SF1 only
     * Created Date: JUNE 1, 2017
     * Created By: Tejaswini Kasar 
     * Modified By :Tejaswini Kasar(US1124160)*/
    //This Page reference will detect the USER AGENT (desktop/mobile) and accordingly redirect to vf page / plan detail page.
    public PageReference redirectBasedOnBrowser(){
        String userAgent = ApexPages.currentPage().getHeaders().get(USER_AGENT);
        String planId = ApexPages.currentPage().getParameters().get(ID);
        Set<id> userIdSet = new Set<id>();
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        psaList = [SELECT AssigneeId FROM PermissionSetAssignment  WHERE PermissionSet.Name =: ADDRESS_FILTERING_ACCESS_STRING];
       if(userAgent.contains(IPHONE) || userAgent.contains(IPAD) ){
           //US1124160 (Start)
           if(!psaList.isEmpty() || psaList != null){
               for(PermissionSetAssignment psa : psaList){
                    userIdSet.add(psa.AssigneeId); 
               }
           }
            if(userIdSet.contains(loggedInUserId) && (!userIdSet.isEmpty() || userIdSet != null)){
                
                pgRef = page.AddressFiltering; 
            }else{
                
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessageToShow));
            }
        //US1124160 (end)           
        } else {
         pgRef= new PageReference(PLAN_EDIT_URL+planId);
  
          pgRef.getParameters().put(RET_URL, new PageReference(PLAN_LIST_URL).getURL());  
          pgRef.getParameters().put(NO_OVERRIDE, ONE); 
          pgRef.setRedirect(true);
         }
        return pgRef;
    }
     /* Description: US946427 DSM to SF1: DSM to SF1: Filter by Rejected Addresses
     * Created Date: JUNE 28, 2017
     * Created By: Tejaswini Kasar 
     */
     //This method will return Rejected addresses based on start and end date entered in Address Filtering Page
    @AuraEnabled
    public static List<Customer_Address__c> getRejectedAddresses(String startDate, String endDate, String planId){
        date startDateVal = Date.valueOf(startDate);
        date endDateVal = Date.valueOf(endDate);
        DateTime dt1 = DateTime.newInstanceGmt(startDateVal.year(),startDateVal.month(),startDateVal.day(),0,0,0);
        DateTime dt2 = DateTime.newInstanceGmt(endDateVal.year(),endDateVal.month(),endDateVal.day(),23,59,59);
        String RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(Label.Knock).getRecordTypeId();
        List<Customer_Address__c> addressList = new List<Customer_Address__c>();
        
        try{
        //Retrieve the List of Addresses in the Plan
        List<Customer_Address__c> addressPlanList = [SELECT Id,Account_Name__c,Address__c,Plan__c,latitude__c, longitude__c,OwnerId,Rejected_Reason__c 
                                                     From Customer_Address__c WHERE Plan__c = :planId AND Rejected_Reason__c != null AND Last_Knock_Date__c>= :dt1];
        Set<Id> addrIDs = new Set<Id>();
        for(Customer_Address__c addr : addressPlanList){
              addrIDs.add(addr.Id);
         }
         Map<Id,List<Task>> rejectedTaskMap = new Map<Id,List<Task>>();
         List<Task> rejectedTaskList = new List<Task>();
         List<Task> rejectedList = [SELECT Id,WhatId,CreatedDate,Rejected_Reason__c FROM Task WHERE RecordType.Id = :RecordTypeId AND WhatId IN :addrIDs AND Rejected__c = True AND Rejected_Reason__c != null AND CreatedDate >= :dt1 AND CreatedDate <= :dt2];  
         for(Customer_Address__c addrList : addressPlanList){
              for(Task taskList : rejectedList){
                  if(taskList != null && taskList.WhatId == addrList.Id){
                          rejectedTaskList.add(taskList);
                      
               }
          }
          if(!rejectedTaskList.isEmpty()) {
                rejectedTaskMap.put(addrList.Id,rejectedTaskList);
          }  
          }
          Set<Id> addressIDs = rejectedTaskMap.keySet();
           
          addressList = [SELECT Id,Name,Latitude__c,Longitude__c,Address_New__c,Last_Disconnected_Date__c,
                 City__c,State__c,PostalCode__c,Customer_Name__c,NCLV_Reg_Decile__c,Targeted__c,
                 Dwelling_Type__c,Status__c,Worked__c,Sort_Code__c,FormulaTapStatus__c,
                 Video_Active1__c,HSI_Active1__c,Voice_Active1__c,XH_Active1__c,HSI_Only__c,
                 Active_Inactive__c,Most_Recent_Disposition__c,Total_Monthly_Rate__c,Comcast_Division__c, 
                 WA_Actives_1_Product__c,WA_Actives_2_Product__c,WA_Actives_3_Product__c,
                 Account__r.AccountNumber,Location_ID__c,Rejected_Reason__c,Account_Name__c,Address__c,Plan__c,OwnerId, Last_Knock_Date__c, LastModifiedDate, (SELECT Id, WhatId,CreatedDate,Rejected_Reason__c FROM Tasks WHERE Rejected_Reason__c != null AND Rejected__c = true) 
                        From Customer_Address__c WHERE Id IN : addressIDs AND Rejected_Reason__c != null  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
               //Creating wrapper Objects for the API
               
            return addressList;
        }
              catch(Exception e){
                  System.debug('Exception occured' + e);
                  return null;
              }
            
            
    }
}