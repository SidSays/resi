/**************************************************************************************************
Name : IndirectRGUMetricUpdateRepBatchTest
Description : This test class is created for Test coverage of IndirectRGUMetricUpdateRepBatch apex class.
Date : 05-May-2017
Author : Animesh Datta
Last modified by : Tejaswini Kasar(US1137111)


***************************************************************************************************/
@isTest
public class IndirectRGUMetricUpdateRepBatchTest{
    /*
        Test Coverage for IndirectRGUMetricUpdateRepBatch
    */
    @testSetup
    public static void testIndirectRGUMetricUpdateRepBatch(){
      
        String goalIndirectSalesRecordTypeId= Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Indirect Sales').getRecordTypeId();
        WorkTestDataUtility.createCustomSettingRecords();
        //Crate Custom Settings record
        RGU_Goal_Target_Actual__c targetActualC=new RGU_Goal_Target_Actual__c();
            targetActualC.Name= 'Indirect';
            targetActualC.Decription__c= 'Test1';
            targetActualC.Offset__c= 1;
            targetActualC.Payroll_End_Date__c= System.Today().addDays(+2);
            targetActualC.Payroll_Start_Date__c= System.Today().addDays(-2);
            targetActualC.SAQL_Limit__c= 2;
            targetActualC.Lagging_Days__c = -2;
            targetActualC.Credential__c = 'YWJjZA==';
            targetActualC.UserName__c = 'YWJjZA==';
        insert targetActualC;
        //decode data
        String inputValue = 'YWJjZA==';
        DecodeEncodeUtility.decodeData(inputValue);
 
        Profile retailSalesMgr = [Select Id, Name From Profile where Name = 'Retail Sales Manager' limit 1];
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 8)+1150)+'';
        User retailSalesMgrUser = new User(Alias = 'C_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = retailSalesMgr.Id,
                                    Username = 'userTest1' + randomstr1 + '@SampleTest.com',
                                    Region__c = 'California Market',
                                    Sales_Rep_Type__c='RepType',
                                    PERNR__c = '12334',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'FedId1'+randomstr1,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr1.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
          
                          );
        insert retailSalesMgrUser;
        //Assign PermissionSet to Coresponding Profile user        
        System.runAs(new User(Id=userInfo.getUserId())){
            assignPermissionSet('SalesSpace_Coach_Access_Retail_Sales_Manager',retailSalesMgrUser.Id);            
        }
        
        //Create Retail Sales Rep User      
        Profile retailSalesRep = [Select Id, Name From Profile where Name = 'Retail Sales Rep' limit 1];
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User retailSalesRepUser = new User(Alias = 'C_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = retailSalesRep.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'California Market',
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level', 
                                    ManagerId= retailSalesMgrUser.Id,
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today(),
                                    PERNR__c = '11111111'          
                          );
        insert retailSalesRepUser;
        //Assign PermissionSet to Coresponding Profile user        
        System.runAs(new User(Id=userInfo.getUserId())){
            assignPermissionSet('SalesSpace_Coach_Access_Retail_Rep',retailSalesRepUser.Id);             
        }
        // Create  Goal record and related Metrics record for Activity for SalesRep
        Goal repRGUGoal = new Goal(); // Standard obj
        repRGUGoal.Name = 'Test RGU Goal';
        repRGUGoal.Profile_Name__c = 'Retail Sales Rep';
        repRGUGoal.ownerId = retailSalesRepUser.Id;
        repRGUGoal.Region__c = retailSalesRepUser.Region__c;
        repRGUGoal.StartDate = System.Today().addDays(-2);
        repRGUGoal.DueDate = System.Today().addDays(+2);
        repRGUGoal.Status = 'Published';
        repRGUGoal.Template_Type__c = 'RGU';
        repRGUGoal.RecordTypeId = goalIndirectSalesRecordTypeId;
        
        insert repRGUGoal; 
        
        Metric repmetricObj = new Metric();        
        repmetricObj.Name = 'Video';
        repmetricObj.ownerId = retailSalesRepUser.Id;
        repmetricObj.TargetValue = 10;
        repmetricObj.currentValue = 5;
        repmetricObj.Status = 'Critical';
        repmetricObj.GoalId = repRGUGoal.Id;
        
        insert repmetricObj; 
        
        Metric waveMetric = new Metric();        
        waveMetric.Name = 'Video';
        waveMetric.ownerId = retailSalesRepUser.Id;
        waveMetric.TargetValue = 100;
        waveMetric.currentValue = 50;
        waveMetric.Status = 'Critical';
        insert waveMetric;
    }  
     public static testmethod void testIndirectRGUMetricUpdateRepBatch1(){
         test.starttest();
         Test.setMock(HttpCalloutMock.class, new WaveAPIUtilHttpCalloutMock()); 
        /*  String queryString = ''; 
        if(System.Label.IndirectRGUMetricUpdateRepBatchQuery != Null){
            queryString = System.Label.IndirectRGUMetricUpdateRepBatchQuery;
        }       
        Integer batchSize = 1;
        if(System.Label.IndirectRGUMetricUpdateRepBatchSize !=null && System.Label.IndirectRGUMetricUpdateRepBatchSize.isNumeric()){
            batchSize = Integer.valueOf(System.Label.IndirectRGUMetricUpdateRepBatchSize);
        }
        
       database.executebatch(new IndirectRGUMetricUpdateRepBatch(queryString),batchSize);*/
    
           String queryString = ''; 
           /* if(System.Label.IndirectRGUMetricUpdateRepBatchQuery != Null){
                queryString = System.Label.IndirectRGUMetricUpdateRepBatchQuery;
            }*/
            RGU_Goal_Target_Actual__c targetActualC =[Select id,Payroll_End_Date__c from RGU_Goal_Target_Actual__c where name = 'Indirect' LIMIT 1];
            Metric waveMetric = [Select id,Name,ownerId,TargetValue,currentValue,Status from metric where name = 'Video' limit 1];
            queryString = 'Select Id, Name, ManagerId,Profile.name,Region__c,PERNR__c from User where IsActive = True AND Profile.Name IN: PROFILE_NAME_LIST_REP and UserPermissionsWorkDotComUserFeature = true AND PERNR__c =\'11111111\'';
            IndirectRGUMetricUpdateRepBatch repBatch = new IndirectRGUMetricUpdateRepBatch(queryString);
            String keyStr = '11111111'+String.valueOf(targetActualC.Payroll_End_Date__c).remove('-')+'Video';
            repBatch.keyVsRGUMetric.put(keyStr,waveMetric);
            
            database.executebatch(repBatch,200);
         
         //SFDCTest.myMethod();
        test.stoptest();
     }
  
    /*
    *  This method set permission set to user base on permissionSetName 
    */     
    static void assignPermissionSet(String permissionSetName, Id userId){        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa);        
    } 
}