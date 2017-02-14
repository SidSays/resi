/***************************************************************************************************************************************
 * Author     : Vivek Patel, Accenture
 * Date       : 03-June-2013
 * Description: This class creates required test data.
 * History
     Version             : 1.0
     Author Last Updated : Vivek Patel, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class SetupTestData {

    public static User dsrUser,dsrUser2,dsrUser3,dsrUser4, Contractor;
    public static User supervisorUser;
    public static User managerUser;
    public static User carManagerUser; 
    public static User businessAdminUser;
    public static Store_Settings__c storeSettings;
    public static EmailTemplate emailTemplate;
    private static          Profile p1 = [Select UserType, UserLicenseId, Name From Profile where Name like 'XFINITY Sales Professional'];
    private static     UserRole r1 = [Select Id, Name from UserRole where Name='DSR'];
    private static     UserRole r5 = [Select Id, Name from UserRole where Name='Contractor'];
    private static     Profile p2 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Sales Development Manager'];
    private static    UserRole r2 = [Select Id, Name from UserRole where Name='DS Supervisor'];
     private static    Profile p3 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Area Sales Manager'];
    private static     UserRole r3 = [Select Id, Name from UserRole where Name='DS Manager'];
    private static     Profile p4 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Business Administrator'];
    private static     UserRole r4 = [Select Id, Name from UserRole where Name='National Manager'];
    private static     Profile p5 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Xfinity CAR Manager'];
    public static void createUsers() {
        //generate Random String 
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr2 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr3 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr4 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr5 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr6 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr7 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr8 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr9 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        businessAdminUser = new User(Alias = 'DA_' + randomstr4.substring(0,4),
                                    Email = randomstr4 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p4.Id,
                                    UserRoleId = r4.Id,
                                    Username = 'userTest' + randomstr4 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    FederationIdentifier = 'FedId1',
                                    EmployeeNumber = 'Emp' + randomstr4.substring(0,4));
        insert businessAdminUser;
        managerUser = new User(Alias = 'DA_' + randomstr3.substring(0,4),
                                    Email = randomstr3 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p3.Id,
                                    UserRoleId = r3.Id,
                                    Username = 'userTest' + randomstr3 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    ManagerId = businessAdminUser.Id,
                                    FederationIdentifier = 'FedId2',
                                    EmployeeNumber = 'Emp' + randomstr3.substring(0,4));
        insert managerUser;
        supervisorUser = new User(Alias = 'DA_' + randomstr2.substring(0,4),
                                    Email = randomstr2 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p2.Id,
                                    UserRoleId = r2.Id,
                                    Username = 'userTest' + randomstr2 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    ManagerId = managerUser.Id,
                                    FederationIdentifier = 'FedId3',
                                    EmployeeNumber = 'Emp' + randomstr3.substring(0,4));
        insert supervisorUser;
        
        carManagerUser = new User(Alias = 'DA_' + randomstr9.substring(0,4),
                                    Email = randomstr9 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p5.Id,
                                    UserRoleId = r3.Id,
                                    Username = 'userTest' + randomstr9 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    ManagerId = managerUser.Id,
                                    FederationIdentifier = 'FedId9',
                                    EmployeeNumber = 'Emp' + randomstr9.substring(0,4));
        insert carManagerUser;
        dsrUser = new User(Alias = 'DA_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest@SampleclassTest.com',
                                    LastName='Testing1',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p1.Id,
                                    UserRoleId = r1.Id,
                                    Username = 'userTest1' + randomstr1 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    Sales_Rep_Type__c = 'Upgrade',
                                    Device_Phone_Number__c = '111111',
                                    PERNR__c = '11111111',
                                    Sales_ID__c = 'abc1111',
                                    ManagerId = supervisorUser.Id,
                                    FederationIdentifier = 'FedId4',
                                    EmployeeNumber = 'Emp' + randomstr1.substring(0,4));  
        dsrUser2 = new User(Alias = 'DA_' + randomstr5.substring(0,4),
                                    Email = randomstr5 + 'userTest@SampleclassTest.com',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p1.Id,
                                    UserRoleId = r1.Id,
                                    Username = 'userTest2' + randomstr5 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    Sales_Rep_Type__c = 'Winback',
                                    Device_Phone_Number__c = '222222',
                                    PERNR__c = '22222222',
                                    Sales_ID__c = 'abc2222',
                                    ManagerId = supervisorUser.Id,
                                    FederationIdentifier = 'FedId5',
                                    EmployeeNumber = 'Emp' + randomstr5.substring(0,4));  
        dsrUser3 = new User(Alias = 'DA_' + randomstr6.substring(0,4),
                                    Email = randomstr6 + 'userTest@SampleclassTest.com',
                                    LastName='Testing3',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p1.Id,
                                    UserRoleId = r1.Id,
                                    Username = 'userTest3' + randomstr6 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    Sales_Rep_Type__c = 'Multiple Dwelling Unit (MDU)',
                                    Device_Phone_Number__c = '333333',
                                    PERNR__c = '33333333',
                                    Sales_ID__c = 'abc3333',
                                    ManagerId = supervisorUser.Id,
                                    FederationIdentifier = 'FedId6',
                                    EmployeeNumber = 'Emp' + randomstr6.substring(0,4));  
        dsrUser4 = new User(Alias = 'DA_' + randomstr7.substring(0,4),
                                    Email = randomstr7 + 'userTest@SampleclassTest.com',
                                    LastName='Testing4',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p1.Id,
                                    UserRoleId = r1.Id,
                                    Username = 'userTest4' + randomstr7 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    Sales_Rep_Type__c = 'Xfinity Home',
                                    Device_Phone_Number__c = '444444',
                                    PERNR__c = '44444444',
                                    Sales_ID__c = 'abc4444',
                                    ManagerId = supervisorUser.Id,
                                    FederationIdentifier = 'FedId7',
                                    EmployeeNumber = 'Emp' + randomstr7.substring(0,4));  
        Contractor = new User(Alias = 'DA_' + randomstr8.substring(0,4),
                                    Email = randomstr8 + 'userTest@SampleclassTest.com',
                                    LastName='Testing5',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p1.Id,
                                    UserRoleId = r5.Id,
                                    Username = 'userTest5' + randomstr8 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    Sales_Rep_Type__c = 'Contractor',
                                    Device_Phone_Number__c = '555555',
                                    PERNR__c = '55555555',
                                    Sales_ID__c = 'abc5555',
                                    ManagerId = supervisorUser.Id,
                                    FederationIdentifier = 'FedId8',
                                    Business_Partner__c = 'TNT',
                                    EmployeeNumber = 'Emp' + randomstr1.substring(0,4));  
        List<User> usersToInsert = new List<User>();
        usersToInsert.add(dsrUser);
        usersToInsert.add(dsrUser2);
        usersToInsert.add(dsrUser3);
        usersToInsert.add(dsrUser4);
        usersToInsert.add(Contractor);
        insert usersToInsert;
    }

    public static void createIndirectUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole role=[Select Id From UserRole WHERE Name='Indirect Manager'];
        User user = new User();
        user.City='Test City';
        user.Username = 'testser@acme.com';
        user.LastName = 'Last Name';
        user.Email = 'tuln@gmail.com';
        user.Alias = 'tuln';
        user.CommunityNickname = 'tee';
        user.TimeZoneSidKey = 'America/Panama';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.ProfileId = p.Id;
        user.FederationIdentifier = 'FedId11';
        user.UserRoleId=role.Id;
        insert user;
    }

    public static void createCustomSettingRecords() {
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        System.runAs(user) { 

            storeSettings = Store_Settings__c.getInstance();
            storeSettings.Max_Store_Visit_Distance_Feet__c = 2000;
            storeSettings.Min_Visit_Time_Minutes__c = 60;
            storeSettings.Scheduled_Visit_Alert_Template__c = 'TestAlertTemplate';
            storeSettings.Visit_Summary_Template__c = 'TestEmailTemplate';
            storeSettings.Visit_Mail_Delay_Minutes__c = 5;
            upsert storeSettings;

            Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'Retail_Sales_Emails'];
            emailTemplate = StoreTestUtility.createEmailTemplate(storeSettings, folder.Id);
            emailTemplate.DeveloperName = storeSettings.Scheduled_Visit_Alert_Template__c;
            insert emailTemplate;

            List<ConfigurableParameters__c> customSettingObjList = new List<ConfigurableParameters__c>();
            List<Planning_Statistics_Colours__c> planningStatsObjList = new List<Planning_Statistics_Colours__c>();
            List<Super_API_Parameters__c> apiParametersObjList = new List<Super_API_Parameters__c>();
           
            ConfigurableParameters__c batchSizeObj = new ConfigurableParameters__c();
            batchSizeObj.Name = 'AddressStatsBatchSize';
            batchSizeObj.NumberValue__c = 1;
            customSettingObjList.add(batchSizeObj);              
            
            ConfigurableParameters__c noOfAssignedDays = new ConfigurableParameters__c();
            noOfAssignedDays.Name = 'Config_ZipOrNodeAssignedDays';
            noOfAssignedDays.NumberValue__c = 90;
            customSettingObjList.add(noOfAssignedDays);
            
            ConfigurableParameters__c PreviousZipOrNodeAssignedDays = new ConfigurableParameters__c();
            PreviousZipOrNodeAssignedDays.Name = 'S_PreviousZipOrNodeAssignedDays';
            PreviousZipOrNodeAssignedDays.NumberValue__c = 90;
            customSettingObjList.add(PreviousZipOrNodeAssignedDays);
            
            ConfigurableParameters__c noOfKnockedDays = new ConfigurableParameters__c();
            noOfKnockedDays.Name = 'Config_ZipOrNodeKnockedDays';
            noOfKnockedDays.NumberValue__c = 30;
            customSettingObjList.add(noOfKnockedDays);
            
            ConfigurableParameters__c PreviousZipOrNodeKnockedDays = new ConfigurableParameters__c();
            PreviousZipOrNodeKnockedDays.Name = 'S_PreviousZipOrNodeKnockedDays';
            PreviousZipOrNodeKnockedDays.NumberValue__c = 30;
            customSettingObjList.add(PreviousZipOrNodeKnockedDays);
            
            ConfigurableParameters__c assignedPercentage = new ConfigurableParameters__c();
            assignedPercentage.Name = 'Config_PrevAssignedAddressPercentage';
            assignedPercentage.NumberValue__c = 75;
            customSettingObjList.add(assignedPercentage);
            
            ConfigurableParameters__c PreviousAssignedAddressPercentage = new ConfigurableParameters__c();
            PreviousAssignedAddressPercentage.Name = 'S_PreviousAssignedAddressPercentage';
            PreviousAssignedAddressPercentage.NumberValue__c = 75;
            customSettingObjList.add(PreviousAssignedAddressPercentage);

            ConfigurableParameters__c knockedPercentage  = new ConfigurableParameters__c();
            knockedPercentage.Name = 'Config_PrevKnockedAddressPercentage';
            knockedPercentage.NumberValue__c = 75;
            customSettingObjList.add(knockedPercentage);
            
            ConfigurableParameters__c knockMinutes  = new ConfigurableParameters__c();
            knockMinutes.Name = 'KnockMinutes';
            knockMinutes.NumberValue__c = 5;
            customSettingObjList.add(knockMinutes);
            
            ConfigurableParameters__c PreviousKnockedAddressPercentage  = new ConfigurableParameters__c();
            PreviousKnockedAddressPercentage.Name = 'S_PreviousKnockedAddressPercentage';
            PreviousKnockedAddressPercentage.NumberValue__c = 75;
            customSettingObjList.add(PreviousKnockedAddressPercentage);
            
            ConfigurableParameters__c currAssignedPercentage = new ConfigurableParameters__c();
            currAssignedPercentage.Name = 'Config_CurrAssignedPercentageCutOff';
            currAssignedPercentage.NumberValue__c = 75;
            customSettingObjList.add(currAssignedPercentage);
            
            ConfigurableParameters__c CurrAssignedPercentageCutOff = new ConfigurableParameters__c();
            CurrAssignedPercentageCutOff.Name = 'S_CurrAssignedPercentageCutOff';
            CurrAssignedPercentageCutOff.NumberValue__c = 75;
            customSettingObjList.add(CurrAssignedPercentageCutOff);
            
            ConfigurableParameters__c currUnassignedPercentage = new ConfigurableParameters__c();
            currUnassignedPercentage.Name = 'Config_CurrUnassignedPercentageCutOff';
            currUnassignedPercentage.NumberValue__c = 75;
            customSettingObjList.add(currUnassignedPercentage);
            
            ConfigurableParameters__c CurrUnassignedPercentageCutOff = new ConfigurableParameters__c();
            CurrUnassignedPercentageCutOff.Name = 'S_CurrUnassignedPercentageCutOff';
            CurrUnassignedPercentageCutOff.NumberValue__c = 75;
            customSettingObjList.add(CurrUnassignedPercentageCutOff);
            
            ConfigurableParameters__c locationLimitObj = new ConfigurableParameters__c();
            locationLimitObj.Name = 'LocationPullUpLimit';
            locationLimitObj.NumberValue__c = 2000;
            customSettingObjList.add(locationLimitObj);   

            ConfigurableParameters__c maxTurfAssignmentObj = new ConfigurableParameters__c();
            maxTurfAssignmentObj.Name = 'HardStopForDSR';
            maxTurfAssignmentObj.NumberValue__c = 5;
            customSettingObjList.add(maxTurfAssignmentObj);
            
            ConfigurableParameters__c offTurfLimitMinutesObj = new ConfigurableParameters__c();
            offTurfLimitMinutesObj.Name = 'OffTurfLimitMinutes';
            offTurfLimitMinutesObj.NumberValue__c = 10;
            customSettingObjList.add(offTurfLimitMinutesObj );
            
            ConfigurableParameters__c addressLimitPerPlan = new ConfigurableParameters__c();
            addressLimitPerPlan.Name = 'AddressLimitPerPlan';
            addressLimitPerPlan.NumberValue__c = 2000;
            customSettingObjList.add(addressLimitPerPlan);

            insert customSettingObjList;
            
            Planning_Statistics_Colours__c AssignedStatsColourObj = new Planning_Statistics_Colours__c();
            AssignedStatsColourObj.Name = 'AssignedStatsColour';
            AssignedStatsColourObj.Colour__c = '#ffff00';
            planningStatsObjList.add(AssignedStatsColourObj);
            
            Planning_Statistics_Colours__c CurrentlyAssignedColourObj = new Planning_Statistics_Colours__c();
            CurrentlyAssignedColourObj.Name = 'CurrentlyAssignedColour';
            CurrentlyAssignedColourObj.Colour__c = '#0000ff';
            planningStatsObjList.add(CurrentlyAssignedColourObj);
            
            Planning_Statistics_Colours__c CurrentlyUnassignedColourObj = new Planning_Statistics_Colours__c();
            CurrentlyUnassignedColourObj.Name = 'CurrentlyUnassignedColour';
            CurrentlyUnassignedColourObj.Colour__c = '#00ff00';
            planningStatsObjList.add(CurrentlyUnassignedColourObj);
            
            Planning_Statistics_Colours__c DefaultColourObj = new Planning_Statistics_Colours__c();
            DefaultColourObj.Name = 'DefaultColour';
            DefaultColourObj.Colour__c = '#ffff00';
            planningStatsObjList.add(DefaultColourObj);
            
            Planning_Statistics_Colours__c KnockedStatsColourObj = new Planning_Statistics_Colours__c();
            KnockedStatsColourObj.Name = 'KnockedStatsColour';
            KnockedStatsColourObj.Colour__c = '#ff0000';
            planningStatsObjList.add(KnockedStatsColourObj);
            
            insert planningStatsObjList;
            
            Super_API_Parameters__c endPointObj = new Super_API_Parameters__c();
            endPointObj.Name = 'Endpoint';
            endPointObj.Value__c = 'https://integration-soa.comcast.com/AccountManagementControllerService/1.35?wsdl';
            apiParametersObjList.add(endPointObj);
            
            Super_API_Parameters__c passWordObj = new Super_API_Parameters__c();
            passWordObj.Name = 'Password';
            passWordObj.Value__c = '8Pa9huku';
            apiParametersObjList.add(passWordObj);
            
            Super_API_Parameters__c userNameObj = new Super_API_Parameters__c();
            userNameObj.Name = 'Username';
            userNameObj.Value__c = 'sftmUser';
            apiParametersObjList.add(userNameObj);
            
            Super_API_Parameters__c ssUsernameObj = new Super_API_Parameters__c();
            ssUsernameObj.Name = 'sourceSystemUserId';
            ssUsernameObj.Value__c = 'sftmUser';
            apiParametersObjList.add(ssUsernameObj);
            
            Super_API_Parameters__c ssIdObj = new Super_API_Parameters__c();
            ssIdObj.Name = 'sourceSystemId';
            ssIdObj.Value__c = 'SF-SSID';
            apiParametersObjList.add(ssIdObj);
            
            Super_API_Parameters__c sServerIdObj = new Super_API_Parameters__c();
            sServerIdObj.Name = 'sourceServerId';
            sServerIdObj.Value__c = '84jfsduifsj8ej';
            apiParametersObjList.add(sServerIdObj);
            
            insert apiParametersObjList;

            List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();


            TriggerSettings__c addressTrigger = new TriggerSettings__c();
            addressTrigger.Name = 'AddressTrigger';
            addressTrigger.isActive__c = True;
            triggerSettingsList.add(addressTrigger);

            TriggerSettings__c addressStatisticsTrigger = new TriggerSettings__c();
            addressStatisticsTrigger.Name = 'AddressStatisticsTrigger';
            addressStatisticsTrigger.isActive__c = True;
            triggerSettingsList.add(addressStatisticsTrigger);

            TriggerSettings__c caseTrigger = new TriggerSettings__c();
            caseTrigger.Name = 'CaseTrigger';
            caseTrigger.isActive__c = True;
            triggerSettingsList.add(caseTrigger);

            TriggerSettings__c contactTrigger = new TriggerSettings__c();
            contactTrigger.Name = 'ContactTrigger';
            contactTrigger.isActive__c = True;
            triggerSettingsList.add(contactTrigger);
            
            TriggerSettings__c contractTrigger = new TriggerSettings__c();
            contractTrigger.Name = 'ContractTrigger';
            contractTrigger.isActive__c = True;
            triggerSettingsList.add(contractTrigger);
            
            TriggerSettings__c eventTrigger = new TriggerSettings__c();
            eventTrigger.Name = 'EventTrigger';
            eventTrigger.isActive__c = True;
            triggerSettingsList.add(eventTrigger);

            TriggerSettings__c feedCommentTrigger = new TriggerSettings__c();
            feedCommentTrigger.Name = 'FeedCommentTrigger';
            feedCommentTrigger.isActive__c = True;
            triggerSettingsList.add(feedCommentTrigger);

            TriggerSettings__c feedItemTrigger = new TriggerSettings__c();
            feedItemTrigger.Name = 'FeedItemTrigger';
            feedItemTrigger.isActive__c = True;
            triggerSettingsList.add(feedItemTrigger);

            TriggerSettings__c leadTrigger = new TriggerSettings__c();
            leadTrigger.Name = 'LeadTrigger';
            leadTrigger.isActive__c = True;
            triggerSettingsList.add(leadTrigger);

            TriggerSettings__c opportunityTrigger = new TriggerSettings__c();
            opportunityTrigger.Name = 'OpportunityTrigger';
            opportunityTrigger.isActive__c = True;
            triggerSettingsList.add(opportunityTrigger);
            
            TriggerSettings__c opportunityPropertyTrigger = new TriggerSettings__c();
            opportunityPropertyTrigger.Name = 'PrimaryPropertyTrigger';
            opportunityPropertyTrigger.isActive__c = True;
            triggerSettingsList.add(opportunityPropertyTrigger);
            
            TriggerSettings__c orderLineItemTrigger = new TriggerSettings__c();
            orderLineItemTrigger.Name = 'OrderLineItemTrigger';
            orderLineItemTrigger.isActive__c = True;
            triggerSettingsList.add(orderLineItemTrigger);

            TriggerSettings__c orderTrigger = new TriggerSettings__c();
            orderTrigger.Name = 'OrderTrigger';
            orderTrigger.isActive__c = True;
            triggerSettingsList.add(orderTrigger);
            
            //Abhishek 29 Jan '15
            
            TriggerSettings__c mduPropertyTrigger = new TriggerSettings__c();
            mduPropertyTrigger.Name = 'PropertyTrigger';
            mduPropertyTrigger.isActive__c = True;
            triggerSettingsList.add(mduPropertyTrigger);
            
            
            TriggerSettings__c phaseStatsTrigger = new TriggerSettings__c();
            phaseStatsTrigger.Name = 'PhaseStatsTrigger';
            phaseStatsTrigger.isActive__c = True;
            triggerSettingsList.add(phaseStatsTrigger);
         
            //Ashish 23 Feb 15
            TriggerSettings__c mduBulkServiceTrigger = new TriggerSettings__c();
            mduBulkServiceTrigger.Name = 'BulkServiceTrigger';
            mduBulkServiceTrigger.isActive__c = True;
            triggerSettingsList.add(mduBulkServiceTrigger);
            
            TriggerSettings__c mduOpportunityPropertyTrigger = new TriggerSettings__c();
            mduOpportunityPropertyTrigger.Name = 'OpportunityPropertyTrigger';
            mduOpportunityPropertyTrigger.isActive__c = True;
            triggerSettingsList.add(mduOpportunityPropertyTrigger); 

            TriggerSettings__c planTrigger = new TriggerSettings__c();
            planTrigger.Name = 'PlanTrigger';
            planTrigger.isActive__c = True;
            triggerSettingsList.add(planTrigger);
            
            TriggerSettings__c taskTrigger = new TriggerSettings__c();
            taskTrigger.Name = 'TaskTrigger';
            taskTrigger.isActive__c = True;
            triggerSettingsList.add(taskTrigger);

            TriggerSettings__c teamMemberTrigger = new TriggerSettings__c();
            teamMemberTrigger.Name = 'TeamMemberTrigger';
            teamMemberTrigger.isActive__c = True;
            triggerSettingsList.add(teamMemberTrigger);
            
            TriggerSettings__c termsAndConditionsTrigger = new TriggerSettings__c();
            termsAndConditionsTrigger.Name = 'TermsAndConditionsTrigger';
            termsAndconditionsTrigger.isActive__c = True;
            triggerSettingsList.add(termsAndConditionsTrigger);

            TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = True;
            triggerSettingsList.add(userTrigger);

            insert triggerSettingsList;

            List<Region_Map__c> regionMapList = new List<Region_Map__c>();

            regionMapList.add(new Region_Map__c(Name='Beltway Market', Old_Region__c='Beltway'));
            regionMapList.add(new Region_Map__c(Name='Big South Region', Old_Region__c='Big South'));
            regionMapList.add(new Region_Map__c(Name='California Market', Old_Region__c='California'));
            regionMapList.add(new Region_Map__c(Name='Florida Region', Old_Region__c='Florida'));
            regionMapList.add(new Region_Map__c(Name='Freedom Market', Old_Region__c='Freedom'));
            regionMapList.add(new Region_Map__c(Name='Greater Boston Market', Old_Region__c='Greater Boston'));
            regionMapList.add(new Region_Map__c(Name='Greater Chicago Market', Old_Region__c='Chicago'));
            regionMapList.add(new Region_Map__c(Name='Heartland Region', Old_Region__c='Heartland'));
            regionMapList.add(new Region_Map__c(Name='Houston Market', Old_Region__c='Houston'));
            regionMapList.add(new Region_Map__c(Name='Keystone Market', Old_Region__c='Keystone'));
            regionMapList.add(new Region_Map__c(Name='Mile High Region', Old_Region__c='Mile High'));
            regionMapList.add(new Region_Map__c(Name='Portland/Salem Market', Old_Region__c='Portland'));
            regionMapList.add(new Region_Map__c(Name='Salt Lake City Market', Old_Region__c='Mountain'));
            regionMapList.add(new Region_Map__c(Name='Seattle Market', Old_Region__c='Seattle'));
            regionMapList.add(new Region_Map__c(Name='Twin Cities Market', Old_Region__c='Twin Cities'));
            regionMapList.add(new Region_Map__c(Name='Western New England Market', Old_Region__c='Western New England'));   

            insert regionMapList;         
            
            List<Call_Center_Settings__c> callCenterSettings = new List<Call_Center_Settings__c>();

            Call_Center_Settings__c lastExportThreshold = new Call_Center_Settings__c();
            lastExportThreshold.Name = 'Last Export Threshold In Days';
            lastExportThreshold.Value__c = '90';
            callCenterSettings.add(lastExportThreshold);

            Call_Center_Settings__c newLeadOppThreshold = new Call_Center_Settings__c();
            newLeadOppThreshold.Name = 'New Lead Opportunity Threshold';
            newLeadOppThreshold.Value__c = '3';
            callCenterSettings.add(newLeadOppThreshold);

            Call_Center_Settings__c orderCreatedThreshold = new Call_Center_Settings__c();
            orderCreatedThreshold.Name = 'Order Created Threshold In Days';
            orderCreatedThreshold.Value__c = '30';
            callCenterSettings.add(orderCreatedThreshold);

            Call_Center_Settings__c neDivision = new Call_Center_Settings__c();
            neDivision.Name = 'Northeast Division';
            neDivision.Value__c = 'CT,DE,ME,MD,MA,NH,NJ,NY,NC,RI,VT,VA';
            callCenterSettings.add(neDivision);

            insert callCenterSettings;




            List<Group> envGroups= new List<Group>();
            Group escalationDisputeGroup = new Group(Name = 'Escalation Dispute', Type = 'Queue');
            envGroups.add(escalationDisputeGroup);
            Group sharedAddressPoolGroup = new Group(Name = 'SharedAddressPool', Type = 'Queue');
            envGroups.add(sharedAddressPoolGroup);
            insert envGroups;

            List<QueueSobject> queueInsert= new List<QueueSobject>();
            List<EnvironmentSpecificIds__c> envIdsList= new List<EnvironmentSpecificIds__c>();
            for(Group queueGroup:envGroups)
            {
                if(queueGroup.Name=='SharedAddressPool')
                {
                    queueInsert.add(new QueueSObject(QueueId = queueGroup.Id, SobjectType = 'Customer_Address__c'));
                }
                else
                {
                    queueInsert.add(new QueueSObject(QueueId = queueGroup.Id, SobjectType = 'Case'));
                }
                envIdsList.add(new EnvironmentSpecificIds__c(Name=queueGroup.Name.replaceAll( '\\s+', ''),Id__c=queueGroup.Id));
            }
            insert queueInsert;

            User userObj = new User(LastName='Test User', FederationIdentifier = 'FedId12',UserName='test12345@comcast.com', email='test12345@comcast.com', Alias='tcom', UserRoleId=r4.Id, ProfileId=p4.Id, EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles');
            insert userObj;
            envIdsList.add(new EnvironmentSpecificIds__c(Name='TransferLeadAndOpty',Id__c=userObj.Id));
            insert envIdsList;
            
    }
}
    public static Exclusion__c createExclusionRecord() {
        Exclusion__c excl;
        System.runAs(supervisorUser) {
            excl = new Exclusion__c();
            excl.Name = 'Test Exclusion';
            excl.Expiration_Date__c = System.Today() + 30;
            excl.Division__c = 'NorthEast';
            excl.Region__c = 'Freedom';
            excl.Nodes__c = '12345';
            insert excl;
        }
        return excl;
    }
    public static Template__c createTemplateRecord() {
        Template__c tmpltObj;
        System.runAs(dsrUser) {
            tmpltObj = new Template__c();
            tmpltObj.Name = 'Test Template';
            tmpltObj.Status__c = 'Active';
            tmpltObj.Plan_Type__c = 'Playlist';
            tmpltObj.Division__c = 'Northeast';
            tmpltObj.Region__c = 'Freedom';
            tmpltObj.Complex_Code_Exists__c = 'No';
            insert tmpltObj;
        }
        return tmpltObj;
    }

}