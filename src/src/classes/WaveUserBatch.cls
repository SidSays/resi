/*
 * @description Set the User.WaveUser__c checkbox, based on Permission Set License (PSL) Assignments
 * In theory, we might also care about Permission Set Assignments, but, in practice if the PSL is assigned, the license is consumed
 * @author Ravi Benedetti
 * @date 20170619
 */ 
global class WaveUserBatch implements Database.Batchable<sObject> {
	/*
	 * Note: The use of the Database.Stateful interface is contraindicated here
	 * - We are not maintaining running totals across invocations
	 * - We do not have very expensive queries that would benefit from cross-invocation caching
	 * - Ergo, the cost of statefulness (i.e. serialization-deserialization) is too high
	 */ 

    // Get the Wave-related Permission Set License Ids
    global List<PermissionSetLicense> listWavePSLs = [SELECT Id FROM PermissionSetLicense WHERE DeveloperName LIKE 'Insights%'];
    
    // Capture the query in code vs custom label to keep things simple
	global Database.QueryLocator start(Database.BatchableContext BC) {
		// sfdcTodo 20170620.1900 More than likely, we will need to update a Custom Setting to turn the User trigger OFF here
       
        String batchQuery = [SELECT value__c FROM Queries__mdt where DeveloperName = 'WaveUserBatch'][0].Value__c;
    	if(String.isEmpty(batchQuery)) {
        	batchQuery = 'SELECT Id, WaveUser__c FROM User WHERE IsActive = TRUE ORDER BY Id';
    	}
        
        // If this is being invoked by a test class, then set limit to match the test scope
        if(Test.isRunningTest()) {
            batchQuery = batchQuery + ' LIMIT 200';
        }
        
        return Database.getQueryLocator(batchQuery);
    }

	// Set or unset the WaveUser__c flag on records in scope    
    global void execute(Database.BatchableContext BC, List<User> listUsers) {
		/* 
		 * Leverage the 'special constructor' available for Maps of sObjects
		 * We are able to use this here, because we are assured there will not be any duplicate users in listUser
		 */ 
        Set<Id> userIds = (new Map<Id,User>(listUsers)).keySet();
        // Select permission set license assignment records for user in scope and for JUST the Wave-related permission set licenses
        List<PermissionSetLicenseAssign> listPsla = [SELECT AssigneeId FROM PermissionSetLicenseAssign WHERE AssigneeId IN :userIds AND PermissionSetLicenseId IN :listWavePSLs];
		/* 
		 * listPSLA will include multiple entires per User, because there are multiple Permission Set Licenses for Wave
		 * Thus, we must derive the set of unique User Ids that are Wave enabled. 
		 * Unfortunately, we cannot use sObject Map Kung Fu here :-/
		 */ 
        Map<String, Boolean> mapWaveUser = new Map<String, Boolean>();
        for(PermissionSetLicenseAssign psla : listPsla) {
            mapWaveUser.put(psla.AssigneeId,TRUE);
        }
        /*
         * Now we cycle through the Users in scope (i.e. listUser) and set or unset the WaveUser__c flag, as necessary
         * We only update the Users that need updating (i.e. that need to have their flag set or unset)
         * In theory, if we disable the User trigger, we need not be so careful. In practice, care is the better part of employment ;-)
         */ 
        List<User> updateUsers = new List<User>();
        for(User oneUser : listUsers) {
			// User is Wave Enabled (just by virtue of being in the map)
            if(mapWaveUser.containsKey(oneUser.Id)) {
				// User.WaveUser__c = FALSE, so we must update User.WaveUser__c to TRUE
                if(!oneUser.WaveUser__c) {
                    oneUser.WaveUser__c = TRUE;
                    updateUsers.add(oneUser);
                }
            // User is not Wave Enabled (just by virtue of not being in the map)   
            } else {
                // User.WaveUser__c = TRUE, so we must update User.WaveUser__c to FALSE
                if(oneUser.WaveUser__c) {
                    oneUser.WaveUser__c = FALSE;
                    updateUsers.add(oneUser);
                }
            }
        }
        try {
            update updateUsers;
        } catch(dmlexception e) {
            // sfdcTodo 20170619.1945 See what the DEV Team standard is for exceptions (right now we just debug)
            System.debug('>>>sfdcDebug>>> Error: ' + e);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
	    /*
         * More than likely, we will need to update a Custom Setting to turn the User trigger back ON here
         */    
    }
}