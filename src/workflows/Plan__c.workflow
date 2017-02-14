<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Turf_Assigned_to_User</fullName>
        <description>Turf Assigned to User</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/Plan_Assignment_Template</template>
    </alerts>
    <alerts>
        <fullName>Turf_Assignment_Notification_To_Team_s_Supervisor</fullName>
        <description>Turf Assignment Notification To Team&apos;s Supervisor</description>
        <protected>false</protected>
        <recipients>
            <field>Supervisor_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/Plan_Assignment_Template_To_Team_s_Supervisor</template>
    </alerts>
    <alerts>
        <fullName>Turf_Expiration_Notification</fullName>
        <description>Turf Expiration Notification</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/Plan_Expiration_Notification_Template</template>
    </alerts>
    <alerts>
        <fullName>Turf_Expiration_Notification_To_Supervisor</fullName>
        <description>Turf Expiration Notification To Supervisor</description>
        <protected>false</protected>
        <recipients>
            <field>Supervisor_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/Plan_Expiration_Notification_Template_Supervisor</template>
    </alerts>
    <fieldUpdates>
        <fullName>Plan_Role</fullName>
        <description>Update Role Field</description>
        <field>Role__c</field>
        <formula>IF( User__c &lt;&gt; null, User__r.UserRole.Name ,  Assigned_Team__r.Role__c  )</formula>
        <name>Plan:Role</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Plan_True_Address_count_update</fullName>
        <description>Update count of address on Plan.</description>
        <field>True_count_of_Addresses__c</field>
        <formula>Number_of_Addresses__c - Number_of_Excluded_Addresses__c</formula>
        <name>Plan: True Address count update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Plan %3A Expiration Notification Rule</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Plan__c.Expiration_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Plan__c.Plan_Level__c</field>
            <operation>equals</operation>
            <value>Turf</value>
        </criteriaItems>
        <criteriaItems>
            <field>Plan__c.Plan_Status__c</field>
            <operation>equals</operation>
            <value>Assigned</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Turf_Expiration_Notification</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Turf_Expiration_Notification_To_Supervisor</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Plan__c.Expiration_Date__c</offsetFromField>
            <timeLength>-5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Plan%3A Email notification to turf assignee</fullName>
        <actions>
            <name>Turf_Assigned_to_User</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Turf_Assignment_Notification_To_Team_s_Supervisor</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND (    ISPICKVAL(Plan_Level__c, &apos;Turf&apos;),    OR    (      NOT(ISBLANK(User__c)),      NOT(ISBLANK(Assigned_Team__c))    )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Plan%3A Update true Address count</fullName>
        <actions>
            <name>Plan_True_Address_count_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR (  ISCHANGED(Number_of_Addresses__c) ,  ISCHANGED(Number_of_Excluded_Addresses__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Plan%3ARole</fullName>
        <actions>
            <name>Plan_Role</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Role for Contractor Sharing</description>
        <formula>User__c &lt;&gt; null || Assigned_Team__c &lt;&gt; null</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
