global class AssignZipNodeCombosBatch implements Database.Batchable<sObject> {
	
	public String query='select Node__c, Region__c, Zip_Code__c, Property_Code__c from Zip_Node_Combinations__c WHERE Completed__c=false';
	public User assignedToUser;
	
	global AssignZipNodeCombosBatch() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		if(assignedToUser!=null){
			query+=' AND Region__c=\''+assignedToUser.Region__c+'\'';
		}
		system.debug(query);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   	if(assignedToUser!=null){
	   		String zipCode='';
	   		String node='';
	   		String region='';
	   		string complexCode='';

	   		for(Zip_Node_Combinations__c zipComboObj:(List<Zip_Node_Combinations__c>)scope){
	   			zipCode=zipComboObj.Zip_Code__c;
	   			node=zipComboObj.Node__c;
	   			region=zipComboObj.Region__c;
	   			complexCode=zipComboObj.Property_Code__c;
	   		}

	   		Plan__c zipNodePlan=new Plan__c();
	   		zipNodePlan.OwnerId=assignedToUser.Id;
	   		zipNodePlan.User__c=assignedToUser.Id;
	   		if(zipCode!=null && node!=null){
	   			zipNodePlan.Name=zipCode+'/'+node;
	   		}else if(complexCode!=null && node!=null){
	   			zipNodePlan.Name=node+'/'+complexCode;
	   		}
	   		zipNodePlan.Plan_Status__c = 'Draft';
    		zipNodePlan.Plan_Level__c = 'Turf';  
    		zipNodePlan.Expiration_Date__c = date.today().addMonths(3);
   			insert zipNodePlan;

   			List<Customer_Address__c> zipNodeAddresses=new List<Customer_Address__c>();
   			if(zipCode!=null && node!=null){
   				zipNodeAddresses=[Select Plan__c, Assigned_Date__c, OwnerId From Customer_Address__c Where Node__c=:node AND PostalCode__c=:zipCode AND Region__c=:assignedToUser.Region__c];
			} else if(complexCode!=null && node!=null){
   				zipNodeAddresses=[Select Plan__c, Assigned_Date__c, OwnerId From Customer_Address__c Where Node__c=:node AND Property_Code__c=:complexCode AND Region__c=:assignedToUser.Region__c];
			}
   			for(Customer_Address__c add:zipNodeAddresses){
   				add.Plan__c=zipNodePlan.Id;
   				add.Assigned_Date__c=Date.today();
   				add.OwnerId=assignedToUser.Id;
   			}

   			update zipNodeAddresses;

   			zipNodePlan.Plan_Status__c='Assigned';
   			update zipNodePlan;	

   			List<Zip_Node_Combinations__c> zipNodeUpdate=new List<Zip_Node_Combinations__c>();

   			for(Zip_Node_Combinations__c zipComboObj:(List<Zip_Node_Combinations__c>)scope){
   				zipComboObj.Completed__c=true;
   				zipNodeUpdate.add(zipComboObj);
   			}

   			update zipNodeUpdate;
   		}
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}