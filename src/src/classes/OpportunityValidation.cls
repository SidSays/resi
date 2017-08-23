/*Type   : Validation on Opportunity for XC AE Contractor's region US738562
* Author : Siddharth Sinha
* Date   : 27-July-2016
* Purpose: To provide validation on logged in user to assign Opportunity outside of Contractor’s region
*/  
public with sharing class OpportunityValidation{

    public Static void AEvalidation(List<Opportunity> oppList){
        // Variable Declarations
        String errMsg = System.label.Opportunity_AE_Change_Validation;
        User currentUser = [SELECT Id,Region__c,Profile_Name_Text__c,Profile.Name FROM User WHERE Id = : UserInfo.getUserId()];
        String userRegion = currentUser.Region__c;
        Map<Id,Set<String>> contractorRegionMap = new Map<Id,Set<String>>();
        Boolean bypass=false;
        Set<Id> AEcontractor = new Set<Id>();
        Set<Id> AssignAEIdSet= new Set<Id>();

        // Add all the opportunity contractors in a Set
        for(Opportunity opp1 :oppList){
            AssignAEIdSet.add(opp1.AssignedAE_ID__c);
        }
        
        for(user u : [Select id,ProfileId,Profile.Name from user where id in :AssignAEIdSet and Profile.Name = 'XC AE Contractors']){
           AEcontractor.add(u.Id);
        }
      
        if(!AEcontractor.isEmpty()){
            if(currentUser.Profile.Name.equalsignorecase(system.label.SystemAdminProfileName)){                
                bypass=true;
            }else{              
                for(Contractor_Region_Mapping__c crm: [select AE_Contractor__c,Region__c from Contractor_Region_Mapping__c where AE_Contractor__c IN :AEcontractor]){
                    Set<String> temp = new Set<String>();
                    
                    if(contractorRegionMap.get(crm.AE_Contractor__c)!=null){
                        temp=contractorRegionMap.get(crm.AE_Contractor__c);
                        temp.add(crm.Region__c);
                    }else{
                        temp.add(crm.Region__c);
                    }
                    contractorRegionMap.put(crm.AE_Contractor__c,temp);             
                }
                if(!contractorRegionMap.isEmpty()){
                    for(Opportunity oppObj : oppList){
                        if(contractorRegionMap.get(oppObj.AssignedAE_ID__c) != null){
                            if(!contractorRegionMap.get(oppObj.AssignedAE_ID__c).contains(userRegion)){
                                oppObj.adderror(errMsg);
                            }       
                        }else if( AEcontractor.contains(oppObj.AssignedAE_ID__c)){                          
                             oppObj.adderror(errMsg);
                        }
                    }               
                }else if(contractorRegionMap.isEmpty()){
                    for(Opportunity oppObj : oppList){
                        if( AEcontractor.contains(oppObj.AssignedAE_ID__c)){ 
                            oppObj.adderror(System.label.Opportunity_AE_Change_Validation1);
                        }
                    }
                }
            }
        }           
    }
}