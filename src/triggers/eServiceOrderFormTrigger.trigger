trigger eServiceOrderFormTrigger on eSOF_Form__c (before insert, before update, after insert, after update)
{
    if(Trigger.isBefore)
    {
        for(eSOF_Form__c newRec: trigger.new)
        {
            if(Trigger.isInsert)
            {
                // envelope sender email should match a user in salesforce and the user should be the owner of the record
                // if not then integration user will be the owner of this record by default
                if(String.isNotBlank(newRec.envelope_email__c))
                {
                    List<User> sfUserList = [select id from user where isactive = true and email =: newRec.envelope_email__c limit 1];
                    if(!sfUserList.isEmpty()) 
                    {
                        newRec.ownerid = ((User)sfUserList.get(0)).id;
                    }
                }
            }
            // recpient 1 = XSP
            if(newRec.Recipient_Routing_Order__c == 1)
            {
                newRec.sender_email__c = newRec.recipient_email__c;
                newRec.sender_name__c = newRec.recipient_name__c;
            }    
            // recpient 2 = customer
            if(newRec.Recipient_Routing_Order__c == 2)
            {
                if(String.isBlank(newRec.customer_email__c))
                {
                    newRec.customer_email__c = newRec.recipient_email__c;
                }
                if(String.isBlank(newRec.customer_first_name__c) && String.isBlank(newRec.customer_last_name__c))
                {
                    newRec.customer_name__c = newRec.recipient_name__c;            
                }
            }
            if(String.isNotBlank(newRec.customer_first_name__c))
            {
                newRec.customer_name__c = newRec.customer_first_name__c;            
            }
            
            if(String.isNotBlank(newRec.customer_last_name__c))
            {
                newRec.customer_name__c = newRec.customer_last_name__c;
                            
                if(String.isNotBlank(newRec.customer_first_name__c))
                {
                    newRec.customer_name__c = newRec.customer_first_name__c + ' ' +newRec.customer_last_name__c;            
                }
            }
        }
    }
}