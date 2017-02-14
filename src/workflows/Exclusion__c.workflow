<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Change_status_to_Expired</fullName>
        <field>Status__c</field>
        <literalValue>Expired</literalValue>
        <name>Change status to Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Expiration_date_is_set_to_Today</fullName>
        <field>Expiration_Date__c</field>
        <formula>TODAY()</formula>
        <name>Expiration date is set to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Exclusion %3A After Expiration Date actions</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Exclusion__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Change_status_to_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Exclusion__c.Expiration_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Exclusion%3A Change expiration date to today</fullName>
        <actions>
            <name>Expiration_date_is_set_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Exclusion__c.Status__c</field>
            <operation>equals</operation>
            <value>Expired</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
