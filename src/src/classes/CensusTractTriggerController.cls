/**
    * @Description: This class will be controller class for all the operation happening from the Census tract trigger.
    * @Author: Amit Kumar - Accenture
    * @Date: 14 May 2017 
    * @Param: NA
    * @return: NA
*/    
public class CensusTractTriggerController {

/**
    * Name: setterritorychanged
    * @Description: This method will be set the territory change flag on the Census tract record if there is any update happen on Territory field.
    * @Author: Accenture
    * @Date: 11 May 2017 
    * @Param: list of Census tarct record,trigger.oldmap
    * @return: NA
*/    
    public static void setterritorychanged(list<CensusTract__c> lstcensus, map<Id,CensusTract__c> oldcensusrecord){
    	set<id> setoldterritories = new set<id>();
    	map<id, string> mapterritories = new map<id, string>();
    	for(id objid:oldcensusrecord.keyset()){
    		if(oldcensusrecord.get(objid).Territory__c !=null){
    			setoldterritories.add(oldcensusrecord.get(objid).Territory__c);
    		}
    	}
    	if(setoldterritories!=null){
    		 for(Territory__c objterrtory:[Select id, Territory_Region__c from Territory__c where id IN:setoldterritories ]){
    		 	mapterritories.put(objterrtory.id,objterrtory.Territory_Region__c);
    		 }
    		 
    	}
    	for(CensusTract__c objcensus:lstcensus){
        	if((oldcensusrecord.get(objcensus.Id)).Territory__c !=objcensus.Territory__c ){
            	objcensus.Territory_Changed__c = true;
            }
            if(objcensus.Territory__c==null && (oldcensusrecord.get(objcensus.Id)).Territory__c !=objcensus.Territory__c ){
            	objcensus.Old_Territory_Region__c = mapterritories.get(((oldcensusrecord.get(objcensus.Id)).Territory__c));
            }
            if(objcensus.Territory__c!=null && (oldcensusrecord.get(objcensus.Id)).Territory__c ==null){
            	objcensus.Old_Territory_Region__c = '';
            }
        } 
    }
}