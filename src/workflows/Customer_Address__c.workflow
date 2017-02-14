<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Change_Disconnected_to_true</fullName>
        <field>Disconnected__c</field>
        <literalValue>1</literalValue>
        <name>Change Disconnected to true</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_the_complex_Office_checkbox</fullName>
        <field>Complex_Office__c</field>
        <literalValue>0</literalValue>
        <name>Clear the complex Office checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Customer_Address_Field_Update</fullName>
        <field>Name</field>
        <formula>Address__c</formula>
        <name>Customer Address Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Targeted_Flag_to_False</fullName>
        <field>Targeted__c</field>
        <literalValue>0</literalValue>
        <name>Update Targeted Flag to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Address%3A Clear the Complex Office checkbox</fullName>
        <actions>
            <name>Clear_the_complex_Office_checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Customer_Address__c.Property_Code__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Customer_Address__c.Complex_Office__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Address%3ADisconnected Checked if Address is former</fullName>
        <actions>
            <name>Change_Disconnected_to_true</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Customer_Address__c.Status__c</field>
            <operation>equals</operation>
            <value>Former</value>
        </criteriaItems>
        <criteriaItems>
            <field>Customer_Address__c.Disconnected__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Customer Address Name Update</fullName>
        <actions>
            <name>Customer_Address_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>OR (  ISNEW(),   ISCHANGED( Address__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Target Flag</fullName>
        <actions>
            <name>Update_Targeted_Flag_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISBLANK(Account__c)),ISPICKVAL(Account__r.Customer_Status__c, &apos;Active&apos;),Targeted__c==true)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
