<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateRegionMappingKey</fullName>
        <field>Region_Mapping_Key__c</field>
        <formula>( AE_Contractor__c ) &amp; &quot;_&quot; &amp;( TEXT( Region__c ) )</formula>
        <name>UpdateRegionMappingKey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Contractors Region Mapping</fullName>
        <actions>
            <name>UpdateRegionMappingKey</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
