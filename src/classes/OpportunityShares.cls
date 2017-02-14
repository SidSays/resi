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

/* This AddRegionShare method will provide manual sharing of an opportunity to related property region's public group
    The trigger event is Opportunity Property trigger, after insert, after update */
    public void AddRegionShare(List<Opportunity_Property__c> olist){
    for(PublicGroupRegion__c pg : listgr){
        RegionGroupMap.put(pg.Name,pg.GroupId__c);
    }
    for(Opportunity_Property__c oppo:olist){
        if(oppo.Opportunity_Record_Type__c.equals(system.label.Opportunity_Record_Type_XC)){
            propSet.add(oppo.id);         
        } 
    } 
    List<Opportunity_Property__c> propList = [SELECT id,Opportunity__c,Property_Region__c, Property__r.Assigned_CAR__c from Opportunity_Property__c where id IN:propSet];   
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
        }
            if(!ListOpShare.isEmpty()){
                Database.SaveResult[] jobShareInsertResult = Database.insert(ListOpShare,false);    
            }
    } 
   // End of method AddRegionShare
 
 /* This DelShare method will remove the manual sharing of an opportunity to related property region's public group and Assigned CAR
   The trigger event is Opportunity Property trigger, after delete */
    public void deleteShare(List<Opportunity_Property__c> olist){
        
        Set<Id> delIds= New Set<Id>();
        
        //added due to extra check while deleling the sharing record
        Set<String> regionGroupIdSet = new Set<String>();
        for(PublicGroupRegion__c pg : listgr){
            regionGroupIdSet.add(pg.GroupId__c);
        }
        
        for(Opportunity_Property__c oppo:olist){
            if(oppo.Opportunity_Record_Type__c.equals(system.label.Opportunity_Record_Type_XC)){
                Delids.add(oppo.Opportunity__c);
               } 
        }
        List<OpportunityShare> dellAllShares = [SELECT Id,OpportunityId,RowCause,UserOrGroupId FROM OpportunityShare WHERE OpportunityId IN : delIds AND UserOrGroupId IN:regionGroupIdSet AND RowCause =:'manual'];
        
        if(!dellAllShares.isEmpty()){
            Database.Delete(dellAllShares , false);  
        } 
        
        List<Opportunity_Property__c> newlist = [SELECT Id,name,Opportunity__c,Property__c,Property_Region__c,Opportunity_Record_Type__c FROM Opportunity_Property__c WHERE Opportunity__c IN : Delids];  
       
       AddRegionShare(newlist);            
    }
   // End of method DelShare
   
    
/* This RecalculatePropertyShares method will delete the old and add the new shares on change of region on property*/
    public void RecalculatePropertyShares(Map<Id,MDU_Property__c> oldMap,Map<Id,MDU_Property__c> newMap){
        
        List<MDU_Property__c> newPropValues = newMap.values();
        Set<Id> propReList = new Set<Id>();
        //Remove the related opportunity share records for the old region from OpportunityShare         
        for(MDU_Property__c prop: newMap.values()){
            if(prop.Assigned_CAR__c != oldMap.get(prop.Id).Assigned_CAR__c || prop.Property_Region__c!= oldMap.get(prop.Id).Property_Region__c){
            propReList.add(prop.Id);
            }
        }   
        
        List<Opportunity_Property__c> relatedlist = [SELECT Id,name,Opportunity__c,Property__c,Property_Region__c,Opportunity_Record_Type__c FROM Opportunity_Property__c WHERE Property__c IN : propReList];  
        deleteShare(relatedlist);
    }     
      // End of method RecalculatePropertyShares
      
}