/******************************************************************************************************************
 * Author     : Animesh Datta
 * Date       : 10-April-2017
 * Description: Keep repeated test data in this class for GoalTrigger and Call methods from test class
 ********************************************************************************************************************/
 
Public Class GoalTestDataUtility {
    
    //Method to create custom settings records
    public static void customSettingsRecord(){
        
        //Trigger setting custom settings list
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        //Create Trigger settings data for User Trigger
        TriggerSettings__c userTrigger = new TriggerSettings__c() ;
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = false;
            triggerSettingsList.add(userTrigger);
        
        //Create Trigger settings data for Goal Trigger
        TriggerSettings__c goalTrigger= new TriggerSettings__c();
            goalTrigger.Name = 'GoalTrigger';
            goalTrigger.isActive__c = true;
            triggerSettingsList.add(goalTrigger);
        
        //Create Trigger settings data for Contractor Region Mapping Trigger
        TriggerSettings__c contractTrigger = new TriggerSettings__c() ;
            contractTrigger.Name = 'ContractorRegionMappingTrigger';
            contractTrigger.isActive__c = true;
            triggerSettingsList.add(contractTrigger);
        //insert trigger setting list
        insert triggerSettingsList; 
    }
    
    //Create XC manager User
    public static User xcManager(){
        
        //get Profile Name: XC Manager
        Profile profile1 = [Select Id, Name From Profile where Name = 'XC Manager' limit 1];
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        //Populate neccessary Data for test user XC Manager
        User xcMgrUser = new User(Alias = 'DSR_' + randomstr.substring(0,4),
                                Email = randomstr + 'userTest1@SampleTest.com',
                                FirstName='Testing1',
                                LastName='Testing2',
                                EmailEncodingKey='UTF-8', 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                TimeZoneSidKey='America/Los_Angeles',
                                ProfileId = profile1.Id,
                                Username = 'userTest1' + randomstr + '@SampleTest.com',
                                Region__c = 'Freedom Market',
                                FederationIdentifier = 'FedId1'+randomstr,
                                UserPermissionsWorkDotComUserFeature = true,
                                EmployeeNumber = 'Emp1' + randomstr.substring(0,4), 
                                Sales_Rep_Type__c='RepType',
                                IsActive =True,
                                Level__c='Level',                
                                Terms_and_Conditions_Accepted__c = system.today());
        return xcMgrUser ;
    }
        
    //Create XC AE Contractor User
    public static User xcAEContractor(){
        
        //get Profile Name: XC AE Contractor
        Profile profile2 = [Select Id, Name From Profile where Name = :system.label.XC_AE_Contractors limit 1];
        //generate Random String 
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        //Populate neccessary Data for test user XC AE Contractor
        User xcAEContractorUser = new User(Alias = 'DSR_' + randomstr1.substring(0,4),
                                        Email = randomstr1 + 'userTest1@SampleTest.com',
                                        FirstName='Testing2',
                                        LastName='Testing2',
                                        EmailEncodingKey='UTF-8', 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        ProfileId = profile2.Id,
                                        Username = 'userTest1' + randomstr1 + '@SampleTest.com',
                                        Region__c = 'Freedom Market',
                                        FederationIdentifier = 'FedId1'+randomstr1,
                                        UserPermissionsWorkDotComUserFeature = true,
                                        EmployeeNumber = 'Emp1' + randomstr1.substring(0,4), 
                                        Sales_Rep_Type__c='RepType',
                                        IsActive =True,
                                        Level__c='Level',                                   
                                        Terms_and_Conditions_Accepted__c = system.today());
        return xcAEContractorUser ; 
        
    }   
}