<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_when_a_member_is_added_to_a_property_event</fullName>
        <description>Notify when a member is added to a property event</description>
        <protected>false</protected>
        <recipients>
            <field>User_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Retail_Sales_Emails/Property_Event_Team_Member</template>
    </alerts>
    <fieldUpdates>
        <fullName>Email_Field_Update</fullName>
        <field>User_Email__c</field>
        <formula>IF( ISBLANK( Team_Member__c ) , Email__c , Team_Member__r.Email )</formula>
        <name>Email Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Email when a member is added to a property event%2E</fullName>
        <actions>
            <name>Email_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(AND(( ISCHANGED( Name ) || ISCHANGED( Property_Event__c ) ||  ISCHANGED(  Email__c ) ), NOT( ISBLANK(Name) ) , NOT( ISBLANK(Property_Event__c) )  ), AND( NOT( ISBLANK(Name) ) , NOT( ISBLANK(Property_Event__c) ), ISNEW() ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
