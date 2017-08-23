// Type   : Managed Apex Sharing for Opportunity
// Author : Siddharth Sinha
// Date   : 14-July-2016
// Purpose: To provide manual sharing for opportunity based upon different conditions by way of different methods.

public without sharing class OpportunityShares{

//  Declarations
    Set<Id> propSet = new Set<Id>();
    Map<String,Id> RegionGroupMap = new Map<String,Id>();
    List<PublicGroupRegion__c> listgr =PublicGroupRegion__c.getall().values();
    List<OpportunityShare> ListOpShare = new List<OpportunityShare>();
     //START US1149452
    List<Region_Profile_PublicGroups__c> regionProfileVsGroupNameCS = Region_Profile_PublicGroups__c.getAll().values();
    Map<String, String> regionVsGroupName = new Map<String, String>();
    Map<String, Id> groupNameVsId  = new Map<String, Id>();
     //END US1149452
	/**
    * @Description  : AddRegionShare method will provide manual sharing of an opportunity to related property region's public group
   					  The trigger event is Opportunity Property trigger, after insert, after update  
    				 - Share Opportunity Owned by XC AE Contactor with CAR Manager Regional Public group
    * @UserStrory : US1149452 XC - Contractor Roles
    * @Last Modify by : Suchita Sharma
    * @Date   : 24-July-2017
    * @Return : void
    */
    public void AddRegionShare(List<Opportunity_Property__c> olist){
      
    for(PublicGroupRegion__c pg : listgr){
        RegionGroupMap.put(pg.Name,pg.GroupId__c);
    }
    for(Opportunity_Property__c oppo:olist){
        if(oppo.Opportunity_Record_Type__c.equals(system.label.Opportunity_Record_Type_XC)){
            propSet.add(oppo.id);         
        }       
    } 
    //START US1149452
    for(Region_Profile_PublicGroups__c cs : regionProfileVsGroupNameCS){                
            if(cs.Profile_Channel__c.equalsIgnoreCase(system.label.CAR_Manager)){ //To get only CAR Manger Regional Group
                regionVsGroupName.put(cs.Region__c, cs.Public_Group_Name__c);
            }
        }
        
        for(Group grp : [SELECT id, Name FROM Group WHERE Name IN :regionVsGroupName.values()]){
            groupNameVsId.put(grp.Name, grp.Id);                
        }
    //END US1149452
    List<Opportunity_Property__c> propList = [SELECT id,Opportunity__c,Property_Region__c, Property__r.Assigned_CAR__c, Opportunity__r.AssignedAE_ID__c,Opportunity__r.AssignedAE_ID__r.Profile.Name from Opportunity_Property__c where id IN:propSet  
    											LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];   
    // Share the opportunity with this Public Group as a Manual Sharing in Read Only Mode
        for(Opportunity_Property__c opi : propList){
            if(RegionGroupMap.get(opi.Property_Region__c) != null){
                OpportunityShare regionShare = new OpportunityShare();
                regionShare.OpportunityId = opi.Opportunity__c;       
                regionShare.UserOrGroupId = RegionGroupMap.get(opi.Property_Region__c);
                regionShare.OpportunityAccessLevel = 'Read';
                ListOpShare.add(regionShare);
            }
            if(opi.Property__r.Assigned_CAR__c != null){
                OpportunityShare CARShare = new OpportunityShare();
                CARShare.OpportunityId = opi.Opportunity__c;       
                CARShare.UserOrGroupId = opi.Property__r.Assigned_CAR__c;
                CARShare.OpportunityAccessLevel = 'Read';
                ListOpShare.add(CARShare);
            }
            //START US1149452
            if(opi.Opportunity__r.AssignedAE_ID__c != null && opi.Opportunity__r.AssignedAE_ID__r.Profile.Name == system.label.XC_AE_Contractors){
                OpportunityShare contractorOppCARMangerGrpShare = new OpportunityShare();
                contractorOppCARMangerGrpShare.OpportunityId = opi.Opportunity__c;       
                contractorOppCARMangerGrpShare.UserOrGroupId = groupNameVsId.get(regionVsGroupName.get(opi.Property_Region__c));
                contractorOppCARMangerGrpShare.OpportunityAccessLevel = system.label.OpportunityEditAccess;                
                ListOpShare.add(contractorOppCARMangerGrpShare);
            }
            //END US1149452
        }
       
        if(!ListOpShare.isEmpty()){
            Database.SaveResult[] jobShareInsertResult = Database.insert(ListOpShare,false);    
        }
    } 
   // End of method AddRegionShare
 
    /**
    * @Description  : This DelShare method will remove the manual sharing of an opportunity to related property region's public group and Assigned CAR
   					  The trigger event is Opportunity Property trigger, after delete 
    				 - delete sharing of Opportunity Owned by XC AE Contactor with CAR Manager Regional Public group
    * @UserStrory : US1149452 XC - Contractor Roles
    * @Last Modify by : Suchita Sharma
    * @Date   : 24-July-2017
    * @Return : void
    */
    public void deleteShare(List<Opportunity_Property__c> olist,Map<Id,String> proprtyIdRegionMap){
        
        Set<Id> delIds= New Set<Id>();
        //START US1149452       
        //Added due to extra check while deleting the sharing record        
        for(Region_Profile_PublicGroups__c cs : regionProfileVsGroupNameCS){                
            if(cs.Profile_Channel__c.equalsIgnoreCase(system.label.CAR_Manager)){ //To get only CAR Manger Regional Group
                regionVsGroupName.put(cs.Region__c, cs.Public_Group_Name__c);
            }
        }
        
        for(Group grp : [SELECT id, Name FROM Group WHERE Name IN :regionVsGroupName.values() LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            groupNameVsId.put(grp.Name, grp.Id);                
        }
        Map<String,String> opportunityIdGroupId = new Map<String,String>();
        
        for(Opportunity_Property__c oppo:olist){
            if(oppo.Opportunity_Record_Type__c.equals(system.label.Opportunity_Record_Type_XC)){
                Delids.add(oppo.Opportunity__c);
                if(oppo.Opportunity__r.AssignedAE_ID__c != null && oppo.Opportunity__r.AssignedAE_ID__r.Profile.Name == system.label.XC_AE_Contractors){
                    if(!proprtyIdRegionMap.isEmpty()){
                        opportunityIdGroupId.put(oppo.Opportunity__c,groupNameVsId.get(regionVsGroupName.get(proprtyIdRegionMap.get(oppo.Property__c))));
                    }else{
                        opportunityIdGroupId.put(oppo.Opportunity__c,groupNameVsId.get(regionVsGroupName.get(oppo.Property_Region__c)));
                    }
                }
            } 
        }   
        List<OpportunityShare> dellAllShares = [SELECT Id,OpportunityId,RowCause,UserOrGroupId FROM OpportunityShare WHERE 
        												(OpportunityId IN : delIds AND (OpportunityAccessLevel = 'Read' AND RowCause =:'manual')) 
        												or (OpportunityId IN : opportunityIdGroupId.keySet() AND UserOrGroupId IN : OpportunityIdGroupId.values())
        												 LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        
        if(!dellAllShares.isEmpty()){
            Database.Delete(dellAllShares , false);  
        } 
        
        List<Opportunity_Property__c> newlist = [SELECT Id,name,Opportunity__c,Property__c,Property_Region__c,Opportunity_Record_Type__c,Opportunity__r.AssignedAE_ID__r.Profile.Name
        												 FROM Opportunity_Property__c WHERE Opportunity__c IN : Delids 
        												  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];  
       
       AddRegionShare(newlist);            
    }
   // End of method DelShare
  
   /**
    * @Description  : This RecalculatePropertyShares method will delete the old and add the new shares on change of region on property
    				 - delete sharing of Opportunity Owned by XC AE Contactor with CAR Manager Regional Public group
    * @UserStrory : US1149452 XC - Contractor Roles
    * @Last Modify by : Suchita Sharma
    * @Date   : 24-July-2017
    * @Return : void
    */
    public void RecalculatePropertyShares(Map<Id,MDU_Property__c> oldMap,Map<Id,MDU_Property__c> newMap){
        Map<Id,String> proprtyIdRegionMap = new Map<Id,String>();
        List<MDU_Property__c> newPropValues = newMap.values();
        Set<Id> propReList = new Set<Id>();
        //Remove the related opportunity share records for the old region from OpportunityShare         
        for(MDU_Property__c prop: newMap.values()){
            if(prop.Assigned_CAR__c != oldMap.get(prop.Id).Assigned_CAR__c || prop.Property_Region__c!= oldMap.get(prop.Id).Property_Region__c){
            propReList.add(prop.Id);
            //START US1149452
            proprtyIdRegionMap.put(prop.Id,oldMap.get(prop.Id).Property_Region__c);
            //END US1149452
            }
            
        }   
        
        List<Opportunity_Property__c> relatedlist = [SELECT Id,name,Opportunity__c,Property__c,Property_Region__c,Opportunity_Record_Type__c,Opportunity__r.AssignedAE_ID__r.Profile.Name FROM Opportunity_Property__c WHERE Property__c IN : propReList];  
        
        if(!relatedlist.isEmpty()){
        	deleteShare(relatedlist,proprtyIdRegionMap);	// US1149452 added new parameter to get old region
        }        
    }     
      // End of method RecalculatePropertyShares
    
}