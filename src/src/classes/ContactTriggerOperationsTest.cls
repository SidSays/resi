/***************************************************************************************************************************************
 * Author     :Jui Desai, Accenture
 * Date       : 27-Feb-2015
 * Description: This is Test class for "ContactTrigger" trigger
 * History
     Version             : 1.0
     Author Last Updated : Jui, Accenture 
     PROJECT             : MDU Salesforce
***************************************************************************************************************************************/
@isTest (seeAllData = false)

Public Class ContactTriggerOperationsTest
{
    private static testMethod void contactTriggerOperationsTest(){    
        
        SetupTestData.createCustomSettingRecords(); 
        Test.startTest();  
        
        /*Create Contact records*/
        List<Contact> ContactObject = TestDataUtility.createContactRecord(10);
        for(integer i = 0 ; i < 9; i++){            
            insert ContactObject[i];
        }
        
        /*Set one record as primary contact*/
        List<Contact> ContactList =[select Primary_Contact__c from Contact where id IN:ContactObject];  
        ContactList[0].Primary_Contact__c=true;
        update ContactList;
        
        /*Set another record as primary contact*/
        try{
            List<Contact> updatedContactList = new List<Contact>();
            for(Contact ContactObj :ContactList){
            ContactObj.Primary_Contact__c=true;
            updatedContactList.add(ContactObj);
            }
            update ContactList;
        }
        catch(Exception e){
            Boolean exp =  e.getMessage().contains(System.Label.Primary_Contact_Trigger_Validation) ? true : false;
            system.assertEquals(exp,true);
        }
         
        Test.stopTest();
     }
}