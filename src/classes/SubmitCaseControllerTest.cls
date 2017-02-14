@isTest
private class SubmitCaseControllerTest {
    
    @isTest static void SubmitCaseControllerTest() {
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
        System.runAs(user) { 
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
        PageReference pageRef = Page.SubmitCase;
        Test.setCurrentPage(pageRef);
        
        SubmitCaseController scc= new SubmitCaseController();

        scc.firstName='';
        scc.lastName='';
        scc.newcase.Region__c='';
        scc.newcase.Preferred_Email__c='';
        scc.newcase.Preferred_Phone__c='';
        scc.newcase.Request_Type__c='';
        scc.newcase.Ticket_Category__c='';
        scc.newcase.Ticket_Category_II__c='';
        scc.newcase.Channel__c='';
        scc.newcase.Description='';
        scc.SubmitCase();
        System.assert(ApexPages.hasMessages());
        scc.attachmentsAdded = attachmentAdded;
        scc.newcase.Preferred_Email__c='test@notcomcast.com';
        scc.SubmitCase();
        System.assert(ApexPages.hasMessages());


        SubmitCaseController sce= new SubmitCaseController();

        sce.firstName='testtt';
        sce.lastName='testtt';
        sce.newcase.Region__c='Big South Region';
        sce.newcase.Preferred_Email__c='deepraj.bhushan@accenture.com';
        sce.newcase.Preferred_Phone__c='442424';
        sce.newcase.Request_Type__c='';
        sce.newcase.Ticket_Category__c='';
        sce.newcase.Ticket_Category_II__c='';
        sce.newcase.Channel__c='Order Lab/Sales Portal';
        sce.newcase.Description='empty';
        sce.SubmitCase();
        System.assert(ApexPages.hasMessages());


        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('FirstName', dsrUser.FirstName);
        ApexPages.currentPage().getParameters().put('LastName', dsrUser.LastName);
        ApexPages.currentPage().getParameters().put('Region', dsrUser.Region__c);
        ApexPages.currentPage().getParameters().put('Email', dsrUser.Email);
        ApexPages.currentPage().getParameters().put('Phone', dsrUser.Phone);
        scc= new SubmitCaseController();
        scc.newcase.Request_Type__c='SFA 2';
        scc.newcase.Ticket_Category__c='Data';
        scc.newcase.Ticket_Category_II__c='Address';
        scc.newcase.Channel__c='Direct Sales';
        scc.newcase.Description='Test Run';
        scc.newcase.Preferred_Email__c='test_mctesty@cable.comcast.com';
      
        scc.SubmitCase();
        scc.newcase.Preferred_Email__c=dsrUser.Email;
        scc.SubmitCase();
        case newcase = new case(); 
        newcase.Request_Type__c='SFA 2';
        newcase.Ticket_Category__c='Data';
        newcase.Ticket_Category_II__c='Address';
        newcase.Channel__c='Direct Sales';
        newcase.Description='Test Run';
        newcase.Preferred_Email__c='test_mctesty@cable.comcast.com';
        insert newcase;
        scc.submitted = true;
        scc.SubmitCase();
        scc.fileBody1=Blob.valueOf('fileBody1');
        scc.fileName1='file1'; 
        Attachment atch1 = new Attachment();
        atch1.body = scc.fileBody1;
        atch1.Name = scc.fileName1;
        atch1.ParentId = newcase.Id;
        insert atch1;
        scc.fileBody2=Blob.valueOf('File 2 Attachment Body');
        scc.fileName2='file2';
        scc.fileBody3=Blob.valueOf('FileBody3');
        scc.fileName3='file3';
        Attachment atch3 = new Attachment();
        atch3.body = scc.fileBody3;
        atch3.Name = scc.fileName3;
        atch3.ParentId = newcase.Id;
        insert atch3;
        PageReference attachReturn = scc.attachFiles();
        Test.setCurrentPage(attachReturn);
        scc= new SubmitCaseController();
        System.assert(ApexPages.hasMessages());
    }
    
}