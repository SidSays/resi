<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>QPR_Name_Field_Template</fullName>
        <description>Updates the QPR name field according the the template: &quot;QPR_FiscalQuarterYear_PersonCoach</description>
        <field>Name</field>
        <formula>&quot;QPR_&quot; &amp;
IF(Date_of_the_review__c&gt;= DATE(YEAR(Date_of_the_review__c),3,22) &amp;&amp; Date_of_the_review__c &lt;= DATE(YEAR(Date_of_the_review__c),6,21),&quot;Q2&quot;, 
IF(Date_of_the_review__c&gt;= DATE(YEAR(Date_of_the_review__c),6,22) &amp;&amp; Date_of_the_review__c &lt;= DATE(YEAR(Date_of_the_review__c),9,21),&quot;Q3&quot;, 
IF(Date_of_the_review__c&gt;= DATE(YEAR(Date_of_the_review__c),9,22) &amp;&amp; Date_of_the_review__c &lt;= DATE(YEAR(Date_of_the_review__c),12,21),&quot;Q4&quot;, 
&quot;Q1&quot; ) ))+ if(MONTH(Date_of_the_review__c)==12 &amp;&amp; Date_of_the_review__c&gt;= DATE(YEAR(Date_of_the_review__c),12,22) , TEXT(YEAR(Date_of_the_review__c)+1),TEXT(YEAR(Date_of_the_review__c)))
+ &quot;_&quot; + Coaching__r.Coached.FirstName + &quot; &quot; + Coaching__r.Coached.LastName</formula>
        <name>QPR Name Field Template</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QPR_Rule_Status_Complete1</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Test_Record_Type</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>QPR Rule Status Complete1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QPR_Rule_Status_Draft1</fullName>
        <field>RecordTypeId</field>
        <lookupValue>QPR_Default_Record_Type</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>QPR Rule Status Draft1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>QPR Name Field Update</fullName>
        <actions>
            <name>QPR_Name_Field_Template</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the name field of the QPR record according to the given template: &apos;QPR_FiscalQuarterYear_PersonCoach&apos;</description>
        <formula>Isnew() || ISCHANGED( Name ) || ISCHANGED( Date_of_the_review__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>QPR Rule Status Complete</fullName>
        <actions>
            <name>QPR_Rule_Status_Complete1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Quarterly_Portfolio_Review__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Set all fields read only on page layout  by assigning QPR Completed Page Layout when the QPR record status is completed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>QPR Rule Status Draft</fullName>
        <actions>
            <name>QPR_Rule_Status_Draft1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set all fields editable on page layout by assigning a Quarterly Portfolio Review Layout when status of QPR record is changed from completed to draft</description>
        <formula>AND(ISCHANGED(Status__c),  NOT( ISPICKVAL( Status__c , &quot;Completed&quot;) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
