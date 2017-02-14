/***************************************************************************************************************************************
 * Author     : Revan Kumar
 * Date       : 24-Feb-2016
 * Description: Test class for System Properties Apex Class
 * User Story : US621425
 
***************************************************************************************************************************************/
@isTest
public class SystemPropertiesTest {
    public static TestMethod void SystemPropertiestestMethod() {
        System_Property__mdt objSystem = new System_Property__mdt();
        List<System_Property__mdt> objSystemproperty = [SELECT Functional_Area__c,DeveloperName FROM System_Property__mdt LIMIT 1];
        Test.Starttest();
        if(objSystemproperty != null && objSystemproperty.size() > 0){
            SystemProperties objCls = new SystemProperties();
            objCls.getSytemProperty(objSystemproperty.get(0).DeveloperName,objSystemproperty.get(0).Functional_Area__c);
        }
        Test.Stoptest();
    }
}