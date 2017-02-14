public class KnockWithGeolocation {
    
    @AuraEnabled
    public static Task createKnock(String addressId ){
        Task obj = new Task(Customer_Address__c = addressId);
        //C Xobj.RecordType.ID = '012G0000000qgYG';
        insert obj;
        System.debug('obj'+obj);
        return obj;
    }
    
    @AuraEnabled
    public static Task updateKnock(Decimal lat, Decimal longi, String knockId){
       system.debug('lat '+lat + ' longi '+ longi+' knockId '+ knockId);
      Task knockRecord =  [Select Id,Knock_Start_Location__c,Knock_Start_Location__Latitude__s,
                           Knock_Start_Location__Longitude__s from Task where Id = :knockId];
        knockRecord.Knock_Start_Location__Latitude__s = lat;
        knockRecord.Knock_Start_Location__Longitude__s = longi;
        update knockRecord;
        return knockRecord;
        
    }
    
    @AuraEnabled
    public static void deleteKnock(Task knock){
        delete knock;
    }
   

}