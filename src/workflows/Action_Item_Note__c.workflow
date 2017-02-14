<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Last_Updated_field</fullName>
        <field>Last_Updated__c</field>
        <formula>TODAY()</formula>
        <name>Last Updated field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Action_Item__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Last Updated field</fullName>
        <actions>
            <name>Last_Updated_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Action_Item_Note__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
