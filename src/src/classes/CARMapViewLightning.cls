public without sharing class CARMapViewLightning{
    
    @AuraEnabled
    public static propertyWrapper getProperyData(String selectedRep , String createdDate, String endDate){
        return (new propertyWrapper(selectedRep , createdDate, endDate));
    }
    
    @AuraEnabled
    public static boolean checkProfile()
    {
        Boolean profCheck;
        String profile = [select id,name from Profile where id=:userinfo.getProfileId() limit 1].name;
        String RSA =System.Label.RSA_Profile_Name; 
        if(profile==RSA){
            profCheck =true;
        }
        else{
            profCheck=false;
        }
        return profCheck;   
    }
    
    @AuraEnabled    
    public static List<user> userData(){
      
    	List<user> userResult = [SELECT Id, Name  FROM user 
                                 WHERE managerId=:userinfo.getUserId() 
                                 AND IsActive=True 
                                 ORDER BY Name];        
	    return userResult;
    }
    
    @AuraEnabled
    public static List<User> userRSADet(){
     	List<String> resultId = new List<String>(); 
   
        User region = [select region__c from user where id=:userinfo.getuserId()];
    	String CARManager = Variable_Setting__c.getInstance('Xfinity_CAR_Manager').Value__c;
	    List<user> userDetail = [Select Id, Name  from User 
                                 WHERE IsActive=true and Profile.name=:CARManager
                                 AND region__c =: region.region__c ];
        for(User usr : userDetail){
	        resultId.add(usr.Id);
	    }
        String CAR = Variable_Setting__c.getInstance('Xfinity_CAR').Value__c;
   		List<user> userResult1 = [Select Id, Name  from user where manager.Id IN :resultId 
                                  AND IsActive=true and Profile.Name=:CAR 
                                  ORDER BY Name ASC];
        
        return userResult1;
    }
    

    // For validations
    @AuraEnabled    
    public static List<user> userCARs(){ 
        List<user> userResult1 = [SELECT Id, Name  from User where manager.Id = :userinfo.getuserId() 
                                  AND IsActive=true and Profile.Name='Xfinity CAR' 
                                  ORDER BY Name ASC];
        return userResult1;
    }
    
    @AuraEnabled
    public static List<Location__c> lastReportedData(String selectedRep){
        try{
        DateTime dt1 = Datetime.newInstance(date.valueOf(System.today()), Time.newInstance(0, 0, 0, 0));
        DateTime dt2 = Datetime.newInstance(date.valueOf(System.today()), Time.newInstance(23, 59, 59, 0));
        List<Location__c> locationResult = [Select Id,Geocode_TimeStamp__c, Timestamp__c,Latitude__c, Longitude__c 
                                            from Location__c
                                            where OwnerId =: selectedRep and CreatedDate > : dt1 and
                                            CreatedDate < : dt2 ORDER BY Geocode_TimeStamp__c DESC limit 1];

            return (locationResult != null && locationResult.size() > 0)?locationResult:null;

        }catch(Exception e){
            return null;
        }
    }
    
    @AuraEnabled
    public static List<Location__c> dailyLocation(String selectedRep , String createdDate){
        Datetime dt1 = Datetime.newInstance(date.valueOf(createdDate), Time.newInstance(0, 0, 0, 0));
        Datetime dt2 = Datetime.newInstance(date.valueOf(createdDate), Time.newInstance(23, 59, 59, 0));

        List<Location__c> locationResult = [Select Id,Geocode_TimeStamp__c, Timestamp__c ,Latitude__c, Longitude__c 
                                            from Location__c where OwnerId =: selectedRep and CreatedDate > : dt1 
                                            and CreatedDate < : dt2 ORDER BY CreatedDate ASC];
        return locationResult;
    }
    
    
    @AuraEnabled    
    public static List<user> userDetails(){ 
        Set<Id> resultId;
        User region = [select region__c from user where id=:userinfo.getuserId()];
        
        // To get the users whose manager is the current logged in user and whose profile is Xfinity CAR Manager
        List<user> userDetail = [Select Id, Name  from User where managerId=:userinfo.getUserId() 
                                 AND IsActive=true and Profile.name='Xfinity CAR Manager'
                                ORDER BY Name ASC];
        resultId = new Set<Id>();
        for(User usr : userDetail){
            resultId.add(usr.Id);
        }
        List<user> userResult1 = [Select Id, Name  from user where manager.Id IN :resultId and IsActive=true 
                                  AND Profile.Name='Xfinity CAR' ORDER By Name ASC];
        return userResult1;
    }
    
    public class propertyWrapper{
        @AuraEnabled 
        public List<Property_Visit__c> propVisits;
        @AuraEnabled 
        public List<MDU_Property__c> properties;  
        @AuraEnabled 
        public List<Property_Visit__c> starPropVisits;
        @AuraEnabled 
        public List<Property_Visit__c> withoutStarPropVisits;
        @AuraEnabled
        public List<MDU_Property__c> filteredPropList;
        Set<Id> propId = new Set<Id>();
        Datetime dt1;
        Datetime dt2;
        String fromD;
        public propertyWrapper(String selectedRep , String createdDate, String endDate){
            
            starPropVisits = new List<Property_Visit__c>();
            withoutStarPropVisits = new List<Property_Visit__c>();
            filteredPropList = new List<MDU_Property__c>();
            
            dt1 = Datetime.newInstance(date.valueOf(createdDate), Time.newInstance(0, 0, 0, 0));
            dt2 = Datetime.newInstance(date.valueOf(endDate), Time.newInstance(23, 59, 59, 0));
            
            propVisits = ([select Id,Name, Property__c,Property__r.Name, Property__r.Property_Location__Latitude__s,
                           Property__r.Property_Location__Longitude__s,
                           Start_Date_Time__c,Visit_Location__Latitude__s,
                           Visit_Location__Longitude__s,CreatedDate,SystemModstamp,
                           End_Date_Time__c,Time_Spent__c,Distance_from_poperty__c 
                           from Property_Visit__c where
                           Visit_Location__Latitude__s != null AND
                           Visit_Location__Longitude__s != null AND
                           CreatedById=: selectedRep and   CreatedDate >= : dt1 and
                          CreatedDate <= : dt2 
                           order by CreatedDate ASC ]);            
            
            for(Property_Visit__c proptemp :propVisits){
                propId.add(proptemp.Property__c);
                
                if(proptemp.Distance_from_poperty__c <= Decimal.valueOf(System.Label.Property_Visit_Distance)){                
                    starPropVisits.add(proptemp);
                }
                else{
                    withoutStarPropVisits.add(proptemp);
                }
            }
            properties = [select Id, Name,Property_Location__Latitude__s,Property_Location__Longitude__s from MDU_Property__c where Id IN : propId order By name ASC];
        }
    }    
}