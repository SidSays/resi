@RestResource(urlMapping='/NoteSyncServicesREST3/*')
/**
 * NotificationServicesREST.cls
 * Created on: 1/17/2014
 * Author: Doug Beltowski
 * Contains various webservice methods for pulling Notes.
 * Last Modified By : Rahul Prabhakar(US609714 - Performance Issue needs to be fixed for the Rest API classes - NoteSyncServicesREST3.addressAccountNotifications)
 */
global without sharing class NoteSyncServicesREST3 {
    @HttpGet
    global static NoteWrapper addressAccountNotifications() {
        
        Integer RECORD_LIMIT = 500;
        //Integer MAX_RECORDS = 2000;
        Decimal totalAddressRecords = 0;
        NoteWrapper wrapper = new NoteWrapper();
        String planId = RestContext.request.params.get('planId');
        Integer page = Integer.valueOf( RestContext.request.params.get('page') );
        Integer offSet = ( page - 1 ) * RECORD_LIMIT;//It is necessary to subtract one from the page to return the first 500 records.
        
        List<Note> noteList = new List<Note>();     
        Map<id,Plan__c> planMap = new Map<Id, Plan__c>( [SELECT id FROM Plan__c WHERE Parent_Plan__c = :planId OR id = :planId] );
        
        for(AggregateResult r : [SELECT COUNT_DISTINCT(id) total, Plan__c FROM Customer_Address__c WHERE Plan__c IN :planMap.keySet() GROUP BY Plan__c]){
            totalAddressRecords += Integer.valueOf( r.get('total') );//Count all Addresses in a plan.
        }
        //Integer totalAddressRecords = [SELECT Count() FROM Customer_Address__c where Plan__c = :planMap.keySet()];
        
        Map<id,Customer_Address__c> addressMap = new Map<id,Customer_Address__c>( [SELECT id, (SELECT Body, CreatedDate, Title, parentId FROM Notes ORDER BY CreatedDate DESC LIMIT 1) FROM Customer_Address__c WHERE Plan__c IN :planMap.keySet() LIMIT :RECORD_LIMIT OFFSET :offSet] );
        for(Customer_Address__c a : addressMap.values() ){
            wrapper.noteList.addAll( a.Notes );
        }
       
        /*List<Account> accounts = [SELECT id, (SELECT Body, CreatedDate, Title, parentId FROM Notes WHERE CreatedDate = LAST_N_DAYS:7 ORDER BY CreatedDate DESC LIMIT 3) FROM Account WHERE Service_Address__c IN :addressMap.keySet()];
        for(Account a : accounts){
            wrapper.noteList.addAll( a.Notes );
        }*/
        
        wrapper.hasNext = offset + RECORD_LIMIT < totalAddressRecords;
        return wrapper;
    }
    
    global class NoteWrapper{
        
        public List<Note> noteList{get;set;}
        public boolean hasNext{get;set;}
        
        NoteWrapper(){
            noteList = new List<Note>();
        }
    }
}