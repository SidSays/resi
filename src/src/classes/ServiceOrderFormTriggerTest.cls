/**
 * Test class for Service order form Trigger
 */
@isTest
private class ServiceOrderFormTriggerTest 
{
   //Test Method
    static testMethod void testTrigger() 
    {
        try
        {
            List<eSOF_Form__c> forms = new List<eSOF_Form__c>();
            
            eSOF_Form__c eSOFObject = new eSOF_Form__c();
            eSOFObject.envelope_email__c = 'xsp_docusign_user@docusigntest.com';
            eSOFObject.Recipient_Routing_Order__c = 1;
            
            eSOFObject.recipient_email__c = 'xsp_user@recipient.com';
            eSOFObject.recipient_name__c = 'xsp recipient';
            
            eSOFObject.customer_email__c = 'customer_user1@recipient.com';
            eSOFObject.customer_name__c = 'customer name1';
            
            forms.add(eSOFObject);
            
            eSOFObject = new eSOF_Form__c();
            eSOFObject.envelope_email__c = 'xsp_docusign_user@docusigntest.com';
            eSOFObject.Recipient_Routing_Order__c = 2;
            
            eSOFObject.recipient_email__c = 'customer_user2@recipient.com';
            eSOFObject.recipient_name__c = 'customer name2';
            forms.add(eSOFObject);
            
            eSOFObject = new eSOF_Form__c();
            eSOFObject.envelope_email__c = 'xsp_docusign_user@docusigntest.com';
            eSOFObject.Recipient_Routing_Order__c = 2;
            
            eSOFObject.recipient_email__c = 'customer_user2@recipient.com';
            eSOFObject.recipient_name__c = 'customer name2';
            
            eSOFObject.customer_last_name__c = 'name3';
            eSOFObject.customer_first_name__c = 'customer';
            
            forms.add(eSOFObject);
            
            insert forms;
            
            System.assertNotEquals(null, forms);
        }
        catch(Exception e)
        {
            System.debug('*** Exception: ' + e.getMessage());
        }
    }
}