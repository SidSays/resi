@RestResource(urlMapping='/AddDSMFilterServiceREST/*')
global without sharing class AddDSMFilterServiceREST {

    @HttpPost
    global static DSMFilterReturnWrapper AddDSMFilter(DSMFilterWrapper filterWrapper){
        
        DSM_Filter__c filter = new DSM_Filter__c();
        filter.Name = filterWrapper.Name;
        filter.OwnerId = filterWrapper.ownerId;
        filter.Timestamp__c = filterWrapper.timeStamp;
        filter.Version__c = filterWrapper.version;
        filter.FilterJSON__c = filterWrapper.filterJSON;
        filter.FilterKey__c = filterWrapper.ownerId + filterWrapper.Name;
        
        DSMFilterReturnWrapper returnWrapper = new DSMFilterReturnWrapper();
        
        try{
            upsert filter FilterKey__c;
            returnWrapper.success = true;
            returnWrapper.filterId = filter.Id;            
        } catch(DMLException ex){
            returnWrapper.success = false;
            System.debug('Following exception occurred :'+ex.getMessage());
            return returnWrapper;
        } 
            return returnWrapper;
        
        
    }
    global Class DSMFilterWrapper{
        
        global String name;
        global String ownerId;
        global String timeStamp;
        global String version;
        global String filterJSON;
    }
    global Class DSMFilterReturnWrapper{
       global Boolean success;
       global String filterId;
    }
}