/****************************************************************************************************************************************************
Name: MDU_LaunchInterviewProcessTest 
Description: This class is used to test Launch interview process by creating Mock responses
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
22 May 2015 Comcast  
*************************************************************************************************************************************************************/
@isTest                        
private class MDU_LaunchInterviewProcessTest{
    
    //Test for Search Interview method
    @isTest static void searchIntrviewProcess() {
                
        Id currentProfileId = userinfo.getProfileId();             
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();
       
       System.runAs(xcUser){                           
                       
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);                             
            Database.insert(TestDataUtility.createIntegrationCS());            
            TestDataUtility.createInterviewTemplateMapping();
            createCleanOpportunutyProperty(true);
        }
                
        // Set mock callout class                                              
        Test.startTest();               
        Opportunity_Property__c opptProperty = [Select Id, Opportunity__c From Opportunity_Property__c ];               
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForInterview(true));
        String url = MDU_LaunchInterviewProcess.processInterview(String.valueOf(opptProperty.Opportunity__c));          
        Test.stopTest();                                                   
    }
    
    //Test for Create Interview method
    @isTest static void createIntrviewProcess() {
               
        Id currentProfileId = userinfo.getProfileId();             
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();        
        System.runAs(xcUser){                                
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);                   
            Database.insert(TestDataUtility.createIntegrationCS());
            TestDataUtility.createInterviewTemplateMapping();
            createCleanOpportunutyProperty(false);
        }
                
        // Set mock callout class        
        Test.startTest();               
        
        Opportunity_Property__c opptProperty = [Select Id, Opportunity__c From Opportunity_Property__c ];                
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForInterview(true));
        String url = MDU_LaunchInterviewProcess.processInterview(String.valueOf(opptProperty.Opportunity__c));                
        
        Test.stopTest();
    }
    
    //Test for Create Interview method
    @isTest static void createIntrviewProcessWithHospIndustry() {
               
        Id currentProfileId = userinfo.getProfileId();  
        Id opptyId = null ;     
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();        
        System.runAs(xcUser){                                        
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);                   
            Database.insert(TestDataUtility.createIntegrationCS());
            TestDataUtility.createInterviewTemplateMapping();
            opptyId = createCleanOpptyPropertyHospInd();            
        }
                
        // Set mock callout class        
        Test.startTest();                                  
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForInterview(true));
        String url = MDU_LaunchInterviewProcess.processInterview(String.valueOf(opptyId));          
        
        Test.stopTest();
    }
    
    //Test for Create Interview method with property of Commercial Industry
    @isTest static void createIntrviewProcessWithCommercialIndustry() {
               
        Id currentProfileId = userinfo.getProfileId();          
        Id opptyCommercInd = null ; 
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();        
        System.runAs(xcUser){                                        
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);                   
            Database.insert(TestDataUtility.createIntegrationCS());
            TestDataUtility.createInterviewTemplateMapping();           
            opptyCommercInd = createCleanOpptyPropertyCommerclInd();
        }
                
        // Set mock callout class        
        Test.startTest();       
        // from the class that implements HttpCalloutMock.                    
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForInterview(true));
        String url = MDU_LaunchInterviewProcess.processInterview(String.valueOf(opptyCommercInd)); 
                        
        Test.stopTest();
    }
    
    
    //Test for Create Interview method
    @isTest static void launchInterviewWthtPropertyOnOppty() {
               
        Id currentProfileId = userinfo.getProfileId();  
        Id opptyId = null ; 
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();        
        System.runAs(xcUser){                                        
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);                   
            Database.insert(TestDataUtility.createIntegrationCS());
            TestDataUtility.createInterviewTemplateMapping();
            opptyId = createOpportunityOnly();
        }
                
        // Set mock callout class        
        Test.startTest();       
        // from the class that implements HttpCalloutMock.                      
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForInterview(true));
        String url = MDU_LaunchInterviewProcess.processInterview(String.valueOf(opptyId));                
        Test.stopTest();
    }
    
    
    //Test for different validation message on Opportunity And Property
    @isTest static void launchInterviewValMessageProcess() {
               
        Id currentProfileId = userinfo.getProfileId();             
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();           
        System.runAs(xcUser){                                       
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);                  
            Database.insert(TestDataUtility.createIntegrationCS());
            TestDataUtility.createInterviewTemplateMapping();
            createOpportunutyPropertyValidation();
        }
       
        Test.startTest();       
        // from the class that implements HttpCalloutMock. 
        Opportunity_Property__c opptProperty = [Select Id, Opportunity__c From Opportunity_Property__c ];                
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForInterview(true));
        String url = MDU_LaunchInterviewProcess.processInterview(String.valueOf(opptProperty.Opportunity__c));
               
        Test.stopTest();
    }
    
    //This method test fault response to searchIndividual method
    @isTest static void faultyResponseProcessTest() {
               
        Id currentProfileId = userinfo.getProfileId();             
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();           
        System.runAs(xcUser){                                       
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);                  
            Database.insert(TestDataUtility.createIntegrationCS());
            TestDataUtility.createInterviewTemplateMapping();
            createCleanOpportunutyProperty(true);
        }
        
        Test.startTest();       
        // from the class that implements HttpCalloutMock. 
        Opportunity_Property__c opptProperty = [Select Id, Opportunity__c From Opportunity_Property__c ];                
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForInterview(false,1));
        MDU_LaunchInterviewProcess launchInterViewProcess = new  MDU_LaunchInterviewProcess();
        String url = MDU_LaunchInterviewProcess.processInterview(String.valueOf(opptProperty.Opportunity__c));       
        System.assertEquals(true,url.contains('Authentication failed'));        
        Test.stopTest();
    }
    
    //This method test fault response to createIndividual method
    @isTest static void faultyResponse1ProcessTest() {
               
        Id currentProfileId = userinfo.getProfileId();             
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();           
        System.runAs(xcUser){                                       
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);                  
            Database.insert(TestDataUtility.createIntegrationCS());
            TestDataUtility.createInterviewTemplateMapping();
            createCleanOpportunutyProperty(true);
        }
        
        Test.startTest();       
        // from the class that implements HttpCalloutMock. 
        Opportunity_Property__c opptProperty = [Select Id, Opportunity__c From Opportunity_Property__c ];                
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForInterview(false,2));
        MDU_LaunchInterviewProcess launchInterViewProcess = new  MDU_LaunchInterviewProcess();
        String url = MDU_LaunchInterviewProcess.processInterview(String.valueOf(opptProperty.Opportunity__c));       
        System.assertEquals(true,url.contains('Authentication failed'));
        
        Test.stopTest();
    }
   
    
     /* 
        This method test fault response to searchInterview method
     */
    @isTest static void faultyResponse3ProcessTest() {
               
        Id currentProfileId = userinfo.getProfileId();             
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();           
        System.runAs(xcUser){                                       
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);                  
            Database.insert(TestDataUtility.createIntegrationCS());
            TestDataUtility.createInterviewTemplateMapping();
            createCleanOpportunutyProperty(true);
        }
       
        Test.startTest();       
        // from the class that implements HttpCalloutMock. 
        Opportunity_Property__c opptProperty = [Select Id, Opportunity__c From Opportunity_Property__c ];                
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForInterview(false,4));
        MDU_LaunchInterviewProcess launchInterViewProcess = new  MDU_LaunchInterviewProcess();
        String url = MDU_LaunchInterviewProcess.processInterview(String.valueOf(opptProperty.Opportunity__c));
        
        System.assertEquals(true,url.contains('Authentication failed'));
        
        Test.stopTest();
    }
    
    /* 
        Test method to test response with fault response to build URL
    */
    @isTest static void faultyResponse4ProcessTest() {
               
        Id currentProfileId = userinfo.getProfileId();             
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();           
        System.runAs(xcUser){                                       
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);                  
            Database.insert(TestDataUtility.createIntegrationCS());
            TestDataUtility.createInterviewTemplateMapping();
            createCleanOpportunutyProperty(true);
        }
        
        Test.startTest();       
        // from the class that implements HttpCalloutMock. 
        Opportunity_Property__c opptProperty = [Select Id, Opportunity__c From Opportunity_Property__c ];                
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForInterview(false,5));
        MDU_LaunchInterviewProcess launchInterViewProcess = new  MDU_LaunchInterviewProcess();
        String url = MDU_LaunchInterviewProcess.processInterview(String.valueOf(opptProperty.Opportunity__c));       
        System.assertEquals(true,url.contains('Authentication failed'));
        
        Test.stopTest();
    }
    
    /* 
        Create Opportunity Property that will show validation
    */
    private static void createOpportunutyPropertyValidation(){
          
        Account accountRec = createTestAccountData();
        Database.insert(accountRec);     
        //006K000000CIwh4 opportunity Id use to create record       
        List<Opportunity> oppList = TestDataUtility.createOpportunity(2);            
        //oppList[0].Contact_Email__c = 'vsadvdsv@dfhds.fdhdsf';
        //oppList[0].Contact_First_Name__c = 'sadvadv';
        //oppList[0].Contact_Last_Name__c = 'vdsadsv';
        oppList[0].ECM_Interview_Instance_Name__c = 'mdu200963february0320150235'; //'mdu006K000000CAZta031220151711';               
        oppList[0].Interview_Created_Date__c = 'date';
        oppList[0].StageName = 'Contract Document Review';
        oppList[0].ContractTerm__c = 1;        
        oppList[0].ContractTermUnit__c = 'months';       
        oppList[0].Contract_Type__c = 'Bulk'; 
        oppList[0].Fiber_To_The_Unit__c = 'None';     
        oppList[0].AccountId = accountRec.Id;                
        insert  oppList[0];
        
        MDU_Property__c prop1 = TestDataUtility.createProperty();
        prop1.Industry_Type__c = 'Multi Family';       
        prop1.Owner_Account__c = accountRec.Id;              
        insert prop1;
        
        Opportunity_Property__c oppProp =  TestDataUtility.createOppProperty(oppList[0].id,prop1.id);
        oppProp.Primary_Property__c  = true;
        insert oppProp; 
       
        OpportunityContactRole OppContactRole = new OpportunityContactRole();
        OppContactRole = MDU_EmptorisUtility.fetchOpportunityContactRoleData(oppList[0].id);
        
    }
    
    /*
        Create Account Record 
    */  
    public static Account createTestAccountData(){
        
        List<Id> recordTypeIds = new List<Id>();      
        String labelName = System.Label.XfinityAccountRecordType;  
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(';')){
                recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }    
        
        Account accountObject = TestDataUtility.createAccount() ;
        accountObject.Is_Parent_Organization__c = false;
        accountObject.RecordTypeId = recordTypeIds[0];        
        return accountObject;
    }
    
    /*
        Create Opportunity Property Record having ECM_Interview_Instance_Name__c  
    */
    private static void createCleanOpportunutyProperty(boolean searchFlag){
        
        Account accountRec = createTestAccountData();
        Database.insert(accountRec);     
        //006K000000CIwh4 opportunity Id use to create record       
        List<Opportunity> oppList = TestDataUtility.createOpportunity(2);            
        oppList[0].Contact_Email__c = 'vsadvdsv@dfhds.fdhdsf';
        oppList[0].Contact_First_Name__c = 'sadvadv';
        oppList[0].Contact_Last_Name__c = 'vdsadsv';
        if(searchFlag){
            oppList[0].ECM_Interview_Instance_Name__c = 'mdu200963february0320150235'; //'mdu006K000000CAZta031220151711';
        }          
        oppList[0].Interview_Created_Date__c = 'date';
        oppList[0].StageName = 'Contract Document Review';
        oppList[0].ContractTermUnit__c = 'months';
        oppList[0].ContractTerm__c = 1;
        oppList[0].Contract_Type__c = 'Bulk';
        oppList[0].Video_Subs__c = 12;             
        oppList[0].Video_Bulk_Current_Rate__c = 2;
        oppList[0].Video_Bulk_Proposed_Rate__c = 2;        
        oppList[0].Video_Estimated_Revenue_Share_Rate__c = 2; 
        oppList[0].Video_Retail_Rate__c = 55;        
        oppList[0].Data_Subs__c = 10;       
        oppList[0].Data_Bulk_Current_Rate__c = 2;
        oppList[0].Data_Bulk_Proposed_Rate__c = 2;
        oppList[0].Data_Retail_Rate__c = 29;        
        oppList[0].Data_Estimated_Revenue_Share__c = 2; 
        oppList[0].Voice_Subs__c = 54;        
        oppList[0].Voice_Bulk_Current_Rate__c = 2;
        oppList[0].Voice_Bulk_Proposed_Rate__c = 2;       
        oppList[0].Voice_Estimated_Revenue_Share__c = 2; 
        oppList[0].Voice_Retail_Rate__c = 29;
        oppList[0].Per_Unit_Door_Fee__c = 2;
        oppList[0].IRR__c = 393;
        oppList[0].NPV__c = 137;
        oppList[0].Total_Equipment_Cost__c = 19393;
        oppList[0].Payback_Period_Months__c = 4;
        oppList[0].Construction_Capex_Cost__c = 2;
        oppList[0].Fiber_To_The_Unit__c = 'None';
        oppList[0].AccountId = accountRec.Id;                
        insert  oppList[0];
        
        MDU_Property__c prop1 = TestDataUtility.createProperty();
        prop1.Industry_Type__c = 'Multi Family';
        prop1.Property_Type__c = 'Apartment';
        prop1.Owner_Account__c = accountRec.Id;
        prop1.MDU_State__c = 'Florida';
        prop1.County__c = 'Bay County';
        prop1.Franchise_New__c = 'Parker City';         
        insert prop1;
        
        Opportunity_Property__c oppProp =  TestDataUtility.createOppProperty(oppList[0].id,prop1.id);
        oppProp.Primary_Property__c  = true;
        insert oppProp; 
       
        OpportunityContactRole OppContactRole = new OpportunityContactRole();
        OppContactRole = MDU_EmptorisUtility.fetchOpportunityContactRoleData(oppList[0].id);
    }
    
    /*
        Create Opportunity Property Record having property of Hospitality as Industry Type
    */
    private static Id createCleanOpptyPropertyHospInd(){
        
        Account accountRec = createTestAccountData();
        Database.insert(accountRec);     
        //006K000000CIwh4 opportunity Id use to create record       
        Opportunity opportunutyRec = createOpportunity(accountRec.Id);
        insert opportunutyRec;
                
        MDU_Property__c prop1 = TestDataUtility.createProperty();
        prop1.Industry_Type__c = 'Hospitality';
        prop1.Property_Type__c = 'Marina';
        prop1.Owner_Account__c = accountRec.Id;
        prop1.MDU_State__c = 'Florida';
        prop1.County__c = 'Bay County';
        prop1.Franchise_New__c = 'Parker City';         
        insert prop1;
        
        Opportunity_Property__c oppProp =  TestDataUtility.createOppProperty(opportunutyRec.id,prop1.id);
        oppProp.Primary_Property__c  = true;
        insert oppProp; 
       
        OpportunityContactRole OppContactRole = new OpportunityContactRole();
        OppContactRole = MDU_EmptorisUtility.fetchOpportunityContactRoleData(opportunutyRec.id);
        return opportunutyRec.id;
    }
    
    /* 
        Create Opportunity Property Record having property of Commercial as Industry Type 
    */
    private static Id createCleanOpptyPropertyCommerclInd(){
        
        Account accountRec = createTestAccountData();
        Database.insert(accountRec);     
        //006K000000CIwh4 opportunity Id use to create record       
        Opportunity opportunutyRec = createOpportunity(accountRec.Id);
        insert opportunutyRec;
                
        MDU_Property__c prop1 = TestDataUtility.createProperty();
        prop1.Industry_Type__c = 'Commercial';
        prop1.Property_Type__c = 'Lobby';
        prop1.Owner_Account__c = accountRec.Id;
        prop1.MDU_State__c = 'Florida';
        prop1.County__c = 'Bay County';
        prop1.Franchise_New__c = 'Parker City';         
        insert prop1;
        
        Opportunity_Property__c oppProp =  TestDataUtility.createOppProperty(opportunutyRec.id,prop1.id);
        oppProp.Primary_Property__c  = true;
        insert oppProp; 
       
        OpportunityContactRole OppContactRole = new OpportunityContactRole();
        OppContactRole = MDU_EmptorisUtility.fetchOpportunityContactRoleData(opportunutyRec.id);
        return opportunutyRec.id;
    }
    
    /* 
        Create opportunity record and return Id
    */
    private static Id createOpportunityOnly(){
        Account accountRec = createTestAccountData();
        Database.insert(accountRec);     
        //006K000000CIwh4 opportunity Id use to create record       
        Opportunity opportunutyRec = createOpportunity(accountRec.Id);             
        insert  opportunutyRec;
        return opportunutyRec.Id;
    }
    
    /* 
        Create Opportunity record
    */
    private static Opportunity createOpportunity(Id accountId){
        List<Opportunity> oppList = TestDataUtility.createOpportunity(2);            
        oppList[0].Contact_Email__c = 'vsadvdsv@dfhds.fdhdsf';
        oppList[0].Contact_First_Name__c = 'sadvadv';
        oppList[0].Contact_Last_Name__c = 'vdsadsv';                  
        oppList[0].Interview_Created_Date__c = 'date';
        oppList[0].StageName = 'Contract Document Review';
        oppList[0].ContractTermUnit__c = 'months';
        oppList[0].ContractTerm__c = 1;
        oppList[0].Contract_Type__c = 'Bulk';
        oppList[0].Video_Subs__c = 12;             
        oppList[0].Video_Bulk_Current_Rate__c = 2;
        oppList[0].Video_Bulk_Proposed_Rate__c = 2;        
        oppList[0].Video_Estimated_Revenue_Share_Rate__c = 2; 
        oppList[0].Video_Retail_Rate__c = 55;        
        oppList[0].Data_Subs__c = 10;       
        oppList[0].Data_Bulk_Current_Rate__c = 2;
        oppList[0].Data_Bulk_Proposed_Rate__c = 2;
        oppList[0].Data_Retail_Rate__c = 29;        
        oppList[0].Data_Estimated_Revenue_Share__c = 2; 
        oppList[0].Voice_Subs__c = 54;        
        oppList[0].Voice_Bulk_Current_Rate__c = 2;
        oppList[0].Voice_Bulk_Proposed_Rate__c = 2;       
        oppList[0].Voice_Estimated_Revenue_Share__c = 2; 
        oppList[0].Voice_Retail_Rate__c = 29;
        oppList[0].Per_Unit_Door_Fee__c = 2;
        oppList[0].IRR__c = 393;
        oppList[0].NPV__c = 137;
        oppList[0].Total_Equipment_Cost__c = 19393;
        oppList[0].Payback_Period_Months__c = 4;
        oppList[0].Construction_Capex_Cost__c = 2;
        oppList[0].Fiber_To_The_Unit__c = 'None';
        oppList[0].AccountId = accountId;  
        return  oppList[0];
    }
    
    
}