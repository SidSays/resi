<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Job_Status_Email_Alert</fullName>
        <description>Job Status Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>animesh.datta@accenture.com.chatter</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/Job_Status_Template</template>
    </alerts>
    <alerts>
        <fullName>Territory_Exclusions_Finished</fullName>
        <description>Territory Exclusions Finished</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Territory_Exclusion_Finished</template>
    </alerts>
    <rules>
        <fullName>Job_Status_Workflow</fullName>
        <actions>
            <name>Job_Status_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Job_Status__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed With Errors,Completed Without Errors</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Territory Exclusions Inclusions</fullName>
        <actions>
            <name>Territory_Exclusions_Finished</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Job_Status__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed Without Errors,Completed With Errors</value>
        </criteriaItems>
        <description>Sends confirmation email to user when territory exclusion or inclusion batch process has finished processing.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
