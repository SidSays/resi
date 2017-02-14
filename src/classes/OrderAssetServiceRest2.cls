@RestResource(urlMapping='/OrderAssetServiceRest2/*')
/**
 * OrderAssetServiceRest.cls
 * Created on: 1/17/2014
 * Author: Doug Beltowski
 * Contains a webservice method for retrieving 
 * Order, Order Line Item, and Asset information
 */

global without sharing class OrderAssetServiceRest2{

	@HttpGet
	global static OrderAssetWrapper getOrderAsset(){
        
        Integer RECORD_LIMIT = 500;
        Decimal totalAccountRecords = 0;
		String planId = RestContext.request.params.get('planId');
        Integer page = Integer.valueOf( RestContext.request.params.get('page') );
        System.debug( 'Requesting Page ' + page );
        Integer offSet = ( page - 1 ) * RECORD_LIMIT;//It is necessary to subtract one from the page to return the first 500 records.
		Set<id> orderIdSet = new Set<id>();
		OrderAssetWrapper orderAssetObject = new OrderAssetWrapper();
		
		//Retrieve any child plans that may exist
		Map<id,Plan__c> planMap = new Map<Id, Plan__c>( [SELECT id FROM Plan__c WHERE Parent_Plan__c = :planId OR id = :planId ] );
		System.debug( 'Initial query to return child plans. Query Row Limit now at: ' + Limits.getQueryRows() );
		planMap.put( planId, null );
		
        for(AggregateResult r : [SELECT COUNT_DISTINCT(id) total, Service_Address__r.Plan__c FROM Account WHERE Account.Service_Address__r.Plan__c IN :planMap.keySet() GROUP By Service_Address__r.Plan__c]){
        	totalAccountRecords += Integer.valueOf( r.get('total') );//Count all Accounts in a plan.
        }
        System.debug( 'Querying page ' + page + ' of ' + Math.Ceil( totalAccountRecords / RECORD_LIMIT ) + ' Account Records' );
        System.debug( 'Returning records from ' + offSet + ' to ' + (offSet + RECORD_LIMIT) );
		//Retrieve the Account records and associated Orders and Assets using the Account > Customer_Address__c > Plan__c relationship
		Map<id, Account> accountMap = new Map<id, Account>( [SELECT 
																(SELECT AccountId, Product2.name, Name, InstallDate, Status FROM Assets),
																(SELECT id FROM OrderContracts__r ORDER BY CreatedDate DESC LIMIT 3) 
															FROM Account a WHERE account.service_address__r.Plan__c IN :planMap.keySet() LIMIT :RECORD_LIMIT OFFSET :offSet ]);
		System.debug( 'SOQL Query Row Limit at: ' + Limits.getQueryRows() );
		System.debug( 'Heap Size at: ' + Limits.getHeapSize() );
		
		orderAssetObject.assetList = new List<Asset>();
		for(Account acct : accountMap.values()){

			orderIdSet.addAll( new Map<id,Order__c>( acct.OrderContracts__r ).keySet() );
			orderAssetObject.assetList.addAll( acct.Assets );
		}

		List<Order__c> orderList = [SELECT Account__c, BillerOrderStatus__c, Order_Number__c, ScheduledInstallationDate__c, CreatedDate,
											Salesperson_ID__c, OwnerId, Owner.Name, LastModifiedDate, Customer_Type__c, Name, Scheduled_Install_Timeframe__c, ActualMRC__c, ActualNRC__c, Worklisted__c, Install_Date_and_Timeframe__c,
										(SELECT Name, Total_Item_MRC__c, Total_Item_NRC__c, Offer_Name__c, LastModifiedDate, 
											Order__c, RECON_Status__c, RGU__c FROM Order_Line_Items__r ORDER BY CreatedDate DESC LIMIT 4) 
									FROM Order__c o WHERE id IN :orderIdSet ];
		accountMap = null;
		System.debug( 'SOQL Query Row Limit at: ' + Limits.getQueryRows() );
		System.debug( 'Heap Size at: ' + Limits.getHeapSize() );
		orderAssetObject.orderList = orderList;
        
        if( totalAccountRecords != 0 ){//Need this to prevent index out of bounds error
        	orderAssetObject.hasNext = offset + RECORD_LIMIT < totalAccountRecords;
        }  
		return orderAssetObject;
	} 

	global class OrderAssetWrapper{
        //public Integer totalAddressRecords;
        public boolean hasNext{get;set;}
		public List<Order__c> orderList{get;set;}
		public List<Asset> assetList{get;set;}
	}
}