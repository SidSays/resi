<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Change_Disconnected_to_true</fullName>
        <field>Disconnected__c</field>
        <literalValue>1</literalValue>
        <name>Change Disconnected to true</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_the_complex_Office_checkbox</fullName>
        <field>Complex_Office__c</field>
        <literalValue>0</literalValue>
        <name>Clear the complex Office checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Customer_Address_Field_Update</fullName>
        <field>Name</field>
        <formula>Address__c</formula>
        <name>Customer Address Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetHSIOnlyAddressUpdate</fullName>
        <field>HSI_Only_Address__c</field>
        <literalValue>1</literalValue>
        <name>SetHSIOnlyAddressUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Targeted_Flag_to_False</fullName>
        <field>Targeted__c</field>
        <literalValue>0</literalValue>
        <name>Update Targeted Flag to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Targeted_equals_True</fullName>
        <field>Targeted__c</field>
        <literalValue>1</literalValue>
        <name>Update Targeted equals True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Target Flag</fullName>
        <actions>
            <name>Update_Targeted_Flag_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISBLANK(Account__c)),ISPICKVAL(Account__r.Customer_Status__c, &apos;Active&apos;),Targeted__c==true)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Targeted Flag to True for inactive Account</fullName>
        <actions>
            <name>Update_Targeted_equals_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISBLANK(Account__c)),AND(NOT(OR(ISPICKVAL(Dwelling_Type__c, &apos;Multiple dwelling Unit&apos;), ISPICKVAL(Dwelling_Type__c, &apos;MDU&apos;),Excluded_from_Territory__c= TRUE,Disconnect_Reason__c=&apos;Non Pay&apos;)),NOT(OR(ISCHANGED(Dwelling_Type__c),ISCHANGED(Excluded_from_Territory__c),ISCHANGED(Disconnect_Reason__c)))),OR(ISPICKVAL(Account__r.Customer_Status__c, &apos;Former&apos;) ,ISPICKVAL(Account__r.Customer_Status__c, &apos;Never&apos;),ISPICKVAL(Account__r.Customer_Status__c, &apos;Shopping&apos;),ISPICKVAL(Account__r.Customer_Status__c, &apos;D&apos;)),NOT(ISBLANK(Territory__c)),Targeted__c==false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>updateHSIonly</fullName>
        <actions>
            <name>SetHSIOnlyAddressUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  HSI_Active1__c,  NOT(  OR(Video_Active1__c,  Voice_Active1__c,  XH_Active1__c)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
