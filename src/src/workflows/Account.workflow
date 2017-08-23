<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_on_Update</fullName>
        <ccEmails>onkar.m.mitragotri@accenture.com</ccEmails>
        <description>Email Alert on Update</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Email_notification_for_parent_account_on_update</template>
    </alerts>
    <alerts>
        <fullName>Email_alert</fullName>
        <ccEmails>onkar.m.mitragotri@accenture.com</ccEmails>
        <description>Email alert</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Email_notification_for_parent_account</template>
    </alerts>
    <alerts>
        <fullName>Overdue_Visit_Alert</fullName>
        <description>Overdue Visit Alert</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Retail_Sales_Emails/Store_Overdue_for_Visit</template>
    </alerts>
    <fieldUpdates>
        <fullName>Account_Update_Disconnect_Flag_to_False</fullName>
        <field>Disconnected__c</field>
        <literalValue>0</literalValue>
        <name>Account: Update Disconnect Flag to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Update_Disconnect_Flag_to_True</fullName>
        <field>Disconnected__c</field>
        <literalValue>1</literalValue>
        <name>Account: Update Disconnect Flag to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prior_Value</fullName>
        <field>Prior_Value__c</field>
        <formula>PRIORVALUE( Name )</formula>
        <name>Prior Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account%3A Update Disconnect Flag to False When Status Equals Active</fullName>
        <actions>
            <name>Account_Update_Disconnect_Flag_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Customer_Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <description>Update Disconnect Flag to False When Account Custome Status Equals Active</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Account%3A Update Disconnect Flag to True When Status Equals Former</fullName>
        <actions>
            <name>Account_Update_Disconnect_Flag_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Customer_Status__c</field>
            <operation>equals</operation>
            <value>Former,D</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email on overdue visit</fullName>
        <actions>
            <name>Overdue_Visit_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Overdue_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow rule will send an email to the owner of a store when the store becomes more than 5 days overdue for a visit</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Parent Organization Email Alert</fullName>
        <actions>
            <name>Email_alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>( $Label.XfinityAccountRecordTypeId= RecordTypeId ) &amp;&amp;($Setup.WorkflowSetting__c.Disable_Workflow_Rule__c != true) &amp;&amp; (ISNEW() &amp;&amp; Is_Parent_Organization__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Parent Organization Email Alert on Update</fullName>
        <actions>
            <name>Email_Alert_on_Update</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>( $Label.XfinityAccountRecordTypeId= RecordTypeId ) &amp;&amp;($Setup.WorkflowSetting__c.Disable_Workflow_Rule__c != true) &amp;&amp; (ISCHANGED( Name) &amp;&amp; Is_Parent_Organization__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Prior Value Calculation</fullName>
        <actions>
            <name>Prior_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>( $Label.XfinityAccountRecordTypeId= RecordTypeId ) &amp;&amp;($Setup.WorkflowSetting__c.Disable_Workflow_Rule__c != true) &amp;&amp; (ISCHANGED( Name) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
