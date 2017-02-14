<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Task_Completion_email_alert</fullName>
        <description>Task Completion email alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Action_Items/Task_Completion_Alert</template>
    </alerts>
    <rules>
        <fullName>Task Completion email alert</fullName>
        <actions>
            <name>Task_Completion_email_alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL( Status , &apos;Completed&apos;) &amp;&amp;  Owner:User.User_Name__c != CreatedBy.User_Name__c  &amp;&amp;  RecordType.DeveloperName =&apos;Task&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
