@isTest
public class CarMapViewLightningTest
{
  static testMethod void CarMapViewLightningTest()
 {
    User carManagerUser;
    User carUser;
    Property_Visit__c pv;
    
    PageReference pageRef = Page.CarMapView;
    Test.setCurrentPage(pageRef);
    //User currentUser= [Select Id from User where Id=:UserInfo.getUserId()];
    
    List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
    TriggerSettings__c userTrigger = new TriggerSettings__c();
    userTrigger.Name = 'UserTrigger';
    userTrigger.isActive__c = false;
    triggerSettingsList.add(userTrigger);
    
    List<Variable_Setting__c> variableSettingsList = new List<Variable_Setting__c>();
    
    Variable_Setting__c variableSet2 = new Variable_Setting__c();
    variableSet2.Name = 'Xfinity_CAR_Manager';
    variableSet2.Value__c= 'Xfinity CAR Manager';
    variableSettingsList.add(variableSet2);
    
    Variable_Setting__c variableSet = new Variable_Setting__c();
    variableSet.Name = 'Xfinity_CAR';
    variableSet.Value__c= 'Xfinity CAR';
    variableSettingsList.add(variableSet);
    
    TriggerSettings__c propVisitTrigger = new TriggerSettings__c();
    propVisitTrigger.Name = 'PropertyVisitTrigger';
    propVisitTrigger.isActive__c = true;
    triggerSettingsList.add(propVisitTrigger);
    
    database.insert(triggerSettingsList,false);
    database.insert(variableSettingsList,false);
    
    
    System.runAs(new User(Id=UserInfo.getUserId()))      
    {
       carManagerUser = TestDataUtility.createXfinityCARManagerUser();
    }  
    System.runAs(carManagerUser)  
    {
       carUser = TestDataUtility.createXfinityCARUser();
    }
    System.runAs(carUser)  
    {
    MDU_Property__c prop = TestDataUtility.createProperty();
    database.insert(prop);
    
     Location__c loc = new Location__c();
     loc.name = 'testLocation';
     loc.Longitude__c = 52.0000;
     loc.Latitude__c = 58.0000;
     loc.Geocode_TimeStamp__c = string.valueOfGmt(System.Now());     
     insert loc;
           
      pv=CARActivityTrackerController.checkIn(prop.Id, loc.Longitude__c, loc.Latitude__c);       
    }
    
    CARMapViewLightning controller = new CARMapViewLightning();
    DateTime d = Date.Today() ;
    String cDate =  d.format('yyyy-MM-dd') ;
    CARMapViewLightning.propertyWrapper propWrp = new CARMapViewLightning.propertyWrapper(carUser.Id,cDate,cDate);   
    System.runAs(carManagerUser)  
    {
    CARMapViewLightning.lastReportedData(carUser.Id);
    CARMapViewLightning.dailyLocation(carUser.Id,cDate);
    CARMapViewLightning.getProperyData(carUser.Id,cDate,cDate);
    CARMapViewLightning.userData();
    CARMapViewLightning.userRSADet();
    CARMapViewLightning.userCARs();
    CARMapViewLightning.checkProfile();
    CARMapViewLightning.userDetails();
    }
    
    
  }
}