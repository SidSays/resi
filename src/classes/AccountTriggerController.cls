/**************************************************************************************************************************************
 * Author          : Animesh Datta
 * Date            : 3-Nov-2016
 * Description     : End Active Store Visit Automatically if Store is Changed 
 * User Story      : US767907
 * History Version : 1.0
 * PROJECT         : SalesSpace Indirect 
 * Updated By      : 
 * Updated By      : 
**************************************************************************************************************************************/
public without sharing class AccountTriggerController {
    
    /**    
    * @Description: Business logic to mark active store visit as completed when store owner is changed.
    * @Author: Animesh Datta, Accenture    
    * @Date: 3-Nov-2015 
    * @Param:  Trigger.New, Trigger.OldMap    
    * @Return: None */ 
    
    public static void endActiveStoreVisitOwnerChage(List<Account> triggerNew, Map<Id, Account> triggerOldMap) {
        
        //Declared variables
        String strRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Store').getRecordTypeId();
        List<Store_Visit__c> storeVisitList = new List<Store_Visit__c>();
        Map<Id,Store_Visit__c> accToStoreVisitMap = new Map<Id,Store_Visit__c>();
        List<Store_Visit__c> listStrVisit;
        Set<ID> accIdSet = new Set<ID>();
        
        try{
            for(Account accn: triggerNew) {
                Account oldAcc = (Account)Trigger.oldMap.get(accn.Id);
                if(strRecordtypeId != null && strRecordtypeId.equalsIgnoreCase(accn.RecordTypeId) && oldAcc.OwnerID != accn.OwnerId) {//check for Recordtype is 'Store' and Store owner is changed or not
                    accIdSet.add(accn.Id);
                }
            }
            if(!accIdSet.isEmpty()) {// go inside if store owner is changed
                storeVisitList = [SELECT Id,Store__c,Store__r.RecordTypeId,Is_Auto_Check_Out__c,Store__r.OwnerId,visit_cutoff_datetime__c,End_Date_Time__c FROM Store_Visit__c WHERE End_Date_Time__c=null AND visit_cutoff_datetime__c!= null AND Store__c In: accIdSet];
                if(!storeVisitList.isEmpty()){

                    for(Store_Visit__c storeVisit : storeVisitList){
                        accToStoreVisitMap.put(storeVisit.Store__c, storeVisit);
                    }
                    if(!accToStoreVisitMap.isEmpty()){
                        listStrVisit = new List<Store_Visit__c>();
                        for(Store_Visit__c strVisit : accToStoreVisitMap.values()){
                            if(strVisit.visit_cutoff_datetime__c!=null){
                                strVisit.End_Date_Time__c = system.now();//mark visit end time to current date time
                                strVisit.Is_Auto_Check_Out__c = True; //visit has been marked as auto checked out
                                listStrVisit.add(strVisit);
                            }
                        }
                    }
                    if(!listStrVisit.isEmpty()) {
                        Database.update(listStrVisit,false);//update store visit
                    }
                }
            }
        }catch(Exception Ex) {
            System.debug('*****Following Exception has been Occurred*****'+Ex.getMessage());
        }
    }
		/* Need   : Data Transformation Hotfix for Last Install Date field on Account
		   Date   : 02/08/2017
		   Author : Siddharth Sinha
		   Params : Trigger.New
		   Return : None
		   Switch : ClearLastInstallDate (System.label.ClearLastInstallDate)
		   Run On : Before Insert/Update
		*/
		// start of method setAccountLastInstallDate
		 public static void setAccountLastInstallDate(List<Account> triggerNew){
		 /*Logic to see if incoming accounts are having Last Install Date coming prior to 1963 (Comcast Foundation Date).
		   The flag ClearLastInstallDate is a system label that is a on/off switch for this method to execute. Runs only when set as Active. */
         try{
         if(!triggerNew.isEmpty() && System.label.ClearLastInstallDate!= null && System.label.ClearLastInstallDate=='Active' && System.Label.Comcast_Foundation_Date!= null){
            for(Account acctRec: triggerNew){
                if(acctRec.Last_Install_Date__c != null && acctRec.Last_Install_Date__c.year() < Integer.valueof(System.Label.Comcast_Foundation_Date)){
                   acctRec.Last_Install_Date__c = null; // Set the Last Install Date to NULL
                  }
               }
            }
         }
         catch(exception ex){
               system.debug('Class Exception on setting account Last Install Date(for Method setAccountLastInstallDate)='+ex.getmessage());
               }
		 }	   
        // end of method setAccountLastInstallDate
    
}