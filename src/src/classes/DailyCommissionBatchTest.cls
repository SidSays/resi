@isTest
private class DailyCommissionBatchTest {
	static testMethod void unitTest1(){
        TriggerSettings__c caseTrigger = new TriggerSettings__c();
        caseTrigger.Name = 'CaseTrigger';
        caseTrigger.isActive__c = True;

        insert caseTrigger;

        Account partAcc = new Account();
        partAcc.Name = 'Test Partner Account';
        partAcc.Type = 'Partner';
        partAcc.ClaimEligibilityDuration__c = 240;
        partAcc.ClaimWaitDuration__c = 60;
        insert partAcc;  

		List<Case> cases = new List<Case>();

		// insert Cases
		for(Integer i = 0; i < 5; i++){
			Case c=createCase('New');
			c.Affiliate_Account__c=partAcc.Id;
			cases.add(c);
		}

		for(Integer i = 0; i < 5; i++){
			Case c=createCase('Management Review');
			cases.add(c);
		}

		insert cases;

		// execute Batch
        DailyCommissionBatch b = new DailyCommissionBatch();
        Database.executeBatch(b,200);

        DailyCommissionBatch dcb= new DailyCommissionBatch();
        System.schedule('DailyCommissionBatch', '0 0 0 3 9 ? 2022', dcb);	
	}

	private static Case createCase(String status){
		Case c = new Case();
		c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Open Assigned Claim').getRecordTypeId();// change this to a query
        c.Region__c='Corporate';
		c.Status = status;
		return c;
	}
}