/***************************************************************************************************************************************
 * Author     : Revan Kumar
 * Date       : 24-Feb-2016
 * Description: Managing & Accessing System Properties
 * User Story : US621425
 
***************************************************************************************************************************************/
public with sharing class SystemProperties {
    /*This getSytemProperty method for passing developer name with functional Area*/
    public String getSytemProperty(String propertyName,String functArea) {
        List<System_Property__mdt> lstSystemproperty = new List<System_Property__mdt> ();
        String valueForProperty = '';
        lstSystemproperty  = [SELECT Value__c FROM System_Property__mdt WHERE DeveloperName=:propertyName
                             AND Functional_Area__c=:functArea LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        if(!lstSystemproperty.isEmpty()) {
            for(System_Property__mdt itrSystemproperty : lstSystemproperty) {
                valueForProperty = itrSystemproperty.Value__c;                
            }
        }
        return valueForProperty;
    }  
}