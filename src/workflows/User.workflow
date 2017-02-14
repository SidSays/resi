<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>UserEmailEncoding</fullName>
        <active>false</active>
        <criteriaItems>
            <field>User.EmailEncodingKey</field>
            <operation>notEqual</operation>
            <value>Unicode (UTF-8)</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
