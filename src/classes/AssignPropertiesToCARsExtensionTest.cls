@isTest
public class AssignPropertiesToCARsExtensionTest{
    public static testMethod void AssignPropertiesToCARsExtension(){
            CARMgrPublicGrpRgn__c cs = new CARMgrPublicGrpRgn__c();
            cs.Name = '1';
            cs.Region__c = 'Freedom Market';
            cs.Group_Name__c = 'CAR Managers - Freedom';
            
            insert cs;
        
        
        List<MDU_Property__c> properties = new List<MDU_Property__c>();
        TestDataUtility.createCustomSettingRecords();
        PageReference pageRef = Page.AssignPropertiesToCARs;
        
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
       
        MDU_Property__c prop1 = TestDataUtility.createProperty();
        //prop1.Assigned_CAR__c= userObj2.Id;
        prop1.Name = 'Test Property1';
        insert prop1;
        
        MDU_Property__c prop2 = TestDataUtility.createProperty();
        //prop2.Assigned_CAR__c = userObj2.Id;
        prop2.Name = 'Test Property2';
        insert prop2;
        Test.startTest();
            System.runAS(userObj){                  
                pageRef.getParameters().put('records' , prop.id);
                //apexpages.currentpage().getParameters().put('records','prop.id');
                //pageRef.getParameters().put('records',prop1.id);
                //apexpages.currentpage().getParameters().put('records','prop1.Id'); 
                //system.debug('Pages value########### ') 
                Test.setCurrentPage(pageRef);
                
                AssignPropertiesToCARsExtension obj = new AssignPropertiesToCARsExtension();
                obj.isError = false;
                obj.selectedCAR = userObj4.Id;
                obj.doAssignment();  
                //obj.selectedCAR = '--None--';           
                obj.cancelAssignment();
                obj.rowToRemove = 1;
                obj.removeRowFromPropertyList();
            }
        Test.stopTest();
      }
      
        public static testMethod void AssignPropertiesToCARsExtensionManager(){
        
            CARMgrPublicGrpRgn__c cs = new CARMgrPublicGrpRgn__c();
            cs.Name = '1';
            cs.Region__c = 'Freedom Market';
            cs.Group_Name__c = 'CAR Managers - Freedom';
            
            insert cs;
        
        List<MDU_Property__c> properties = new List<MDU_Property__c>();
        TestDataUtility.createCustomSettingRecords();
        PageReference pageRef = Page.AssignPropertiesToCARs;
        
        User userObj = TestDataUtility.createXfinityCARManagerUser();
        User userObj3 = TestDataUtility.createXfinityCARUser();
        userObj3.ManagerId = userObj.id;
        User userObj4 = TestDataUtility.createXfinityCARUser();
        userObj3.ManagerId = userObj.id;
        
        MDU_Property__c prop = TestDataUtility.createProperty();
        prop.Assigned_CAR__c= userObj3.Id;
        prop.Name = 'Test Property';
        insert prop;
        //properties.add(prop);
        
        MDU_Property__c prop1 = TestDataUtility.createProperty();
        //prop1.Assigned_CAR__c= userObj3.Id;
        prop1.Name = 'Test Property1';
        insert prop1;
        //properties.add(prop1);
          
        MDU_Property__c prop2 = TestDataUtility.createProperty();
        //prop2.Assigned_CAR__c= userObj3.Id;
        prop2.Name = 'Test Property2';
        insert prop2;
        //properties.add(prop2);
        Test.startTest();
            System.runAS(userObj){           
                pageRef.getParameters().put('records' , prop.id+''+-2+''+prop1.id);
                //apexpages.currentpage().getParameters().put('records',prop.id); 
                //pageRef.getParameters().put('records',prop1.id);
                //apexpages.currentpage().getParameters().put('records',prop1.id);        
                Test.setCurrentPage(pageRef);
                AssignPropertiesToCARsExtension obj = new AssignPropertiesToCARsExtension();
                obj.isError = false;
                obj.selectedCAR = userObj4.Id;
                obj.doAssignment();
                //obj.selectedCAR = 'userObj4'; 
                //obj.selectedCAR = '--None--'; 
                obj.cancelAssignment();
                obj.rowToRemove = 1;
                obj.removeRowFromPropertyList();
            }
        Test.stopTest();
      }
}