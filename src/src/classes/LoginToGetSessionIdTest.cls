/**************************************************************************************************
Name : LoginToGetSessionIdTest
Description : This test class is created for test coverage of LoginToGetSessionId
Date : 07-May-2017
Author : Animesh Datta
***************************************************************************************************/
@isTest
private class LoginToGetSessionIdTest{
    
    /*
        Get mock response with status code 200
    */
    private static testMethod void logInTest(){        
            WorkTestDataUtility.createCustomSettingRecords();
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
                                        FederationIdentifier = 'FedId1'+randomstr,
                                        UserPermissionsWorkDotComUserFeature = true,
                                        EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                        Terms_and_Conditions_Accepted__c = system.today(),
                                        PERNR__c = '11111111'
              
                              );
            insert retailSalesRepUser;
            System.setPassword(retailSalesRepUser.id,'1234@abc');
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new LoginToGetSessionIdMockServiceImpl());
                LoginToGetSessionId.login('userTest1' + randomstr + '@SampleTest.com','1234@abc');
            Test.stopTest();
    }
    /*
        Get mock response with status code not 200
    */
    private static testMethod void logInExceptionTest(){        
        try{
            WorkTestDataUtility.createCustomSettingRecords();
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
                                        FederationIdentifier = 'FedId1'+randomstr,
                                        UserPermissionsWorkDotComUserFeature = true,
                                        EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                        Terms_and_Conditions_Accepted__c = system.today(),
                                        PERNR__c = '11111112'
                              );
            insert retailSalesRepUser;
            System.setPassword(retailSalesRepUser.id,'1234@abc');
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new LoginToGetSessionIdFailMockServiceImpl());
                LoginToGetSessionId.login('userTest1' + randomstr + '@SampleTest.com','1234@abc');
            Test.stopTest();
        }catch(Exception ex){}
    }
}