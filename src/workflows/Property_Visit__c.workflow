<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>End_Property_Visit</fullName>
        <field>End_Date_Time__c</field>
        <formula>Now()</formula>
        <name>End Property Visit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Last_CAR_Visit_Date</fullName>
        <description>Update Last CAR VIsit Date  when Auto Checkout is done</description>
        <field>Last_CAR_Update_Date__c</field>
        <formula>now()</formula>
        <name>Last CAR Visit Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Property__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>auto_checkout_true</fullName>
        <field>Is_auto_checkout__c</field>
        <literalValue>1</literalValue>
        <name>auto checkout true</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Property Visit Close</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Property_Visit__c.End_Date_Time__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>End_Property_Visit</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Last_CAR_Visit_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>auto_checkout_true</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Property_Visit__c.CreatedDate</offsetFromField>
            <timeLength>8</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
