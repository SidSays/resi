<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Actual_v_s_Target_update</fullName>
        <field>Description</field>
        <formula>TEXT( CurrentValue ) + &apos; of &apos; + TEXT( TargetValue )</formula>
        <name>Actual v/s Target update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BehindFieldTrack</fullName>
        <field>Status__c</field>
        <literalValue>Behind</literalValue>
        <name>BehindFieldTrack</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CriticalFieldUpdate</fullName>
        <field>Status__c</field>
        <literalValue>Critical</literalValue>
        <name>CriticalFieldUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OnTrackFieldUpdate</fullName>
        <field>Status__c</field>
        <literalValue>On Track</literalValue>
        <name>OnTrackFieldUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Actual v%2Fs Target calculation</fullName>
        <actions>
            <name>Actual_v_s_Target_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Actual v/s Target calculation on metric</description>
        <formula>OR(ISCHANGED(CurrentValue),ISCHANGED(TargetValue), ISNEW())</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MetricStatusFieldUpdate</fullName>
        <actions>
            <name>OnTrackFieldUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Metric.Status</field>
            <operation>equals</operation>
            <value>On Track</value>
        </criteriaItems>
        <description>A workflow rule to update the new Status field with the value from the standard &quot;Status&quot; field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MetricStatusUpdateII</fullName>
        <actions>
            <name>BehindFieldTrack</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Metric.Status</field>
            <operation>equals</operation>
            <value>Behind</value>
        </criteriaItems>
        <description>A workflow rule to update the new Status field with the value from the standard &quot;Status&quot; field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MetricStatusUpdateIII</fullName>
        <actions>
            <name>CriticalFieldUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Metric.Status</field>
            <operation>equals</operation>
            <value>Critical</value>
        </criteriaItems>
        <description>A workflow rule to update the new Status field with the value from the standard &quot;Status&quot; field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
