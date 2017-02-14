<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Action_Item_1_Day_from_Due_Date</fullName>
        <description>Action Item 1 Day from Due Date</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Action_Items/Action_Item_Due</template>
    </alerts>
    <alerts>
        <fullName>Action_Item_3_Days_Overdue</fullName>
        <description>Action Item 3 Days Overdue</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Action_Items/Action_Item_Overdue</template>
    </alerts>
    <alerts>
        <fullName>Action_Item_5_Days_from_Due_Date</fullName>
        <description>Action Item 5 Days from Due Date</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Action_Items/Action_Item_Due</template>
    </alerts>
    <alerts>
        <fullName>Action_Item_7_Days_Overdue</fullName>
        <description>Action Item 7 Days Overdue</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Action_Items/Action_Item_Overdue</template>
    </alerts>
    <alerts>
        <fullName>Action_Item_Assigned</fullName>
        <description>Action Item Assigned</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Action_Items/Action_Item_Assigned</template>
    </alerts>
    <alerts>
        <fullName>Action_Item_Complete</fullName>
        <description>Action Item Complete</description>
        <protected>false</protected>
        <recipients>
            <field>Project_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Action_Items/Action_Item_Complete</template>
    </alerts>
    <alerts>
        <fullName>Action_Item_Notice</fullName>
        <description>Action Item Notice</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Project_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/Action_Item_Notice</template>
    </alerts>
    <rules>
        <fullName>Action Item Assigned</fullName>
        <actions>
            <name>Action_Item_Assigned</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Action Item record is created or Assigned To is changed</description>
        <formula>AND( 
OR( 
AND( 
ISNEW(), 
CASESAFEID(Assigned_To__c)&lt;&gt;CASESAFEID(CreatedById) 
), 
AND( 
ISCHANGED(Assigned_To__c), 
CASESAFEID(Assigned_To__c)&lt;&gt;CASESAFEID(LastModifiedById) 
) 
) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Action Item Due - 1 Day Alert</fullName>
        <active>true</active>
        <description>Must have 2 WF Rules to support Due Date Email Notice requirement. Time-based WF rules will trigger events that are scheduled to happen in advance. Thus 1 WF to handle 5 day alert, 1 WF to handle 1 day alert.</description>
        <formula>AND( 
NOT(CONTAINS(TEXT(Status__c),&quot;Complete&quot;)), 
NOT(ISBLANK(Due_Date__c)), Due_Date__c - TODAY() &gt; 1 
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Action_Item_1_Day_from_Due_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Action_Item__c.Due_Date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Action Item Due - 5 Day Alert</fullName>
        <active>true</active>
        <description>Must have 2 WF Rules to support Due Date Email Notice requirement. Time-based WF rules will trigger events that are scheduled to happen in advance. Thus 1 WF to handle 5 day alert, 1 WF to handle 1 day alert.</description>
        <formula>AND( 
NOT(CONTAINS(TEXT(Status__c),&quot;Complete&quot;)), 
NOT(ISBLANK(Due_Date__c)), Due_Date__c - TODAY() &gt; 5 
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Action_Item_5_Days_from_Due_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Action_Item__c.Due_Date__c</offsetFromField>
            <timeLength>-5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Action Item Notice</fullName>
        <active>false</active>
        <formula>DATEVALUE( LastModifiedDate )  =  TODAY()</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Action_Item_Notice</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Action_Item__c.LastModifiedDate</offsetFromField>
            <timeLength>5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Action Item Overdue</fullName>
        <active>true</active>
        <description>Send email alert 3 and 7 days after an Action Item&apos;s Due Date if the Action Item Status is not Completed.</description>
        <formula>AND( 
NOT(CONTAINS(TEXT(Status__c),&quot;Complete&quot;)), 
NOT(ISBLANK(Due_Date__c)) 
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Action_Item_3_Days_Overdue</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Action_Item__c.Due_Date__c</offsetFromField>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Action_Item_7_Days_Overdue</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Action_Item__c.Due_Date__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Project Owner Alert - Action Item Completed</fullName>
        <actions>
            <name>Action_Item_Complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>CONTAINS(TEXT(Status__c),&quot;Complete&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
