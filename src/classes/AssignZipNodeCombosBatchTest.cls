@isTest
private class AssignZipNodeCombosBatchTest {
    public static User supervisorUser;
    public static User managerUser;
    private static Profile p2 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Sales Development Manager'];
    private static UserRole r2 = [Select Id, Name from UserRole where Name='DS Supervisor'];
    private static Profile p3 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Area Sales Manager'];
    private static UserRole r3 = [Select Id, Name from UserRole where Name='DS Manager'];

    private static void createUser() {
        String randomstr2 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr3 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        
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
                            Region__c = 'Freedom Market',
                            //ManagerId = businessAdminUser.Id,
                            FederationIdentifier = 'FedId28',
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
                            Region__c = 'Freedom Market',
                            ManagerId = managerUser.Id,
                            FederationIdentifier = 'FedId29',
                            EmployeeNumber = 'Emp' + randomstr3.substring(0,4));
        insert supervisorUser;
    }

    @isTest 
    static void testZipNodeCombos() {
        System.runAs(new User(Id = Userinfo.getUserId())) {

            try{
                SetupTestData.createCustomSettingRecords();
                createUser();
                
                Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
                
                Customer_Address__c address1 = new Customer_Address__c();
                    address1.Address__c = 'Test Address Line1';
                    address1.City__c = 'Test city';
                    address1.State__c = 'Test State';
                    address1.PostalCode__c = '98564';
                    address1.Country__c = 'Test Country';
                    address1.Corp__c = '111111';
                    address1.Route_Code__c = '1111111111';
                    address1.Node__c = '1111';
                    address1.Division = freedomRegion.Id;
                    address1.Region__c='Freedom Market';
                insert address1;

                Zip_Node_Combinations__c znc= new Zip_Node_Combinations__c();
                    znc.Name=address1.Node__c+'/'+address1.PostalCode__c+address1.Region__c;
                    znc.Node__c=address1.Node__c;
                    znc.Zip_Code__c=address1.PostalCode__c;
                    znc.Region__c=address1.Region__c;
                    znc.Completed__c = false;
                insert znc;

                test.startTest();
                    AssignZipNodeCombosBatch azncb=new AssignZipNodeCombosBatch();
                    azncb.assignedToUser=supervisorUser;
                    Database.executeBatch(azncb);
                test.stopTest();
            }
            Catch(Exception E){
                System.debug('---' +E);
            }
        }
    } 

    @isTest 
    static void testNodeComplexCodeCombos() {
        System.runAs(new User(Id = Userinfo.getUserId())) {

            try{
                Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
                
                SetupTestData.createCustomSettingRecords();
                createUser();   
                
                Customer_Address__c address1 = new Customer_Address__c();
                    address1.Address__c = 'Test Address Line1';
                    address1.City__c = 'Test city';
                    address1.State__c = 'Test State';
                    address1.PostalCode__c = '98565';
                    address1.Country__c = 'Test Country';
                    address1.Corp__c = '111111';
                    address1.Route_Code__c = '1111111111';
                    address1.Node__c = '2222';
                    address1.Property_Code__c='ABCD';
                    address1.Division = freedomRegion.Id;
                    address1.Region__c= 'Freedom Market';
                insert address1;


                Zip_Node_Combinations__c znc3= new Zip_Node_Combinations__c();
                    znc3.Name=address1.Node__c+'/'+address1.Property_Code__c+address1.Region__c;
                    znc3.Node__c=address1.Node__c;
                    znc3.Property_Code__c=address1.Property_Code__c;
                    znc3.Region__c=address1.Region__c;
                    znc3.Completed__c = false;
                insert znc3;

                test.startTest();
                    AssignZipNodeCombosBatch azncb=new AssignZipNodeCombosBatch();
                    azncb.assignedToUser=supervisorUser;
                    Database.executeBatch(azncb);
                test.stopTest();
            }
            Catch(Exception E){
            System.debug('---' +E);
            }

        }
    }
}