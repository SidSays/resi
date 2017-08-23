<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Owner_Blacklisted_Audit_Email_Alert</fullName>
        <description>Notify_Owner_Blacklisted_Audit_Email_Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>daniel_clancy@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>elizabeth_haworth@comcast.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Email_Templates/Notify_Owner_Elizabeth_Haworth</template>
    </alerts>
    <rules>
        <fullName>Notify Owner Elizabeth Haworth Blacklist Audit</fullName>
        <actions>
            <name>Notify_Owner_Blacklisted_Audit_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Blacklist_Audit__c.Notify__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
