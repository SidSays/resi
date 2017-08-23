<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Capture_Lead_Closed_Date</fullName>
        <field>Closed_Date__c</field>
        <formula>TODAY()</formula>
        <name>Capture Lead Closed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Capture_Ownership_Transfer_Date</fullName>
        <field>Ownership_Transfer_Date__c</field>
        <formula>LastModifiedDate</formula>
        <name>Capture Ownership Transfer Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Lead %3A Update the Lead Close Date</fullName>
        <actions>
            <name>Capture_Lead_Closed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.IsConverted</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Lead %3A Update the Ownership Transfer Date</fullName>
        <actions>
            <name>Capture_Ownership_Transfer_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(OwnerId)   &amp;&amp; ISNULL(Ownership_Transfer_Date__c)  &amp;&amp;  (ISPICKVAL( LeadSource , &apos;Affiliate&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
