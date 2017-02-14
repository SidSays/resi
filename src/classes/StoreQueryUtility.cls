/**
 * Utility class for store related queries 
 *
 * @author  Ryan Sayles     <rsayles@acumensolutions.com>
 * @author  Sahil Grover    <sgrover@acumensolutions.com>
 */

public with sharing class StoreQueryUtility {

    public static Account queryStore(final Id storeId) {
        return [
            SELECT Id, Name, Store_Nickname__c, Store_Type__c, 
                Store_Location__latitude__s, Store_Location__longitude__s,
                Billing_Address__c
            FROM Account
            WHERE Id = :storeId
            ];
    }
 
    public static UserRole queryUserRole(final Id roleId) {
        UserRole objUserRole = new UserRole ();
        if(roleId!=null) {
            objUserRole = [SELECT DeveloperName FROM UserRole WHERE Id = :roleId];
        }
        return objUserRole;
    }

    public static List<Store_Visit_Activity_Category__c> queryActivityCategories(final String storeType, final String userRoleName) {
        return new List<Store_Visit_Activity_Category__c>([
            SELECT Number_Required__c, Record_Type_Name__c, Store_Activity_Category__c, Email_Template__c,
                Send_Mail_Check_Field__c, Store_Type__c
            FROM Store_Visit_Activity_Category__c
            WHERE Store_Type__c = :storeType AND User_Role__c = :userRoleName
            ORDER BY Number_Required__c DESC
            ]);
    }

    public static List<Store_Activity__c> queryStoreActivities(final Id storeVisitId){
        return new List<Store_Activity__c>([
            SELECT Id, Name, RecordTypeId, RecordType.DeveloperName, CreatedDate, LastModifiedDate, Notes__c,
                Is_Activity_Complete__c, Store_Type__c
            FROM Store_Activity__c
            WHERE Store_Visit__c = :storeVisitId
            ]);
    }

    public static List<RecordType> queryRecordTypes(final String sobjectName) {
        return new List<RecordType>([
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE SobjectType = :sobjectName
            ]);
    }

    public static EmailTemplate queryEmailTemplate(final String templateName) {
        return [
            SELECT Id, Body, HtmlValue
            FROM EmailTemplate
            WHERE DeveloperName = :templateName
            LIMIT 1
        ];
    }

    public static Map<Id, Account> queryStoreMap(final Set<String> storeIds) {
        return new Map<Id, Account>([
            SELECT Id, Last_Visit_Date__c, Name, Store_Nickname__c, Store_Type__c, 
                Store_Location__latitude__s, Store_Location__longitude__s
            FROM Account
            WHERE Id IN :storeIds
            ]);
    }

    public static Store_Visit__c queryStoreVisit(final Id visitId) {
       System.debug('>>>>visitId'+visitId);
       Store_Visit__c obj = [
            SELECT Id, Store__c, Start_Date_Time__c, End_Date_Time__c, Notes__c,Visit_Type__c,
                OwnerId, Owner_Full_Name__c, ShowPopup__c, Store_Address__c, Store_Name__c, Prospect_Store_Name__c,
                Store_Visit_Status__c,Old_records__c                
            FROM Store_Visit__c
            WHERE Id = :visitId
            LIMIT 1
            ];
            System.debug('>>>obj'+obj);
        return obj; 
    }

    public static List<Task> queryVisitTasks(final Id visitId) {
        return new List<Task>([
            SELECT Id, Subject, OwnerId, Status
            FROM Task
            WHERE WhatId = : visitId
            ]);
    }

    public static RecordType queryRecordType(String recordTypeDevName) {
        return [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :recordTypeDevName
            LIMIT 1
        ];
    }

    public static User queryUser(Id userId) {
        User objUser = new User();
        if(userId!=null) {
           objUser = [SELECT Id, Email, UserRoleId ,managerid FROM User WHERE Id = :userId LIMIT 1];
        }
        return objUser; 
    }
    
}