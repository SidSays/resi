<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateFlagForOpportunityDelete</fullName>
        <field>FlagForOpportunity__c</field>
        <literalValue>1</literalValue>
        <name>UpdateFlagForOpportunityDelete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>OpportunityDeleteFromApplicationLog</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Application_Log__c.isSuccess__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application_Log__c.OpportunityID__c</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>US1107249 - Time based workflow for updating the flag in application log</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>UpdateFlagForOpportunityDelete</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Application_Log__c.CreatedDate</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
