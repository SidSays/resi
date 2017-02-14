/**
  * Class Name: CarMapViewController
  * Author: Pranjal Singh, Accenture
  * Date: 05-Jan-2016
  * User Story:US606813
  * Description: Contains supporting actions for VF page CarMapView to display CAR locations on Map
    */
 global class CarMapViewController {
     
    public static Set<Id> resultId;
 
    @RemoteAction    
    global static List<user> userData(){
    List<user> userResult = [Select Id, Name  from user where managerId=:userinfo.getUserId() and IsActive=true];
    return userResult;
   
    }
    
    @RemoteAction
    public static List<User> userDet(){
        
    User region = [select region__c from user where id=:userinfo.getuserId()];
    
    //List<user> userDetail = [Select Id, Name  from user where managerId=:userinfo.getUserId() and IsActive=true and Profile.name='Xfinity CAR Manager' and region__c =: region.region__c];
    List<user> userDetail = [Select Id, Name  from user where IsActive=true and Profile.name='Xfinity CAR Manager' and region__c =: region.region__c];
    resultId = new Set<Id>();
    for(User usr : userDetail){
        resultId.add(usr.Id);
    }
    return userDetail;
    
    
    }

    @RemoteAction    
    global static List<user> userData1(){ 
     User region = [select region__c from user where id=:userinfo.getuserId()];
    
    List<user> userDetail = [Select Id, Name  from user where managerId=:userinfo.getUserId() and IsActive=true and Profile.name='Xfinity CAR Manager' and region__c =: region.region__c];
    resultId = new Set<Id>();
    for(User usr : userDetail){
        resultId.add(usr.Id);
    }
    List<user> userResult1 = [Select Id, Name  from user where manager.Id IN :resultId and IsActive=true and Profile.Name='Xfinity CAR'];
    return userResult1;
    
    }
    
    @RemoteAction    
    global static List<boolean> checkProfile(){
    List<boolean> profCheck = new List<boolean>();
    String profile = [select id,name from Profile where id=:userinfo.getProfileId() limit 1].name;
        if(profile=='Regional System Admin (RSA)'){
            profCheck.add(true);
        }
        else{
            profCheck.add(false);
        }
    return profCheck;   
    }
    
    @RemoteAction    
    global static List<user> mgrData(Id mgrId){ 
    system.debug('ID' +mgrId);
        List<user> userResult1 = [Select Id,name from user where manager.Id=:mgrId and IsActive=true and Profile.Name='Xfinity CAR'];
    return userResult1;
    
    }
    
    @RemoteAction    
    global static propertyWrapper  propVisitData(ID selectedRep , String startDate, String endDate){
        propertyWrapper objpropertyWrapper = new propertyWrapper(selectedRep , startDate, endDate);
        return objpropertyWrapper;
    }
    
    @RemoteAction    
    global static List<Location__c> locationData1(ID selectedRep , String createdDate){
    Datetime dt1;
    Datetime dt2;
    String [] dateParts= createdDate.split('/');
    String fromD;
    if(dateParts.size()==3){
         String month  = dateParts[0];
         String day  = dateParts[1];
         String year = dateParts[2];
     fromD = dateParts[2]+'-'+dateParts[0]+'-'+dateParts[1];
     dt1 = Datetime.newInstance(date.valueOf(fromD), Time.newInstance(0, 0, 0, 0));
     dt2 = Datetime.newInstance(date.valueOf(fromD), Time.newInstance(23, 59, 59, 0));
    }
    List<Location__c> locationResult = [Select Id,Geocode_TimeStamp__c, Timestamp__c ,Latitude__c, Longitude__c  from Location__c where OwnerId=: selectedRep and CreatedDate > : dt1 and CreatedDate < : dt2 ORDER BY CreatedDate ASC];
    return locationResult;
    }
      
    @RemoteAction    
    global static List<Location__c> locationData(ID selectedRep){
    DateTime dt1 = Datetime.newInstance(date.valueOf(System.today()), Time.newInstance(0, 0, 0, 0));
    DateTime dt2 = Datetime.newInstance(date.valueOf(System.today()), Time.newInstance(23, 59, 59, 0));
        
    List<Location__c> locationResult = [Select Id,Geocode_TimeStamp__c, Timestamp__c,Latitude__c, Longitude__c  from Location__c where OwnerId=: selectedRep and CreatedDate > : dt1 and CreatedDate < : dt2 ORDER BY Geocode_TimeStamp__c DESC limit 1];
    return locationResult;
    }
    
    
    global class propertyWrapper{
        public List<Property_Visit__c> propVisit;
        public List<MDU_Property__c> property;  
        Set<Id> propId = new Set<Id>();
        Datetime dt1;
        Datetime dt2;
        String fromD;
        public propertyWrapper(ID selectedRep , String createdDate, String endDate){
            String [] dateParts= createdDate.split('/');
            if(dateParts.size()==3){
             String month  = dateParts[0];
             String day  = dateParts[1];
             String year = dateParts[2];
             fromD = dateParts[2]+'-'+dateParts[0]+'-'+dateParts[1];
             dt1 = Datetime.newInstance(date.valueOf(fromD), Time.newInstance(0, 0, 0, 0));
             dt2 = Datetime.newInstance(date.valueOf(system.today()), Time.newInstance(23, 59, 59, 0));
            }
            dateParts= endDate.split('/');
            if(dateParts.size()==3){
             String month  = dateParts[0];
             String day  = dateParts[1];
             String year = dateParts[2];
             fromD = dateParts[2]+'-'+dateParts[0]+'-'+dateParts[1];
             dt2 = Datetime.newInstance(date.valueOf(fromD), Time.newInstance(23, 59, 59, 0));
            }
            
            propVisit = ([select Id,Property__c,Start_Date_Time__c,Visit_Location__Latitude__s,Visit_Location__Longitude__s,End_Date_Time__c,Time_Spent__c,Distance_from_poperty__c from Property_Visit__c where createdById=: selectedRep and   CreatedDate >= : dt1 and CreatedDate <= : dt2 order by CreatedDate ASC]);
            for(Property_Visit__c proptemp :propVisit){
                propId.add(proptemp.Property__c);
            }
            property = [select Id, Name,Property_Location__Latitude__s,Property_Location__Longitude__s from MDU_Property__c where Id IN : propId order By name ASC];
              
        }
    }
}