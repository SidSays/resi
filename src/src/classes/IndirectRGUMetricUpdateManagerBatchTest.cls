/**************************************************************************************************
Name : IndirectRGUMetricUpdateManagerBatchTest
Description : This test class is created for Test coverage of IndirectRGUMetricUpdateManagerBatch apex class.
Date : 24/04/2017
Author : Amit Kumar Pradhan
Last Modified by : Tejaswini kasar
***************************************************************************************************/
@isTest
public class IndirectRGUMetricUpdateManagerBatchTest{  
    public static testmethod void testIndirectMonthlyGoalCreationBatch(){
        String goalIndirectSalesRecordTypeId= Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Indirect Sales').getRecordTypeId();
        WorkTestDataUtility.createCustomSettingRecords();
        
        RGU_Goal_Target_Actual__c targetActualC=new RGU_Goal_Target_Actual__c();
        targetActualC.Name= 'Indirect';
        targetActualC.Decription__c= 'Test1';
        targetActualC.Offset__c= 1;
        targetActualC.Payroll_End_Date__c= System.Today().addDays(+2);
        targetActualC.Payroll_Start_Date__c= System.Today().addDays(-2);
        targetActualC.SAQL_Limit__c= 2;
        targetActualC.Lagging_Days__c = -2;
        
        insert targetActualC;
        
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
                                    ManagerId= retailSalesMgrUser.Id,
                                    PERNR__c = '4747474',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
          
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
        repRGUGoal.Status = 'Draft';
        repRGUGoal.Template_Type__c = 'RGU';
        repRGUGoal.RecordTypeId = Indirect_Constants.INDIRECT_RECORD_TYPE_ID;
        
        insert repRGUGoal; 
        
        Metric repmetricObj = new Metric();        
        repmetricObj.Name = 'Video';
        repmetricObj.ownerId = retailSalesRepUser.Id;
        repmetricObj.TargetValue = 10;
        repmetricObj.currentValue = 5;
        repmetricObj.Status = 'Critical';
        repmetricObj.DueDate = System.Today().addDays(+2);
        repmetricObj.GoalId = repRGUGoal.Id;
        
        insert repmetricObj; 
        
        // Create  Goal record and related Metrics record for Activity for SalesManager
        Goal mgrRGUGoal = new Goal(); // Standard obj
        mgrRGUGoal.Name = 'Test RGU Goal Manager';
        mgrRGUGoal.Profile_Name__c = 'Retail Sales Manager';
        mgrRGUGoal.ownerId = retailSalesMgrUser.Id;
        mgrRGUGoal.Region__c = retailSalesMgrUser.Region__c;
        mgrRGUGoal.StartDate = System.Today().addDays(-2);
        mgrRGUGoal.DueDate = System.Today().addDays(+2);
        mgrRGUGoal.Status = 'Draft';
        mgrRGUGoal.Template_Type__c = 'RGU';
        
        mgrRGUGoal.RecordTypeId = Indirect_Constants.INDIRECT_RECORD_TYPE_ID;
        
        insert mgrRGUGoal; 
        
        Metric mgrmetricObj = new Metric();        
        mgrmetricObj.Name = 'Video';
        mgrmetricObj.ownerId = retailSalesMgrUser.Id;
        mgrmetricObj.TargetValue = 1;
        mgrmetricObj.currentValue = 0;
        mgrmetricObj.DueDate = System.Today().addDays(+2);
        mgrmetricObj.Status = 'Critical';
        mgrmetricObj.GoalId = mgrRGUGoal.Id;
        
        insert mgrmetricObj; 
        
         String queryString = '';
            if(System.Label.IndirectRGUMetricUpdateManagerBatchQuery != null){
                queryString = System.Label.IndirectRGUMetricUpdateManagerBatchQuery;
            }              
            Integer batchSize = 200;
            if(System.Label.IndirectRGUMetricUpdateManagerBatchSize != null && System.Label.IndirectRGUMetricUpdateManagerBatchSize.isNumeric()){
                batchSize = Integer.valueOf(System.Label.IndirectRGUMetricUpdateManagerBatchSize);
            }       
             database.executebatch(new IndirectRGUMetricUpdateManagerBatch(queryString), 200);
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