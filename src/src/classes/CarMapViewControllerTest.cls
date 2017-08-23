@isTest
public class CarMapViewControllerTest
{
  static testMethod void CarMapViewControllerTest()
 {
    User carManagerUser;
    User carUser;
    Property_Visit__c pv;
    
    PageReference pageRef = Page.CarMapView;
    Test.setCurrentPage(pageRef);
    User currentUser= [Select Id from User where Id=:UserInfo.getUserId()];
    
    List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
    TriggerSettings__c userTrigger = new TriggerSettings__c();
    userTrigger.Name = 'UserTrigger';
    userTrigger.isActive__c = false;
    triggerSettingsList.add(userTrigger);
    insert triggerSettingsList;
    
    
    System.runAs(currentUser)      
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
    
    CarMapViewController controller = new CarMapViewController();
    DateTime d = Date.Today() ;
    String cDate =  d.format('MM/dd/yyyy') ;
    CarMapViewController.propertyWrapper propWrp = new CarMapViewController.propertyWrapper(carUser.Id,cDate,cDate);   
    System.runAs(carManagerUser)  
    {
    CarMapViewController.locationData(carUser.Id);
    CarMapViewController.locationData1(carUser.Id,cDate);
    CarMapViewController.propVisitData(carUser.Id,cDate,cDate);
    CarMapViewController.userData();
    CarMapViewController.userDet();
    CarMapViewController.userData1();
    CarMapViewController.checkProfile();
    CarMapViewController.mgrData(carManagerUser.Id);
    }
    
    
  }
}