/***************************************************************************************************************************************
 * Author     : Abhishek, Accenture
 * Date       : 29-January-2015
 * Description: This is Test class for "PhaseStatsTrigger" trigger
 * History
     Version             : 1.0
     Author Last Updated : Abhishek, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class PhaseStatsTriggerTest {
    
    /*
      Test for updating Phase Stats for Status Complete with New Build Status also Complete.
    */
    private static testMethod void testContactTriggerController() {
        
        TestDataUtility.createCustomSettingRecords();
        Test.startTest();
        
        /*  Create New Bulk And Its child Phase Stats and Check New Buld Status on update of Status on Phase Stats   */
        New_Build__c newBuild = TestDataUtility.createNewBuild();
        Database.insert(newBuild);
        Phase_Stats__c phStats = TestDataUtility.createPhaseStats();
        phStats.As_of_Date_del__c= Date.Today();
        phStats.Completed_Status__c = true;
        phStats.New_Build__c=newBuild.id;
        Database.insert(phStats);
   
        
        New_Build__c newBuildParent = [Select Id, Status__c,Phase_Completed_Date__c from New_Build__c where Id = :newBuild.id];
        System.assertEquals(newBuildParent.Status__c,'Complete');
        System.assertEquals(newBuildParent.Phase_Completed_Date__c,Date.Today());
        
        Test.stopTest();
    }
    
    private static testMethod void testContactTriggerController1() {
        
        TestDataUtility.createCustomSettingRecords();
        Test.startTest();   
        
        /*  Create New Build And Phase status to check delete trigger on Phase Stats */
        New_Build__c newBuild = TestDataUtility.createNewBuild();
        newBuild.Status__c  = 'Active';
        Database.insert(newBuild) ;
        
        List<Phase_Stats__c> phaseStatsList = new List<Phase_Stats__c>();
        for(Integer i = 0; i< 2;i++){
            Phase_Stats__c phStatsTmp = new Phase_Stats__c(); 
            if( i == 0){
                phStatsTmp.Completed_Status__c = false;
                phStatsTmp.As_of_Date_del__c = Date.Today();
                phStatsTmp.New_Build__c = newBuild.Id;
                phaseStatsList.add(phStatsTmp);
            }else if(i == 1){
                phStatsTmp.Completed_Status__c= true;
                phStatsTmp.As_of_Date_del__c= Date.Today();
                phStatsTmp.New_Build__c = newBuild.Id;
                phaseStatsList.add(phStatsTmp);
            }
        }
        Database.insert(phaseStatsList);
        Delete phaseStatsList[0];
        New_Build__c newBuilkTemp = [Select Id, Status__c from New_Build__c where Id = :newBuild.Id];
        System.assertEquals(newBuilkTemp.Status__c,'Complete');
    
        Test.stopTest();
    }   
    
    private static testMethod void testContactTriggerController2() {
        
        TestDataUtility.createCustomSettingRecords();
        Test.startTest();   
        
        /* New Build with 'Complete' Status , Change to 'Active' Status   */
        New_Build__c newBuild2 = TestDataUtility.createNewBuild();
        newBuild2.Status__c  = 'Complete';
        Database.insert(newBuild2) ;      
        List<Phase_Stats__c> phaseStatsList2 = new List<Phase_Stats__c>();
        for(Integer i = 0; i< 2;i++){
            Phase_Stats__c phStatsTmp = new Phase_Stats__c(); 
            if( i == 0){
                phStatsTmp.Completed_Status__c = false;
                phStatsTmp.As_of_Date_del__c = Date.Today();
                phStatsTmp.New_Build__c = newBuild2.Id;
                phaseStatsList2.add(phStatsTmp);
            }else if(i == 1){
                phStatsTmp.Completed_Status__c= true;
                phStatsTmp.As_of_Date_del__c= Date.Today();
                phStatsTmp.New_Build__c = newBuild2.Id;
                phaseStatsList2.add(phStatsTmp);
            }
        }
        Database.insert(phaseStatsList2);
        Delete phaseStatsList2[1];
        New_Build__c newBuilkTemp2 = [Select Id, Status__c from New_Build__c where Id = :newBuild2.Id];        
        System.assertEquals(newBuilkTemp2.Status__c,'Active');    
        
        Test.stopTest();
    }   
    
    //Test for New Build Status not Complete.
    private static testMethod void testContactTriggerController3(){
        
        TestDataUtility.createCustomSettingRecords();
        Phase_Stats__c phStats2 = TestDataUtility.createPhaseStats();
        phStats2.Completed_Status__c = true;
        phStats2.As_of_Date_del__c= Date.Today();
        Database.insert(phStats2);
        
        List<New_Build__c> newBuildOriginal =[Select Id, Status__c,Phase_Completed_Date__c from New_Build__c where Id =:phStats2.New_Build__c];
        newBuildOriginal[0].Status__c = 'Complete';
        Database.update(newBuildOriginal);
        
        Test.startTest();
        phStats2.Completed_Status__c = false;
        Database.update(phStats2);
        List<Phase_Stats__c> updatedRecord =[Select Id, New_Build__c,Completed_Status__c from Phase_Stats__c where Id = :phStats2.Id];
        List<Id> newBuildIdSet = new List<Id>();
        for(Phase_Stats__c ph :updatedRecord){
            newBuildIdSet.add(ph.New_Build__c);
        }
        New_Build__c newBuildParent = [Select Id, Status__c,Phase_Completed_Date__c from New_Build__c where Id = :newBuildIdSet[0]];
        System.assertEquals(newBuildParent.Status__c,'Active');
        System.assertEquals(newBuildParent.Phase_Completed_Date__c,null);
        Test.stopTest();
    }
    
}