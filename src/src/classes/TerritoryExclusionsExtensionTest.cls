@isTest
private class TerritoryExclusionsExtensionTest {

	private static Customer_Address__c CAONE;

	@isTest static void testGetAvailableLenses() {
		init();
		Test.setMock(HttpCalloutMock.class, new TerritoryExclusionWaveMockServiceImpl());
		Test.startTest();
		List<WaveLenses.Lenses> lenses = TerritoryExclusionsExtension.getAvailableLenses();
		Test.stopTest();
		System.assert(lenses.size()==1);
	}

	@isTest static void testGetLensData() {
		init();
		Test.setMock(HttpCalloutMock.class, new TerritoryExclusionWaveMockServiceImpl());
		Test.startTest();
				TerritoryExclusionsExtension.LensAndXmd lenses = TerritoryExclusionsExtension.getLensData('LensId');
				Test.stopTest();
		System.assert(lenses.xmdStr!=null);
		System.assert(lenses.versionId == '0Fc7A0000000wISSAY');
	}

	@isTest static void testSaqlToCount(){
		init();
		Test.setMock(HttpCalloutMock.class, new TerritoryExclusionWaveMockServiceImpl());
		Integer count;
		Test.startTest();
			count = TerritoryExclusionsExtension.saqlToCount('/services/data/v36.0/wave/query');
		Test.stopTest();

		System.assertEquals(1, count, 'Incorrect number of records retrieved from callout');
	}

	@isTest static void testExecuteExclusionsBatchInclude(){
		init();
		Test.setMock(HttpCalloutMock.class, new TerritoryExclusionWaveMockServiceImpl());
		Integer count;
		String saql = 'q = load "0FbP0000000DCVAKA4/0FcP0000000GJ8CKAW"; q = filter q by \'Property_Code__c\' == "067R"; q = foreach q generate \'Id\' as \'Id\';';

		Test.startTest();
			TerritoryExclusionsExtension.executeExclusionsBatch(saql, false, 'lensId', 'lensName');
		Test.stopTest();

		Customer_Address__c requeriedAddressOne = [SELECT Last_Inclusion_Action_Date__c, Excluded_from_Territory__c, Inclusion_Lens__c FROM Customer_Address__c WHERE Id = : CAONE.Id];

		System.assertEquals(false, requeriedAddressOne.Excluded_from_Territory__c);
		System.assertEquals(Date.today(), requeriedAddressOne.Last_Inclusion_Action_Date__c);
		System.assertEquals('lensName', requeriedAddressOne.Inclusion_Lens__c);
	}

	@isTest static void testExecuteExclusionsBatchExclude(){
		init();
		Test.setMock(HttpCalloutMock.class, new TerritoryExclusionWaveMockServiceImpl());
		Integer count;
		String saql = 'q = load "0FbP0000000DCVAKA4/0FcP0000000GJ8CKAW"; q = filter q by \'Property_Code__c\' == "067R"; q = foreach q generate \'Id\' as \'Id\';';

		Test.startTest();
			TerritoryExclusionsExtension.executeExclusionsBatch(saql, true, 'lensId', 'lensName');
		Test.stopTest();

		Customer_Address__c requeriedAddressOne = [SELECT Last_Exclusion_Action_Date__c, Excluded_from_Territory__c, Exclusion_Lens__c FROM Customer_Address__c WHERE Id = : CAONE.Id];

		System.assertEquals(true, requeriedAddressOne.Excluded_from_Territory__c);
		System.assertEquals(Date.today(), requeriedAddressOne.Last_Exclusion_Action_Date__c);
		System.assertEquals('lensName', requeriedAddressOne.Exclusion_Lens__c);
	}

	static void init(){
		TriggerSettings__c AddressTrigger = new TriggerSettings__c();
		AddressTrigger.Name = 'AddressTrigger';
		AddressTrigger.isActive__c = false;
		Database.insert(AddressTrigger);

		CAONE = new Customer_Address__c();
		CAONE.PostalCode__c = 'abcdefgh';
		CAONE.PostalCode_4__c = 'qwerty';
		CAONE.Address__c = 'test address';
		CAONE.Is_Account_Linking_Processed__c=false;
		CAONE.PostalCode__c = 'qwertyuio';
		CAONE.Name = 'caOne';

		insert CAONE;
	}
}