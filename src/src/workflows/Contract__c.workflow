<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Contract_Status_Active</fullName>
        <field>Contract_Status__c</field>
        <literalValue>Active</literalValue>
        <name>Contract Status Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contract_Status_Archived</fullName>
        <field>Contract_Status__c</field>
        <literalValue>Archived</literalValue>
        <name>Contract Status Archived</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contract_Status_Expired</fullName>
        <field>Contract_Status__c</field>
        <literalValue>Expired</literalValue>
        <name>Contract Status Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contract_Status_Franchise</fullName>
        <field>Contract_Status__c</field>
        <literalValue>Franchise</literalValue>
        <name>Contract Status Franchise</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Expiration_Date_Update_Custom</fullName>
        <field>Expiration_Date__c</field>
        <formula>Expire_Date__c</formula>
        <name>Expiration Date Update Custom</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Initial_Eff_Date_Update_From_Eff_Date</fullName>
        <field>Initial_Effective_Date__c</field>
        <formula>Effective_Date__c</formula>
        <name>Initial Eff Date Update From Eff Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Initial_Expiration_Date_Update_2</fullName>
        <field>Initial_Expiration_Date__c</field>
        <formula>Expiration_Date__c</formula>
        <name>Initial Expiration Date Update 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Data_Units_To_Null_For_No_Data</fullName>
        <description>Set Data Units To Null For No Data In Data Picklist field</description>
        <field>Data_Units__c</field>
        <name>Set Data Units To Null For No Data</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Video_Units_To_Null_For_Video_No</fullName>
        <field>Video_Units__c</field>
        <name>Set Video Units To Null For Video No</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Voice_Units_To_Null_For_No_Voice</fullName>
        <field>Voice_Units__c</field>
        <name>Set Voice Units To Null For No Voice</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Data_Sub</fullName>
        <description>To Update data units in contract</description>
        <field>Data_Units__c</field>
        <formula>Address_Units__c</formula>
        <name>Update Data Sub</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Video_Subs</fullName>
        <description>To Update video units in contract</description>
        <field>Video_Units__c</field>
        <formula>Address_Units__c</formula>
        <name>Update Video Subs</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Voice_Subs</fullName>
        <description>To Update voice units in contract</description>
        <field>Voice_Units__c</field>
        <formula>Address_Units__c</formula>
        <name>Update Voice Subs</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Contract Expiration Date Update Custom</fullName>
        <actions>
            <name>Expiration_Date_Update_Custom</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Initial_Expiration_Date_Update_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$Setup.WorkflowSetting__c.Disable_Workflow_Rule__c != true &amp;&amp; (ISBLANK(TEXT(Sub_Status__c)) || ISPICKVAL(Sub_Status__c, &apos;New&apos;) || ISPICKVAL(Sub_Status__c, &apos;Renewed&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contract Field Update Archive Custom</fullName>
        <actions>
            <name>Contract_Status_Archived</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$Setup.WorkflowSetting__c.Disable_Workflow_Rule__c != true &amp;&amp; (Archived__c  = True)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contract Field Update LOF Custom</fullName>
        <actions>
            <name>Contract_Status_Franchise</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$Setup.WorkflowSetting__c.Disable_Workflow_Rule__c  != true &amp;&amp; (Life_of_Franchise__c = True &amp;&amp;  Archived__c = false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contract Initial Effective Date Update Custom</fullName>
        <actions>
            <name>Initial_Eff_Date_Update_From_Eff_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$Setup.WorkflowSetting__c.Disable_Workflow_Rule__c != true &amp;&amp; (ISBLANK(TEXT(Sub_Status__c)) || ISPICKVAL(Sub_Status__c, &apos;New&apos;) || ISPICKVAL(Sub_Status__c, &apos;Renewed&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contract Status Update Active Custom</fullName>
        <actions>
            <name>Contract_Status_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$Setup.WorkflowSetting__c.Disable_Workflow_Rule__c  != true &amp;&amp; (Archived__c == false &amp;&amp;  Life_of_Franchise__c == false &amp;&amp;  (Expire_Date__c &gt;=  TODAY() ||  ISNULL(Expire_Date__c) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contract Status Update Expired Custom</fullName>
        <actions>
            <name>Contract_Status_Expired</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$Setup.WorkflowSetting__c.Disable_Workflow_Rule__c  != true &amp;&amp; (Archived__c == false &amp;&amp; Life_of_Franchise__c == false &amp;&amp; (ISPICKVAL(Sub_Status__c, &apos;New&apos;) || ISPICKVAL(Sub_Status__c, &apos;Renewed&apos;) || ISBLANK(TEXT(Sub_Status__c))  ) &amp;&amp; (Expire_Date__c &lt; TODAY() || Expire_Date__c = DATE(1900,01,01) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Data Sub Update</fullName>
        <actions>
            <name>Update_Data_Sub</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>To Update the Data sub field</description>
        <formula>$Setup.WorkflowSetting__c.Disable_Workflow_Rule__c  != true &amp;&amp; (Archived__c  = false &amp;&amp; ISPICKVAL(Data__c, &apos;Yes&apos;) &amp;&amp; (Data_All_Units__c  = true &amp;&amp; ( Address_Units__c  &lt;&gt; Data_Units__c ||   ISNULL(Data_Units__c)  ) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Data Units To Null</fullName>
        <actions>
            <name>Set_Data_Units_To_Null_For_No_Data</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Data Units To Null For Data as No in picklist</description>
        <formula>$Setup.WorkflowSetting__c.Disable_Workflow_Rule__c  != true &amp;&amp;   (  ISPICKVAL( Data__c , &apos;No&apos; )|| ISBLANK(TEXT( Data__c )) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Video Units To Null</fullName>
        <actions>
            <name>Set_Video_Units_To_Null_For_Video_No</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Video Units To Null For No video</description>
        <formula>$Setup.WorkflowSetting__c.Disable_Workflow_Rule__c  != true &amp;&amp;   (  ISPICKVAL(Video__c , &apos;No&apos; )|| ISBLANK(TEXT(Video__c )) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Voice Units To Null</fullName>
        <actions>
            <name>Set_Voice_Units_To_Null_For_No_Voice</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Voice Units To Null For No Voice</description>
        <formula>$Setup.WorkflowSetting__c.Disable_Workflow_Rule__c  != true &amp;&amp;   (  ISPICKVAL( Voice__c , &apos;No&apos; )|| ISBLANK(TEXT(Voice__c )) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Video Sub Update</fullName>
        <actions>
            <name>Update_Video_Subs</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>To Update the Video sub field</description>
        <formula>$Setup.WorkflowSetting__c.Disable_Workflow_Rule__c  != true &amp;&amp; (Archived__c   = false &amp;&amp; ISPICKVAL(Video__c, &apos;Yes&apos;) &amp;&amp; (Video_All_Units__c = true  &amp;&amp; ( Address_Units__c  &lt;&gt;  Video_Units__c ||  ISNULL(Video_Units__c) )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Voice Sub Update</fullName>
        <actions>
            <name>Update_Voice_Subs</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>To Update the Voice sub field</description>
        <formula>$Setup.WorkflowSetting__c.Disable_Workflow_Rule__c != true &amp;&amp;(Archived__c  = false &amp;&amp; ISPICKVAL(Voice__c, &apos;Yes&apos;)&amp;&amp; (Voice_All_Units__c  = true  &amp;&amp;  ( Address_Units__c  &lt;&gt;  Voice_Units__c  ||     ISNULL(Voice_Units__c) )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
