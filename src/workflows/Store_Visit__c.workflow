<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CheckAutoCheckOut</fullName>
        <description>It Updates Is_Auto_Check_Out__c to true in case of auto check out</description>
        <field>Is_Auto_Check_Out__c</field>
        <literalValue>1</literalValue>
        <name>CheckAutoCheckOut</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>End_Store_Visit</fullName>
        <description>It ends the store visit at mid night.</description>
        <field>End_Date_Time__c</field>
        <formula>visit_cutoff_datetime__c</formula>
        <name>End Store Visit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Fully_Compliant_to_No</fullName>
        <field>Fully_Compliant__c</field>
        <literalValue>No</literalValue>
        <name>Update Fully Compliant to No</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Fully_Compliant_to_Yes</fullName>
        <field>Fully_Compliant__c</field>
        <literalValue>Yes</literalValue>
        <name>Update Fully Compliant to Yes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Store Visit Close</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Store_Visit__c.End_Date_Time__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CheckAutoCheckOut</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>End_Store_Visit</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Store_Visit__c.visit_cutoff_datetime__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Fully Compliant field to No</fullName>
        <actions>
            <name>Update_Fully_Compliant_to_No</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Store_Visit__c.Fully_Compliant_Formula__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow will update the Fully Compliant? picklist field to No when the formula field of the same name is set to false</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Fully Compliant field to Yes</fullName>
        <actions>
            <name>Update_Fully_Compliant_to_Yes</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Store_Visit__c.Fully_Compliant_Formula__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This rule will update the Fully Compliant? picklist field to Yes when the formula field with the same name is set to True</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
