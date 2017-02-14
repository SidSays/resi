/** **********************************************************************
* Name: NewBuildTriggerTest
* Author: Jui Desai
* User Story :
* Description: This class is used to test operation on New Build Trigger 
    Date                 PRJ/DFCT/ENHC#            Summary of Changes 
  -------------         -----------------       ------------------------------
  08-May-2015        Comcast Resi(MDU)              Initial Release 
  
**************************************************************************/
@isTest
public class NewBuildTriggerTest {
    
    //Test for updating New Build for Status Complete with Property Status also Complete.
    private static testMethod void testNwBuildTriggerForInsert() {
        
        TestDataUtility.createCustomSettingRecords();
        Test.startTest();    
        
        /*  Create Property And Its child New Build and Check Property Status on update of Status on New Build   */        
        MDU_Property__c propertyObj  =  TestDataUtility.createProperty();
        Database.insert(propertyObj);
        New_Build__c newBuild = TestDataUtility.createNewBuild();
        newBuild.Property__c = propertyObj.id; 
        Database.insert(newBuild);
        
        MDU_Property__c propertyParent = [Select Id, New_Build_Property__c from MDU_Property__c where Id = :propertyObj.id];
        System.assertEquals(propertyParent.New_Build_Property__c,true);
        
        Test.stopTest();
    }

    private static testMethod void testNwBuildTriggerForDeleteStatusFalse() {   
    
        TestDataUtility.createCustomSettingRecords();
        Test.startTest();
        
        /*  Create Property And New Build to check delete trigger on New Build */
        MDU_Property__c PropObj = TestDataUtility.createProperty();
        PropObj.New_Build_Property__c  = true;
        Database.Insert(PropObj) ;
        
        List<New_Build__c> newBuildList = new List<New_Build__c>();

        New_Build__c newBuildTemp = new New_Build__c(); 
        newBuildTemp.Status__c = 'Active';
        newBuildTemp.Property__c = PropObj.Id;
        newBuildList.add(newBuildTemp);
        
        New_Build__c newBuildTemp1 = new New_Build__c();
        newBuildTemp1.Status__c = 'Complete';
        newBuildTemp1.Property__c = PropObj.Id;
        newBuildList.add(newBuildTemp1);
        
        Database.Insert(newBuildList);
        Database.Delete(newBuildList[0]);
        MDU_Property__c PropTemp = [Select Id, New_Build_Property__c from MDU_Property__c where Id = :PropObj.Id];
        System.assertEquals(PropTemp.New_Build_Property__c,false);
        Test.stopTest();
    }   
        private static testMethod void testNwBuildTriggerForDeleteStatusTrue() {    
    
        TestDataUtility.createCustomSettingRecords();
        Test.startTest();
        /* Property with False Status , Change to True Status   */
        MDU_Property__c PropObj2 = TestDataUtility.createProperty();
        PropObj2.New_Build_Property__c  = false;
        Database.Insert(PropObj2);  
        
        List<New_Build__c> newBuildList2 = new List<New_Build__c>();
        
        New_Build__c newBuildTemp2 = new New_Build__c(); 
        newBuildTemp2.Status__c = 'Active';
        newBuildTemp2.Property__c = PropObj2.Id;
        newBuildList2.add(newBuildTemp2);
            
        New_Build__c newBuildTemp3 = new New_Build__c(); 
        newBuildTemp3.Status__c = 'Complete';
        newBuildTemp3.Property__c = PropObj2.Id;
        newBuildList2.add(newBuildTemp3);
           
        Database.insert(newBuildList2);
        Database.Delete(newBuildList2[1]);
        MDU_Property__c PropTemp2 = [Select Id, New_Build_Property__c from MDU_Property__c where Id = :PropObj2.Id];
        System.assertEquals(PropTemp2.New_Build_Property__c,true);       
        Test.stopTest();
    }
    
    //Test for Property Status False.
    private static testMethod void testNwBuildTriggerForUpdate(){
        
       TestDataUtility.createCustomSettingRecords();
       Test.startTest();
       
        MDU_Property__c PropObj2 = TestDataUtility.createProperty();
        PropObj2.New_Build_Property__c  = false;
        Database.Insert(PropObj2);  
        
        List<New_Build__c> newBuildList3 = new List<New_Build__c>();
        
        New_Build__c newBuildTemp2 = new New_Build__c(); 
        newBuildTemp2.Status__c = 'Complete';
        newBuildTemp2.Property__c = PropObj2.Id;
        newBuildList3.add(newBuildTemp2);

        New_Build__c newBuildTemp3 = new New_Build__c();
        newBuildTemp3.Status__c = 'Complete';
        newBuildTemp3.Property__c = PropObj2.Id;
        newBuildList3.add(newBuildTemp3);
        
        Database.insert(newBuildList3);
        newBuildList3[1].Status__c = 'Active';
        Database.Update(newBuildList3[1]);
        
        MDU_Property__c PropTemp2 = [Select Id, New_Build_Property__c from MDU_Property__c where Id = :PropObj2.Id];
        System.assertEquals(PropTemp2.New_Build_Property__c,true);       
        Test.stopTest();
    }   
}