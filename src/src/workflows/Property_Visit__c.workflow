<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Auto_Checkout</fullName>
        <field>Is_auto_checkout__c</field>
        <literalValue>1</literalValue>
        <name>Auto Checkout</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>End_Date</fullName>
        <field>End_Date_Time__c</field>
        <formula>Now()</formula>
        <name>End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>End_Property_Visit</fullName>
        <field>End_Date_Time__c</field>
        <formula>Now()</formula>
        <name>End Property Visit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>End_Property_Visit_Date</fullName>
        <field>End_Date_Time__c</field>
        <formula>Now()</formula>
        <name>End Property Visit Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Is_Auto_Checkout_True</fullName>
        <field>Is_auto_checkout__c</field>
        <literalValue>1</literalValue>
        <name>Is Auto Checkout True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LastCARVisit_Date</fullName>
        <field>Last_CAR_Update_Date__c</field>
        <formula>now()</formula>
        <name>LastCARVisit Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Property__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Last_CAR_Visit_Date</fullName>
        <description>Update Last CAR VIsit Date  when Auto Checkout is done</description>
        <field>Last_CAR_Update_Date__c</field>
        <formula>now()</formula>
        <name>Last CAR Visit Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Property__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Property_Last_CAR_Visit_Date</fullName>
        <description>Update Last CAR VIsit Date  when Auto Checkout is done</description>
        <field>Last_CAR_Update_Date__c</field>
        <formula>now()</formula>
        <name>Property Last CAR Visit Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Property__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Completed</fullName>
        <description>Update Status as Completed after 8 hours of check in time.</description>
        <field>Status__c</field>
        <literalValue>Completed</literalValue>
        <name>Status Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdatePropertyVisitName</fullName>
        <field>Name</field>
        <formula>Property__r.Name+&apos; - &apos;+TEXT(Visit_Plan__c)+&apos; - &apos;+ TEXT(TODAY())</formula>
        <name>UpdatePropertyVisitName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>auto_checkout_true</fullName>
        <field>Is_auto_checkout__c</field>
        <literalValue>1</literalValue>
        <name>auto checkout true</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>DisplayPropertyVisitName</fullName>
        <actions>
            <name>UpdatePropertyVisitName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Visit_Plan__c )  ||  ISCHANGED(Property__c)|| ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Property Visit Close</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Property_Visit__c.End_Date_Time__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Property_Visit__c.Status__c</field>
            <operation>equals</operation>
            <value>In Progress</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>End_Property_Visit_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Is_Auto_Checkout_True</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Property_Last_CAR_Visit_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Property_Visit__c.Check_In_Time__c</offsetFromField>
            <timeLength>8</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Property Visit Close old</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Property_Visit__c.End_Date_Time__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>End_Property_Visit</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Last_CAR_Visit_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>auto_checkout_true</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Property_Visit__c.CreatedDate</offsetFromField>
            <timeLength>8</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
