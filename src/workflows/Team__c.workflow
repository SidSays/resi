<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Flag_the_duplicate_teams</fullName>
        <field>Unique_Check__c</field>
        <formula>Name +  TEXT(Region__c)</formula>
        <name>Flag the duplicate teams</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Team %3A Flag Duplicates</fullName>
        <actions>
            <name>Flag_the_duplicate_teams</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Team__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
