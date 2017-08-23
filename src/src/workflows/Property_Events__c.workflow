<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_when_Property_Event_is_created</fullName>
        <description>Notify when Property Event is created</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Retail_Sales_Emails/Property_Event</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Property_Region_field</fullName>
        <field>Property_Region__c</field>
        <formula>TEXT(Property__r.Property_Region__c)</formula>
        <name>Update Property Region field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Email when Property Event is created</fullName>
        <actions>
            <name>Notify_when_Property_Event_is_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Property_Events__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Property Region field</fullName>
        <actions>
            <name>Update_Property_Region_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TEXT(Property__r.Property_Region__c)!= null</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
