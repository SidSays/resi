global class TerritoryExclusionsBatch implements Database.Batchable<Integer>, Database.AllowsCallouts{
	private Boolean exclude;
	private static WaveAPIUtil wave;
	static {
		wave = WaveAPIUtil.getInstance();
	}
	private string sessionId;
	private Job_Status__c js;
	private Integer chunkSize;
	private Integer totalNumRecords;
	private String saqlQuery;
	private String lensName;
	private Id jobStatusId;
	private String lensId;

	global TerritoryExclusionsBatch(String saqlQuery, Boolean exclude, String sessionId, Id userId, Integer totalNumRecords, String lensId, String lensName) {
		this.exclude = exclude;
		this.sessionId = sessionId;
		this.chunkSize =	Integer.valueOf([SELECT Value__c FROM System_Property__mdt WHERE MasterLabel = 'Territory Exclusion Batch Chunk Size'].Value__c);
		this.totalNumRecords = totalNumRecords;
		this.saqlQuery = saqlQuery;
		this.lensName = lensName;
		this.lensId = lensId;

		js = new Job_Status__c(Batch_Start_Time__c = Datetime.now(), Total_Records_Processed__c = 0, Total_No_Of_Records__c = totalNumRecords, Status__c = 'In Progress', Name = (exclude) ? 'Exclude ' + lensName + ' ' + Datetime.now() : 'Include ' + lensName + ' ' + Datetime.now());
		insert js;
		jobStatusId = js.Id;
	}

	global Iterable<Integer> start(Database.BatchableContext BC) {
		return new OffsetIterable(chunkSize, totalNumRecords);
	}

	global void execute(Database.BatchableContext BC, List<Integer> scope) {
		List<Customer_Address__c> addresses;
		js = [SELECT Total_Records_Processed__c, Comments__c FROM Job_Status__c WHERE Id = :jobStatusId];
		try{
			String newSaqlQuery = saqlQuery;
			newSaqlQuery += 'q = offset q ' + scope[0] + ';';
			newSaqlQuery += 'q = limit q ' + chunkSize + ';';

			List<Id> addressIds = queryForAddresses(newSaqlQuery);
			addresses = [SELECT Excluded__c FROM Customer_Address__c WHERE Id IN: addressIds];
			if(exclude){
				for(Customer_Address__c c: addresses){
						c.Excluded__c = exclude;
						c.Last_Exclusion_Action_Date__c = Date.today();
						c.Exclusion_Lens__c = lensName;
				}
			} else {
				for(Customer_Address__c c: addresses){
					c.Excluded__c = exclude;
					c.Last_Inclusion_Action_Date__c = Date.today();
					c.Inclusion_Lens__c = lensName;
				}
			}
			update addresses;
		} catch (Exception e) {
			js.Comments__c = e.getMessage() + 'process error';
		}
		js.Total_Records_Processed__c += addresses.size();
		update js;
	}

	global void finish(Database.BatchableContext BC) {
		js = [SELECT Status__c, Comments__c, Batch_End_Time__c FROM Job_Status__c WHERE Id = :jobStatusId];
		if(String.isNotBlank(js.Comments__c) && js.Comments__c.contains('process error')){
			js.Status__c = 'Completed With Errors';
		} else {
			js.Status__c = 'Completed Without Errors';
		}
		js.Batch_End_Time__c = Datetime.now();
		update js;
	}

	public void executeBatch(){
		Database.executeBatch(this, 1);
	}

	public List<Id> queryForAddresses(String qString){
		List<Id> addresses = new List<Id>();
		String queryRes = wave.postQueryAsync(qString, sessionId);

		// We only care about the list of records contained in this response (queryRes.results.records)
		Map<String, Object> postQueryMap = (Map<String, Object>) JSON.deserializeUntyped(queryRes);
		Map<String, Object> resultsObj = (Map<String, Object>) postQueryMap.get('results');

		List<Object> addressList;
		if(!resultsObj.isEmpty()){
			addressList = (List<Object>) resultsObj.get('records');
		}
		if(addressList.size() > 0){
			for (Integer i = 0; i < addressList.size(); i++) {
				Id addressId = (Id) ((Map<String, Object>) addressList[i]).get('Id');
				addresses.add(addressId);
			}
		}
		return addresses;
	}
}