@isTest

private class SubmitOrderLabCaseControllerTest {
    
    @isTest static void SubmitOrderLabCaseControllerTest() {
        //SetupTestData.createCustomSettingRecords();
        boolean attachmentAdded = false;
        User dsrUser;
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
         TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = True;
            triggerSettingsList.add(userTrigger);
        
        TriggerSettings__c caseTrigger = new TriggerSettings__c();
            caseTrigger.Name = 'CaseTrigger';
            caseTrigger.isActive__c = True;
            triggerSettingsList.add(caseTrigger);
            insert triggerSettingsList;
          
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        system.runAs(user){
                    Profile p1 = [Select UserType, UserLicenseId, Name From Profile where Name like 'XFINITY Sales Professional'];
                    UserRole r1 = [Select Id, Name from UserRole where Name='DSR'];
                    dsrUser = new User(Alias = 'McTest',
                                                Email = 'test_mctest@cable.comcast.com',
                                                FirstName='Fred',
                                                LastName='McTest',
                                                Phone='(216) 654-9813',
                                                EmailEncodingKey='UTF-8', 
                                                LanguageLocaleKey='en_US', 
                                                LocaleSidKey='en_US', 
                                                TimeZoneSidKey='America/Los_Angeles',
                                                ProfileId = p1.Id,
                                                UserRoleId = r1.Id,
                                                Username = 'test_mctest@cable.comcast.com',
                                                Region__c = 'Beltway',
                                                Sales_Rep_Type__c = 'Upgrade',
                                                Device_Phone_Number__c = '111111',
                                                PERNR__c = '11111111',
                                                Sales_ID__c = 'abc1111',
                                                ManagerId = UserInfo.getUserId(),
                                                FederationIdentifier = 'FedId4',
                                                EmployeeNumber = 'Emp1234'); 
                    insert dsrUser;
          }
        PageReference pageRef = Page.SubmitOrderLabCase;
        Test.setCurrentPage(pageRef);
        SubmitOrderLabCaseController scc;
        System.runAs(dsrUser){
            ApexPages.currentPage().getParameters().put('FirstName', 'TestFirst');
            ApexPages.currentPage().getParameters().put('LastName', 'TestLast');
            ApexPages.currentPage().getParameters().put('Region', 'Beltway');
            ApexPages.currentPage().getParameters().put('Email', 'abc@abc.com');
            ApexPages.currentPage().getParameters().put('Phone', '9708099890');
            scc = new SubmitOrderLabCaseController();
            scc.SubmitCase();
            scc.newcase.Channel__c = 'Direct Sales';
            scc.newcase.Request_Type__c = 'SFA 2';
            scc.newcase.Ticket_Category__c='Reporting';
            scc.newcase.Ticket_Category_II__c='Address';
            scc.newcase.Description = 'Test Desc';
            scc.newcase.OrderID__c='5555555';
            scc.newcase.Region__c='Corporate';
            scc.newcase.AccountNumber__c='790989766';
            scc.SubmitCase();
            scc.newcase.Report_Name__c = 'Test Report';
            scc.fileName1='fn1';
            scc.fileBody1=Blob.valueOf('fileBody1');
            scc.fileName2='fn2';
            scc.fileBody2=Blob.valueOf('fileBody2');
            scc.fileName3='fn3';
            scc.fileBody3=Blob.valueOf('fileBody3');
            scc.contentType1 = 'Text';
            scc.contentType2 = 'Text';
            scc.contentType3 = 'Text';
            scc.errorMessages = 'Test Error';
            scc.channelName ='Test Channel';
            scc.SubmitCase();
            
            Case newcase = new Case(); 
            newcase.Requested_For__c=dsruser.Id;
            newcase.AccountNumber__c='790989766';
            newcase.Preferred_Phone__c='9708099890';
            newcase.Request_Type__c='SFA 2';
            newcase.Ticket_Category__c='Data';
            newcase.Ticket_Category_II__c='Address';
            newcase.Channel__c='Direct Sales';
            newcase.Region__c='Corporate';
            newcase.Description='Test Run';
            newcase.OrderID__c='5555555';
            newcase.Region__c='Beltway Market';
            newcase.Preferred_Email__c='test_mctesty@cable.comcast.com';
        
        	insert newcase;
            ApexPages.currentPage().getParameters().put('CaseId', newcase.Id);
        	
            scc= new SubmitOrderLabCaseController();
        }
        
    }
    
}