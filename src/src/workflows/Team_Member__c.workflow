<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Flag_the_duplicate_members</fullName>
        <field>Unique_Check__c</field>
        <formula>User_Name__r.FirstName +  User_Name__r.LastName +  Team__r.Name</formula>
        <name>Flag the duplicate members</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Team_Role_Update</fullName>
        <field>Role__c</field>
        <formula>User_Name__r.UserRole.Name</formula>
        <name>Team: Role Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Team__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Team Members %3A Flag Duplicates</fullName>
        <actions>
            <name>Flag_the_duplicate_members</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Team_Member__c.User_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Team%3A Role Update</fullName>
        <actions>
            <name>Team_Role_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Team_Member__c.User_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
