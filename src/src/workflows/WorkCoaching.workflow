<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Coaching_Name</fullName>
        <description>Name of the Coaching, when coaching relationship is created</description>
        <field>Name</field>
        <formula>&quot;1-1_&quot; + &quot;(&quot; + Coach.FirstName + &quot;:&quot; + Coached.FirstName + &quot; &quot; + Coached.LastName + &quot;)&quot;</formula>
        <name>Coaching Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Coaching Name Value</fullName>
        <actions>
            <name>Coaching_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkCoaching.CoachId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Name of the coaching</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
