/*
* Description: Test Utility class to create required data for test execution.
*/
@isTest
public class TestDataUtility{

    private static final string RECORD_TYPE_SEPERATION = ';';
     
    /*
     Create test Account
    */
    public static Account createAccount() {   
        List<Id> recordTypeIds = new List<Id>();      
        String labelName = System.Label.XfinityAccountRecordType;  
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(RECORD_TYPE_SEPERATION)){
                recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }       
        Account acc = new Account();
        acc.RecordTypeId = recordTypeIds[0];
        acc.Name='Test123';
        acc.Zip_Code__c = '12345';
        acc.Description = 'test Desc';       
        return acc;
    }
    
    /*
    * Create test Contact
    */
     public static List<Contact> createContactRecord(Integer numCont) {
        Account acc = createAccount();
        insert acc;
        List<Contact> conList = new List<Contact>();
        for(Integer i=0;i<numCont;i++) {
            Contact con = new Contact();         
            con.lastname = 'Test Contact'+i;  
            con.firstname = 'first name'; 
            con.AccountId = acc.Id;    
            conList.add(con);
        }        
        return conList;  
           
    }
    
    /* 
    * Create Opportunity
    */
    public static List<Opportunity> createOpportunity(Integer numCont){
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0;i<numCont;i++) {
            Opportunity opp = new Opportunity();
            opp.Name ='Test Opportunity';
            opp.StageName = 'Assigned';
            opp.CloseDate =Date.today()+10;
            opp.Sales_Portfolio_Name__c = 'test@$#121212121'+i;        
            oppList.add(opp);
        }
        return oppList;
            
    }
   
    /*
    * Create Property
    */
    public static MDU_Property__c createProperty() {
        MDU_Property__c prop = new MDU_Property__c();
        // set all mandetory fields         
        prop.Address__c = 'Test Address';
        prop.Address_2__c = 'test address';
        prop.City__c = 'Pune';
        //prop.Name = 'Test Property';
        //prop.Property_Name_Address__c='magarpatta city';
        prop.MDU_State__c = 'Alaska';
        prop.County__c ='PH';       
        prop.Corporate__c = 'Comcast Cable';
        prop.PostalCode__c ='12345';
        prop.Property_Division__c = 'Central';
        prop.Property_Region__c = 'Florida';
        prop.Property_Area__c = 'NF Jacksonville';
        prop.System__c = '04 - Neptune Beach';
        prop.Industry_Type__c = 'Multi Family';
        prop.Property_Type__c = 'Assisted Living';
        prop.Number_of_Units__c = 101;
        prop.Comcast_Video_Serviced__c = 'Yes';
        prop.Video_Billing_Type__c = 'Bulk';        
        prop.Comcast_Data_Serviced__c = 'Yes';
        prop.Data_Billing_Type__c = 'Bulk';
        prop.Comcast_Voice_Serviced__c = 'Yes';
        prop.Voice_Billing_Type__c = 'Bulk';  
        prop.Increase_Period__c = 'None';
        prop.Contract_Video_Notice_Period__c = null;              
        return prop;  
    }
    
    /*
    * Create Opportunity Property
    */
    public static Opportunity_Property__c createOppProperty(Id oppId, Id propId) {
        Opportunity_Property__c oppPropInst = new Opportunity_Property__c();
        oppPropInst.Opportunity__c = oppId;
        oppPropInst.Property__c = propId;
        system.debug('Opportunity ID '+oppId + 'Property ID' +propId);
        return oppPropInst;
    }
    
    /*
    * Create New Build
    */
    public static New_Build__c createNewBuild(){
        MDU_Property__c prop = createProperty();
        insert prop;
        New_Build__c newBuild = new New_Build__c();
        newBuild.Completed_Status__c = false;
        newBuild.Property__c = prop.Id;
        newBuild.Status__c = 'Active';
        return newBuild;
    }
    
    /*
    * Create Phase Stats
    */    
    public static Phase_Stats__c createPhaseStats(){
        New_Build__c newBuild = createNewBuild();
        insert newBuild;
        Phase_Stats__c phStats = new Phase_Stats__c();
        phStats.Completed_Status__c= false;
        phStats.New_Build__c = newBuild.Id;
        return phStats;
    }
    
    /*
     Create Contract 
    */
    public static Contract__c createContract(id propertyId) {           
        //Create contract record
        Contract__c contract = new Contract__c();
        contract.Property__c = propertyId;                
        return contract;
    }
    
    /*
     Create MDU Zip Code Fiber Record
    */
    public static List<MDU_Zip_Code_Fiber__c> createMduZipCodeFiber() {           
        //Create contract record
        List<MDU_Zip_Code_Fiber__c> zipFiberList = new List<MDU_Zip_Code_Fiber__c>();
        for(integer i=0 ; i<2; i++){
           MDU_Zip_Code_Fiber__c zipFiberObject = new MDU_Zip_Code_Fiber__c();
           if(i == 0){
               zipFiberObject.Name ='Zip Fiber % Greater Than .35';
               zipFiberObject.Zip_Code__c = '10541';
               zipFiberObject.Fiber_Homes_Count__c = 9809;
               zipFiberObject.Total_Homes_Count__c = 9865;              
           }else{
               zipFiberObject.Name ='Zip Fiber % Less Than .35';
               zipFiberObject.Fiber_Homes_Count__c = 190;
               zipFiberObject.Total_Homes_Count__c = 1454;
               zipFiberObject.Zip_Code__c = '01431';    //fiber % == .13               
           }
           zipFiberList.add(zipFiberObject);
        }                        
        return zipFiberList;
    }
         
    /*
    * Create Bulk Rate Increase 
    */
    public static Bulk_Rate_Increase__c createBulkRateIncrease(id propertyId){
         Bulk_Rate_Increase__c bulkRateObject = new Bulk_Rate_Increase__c();
         bulkRateObject.Property__c = propertyId;         
         return bulkRateObject;
    }
    
    /*
    * Create Phase Stats
    */
    public static Bulk_Service__c createBulkService(id bulkRateIncreaseId){
         Bulk_Service__c bulkServiceObject = new Bulk_Service__c();
         bulkServiceObject.Bulk_Service__c = 'Test Bulk Service'; //Change for property lookup 
         bulkServiceObject.Bulk_Rate_Increase__c = bulkRateIncreaseId;
         return bulkServiceObject;
    }
    
    /*
    * Create User Object
    */
    public static User createUser(string profileId,string userLicense,string userRoleID){
        
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        System.debug('Random'+randomstr1 );
        User testUser = new User();
        testUser.City='Test City';
        testUser.Username = 'testash@gmail.com';
        testUser.LastName = 'First Last';       
        testUser.Email = 'storehomeuser1@test1.com';
        testUser.Alias = 'Test_';
        testUser.CommunityNickname = 'test';
        testUser.TimeZoneSidKey = 'America/Panama';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.ProfileId = profileId;
        testUser.DefaultDivision = '02dG0000000007HIAQ';
        testUser.FederationIdentifier = 'asd';
        //testUser.Profile.UserLicense.id = userLicense;
        testUser.UserRoleId  = userRoleID; 
        system.debug('User'+testUser )   ;   
        return testUser;                  
    } 
    
    /* Create Franchise Object */
     public static Franchise__c createFranchise(){
        Franchise__c franchiseObject = new Franchise__c();
        franchiseObject.County__c = 'Bay County';
        //franchiseObject.State_Name__c = 'Florida';
        franchiseObject.State_ID__c = 'FL';
        franchiseObject.Franchise_Name__c =  'Parker City' ;
        return franchiseObject;
    }
    
    /*
    * Get XC Integration Profile
    */
    public static Profile getXCIntegrationProfile(){
        return [Select Id, Name From Profile where Name = 'XC Integration Profile' limit 1];
    }
    
     /*
    * Get XC Account Executive Profile
    */
    public static Profile getXCAccountExecProfile(){
        return [Select Id, Name From Profile where Name = 'XC Account Executive' limit 1];
    }
     /*
    * Get DSR Manager Profile
    */
    public static Profile getDSRManagerProfile(){
        return [Select Id, Name From Profile where Name = :system.label.ASM_Profile_Name limit 1];
    }
    /*
    * Create XC Account Executive Profile User
    */
    public static User createXCAccountExecUser(){
        Profile p = getXCAccountExecProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User xcAccExecUser = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    LastName='Testing1',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
        insert xcAccExecUser;
        return xcAccExecUser;
        
    }
    /*
    * Create DSR Manager
    */
     public static User createDsrManagerUser(){
        Profile p = getDSRManagerProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User DSRManagerUser = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    LastName='Testing1',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
        insert DSRManagerUser;
        return DSRManagerUser;
        
    }
    /*
    * Create XC Integration User
    */
    public static User createXCIntegrationUser(){
        Profile p = getXCIntegrationProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1100)+'';
        User xcIntegrationUser = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest@SampleTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    FederationIdentifier = 'FedId'+randomstr,
                                    EmployeeNumber = 'Emp' + randomstr.substring(0,4));
        insert xcIntegrationUser;
        return xcIntegrationUser;
        
    }
     /*
    * Get Xfinity CAR Manager Profile
    */
         public static Profile getXfinityCARManagerProfile(){
        return [Select Id, Name From Profile where Name = 'Xfinity CAR Manager' limit 1];
    }
    /*
    * Create XfinityCAR Manager
    */
     public static User createXfinityCARManagerUser(){
        Profile p = getXfinityCARManagerProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User XfinityCARManagerUser = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    LastName='Testing1',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
      insert XfinityCARManagerUser;
        return XfinityCARManagerUser;
        
    }
      /*
    * Get Xfinity CAR  Profile
    */
         public static Profile getXfinityCARProfile(){
        return [Select Id, Name From Profile where Name = 'Xfinity CAR' limit 1];
    }
    /*
    * Create XfinityCAR 
    */
     public static User createXfinityCARUser(){
        Profile p = getXfinityCARProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User XfinityCARUser = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    LastName='Testing1',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
      insert XfinityCARUser;
        return XfinityCARUser;
        
    }
        
    /* Get System ADministrator  Profile
    */
    public static Profile getSAdminProfile(){
        return [Select Id, Name From Profile where Name = 'System Administrator' limit 1];
    }      
     /*
    * Create System Administrator Profile User
    */
    public static User createSAdminUser(){
        Profile p = getSAdminProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User AdminUser = new User(Alias = 'AE_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',                                    
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    IsActive = true,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today());
         
        insert AdminUser;    
        return AdminUser;
    }
                                             
        /*
    * Get RSA Profile
    */
    public static Profile getRSAProfile(){
        return [Select Id, Name From Profile where Name = 'Regional System Admin (RSA)' limit 1];
    }
        /*
    * Create RSA User
    */
     public static User createRSAUser(){
        Profile p = getRSAProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User RSAUser = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    LastName='Testing1',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
       insert RSAUser;
       return RSAUser;
        
    }
    
    
    /*
        Create Custom setting Record for Emptoris Integration
    */  
    public static List<MDU_EmptorisIntegrationCS__c> createIntegrationCS(){
        List<MDU_EmptorisIntegrationCS__c> integrationCSList = new List<MDU_EmptorisIntegrationCS__C>();
        Integer i=0;
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'sourceStr', Param_Value__c = 'DEFAULT'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'SEARCH_INTERVIEW_ENDPOINT', Param_Value__c = 'https://comcaststaging.emptoris.com/webservices/services/InterviewInstanceServices'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'BUILD_SSO_URL_WIZARD_ENDPOINT', Param_Value__c = 'https://comcaststaging.emptoris.com/webservices/services/SingleSignonServices'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'CREATE_INTERVIEW_ENDPOINT', Param_Value__c = 'https://comcaststaging.emptoris.com/webservices/services/InterviewInstanceServices'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'GETCONTRACTUSER_ENDPOINT', Param_Value__c = 'https://comcaststaging.emptoris.com/webservices/services/UserServices'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'GETCONTRACT_DETAILS_ENDPOINT', Param_Value__c = 'https://comcaststaging.emptoris.com/webservices/services/ContractServices'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'DELETE_CONTRACT_ENDPOINT', Param_Value__c = 'https://comcaststaging.emptoris.com/webservices/services/ContractServices'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'GET_CONTRACT_URL_ENDPOINT', Param_Value__c = 'https://comcaststaging.emptoris.com/webservices/services/SingleSignonServices'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'LAUNCH_EMPTORIS_URL_ENDPOINT', Param_Value__c = 'https://comcaststaging.emptoris.com/webservices/services/SingleSignonServices'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'HOST_URL', Param_Value__c = 'comcaststaging.emptoris.com'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'MduWriteBackUser', Param_Value__c = '!cdcemptorismdu'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'hostStr', Param_Value__c = ''));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'algoStr', Param_Value__c = 'MD5'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'SHARED SECRET', Param_Value__c = '_SHARED_SECRET_'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'EmptorisOrgID', Param_Value__c = '82425a405b9043d892bb074cc6a22bfe'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'EmptorisAccount', Param_Value__c = 'usertomanageindividual'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'usertodeletecontract', Param_Value__c = 'usertodeletecontract'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'SEARCH_INDIVIDUAL_ENDPOINT', Param_Value__c = 'https://comcaststaging.emptoris.com/webservices/services/IndividualServices'));
        integrationCSList.add(new MDU_EmptorisIntegrationCS__c(Name = String.valueOf(++i), Param_Name__c = 'CREATE_INDIVIDUAL_ENDPOINT', Param_Value__c = 'https://comcaststaging.emptoris.com/webservices/services/IndividualServices'));                       
        return integrationCSList;
    }
    
        /*
        Create Custom setting Record for Emptoris Field Mapping
    */ 
    public static List<MDU_EmptorisFieldMapping__c> createEmptorisFieldMapping(){
        List<MDU_EmptorisFieldMapping__c> emptorisFieldMappingList = new List<MDU_EmptorisFieldMapping__c>();
        Integer i=0;        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MDUContractPropertyFee', DIRECT_Object_Property__c = 'TotalSupportFee', ECM_Variable_Data_Type__c = 'Decimal', ECM_Variable_ID__c = 'de96371f99014a9d92d030394f396095', ECM_Variable_Internal_Name__c='total_compensation', ECM_Variable_Mapping_ID__c=127, ECM_Variable_Name__c='Total Amount of Compensation', ECM_Variable_Sequence__c='TD_64',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c=''));        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= '', DIRECT_Object_Property__c = '', ECM_Variable_Data_Type__c = 'Decimal', ECM_Variable_ID__c = 'ffa30f7f894b47cdb9ff0f61b81f2fb0', ECM_Variable_Internal_Name__c='total_monthly_billing', ECM_Variable_Mapping_ID__c=91, ECM_Variable_Name__c='Total Monthly Billing', ECM_Variable_Sequence__c='TD_148',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c=''));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Complex_County', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '9d52d9caf48f4587886feaf63d13e1c0', ECM_Variable_Internal_Name__c='property_county_easement', ECM_Variable_Mapping_ID__c=365, ECM_Variable_Name__c='Property County Easement', ECM_Variable_Sequence__c='property_county_easement',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='County__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Owner_Address_1', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '5547d5e7b863428c962791fc67e5ee5c', ECM_Variable_Internal_Name__c='customer_add_1', ECM_Variable_Mapping_ID__c=148, ECM_Variable_Name__c='Customer Address Line 1', ECM_Variable_Sequence__c='TD_67',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='owner_account_street__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Owner_Address_State', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = 'cdd6ca01a1fc43f2868ba7b5a4c7f34c', ECM_Variable_Internal_Name__c='customer_add_state', ECM_Variable_Mapping_ID__c=149, ECM_Variable_Name__c='Customer Address State', ECM_Variable_Sequence__c='TD_70',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='owner_account_mduState__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Owner_Address_2', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = 'be0f54ded5a84b5f8f3f931c8ce96cc8', ECM_Variable_Internal_Name__c='customer_add_2', ECM_Variable_Mapping_ID__c=151, ECM_Variable_Name__c='Customer Address Line 2', ECM_Variable_Sequence__c='TD_68',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='BLANK'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Owner_Address_City', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '6b4a299d643040b9b7a132001fd93cc2', ECM_Variable_Internal_Name__c='customer_add_city', ECM_Variable_Mapping_ID__c=152, ECM_Variable_Name__c='Customer Address City', ECM_Variable_Sequence__c='TD_69',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='owner_account_city__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Complex_Name', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '015b3e563b854e028280988215a93891', ECM_Variable_Internal_Name__c='property_name', ECM_Variable_Mapping_ID__c=156, ECM_Variable_Name__c='Property Name', ECM_Variable_Sequence__c='TD_78',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Name'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Complex_Address_1', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = 'eee07796d8da409483f7cdfb11e03172', ECM_Variable_Internal_Name__c='property_add_1', ECM_Variable_Mapping_ID__c=158, ECM_Variable_Name__c='Property Address Line 1', ECM_Variable_Sequence__c='TD_79',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Address__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Complex_County', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '3b93ce2e8b2f402887925f1596bf57ca', ECM_Variable_Internal_Name__c='property_county', ECM_Variable_Mapping_ID__c=161, ECM_Variable_Name__c='Property County', ECM_Variable_Sequence__c='TD_84',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='County__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Complex_Address_2', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = 'e0fdc38e2749454f863ef09594b7969a', ECM_Variable_Internal_Name__c='property_add_2', ECM_Variable_Mapping_ID__c=162, ECM_Variable_Name__c='Property Address Line 2', ECM_Variable_Sequence__c='TD_80',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Address_2__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'State', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = 'ccf76b27265044c691df901d316cce0d', ECM_Variable_Internal_Name__c='franchise_state', ECM_Variable_Mapping_ID__c=163, ECM_Variable_Name__c='Franchise State', ECM_Variable_Sequence__c='TD_94',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='MDU_State__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Complex_City', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '5cb00e965aa24c55b3b1da59cfe84b38', ECM_Variable_Internal_Name__c='property_add_city', ECM_Variable_Mapping_ID__c=171, ECM_Variable_Name__c='Property Address City', ECM_Variable_Sequence__c='TD_81',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='City__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'State_Abbreviation', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = 'cba2445afe474eccb309fc5014249ded', ECM_Variable_Internal_Name__c='property_add_state', ECM_Variable_Mapping_ID__c=172, ECM_Variable_Name__c='Property Address State', ECM_Variable_Sequence__c='TD_82',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='State_Name__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Property_Grade', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '0da2e1e8d69a4af280033ec5a6affbc8', ECM_Variable_Internal_Name__c='property_grade', ECM_Variable_Mapping_ID__c=214, ECM_Variable_Name__c='Property Grade', ECM_Variable_Sequence__c='TD_268',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Property_Grade__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'State', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = 'c2c137de883b4042a22e7c631d006379', ECM_Variable_Internal_Name__c='property_state_long', ECM_Variable_Mapping_ID__c=256, ECM_Variable_Name__c='Property State Long', ECM_Variable_Sequence__c='TD_327',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='MDU_State__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'MDU_Complex_ID', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '01ad410e08ab46258b37657dcd5eeb32', ECM_Variable_Internal_Name__c='property_id', ECM_Variable_Mapping_ID__c=283, ECM_Variable_Name__c='Property ID', ECM_Variable_Sequence__c='TD_230',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Id'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Owner_Address_Zip', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = 'ab67c7ffbfad4b9988b15043deac3b3d', ECM_Variable_Internal_Name__c='customer_addr_zip', ECM_Variable_Mapping_ID__c=314, ECM_Variable_Name__c='Customer Address Zip', ECM_Variable_Sequence__c='TD_238',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='owner_account_zipcode__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Owner_Name', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '7fd6b5ac56114c8e94c67b3e3e8da6c2', ECM_Variable_Internal_Name__c='owner_name', ECM_Variable_Mapping_ID__c=320, ECM_Variable_Name__c='Owner Name', ECM_Variable_Sequence__c='TD_298',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='owner_account_name__c'));
                
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Complex_Zip', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '7aa589b08d314f55aa572231d44b1df4', ECM_Variable_Internal_Name__c='property_addr_zip', ECM_Variable_Mapping_ID__c=323, ECM_Variable_Name__c='Property Address Zip', ECM_Variable_Sequence__c='TD_239',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='PostalCode__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Owner_Address_2', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '7fd7b0e0b83c4aef89db2c081b3b1b1a', ECM_Variable_Internal_Name__c='owner_add_2', ECM_Variable_Mapping_ID__c=324, ECM_Variable_Name__c='Owner Address Line 2', ECM_Variable_Sequence__c='TD_303',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='BLANK'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Owner_Address_State', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '7b76a9aab8114f29b085940fe31fc84c', ECM_Variable_Internal_Name__c='owner_add_state', ECM_Variable_Mapping_ID__c=325, ECM_Variable_Name__c='Owner Address State', ECM_Variable_Sequence__c='TD_301',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='owner_account_mduState__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Owner_Address_1', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '36e8fcc5152d43669b15aa5f804adf55', ECM_Variable_Internal_Name__c='owner_add_1', ECM_Variable_Mapping_ID__c=326, ECM_Variable_Name__c='Owner Address Line 1', ECM_Variable_Sequence__c='TD_304',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='owner_account_street__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Owner_Address_Zip', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '03bad234009a4392b0cbf4b88c8b3fe2', ECM_Variable_Internal_Name__c='owner_addr_zip', ECM_Variable_Mapping_ID__c=327, ECM_Variable_Name__c='Owner Address Zip', ECM_Variable_Sequence__c='TD_300',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='owner_account_zipcode__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Owner_Address_City', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = 'bcae9aed70174090bc4871f51c91fc57', ECM_Variable_Internal_Name__c='owner_add_city', ECM_Variable_Mapping_ID__c=329, ECM_Variable_Name__c='Owner Address City', ECM_Variable_Sequence__c='TD_305',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='owner_account_city__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Risk_Status', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = 'e46d636966be4866bd96f467d204ad42', ECM_Variable_Internal_Name__c='risk_status', ECM_Variable_Mapping_ID__c=363, ECM_Variable_Name__c='Risk Status', ECM_Variable_Sequence__c='risk_status',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Risk_Status__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Property_Rating', ECM_Variable_Data_Type__c = 'Decimal', ECM_Variable_ID__c = 'be27d5483a1544108d9dc8f050c3a2b6', ECM_Variable_Internal_Name__c='property_rating', ECM_Variable_Mapping_ID__c=364, ECM_Variable_Name__c='Property Rating', ECM_Variable_Sequence__c='property_rating',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Property_Rating__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Property_Type', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '256854193dad4a659135711b31320498', ECM_Variable_Internal_Name__c='property_type', ECM_Variable_Mapping_ID__c=98, ECM_Variable_Name__c='Property Type', ECM_Variable_Sequence__c='TD_155',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Property_Type__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Comcast_Legal_Entity', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '34fd4ffddea846d3a95dd1f8951ec28d', ECM_Variable_Internal_Name__c='comcast_legal_entity_name', ECM_Variable_Mapping_ID__c=122, ECM_Variable_Name__c='Comcast Legal Entity Name', ECM_Variable_Sequence__c='TD_56',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='comcast_legal_name_hidden__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Owner_Name', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = 'b24286fdb3234400bb5c3c70c5eef565', ECM_Variable_Internal_Name__c='customer_name', ECM_Variable_Mapping_ID__c=125, ECM_Variable_Name__c='Customer Name', ECM_Variable_Sequence__c='TD_59',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='owner_account_name__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Complex_Units_Count', ECM_Variable_Data_Type__c = 'Decimal', ECM_Variable_ID__c = '2b2d9cfb003c44a39c14d9bcf7c0fd2f', ECM_Variable_Internal_Name__c='number_of_units', ECM_Variable_Mapping_ID__c=130, ECM_Variable_Name__c='Number of Units', ECM_Variable_Sequence__c='TD_89',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Number_of_Units__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Franchise_Name', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '3d40822a6136405daaa7c14bb266a1bc', ECM_Variable_Internal_Name__c='franchise_name', ECM_Variable_Mapping_ID__c=131, ECM_Variable_Name__c='Franchise Name', ECM_Variable_Sequence__c='TD_91',Mapping_Function_Name__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Franchise_Name_Hidden__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Comcast_Legal_Entity', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '86e34e42ce084d8c8fe7ca07e247e714', ECM_Variable_Internal_Name__c='comcast_legal_entity_add_1', ECM_Variable_Mapping_ID__c=138, ECM_Variable_Name__c='Comcast Legal Entity Address Line 1', ECM_Variable_Sequence__c='TD_136',Mapping_Function_Name__c='', Object__c='Legal_Entity__c', SFDC_Field_Name__c='Legal_Entity_Address_Street__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Comcast_Legal_Entity', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '6bc051be2d81451ab0d55f7b0b3fb75e', ECM_Variable_Internal_Name__c='comcast_legal_entity_add_city', ECM_Variable_Mapping_ID__c=139, ECM_Variable_Name__c='Comcast Legal Entity Address City', ECM_Variable_Sequence__c='TD_138',Mapping_Function_Name__c='', Object__c='Legal_Entity__c', SFDC_Field_Name__c='Legal_Entity_Address_City__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Comcast_Legal_Entity', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = 'e917b5df7a2e4a748fadac94767b4b5c', ECM_Variable_Internal_Name__c='comcast_legal_entity_add_2', ECM_Variable_Mapping_ID__c=140, ECM_Variable_Name__c='Comcast Legal Entity Address Line 2', ECM_Variable_Sequence__c='TD_137',Mapping_Function_Name__c='', Object__c='Legal_Entity__c', SFDC_Field_Name__c='Legal_Entity_Address_Line2__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Comcast_Legal_Entity', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '2749628a43574886a9cb0989bd5e4044', ECM_Variable_Internal_Name__c='comcast_legal_entity_add_state', ECM_Variable_Mapping_ID__c=141, ECM_Variable_Name__c='Comcast Legal Entity Address State', ECM_Variable_Sequence__c='TD_140',Mapping_Function_Name__c='', Object__c='Legal_Entity__c', SFDC_Field_Name__c='Legal_Entity_Address_State_ID__c'));
        
        emptorisFieldMappingList.add(new MDU_EmptorisFieldMapping__c(Name = String.valueOf(++i), DIRECT_Object__c= 'MduComplexLite', DIRECT_Object_Property__c = 'Comcast_Legal_Entity', ECM_Variable_Data_Type__c = 'String', ECM_Variable_ID__c = '9d09f0ab5e734062aa67a0bf7c8952fd', ECM_Variable_Internal_Name__c='comcast_legal_entity_add_zip', ECM_Variable_Mapping_ID__c=143, ECM_Variable_Name__c='Comcast Legal Entity Address Zip', ECM_Variable_Sequence__c='TD_141',Mapping_Function_Name__c='', Object__c='Legal_Entity__c', SFDC_Field_Name__c='Legal_Entity_Address_Zip__c'));
        
        database.insert(emptorisFieldMappingList);
        return emptorisFieldMappingList;
    }
      
    
    /*
        Create Custom setting Record for Trigger user in MDU application
    */ 
    public static void createCustomSettingRecords() {
    
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        System.runAs(user) { 
            List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
            
            TriggerSettings__c mduPropertyTrigger = new TriggerSettings__c();
            mduPropertyTrigger.Name = 'PropertyTrigger';
            mduPropertyTrigger.isActive__c = True;
            triggerSettingsList.add(mduPropertyTrigger);
                    
            TriggerSettings__c phaseStatsTrigger = new TriggerSettings__c();
            phaseStatsTrigger.Name = 'PhaseStatsTrigger';
            phaseStatsTrigger.isActive__c = True;
            triggerSettingsList.add(phaseStatsTrigger);
            
            TriggerSettings__c mduBulkServiceTrigger = new TriggerSettings__c();
            mduBulkServiceTrigger.Name = 'BulkServiceTrigger';
            mduBulkServiceTrigger.isActive__c = True;
            triggerSettingsList.add(mduBulkServiceTrigger);
            
            TriggerSettings__c mduOpportunityPropertyTrigger = new TriggerSettings__c();
            mduOpportunityPropertyTrigger.Name = 'OpportunityPropertyTrigger';
            mduOpportunityPropertyTrigger.isActive__c = True;
            triggerSettingsList.add(mduOpportunityPropertyTrigger); 
            
            TriggerSettings__c opportunityTrigger = new TriggerSettings__c();
            opportunityTrigger.Name = 'OpportunityTrigger';
            opportunityTrigger.isActive__c = True;
            triggerSettingsList.add(opportunityTrigger);
            
            TriggerSettings__c contactTrigger = new TriggerSettings__c();
            contactTrigger.Name = 'ContactTrigger';
            contactTrigger.isActive__c = True;
            triggerSettingsList.add(contactTrigger);
            
            TriggerSettings__c newBuildTrigger = new TriggerSettings__c();
            newBuildTrigger.Name = 'NewBuildTrigger';
            newBuildTrigger.isActive__c = True;
            triggerSettingsList.add(newBuildTrigger);
            
            TriggerSettings__c contractTrigger = new TriggerSettings__c();
            contractTrigger.Name = 'ContractTrigger';
            contractTrigger.isActive__c = True;
            triggerSettingsList.add(contractTrigger);
            
            TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = True;
            triggerSettingsList.add(userTrigger);
            
            TriggerSettings__c xfinityOptyTrigger = new TriggerSettings__c();
            xfinityOptyTrigger.Name = 'XfinityOpportunityTrigger';
            xfinityOptyTrigger.isActive__c = True;
            triggerSettingsList.add(xfinityOptyTrigger);
            
            TriggerSettings__c xfinityAccTrigger = new TriggerSettings__c();
            xfinityAccTrigger.Name = 'XfinityAccountTrigger';
            xfinityAccTrigger.isActive__c = True;
            triggerSettingsList.add(xfinityAccTrigger );
            
            TriggerSettings__c AccTrigger = new TriggerSettings__c();
            AccTrigger.Name = 'AccountTrigger';
            AccTrigger.isActive__c = True;
            triggerSettingsList.add(AccTrigger);
            
            TriggerSettings__c GoalTrigger = new TriggerSettings__c();
            GoalTrigger.Name = 'GoalTrigger';
            GoalTrigger.isActive__c = True;
            triggerSettingsList.add(GoalTrigger);
            
            TriggerSettings__c MetricTrigger = new TriggerSettings__c();
            MetricTrigger.Name = 'MetricTrigger';
            MetricTrigger.isActive__c = True;
            triggerSettingsList.add(MetricTrigger);
            
            TriggerSettings__c PropertyVisitTrigger = new TriggerSettings__c();
            PropertyVisitTrigger .Name = 'PropertyVisitTrigger';
            PropertyVisitTrigger .isActive__c = True;
            triggerSettingsList.add(PropertyVisitTrigger);
            
            insert triggerSettingsList;
        }
    } 
    
    /*
    Create Legal Entity Data
    */
    public static List<Legal_Entity__c> createLegalEntityList(){
        List<Legal_Entity__c> legalEntityList = new List<Legal_Entity__c>();    
        Integer i=0;
        legalEntityList.add(new Legal_Entity__c(Legal_Entity_Name__c = 'Adelphia Cablevision of West Palm Beach III, LLC',Name = 'Test '+ String.valueOf(++i)));
        legalEntityList.add(new Legal_Entity__c(Legal_Entity_Name__c = 'Alabama T.V. Cable, Inc.',Name = 'Test '+ String.valueOf(++i)));
        return legalEntityList;
    }   
        
    /*
    * Create Legal Franchise Data
    */
    public static List<Franchise__c> createFranchiseList(){
        List<Legal_Entity__c> legalEntityList = createLegalEntityList();
        List<Franchise__c> franchiseList = new List<Franchise__c>();
        Database.Insert(legalEntityList);
        System.debug('Entity List'+legalEntityList[0].Id +' , '+ legalEntityList[1].Id);
        //StateId 'AL' => State Name 'Alabama'
        //StateId 'AK' => State Name 'Alaska'
        franchiseList.add(new Franchise__c(Franchise_Name__c = 'Abbeville City', State_ID__c = 'AL', County__c = 'Harford County' , Legal_Entity__c = Id.valueOf(legalEntityList[0].Id)));
        franchiseList.add(new Franchise__c(Franchise_Name__c = 'Aberdeen Town', State_ID__c = 'AK',  County__c = 'Blackford', Legal_Entity__c = Id.valueOf(legalEntityList[1].Id)));  
        return franchiseList;             
    }
    
    /*
    * custom settings to ByPass validation  
    */
    public static void bypassValidationCS(Id userId){
                
        ValidationSetting__c validationSetting = new ValidationSetting__c(SetupOwnerId = userId, Name = 'Test', Disable_Validation_Rule__c = true);
        insert validationSetting; 
    } 
    
    /*
        Create Custom setting Record for Interview Template Mapping
    */ 
    public static List<MDU_InterviewTemplateMapping__c> createInterviewTemplateMapping(){
        List<MDU_InterviewTemplateMapping__c> interviewTemplateMappingList = new List<MDU_InterviewTemplateMapping__c>();
        Integer i=0;
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='data_retail_rate_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Data_Retail_Rate__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='voice_retail_rate_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Voice_Retail_Rate__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='video_bulk_current_rate_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Video_Bulk_Current_Rate__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='data_bulk_current_rate_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Data_Bulk_Current_Rate__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='voice_bulk_current_rate_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Voice_Bulk_Current_Rate__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='video_service_fee_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Video_Bulk_Proposed_Rate__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='data_service_fee_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Data_Bulk_Proposed_Rate__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='irr_hidden', Data_Type__c='Integer', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='IRR__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='npv_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='NPV__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='total_equip_cost_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Total_Equipment_Cost__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='portfolio_prop_count_hidden', Data_Type__c='Integer', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Total_Properties__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='portfolio_unit_total_hidden', Data_Type__c='Integer', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Number_of_Units__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='owner_address1_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='OpportunityProperty', SFDC_Field_Name__c='owner_account_street__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='owner_city_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='OpportunityProperty', SFDC_Field_Name__c='owner_account_city__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='owner_state_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='OpportunityProperty', SFDC_Field_Name__c='owner_account_mduState__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='owner_zip_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='OpportunityProperty', SFDC_Field_Name__c='owner_account_zipcode__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='developer_name_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='OpportunityProperty', SFDC_Field_Name__c='Developer_Account_Name__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='developer_address1_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='OpportunityProperty', SFDC_Field_Name__c='developer_account_address__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='developer_city_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='OpportunityProperty', SFDC_Field_Name__c='developer_account_city__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='developer_state_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='OpportunityProperty', SFDC_Field_Name__c='developer_account_state__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='franchise_state_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='MDU_State__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='ae_area_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='BLANK_PROP', SFDC_Field_Name__c='', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='ae_region_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='BLANK_PROP', SFDC_Field_Name__c='', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='ae_division_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='BLANK_PROP', SFDC_Field_Name__c='', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='comcast_legal_name_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='comcast_legal_name_hidden__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='comcast_legal_address1_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='BLANK_PROP', SFDC_Field_Name__c='', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='comcast_legal_address2_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='BLANK_PROP', SFDC_Field_Name__c='', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='comcast_legal_city_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='BLANK_PROP', SFDC_Field_Name__c='', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='comcast_legal_state_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='BLANK_PROP', SFDC_Field_Name__c='', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='voice_service_fee_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Voice_Bulk_Proposed_Rate__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='video_monthly_revenue_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Video_Monthly_Revenue__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='data_monthly_revenue_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Data_Monthly_Revenue__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='voice_monthly_revenue_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Voice_Monthly_Revenue__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='video_est_revshare_rate_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Video_Estimated_Revenue_Share_Rate__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='data_est_revshare_rate_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Data_Estimated_Revenue_Share__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='voice_est_revshare_rate_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Voice_Estimated_Revenue_Share__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='compensation_per_unit_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Per_Unit_Door_Fee__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='data_subs_hidden', Data_Type__c='Integer', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Data_Subs__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='voice_subs_hidden', Data_Type__c='Integer', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Voice_Subs__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='video_penetration_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Video_Penetration__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='data_penetration_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Data_Penetration__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='voice_penetration_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Voice_Penetration__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='video_retail_rate_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Video_Retail_Rate__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='comcast_legal_zip_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='BLANK_PROP', SFDC_Field_Name__c='', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='risk_status_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Risk_Status__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='opportunity_info', Data_Type__c='String', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='opportunity_info__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='opp_id_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Id', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='opp_type_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Type', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='service_type_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Contract_Type__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='fiber_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Fiber_To_The_Unit__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='owner_name_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='OpportunityProperty', SFDC_Field_Name__c='owner_account_name__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='number_of_units_hidden', Data_Type__c='Integer', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Number_of_Units__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='property_rating_hidden', Data_Type__c='Integer', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Property_Rating__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='total_contract_value_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Gross_Contract_Value__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='bulk_discount_rate_hidden', Data_Type__c='Integer', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Video_Bulk_Discount__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='data_bulk_discount_rate_hidden', Data_Type__c='Integer', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Data_Bulk_Discount__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='voice_bulk_disc_rate_hidden', Data_Type__c='Integer', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Voice_Bulk_Discount__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='video_subs_hidden', Data_Type__c='Integer', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Video_Subs__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='payback_period_hidden', Data_Type__c='Integer', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Payback_Period_Months__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='construction_cost_hidden', Data_Type__c='Decimal', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Construction_Capex_Cost__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='property_name_address', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Property_Name_Address__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='property_info', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Property_Info__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='property_id_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Id', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='property_name_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='name', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='property_address1_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Address__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='property_address2_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Address_2__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='property_city_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='City__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='property_county_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='County__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='property_state_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='MDU_State__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='property_state_short_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='State_Name__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='property_zip_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='PostalCode__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='industry_type_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Industry_Type__c', Template__c='mdu_residential' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='property_type_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Property_Type__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='franchise_name_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='MDU_Property__c', SFDC_Field_Name__c='Franchise_Name_Hidden__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='franchise_location_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='BLANK_PROP', SFDC_Field_Name__c='', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='developer_zip_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='OpportunityProperty', SFDC_Field_Name__c='developer_account_zip__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='contract_term_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='ContractTerm__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='contract_term_unit_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='ContractTermUnit__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='portfolio_indicator_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='portfolio_indicator_hidden__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='portfolio_name_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='Opportunity', SFDC_Field_Name__c='Sales_Portfolio_Name__c', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='ae_corp_hidden', Data_Type__c='String', Fixed_Value__c='Comcast Cable', Object__c='FIXED_PROP', SFDC_Field_Name__c='', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='developer_address2_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='BLANK_OPP', SFDC_Field_Name__c='', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
        
        interviewTemplateMappingList.add(new MDU_InterviewTemplateMapping__c(Name = String.valueOf(++i), Attribute_Name__c='owner_address2_hidden', Data_Type__c='String', Fixed_Value__c='', Object__c='BLANK_OPP', SFDC_Field_Name__c='', Template__c='mdu_residential, mdu_residential_sfu, mdu_education, mdu_hospitality, mdu_healthcare' ));
    
        database.insert(interviewTemplateMappingList);
        return interviewTemplateMappingList;
    }  

    /*
        Create Custom setting Record for Contract Extraction
    */ 
    public static void createContractExtractionCS(){
        List<MDU_ContractExtraction__c> ContractExtractionList = new List<MDU_ContractExtraction__c>();
        Integer i=0;
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Contract_Term_Renew_Unit', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='39653b4a0a324b9790df80d4dc13223b', ECM_Variable_Internal_Name__c='renewal_period_unit', ECM_Variable_Mapping_ID__c='18', ECM_Variable_Name__c='Renewal Period Unit', ECM_Variable_Sequence__c='TD_114', Mapping_Function_Name__c='GetContractTermUnit', SFDC_Field_API_Name__c='Renewal_Term_Unit__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Common_Area_Courtesy_DATA_Outlets', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='813203b4501a42c9af67586013273f72', ECM_Variable_Internal_Name__c='num_common_courtesy_hsi', ECM_Variable_Mapping_ID__c='19', ECM_Variable_Name__c='Number of Common Courtesy HSI Outlets', ECM_Variable_Sequence__c='TD_201', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Data_Outlets__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Contract_DoorToDoor_Sales', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='cfc99163b2cc424db0fbdd0cea0fb63d', ECM_Variable_Internal_Name__c='direct_sales_permitted', ECM_Variable_Mapping_ID__c='20', ECM_Variable_Name__c='Direct Sales Permitted', ECM_Variable_Sequence__c='TD_129', Mapping_Function_Name__c='GetDirectSales', SFDC_Field_API_Name__c='Door_to_Door_Sales_Permitted__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Home_Owned_By', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='6cd0a6764d6747f586def824b16ae136', ECM_Variable_Internal_Name__c='chw_owned_by', ECM_Variable_Mapping_ID__c='21', ECM_Variable_Name__c='CHW Owned By', ECM_Variable_Sequence__c='TD_186', Mapping_Function_Name__c='GetOwnerComcastAsInt', SFDC_Field_API_Name__c='Home_Owned_By__c', SFDC_Object__c='Contract__c' ));
                
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Home_Run_Installed_By', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='d8b95660b8b04c1a881306fa1a481929', ECM_Variable_Internal_Name__c='chrw_will_be_installed_by', ECM_Variable_Mapping_ID__c='22', ECM_Variable_Name__c='CHRW Will Be Installed By', ECM_Variable_Sequence__c='TD_192', Mapping_Function_Name__c='GetComcastOwnerPreExistingAsInt', SFDC_Field_API_Name__c='Home_Run_Installed_By__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Data_Billing_Type_ID', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='561618c85269415a9a187aaa6e2c60d6', ECM_Variable_Internal_Name__c='billing_type_hsi', ECM_Variable_Mapping_ID__c='23', ECM_Variable_Name__c='Billing Type HSI', ECM_Variable_Sequence__c='TD_162', Mapping_Function_Name__c='GetBulkRetailAsInt', SFDC_Field_API_Name__c='Data_Billing_Type__c', SFDC_Object__c='Contract__c' ));
                
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Voice', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='f430cb14984543a989d52cc3e1312362', ECM_Variable_Internal_Name__c='contract_service_cdv', ECM_Variable_Mapping_ID__c='24', ECM_Variable_Name__c='Contract Service CDV', ECM_Variable_Sequence__c='TD_171', Mapping_Function_Name__c='GetYesNoFromContractServiceAsInt', SFDC_Field_API_Name__c='Voice__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Assignment_ID', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='0360398b1ea14b8d8f2e658378f6c339', ECM_Variable_Internal_Name__c='assignability_type', ECM_Variable_Mapping_ID__c='3', ECM_Variable_Name__c='Assignability Type', ECM_Variable_Sequence__c='TD_173', Mapping_Function_Name__c='GetAssignabilityTypeAsInt', SFDC_Field_API_Name__c='Assignment_ID__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Installed_By', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='8fe298d47b234686854a18df11761911', ECM_Variable_Internal_Name__c='insertion_equip_installed_by', ECM_Variable_Mapping_ID__c='4', ECM_Variable_Name__c='Insertion Equipment Installed By', ECM_Variable_Sequence__c='TD_181', Mapping_Function_Name__c='GetOwnerComcastAsIntForInsertion', SFDC_Field_API_Name__c='Insertion_Equip_Installed_By__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Distribution_Owned_By', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='14a4bba959f94ac095f4eca606e50a36', ECM_Variable_Internal_Name__c='distribution_owned_by', ECM_Variable_Mapping_ID__c='5', ECM_Variable_Name__c='Distribution Owned By', ECM_Variable_Sequence__c='TD_183', Mapping_Function_Name__c='GetOwnerComcastAsInt', SFDC_Field_API_Name__c='Distribution_Owned_By__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Data_Marketing_Rights', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='d89888bf0acb46d0b62cebc1dda2c20b', ECM_Variable_Internal_Name__c='marketing_rights_hsi', ECM_Variable_Mapping_ID__c='6', ECM_Variable_Name__c='Marketing Rights - HSI', ECM_Variable_Sequence__c='TD_134', Mapping_Function_Name__c='GetNoneNonExclusiveExclusiveAsInt', SFDC_Field_API_Name__c='Data_Marketing_Rights__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Video_Marketing_Rights', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='3d647ff4107e4c988aba00faf33ef523', ECM_Variable_Internal_Name__c='marketing_rights_video', ECM_Variable_Mapping_ID__c='7', ECM_Variable_Name__c='Marketing Rights - Video', ECM_Variable_Sequence__c='TD_133', Mapping_Function_Name__c='GetNoneNonExclusiveExclusiveAsInt', SFDC_Field_API_Name__c='Video_Marketing_Rights__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Common_Area_Courtesy_Video_Outlets', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='66372370fbf7476eb5440ed8ba190673', ECM_Variable_Internal_Name__c='num_common_courtesy_video', ECM_Variable_Mapping_ID__c='9', ECM_Variable_Name__c='Number of Common Courtesy Video Outlets', ECM_Variable_Sequence__c='TD_199', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Video_Outlets__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Individual_Recipient_Courtesy_Video_Outlets', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='ce9317256c7c4f57a23625ba5a1a0ef2', ECM_Variable_Internal_Name__c='num_individual_courtesy_video', ECM_Variable_Mapping_ID__c='12', ECM_Variable_Name__c='Number of Individual Courtesy Video Outlets', ECM_Variable_Sequence__c='TD_204', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Recipient_Video_Outlets__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Home_Run_Owned_By', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='5739549a9c6b49f48c941ae9fd83edb0', ECM_Variable_Internal_Name__c='chrw_owned_by', ECM_Variable_Mapping_ID__c='13', ECM_Variable_Name__c='CHRW Owned By', ECM_Variable_Sequence__c='TD_196', Mapping_Function_Name__c='GetOwnerComcastAsInt', SFDC_Field_API_Name__c='Home_Run_Owned_By__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Video', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='1697fac8fc054ef6925c36700332d63e', ECM_Variable_Internal_Name__c='contract_service_video', ECM_Variable_Mapping_ID__c='14', ECM_Variable_Name__c='Contract Service Video', ECM_Variable_Sequence__c='TD_169', Mapping_Function_Name__c='GetYesNoFromContractServiceAsInt', SFDC_Field_API_Name__c='Video__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Data', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='c2a5aa29d7d542cdb25d58b9bb606ff9', ECM_Variable_Internal_Name__c='contract_service_hsi', ECM_Variable_Mapping_ID__c='15', ECM_Variable_Name__c='Contract Service HSI', ECM_Variable_Sequence__c='TD_170', Mapping_Function_Name__c='GetYesNoFromContractServiceAsInt', SFDC_Field_API_Name__c='Data__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Voice_Billing_Type_ID', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='9bbb880f97cc460892833938628f858e', ECM_Variable_Internal_Name__c='billing_type_cdv', ECM_Variable_Mapping_ID__c='16', ECM_Variable_Name__c='Billing Type CDV', ECM_Variable_Sequence__c='TD_165', Mapping_Function_Name__c='GetBulkRetailAsInt', SFDC_Field_API_Name__c='Voice_Billing_Type__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Distribution_Maintained_By', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='c3a274c3f41745a298351a38e0359e42', ECM_Variable_Internal_Name__c='distribution_maintained_by', ECM_Variable_Mapping_ID__c='17', ECM_Variable_Name__c='Distribution Maintained By', ECM_Variable_Sequence__c='TD_177', Mapping_Function_Name__c='GetOwnerComcastAsInt', SFDC_Field_API_Name__c='Distribution_Maintained_By__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Home_ExclusiveUse', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='92f84492e2724a1c8390728a02c50c61', ECM_Variable_Internal_Name__c='chw_exclusive', ECM_Variable_Mapping_ID__c='28', ECM_Variable_Name__c='CHW Exclusive', ECM_Variable_Sequence__c='TD_190', Mapping_Function_Name__c='GetYesNoAsInt', SFDC_Field_API_Name__c='Home_Exclusive_Use__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Home_Run_Paid_By', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='f082ccc42d9848d6a7c6300f1dcb38ec', ECM_Variable_Internal_Name__c='chrw_paid_by', ECM_Variable_Mapping_ID__c='29', ECM_Variable_Name__c='CHRW Paid By', ECM_Variable_Sequence__c='TD_195', Mapping_Function_Name__c='GetComcastOwnerPreExistingAsInt', SFDC_Field_API_Name__c='Home_Run_Paid_By__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Owned_By', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='9c88da399a3a42d39e40d8ffd6c150da', ECM_Variable_Internal_Name__c='insertion_equip_owned_by', ECM_Variable_Mapping_ID__c='30', ECM_Variable_Name__c='Insertion Equipment Owned By', ECM_Variable_Sequence__c='TD_180', Mapping_Function_Name__c='GetOwnerComcastAsIntForInsertion', SFDC_Field_API_Name__c='Insertion_Equip_Owned_By__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Contract_COI', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='cb009c23c3a64cd9a93fda0e446c599f', ECM_Variable_Internal_Name__c='certificate_of_insurance', ECM_Variable_Mapping_ID__c='31', ECM_Variable_Name__c='Certificate of Insurance', ECM_Variable_Sequence__c='TD_182', Mapping_Function_Name__c='GetCertificateOfInsuranceAsInt', SFDC_Field_API_Name__c='Certificate_of_Insurance_Required__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Voice_Marketing_Rights', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='d996dccad37f4342b06fedc3e5673917', ECM_Variable_Internal_Name__c='marketing_rights_cdv', ECM_Variable_Mapping_ID__c='32', ECM_Variable_Name__c='Marketing Rights - CDV', ECM_Variable_Sequence__c='TD_135', Mapping_Function_Name__c='GetNoneNonExclusiveExclusiveAsInt', SFDC_Field_API_Name__c='Voice_Marketing_Rights__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='HomeRun_ExclusiveUse', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='ae934324c32145659d30b63582955352', ECM_Variable_Internal_Name__c='chrw_exclusive', ECM_Variable_Mapping_ID__c='33', ECM_Variable_Name__c='CHRW Exclusive', ECM_Variable_Sequence__c='TD_198', Mapping_Function_Name__c='GetYesNoAsInt', SFDC_Field_API_Name__c='Home_Run_Exclusive_Use__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Distribution_ExclusiveUse', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='4ddf49613f9b4e428d2e33366cfd5501', ECM_Variable_Internal_Name__c='distribution_exclusive', ECM_Variable_Mapping_ID__c='34', ECM_Variable_Name__c='Distribution Exclusive', ECM_Variable_Sequence__c='TD_200', Mapping_Function_Name__c='GetYesNoAsInt', SFDC_Field_API_Name__c='Distribution_Exclusive_Use__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Contract_Expiration', ECM_Variable_Data_Type__c='Date', ECM_Variable_ID__c='ccb47e0da5bc45999a0904fe2bf2b8bd', ECM_Variable_Internal_Name__c='effective_end_date', ECM_Variable_Mapping_ID__c='35', ECM_Variable_Name__c='Effective_End_Date', ECM_Variable_Sequence__c='TD_38', Mapping_Function_Name__c='CalculateContractDates', SFDC_Field_API_Name__c='Expiration_Date__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Home_Maintained_By', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='7524ecc24e974010ae8761d08b13c30a', ECM_Variable_Internal_Name__c='chw_maintained_by', ECM_Variable_Mapping_ID__c='36', ECM_Variable_Name__c='CHW Maintained By', ECM_Variable_Sequence__c='TD_184', Mapping_Function_Name__c='GetOwnerComcastAsInt', SFDC_Field_API_Name__c='Home_Maintained_By__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Equipment_Type_ID', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='9693aaf3312340d0859814a2f54516f1', ECM_Variable_Internal_Name__c='digital_video_equipment', ECM_Variable_Mapping_ID__c='37', ECM_Variable_Name__c='Digital Video Equipment', ECM_Variable_Sequence__c='TD_285', Mapping_Function_Name__c='GetEquipmentType', SFDC_Field_API_Name__c='Equipment__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Contract_Term_Renew', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='babb71a705234320b47750d998197d04', ECM_Variable_Internal_Name__c='renewal_period', ECM_Variable_Mapping_ID__c='39', ECM_Variable_Name__c='Renewal Period', ECM_Variable_Sequence__c='TD_108', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Renewal_Term__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Video_Increase_Notice', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='6016e95a70c743c784791cdbcfcaa1a6', ECM_Variable_Internal_Name__c='bulk_rate_increase_notice_peri', ECM_Variable_Mapping_ID__c='55', ECM_Variable_Name__c='Bulk Rate Increase Notice Period', ECM_Variable_Sequence__c='TD_111', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Video_Increase_Notice__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractPropertyFee', DIRECT_Object_Property__c='Per_Unit_Door_Fee', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='bc0a845c238b412caa5a3d262579cf46', ECM_Variable_Internal_Name__c='compensation_per_unit', ECM_Variable_Mapping_ID__c='58', ECM_Variable_Name__c='Door Fee per Unit', ECM_Variable_Sequence__c='TD_115', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='Property_Fees__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Contract_Effective', ECM_Variable_Data_Type__c='Date', ECM_Variable_ID__c='cf770ce99c0140318ea807d010966277', ECM_Variable_Internal_Name__c='effective_start_date', ECM_Variable_Mapping_ID__c='82', ECM_Variable_Name__c='Effective_Start_Date', ECM_Variable_Sequence__c='TD_39', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Effective_Date__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Converters_Per_Unit', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='dd1a1393b63b4b01a3de87f8ff03deae', ECM_Variable_Internal_Name__c='number_of_receivers', ECM_Variable_Mapping_ID__c='95', ECM_Variable_Name__c='Number of Receivers', ECM_Variable_Sequence__c='TD_151', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Converters_per_Unit__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Number_Channels', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='04fcb23d8532479b92cb02f777964a20', ECM_Variable_Internal_Name__c='insertion_channel_num', ECM_Variable_Mapping_ID__c='108', ECM_Variable_Name__c='Number of Channels', ECM_Variable_Sequence__c='TD_174', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Number_of_Channels__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Distribution_Paid_By', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='af5acb38647c4b22bf4f90ff66314fa1', ECM_Variable_Internal_Name__c='distribution_paid_by', ECM_Variable_Mapping_ID__c='109', ECM_Variable_Name__c='Distribution Paid By', ECM_Variable_Sequence__c='TD_178', Mapping_Function_Name__c='GetComcastOwnerPreExistingAsInt', SFDC_Field_API_Name__c='Distribution_Paid_By__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractPropertyFee', DIRECT_Object_Property__c='TotalSupportFee', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='de96371f99014a9d92d030394f396095', ECM_Variable_Internal_Name__c='total_compensation', ECM_Variable_Mapping_ID__c='127', ECM_Variable_Name__c='Total Amount of Compensation', ECM_Variable_Sequence__c='TD_64', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Total_Support_Fee__c', SFDC_Object__c='Property_Fees__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractPropertyFee', DIRECT_Object_Property__c='Video_Min_Payment_Percent', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='53d1b0d7e2434e6c93efcdba3bc668bb', ECM_Variable_Internal_Name__c='rev_share_min_pen', ECM_Variable_Mapping_ID__c='132', ECM_Variable_Name__c='Revenue Share Min Penetration with Payment - Video', ECM_Variable_Sequence__c='TD_117', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Video_Minimum_Penetration_w_Payment__c', SFDC_Object__c='Property_Fees__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractPropertyFee', DIRECT_Object_Property__c='Video_Max_PayRate_Percent', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='032ff6d548734b18ac361ab94c28f642', ECM_Variable_Internal_Name__c='rev_share_max_sliding_rate', ECM_Variable_Mapping_ID__c='135', ECM_Variable_Name__c='Revenue Share at Maximum Slide Rate - Video', ECM_Variable_Sequence__c='TD_119', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Video_Maximum_Pay_Rate__c', SFDC_Object__c='Property_Fees__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractPropertyFee', DIRECT_Object_Property__c='Video_Payment_At_Fifty_Percent', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='299840770d3b463da03d16b640f32642', ECM_Variable_Internal_Name__c='rev_share_50_pen', ECM_Variable_Mapping_ID__c='136', ECM_Variable_Name__c='Revenue Share at 50% Penetration - Video', ECM_Variable_Sequence__c='TD_116', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Video_Payment_at_50_Penetration__c', SFDC_Object__c='Property_Fees__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Contract_Name', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='4d8ea59d01dc4a08bbd4b63fc3a4db30', ECM_Variable_Internal_Name__c='agreement_name', ECM_Variable_Mapping_ID__c='145', ECM_Variable_Name__c='Agreement Name', ECM_Variable_Sequence__c='TD_49', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Name', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractBulkServiceType', DIRECT_Object_Property__c='Service_Type_ID', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='8158c7b8fa6044efb0f9a43deafa9d7d', ECM_Variable_Internal_Name__c='bulk_service_type', ECM_Variable_Mapping_ID__c='155', ECM_Variable_Name__c='Bulk Service Type (Residential)', ECM_Variable_Sequence__c='TD_77', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Service_Type__c', SFDC_Object__c='Contracted_Bulk_Service__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Contract_Term', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='7256e716e4f74dcb93e2398947b5b449', ECM_Variable_Internal_Name__c='contract_term', ECM_Variable_Mapping_ID__c='160', ECM_Variable_Name__c='Contract Term', ECM_Variable_Sequence__c='TD_96', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Contract_Term__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Premium_Service', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='f4a1b06e9fa042f681dfea9f80f9bfd1', ECM_Variable_Internal_Name__c='bulk_premium_services', ECM_Variable_Mapping_ID__c='165', ECM_Variable_Name__c='Bulk Premium Services', ECM_Variable_Sequence__c='TD_107', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Premium_Service__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Video_Outlets_Per_Unit', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='57096b74e3b8476290117ce7f4c7721d', ECM_Variable_Internal_Name__c='video_number_of_outlets', ECM_Variable_Mapping_ID__c='166', ECM_Variable_Name__c='Video Number of Outlets', ECM_Variable_Sequence__c='TD_101', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Video_Outlets_Per_Unit__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Data_Outlets_Per_Unit', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='5f0ad993a8344001a557c012dec300fb', ECM_Variable_Internal_Name__c='internet_number_of_outlets', ECM_Variable_Mapping_ID__c='175', ECM_Variable_Name__c='Internet Number of Outlets', ECM_Variable_Sequence__c='TD_105', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Data_Outlets_Per_Unit__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Home_Paid_By', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='830ebda0a71643c8a99b3cc4b71218ad', ECM_Variable_Internal_Name__c='chw_paid_by', ECM_Variable_Mapping_ID__c='179', ECM_Variable_Name__c='CHW Paid By', ECM_Variable_Sequence__c='TD_187', Mapping_Function_Name__c='GetComcastOwnerPreExistingAsInt', SFDC_Field_API_Name__c='Home_Paid_By__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Common_Area_Courtesy_Level_of_Video_Service', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='92386c4095f64be5b1b4ac11eca05dbf', ECM_Variable_Internal_Name__c='level_of_cable_service', ECM_Variable_Mapping_ID__c='182', ECM_Variable_Name__c='Courtesy Account - Common Area - Level of Cable Service', ECM_Variable_Sequence__c='TD_207', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Video_Service_Level__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Common_Area_Courtesy_Level_of_DATA_Service', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='7619a5d591a941afbd7dd56583e26bb7', ECM_Variable_Internal_Name__c='level_of_internet_service', ECM_Variable_Mapping_ID__c='184', ECM_Variable_Name__c='Courtesy Account - Common Area - Level of Internet Service', ECM_Variable_Sequence__c='TD_208', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Data_Service_Level__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Video_Rate_Escalator', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='ddfb98fe401c41c09af1978f1b77b2ae', ECM_Variable_Internal_Name__c='video_bulk_rate_escalator', ECM_Variable_Mapping_ID__c='187', ECM_Variable_Name__c='Video Bulk Rate Escalator (%)', ECM_Variable_Sequence__c='TD_216', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Video_Rate_Escalator__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Home_Installed_By', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='75a54d41af304b6d8a6281ad4a987a2c', ECM_Variable_Internal_Name__c='chw_wiring', ECM_Variable_Mapping_ID__c='189', ECM_Variable_Name__c='CHW Wiring', ECM_Variable_Sequence__c='TD_215', Mapping_Function_Name__c='GetComcastOwnerPreExistingAsInt', SFDC_Field_API_Name__c='Home_Installed_By__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Distribution_Installed_By', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='7b5c45d20a964cecbea595f022df3961', ECM_Variable_Internal_Name__c='distribution', ECM_Variable_Mapping_ID__c='190', ECM_Variable_Name__c='Distribution Wiring', ECM_Variable_Sequence__c='TD_213', Mapping_Function_Name__c='GetComcastOwnerPreExistingAsInt', SFDC_Field_API_Name__c='Distribution_Installed_by__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Data_Rate_Escalator', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='188d49cb33444220b2699e9b14a9089f', ECM_Variable_Internal_Name__c='internet_bulk_rate_escalator', ECM_Variable_Mapping_ID__c='191', ECM_Variable_Name__c='Data Bulk Rate Escalator (%)', ECM_Variable_Sequence__c='TD_217', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Data_Rate_Escalator__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractPropertyFee', DIRECT_Object_Property__c='Door_Fees', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='f462d1652c574b8eaef4cbff47d7ef16', ECM_Variable_Internal_Name__c='door_fee_provision', ECM_Variable_Mapping_ID__c='193', ECM_Variable_Name__c='Door Fee Provision?', ECM_Variable_Sequence__c='TD_219', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='Property_Fees__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractPropertyFee', DIRECT_Object_Property__c='Recurring_Fees', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='19e3a9f869784d26b595863c3031134f', ECM_Variable_Internal_Name__c='revenue_share_provision', ECM_Variable_Mapping_ID__c='195', ECM_Variable_Name__c='Revenue Share Provision?', ECM_Variable_Sequence__c='TD_221', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='Property_Fees__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractPropertyFee', DIRECT_Object_Property__c='Revenue_Sharing_Type_ID', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='fe8edfaffd51477688200f722330a6d7', ECM_Variable_Internal_Name__c='revenue_share_lob', ECM_Variable_Mapping_ID__c='196', ECM_Variable_Name__c='Revenue Share Lines of Business', ECM_Variable_Sequence__c='TD_222', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='Property_Fees__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Voice_Units', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='0147f89ec303434290663263da9a27bd', ECM_Variable_Internal_Name__c='cdv_units', ECM_Variable_Mapping_ID__c='198', ECM_Variable_Name__c='CDV Units', ECM_Variable_Sequence__c='TD_257', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Voice_Units__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Data_Units', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='6b61f6dcf30c4a3389dd3f42a29e4a99', ECM_Variable_Internal_Name__c='hsd_units', ECM_Variable_Mapping_ID__c='200', ECM_Variable_Name__c='HSD Units', ECM_Variable_Sequence__c='TD_255', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Data_Units__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Voice_Outlets_Per_Unit', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='b2f368e4399346a5b110a6b3f647ae1a', ECM_Variable_Internal_Name__c='voice_number_of_outlets', ECM_Variable_Mapping_ID__c='249', ECM_Variable_Name__c='Voice Number of Outlets', ECM_Variable_Sequence__c='TD_307', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Voice_Outlets_Per_Unit__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractPropertyFee', DIRECT_Object_Property__c='FeeTerms', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='9281656743d54df1ba274ec314b297d9', ECM_Variable_Internal_Name__c='comp_payable_with', ECM_Variable_Mapping_ID__c='254', ECM_Variable_Name__c='Compensation Payable Within', ECM_Variable_Sequence__c='TD_329', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Payment_Terms__c', SFDC_Object__c='Property_Fees__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Video_Increase_Period', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='3d3d87915ddb44cbaeb0f9dd071cff83', ECM_Variable_Internal_Name__c='bulk_rate_increase_period_unit', ECM_Variable_Mapping_ID__c='271', ECM_Variable_Name__c='Bulk Rate Increase Period Unit', ECM_Variable_Sequence__c='TD_249', Mapping_Function_Name__c='GetBulkRateIncreasePeriodAsInt', SFDC_Field_API_Name__c='Video_Increase_Period__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Maintained_By', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='50f8efb179a04b5cbff99613087dff84', ECM_Variable_Internal_Name__c='insertion_equip_maintained_by', ECM_Variable_Mapping_ID__c='25', ECM_Variable_Name__c='Insertion Equipment Maintained By', ECM_Variable_Sequence__c='TD_179', Mapping_Function_Name__c='GetOwnerComcastAsIntForInsertion', SFDC_Field_API_Name__c='Insertion_Equip_Maintained_By__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Contract_Term_Unit', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='2f38183d26e84762acb07ca92f31cb52', ECM_Variable_Internal_Name__c='contract_term_unit', ECM_Variable_Mapping_ID__c='26', ECM_Variable_Name__c='Contract Term Unit', ECM_Variable_Sequence__c='TD_97', Mapping_Function_Name__c='GetContractTermUnit', SFDC_Field_API_Name__c='Contract_Term_Unit__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Contract_Term_Cancel', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='eca89cfe5f454826bbf0196571975d57', ECM_Variable_Internal_Name__c='termination_notice_period', ECM_Variable_Mapping_ID__c='27', ECM_Variable_Name__c='Auto-Renew Termination Notice Period', ECM_Variable_Sequence__c='TD_125', Mapping_Function_Name__c='ParseTermPeriod', SFDC_Field_API_Name__c='Days_to_Cancel__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractPropertyFee', DIRECT_Object_Property__c='Data_Min_Payment_Percent', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='365725a058d14dbe896dc9ccdeb96a1a', ECM_Variable_Internal_Name__c='rev_share_min_pen_data', ECM_Variable_Mapping_ID__c='286', ECM_Variable_Name__c='Revenue Share Min Penetration with Payment - Data', ECM_Variable_Sequence__c='TD_331', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Data_Minimum_Penetration_w_Payment__c', SFDC_Object__c='Property_Fees__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractPropertyFee', DIRECT_Object_Property__c='Data_Max_PayRate_Percent', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='084b3d7e715540c7a7405fffab1ffb30', ECM_Variable_Internal_Name__c='rev_share_max_sliding_rate_dat', ECM_Variable_Mapping_ID__c='289', ECM_Variable_Name__c='Revenue Share at Maximum Slide Rate - Data', ECM_Variable_Sequence__c='TD_334', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Data_Maximum_Pay_Rate__c', SFDC_Object__c='Property_Fees__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractPropertyFee', DIRECT_Object_Property__c='Data_Payment_At_Fifty_Percent', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='fd2af6c4c7e54ee8b0c218c0a9190268', ECM_Variable_Internal_Name__c='rev_share_50_pen_data', ECM_Variable_Mapping_ID__c='291', ECM_Variable_Name__c='Revenue Share at 50% Penetration - Data', ECM_Variable_Sequence__c='TD_332', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Data_Payment_at_50_Penetration__c', SFDC_Object__c='Property_Fees__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractPropertyFee', DIRECT_Object_Property__c='Voice_Min_Payment_Percent', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='3768a22d7ad44bc39c5f60cd5e016c7c', ECM_Variable_Internal_Name__c='rev_share_min_pen_voice', ECM_Variable_Mapping_ID__c='292', ECM_Variable_Name__c='Revenue Share Min Penetration with Payment - Voice', ECM_Variable_Sequence__c='TD_335', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Voice_Minimum_Penetration_w_Payment__c', SFDC_Object__c='Property_Fees__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractPropertyFee', DIRECT_Object_Property__c='Voice_Max_PayRate_Percent', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='83698cff5d944e82921dad096f5ee189', ECM_Variable_Internal_Name__c='rev_share_max_sliding_rate_voi', ECM_Variable_Mapping_ID__c='294', ECM_Variable_Name__c='Revenue Share at Maximum Slide Rate - Voice', ECM_Variable_Sequence__c='TD_337', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Voice_Maximum_Pay_Rate__c', SFDC_Object__c='Property_Fees__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractPropertyFee', DIRECT_Object_Property__c='Voice_Payment_At_Fifty_Percent', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='8b9284cbed7444e582e3695b1244a47b', ECM_Variable_Internal_Name__c='rev_share_50_pen_voice', ECM_Variable_Mapping_ID__c='296', ECM_Variable_Name__c='Revenue Share at 50% Penetration - Voice', ECM_Variable_Sequence__c='TD_336', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Voice_Payment_at_50_Penetration__c', SFDC_Object__c='Property_Fees__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Service_Type_ID', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='cdd4c3d1e8164037a87429c03048cbf9', ECM_Variable_Internal_Name__c='coutesy_account_type', ECM_Variable_Mapping_ID__c='310', ECM_Variable_Name__c='Courtesy Account Type(s)', ECM_Variable_Sequence__c='TD_205', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Individual_Recipient_Video_Units', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='2d6659a2823947cebadc0a60e86cad38', ECM_Variable_Internal_Name__c='court_indiv_num_of_units_vid', ECM_Variable_Mapping_ID__c='312', ECM_Variable_Name__c='Courtesy Individual Account Num of Units Video', ECM_Variable_Sequence__c='TD_209', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Recipients_Video_Units__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Individual_Recipient_Video_Level_of_Service', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='4d73cafa339b4765bcfae73aff9c2426', ECM_Variable_Internal_Name__c='level_of_cable_service_ind', ECM_Variable_Mapping_ID__c='313', ECM_Variable_Name__c='Courtesy Account - Individual - Level of Cable Service', ECM_Variable_Sequence__c='TD_224', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Recipient_Video_Service_Level__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContractBulkServiceType', DIRECT_Object_Property__c='Service_Type_ID', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='be4bb06bc80248c5bb3a03d4fdb3b4aa', ECM_Variable_Internal_Name__c='bulk_service_type_hospitality', ECM_Variable_Mapping_ID__c='319', ECM_Variable_Name__c='Bulk Service Type (Hospitality)', ECM_Variable_Sequence__c='TD_236', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Service_Type__c', SFDC_Object__c='Contracted_Bulk_Service__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Home_Run_Maintained_By', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='bb496b15d68e46c992b4028b8ba02c45', ECM_Variable_Internal_Name__c='chrw_maintained_by', ECM_Variable_Mapping_ID__c='1', ECM_Variable_Name__c='CHRW Maintained By', ECM_Variable_Sequence__c='TD_194', Mapping_Function_Name__c='GetOwnerComcastAsInt', SFDC_Field_API_Name__c='Home_Run_Maintained_By__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MDUContract', DIRECT_Object_Property__c='Video_Billing_Type_ID', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='2027995844284de195d60615c67743be', ECM_Variable_Internal_Name__c='billing_type_videp', ECM_Variable_Mapping_ID__c='2', ECM_Variable_Name__c='Billing Type Video', ECM_Variable_Sequence__c='TD_161', Mapping_Function_Name__c='GetBulkRetailAsInt', SFDC_Field_API_Name__c='Video_Billing_Type__c', SFDC_Object__c='Contract__c' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='93481a326c8b48b189637b1218ee4937', ECM_Variable_Internal_Name__c='chrw_wiring', ECM_Variable_Mapping_ID__c='186', ECM_Variable_Name__c='CHRW Wiring', ECM_Variable_Sequence__c='TD_214', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='eebe28fd383c4764a958c5249de58659', ECM_Variable_Internal_Name__c='chw_will_be_installed_by', ECM_Variable_Mapping_ID__c='100', ECM_Variable_Name__c='CHW Will Be Installed By', ECM_Variable_Sequence__c='TD_191', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='980b0e12f389412f98c8912821555638', ECM_Variable_Internal_Name__c='auto_renew_limit', ECM_Variable_Mapping_ID__c='168', ECM_Variable_Name__c='Auto Renew Limit', ECM_Variable_Sequence__c='TD_98', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='160a2c03eca04366b9ccec7f4c7de2a1', ECM_Variable_Internal_Name__c='insertion_channel_agreement', ECM_Variable_Mapping_ID__c='106', ECM_Variable_Name__c='Channel Agreement', ECM_Variable_Sequence__c='TD_172', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='17ec4a421d3c478b98eb1957a6caa753', ECM_Variable_Internal_Name__c='video_subs', ECM_Variable_Mapping_ID__c='270', ECM_Variable_Name__c='Video Subs', ECM_Variable_Sequence__c='TD_399', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='8f2815a7af9b478d8f6dae7bc8b6fd6b', ECM_Variable_Internal_Name__c='equipment_quantity_dct', ECM_Variable_Mapping_ID__c='288', ECM_Variable_Name__c='Digital Video Equipment Quantity - DCT', ECM_Variable_Sequence__c='TD_309', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='ae3eb387ecef46edbe754c2a8adf7384', ECM_Variable_Internal_Name__c='equipment_quantity_dta', ECM_Variable_Mapping_ID__c='287', ECM_Variable_Name__c='Digital Video Equipment Quantity - DTA', ECM_Variable_Sequence__c='TD_308', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='fa550887e94d4dd1928e6c5364c5d11e', ECM_Variable_Internal_Name__c='opportunity_id', ECM_Variable_Mapping_ID__c='281', ECM_Variable_Name__c='Opportunity ID', ECM_Variable_Sequence__c='TD_229', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MduComplexLite', DIRECT_Object_Property__c='MDU_Complex_ID', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='01ad410e08ab46258b37657dcd5eeb32', ECM_Variable_Internal_Name__c='property_id', ECM_Variable_Mapping_ID__c='283', ECM_Variable_Name__c='Property ID', ECM_Variable_Sequence__c='TD_230', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='b378c44d681e4998b6c51ba1253f455a', ECM_Variable_Internal_Name__c='service_fee_per_unit', ECM_Variable_Mapping_ID__c='86', ECM_Variable_Name__c='Monthly Video Service Fee Per Unit', ECM_Variable_Sequence__c='TD_145', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='df710e69457d4c328679ab25bd1c31e1', ECM_Variable_Internal_Name__c='industry_type', ECM_Variable_Mapping_ID__c='94', ECM_Variable_Name__c='Industry Type', ECM_Variable_Sequence__c='TD_152', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='ec7b7cb495814e05952bfc822f8ce069', ECM_Variable_Internal_Name__c='billing_type', ECM_Variable_Mapping_ID__c='103', ECM_Variable_Name__c='Billing Type', ECM_Variable_Sequence__c='TD_160', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='MduComplexLite', DIRECT_Object_Property__c='Complex_Units_Count', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='2b2d9cfb003c44a39c14d9bcf7c0fd2f', ECM_Variable_Internal_Name__c='number_of_units', ECM_Variable_Mapping_ID__c='130', ECM_Variable_Name__c='Number of Units', ECM_Variable_Sequence__c='TD_89', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='String', ECM_Variable_ID__c='96e412193c63498cbe3b256aed289edc', ECM_Variable_Internal_Name__c='bulk_unit_outlet_type', ECM_Variable_Mapping_ID__c='251', ECM_Variable_Name__c='Bulk Service to Unit or Outlet', ECM_Variable_Sequence__c='TD_312', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='9872a3529d864e25a5b0886e08057dce', ECM_Variable_Internal_Name__c='hsi_service_fee_per_unit', ECM_Variable_Mapping_ID__c='258', ECM_Variable_Name__c='Monthly Data Service Fee Per Unit', ECM_Variable_Sequence__c='TD_242', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='ae3eb387ecef46edbe754c2a8adf7384', ECM_Variable_Internal_Name__c='equipment_quantity_dta', ECM_Variable_Mapping_ID__c='287', ECM_Variable_Name__c='Digital Video Equipment Quantity - DTA', ECM_Variable_Sequence__c='TD_308', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='8f2815a7af9b478d8f6dae7bc8b6fd6b', ECM_Variable_Internal_Name__c='equipment_quantity_dct', ECM_Variable_Mapping_ID__c='288', ECM_Variable_Name__c='Digital Video Equipment Quantity - DCT', ECM_Variable_Sequence__c='TD_309', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='3ce2d313c5d4464cb7e90ebefb474e0d', ECM_Variable_Internal_Name__c='voice_bulk_bill_rate', ECM_Variable_Mapping_ID__c='317', ECM_Variable_Name__c='Monthly Voice Service Fee Per Unit', ECM_Variable_Sequence__c='TD_232', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='', SFDC_Object__c='' ));
        
        ContractExtractionList.add(new MDU_ContractExtraction__c(Name = String.valueOf(++i), DIRECT_Object__c='', DIRECT_Object_Property__c='', ECM_Variable_Data_Type__c='Decimal', ECM_Variable_ID__c='9c9df262b67b486e9160776f4dc052a9', ECM_Variable_Internal_Name__c='bulk_master_account_number', ECM_Variable_Mapping_ID__c='38', ECM_Variable_Name__c='zzz_Bulk Master Account Number', ECM_Variable_Sequence__c='TD_106', Mapping_Function_Name__c='', SFDC_Field_API_Name__c='Bulk_Account_Number__c', SFDC_Object__c='MDUContract' ));
        
        Database.insert(ContractExtractionList);
    }   
    
    /*
        Create Custom setting Record for Interview Template Mapping
    */ 
    public static void createMduPublicGrpRgnAreaCS(){
        List<MduPublicGrpRgnArea__c> MduPublicGrpRgnAreaList = new List<MduPublicGrpRgnArea__c>();
        Integer i=0;
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='', Group_Name__c='XC Beltway Region', Region__c='Beltway'));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='Bay Area', Division__c='', Group_Name__c='XC CA Bay Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='Central', Division__c='', Group_Name__c='XC CA Central Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='', Group_Name__c='XC Greater Chicago Region', Region__c='Greater Chicago'));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='', Group_Name__c='XC Houston Region', Region__c='Houston'));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='', Group_Name__c='XC Keystone Region', Region__c='Keystone'));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='', Group_Name__c='XC Mile High Region', Region__c='Mile High Region'));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='', Group_Name__c='XC Mountain Region', Region__c='Mountain Region'));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='NF Jacksonville', Division__c='', Group_Name__c='XC North Florida Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='NF Lake County/Orlando', Division__c='', Group_Name__c='XC North Florida Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='NF PC/Tally', Division__c='', Group_Name__c='XC North Florida Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='', Group_Name__c='XC Oregon/SW WA Region', Region__c='Oregon/SW Washington'));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='SF Broward County', Division__c='', Group_Name__c='XC South Florida Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='SF Miami/Dade/FL Keys', Division__c='', Group_Name__c='XC South Florida Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='SWF Cape Coral/Naples', Division__c='', Group_Name__c='XC Southwest Florida Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='SWF Sarasota/Ven/PtC/Seb', Division__c='', Group_Name__c='XC Southwest Florida Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='', Group_Name__c='XC Washington Region', Region__c='Washington'));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='WP Central', Division__c='', Group_Name__c='XC WP Florida Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='WP North', Division__c='', Group_Name__c='XC WP Florida Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='WP South', Division__c='', Group_Name__c='XC WP Florida Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='', Group_Name__c='XC Big South Region', Region__c='Big South'));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='', Group_Name__c='XC Freedom Region', Region__c='Freedom Market'));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='', Group_Name__c='XC Western NE Region', Region__c='Western NE'));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='', Group_Name__c='XC Greater Boston Region', Region__c='Greater Boston Region'));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='Central', Group_Name__c='XC North Florida Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='Central', Group_Name__c='XC South Florida Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='Central', Group_Name__c='XC Southwest Florida Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='Central', Group_Name__c='XC WP Florida Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='Central', Group_Name__c='XC Greater Chicago Region', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='Northeast', Group_Name__c='XC Beltway Region', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='Northeast', Group_Name__c='XC Freedom Region', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='Northeast', Group_Name__c='XC Keystone Region', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='West', Group_Name__c='XC Houston Region', Region__c=''));
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='West', Group_Name__c='XC Mile High Region', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='West', Group_Name__c='XC Mountain Region', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='West', Group_Name__c='XC CA Bay Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='West', Group_Name__c='XC CA Central Area', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='West', Group_Name__c='XC Oregon/SW WA Region', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='West', Group_Name__c='XC Washington Region', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='Northeast', Group_Name__c='XC Western NE Region', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='Northeast', Group_Name__c='XC Greater Boston Region', Region__c=''));
        
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='Central', Group_Name__c='XC Big South Region', Region__c=''));
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='', Group_Name__c='XC Twin Cities Region', Region__c='Twin Cities'));
        MduPublicGrpRgnAreaList.add(new MduPublicGrpRgnArea__c(Name = String.valueOf(++i), Area__c='', Division__c='', Group_Name__c='XC Heartland Region', Region__c='Heartland'));
    
        Database.insert(MduPublicGrpRgnAreaList);
    }
    
    /*
       This method enable Application log creation functionality to current User or Profile
    */   
    public static void setApplicationLogEnableCS(Id profileOrUserId){
         MDU_UserAppLoggingCS__c applicationLogSetting = new MDU_UserAppLoggingCS__c(SetupOwnerId = profileOrUserId);
         Database.insert(applicationLogSetting);
    }
    
    /*
       This method enable Allow Parent account Change for current User or Profile
    */   
    public static void setAllowParentAccChange(Id profileOrUserId){
         MDU_AllowParentAccChange__c allowParentAccChangeSetting = new MDU_AllowParentAccChange__c(SetupOwnerId = profileOrUserId);
         allowParentAccChangeSetting.Disable_Validation__c= true;
         Database.insert(allowParentAccChangeSetting);
    }
    /*
       This method creates records for custom setting Training Region-wise Access Setting
    */ 
   public static void createTrainingRegionCSRecords(){
        List<User_Feature_Permission_Setting__c> TrainingRegionCSList = new List<User_Feature_Permission_Setting__c>();
        User_Feature_Permission_Setting__c XfinityCAR = new User_Feature_Permission_Setting__c();
        XfinityCAR.Name = 'Xfinity CAR';
        XfinityCAR.Channel__c = 'Property Lab';
        TrainingRegionCSList.add(XfinityCAR);
        Database.insert(TrainingRegionCSList);
    }
    public static void createTrainingRegionCSRecords1(){
        List<User_Feature_Permission_Setting__c> TrainingRegionCSList1 = new List<User_Feature_Permission_Setting__c>();
        User_Feature_Permission_Setting__c XfinityCARManager = new User_Feature_Permission_Setting__c();
        XfinityCARManager.Name = 'Xfinity CAR Manager';
        XfinityCARManager.Channel__c = 'Property Lab';
        TrainingRegionCSList1.add(XfinityCARManager);
        Database.insert(TrainingRegionCSList1);
    }
    
    
}