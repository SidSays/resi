<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Goal and Metrics</label>
    <protected>false</protected>
    <values>
        <field>Field_Set__c</field>
        <value xsi:type="xsd:string">Name,StartDate,DueDate,Description,RecordTypeId,Status,Division__c,Level__c,Profile_Name__c,Region__c,Sales_Rep_Type__c,Template_Type__c,(SELECT Name,StartDate,DueDate,Description,RecordTypeId,Status,TargetValue,Sort_Order__c FROM Metrics)</value>
    </values>
    <values>
        <field>Object_API_Name__c</field>
        <value xsi:type="xsd:string">Goal</value>
    </values>
</CustomMetadata>
