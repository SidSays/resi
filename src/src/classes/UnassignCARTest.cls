@isTest
public class UnassignCARTest{
      public static testMethod void UnassignCAR(){
            List<MDU_Property__c> properties = new List<MDU_Property__c>();
         	CARMgrPublicGrpRgn__c cs = new CARMgrPublicGrpRgn__c();
	    	cs.Name = '1';
	    	cs.Region__c = 'Freedom Market';
	    	cs.Group_Name__c = 'CAR Managers - Freedom';
	    	
	    	insert cs;
            TestDataUtility.createCustomSettingRecords();
            PageReference pageRef = Page.UnassignCAR;
            
        
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
         
            insert prop;
            ApexPages.StandardController ssc = new ApexPages.StandardController(prop);
            UnassignCAR controller = new UnassignCAR(ssc);
        
            MDU_Property__c prop1 = TestDataUtility.createProperty();
            prop1.Name = 'Test Property1';
            insert prop1;
            
             Test.startTest();
                System.runAS(userObj){                  
                pageRef.getParameters().put('records' , prop.id);
                Test.setCurrentPage(pageRef);
                controller.Unassign();
               // controller.selectedCAR = 'userObj2';
                controller.selectedCAR = '--None--';           
                controller.Cancel();
               }
        Test.stopTest();
      }
      
      public static testMethod void AssignCARManager(){
   		
   		CARMgrPublicGrpRgn__c cs = new CARMgrPublicGrpRgn__c();
    	cs.Name = '1';
    	cs.Region__c = 'Freedom Market';
    	cs.Group_Name__c = 'CAR Managers - Freedom';
    	
    	insert cs;
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
        UnassignCAR controller = new UnassignCAR(ssc);
        Test.startTest();
            System.runAS(userObj){           
               pageRef.getParameters().put('records' , prop.id);
                Test.setCurrentPage(pageRef);
                controller.Unassign();
                //controller.selectedCAR = 'userObj3';
                controller.selectedCAR = '--None--';           
                controller.Cancel();
              }
        Test.stopTest();
      }
}