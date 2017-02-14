@isTest 
public class UnassignedpropertiestoCARsExtensionTest{
      public static testMethod void UnassignCAR(){
            List<MDU_Property__c> properties = new List<MDU_Property__c>();
             Integer rowToRemove = 1;
            TestDataUtility.createCustomSettingRecords();
            PageReference pageRef = Page.UnassignPropertiestoCARs;
            
        
            User userObj = TestDataUtility.createRSAUser();
            User userObj2 = TestDataUtility.createXfinityCARUser();
            userObj2.ManagerId = userObj.id;
        
            User userObj3 = TestDataUtility.createXfinityCARUser();
            userObj3.ManagerId = userObj.id;
        
            User userObj4 = TestDataUtility.createXfinityCARUser();
            userObj4.ManagerId = userObj.id;
        
            MDU_Property__c prop = TestDataUtility.createProperty();
            prop.Assigned_CAR__c= userObj2.Id;
            prop.Name = 'Property11';
            prop.OwnerId = userObj.Id;
         
            insert prop;
            ApexPages.StandardController ssc = new ApexPages.StandardController(prop);
            UnassignpropertiestoCARsExtension controller = new UnassignpropertiestoCARsExtension();
        
            MDU_Property__c prop1 = TestDataUtility.createProperty();
            prop1.Name = 'Test Property1';
            insert prop1;
            
             Test.startTest();
                System.runAS(userObj){                  
                pageRef.getParameters().put('records' , prop.id);
                Test.setCurrentPage(pageRef);
                
                controller.unassignCar();
                
                controller.cancelAssignment();
                controller.removeRowFromPropertyList();
                
               }
        Test.stopTest();
      }
      
    /*  public static testMethod void AssignCARManager(){
   Integer rowToRemove = 0;
        List<MDU_Property__c> properties = new List<MDU_Property__c>();
        TestDataUtility.createCustomSettingRecords();
        PageReference pageRef = Page.AssignCAR;
        User userObj = TestDataUtility.createXfinityCARManagerUser();
        User userObj3 = TestDataUtility.createXfinityCARUser();
        userObj3.ManagerId = userObj.id;
        MDU_Property__c prop = TestDataUtility.createProperty();
        prop.Assigned_CAR__c= userObj3.Id;
        prop.Name = 'Test Property';
        insert prop;
        ApexPages.StandardController ssc = new ApexPages.StandardController(prop);
         UnassignpropertiestoCARsExtension controller = new UnassignpropertiestoCARsExtension();
        Test.startTest();
            System.runAS(userObj){           
               pageRef.getParameters().put('records' , prop.id);
                Test.setCurrentPage(pageRef);
                
                controller.unassignCar();
                                controller.cancelAssignment();
                controller.removeRowFromPropertyList();

              }
        Test.stopTest();
      }*/
}