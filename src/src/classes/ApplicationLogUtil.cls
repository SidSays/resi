/*************************************************************************************
    Name             : ApplicationLogUtil.cls
    Description      : Class to process the content of email and create Application log record
    Created By       : Accenture
    Created Date     : 06/25/2017
    User Story		 : US1026408: Create a trigger exception logging framework
 
************************************************************************************/
public with sharing class ApplicationLogUtil {
   

    /************************************************************************************************************
        @Name       :   insertApplogforexceptions
        @Description:   Method to process the exception
        @Parameters :   Exception object: Exception Record for Try Catch
        				CodeType: Type of code e.g. Trigger, Class, Future Method, Batch Class,Integration
        			    className: Code Snippet Name
        			    RecordId: Error on which error has occured. this will be passed for single record transcation.
        			    ObjName: Object Name on which operation happening
        			    sfdcRTId: Application Log Record type id
        			    sendEmail: Email notification requried or not	
        @Returns    :   void
    ************************************************************************************************************/
    public static void insertApplogforexceptions(Exception ex, string codeType,String className, String objName, Boolean sendEmail,string recordid,string sfdcRTId){
    		Application_Log__c objapplicationlog = new Application_Log__c();
			objapplicationlog.Type_of_Exception__c = ex.getTypeName();
			objapplicationlog.Log_Message__c = ex.getMessage() + ConstantHandler.APPEXCEPTIONCONNECTOR+ ex.getTypeName();
			objapplicationlog.Object_Name__c = objName;
			objapplicationlog.Snippet_Name__c = className;
			objapplicationlog.RecordTypeId = sfdcRTId;
			objapplicationlog.Send_Email__c = sendEmail;
			if(recordid!=null){
				objapplicationlog.Failed_Record_Id__c = recordid;	
			}
			if(ex.getLineNumber() != null){ 
				objapplicationlog.Exception_line__c = ex.getLineNumber();
			}
			if(!String.isBlank(ex.getStackTraceString())){
				objapplicationlog.Stack_Trace__c = ex.getStackTraceString();
			}
			if(ex.getTypeName().containsIgnoreCase(ConstantHandler.APPDMLEXCEPTION)){
				if(ex.getDmlFieldNames(0) != null){
					objapplicationlog.Error_field_Names__c = String.join(ex.getDmlFieldNames(0),ConstantHandler.APPCOMMASEPERATOR);
				}
				if(ex.getDmlId(0) != null){
					objapplicationlog.Failed_Record_Id__c = ex.getDmlId(0);
				}
				if(!String.isBlank(ex.getDmlStatusCode(0))){
					objapplicationlog.Status_Code__c = ex.getDmlStatusCode(0);
				}
			}
			if (objapplicationlog != null) {
				database.insert (objapplicationlog,false);
			}
		
     }
     /************************************************************************************************************
        @Name       :   insertApplogforsaveresult
        @Description:   Method to process the exception
        @Parameters :   SaveResult: Save Result for Insert and Update DML 
        			   CodeType: Type of code e.g. Trigger, Class, Future Method, Batch Class,Integration
        			   className: Code Snippet Name
        			   ObjName: Object Name on which operation happening
        			   sfdcRTId: Application Log Record type id
        			   sendEmail: Email notification requried or not
        			   lstSObject: List of record which wither get inserted, deleted, updated and upserted        
        @Returns    :   void
    ************************************************************************************************************/
    public static void insertApplogforsaveresult(Database.saveResult[] saveResult, String codeType,String className, String objName, Boolean sendEmail,List< sObject > lstSObject,string sfdcRTId){
    	List < Application_Log__c > lstapplicationlog = new List < Application_Log__c > ();
        if(!lstSObject.isEmpty()){         
            for (Integer i = 0; i < lstSObject.size(); i++) {
                Database.SaveResult sr = saveResult[i];        
				sObject sObj = lstSObject[i];
                if (!sr.isSuccess()) {
                    Application_Log__c objapplicationlog = new Application_Log__c();
			        objapplicationlog.Log_Message__c = (sr.getErrors()[0].getMessage())+ConstantHandler.APPEXCEPTIONCONNECTOR2+sObj.Id;
					objapplicationlog.Object_Name__c = objName;
					objapplicationlog.Snippet_Name__c = className;
					objapplicationlog.RecordTypeId = sfdcRTId;
					objapplicationlog.Send_Email__c = sendEmail;
					if(sObj.id!=null){
						objapplicationlog.Failed_Record_Id__c = sObj.id;	
					}
					if(sr.getErrors() != null && sr.getErrors()[0] != null && sr.getErrors()[0].getFields() != null){
						objapplicationlog.Failed_Record_Id__c = String.join(sr.getErrors()[0].getFields(),ConstantHandler.APPCOMMASEPERATOR);
					}
					if(sr.getErrors() != null && sr.getErrors()[0] != null && sr.getErrors()[0].getStatusCode() != null){
						objapplicationlog.Status_Code__c = String.valueOf(sr.getErrors()[0].getStatusCode());
					}
					lstapplicationlog.add(objapplicationlog);
          		}
             }
			}
                                       
            if (lstapplicationlog.size() > 0) {
                database.insert (lstapplicationlog,false);
            }
    	
    }
     /************************************************************************************************************
        @Name       :   insertApplogfordeleteresult
        @Description:   Method to process the exception
        @Parameters :   DeleteResult: Delete result for Delete DML 
        			   CodeType: Type of code e.g. Trigger, Class, Future Method, Batch Class,Integration
        			   className: Code Snippet Name
        			   ObjName: Object Name on which operation happening
        			   sfdcRTId: Application Log Record type id
        			   sendEmail: Email notification requried or not
        			   lstSObject: List of record which wither get inserted, deleted, updated and upserted     
        @Returns    :   void
    ************************************************************************************************************/
    public static void insertApplogfordeleteresult(Database.DeleteResult[] deleteResult, String codeType,String className, String objName, Boolean sendEmail,List< sObject > lstSObject,string sfdcRTId){
    	List < Application_Log__c > lstapplicationlog = new List < Application_Log__c > ();
        if(!lstSObject.isEmpty()){         
            for (Integer i = 0; i < lstSObject.size(); i++) {
                Database.DeleteResult sr = DeleteResult[i];        
				sObject sObj = lstSObject[i];
                if (!sr.isSuccess()) {
                    Application_Log__c objapplicationlog = new Application_Log__c();
			        objapplicationlog.Log_Message__c = (sr.getErrors()[0].getMessage())+ConstantHandler.APPEXCEPTIONCONNECTOR2+sObj.Id;
					objapplicationlog.Object_Name__c = objName;
					objapplicationlog.Snippet_Name__c = className;
					objapplicationlog.RecordTypeId = sfdcRTId;
					objapplicationlog.Send_Email__c = sendEmail;
					if(sObj.id!=null){
						objapplicationlog.Failed_Record_Id__c = sObj.id;	
					}
					
					if(sr.getErrors() != null && sr.getErrors()[0] != null && sr.getErrors()[0].getFields() != null){
						objapplicationlog.Failed_Record_Id__c = String.join(sr.getErrors()[0].getFields(),ConstantHandler.APPCOMMASEPERATOR);
					}
					if(sr.getErrors() != null && sr.getErrors()[0] != null && sr.getErrors()[0].getStatusCode() != null){
						objapplicationlog.Status_Code__c = String.valueOf(sr.getErrors()[0].getStatusCode());
					}
					lstapplicationlog.add(objapplicationlog);
          		}
             }
			}
                                       
            if (lstapplicationlog.size() > 0) {
                database.insert (lstapplicationlog,false);
            }
    	
    }
     /************************************************************************************************************
        Name       :   insertApplogforupsertresult
        Description:   Method to process the exception
        Parameters :   upsertResult: upsert result for upsert DML 
        			   CodeType: Type of code e.g. Trigger, Class, Future Method, Batch Class,Integration
        			   className: Code Snippet Name
        			   ObjName: Object Name on which operation happening
        			   sfdcRTId: Application Log Record type id
        			   sendEmail: Email notification requried or not
        			   lstSObject: List of record which wither get inserted, deleted, updated and upserted    
        Returns    :   void
    ************************************************************************************************************/
    public static void insertApplogforupsertresult(DataBase.UpsertResult[] upsertResult, String codeType,String className, String objName, Boolean sendEmail,List< sObject > lstSObject,string sfdcRTId){
    	List < Application_Log__c > lstapplicationlog = new List < Application_Log__c > ();
        if(!lstSObject.isEmpty()){         
            for (Integer i = 0; i < lstSObject.size(); i++) {
                Database.UpsertResult sr = UpsertResult[i];        
				sObject sObj = lstSObject[i];
                if (!sr.isSuccess()) {
                    Application_Log__c objapplicationlog = new Application_Log__c();
			        objapplicationlog.Log_Message__c = (sr.getErrors()[0].getMessage())+ConstantHandler.APPEXCEPTIONCONNECTOR2+sObj.Id;
					objapplicationlog.Object_Name__c = objName;
					objapplicationlog.Snippet_Name__c = className;
					objapplicationlog.RecordTypeId = sfdcRTId;
					objapplicationlog.Send_Email__c = sendEmail;
					if(sObj.id!=null){
						objapplicationlog.Failed_Record_Id__c = sObj.id;	
					}					
					if(sr.getErrors() != null && sr.getErrors()[0] != null && sr.getErrors()[0].getFields() != null){
						objapplicationlog.Failed_Record_Id__c = String.join(sr.getErrors()[0].getFields(),ConstantHandler.APPCOMMASEPERATOR);
					}
					if(sr.getErrors() != null && sr.getErrors()[0] != null && sr.getErrors()[0].getStatusCode() != null){
						objapplicationlog.Status_Code__c = String.valueOf(sr.getErrors()[0].getStatusCode());
					}
					lstapplicationlog.add(objapplicationlog);
          		}
             }
			}
                                       
            if (lstapplicationlog.size() > 0) {
                database.insert (lstapplicationlog,false);
            }
    	
    }
     /************************************************************************************************************
        Name       :   insertApplogforemailresult
        Description:   Method to process the exception
        Parameters :   Messaging.SendEmailResult[] emailResult, String codeType,String className,String objName,Boolean sendEmail, Recordtypeid
        Returns    :   void
    ************************************************************************************************************/
    public static void insertApplogforemailresult(Messaging.SendEmailResult[] emailResult, String codeType,String className, String objName, Boolean sendEmail,string sfdcRTId){
    	List < Application_Log__c > lstapplicationlog = new List < Application_Log__c > ();
        for (Integer i = 0; i < emailResult.size(); i++) {
                Messaging.SendEmailResult sr = emailResult[i];                
                if (!sr.isSuccess()) {
                    Application_Log__c objapplicationlog = new Application_Log__c();
			        objapplicationlog.Log_Message__c = sr.getErrors()[0].getMessage();
					objapplicationlog.Object_Name__c = objName;
					objapplicationlog.Snippet_Name__c = className;
					objapplicationlog.RecordTypeId = sfdcRTId;
					objapplicationlog.Send_Email__c = sendEmail;
										
					if(sr.getErrors() != null && sr.getErrors()[0] != null && sr.getErrors()[0].getFields() != null){
						objapplicationlog.Failed_Record_Id__c = String.join(sr.getErrors()[0].getFields(),ConstantHandler.APPCOMMASEPERATOR);
					}
					if(sr.getErrors() != null && sr.getErrors()[0] != null && sr.getErrors()[0].getStatusCode() != null){
						objapplicationlog.Status_Code__c = String.valueOf(sr.getErrors()[0].getStatusCode());
					}
					lstapplicationlog.add(objapplicationlog);
          		}
             }
			
                                       
            if (lstapplicationlog.size() > 0) {
               database.insert (lstapplicationlog,false);
            }
    	
    }
    
  
}