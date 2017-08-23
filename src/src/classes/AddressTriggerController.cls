/***************************************************************************************************************************************
 * Author              : Amitkumar Bangad
 * Date                : 25-April-2013
 * Description         : Contains Supporting actions for Customer Address Triggers
 * Last Modified       : Malay Desai
 * Requirement         : US583744: Business Partner: Manager hierarchy access
 * Date                : 9-MAR-2015  
 * Modified By: Animesh
 * Modified Date: 25-Jul-2017
 * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Bypassing trigger when PlanEdit is executed 
***************************************************************************************************************************************/
public class AddressTriggerController {
    private static final string STR_HSIONLYINCLUDED = 'HSI Only Included=false';
     private static final string STR_NONMARKETABLEEXCLUDED = 'Non-Marketable Addresses Excluded=true'; //US1159184 changes
    public static boolean byPassFromPlanEdit = true;// US1137083 - Animesh - 25-Jul-2017

    /**
    * @Description: This method sets the Disconnect Checkbox to True and clears the Complex Office Checkbox if Criteria are met.
    * @Author: Erin McGee, Acumen Solutions
    * @Date: 23-December-2014
    * @Param: Trigger.New
    * @Return: void.
    * @LastUpdatedBy : Malay Desai, Accenture
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Added Try Catch
    */
    public static void setCheckboxes(List<Customer_Address__c> newAddressList) {
        try{
            List<Customer_Address__c> addressList= new List<Customer_Address__c>();
            for(Customer_Address__c addr: newAddressList){
                if(addr.Status__c == 'Former' && !addr.Disconnected__c){
                    addr.Disconnected__c=true;
                } else if (addr.Status__c != 'Former' && addr.Disconnected__c){
                    addr.Disconnected__c=false;
                }else{}
            }
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }

    /**
    * @Description: This method sets the Address Standard Division.
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 25-April-2013
    * @Param: Trigger.New
    * @Return: void.
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Added Try Catch
    */
    public static void setAddressDivisionAndDisconnected(List<Customer_Address__c> newAddressList) {
        try{
            Set<Id> divisionIds = new Set<Id>();
            Set<String> divisionNames = new Set<String>();
            Map<String, Id> divisionIdbyName = new Map<String, Id> ();
            for(Customer_Address__c addr: newAddressList){
                if(addr.Region__c != null){
                    divisionNames.add(addr.Region__c);  
                } else{
                    divisionNames.add(Label.DivisionGlobal);
                }
            }
            if(!divisionNames.IsEmpty()){
                for(Division div: [SELECT Id, Name FROM Division WHERE name=: divisionNames]){
                    divisionIdbyName.put(div.name, div.Id);    
                }
                for(Customer_Address__c ad: newAddressList){
                    if(ad.Region__c != null){
                        ad.Division = divisionIdbyName.get(ad.Region__c); 
                    } else{
                        ad.Division = divisionIdbyName.get(Label.DivisionGlobal);  
                    }
                }
            }else{}
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }
    
    /**
    * @Description: US583744: Business Partner: Manager hierarchy access
    * @Author: Radhika Bansal, Accenture
    * @Date: 3-Nov-2015
    * @Param: Trigger.New
    * @Return: void
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Added Try Catch
    */
    public static void addressShareAccess(List<Customer_Address__c> addressdata){
        try{
            List<User> newUsers = new List<User>(); // To create the list of users sepcific to Profile Contractor Sales Professional;
            List<Customer_Address__Share> addShares = new List<Customer_Address__Share>();
            Set<Id> ownerList = new Set<Id>();
            // To Create a list of owners for the Address records
            for(Customer_Address__c address : addressdata){
                ownerList.add(address.OwnerId);
            }
            String profileName = System.Label.Contractor_Direct_Sales_Representative;
            String manager = System.Label.Manager;
            newUsers= [Select id from user where Id IN :ownerList and Profile.name = :profileName  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            Map<Id, Id> groupMap = new Map<Id, Id>(); // To map the user id with its manager hierarchy
            for(Group g : [SELECT Id, RelatedId,Type FROM Group WHERE Type = :manager AND RelatedId IN :newUsers]){
                groupMap.put(g.RelatedId, g.Id);
            }
            // The below code assign the Address record access to the manager hierarchy of the user.
           Customer_Address__Share adRecord ;
            for(Customer_Address__c address : addressdata){
                if(!groupMap.isEmpty() && groupMap.get(address.OwnerId)!=null){
                     adRecord = new Customer_Address__Share();
                    adRecord.ParentId = address.Id;
                    adRecord.userorgroupId = groupMap.get(address.OwnerId);
                    adRecord.AccessLevel = System.Label.EditAddressTriggerController;
                    //adRecord.rowCause = Schema.Customer_Address__Share.rowCause.Manual;
                    addShares.add(adRecord);
                }else{}
            }
            if(!addShares.isEmpty()){
                Database.SaveResult[] CoachingShareInsertResult = Database.insert(addShares ,false);
            }
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }
    /*
    public static Map<String, Id> buildRegionGroupMap(){
        
        Map<String,String> groupRegionMap = new Map<String,String>(); // Map containing Public Group Name and correspodning Region
        Map<String, Id> groupMap = new Map<String, Id>(); // Map containing Region and corresponding Public Group's Id
        
        for(Address_Regional_Sharing__c record : Address_Regional_Sharing__c.getAll().values()){            
            if(record != null){
                groupRegionMap.put(record.Public_Group__c, record.Region__c);
            }
        }
        
        for(Group publicGroup : [SELECT id,Name FROM Group WHERE Name IN :groupRegionMap.keySet()  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){            
            if(publicGroup!=null){
                groupMap.put(groupRegionMap.get(publicGroup.Name), publicGroup.Id); //Region vs corresponding GroupId
            }
        }
        return groupMap;
    }
    */
     /**
    * @Description: US596845: Address regional sharing: Part 1
    * @Author: Malay Desai, Accenture
    * @Date: 31-DEC-2015
    * @Param: List of Addresses to Share
    * @Return: null
    */
    /* Commented for US596845
    public static void shareAddressWithinRegionalGroups(List<Customer_Address__c> addressList){
        List<Customer_Address__Share> addressShareList = new List<Customer_Address__Share>();
        Map<String, Id> groupMap = buildRegionGroupMap();
        String rowCause = Schema.Customer_Address__Share.rowCause.Region__c;
        
        for(Customer_Address__c address : addressList){
            Customer_Address__Share addressShare = new Customer_Address__Share();
            addressShare.parentId = address.Id;
            addressShare.userorgroupId = groupMap.get(address.Region__c);
            Address_Regional_Sharing__c tempCS = Address_Regional_Sharing__c.getValues(address.Region__c);
            addressShare.AccessLevel = tempCS != null? tempCS.Access_Level__c:System.Label.EditAddressTriggerController;
            addressShare.rowCause = rowCause;
            addressShareList.add(addressShare);         
        }
        
        if(!addressShareList.isEmpty()){
          List<Database.SaveResult> srList = Database.insert(addressShareList,false);
    
            for(Database.SaveResult sr : srList){            
            if(!sr.isSuccess()){                                                 
                for(Database.Error error : sr.getErrors()){
                    System.Debug('Error Fields : '+ error.getFields());
                    System.Debug('Error Message : ' + error.getMessage());
                    System.Debug('Error Status Code : ' + error.getStatusCode());                                                              
                 }
            }
          }
      }
        
    }
    */
    
     /**
    * @Description: US596845: Address regional sharing: Part 1
    * @Author: Malay Desai, Accenture
    * @Date: 31-DEC-2015
    * @Param: List of Addresses for which sharing needs to be added or removed
    * @Return: null
    */
    /*
    public static void updateAddressSharingOnRegionChange(List<Customer_Address__c> addressList, Map<Id,Customer_Address__c> oldAddressMap){
        List<Customer_Address__c> newAddressList = new List<Customer_Address__c>();
        List<Customer_Address__c> oldAddressList = new List<Customer_Address__c>();
        for(Customer_Address__c address : addressList){
            if(address.Region__c != null && address.Region__c != oldAddressMap.get(address.Id).Region__c){
                newAddressList.add(address);
                oldAddressList.add(oldAddressMap.get(address.Id));
            }
        }
        unshareAddressWithRegionalGroups(oldAddressList);
        shareAddressWithinRegionalGroups(newAddressList);
    }
    */
    /**
    * @Description: US596845: Address regional sharing: Part 1
    * @Author: Malay Desai, Accenture
    * @Date: 31-DEC-2015
    * @Param: List of Addresses for which sharing needs to be removed
    * @Return: null
    */
    /*
     public static void unshareAddressWithRegionalGroups(List<Customer_Address__c> addressList){
        
        Set<Id> addressIds = new Set<Id>();
        List<Customer_Address__Share> addressShareList;
        for(Customer_Address__c address : addressList){
            addressIds.add(address.Id);
        }
        
        if(addressIds.size() > 0){
            addressShareList = [SELECT id FROM Customer_Address__Share WHERE parentId IN :addressIds];
        
        
        List<Database.DeleteResult> srList = Database.delete(addressShareList,false);
    
            for(Database.DeleteResult sr : srList){            
            if(!sr.isSuccess()){                                                 
                for(Database.Error error : sr.getErrors()){
                    System.Debug('Error Fields : '+ error.getFields());
                    System.Debug('Error Message : ' + error.getMessage());
                    System.Debug('Error Status Code : ' + error.getStatusCode());                                                              
                 }
            }
          }
        }
     }
    */ 
    /**
    * @Description: To set the Property__c lookup on Address records
    * @Author: Malay Desai, Accenture
    * @Date: 31-DEC-2015
    * @Param: Trigger.new
    * @Return: null
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Added Try Catch
    */
    public static void setPropertyToAddress(List<Customer_Address__c> address){
        try{
            Map<Customer_Address__c, String> addressCodesMap = new Map<Customer_Address__c,String>();
            Map<String, Id> addressCodeIDMap;         
            for(Customer_Address__c addr:address){
                if(addr.Property_Code__c != null && addr.Corp__c !=null && addr.Region__c !=null)
                    addressCodesMap.put(addr,addr.Property_Code__c+'_'+addr.Corp__c+'_'+addr.Region__c );
            } 
            if(addressCodesMap.size() > 0){
                List<MDU_Property__c> properties = [SELECT Id,Address_Code__c FROM MDU_Property__c WHERE Address_Code__c IN:addressCodesMap.values()];
                if(properties != null && !properties.isEmpty()){
                    addressCodeIDMap = new Map<String, Id>();
                    for(MDU_Property__c property : properties){
                        addressCodeIDMap.put(property.Address_Code__c, property.Id);
                    }
                    for(Customer_Address__c cAddress :addressCodesMap.keySet()){
                        cAddress.property__c = addressCodeIDMap.get(addressCodesMap.get(cAddress));
                    }
                }
            }
            
             /*if(properties!= null && !properties.isEmpty()){
                 for(MDU_Property__c prop:properties){
                    for(Customer_Address__c cAddress :addressCodesMap.keySet()){
                        System.debug('*** addressCodesMap is null : ' + (addressCodesMap == null));
                        System.debug('*** addressCodesMap value: ' + addressCodesMap.get(cAddress));
                        if(addressCodesMap.get(cAddress).equalsIgnoreCase(prop.Address_Code__c)){
                            cAddress.property__c = prop.Id;
                        }
                    }
                 }
            } */
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }
    /**
    * @Description: To remove the Property__c lookup on Address records
    * @Author: Ashish Srivastava, Accenture
    * @Date: 18-March-2016
    * @Param: Trigger.new
    * @Return: null
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Added Try Catch
    */
    public static void removePropertyFromAddress(List<Customer_Address__c> addressList){
        try{
            for(Customer_Address__c address : addressList){
                if(address.Property_Code__c == null || address.Corp__c== null || address.Region__c == null){
                        address.property__c = null;
                }
            }
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }
     /**
    * @Description: Create Property button parent validation
    * @Author: Shivani Gautam, Accenture
    * @Date: 17th Jan 2017
    * @Param: Trigger.new
    * @Return: null
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Added Try Catch
    */
    public static void setIsNewOnAddress(List<Customer_Address__c> addressList){
        try{
            for(Customer_Address__c address : addressList){
                address.Is_New__c = true;
            }
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }
    /**
    * @Author: 
    * @Date: 
    * @Param: Trigger.new,Trigger.oldMap
    * @Return: null
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Added Try Catch
    */
    public static void setFlagOnRemovingParentAddress(List<Customer_Address__c> addressList, Map<Id,Customer_Address__c> oldAddressMap){
        try{
        for(Customer_Address__c address : addressList){
            if(address.Parent_Address__c == null && oldAddressMap.get(address.Id).Parent_Address__c != null){
                address.Is_New__c = true;
            }
        }
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }
    
    /**
    * @Description: updating total no of worked field in Plan
    * @Author: Amit Kumar Pradhan, Accenture
    * @Date: 23-Feb-2017
    * @Param: Trigger.new, Trigger.oldMap
    * @Return: null
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Added Try Catch
    */
    public static void updateTotalWorkedAddrOnPlan(List<Customer_Address__c> newAddrList, Map<Id,Customer_Address__c> oldAddrMap){   
        try{
            Map<String,Integer> planIdAndWorkedCountMap = new Map<String,Integer>();
            for(Customer_Address__c address : newAddrList){
                if(address.Plan__c != null && address.Worked__c != oldAddrMap.get(address.Id).Worked__c){
                    Integer tempCount = 0;
                    if(planIdAndWorkedCountMap.containsKey(address.Plan__c)){
                        tempCount = planIdAndWorkedCountMap.get(address.Plan__c);
                    }
                    
                    if(address.Worked__c){
                        tempCount++;
                    }else{
                        tempCount--;
                    }
                    planIdAndWorkedCountMap.put(address.Plan__c, tempCount);
                }
            }
            
            if(planIdAndWorkedCountMap != null && !planIdAndWorkedCountMap.isEmpty()){
                List<Plan__c> planList = new List<Plan__c>();
                for(Plan__c planobj : [SELECT Id, Total_Worked_Addresses__c FROM Plan__c WHERE Id IN:planIdAndWorkedCountMap.keySet()]){
                    if(planobj.Total_Worked_Addresses__c == null){
                        planobj.Total_Worked_Addresses__c = 0;
                        planobj.Total_Worked_Addresses__c += planIdAndWorkedCountMap.get(planobj.Id);
                    }
                    else{
                        planobj.Total_Worked_Addresses__c += planIdAndWorkedCountMap.get(planobj.Id);
                    }
                    
                    //planobj.Total_Worked_Addresses__c += planIdAndWorkedCountMap.get(planobj.Id);
                    if(planobj.Total_Worked_Addresses__c < 0){
                        planobj.Total_Worked_Addresses__c = 0;
                    }
                    planList.add(planobj);
                }
                
                if(planList != null && !planList.isEmpty()){
                    database.update(planList,false);
                }
            }
        }catch(Exception e){system.debug('***Following exception has occured***: '+e.getMessage());}  
    }
     /**    
    * @Description: US1096534:Direct - Dynamically Remove Inactive to Active Addresses from Turf.
            As a West Division XSP when a Targeted Address in my “Assigned” Turf is no longer Targeted and the Address is removed from my Turf.
          As a Central/NED XSP when a non-HSI Only Targeted Address in my “Assigned” Turf is no longer Targeted and the Address is removed from my Turf 
    * @Author: Amit Kumar, Accenture    
    * @Date: 14-May-2017 
    * @Param:  Trigger.New, Trigger.OldMap    
    * @Return: None 
    * Modified By: Kiran Kumar
    * Modified Date: 09-Aug-2017
    * Modification Details: US1159184- Direct - Dynamically Remove Non Marketable Addresses from Turf
    */
    public static void removeaddressfromplan(List<Customer_Address__c> newAddrList, Map<Id,Customer_Address__c> oldAddrMap){  
       
        User sharedData = [Select Id, Name from User where Name=:ConstantHandler.SHARED_DATA_USER_NAME LIMIT 1];
        try{
   // US1159184 changes Start
            Map<Id,Customer_address__c>mapOfAdd = new Map<Id,Customer_Address__c>(
                [Select Id, Plan__r.Parameters__c from  Customer_Address__c where plan__c != null and Id in :oldAddrMap.keyset()]);
  // US1159184 changes End        
            for(Customer_Address__c objaddress : newAddrList){
                if(objaddress.Targeted__c != oldAddrMap.get(objaddress.Id).Targeted__c && 
                   !objaddress.Targeted__c && objaddress.Plan__c!=null && 
                   !(string.Isblank(objaddress.Comcast_Division__c))
                  ){
                  if(objaddress.Comcast_Division__c.equalsIgnoreCase(ConstantHandler.STR_WEST_NAME)){
                    objaddress.Plan__c = null;
                    objaddress.OwnerId = sharedData.id;
                  }else if((
                             (objaddress.Comcast_Division__c.equalsIgnoreCase(ConstantHandler.STR_NORTHEAST_NAME)) ||
                             (objaddress.Comcast_Division__c.equalsIgnoreCase(ConstantHandler.STR_CENTRAL_NAME))
                            )&&
                            (objaddress.HSI_Only__c).equalsIgnoreCase(ConstantHandler.STR_HSIONLY_NO_VAL)
                          ){
                    objaddress.Plan__c = null;
                    objaddress.OwnerId = sharedData.id;
                  }
                }
                // US1159184 changes start
                if(objaddress.Plan__c != null && !String.isBlank(mapOfAdd.get(objAddress.Id).Plan__r.Parameters__c) && mapOfAdd.get(objAddress.Id).Plan__r.Parameters__c.containsIgnoreCase(STR_NONMARKETABLEEXCLUDED) &&
                          objaddress.Non_Marketable__c == true && objaddress.Non_Marketable__c != oldAddrMap.get(objaddress.Id).Non_Marketable__c){
                              objaddress.Plan__c = null;
                      objaddress.OwnerId = sharedData.id;
                  }
                // US1159184 changes end
            }  
            
        }catch(Exception e){system.debug('***Following exception has occured***: '+e.getMessage());}       
    }
    
      /**    
    * @Description: US1096537- Dynamically Add Targeted Address to Turf.
      As an XSP when an Address in my Territory becomes Targeted and meets the parameters of an “Assigned” Turf add the 
      Address to my Assigned Turf so that I can work the most recently Targeted Addresses in my Territory.
    * @Author: Kiran Kumar, Accenture    
    * @Date: 06-June-2017 
    * @Param:Trigger.New, Trigger.OldMap    
    * @Return: None 
    * @Modified On: 9-Aug-2017
    * @Modified By: Srini Bhattiprolu
    * @User Story: US1129121: Direct - Dynamic Turf and DSM Limits
    * @Chnage: Added logic to prevent the dynamic addition of targeted/HSI only address to the turf if the turf already had 1200 addresses
    */ 
   public static void addAddressToPlan(List<Customer_Address__c> newAddrList, Map<Id,Customer_Address__c> oldAddrMap){ 
        Set<Id> territoriesIds = new Set<Id>();   
        Map<String,Plan__c> mapCensusPlan = new map<String,Plan__c>();
        Map<String,List<Customer_Address__c>> mapcensusaddress = new Map<String,List<Customer_Address__c>>(); 
        list<Customer_Address__c> lsttemp;
        list<Customer_Address__c> lstfilteredaddress = new list<Customer_Address__c>();
        SystemProperties sysProps = new SystemProperties(); //Srini Bhattiprolu: Defined the instace of this class for using Custom Mata Dat Type - AddressMaxLimitPerTurf
        
        try{
        // extracting census tract, territoriesIds from address
        for(Customer_Address__c objAddress : newAddrList){
            //Filtering address based on condition
            // US1097310 starts : Added by Kiran 
        if(
            (
                ( 
                    (
                        oldAddrMap!=null &&
                        objaddress.HSI_Only_Address__c && 
                        oldAddrMap.get(objaddress.Id).HSI_Only_Address__c != objaddress.HSI_Only_Address__c
                    ) ||
                    (
                        oldAddrMap==null &&
                        objaddress.HSI_Only_Address__c
                    )
                ) && 
                (
                    (objaddress.Comcast_Division__c.equalsIgnoreCase(ConstantHandler.STR_NORTHEAST_NAME)) ||
                    (objaddress.Comcast_Division__c.equalsIgnoreCase(ConstantHandler.STR_CENTRAL_NAME))
                )
            ) || 
            (
                oldAddrMap!=null && 
                objaddress.Targeted__c && 
                objaddress.Targeted__c != oldAddrMap.get(objaddress.Id).Targeted__c && 
                !objaddress.Excluded_from_Territory__c
            )||
            (!objaddress.Excluded_from_Territory__c && objaddress.Targeted__c && oldAddrMap ==null)
        ){
         
                // US1097310 Ends : Added by Kiran
            if(objAddress.Territory__c != null){ 
                  territoriesIds.add(objAddress.Territory__c);
              }
              if(ObjAddress.Census_Tract__c != null){
                  if(mapcensusaddress.containsKey(ObjAddress.Census_Tract__c)){
                    lsttemp = new list<Customer_Address__c>();
                        lsttemp = mapcensusaddress.get(ObjAddress.Census_Tract__c);
                      lsttemp.add(ObjAddress);
                      mapcensusaddress.put(ObjAddress.Census_Tract__c, lsttemp);
                  }else{
                      mapcensusaddress.put(ObjAddress.Census_Tract__c, new List<Customer_Address__c>{ObjAddress});
                  }
                  lstfilteredaddress.add(ObjAddress);
              }
          }
          }
        // to get all assigned plans,users,teams based on territory
        if(mapcensusaddress.size()> 0 ){ 
            for(Plan__c ObjPlan : [Select Assigned_Team__c,Assigned_Team__r.supervisor__c,User__c, Census_Tracts__c ,Plan_Status__c, Territory__c, Createddate, Parameters__c, Number_of_Addresses__c, True_count_of_Addresses__c from  plan__c where Plan_Status__c =: Label.PlanStatusAssigned And Territory__c in : territoriesIds ]){
                for(string objcensus : mapcensusaddress.keyset()){
                    IF((objPlan.Census_Tracts__c).contains(objcensus)){
                        if(!mapCensusPlan.containskey(objcensus)){
                            mapCensusPlan.put(objcensus,objPlan);
                        }else{
                          //To check for latest created plan
                            if(objPlan.Createddate>mapCensusPlan.get(objcensus).createddate){
                                mapCensusPlan.put(objcensus,objPlan);
                            }
                        }
                    }
                }
            }
            // Assigning plans,owner  to filtered address 
            for(Customer_Address__c objAddress : lstfilteredaddress){
              if((mapCensusPlan.get(objAddress.Census_Tract__c) != null && objaddress.Targeted__c && mapCensusPlan.get(objAddress.Census_Tract__c).True_count_of_Addresses__c < Integer.valueOf(sysProps.getSytemProperty('AddressMaxLimitPerTurf','Turf Planning')) ) || 
              (mapCensusPlan.get(objAddress.Census_Tract__c) != null && objaddress.HSI_Only_Address__c && !mapCensusPlan.get(objAddress.Census_Tract__c).Parameters__c.containsIgnoreCase(STR_HSIONLYINCLUDED ) && mapCensusPlan.get(objAddress.Census_Tract__c).True_count_of_Addresses__c < Integer.valueOf(sysProps.getSytemProperty('AddressMaxLimitPerTurf','Turf Planning')))){
                  objAddress.Plan__c = mapCensusPlan.get(objAddress.Census_Tract__c).Id;
                    if(mapCensusPlan.get(ObjAddress.Census_Tract__c).User__c != null){
                      objAddress.OwnerId = mapCensusPlan.get(ObjAddress.Census_Tract__c).User__c;
                    }else{
                      objAddress.OwnerId = mapCensusPlan.get(ObjAddress.Census_Tract__c).Assigned_Team__r.supervisor__c;
                      ObjAddress.Team__c = mapCensusPlan.get(ObjAddress.Census_Tract__c).Assigned_Team__c;
                    }
                 }
             }
       }
        }catch(QueryException qe){system.debug('***Following exception has occured***: '+ qe.getMessage());}
    }
    /**
    * @Description: Updating No.of Addresses and No.of Addresses Currently on Plan attributes on the Plan when the address is added to the Turf
    * @Author: Srini Bhattiprolu, Accenture
    * @Date: 15-Jun-2017
    * @User Story: US1105183 - Direct - Update Plan 'Address Details' when Turf Updates
    * @Param: Trigger.new, Trigger.oldMap
    * @Return: void
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details.Optimazised Code. Added Try Catch
    */
    public static void updatePlanOnAddressAddToTurf(List<Customer_Address__c> newAddrList, Map<Id,Customer_Address__c> oldAddrMap){
        try{
            if(!TurfPlanningController.TurfPlanningPlanUpdate){
                List<Plan__c> planToUpdateList = new List<Plan__c>();
                Set<Id> planIdSet = new Set<Id>();
                for (Customer_Address__c address : newAddrList){
                    if (address.Plan__c != null && oldAddrMap.get(address.Id).Plan__c ==null){
                        planIdSet.add(address.Plan__c);
                    }
                }
                if(!planIdSet.isEmpty()){
                    planToUpdateList = [SELECT Id FROM Plan__c WHERE Id IN: planIdSet 
                                        LIMIT :(Limits.getLimitQueryRows()-Limits.getQueryRows())];
                }               
                if (!planToUpdateList.isEmpty() && !TurfPlanningController.TurfPlanningPlanUpdate){
                    database.update(planToUpdateList, false);
                }
            }
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    } 
    /**
    * @Description: Updating No.of Addresses and No.of Addresses Currently on Plan attributes on the Plan when the address is removed from the Turf
    * @Author: Srini Bhattiprolu, Accenture
    * @Date: 15-Jun-2017
    * @User Story: US1105183 - Direct - Update Plan 'Address Details' when Turf Updates
    * @Param: Trigger.new, Trigger.oldMap
    * @Return: void
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details.Optimazised Code. Added Try Catch
    */
    public static void updatePlanOnAddressRemovalFromTurf(List<Customer_Address__c> newAddrList, Map<Id,Customer_Address__c> oldAddrMap){
        try{
            if(!TurfPlanningController.TurfPlanningPlanUpdate){
                List<Plan__c> planToUpdateList = new List<Plan__c>();
                Set<Id> planIdSet = new Set<Id>();
                for (Customer_Address__c address : newAddrList){
                    if (oldAddrMap.get(address.Id).Plan__c !=null && address.Plan__c == null){
                        planIdSet.add(oldAddrMap.get(address.Id).Plan__c);
                    }
                }
                if(!planIdSet.isEmpty()){
                    planToUpdateList = [SELECT Id FROM Plan__c WHERE Id IN: planIdSet 
                                        LIMIT :(Limits.getLimitQueryRows()-Limits.getQueryRows())];
                }
                if (!planToUpdateList.isEmpty() && !TurfPlanningController.TurfPlanningPlanUpdate){ 
                    PlanTriggerController.dynamicallyRemovedAddress = true;
                    database.update (planToUpdateList, false);      
                }
            }
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }
}