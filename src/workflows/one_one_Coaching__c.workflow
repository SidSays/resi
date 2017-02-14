<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Record_type_update</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Status_Submitted_SDM_CAR_coachee</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Record type update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Record_type_update_for_Draft</fullName>
        <description>When the status of the coaching record is changed from submitted to draft, this new record type will be assigned.</description>
        <field>RecordTypeId</field>
        <lookupValue>Status_Draft_SDM_CAR_coachee</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Record type update for Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Record_type_update_for_SDM</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Status_Submitted_SDM_Coach</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Record type update for SDM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Record_type_update_for_SDM_draft</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Status_Draft_SDM_Coach</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Record type update for SDM draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>1-1 status is Draft for XSP when SDM as Coach</fullName>
        <actions>
            <name>Record_type_update_for_SDM_draft</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule will be fired in case of status= draft. The edit button will be visible on the layout and status field will not be read only for the SDM when SDM is Person Coached.</description>
        <formula>AND(ISPICKVAL(Status__c  , &apos;Draft&apos;),coaching__r.Coach.Profile.Name = $Label.DS_Supervisor)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>1-1 status is Draft when coach is ASM_CAR Mgr</fullName>
        <actions>
            <name>Record_type_update_for_Draft</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule will be fired in case of status= draft. The edit button will be visible on the layout and status field will not be read only for the Person Coached.</description>
        <formula>AND(ISPICKVAL(Status__c , &apos;Draft&apos;), OR(coaching__r.Coach.Profile.Name =  $Label.Xfinity_CARmanager_ProfileName, coaching__r.Coach.Profile.Name =  $Label.DS_Manager, coaching__r.Coach.Profile.Name =  $Label.RetailSalesManagerProfileName ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>1-1 status is submitted coach is ASM_CAR Mgr</fullName>
        <actions>
            <name>Record_type_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule will be fired in case of status= submitted.The edit button will not be visible on the layout for the reps</description>
        <formula>AND(ISPICKVAL(Status__c , &apos;Submitted&apos;), OR(coaching__r.Coach.Profile.Name = $Label.Xfinity_CARmanager_ProfileName , coaching__r.Coach.Profile.Name = $Label.DS_Manager, coaching__r.Coach.Profile.Name = $Label.RetailSalesManagerProfileName))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>1-1 status is submitted for rep when SDM is coach</fullName>
        <actions>
            <name>Record_type_update_for_SDM</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule will be fired in case of status= submitted.The edit button will not be visible on the layout for the SDM</description>
        <formula>AND(ISPICKVAL(Status__c  , &apos;submitted&apos;),coaching__r.Coach.Profile.Name = $Label.DS_Supervisor)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
