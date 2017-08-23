/**
 * Name     : GSIRootMetaDataService 
 * Usage    : GSI Application metadata service query metadata for GSI application, return
 *            data for Root Nodes for Home screen max 8, and related details of Node & Node Items tat present
 *            Capability, Teams, Clients, Markets and related items
 *  
 * Created By      : Igor Androsov
 * Modified By     : Igor Androsov
 * Modified Date   : Nov 06, 2015
 */
@RestResource(urlMapping='/gsiroot/*') 
global class GSIRootMetaDataService {

  @HttpGet
    global static List<GSIRootMetadata> doGet() {
      // TODO Complete this method with full logic and test cases
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String refreshDate = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1); // use this parm flag fomr app to query delta uopdated records may not need to use it

        System.debug('#### GSI Param refreshDate: '+refreshDate); // Pass refresh Date for metadata download delta logic Foprmat DATE ONLY 2013-07-18 used for Team pictures, Clients image
        // If NO parameter value will be last elemet  = gsidata
        Date refreshedDate = null;
        if(refreshDate != 'gsidata'){
          //Parameter for last refreshDate time is Pressent
            if(refreshDate != null){
              try{
                  refreshedDate = date.valueOf(refreshDate);
              }catch(Exception ex){}
            }
        }

    	/*** TODO insert logic to query and get all root Nodes ***/
    	    
    	List<GSIRootMetadata> rootNodeList = GSIRootMetaDataService.getRootData(refreshedDate);
    	
    	
    	system.debug('::: Returned ::::'+rootNodeList);
        return rootNodeList;
    	
    }

	private static List<GSIRootMetadata> getRootData(Date refreshedDate) {
		List<GSIRootMetadata> rootNodeList = new List<GSIRootMetadata>();
		List<GSI_Root_Node__c> rootList = GSIRootMetaDataService.getRootNodeList();
		for(GSI_Root_Node__c rn : rootList){
			GSIRootMetadata rd = new GSIRootMetadata();
			rd.recordId = rn.Id;
			rd.rootNode = rn;
			rootNodeList.add(rd);
		}
		return rootNodeList;
	}
	
	private static List<GSI_Root_Node__c> getRootNodeList() {
		List<GSI_Root_Node__c> rootList = [SELECT Id, Name, Color__c, Enabled__c, Image_Name__c, Image_File_ID__c, 
                                           Sort_Order__c, Node_Type__c, Content_Category__c, Category_Name__c   
		                                   FROM GSI_Root_Node__c 
		                                   WHERE Enabled__c = true ORDER BY Sort_Order__c LIMIT 8];		
		return rootList;
	}
    
}