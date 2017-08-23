@RestResource(urlMapping='/GetPropertyEventServicesREST/*')
/**************
 * Class : GetPropertyEventServicesREST
 * User Story : US989691(XC Property Events: SFDC API & DSM)
 * Auther :Amit Kumar Pradhan  
 ***************/
global without Sharing class GetPropertyEventServicesREST {
  
    /**
     * This is the entry point to access the @HttpGet services within this class.
     **/   
    @HttpGet   
    global static List<Property_Events__c> getPropertyEvent(){
        String userId = RestContext.request.params.get('userId');        
        Set<String> propertyEventIdSet = new Set<String>();        
        List<Property_Event_Team_Member__c> propEventTeamMemberList = new List<Property_Event_Team_Member__c>();
        try{     
            if(userId != null){
                for(Property_Event_Team_Member__c propEventTeamMember : [SELECT Id, Name, Team_Member__c, Property_Event__c FROM Property_Event_Team_Member__c 
                                                                        WHERE Team_Member__c =: userId]){
                    if(propEventTeamMember.Property_Event__c != null){
                        propertyEventIdSet.add(propEventTeamMember.Property_Event__c );
                    }                                 
                }
            }
            if(!propertyEventIdSet.isEmpty()){
                return [SELECT Id, Name, Property__c FROM Property_Events__c WHERE Id IN: propertyEventIdSet];
            }else{
                return null;
            }     
        }catch(Exception e){
            System.debug('Exception occured...'+ e);
            return null;
        }
    }
       
}