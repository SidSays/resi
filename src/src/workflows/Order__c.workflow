<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Check_Worklisted</fullName>
        <field>Worklisted__c</field>
        <literalValue>1</literalValue>
        <name>Check Worklisted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Region_Update</fullName>
        <field>Region__c</field>
        <formula>TEXT(ActivatedBy__r.Region__c)</formula>
        <name>Region Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Worklisted</fullName>
        <description>Uncheck worklisted if Order Status is anything other than Pending and Work Order ID is not NULL</description>
        <field>Worklisted__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Worklisted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Scheduled_Installation_Date</fullName>
        <field>ScheduledInstallationDate__c</field>
        <name>Update Scheduled Installation Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Order %3A Check Worklisted Checkbox</fullName>
        <actions>
            <name>Check_Worklisted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.OrderStatus__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.WorkOrderID__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Check Worklisted checkbox if Order Status is pending and Work Order ID is null.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Order %3A UnCheck Worklisted Checkbox</fullName>
        <actions>
            <name>Uncheck_Worklisted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2</booleanFilter>
        <criteriaItems>
            <field>Order__c.OrderStatus__c</field>
            <operation>notEqual</operation>
            <value>Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.WorkOrderID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Uncheck the Worklisted checkbox if Order Status is not Pending and Work Order ID is not null</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Order%3A Set Scheduled Installation Date To NULL</fullName>
        <actions>
            <name>Update_Scheduled_Installation_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.OrderStatus__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Order%3A Update Order Region</fullName>
        <actions>
            <name>Region_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.ActivatedBy__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
