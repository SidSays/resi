/***************************************************************************************************************************************
 * Author     : Vivek Patel, Accenture
 * Date       : 17-May-2013
 * Description: This is Test class for "PlanEditExtn" class.
 * History
     Version             : 1.0
     Author Last Updated : Vivek Patel, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/

@isTest
public class PlanEditExtnTest {  
     public static User contractorSalesLeader, reContractorSalesLeader;
     private static Profile p6 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Contractor Sales Leader'];
     private static UserRole r5 = [Select Id, Name from UserRole where Name='Contractor']; 
     private static User user = [Select Id,Region__c from User where Id=:UserInfo.getUserId()];
     private static String randomstr10 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
     private static String randomstr11 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
    private static testMethod void testPlanEditPageExtn() { 
        // Creating Test data
        Integer pageNumber = 10;
        SetupTestData.createCustomSettingRecords();
        SetupTestData.createUsers();
        Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
        PageReference pageRef = Page.PlanEdit;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('NodeOrZip', 'ZipCode In (98564)');          
        Team__c team;
        Team_Member__c teamMember;
        Plan__c NationalPlanObj;
        Plan__c DivisionPlanObj;
        Plan__c RegionPlanObj;
        Plan__c areaPlanObj;
        Plan__c turfPlanObj;
        Plan__c playlistPlanObj;
        Template__c selectTemplate;
        //Creating Area level plan as Area level Manager.
        System.runAs(SetupTestData.managerUser) {
            Test.StartTest();
            areaPlanObj = new Plan__c();
            areaPlanObj.Name = 'Test Area Plan';
            areaPlanObj.Plan_Status__c = 'Draft';
            areaPlanObj.Plan_Level__c = 'Area';
            areaPlanObj.Expiration_Date__c = System.Today() + 45;
            //areaPlanObj.PlanCriteria__c = null;
            ApexPages.StandardController controller1 = new ApexPages.StandardController(areaPlanObj);
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
            extnObj1.quickSave();
            //System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR));
            //areaPlanObj.User__c = UserInfo.getUserId();
            areaPlanObj.User__c = SetupTestData.managerUser.Id;
            extnObj1.selectedTemplate.Customer_Status__c = 'Active';
            extnObj1.selectedTemplate.Complex_Code_Exists__c = 'Yes';
            extnObj1.selectedTemplate.Disconnect_Reason__c = 'Billing Problem'; 
            extnObj1.selectedTemplate.Dwelling_Type__c = 'Single Family';
            extnObj1.selectedTemplate.Last_Disposition__c = 'No Knock';
            extnObj1.selectedTemplate.Monthly_Rate_MRC__c = 250.0;
            extnObj1.selectedTemplate.Nodes__c = '5844';
            //extnObj1.selectedTemplate.Agent_Code__c = '0428';
            //extnObj1.selectedTemplate.Targeted__c = 'Yes';
            extnObj1.selectedTemplate.City__c = 'Vegas';
            extnObj1.selectedTemplate.Number_of_Knocks_Less_Than__c = 10;   
            extnObj1.selectedTemplate.Products__c = '3 Product Customer';
            extnObj1.selectedTemplate.Property_Code__c = '25874,25875';       
            extnObj1.selectedTemplate.Zip_Codes__c = '98564';
            extnObj1.selectedTemplate.Last_Knock_Date__c = System.today();
            extnObj1.selectedTemplate.Disconnect_Date__c = System.today();
            extnObj1.selectedTemplate.Xfinity_Home_Upgrade_Score__c = '5';
            extnObj1.selectedTemplate.TP_Upgrade_Score__c = '5';
            extnObj1.selectedTemplate.TP_Acquisition_Score__c= '5';
            extnObj1.selectedTemplate.Xfinity_Home_Acquisition_Score__c= '5';
            extnObj1.selectedTemplate.Sub_Bad_Debt_Propensity__c = '3';
            extnObj1.selectedTemplate.Non_Sub_Bad_Debt_Propensity__c = '3';
            extnObj1.selectedTemplate.Management_Area__c = '12345';
            extnObj1.selectedTemplate.Street__c='Address Line1';
            extnObj1.selectedTemplate.Route_Code__c='22222';
            extnObj1.selectedTemplate.Census_Block_Sub_Block__c='2246';
            extnObj1.save();
            extnObj1.tmpltId = extnObj1.selectedTemplate.Id;
            //extnObj1.Census_Block_Sub_Block = false;
            //extnObj1.addressCount = 50;
            //extnObj1.contractorDSSOption =  'Test for DSS Option';
            //extnObj1.pageSize = null;
            System.assert(areaPlanObj.Plan_Status__c == 'Assigned');
        }
        
        //Creating Turf level plan as Supervisor.
        System.runAs(SetupTestData.supervisorUser) {            
            List<Account> accList = new List<Account>();    
            Account acc;
            for(Integer i=1; i<=10; i++) {
                acc = new Account();
                acc.Name = 'Test Account '+i;
                acc.Customer_Status__c = 'Active';
                acc.Installation_Status__c = 'Active';
                acc.Division = freedomRegion.Id;
                acc.Video_Active__c = True;
                acc.HSI_Active__c = True;
                acc.Verizon_Wireless_Active__c = True;
                acc.Voice_Active__c = True;
                acc.Home_Security_Active__c = True;
                acc.XSS_Active__c = True;
                acc.Disconnect_Reason__c = 'Billing Problem';
                acc.Total_Monthly_Rate__c = 250.0;
                acc.Last_Disconnected_Date__c = System.Today()-2;
                accList.add(acc);
            }
            Database.insert(accList,true);

            List<Customer_Address__c> addressList = new List<Customer_Address__c>();
            Customer_Address__c custAddress;
            for(Integer i=1; i<=10; i++) {
                custAddress = new Customer_Address__c();
                custAddress.Address__c = 'Test Address Line1';
                custAddress.City__c = 'Test city';
                custAddress.State__c = 'Test State';
                custAddress.PostalCode__c = '98564';    
                custAddress.Country__c = 'Test Country';
                custAddress.Region__c = 'Freedom Market';
                //custAddress.Account__c = accList[i].Id;
                //custAddress.Status__c = 'Active';
                custAddress.Dwelling_Type__c = 'Single Family'; 
                custAddress.Internet_Serviceable__c = True;
                custAddress.Complex_Office__c = True;
                custAddress.Digital_Serviceable__c = True;
                custAddress.Most_Recent_Disposition__c = 'No Knock';
                custAddress.Node__c = '5844';
                custAddress.Property_Code__c = '25874';
                if(i==1){
                   custAddress.Property_Code__c = '25875'; 
                }
                if(i==2){
                   custAddress.Property_Code__c = '25876'; 
                }
                custAddress.Route_Code__c='22222';
                custAddress.Census_Block__c='12222246';
                custAddress.Number_of_Knocks__c = 5;
                custAddress.Last_Knock_Date__c = System.Now()-2;
                custAddress.Region__c = 'Freedom Market';
                custAddress.ManagementArea__c = '12345';
                custAddress.Division=freedomRegion.Id;
                addressList.add(custAddress);
                
            }
            Database.insert(addressList,true);
            
            //Creating the customer object data.
            
        Customer_Address__c  custAddressObj = new Customer_Address__c();
                custAddressObj.Address__c = 'Test Address Line1';
                custAddressObj.Address_2__c = 'Test Address Line2';
                custAddressObj.City__c = 'Test city';
                custAddressObj.State__c = 'Test State';
                custAddressObj.PostalCode__c = '98564';    
                custAddressObj.Country__c = 'Test Country';
                //custAddressObj.Region__c = 'Freedom Market';
                custAddressObj.Account__c = accList[0].Id;
                custAddressObj.Dwelling_Type__c = 'Single Family'; 
                custAddressObj.Internet_Serviceable__c = True;
                custAddressObj.Complex_Office__c = True;
                custAddressObj.Digital_Serviceable__c = True;
                custAddressObj.Most_Recent_Disposition__c = 'No Knock';
                custAddressObj.Node__c = '5844';
                custAddressObj.Property_Code__c = '25874';
                custAddressObj.Route_Code__c='22222';
                custAddressObj.Census_Block__c='12222246';
                custAddressObj.Number_of_Knocks__c = 5;
                custAddressObj.Last_Knock_Date__c = System.Now()-2;
                //custAddressObj.Region__c = 'Freedom Market';
                custAddressObj.ManagementArea__c = '12345';
                custAddressObj.Division=freedomRegion.Id;
                //custAddressObj.Census_Block_Sub_Block__c ='2246';
                //custAddressObj.Active_Inactive__c = 'Active';
                //custAddressObj.Disconnect_Reason__c = 'Billing Problem';
                //custAddressObj.Last_Disconnected_Date__c = System.today()-2;
                //custAddressObj.Total_Monthly_Rate__c=125;
                custAddressObj.TP_Upgrade_Score__c = 4;
                custAddressObj.TP_Acquisition_Score__c =3;
                custAddressObj.Xfinity_Home_Acquisition_Score__c = 2;
                custAddressObj.Xfinity_Home_Upgrade_Score__c =3;
                custAddressObj.Sub_Bad_Debt_Propensity__c = 5;
                custAddressObj.Non_Sub_Bad_Debt_Propensity__c = 7;
                custAddressObj.Excluded__c = false;
                custAddressObj.Region__c='Beltway Market';
                custAddressObj.Non_Marketable__c = false;
                custAddressObj.No_Solicitation__c = false;
            
                
                insert custAddressObj;
               // system.debug('------Census_Block_Sub_Block__c ' + custAddressObj.Census_Block_Sub_Block__c);
              //  system.debug('------custAddressObj.Active_Inactive__'+custAddressObj.Active_Inactive__c);
            //*******************ending here.
            
            team = new Team__c();
            team.Name = 'Test Team';
            team.Region__c = SetupTestData.supervisorUser.Region__c;
            team.Supervisor__c = SetupTestData.supervisorUser.Id;
            insert team;
            
            teamMember = new Team_Member__c();
            teamMember.Team__c = team.Id;
            teamMember.User_Name__c = SetupTestData.supervisorUser.Id;
            insert teamMember;

            /*selectTemplate = new Template__c();
            selectTemplate.Name = 'Test Template';
            selectTemplate.Agent_Code__c = '2804';
            selectTemplate.Targeted__c = 'Yes';
            selectTemplate.Management_Area__c = '53959';
            selectTemplate.Sub_Bad_Debt_Propensity__c = '4';
            selectTemplate.Non_Sub_Bad_Debt_Propensity__c = '2';
            selectTemplate.TP_Upgrade_Score__c = '1';
            selectTemplate.TP_Acquisition_Score__c = '2';
            selectTemplate.Xfinity_Home_Acquisition_Score__c = '2';
            selectTemplate.Xfinity_Home_Upgrade_Score__c = '8';
            selectTemplate.Division__c = 'West';
            selectTemplate.Region__c = 'Big South Region';
            selectTemplate.Plan_Type__c = 'Playlist';
            //selectTemplate.Zip_Codes__c = '411028';
            //selectTemplate.Nodes__c = '560103';
            selectTemplate.Customer_Status__c = 'Active';
            selectTemplate.Complex_Code_exists__c = 'Yes';
            selectTemplate.Products__c = 'Verizon Wireless';
            selectTemplate.Disconnect_Reason__c = 'DSL';
            selectTemplate.Dwelling_Type__c = 'Vacant';
            selectTemplate.Property_Code__c = '040791';
            selectTemplate.Disconnect_Date__c = System.Today() + 30;
            selectTemplate.Last_Disposition__c = 'Contact';
            selectTemplate.Last_Knock_Date__c = System.Today();
            selectTemplate.Monthly_Rate_MRC__c = 1000.00;
            selectTemplate.Number_of_Knocks_Less_Than__c = 10;
            selectTemplate.Street__c = 'Bellandur';
            selectTemplate.City__c = 'Bang';
            selectTemplate.Route_Code__c = '280289';
            selectTemplate.Census_Block_Sub_Block__c = 'True';
            insert selectTemplate; */
            
            turfPlanObj = new Plan__c();
            turfPlanObj.Name = 'Test Turf Plan';
            turfPlanObj.Plan_Status__c = 'Draft';
            turfPlanObj.Plan_Level__c = 'Turf';
            turfPlanObj.PlanCriteria__c = null;
            turfPlanObj.Parent_Plan__c = areaPlanObj.Id;
            turfPlanObj.Expiration_Date__c = System.Today() + 10;
            ApexPages.StandardController controller2 = new ApexPages.StandardController(turfPlanObj);
            PlanEditExtn extnObj2 = new PlanEditExtn(controller2);
            extnObj2.quickSave();
            extnObj2.setCriteria();
            //extnObj2.addAddresses(1);
            PlanEditExtn extnObj3 = new PlanEditExtn(controller2);
            custAddressObj.Plan__c = turfPlanObj.Id;
            update custAddressObj;
            PlanEditExtn.AddressWrapper innerclasswrapper = new PlanEditExtn.AddressWrapper(custAddressObj);
            //extnObj3.pageAddresses.add(innerclasswrapper);
            //extnObj2.removalAddressWrapperList.add(innerclasswrapper);
            //extnObj2.addrsWrapper.add(innerclasswrapper);
            extnObj3.showAssignedAddresses = true;
            extnObj3.searchAddressses();
            extnObj3.checkEditAccess();
            extnObj3.nextSetOfRecords();
            extnObj3.pageSize = 5;
            extnObj3.previousSetOfRecords();
            //extnObj3.addAddresses(0);
            extnObj3.addAddresses(2);
            //extnObj3.pageAddresses[0].selected = true;
            extnObj3.addSelected();
            extnObj3.updateMasterList();
            extnObj3.addPage();
            extnObj3.addAll();    
            //extnObj3.displayAssignedAddressesMessage('Plan__c = null');
            PlanEditExtn extnObj4 = new PlanEditExtn(controller2);
            extnObj2.removalQueryFieldOption= 'Property_Code__c';
            extnObj2.removalQueryInputField='25874';
            extnObj2.addressRemovalSearch();
            extnObj2.removalAddressWrapperList.get(0).selected = true;
            extnObj2.removeSelected();
            extnObj2.removeAll();
            
            /*PlanEditExtn extnObj5 = new PlanEditExtn(controller2);
            extnObj5.removalQueryFieldOption='Property_Code__c';
            extnObj5.removalQueryInputField='25876';
            extnObj5.addressRemovalSearch();
            extnObj5.removeAll();*/
            
            PageReference planAssignPageRef = Page.PlanAssignmentPage;
            Test.setCurrentPage(planAssignPageRef);
            ApexPages.currentPage().getParameters().put('lksrch', 'Test Team');
            PlanAssignmentController planAssignController = new PlanAssignmentController();
            planAssignController.Search();
            planAssignController.getFormTag();
            planAssignController.getTextBox();
            Boolean b1 = planAssignController.getIsTeamResultEmpty();
            System.assert(b1 == false);
            Boolean b2 = planAssignController.getIsOtherTeamResultEmpty();
            System.assert(b2 == true);
            
            //turfPlanObj.Expiration_Date__c = System.Today() + 30;
            turfPlanObj.Assigned_Team__c = team.Id;
            extnObj3.quickSave();
            extnObj3.cancel();
            //System.assert(turfPlanObj.Plan_Status__c == 'Assigned');
            //System.assert(turfPlanObj.Number_of_Addresses__c == 11); 
        }
        
        //Creating Playlist level plan as DSR.
        System.runAs(SetupTestData.dsrUser) {
            playlistPlanObj = new Plan__c();
            playlistPlanObj.Name = 'Test Playlist Plan';
            playlistPlanObj.Plan_Status__c = 'Draft';
            playlistPlanObj.Plan_Level__c = 'Playlist';
            playlistPlanObj.Parent_Plan__c = turfPlanObj.Id;
            ApexPages.StandardController controller3 = new ApexPages.StandardController(playlistPlanObj);
            PlanEditExtn extnObj4 = new PlanEditExtn(controller3);
            //extnObj3.showAssignedAddresses = true;
            extnObj4.quickSave();
            extnObj4.checkEditAccess();
            extnObj4.searchAddressses();
            //extnObj4.removeSelected();
            //extnObj4.setCriteria();            
            //System.assert(playlistPlanObj.Plan_Status__c == 'Assigned');

            PageReference pageRef1 = Page.SelectTemplate;
            Test.setCurrentPage(pageRef1);
            ApexPages.currentPage().getParameters().put('PlanId', playlistPlanObj.Id);

            Test.StopTest();                    
            SearchTemplateController controllerObj = new SearchTemplateController();
            controllerObj.searchTemplates();
            List<Template__c> tmpltList = controllerObj.templates;
            Template__c tmpltObj = SetupTestData.createTemplateRecord();
            ApexPages.currentPage().getParameters().put('tmpltId', tmpltObj.Id);
            ApexPages.currentPage().getParameters().put('PlanId', playlistPlanObj.Id);                  
                        
            SearchTemplateController controllerObj1 = new SearchTemplateController();
            controllerObj1.searchString = 'Test Template';
            tmpltList = controllerObj1.templates;
            //System.assert(tmpltList[0].Name == 'Test Template');
            controllerObj1.searchTemplates();
            extnObj4.removalQueryInputField='25875';
            extnObj4.addressRemovalSearch();
            //extnObj4.removalAddressWrapperList.get(0).selected = true;
            extnObj4.removeSelected();
            extnObj4.removeAll();
        }
    }
    private static testMethod void testPlanTriggerController(){
        SetupTestData.createCustomSettingRecords();
        SetupTestData.createUsers();
        List<User> usersToInsert = new List<User>();
        contractorSalesLeader = new User(Alias = 'DA_' + randomstr10.substring(0,4),
                                    Email = randomstr10 + 'userTest@SampleclassTest.com',
                                    LastName='Testing5',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p6.Id,
                                    UserRoleId = r5.Id,
                                    Username = 'userTest5' + randomstr10 + '@SampleclassTest.com',
                                    Region__c = user.Region__c,
                                    Sales_Rep_Type__c = 'Contractor',
                                    Device_Phone_Number__c = '555555',
                                    PERNR__c = '55555555',
                                    Sales_ID__c = 'abc5555',
                                    ManagerId = SetupTestData.supervisorUser.Id,
                                    FederationIdentifier = randomstr10+'FedId18',
                                    Business_Partner__c = 'TNT',
                                    EmployeeNumber = 'Emp' + randomstr10.substring(0,4)); 
        reContractorSalesLeader = new User(Alias = 'DA_' + randomstr11.substring(0,4),
                                    Email = randomstr11 + 'userTest@SampleclassTest.com',
                                    LastName='Testing6',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p6.Id,
                                    UserRoleId = r5.Id,
                                    Username = 'userTest5' + randomstr11 + '@SampleclassTest.com',
                                    Region__c = user.Region__c,
                                    Sales_Rep_Type__c = 'Contractor',
                                    Device_Phone_Number__c = '555555',
                                    PERNR__c = '55555555',
                                    Sales_ID__c = 'abc5555',
                                    ManagerId = SetupTestData.supervisorUser.Id,
                                    FederationIdentifier = randomstr11+'FedId19',
                                    Business_Partner__c = 'TNT',
                                    EmployeeNumber = 'Emp' + randomstr11.substring(0,4)); 
            usersToInsert.add(contractorSalesLeader);
            usersToInsert.add(reContractorSalesLeader);
            insert usersToInsert;
            

        Test.StartTest();
        Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
        Plan__c pln;  
        System.runAs(SetupTestData.supervisorUser){                        
            //Create a turf Level Plan 
            pln = new Plan__c();            
            pln.Name = 'TestPlan';            
            pln.Plan_Level__c = 'Playlist'; 
            pln.Expiration_Date__c = system.Today() + 30;            
            ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);            
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);            
            extnObj1.quickSave();
            
            //Create Customer Address
            Customer_Address__c addr = new Customer_Address__c();
            addr.Address__c = 'Test Address';
            addr.State__c = 'Test State';
            addr.City__c = 'Test City';
            addr.Country__c = 'Test Country';
            addr.PostalCode__c = '12345';
            addr.Node__c = '12345';
            addr.Route_Code__c = '1111111111';
            addr.Corp__c = '111111';
            addr.Division = freedomRegion.Id;
            addr.Non_Marketable__c = TRUE;
            addr.Do_Not_Knock__C = TRUE;
            addr.ManagementArea__c = '12345';
            insert addr;
            addr.Plan__c = pln.Id;
            update addr;
            //Create Exclusion Record
            List<Exclusion__c> excList = new List<Exclusion__c>();
            Exclusion__c excl = new Exclusion__c();
            excl.Name = 'Test Exclusion1';
            excl.Expiration_Date__c = System.Today() + 30;
            excl.Division__c = 'NorthEast';
            excl.Region__c = 'Freedom Market';
            excl.Nodes__c = '12345';
            excl.Installation_Status__c = 'Pending Install';
            excl.Past_Due_Balance__c = 200.00;
            excl.Non_Marketable_Address__c = TRUE;
            excl.Do_Not_Knock__C = TRUE;
            excl.Non_Voice_Serviceable__c = TRUE;
            excl.Non_Internet_Serviceable__c = TRUE;
            excl.Non_Digital_Serviceable__c = TRUE;
            excl.Complex_Codes__c = '234';
            excList.add(excl);
            
            Exclusion__c excl1 = new Exclusion__c();
            excl1.Name = 'Test Exclusion2';
            excl1.Expiration_Date__c = System.Today() + 10;
            excl1.Division__c = 'West';
            excl1.Region__c = 'Freedom';
            excl1.Nodes__c = '79864';
            //excl1.Installation_Status__c = 'Pending Install';
            //excl1.Past_Due_Balance__c = 200.00;
            excList.add(excl1);
            insert excList;
            pln.Exclusion__c = excList[0].Id;
            pln.User__c = SetupTestData.DSRUser.Id; 
            extnObj1.Save(); 
            
            pln.Exclusion__c = excList[1].Id;
            extnObj1.Save(); 
            // Delete the Plan
            try{
                delete pln;
            } catch (Exception e){
                System.AssertNotEquals(e.getMessage(),null);    
            }
        }
        System.runAs(SetupTestData.businessAdminUser){
            // Create a new Plan
           
            Plan__c pln1 = new Plan__c();            
            pln1.Name = 'TestPlan1';            
            pln1.Plan_Level__c = 'Turf';    
            pln1.Plan_Status__c = 'Draft';    
            pln1.Expiration_Date__c = System.Today() + 11;
            pln1.User__c = contractorSalesLeader.Id;          
            ApexPages.StandardController controller2 = new ApexPages.StandardController(pln1);            
            PlanEditExtn extnObj2 = new PlanEditExtn(controller2); 
            extnObj2.reContractorOption = 'Testing5';
            extnObj2.quickSave();
            extnObj2.getReassignedUsers();
            extnObj2.fetchAssignedAddress();
            extnObj2.bulkReAssignedAddressses();
            pln1.Plan_Level__c = 'Turf'; 
            update pln1;
            Test.StopTest();
            // Delete the Plan in context of Admin
           /*try{
                delete pln1;
            } catch (Exception e){
                System.AssertNotEquals(e.getMessage(),null);    
            }*/
            
           // Delete the Plan in Context of Admin
           /* try{
                delete pln;
            } catch (Exception e){
                System.AssertNotEquals(e.getMessage(),null);    
            }*/
            
            // Assign Plan 
            pln1.User__c = SetupTestData.DSRUser.Id; 
            //extnObj2.Save();           
        }
    }
    
    
    //Test Method for "BulkPlan" Assignment 
    private static testMethod void testbulkPlanAssignment(){
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = True;
        triggerSettingsList.add(userTrigger);
        
        TriggerSettings__c planTrigger = new TriggerSettings__c();
        planTrigger.Name = 'PlanTrigger';
        planTrigger.isActive__c = True;
        triggerSettingsList.add(planTrigger);
        
        TriggerSettings__c addressTrigger = new TriggerSettings__c();
        addressTrigger.Name = 'AddressTrigger';
        addressTrigger.isActive__c = True;
        triggerSettingsList.add(addressTrigger);
        
        
        
        
        
        insert triggerSettingsList;
        
        
        User rSAUser;
        User conDSSUser;
        Profile rsaProfile = [Select UserType, UserLicenseId, Name From Profile where Name like 'Regional System Admin (RSA)'];      
        UserRole rsaRole = [Select Id, Name from UserRole where Name='Regional Manager'];
        Profile conDSSProfile = [Select UserType, UserLicenseId, Name From Profile where Name like 'Contractor Sales Leader'];
        UserRole conDSSRole = [Select Id, Name from UserRole where Name='DS Supervisor'];
        
        String randomstr4 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        
       
        System.runAs(user){
        rSAUser = new User(Alias = 'DA_' + randomstr4.substring(0,4),
                                    Email = randomstr4 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    IsActive = true ,
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = rsaProfile.Id,
                                    UserRoleId = rsaRole.Id,
                                    Username = 'userTest' + randomstr4 + '@SampleclassTest.com',
                                    Region__c = 'BigSouthRegion',
                                    FederationIdentifier = 'FedId1',
                                    EmployeeNumber = 'Emp' + randomstr4.substring(0,4));
        insert rSAUser;
        }
        Assign_Bulk_Access__c asgnBulk = new Assign_Bulk_Access__c();
        asgnBulk.SetupOwnerId  = rSAUser.ID;
        asgnBulk.IsTrue__c = True;
        insert asgnBulk;
        
        System.runAs(rSAUser) {
        String randomstr3 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        conDSSUser = new User(Alias = 'DA_' + randomstr3.substring(0,4),
                                    Email = randomstr3 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    IsActive = true ,
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = conDSSProfile.Id,
                                    UserRoleId = conDSSRole.Id,
                                    Username = 'userTest' + randomstr3 + '@SampleclassTest.com',
                                    Region__c = 'BigSouthRegion',
                                    FederationIdentifier = '1245FedId12345',
                                    EmployeeNumber = 'Emp' + randomstr3.substring(0,4));
        insert conDSSUser;
        
       
        Test.StartTest();
         
        Division bigSouthRegion = [select id, name from Division where name ='Big South Region'];
        List<Customer_Address__c> addrList = new List<Customer_Address__c>();
            Customer_Address__c addr1;
            
            // Create 5 Customer Address Data
            for(integer i=0; i<5; i++){
                addr1 = new Customer_Address__c();
                addr1.Address__c = 'Test Address' +i;
                addr1.State__c = 'Test State' +i;
                addr1.City__c = 'Test City' +i;
                addr1.Country__c = 'Test Country'+i;
                addr1.PostalCode__c = '12345';
                addr1.Corp__c = '111111';
                addr1.Node__c = '1111';
                addr1.Route_Code__c = '1111111111';
                addr1.Region__c = 'BigSouthRegion';
                addr1.Division=bigSouthRegion .Id;
                addrList.add(addr1);
            }
            insert addrList; 
        
            
        
            //Create a bulk Level Plan 
            Plan__c pln = new Plan__c();
            pln.Name = 'TestPlan';
            pln.Plan_Level__c = 'Bulk';  
            pln.True_count_of_Addresses__c = 7; 
            pln.Expiration_Date__c = null;
            ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
            extnObj1.addressCount = 100;
            extnObj1.quickSave();
            extnObj1.selectedTemplate.Zip_Codes__c = '12345';
            extnObj1.getItems();
            extnObj1.searchBulkAddressses();            
            extnObj1.contractorDSSOption = conDSSUser.LastName;
            
            extnObj1.bulkAssignedAddressses();
            extnObj1.getPlanTypeValue();
            
            PageReference pageRef = Page.PlanEdit;
            Test.setCurrentPage(pageRef);
            
           //  delete pln;
            //extnObj1.quickSave();
            extnObj1.getItems();
            extnObj1.searchBulkAddressses();
            extnObj1.bulkAssignedAddressses();
            extnObj1.getPlanTypeValue();
        Test.StopTest();    
        }
    }
    
    private static testMethod void testPlaylistPlanAssignment(){
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = True;
        triggerSettingsList.add(userTrigger);
        
        TriggerSettings__c planTrigger = new TriggerSettings__c();
        planTrigger.Name = 'PlanTrigger';
        planTrigger.isActive__c = True;
        triggerSettingsList.add(planTrigger);
        
        TriggerSettings__c addressTrigger = new TriggerSettings__c();
        addressTrigger.Name = 'AddressTrigger';
        addressTrigger.isActive__c = True;
        triggerSettingsList.add(addressTrigger);
        
        insert triggerSettingsList;
        
        User rSAUser;
        User conDSSUser;
        Profile rsaProfile = [Select UserType, UserLicenseId, Name From Profile where Name like 'Regional System Admin (RSA)'];      
        UserRole rsaRole = [Select Id, Name from UserRole where Name='Regional Manager'];
        Profile conDSSProfile = [Select UserType, UserLicenseId, Name From Profile where Name like 'Contractor Sales Leader'];
        UserRole conDSSRole = [Select Id, Name from UserRole where Name='DS Supervisor'];
        
        String randomstr4 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';      
       
        System.runAs(user){
        rSAUser = new User(Alias = 'DA_' + randomstr4.substring(0,4),
                                    Email = randomstr4 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    IsActive = true ,
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = rsaProfile.Id,
                                    UserRoleId = rsaRole.Id,
                                    Username = 'userTest' + randomstr4 + '@SampleclassTest.com',
                                    Region__c = 'BigSouthRegion',
                                    FederationIdentifier = randomstr4+'FedId12',
                                    EmployeeNumber = 'Emp' + randomstr4.substring(0,4));
        insert rSAUser;
        }
        System.runAs(rSAUser) {
        String randomstr3 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        conDSSUser = new User(Alias = 'DA_' + randomstr3.substring(0,4),
                                    Email = randomstr3 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    IsActive = true ,
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = conDSSProfile.Id,
                                    UserRoleId = conDSSRole.Id,
                                    Username = 'userTest' + randomstr3 + '@SampleclassTest.com',
                                    Region__c = 'BigSouthRegion',
                                    FederationIdentifier = randomstr3+'1245',
                                    EmployeeNumber = 'Emp' + randomstr3.substring(0,4));
        insert conDSSUser;
        
       
        Test.StartTest();
         
        Division bigSouthRegion = [select id, name from Division where name ='Big South Region'];
        List<Customer_Address__c> addrList = new List<Customer_Address__c>();
            Customer_Address__c addr1;
            
            // Create 5 Customer Address Data
            for(integer i=0; i<5; i++){
                addr1 = new Customer_Address__c();
                addr1.Address__c = 'Test Address' +i;
                addr1.State__c = 'Test State' +i;
                addr1.City__c = 'Test City' +i;
                addr1.Country__c = 'Test Country'+i;
                addr1.PostalCode__c = '12345';
                addr1.Corp__c = '111111';
                addr1.Node__c = '1111';
                addr1.Route_Code__c = '1111111111';
                addr1.Region__c = 'Big South Region';
                addr1.Division=bigSouthRegion .Id;
                addrList.add(addr1);
            }
            insert addrList; 
            
            //Create a bulk Level Plan 
            Plan__c pln = new Plan__c();    
            pln.Name = 'TestPlan';
            pln.Plan_Level__c = 'Playlist';
            //pln.Parent_Plan__c = parentPlan.Id;   
            pln.Expiration_Date__c = system.Today() + 30;

            ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
            extnObj1.noOfSuccess = 10;
            extnObj1.showAssignedAddresses = true;
            //extnObj1.quickSave();
            extnObj1.selectedTemplate.Zip_Codes__c = '12345';
            extnObj1.createQueryString();
            extnObj1.searchAddressses();
            extnObj1.getItems();
            extnObj1.savePlan();
            extnObj1.searchBulkAddressses();            
            extnObj1.contractorDSSOption = conDSSUser.LastName;
            
            extnObj1.bulkAssignedAddressses();
            extnObj1.getPlanTypeValue();
            
            List<Customer_Address__c> updatedAddressList = new List<Customer_Address__c>();
            for(Customer_Address__c addr : addrList){
                addr.Plan__c = pln.Id;
                updatedAddressList.add(addr);
            }
            update updatedAddressList;
            
            extnObj1.selectedTemplate.Zip_Codes__c = '123,456';
            extnObj1.selectedTemplate.Nodes__c = '574,363';
            extnObj1.selectedTemplate.City__c = 'PUNE';
            extnObj1.selectedTemplate.Agent_Code__c = '123';
            extnObj1.selectedTemplate.Targeted__c = 'Yes';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Products__c= '2 Product Customer';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Products__c= '1 Product Customer';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Products__c= 'Video Only';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Products__c= 'HSI Only';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Products__c= 'Voice Only';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Products__c= 'HSI & Voice Only';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Products__c= 'Video';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Products__c= 'HSI';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Products__c= 'Voice';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Products__c= 'XH';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Products__c= 'XSS';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Products__c= 'Verizon Wireless';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Products__c= 'No Video';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Products__c= 'No HSI';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Products__c= 'No Voice';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Products__c= 'No Xfinity Home';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Agent_Code__c = '28';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Targeted__c = 'No';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Complex_Code_exists__c= 'No';
            extnObj1.createQueryString();
            extnObj1.selectedTemplate.Disconnect_Date__c = null;
            extnObj1.selectedTemplate.Last_Knock_Date__c = null;
            extnObj1.createQueryString();
            extnObj1.setCriteria();
            extnObj1.save();
            extnObj1.removalQueryFieldOption='Property_Code__c';
            extnObj1.removalQueryInputField='25875';
            extnObj1.addressRemovalSearch();
            PageReference pageRef = Page.PlanEdit;
            Test.setCurrentPage(pageRef);
        Test.StopTest();    
        }
    }
    
    private static testMethod void testPageMessages(){
         /* Profile p2 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Sales Development Manager'];
           private static     Profile p4 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Business Administrator'];
    UserRole r2 = [Select Id, Name from UserRole where Name='DS Supervisor'];
         String randomstr2 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
         String randomstr4 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        User businessAdminUser = new User(Alias = 'DA_' + randomstr4.substring(0,4),
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
        User  supervisorUser = new User(Alias = 'DA_' + randomstr2.substring(0,4),
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
                                    ManagerId = businessAdminUser.Id,
                                    FederationIdentifier = 'FedId3',
                                    EmployeeNumber = 'Emp' + randomstr2.substring(0,4));
        insert supervisorUser;*/
         /*   List<User> usersToInsert = new List<User>();
        contractorSalesLeader = new User(Alias = 'DA_' + randomstr10.substring(0,4),
                                    Email = randomstr10 + 'userTest@SampleclassTest.com',
                                    LastName='Testing5',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p6.Id,
                                    UserRoleId = r5.Id,
                                    Username = 'userTest5' + randomstr10 + '@SampleclassTest.com',
                                    Region__c = user.Region__c,
                                    Sales_Rep_Type__c = 'Contractor',
                                    Device_Phone_Number__c = '555555',
                                    PERNR__c = '55555555',
                                    Sales_ID__c = 'abc5555',
                                    ManagerId = user.Id,
                                    FederationIdentifier = 'FedId'+randomstr10,
                                    Business_Partner__c = 'TNT',
                                    EmployeeNumber = 'Emp' + randomstr10.substring(0,4)); 
        reContractorSalesLeader = new User(Alias = 'DA_' + randomstr11.substring(0,4),
                                    Email = randomstr11 + 'userTest@SampleclassTest.com',
                                    LastName='Testing6',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p6.Id,
                                    UserRoleId = r5.Id,
                                    Username = 'userTest5' + randomstr11 + '@SampleclassTest.com',
                                    Region__c = user.Region__c,
                                    Sales_Rep_Type__c = 'Contractor',
                                    Device_Phone_Number__c = '555555',
                                    PERNR__c = '55555555',
                                    Sales_ID__c = 'abc5555',
                                    ManagerId = user.Id,
                                    FederationIdentifier = 'FedId'+randomstr11,
                                    Business_Partner__c = 'TNT',
                                    EmployeeNumber = 'Emp' + randomstr11.substring(0,4)); 
            usersToInsert.add(contractorSalesLeader);
            usersToInsert.add(reContractorSalesLeader);
            insert usersToInsert;*/
            
        System.runAs(user){
            Test.startTest();
                PageReference pageRef = Page.PlanEdit;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('NodeOrZip', 'Node In (98564)'); 
                           
                Team__c team = new Team__c();
                team.Name = 'Test Team';
                team.Region__c = user.Region__c;
                team.Supervisor__c = user.Id;
                insert team;
                
                //Create a Parent Plan of Playlist Type
                Plan__c parentPlan = new Plan__c();
                parentPlan.Name = 'Test Parent Plan';
                parentPlan.Plan_level__c = 'Turf';
                parentPlan.User__c = user.Id;
                parentPlan.Assigned_Team__c = team.Id;
                parentPlan.Expiration_Date__c = System.today() + 45;
                parentPlan.Plan_Status__c = 'Draft';
                ApexPages.StandardController controller = new ApexPages.StandardController(parentPlan);
                PlanEditExtn extnObj1 = new PlanEditExtn(controller);
                
                extnObj1.noOfSuccess = 10;
                extnObj1.quickSave();
                extnObj1.savePlan();

                Plan__c childPlan = new Plan__c();    
                childPlan.Name = 'TestPlan';
                childPlan.Plan_Level__c = Label.PlanTypePlaylist;
                childPlan.Parent_Plan__c = parentPlan.Id; 
                childPlan.Expiration_Date__c = null;
                childPlan.Plan_Status__c = 'Draft';
                //childPlan.User__c = contractorSalesLeader.Id;
                ApexPages.StandardController controller1 = new ApexPages.StandardController(childPlan);
                PlanEditExtn extnObj2 = new PlanEditExtn(controller1);
                
                extnObj2.quickSave();
                extnObj2.savePlan();
                
                ApexPages.Message[] errorPageMessages = ApexPages.getMessages();
                System.assertNotEquals(0, errorPageMessages.size());
                Boolean errorPage = false;
                
                for(ApexPages.Message message : errorPageMessages){
                    if(message.getSeverity() == ApexPages.Severity.ERROR){
                        errorPage = true;
                    }
                }
                System.assert(errorPage);
            Test.stopTest();
        }
    }
}