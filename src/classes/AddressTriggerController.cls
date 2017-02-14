/***************************************************************************************************************************************
 * Author              : Amitkumar Bangad
 * Date                : 25-April-2013
 * Description         : Contains Supporting actions for Customer Address Triggers
 * Last Modified       : Malay Desai
 * Requirement         : US583744: Business Partner: Manager hierarchy access
 * Date                : 9-MAR-2015        
***************************************************************************************************************************************/

public class AddressTriggerController {

    /**
    * @Description: This method sets the Disconnect Checkbox to True and clears the Complex Office Checkbox if Criteria are met.
    * @Author: Erin McGee, Acumen Solutions
    * @Date: 23-December-2014
    * @Param: Trigger.New
    * @Return: void.
    * @LastUpdatedBy : Malay Desai, Accenture
    */
    public static void setCheckboxes(List<Customer_Address__c> newAddressList) {
        List<Customer_Address__c> addressList= new List<Customer_Address__c>();
        for(Customer_Address__c addr: newAddressList){
            if(addr.Status__c == 'Former' && !addr.Disconnected__c){
                addr.Disconnected__c=true;
            } else if (addr.Status__c != 'Former' && addr.Disconnected__c){
                addr.Disconnected__c=false;
            }
        }
    }

    /**
    * @Description: This method sets the Address Standard Division.
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 25-April-2013
    * @Param: Trigger.New
    * @Return: void.
    */
    public static void setAddressDivisionAndDisconnected(List<Customer_Address__c> newAddressList) {
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
        }
    }
    
    /**
    * @Description: US583744: Business Partner: Manager hierarchy access
    * @Author: Radhika Bansal, Accenture
    * @Date: 3-Nov-2015
    * @Param: Trigger.New
    * @Return: void
    */

    public static void addressShareAccess(List<Customer_Address__c> addressdata){
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
            }
        }
        if(!addShares.isEmpty()){
            Database.SaveResult[] CoachingShareInsertResult = Database.insert(addShares ,false);
        }
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
    */
    public static void setPropertyToAddress(List<Customer_Address__c> address){
         
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
     }
    /**
    * @Description: To remove the Property__c lookup on Address records
    * @Author: Ashish Srivastava, Accenture
    * @Date: 18-March-2016
    * @Param: Trigger.new
    * @Return: null
    */
     public static void removePropertyFromAddress(List<Customer_Address__c> addressList){
         for(Customer_Address__c address : addressList){
             if(address.Property_Code__c == null || address.Corp__c== null || address.Region__c == null){
                 address.property__c = null;
              }
    }
   }
 
  
  public static void setIsNewOnAddress(List<Customer_Address__c> addressList){
      for(Customer_Address__c address : addressList){
          address.Is_New__c = true;
      }
  }
    public static void setFlagOnRemovingParentAddress(List<Customer_Address__c> addressList, Map<Id,Customer_Address__c> oldAddressMap){
        for(Customer_Address__c address : addressList){
            if(address.Parent_Address__c == null && oldAddressMap.get(address.Id).Parent_Address__c != null){
                address.Is_New__c = true;
            }
      }
  }
}