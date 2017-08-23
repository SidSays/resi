/*********************************************************************************************
Name : TerritorySmoothingBatchSchedule
Description : Scheduler for TerritorySmoothingBatchSchedule
User Story : US1103983
Date : 12 May 2017
Author : Amit Kumar -  Accenture 
***************************************************************************************************/
global class TerritorySmoothingBatchSchedule implements Schedulable{
	private map<string,CensusTract__c> mapcensusterritory = new map<string,CensusTract__c>();
    private set<string> setuniqueregion = new set<string>();
    
	//Method to process the modified Census records and ge the unique Region and Census records
	global void execute(SchedulableContext sc){
		//Query the Census Tract records
		for(CensusTract__c objtract:[SELECT id, Territory__c, CensusTractNumber__c, Territory__r.Territory_Region__c, Territory_Changed__c,Old_Territory_Region__c
											FROM CensusTract__c where Territory_Changed__c=:true LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
        	mapcensusterritory.put(objtract.CensusTractNumber__c,objtract);	  //Add the records based on Census number and Census tract record
        	if(!(string.isBlank(objtract.Territory__r.Territory_Region__c))){  //Check if Territory has been changed and new Territory has been added
        		string regioncheck = Variable_Setting__c.getInstance('TerritorySmoothingRegions') != null ? Variable_Setting__c.getInstance('TerritorySmoothingRegions').Value__c : '';//Get the Region for which territory smoothing needs to be run
        		if(regioncheck.contains(objtract.Territory__r.Territory_Region__c)){
        			setuniqueregion.add(objtract.Territory__r.Territory_Region__c);
        		}
        	}else if(objtract.Territory__c ==null){
        		setuniqueregion.add(objtract.Old_Territory_Region__c);
        	}
        }  
        if(!setuniqueregion.Isempty()){  //If Census record Territory record is not Empty 
        	list<string> lstuniqueregion = new list<string>();
        	lstuniqueregion.addall(setuniqueregion); //Add all region in a list to process in For loop and get the index
        	for(integer i =0;i<lstuniqueregion.size();i++){
        		TerritorySmoothingBatch objterritorybatch = new TerritorySmoothingBatch(lstuniqueregion[i],mapcensusterritory); //Instantiate the Territory batch for processing 
        		if(i==0){																								//If only one region is Present then start the batch at 0 minute 
        		 	system.scheduleBatch(objterritorybatch, 'Territory Smoothining  '+lstuniqueregion[i], 0);
        		}else{                                                                                                 //Any subsequent batch will schedule after index+5 minute.
        			system.scheduleBatch(objterritorybatch, 'Territory Smoothining  '+lstuniqueregion[i], i+i+5);
        		}//End of Else condition
        		
        	}	//End of iteration of for loop of Regions
        }//End of ISempty check for Regions
    }//End of Execute method
}//End od class