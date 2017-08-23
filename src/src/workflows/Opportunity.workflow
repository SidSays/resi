<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_to_Assigned_XC_Sales_Engineer</fullName>
        <description>XC - Sales Engineer - Workflow / Email Alert-US1021127</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_SE__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/XC_Sales_Engineer_Assignment_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Cost</fullName>
        <field>Cost__c</field>
        <formula>IF(ISBLANK(Per_Unit_Door_Fee__c), 0, Per_Unit_Door_Fee__c) * Number_of_Units__c 

+ 

Video_Revenue__c * IF(ISBLANK(Video_Estimated_Revenue_Share_Rate__c), 0, Video_Estimated_Revenue_Share_Rate__c) 

+ 

Data_Revenue__c * IF(ISBLANK(Data_Estimated_Revenue_Share__c), 0, Data_Estimated_Revenue_Share__c) 

+ 

Voice_Revenue__c * IF(ISBLANK(Voice_Estimated_Revenue_Share__c), 0, Voice_Estimated_Revenue_Share__c) 

+ 

IF(ISBLANK(Construction_Capex_Cost__c), 0, Construction_Capex_Cost__c) 

+ 

IF(ISBLANK(Total_Equipment_Cost__c), 0, Total_Equipment_Cost__c)</formula>
        <name>Cost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Opportunity_Close_Lost_Date</fullName>
        <field>Close_Lost_Date__c</field>
        <formula>TODAY()</formula>
        <name>Populate Opportunity Close Lost Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Close_Date_For_Close_Opportunity</fullName>
        <description>Set Close Date to the date on which opportunity close</description>
        <field>CloseDate</field>
        <formula>TODAY()</formula>
        <name>Set Close Date For Close Opportunity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XC_Contract_Term_Months</fullName>
        <description>Upon opportunity update, calculate the contract term months field.</description>
        <field>Contract_Term_Months__c</field>
        <formula>IF(ISPICKVAL(ContractTermUnit__c , &apos;Years&apos;), 12, IF(ISPICKVAL(ContractTermUnit__c , &apos;Months&apos;), 1, 0)) * ContractTerm__c</formula>
        <name>XC Contract Term Months</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Close Date For Close Opportunity</fullName>
        <actions>
            <name>Set_Close_Date_For_Close_Opportunity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This use to set close date as Today&apos;s date for close opportunity</description>
        <formula>( $Label.XfinityOpptyRecordTypeId = RecordTypeId ) &amp;&amp;($Setup.WorkflowSetting__c.Disable_Workflow_Rule__c != true &amp;&amp; ISCHANGED(StageName) &amp;&amp; (ISPICKVAL( StageName , &apos;Closed Won&apos;) || ISPICKVAL( StageName , &apos;Closed Lost&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity %3A Update Close Lost Date</fullName>
        <actions>
            <name>Populate_Opportunity_Close_Lost_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Lost</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Xfinity Opportunity Record Type</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>XC Opportunity Update</fullName>
        <actions>
            <name>Cost</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>XC_Contract_Term_Months</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Xfinity Opportunity Record Type</value>
        </criteriaItems>
        <description>Calculates specific fields upon opportunity update.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>XC Sales Engineer Notification</fullName>
        <actions>
            <name>Email_to_Assigned_XC_Sales_Engineer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>XC Sales Engineer Notification- US1021127</description>
        <formula>ISCHANGED( Assigned_SE__c) &amp;&amp;  NOT((ISNULL(Assigned_SE__c) || ISBLANK(Assigned_SE__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
