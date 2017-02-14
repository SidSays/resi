<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>StatusPicklistUpdate</fullName>
        <field>Status__c</field>
        <literalValue>Complete</literalValue>
        <name>StatusPicklistUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>UpdateStatusForCompletionDate</fullName>
        <actions>
            <name>StatusPicklistUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$Setup.WorkflowSetting__c.Disable_Workflow_Rule__c  != true &amp;&amp; (NOT(ISNULL(Phase_Completed_Date__c  )))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
