public with sharing class StoreQueryUtilityLight {
    @AuraEnabled
    public static Account queryStore(final Id storeId) {
        return [
            SELECT Id, Name, Store_Nickname__c, Store_Type__c, 
                Store_Location__latitude__s, Store_Location__longitude__s,
                Billing_Address__c
            FROM Account
            WHERE Id = :storeId
            ];
    }

    @AuraEnabled
    public static UserRole queryUserRole(final Id roleId) {
        return [
            SELECT DeveloperName
            FROM UserRole
            WHERE Id = :roleId
            ];
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
}