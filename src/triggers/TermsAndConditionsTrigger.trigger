trigger TermsAndConditionsTrigger on Terms_and_Conditions__c (before insert, before update) 
{
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('TermsAndConditionsTrigger');
    if(triggerSetting.isActive__c){
        if(trigger.New[0].Active__c)
        {
            TermsAndConditonsTriggerHelper.checkIfTandCActive(trigger.New[0]);
        }
        if(trigger.New[0].Reset_Terms_and_Conditions_Accepted__c)
        {
            ResetTermsAndConditionsAcceptedBatch rtacab= new ResetTermsAndConditionsAcceptedBatch();
            if(Test.isRunningTest()){
                rtacab.query='SELECT Terms_and_Conditions_Accepted__c FROM User Where Id=\''+SetupTestData.dsrUser.Id+'\'';
            }
            Database.executeBatch(rtacab);
            trigger.New[0].Reset_Terms_and_Conditions_Accepted__c=false;
        }
    }
}