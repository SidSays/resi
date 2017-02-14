@isTest
private class QPRTriggerControllerTest{
    
    static void AssignPermissionSet(String permissionSetName, Id userId){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa);      
    }
    
    public static testMethod void doNotDeleteCompletedQPRTest() {
        //generate Random String 
        WorkTestDataUtility.createCustomSettingRecords();
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        Profile profile2 = [Select Id, Name From Profile where Name = 'Xfinity CAR Manager' limit 1];
        User carManager = new User();
        User carUser = new User();
        Quarterly_Portfolio_Review__c qprRecord;
        system.runAs(new User(Id = UserInfo.getUserId())){
            carManager = new User(Alias = 'CAR_' + randomstr1.substring(0,4),
                                        Email = randomstr1 + 'userTest1@SampleTest.com',
                                        FirstName='Testing2',
                                        LastName='Testing2',
                                        EmailEncodingKey='UTF-8', 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        ProfileId = profile2.Id,
                                        Username = 'userTest1' + randomstr1 + '@SampleTest.com',
                                        Region__c = 'Beltway Market',
                                        FederationIdentifier = 'FedId1'+randomstr1,
                                        EmployeeNumber = 'Emp1' + randomstr1.substring(0,4), 
                                        IsActive =True,
                                        Level__c='Level',
                                        UserPermissionsWorkDotComUserFeature = true,                                
                                       Terms_and_Conditions_Accepted__c = system.today());
                        insert carManager;
                AssignPermissionSet('SalesSpace_Coach_Access_CAR_Manager',carManager.Id); 
        
            Profile profile1 = [Select Id, Name From Profile where Name = 'Xfinity CAR' limit 1];
            //generate Random String 
            String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
            carUser = new User(Alias = 'CAR_' + randomstr.substring(0,4),
                                        Email = randomstr + 'userTest1@SampleTest.com',
                                        FirstName='Testing1',
                                        LastName='Testing2',
                                        EmailEncodingKey='UTF-8', 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        ProfileId = profile1.Id,
                                        Username = 'userTest1' + randomstr + '@SampleTest.com',
                                        Region__c = 'Beltway Market',
                                        FederationIdentifier = 'FedId1'+randomstr,
                                        EmployeeNumber = 'Emp1' + randomstr.substring(0,4), 
                                        IsActive =True,
                                        Level__c='Level',
                                        UserPermissionsWorkDotComUserFeature = true,
                                        ManagerId = carManager.id,
                                       Terms_and_Conditions_Accepted__c = system.today());
                    insert carUser;
            AssignPermissionSet('SalesSpace_Coach_Access_CAR',carUser.Id); 
        }
        System.runAs(carManager){
            WorkCoaching coachingRecord= new WorkCoaching();
            coachingRecord.CoachId = carManager.Id;
            coachingRecord.CoachedId = carUser.Id;
            
            insert coachingRecord;
         
        qprRecord = new Quarterly_Portfolio_Review__c();
            qprRecord.Name = 'test';
            qprRecord.X90_Day_Marketing_Plan__c = 'Test';
            qprRecord.X90_Day_Marketing_Plan_Due_Date__c= system.today();
            qprRecord.Coaching__c = coachingRecord.id;
            qprRecord.Monthly_Action_Plan__c  = 'Test';
            qprRecord.Monthly_Action_Plan_Due_Date__c = system.today();
            qprRecord.Weekly_Action_Plan__c = 'Test';
            qprRecord.Weekly_Action_Plan_Due_Date__c = system.today();
            qprRecord.Status__c = 'Draft';
         
            insert qprRecord;
        }        
            List<MDU_Property__c> propertyList = new List<MDU_Property__c>();
            
            system.runAs(new User(Id = UserInfo.getUserId())){
            for(integer i=0;i<10;i++){
                MDU_Property__c property = new MDU_Property__c();
                property.Name = 'Test' + i;
                property.Address__c = 'Test' + i;
                property.Corporate__c = 'Comcast Cable';
                property.Property_Division__c = 'Northeast';
                property.City__c = 'Test' + i;
                property.MDU_State__c = 'Kansas';
                property.Property_Region__c = 'Beltway Market';
                property.Coffee_Vendor_on_Site__c = 'N/A';
                property.Assigned_CAR__c = carUser.id;
                property.Industry_Type__c = 'Commercial';
                property.Property_Type__c = 'Commercial';
                property.Number_of_Units__c = 3;
                property.Comcast_Video_Serviced__c = 'No';
                property.Comcast_Voice_Serviced__c = 'No';
                property.Comcast_Data_Serviced__c = 'No';
                property.Property_Area__c =     'DC Metro';
                property.System__c = 'DC';
                
                    propertyList.add(property);             
            }
                     
            Database.SaveResult[] propList = Database.insert(propertyList,false);
            }
            test.starttest();
                qprRecord.Top_Property_1__c = propertyList[0].Id;
                qprRecord.Bottom_Property_1__c = propertyList[1].Id;
                qprRecord.Top_Property_2__c = propertyList[2].Id;
                qprRecord.Bottom_Property_2__c = propertyList[3].Id;
                qprRecord.Top_Property_3__c = propertyList[4].Id;
                qprRecord.Bottom_Property_3__c = propertyList[5].Id;
                qprRecord.Top_Property_4__c = propertyList[6].Id;
                qprRecord.Bottom_Property_4__c = propertyList[7].Id;
                qprRecord.Top_Property_5__c = propertyList[8].Id;
                qprRecord.Bottom_Property_5__c = propertyList[9].Id;
                update qprRecord;
            test.stoptest();
            
            system.runAs(carManager){
                qprRecord.Status__c = 'Completed';
                update qprRecord;
                try{
                    Delete qprRecord;
                    }catch(Exception ex){
                }
            }
            try{
                Delete qprRecord;
                }catch(Exception ex){
            }
    }
}