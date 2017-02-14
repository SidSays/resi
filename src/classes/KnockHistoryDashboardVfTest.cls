/**************************************************************************************************
Name : KnockHistoryDashboardVfTest
Description : This class created to test KnockDashboardHistController class
User Story : US491510
Date : 15 September 2015
Author : Ashish Sonawane
***************************************************************************************************/
@isTest
public class KnockHistoryDashboardVfTest{
        
    private static testmethod void KnockHistoryDashboard(){
        WorkTestDataUtility.createCustomSettingRecords();   
       
        List<Task> taskList = new List<Task>(); 
        string knockRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId();
        Division freedomRegion = [select id, name from Division where name ='Beltway Market'];
                 
        /* Create plan and Address for DSR User  */
        Customer_Address__c addr = new Customer_Address__c();
        Plan__c pln = new Plan__c();
       
        pln.Name = 'TestPlan';
        pln.Plan_Level__c = 'Turf';
        pln.Plan_Status__c = 'Draft';
        pln.No_of_No_Knock__c = 1;
        pln.No_of_No_Answer__c = 1;
        pln.No_of_Knock__c = 2;
        pln.User__c = UserInfo.getUserId();
        ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
        PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
        
        extnObj1.quickSave();
        
        addr.Address__c = 'Test Address';
        addr.State__c = 'Test State';
        addr.City__c = 'Test City';
        addr.Country__c = 'Test Country';
        addr.PostalCode__c = '12345';
        addr.Node__c = '1111';
        addr.Corp__c = '11111111';
        addr.Route_Code__c = '1111111111';
        addr.Region__c = 'Beltway Market';
        addr.Division = freedomRegion.Id;
        
        addr.plan__c = pln.Id;
        Database.insert(addr);
        pln.User__c = UserInfo.getUserId();
        extnObj1.Save();
        
        
        /* Create Knock Record */ 
        for(Integer i=0 ; i<7;i++){          
            Task taskObj = WorkTestDataUtility.CreateTask();         
            taskObj.whatId = addr.Id;
            taskObj.Dwelling_Type__c='MDU';  
            taskObj.OwnerId = UserInfo.getUserId();   
            taskObj.HSI_Sold__c = true;
            taskObj.Video_Sold__c = true;
            taskObj.Voice_Sold__c = true;
            taskObj.XH_Sold__c = true;    
            taskObj.RecordTypeId = knockRecordTypeId;
            taskObj.Event_Category__c = 'Back to School';  
            if(i==0){
            taskObj.Disposition__c='No Knock';
            }else if(i==1){
            taskObj.Disposition__c='Contact'; 
            }else if(i==2){
             taskObj.Disposition__c='Engage';
            }else if(i==3){
             taskObj.Disposition__c='Discover';
            }else if(i==4){
             taskObj.Disposition__c='Position';
            }else if(i==5){
             taskObj.Disposition__c='Close';
            }else if(i==6){
             taskObj.Disposition__c='Start';                         
            }
            taskList.add(taskObj);         
        }
        Database.Insert(taskList); 
        
        System.debug('Comcast Division'+[Select Comcast_Division__c From Customer_Address__c LIMIT 1][0].Comcast_Division__c);
        
        Test.startTest();   
        
        PageReference pageRef = Page.KnockHistoryDashboardMainVfPage;
        Test.setCurrentPage(pageRef);         
        /* Call Constructor that will use to Create New Property */
        KnockDashboardHistController knockDashboardHistController = new KnockDashboardHistController();
       
        knockDashboardHistController.getCentralKnockHrsData();
        knockDashboardHistController.getCentalKnockDaysData();
        knockDashboardHistController.getNortheasternKnockHrsData();
        knockDashboardHistController.getNortheasternKnockDaysData();
        knockDashboardHistController.getWesternKnockHrsData();
        knockDashboardHistController.getWesternKnockDaysData();
        knockDashboardHistController.getOverallKnockHrsData();
        knockDashboardHistController.getOverallKnockDaysData();
        Test.stopTest();     
        /*
        pageRef.getparameters().put('id',propertyObject.id);   
        ApexPages.StandardController standardController =  new ApexPages.StandardController(propertyObject)  ; 
        */  
    }
    
}