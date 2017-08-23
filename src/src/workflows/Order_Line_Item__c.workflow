<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>RGU_Field_Update_for_CDV</fullName>
        <field>RGU__c</field>
        <literalValue>CDV</literalValue>
        <name>RGU: Field Update for CDV</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RGU_Field_Update_for_HSD</fullName>
        <field>RGU__c</field>
        <literalValue>HSD</literalValue>
        <name>RGU: Field Update for HSD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RGU_Field_Update_for_Other</fullName>
        <field>RGU__c</field>
        <literalValue>Other</literalValue>
        <name>RGU: Field Update for Other</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RGU_Field_Update_for_Video</fullName>
        <field>RGU__c</field>
        <literalValue>Video</literalValue>
        <name>RGU: Field Update for Video</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RGU_Field_Update_for_XH</fullName>
        <field>RGU__c</field>
        <literalValue>XH</literalValue>
        <name>RGU: Field Update for XH</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>OrderLineItem%3A RGU field Update for CDV</fullName>
        <actions>
            <name>RGU_Field_Update_for_CDV</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order_Line_Item__c.Name</field>
            <operation>contains</operation>
            <value>Voice</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OrderLineItem%3A RGU field Update for HSD</fullName>
        <actions>
            <name>RGU_Field_Update_for_HSD</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order_Line_Item__c.Name</field>
            <operation>contains</operation>
            <value>Internet</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OrderLineItem%3A RGU field Update for Other</fullName>
        <actions>
            <name>RGU_Field_Update_for_Other</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order_Line_Item__c.Name</field>
            <operation>contains</operation>
            <value>HD</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OrderLineItem%3A RGU field Update for Video</fullName>
        <actions>
            <name>RGU_Field_Update_for_Video</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Order_Line_Item__c.Name</field>
            <operation>contains</operation>
            <value>Digital</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order_Line_Item__c.Name</field>
            <operation>contains</operation>
            <value>Analog</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OrderLineItem%3A RGU field Update for XH</fullName>
        <actions>
            <name>RGU_Field_Update_for_XH</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order_Line_Item__c.Name</field>
            <operation>contains</operation>
            <value>Home</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
