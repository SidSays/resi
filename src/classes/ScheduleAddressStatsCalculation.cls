/***************************************************************************************************************************************
 * Author     : Vivek Patel
 * Date       : 10-May-2013
 * Description: This class will be scheduled using 'Schedule Apex' feature of salesforce.
 * Requirement: 262 Plan statistics on Addres Statistics table.
 * History
     Version             : 1.0
     Author Last Updated : Vivek Patel 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
global class ScheduleAddressStatsCalculation implements Schedulable{

/***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 10-May-2013
     * Param      : SchedulableContext 
     * Return     : None
     * Description: This method will start the batch process that calculates Address statistics.
************************************************************************************************************************************/
	global void execute(SchedulableContext sc) {
		Integer batchSize;
		try {
			batchSize = (Integer) ConfigurableParameters__c.getValues('AddressStatsBatchSize').NumberValue__c; 
		}catch(Exception ex) {
			System.debug('No data found in custom setting:'+ex);
		}
		if(batchSize != null) {
			AddressesStatsCalculationZipBatch addressesStatsCalculationZipBatchObj = new AddressesStatsCalculationZipBatch(); 
			database.executebatch(addressesStatsCalculationZipBatchObj, batchSize);			
            AddressesStatsCalculationNodeBatch addressesStatsCalculationNodeBatchObj = new AddressesStatsCalculationNodeBatch(); 
			database.executebatch(addressesStatsCalculationNodeBatchObj, batchSize);
		}
   }
}