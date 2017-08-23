/**************************************************************************************************
* Name : VariableSettingTestUtility
* Description : Keep custom settings(Variable_Setting__c) data here to use in test class
* Date : 08-may-2017
* Author : Animesh Datta
***************************************************************************************************/
@isTest
public class VariableSettingTestUtility{
    public static void variableSettingsData() {
        system.runAs(new User(Id = Userinfo.getUserId())){
            List<Variable_Setting__c> csSetDataList = new List<Variable_Setting__c>();
            Variable_Setting__c variableSetting1 = new Variable_Setting__c();
            variableSetting1.name = 'ReadShareAccess';
            variableSetting1.Description__c = 'Share records in Read only mode';
            variableSetting1.Value__c = 'Read';
            csSetDataList.add(variableSetting1);
            
            Variable_Setting__c variableSetting2= new Variable_Setting__c();
            variableSetting2.name = 'ManualShare';
            variableSetting2.Description__c = 'Share records manually i.e. sharing reason = Manual';
            variableSetting2.Value__c = 'Manual';
            csSetDataList.add(variableSetting2);
            
            Variable_Setting__c variableSetting3 = new Variable_Setting__c();
            variableSetting3 .name = 'ManagerGroup';
            variableSetting3 .Description__c = 'value = Manager. Using in query to fetch manager group';
            variableSetting3 .Value__c = 'Manager';
            csSetDataList.add(variableSetting3);
            
            Variable_Setting__c variableSettings4 = new Variable_Setting__c();
            variableSettings4.Name = 'Address_link_to_Territory_Update';
            variableSettings4.Value__c = 'True';
            csSetDataList.add(variableSettings4);
            
            Variable_Setting__c variableSettings5 = new Variable_Setting__c();
            variableSettings5.Name = 'ProfileCheckForCoachingSharing';
            variableSettings5.Value__c = 'XFINITY Sales Professional,Sales Development Manager,Area Sales Manager,Xfinity CAR,Xfinity CAR Manager,Retail Sales Rep';
            csSetDataList.add(variableSettings5);
            
            Variable_Setting__c variableSettings6 = new Variable_Setting__c();
            variableSettings6.Name = 'BusinessAdminProfile';
            variableSettings6.Value__c = 'Business Administrator';
            csSetDataList.add(variableSettings6);
            
            Variable_Setting__c variableSettings7 = new Variable_Setting__c();
            variableSettings7.Name = 'ShareDataUser';
            variableSettings7.Value__c = 'Shared Data User';
            csSetDataList.add(variableSettings7);
            
            Variable_Setting__c variableSettings8 = new Variable_Setting__c();
            variableSettings8.Name = 'Centraldivision';
            variableSettings8.Value__c = 'Central';
            csSetDataList.add(variableSettings8);
            
            Variable_Setting__c variableSettings9 = new Variable_Setting__c();
            variableSettings9.Name = 'HSIOnly';
            variableSettings9.Value__c = 'No';
            csSetDataList.add(variableSettings9);
            
            Variable_Setting__c variableSettings10 = new Variable_Setting__c();
            variableSettings10.Name = 'nedivision';
            variableSettings10.Value__c = 'Northeast';
            csSetDataList.add(variableSettings10);
            
            Variable_Setting__c variableSettings11 = new Variable_Setting__c();
            variableSettings11.Name = 'westdivision';
            variableSettings11.Value__c = 'West';
            csSetDataList.add(variableSettings11);
            
                       
            Variable_Setting__c variableSettings13 = new Variable_Setting__c();
            variableSettings13.Name = 'AppBatchClass';
            variableSettings13.Value__c = 'Batch Class';
            csSetDataList.add(variableSettings13);
            
            Variable_Setting__c variableSettings14 = new Variable_Setting__c();
            variableSettings14.Name = ' Appbatchdeletebatch';
            variableSettings14.Value__c = 'ApplicationLogPurgeBatch';
            csSetDataList.add(variableSettings14);
            
            Variable_Setting__c variableSettings15 = new Variable_Setting__c();
            variableSettings15.Name = 'AppTrigger';
            variableSettings15.Value__c = 'Trigger';
            csSetDataList.add(variableSettings15);
           
            Variable_Setting__c variableSettings16 = new Variable_Setting__c();
            variableSettings16.Name = 'AppClass';
            variableSettings16.Value__c = 'Class';
            csSetDataList.add(variableSettings16);
            
            Variable_Setting__c variableSettings17 = new Variable_Setting__c();
            variableSettings17.Name = 'AppCommaseperator';
            variableSettings17.Value__c = ',';
            csSetDataList.add(variableSettings17);
            Variable_Setting__c variableSettings18 = new Variable_Setting__c();
            variableSettings18.Name = 'APPDMLException';
            variableSettings18.Value__c = 'DmlException';
            csSetDataList.add(variableSettings18);
            Variable_Setting__c variableSettings19 = new Variable_Setting__c();
            variableSettings19.Name = 'AppExceptionConnector';
            variableSettings19.Value__c = ':-->';
            csSetDataList.add(variableSettings19);
            Variable_Setting__c variableSettings20 = new Variable_Setting__c();
            variableSettings20.Name = 'AppExceptionConnector2';
            variableSettings20.Value__c = 'On Record Id-->';
            csSetDataList.add(variableSettings20);
            Variable_Setting__c variableSettings21 = new Variable_Setting__c();
            variableSettings21.Name = 'AppLogPurgeQuery';
            variableSettings21.Value__c = 'Select Id from Application_Log__c where RecordTypeid =:nonintegrationRTypeId Limit 100';
            csSetDataList.add(variableSettings21);
            Variable_Setting__c variableSettings22 = new Variable_Setting__c();
            variableSettings22.Name = 'NonIntegrationLogRecordType';
            variableSettings22.Value__c = 'Non Integration Log';
            csSetDataList.add(variableSettings22);
            Variable_Setting__c variableSettings23 = new Variable_Setting__c();
            variableSettings23.Name = 'PropertyVisitCompleted';
            variableSettings23.Value__c = 'Completed';
            csSetDataList.add(variableSettings23);
            
            insert csSetDataList;
        }
    }
}