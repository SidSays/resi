/**************************************************************************************************
Name : DSMTestDataUtility
Description : This is Utility class created to create Test data for DSM
Date : 1 Oct 2015
Author : Ashish Sonawane
***************************************************************************************************/
@isTest
public class DSMTestDataUtility{   
   
   /*
     * This method create custom setting record for AccountManagementServiceCS__c for Direct Sales App
     * Author : Ashish Sonawane
    */  
    public static void generateAccountManagementServiceCS(){
        
        List<AccountManagementServiceCS__c> accountContactCSList = new List<AccountManagementServiceCS__c>();     
        accountContactCSList.add(new AccountManagementServiceCS__c(Name = 'Endurl',Param_Value__c='https://eproxy-int.comcast.net/AccountManagementService/15.04'));        
        accountContactCSList.add(new AccountManagementServiceCS__c(Name = 'numberOfRecentMonths',Param_Value__c='1'));        
        accountContactCSList.add(new AccountManagementServiceCS__c(Name = 'Password', Param_Value__c='WR30tnI7s#4'));        
        accountContactCSList.add(new AccountManagementServiceCS__c(Name = 'SystemServiceId', Param_Value__c='SalesSpace'));        
        accountContactCSList.add(new AccountManagementServiceCS__c(Name = 'Username', Param_Value__c='sfespuser'));
        Database.insert(accountContactCSList);
    }
    
}