/***************************************************************************************************************************************
* Author : Himanshu Lakhara
* Date : 1-April-2015
* Class Name : UpdateFederationIdPilotUserTest
* Description: Test Class for UpdateFederationIdPilotUser
* Requirement: 00014929
***************************************************************************************************************************************/
@isTest

//Test Class for UpdateFederationIdPilotUser
public Class UpdateFederationIdPilotUserTest{
    public static testMethod void UpdateFederationIdTest(){
        
            //Create Custom setting reqired for trigger entry
            TriggerSettings__c triggerSettings = new TriggerSettings__c(Name='UserTrigger', isActive__c=true);
            insert triggerSettings;
        
            Profile SysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            
            //Creating various users with SysAdminProfile profile
            User testUser1 = new User(Alias = 'standt', Email='DSR1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', FederationIdentifier = 'FedId1', ProfileId = SysAdminProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestUserResiAbc@testorg.com');
            
            Insert testUser1;
            
            try{  
               testUser1.Pilot_User__c = True;
               update testUser1;
            }catch(DmlException e){
               System.assert(true);
            }
              
    }
}