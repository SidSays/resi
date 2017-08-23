<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>OpportunityPropertyIdUpdate</fullName>
        <description>Update OpptyProprtyId field</description>
        <field>OpptyPropertyID__c</field>
        <formula>CASESAFEID(Opportunity__c)+CASESAFEID(Property__c)</formula>
        <name>OpportunityPropertyIdUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Oppty_Property_Unit_Update</fullName>
        <field>Number_of_Units__c</field>
        <formula>Property__r.Number_of_Units__c</formula>
        <name>Oppty Property Unit Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MDU_OpportunityPropertyIdUpdate</fullName>
        <actions>
            <name>OpportunityPropertyIdUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the OpptyPropertyId field using concatenation of opportunity Id and Property Id</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Oppty Property Unit Update</fullName>
        <actions>
            <name>Oppty_Property_Unit_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$Setup.WorkflowSetting__c.Disable_Workflow_Rule__c  != true &amp;&amp; (Number_of_Units__c  &lt;&gt;   Property__r.Number_of_Units__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
