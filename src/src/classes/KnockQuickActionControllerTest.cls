/******************************************************************************************************************
 * Author     : Malay Desai, Accenture
 * Description: Test Class for KnockQuickActionController
 * @Last Modified By: Malay Desai, Accenture
 * @User Story: US1139040	DSM to SF1: Actions - Knock and Log Knock Location (Dev Continued + TQM),
 * @Last Modified Date: 2-Aug-2017  
 ********************************************************************************************************************/

@isTest
public class KnockQuickActionControllerTest{

    static testMethod void testGetAllPicklistValues(){        
    	 Test.startTest();
         KnockQuickActionController.getAllPicklistValues();
         Test.stopTest();
    }
    
 	static testMethod void testCreateNewKnock(){
  	        insert new TriggerSettings__c(Name='TaskTrigger', IsActive__c=true);
      		insert new TriggerSettings__c(Name='AddressTrigger', IsActive__c=true);
      		insert new TriggerSettings__c(Name='PropertyTrigger', IsActive__c=true);
      		insert new TriggerSettings__c(Name='PropertyEventTrigger', IsActive__c=true);
      
            Customer_Address__c addr = new Customer_Address__c();
            addr.Address__c = 'Test Address';
            addr.State__c = 'Test State';
            addr.City__c = 'Test City';
            addr.Country__c = 'Test Country';
            addr.PostalCode__c = '12345';
            addr.Node__c = '1111';
            addr.Corp__c = '11111111';
            addr.Route_Code__c = '1111111111';
            addr.Region__c = 'Freedom Market';
            addr.Latitude__c=41.405556;
            addr.Longitude__c=-81.664167;            
            addr.Rejected_Reason__c = 'test';
            insert addr;
            
            MDU_Property__c property;
            property = new MDU_Property__c();
            property.Name = 'Test';
            property.Address__c = 'Test';
            property.Corporate__c = 'Comcast Cable';
            property.Property_Division__c = 'Northeast';
            property.City__c = 'Test';
            property.MDU_State__c = 'Kansas';
            property.Property_Region__c = 'Freedom Market';
            property.Coffee_Vendor_on_Site__c = 'No';
            property.Industry_Type__c = 'Commercial';
            property.Property_Type__c = 'Commercial';
            property.Number_of_Units__c = 3;
            property.Comcast_Video_Serviced__c = 'No';
            property.Comcast_Voice_Serviced__c = 'No';
            property.Comcast_Data_Serviced__c = 'No';
            property.Property_Area__c =     'DC Metro';
            property.System__c = 'DC';
            insert property;
            Property_Events__c propertyEvent;
            propertyEvent = new Property_Events__c();
            propertyEvent.Name = 'Test';
            propertyEvent.Start_Time__c = system.now();
            propertyEvent.Property__c = property.id;
            propertyEvent.End_Time__c = system.now();
            propertyEvent.Type__c = 'Other';
            propertyEvent.Voice__c = null;
            propertyEvent.Video__c = null;
            propertyEvent.XH__c = null;
            propertyEvent.HSI__c = null;
  			insert propertyEvent;
      
  			Test.startTest();
  			String propEventId = propertyEvent.id; 
            String Enddate = '2017-12-31';
  			//Normal test
            KnockQuickActionController.createNewKnock(addr.id,41.375556, 81.68083, 'Start','AT&T', 'AT&T', 
                 'AT&T', 'ADT','Winback','test',Enddate,Enddate, 
                 Enddate, Enddate, true,true,true,true,'other',propEventId,'test','test');

			//Exception			                
  			delete [SELECT Id FROM TriggerSettings__c WHERE NAME='TaskTrigger'];
            KnockQuickActionController.createNewKnock(addr.id,41.375556, 81.68083, 'Start','AT&T', 'AT&T', 
                 'AT&T', 'ADT','Winback','test',Enddate,Enddate, 
                 Enddate, Enddate, true,true,true,true,'other',null,'test','test');
  
  			List<Task> knockList = [SELECT Id FROM Task WHERE WhatId =:addr.Id];
  			System.assertEquals(1, knockList.size());

  			Test.stopTest();
	}
 }