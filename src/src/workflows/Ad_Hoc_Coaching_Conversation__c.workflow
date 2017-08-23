<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Ad_Hoc_Coaching_Name_field_Template</fullName>
        <description>Updates the Ad Hoc Coaching Conversation name field according to the template : AdHoc_Date_PersonCoached</description>
        <field>Name</field>
        <formula>&quot;AdHoc_&quot; &amp; Text(DATEVALUE(CreatedDate))+ &quot;_&quot; + coaching__r.Coached.FirstName + &quot; &quot; + coaching__r.Coached.LastName</formula>
        <name>Ad Hoc Coaching Name field Template</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Ad Hoc Coaching Name field Update</fullName>
        <actions>
            <name>Ad_Hoc_Coaching_Name_field_Template</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the name field of the Ad Hoc Coaching Conversation record according to the given template: AdHoc_Date_PersonCoached</description>
        <formula>Isnew() || ISCHANGED( Name ) || ISCHANGED( CreatedDate )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
