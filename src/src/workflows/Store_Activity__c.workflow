<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Display_Not_Functioning</fullName>
        <description>Display Not Functioning</description>
        <protected>false</protected>
        <recipients>
            <field>Display_Vendor_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Retail_Sales_Emails/Display_Not_Functioning</template>
    </alerts>
    <alerts>
        <fullName>Display_not_Setup_correctly</fullName>
        <description>Display not Setup correctly</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Retail_Sales_Emails/Display_not_Setup_correctly</template>
    </alerts>
    <alerts>
        <fullName>Email_Self_Issue_Resolution_Notes</fullName>
        <description>Email Self Issue Resolution Notes</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Retail_Sales_Emails/Store_Issue_Resolution</template>
    </alerts>
    <alerts>
        <fullName>Marketing_Materials_Need_Reorder</fullName>
        <description>Marketing Materials Need Reorder</description>
        <protected>false</protected>
        <recipients>
            <field>Innerworkings_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Retail_Sales_Emails/Marketing_Materials_Need_Reorder</template>
    </alerts>
    <alerts>
        <fullName>Marketing_Materials_Not_Current</fullName>
        <description>Marketing Materials Not Current</description>
        <protected>false</protected>
        <recipients>
            <field>Managers_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Retail_Sales_Emails/Marketing_Materials_Not_Current</template>
    </alerts>
    <alerts>
        <fullName>Rep_Lacks_Knowledge_of_Training_Topics</fullName>
        <description>Rep Lacks Knowledge of Training Topics</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Retail_Sales_Emails/Rep_Lacks_Knowledge_of_Topics_Covered</template>
    </alerts>
    <alerts>
        <fullName>Rep_Lacks_Tablet_to_Sell_Service</fullName>
        <description>Rep Lacks Tablet to Sell Service</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Retail_Sales_Emails/Rep_Lacks_Tablet_to_Sell_Service</template>
    </alerts>
    <alerts>
        <fullName>Rep_Not_Present</fullName>
        <description>Rep Not Present</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Retail_Sales_Emails/Rep_Not_Present</template>
    </alerts>
    <alerts>
        <fullName>Rep_Not_Wearing_Appropriate_Attire</fullName>
        <description>Rep Not Wearing Appropriate Attire</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Retail_Sales_Emails/Rep_Not_Wearing_Appropriate_Attire</template>
    </alerts>
    <alerts>
        <fullName>Rep_found_better_table_location</fullName>
        <description>Rep found better table location</description>
        <protected>false</protected>
        <recipients>
            <field>Managers_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Retail_Sales_Emails/Better_Table_Location</template>
    </alerts>
    <alerts>
        <fullName>Rep_tablet_lacks_3G_coverage</fullName>
        <description>Rep tablet lacks 3G coverage</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Retail_Sales_Emails/Rep_Tablet_Lacks_3G_Coverage</template>
    </alerts>
    <alerts>
        <fullName>Tablet_not_loaded_with_XF_Video</fullName>
        <description>Tablet not loaded with XF Video</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Retail_Sales_Emails/Tablet_not_loaded_with_XF_video</template>
    </alerts>
    <alerts>
        <fullName>Tablet_not_loaded_with_attractor_loop</fullName>
        <description>Tablet not loaded with attractor loop</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Retail_Sales_Emails/Tablet_not_loaded_with_Attractor_Loop</template>
    </alerts>
    <fieldUpdates>
        <fullName>Check_Notes_Complete</fullName>
        <description>This will check the &quot;Notes Complete?&quot; checkkbox</description>
        <field>Notes_Complete__c</field>
        <literalValue>1</literalValue>
        <name>Check Notes Complete?</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Innerworkings_Email</fullName>
        <description>This will update the Innerworkings Email Address field with the value from the Innerworkings Email field so it can be used in a workflow email</description>
        <field>Innerworkings_Email_Address__c</field>
        <formula>Innerworkings_Email__c</formula>
        <name>Populate Innerworkings Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Managers_Email</fullName>
        <description>This will update the Managers Email field with the value from the Manager Email field so it can be used in a workflow email</description>
        <field>Managers_Email__c</field>
        <formula>Manager_Email__c</formula>
        <name>Populate Managers Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Display_Vendor_Email</fullName>
        <description>This workflow rule will populate the Display Vendor email address on store activity</description>
        <field>Display_Vendor_Email_Address__c</field>
        <formula>Display_Vendor_Email__c</formula>
        <name>Update Display Vendor Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Is_Activity_Completed</fullName>
        <description>Update Is Activity Completed</description>
        <field>Is_Activity_Completed__c</field>
        <literalValue>1</literalValue>
        <name>Update Is Activity Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Is_Activity_Completed_New</fullName>
        <description>This field updated is for calculating new survey questions</description>
        <field>Is_Activity_Completed_New__c</field>
        <literalValue>1</literalValue>
        <name>Update Is Activity Completed New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_What_was_review_with_Mgr_compltd</fullName>
        <description>Updates the &quot;What was reviewed with Mgr. completed&quot; field</description>
        <field>What_was_reviewed_with_Mgr_completed_New__c</field>
        <literalValue>1</literalValue>
        <name>Update What was review with Mgr. compltd</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Check for Notes Complete</fullName>
        <actions>
            <name>Check_Notes_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Store_Activity__c.Notes__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This Workflow Rule will check the Notes Complete? checkbox if the Notes field has been populated</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Check the what did you review with Mgr field</fullName>
        <actions>
            <name>Update_What_was_review_with_Mgr_compltd</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Store_Activity__c.What_was_reviewed_with_Mgr_on_duty__c</field>
            <operation>notEqual</operation>
            <value>Null</value>
        </criteriaItems>
        <description>This workflow rule checks the checkbox field &quot;	
What was reviewed with Mgr. completed&quot; if &quot;What was reviewed with Mgr. on duty?&quot; is filled.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Create Task for Rep Not Engaging Customers</fullName>
        <actions>
            <name>X3PL_Rep_Not_Sufficient_Engaged_at_Last_Visit</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Store_Activity__c.Rep_not_actively_engaging_customers__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This rule will create a task for follow up when a rep checks the &quot;Rep not actively engaging customers?&quot; checkbox on a 3PL Training activity</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email because display not functioning correctly</fullName>
        <actions>
            <name>Display_Not_Functioning</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Store_Activity__c.Display_not_functioning__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow will send an email to the Display Vendor if the rep checks the &quot;Display not functioning?&quot; checkbox on a marketing activity.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email because marketing materials need re-order</fullName>
        <actions>
            <name>Marketing_Materials_Need_Reorder</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Store_Activity__c.Materials_need_re_order__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Store_Activity__c.Please_select_materials_needing_reorder__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow will send an email to Innerworkings if the rep checks the &quot;Materials need re-order?&quot; checkbox on a marketing activity.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Innerworkings Email</fullName>
        <actions>
            <name>Populate_Innerworkings_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Store_Activity__c.Innerworkings_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow rule will populate the Innerworkings email address on store activity</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Is Activity Completed New</fullName>
        <actions>
            <name>Update_Is_Activity_Completed_New</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate Is Activity Completed for new survey questions.</description>
        <formula>IF (ISBLANK(TEXT(Is_signage_visible_and_intact_in_store__c)),  IF (ISBLANK(TEXT(Is_event_planogram_set_up_correctly__c)),   IF (ISBLANK(Any_feedback_concerns_from_the_Mgr__c),   IF (ISBLANK(What_was_reviewed_with_Mgr_on_duty__c),   IF (ISBLANK(What_KPIs_did_you_review_with_the_Mgr__c),   IF (ISBLANK(TEXT(Did_you_engage_in_selling_with_reps__c)),    IF (ISBLANK(TEXT(Was_sale_of_Xfinity_services_attempted__c)),  IF (ISBLANK(Which_modules_trainings_were_reviewed__c),  IF (ISBLANK(What_did_you_discuss_with_the_reps__c),   IF (ISBLANK(Notes__c),  IF (ISBLANK(TEXT(Did_you_observe_Sales_rep__c)),  IF (NOT(OR(TV__c,Internet__c,Voice__c,XH_Secure__c,XH_Control__c)),  false, true), true), true), true), true), true),true), true), true), true), true), true)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Managers Email</fullName>
        <actions>
            <name>Populate_Managers_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Store_Activity__c.Manager_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow rule will populate the manager&apos;s email address on store activity</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Display Vendor Email</fullName>
        <actions>
            <name>Update_Display_Vendor_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Store_Activity__c.Display_Vendor_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow rule will populate the Display Vendor email address on store activity</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Issue_Resolution</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>14</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Issue Resolution</subject>
    </tasks>
    <tasks>
        <fullName>X3PL_Rep_Not_Sufficient_Engaged_at_Last_Visit</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>14</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Store_Activity__c.CreatedDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>3PL Rep Not Sufficiently Engaged at Last Visit</subject>
    </tasks>
</Workflow>
