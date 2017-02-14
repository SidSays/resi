/**
* This Class is intended to handle the assignment of all Customer_Address__c records during a Territory, Turf or Playlist assignment to XSP Users
*
* @Author salesforce Services
* @Date 08/23/2016
*/
public with sharing class AddressAssignment {

    /**
    * This method will execute the business logic to update the ownerId, Territory__c and Plan__c fields on Customer_Address__c records
    *
    * @return   True or False depending on the success of the DML operation
    * @see Boolean
    */
    public static boolean alignToTerritory(ID newTerritoryId, Set<Id> addressIds) {

    	//Check a few things BEFORE we go into the update logic:
    	// 1. Determine if the current DML transaction count is less than the salesforce Governor Limit for all DML operations that can occur in a single transaction
    	// 2. Check to see if the Running User can update the Customer_Address__c object
    	// 3. Check to see if the Running User can update the Customer_Address__c.Territory__c field
    	Boolean result = false;

    	if(Limits.getDMLRows() < Limits.getLimitDMLRows() &&
    		Schema.sObjectType.Customer_Address__c.isUpdateable() &&
    		Schema.sObjectType.Customer_Address__c.fields.Territory__c.isUpdateable()
    		) {

    		try{
	            List<Customer_Address__c> addressList = new List<Customer_Address__c>();

	            for(Id aId: addressIds) {
                    addressList.add(new Customer_Address__c(
                        Id = aId,
                        Territory__c = newTerritoryId //Update the Territory__c lookup field
                      )
                    );
	            }

	            //Conduct the update operation
	        	Database.SaveResult[] srList = Database.Update(addressList,false);

	        	//If the update operation was successful, return a 'true' value for the calling Class to handle
	        	result = true;

        	}
        	catch(DmlException e){
        		return result;
        	}
        }

    	//If the update operation was NOT successful, return a 'false' value for the calling Class to handle
    	return result;
    }
}