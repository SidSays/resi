/******************************************************************************************************************
 * Author     : Malay Desai, Accenture
 * Description: Contains AuraEnabled methods for support "Knock" from SF1 App
 * @Last Modified By: Malay Desai, Accenture
 * @User Story: US1139040	DSM to SF1: Actions - Knock and Log Knock Location (Dev Continued + TQM),
 * @Last Modified Date: 2-Aug-2017  
 ********************************************************************************************************************/

public class KnockQuickActionController {
   private static final String KNOCK_RECORDTYPE = Schema.SObjectType.Task.getRecordTypeInfosByName().get(Label.Knock).getRecordTypeId();
   private static final String STATUS_COMPLETED = 'Completed' ;
   private static final String PRIORITY_NORMAL  = 'Normal';
    
    @AuraEnabled
    public static PicklistWrapper getAllPicklistValues(){
			List<String> dpOptions  = new List<String>();
            List<String> vcoptions  = new List<String>();
            List<String> icoptions  = new List<String>();
            List<String> xhoptions  = new List<String>();
            List<String> pcoptions  = new List<String>();
            List<String> stoptions  = new List<String>();
            List<String> nmroptions = new List<String>();
            List<String> rroptions  = new List<String>();
            
            for (Schema.PicklistEntry ops: Task.Disposition__c.getDescribe().getPicklistValues()) {
                dpOptions.add(ops.getLabel());
            }
            for (Schema.PicklistEntry ops: Task.Video_Competitor__c.getDescribe().getPicklistValues()) {
                vcOptions.add(ops.getLabel());
            }
            for (Schema.PicklistEntry ops: Task.Internet_Competitor__c.getDescribe().getPicklistValues()) {
                icOptions.add(ops.getLabel());
            }
            for (Schema.PicklistEntry ops: Task.Phone_Competitor__c.getDescribe().getPicklistValues()) {
                pcOptions.add(ops.getLabel());
            }
            for (Schema.PicklistEntry ops: Task.Home_Security_Competitor__c.getDescribe().getPicklistValues()) {
                xhOptions.add(ops.getLabel());
            }
            for (Schema.PicklistEntry ops: Task.Sales_Type__c.getDescribe().getPicklistValues()) {
                stOptions.add(ops.getLabel());
            }
            for (Schema.PicklistEntry ops: Task.Non_Marketable_Reason__c.getDescribe().getPicklistValues()) {
                nmrOptions.add(ops.getLabel());
            }
            for (Schema.PicklistEntry ops: Task.Rejected_Reason__c.getDescribe().getPicklistValues()) {
                rrOptions.add(ops.getLabel());
            }
            return new PicklistWrapper(dpOptions,vcOptions,icOptions,pcOptions,xhOptions,stOptions,nmrOptions,rroptions);
    }
    
    @AuraEnabled
    public static TaskWrapper createNewKnock
        (Id addrId, Decimal lat, Decimal longi, String disposition,String vc, String ic, 
         String pc, String xh, String st, String nm, String vcdate,String icdate, 
         String pcdate, String xhdate, Boolean vcsold,Boolean icsold, Boolean pcsold, 
         Boolean xhsold, String rr, String propEvt, String evtName, String comments){
            try{
                Task knock = new Task();
                knock.WhatId = addrId;
                knock.Disposition__c = disposition;
                knock.Disposition_Latitude__c = lat;
                knock.Disposition_Longitude__c = longi;
                knock.RecordTypeId = KNOCK_RECORDTYPE;
                knock.OwnerId = UserInfo.getUserId();
                knock.Subject = disposition+system.today();
                knock.Video_Competitor__c = vc;
                knock.Video_Contract_End__c = 
                    (String.isBlank(vcdate))? null: Date.parse(vcdate.split('-')[1]+'/'+vcdate.split('-')[2]+'/'+ vcdate.split('-')[0]);
                knock.Video_Sold__c = vcsold;
                knock.Internet_Competitor__c = ic;
                knock.Internet_Contract_End__c = 
                    (String.isBlank(icdate))? null: Date.parse(icdate.split('-')[1]+'/'+icdate.split('-')[2]+'/'+ icdate.split('-')[0]);
                knock.HSI_Sold__c = icsold;
                knock.Phone_Competitor__c = pc;
                knock.Phone_Contract_End__c = 
                    (String.isBlank(pcdate))? null: Date.parse(pcdate.split('-')[1]+'/'+pcdate.split('-')[2]+'/'+ pcdate.split('-')[0]);
                knock.Voice_Sold__c = pcsold;
                knock.Home_Security_Competitor__c = xh;
                knock.Security_Contract_End__c = 
                    (String.isBlank(xhdate))? null: Date.parse(xhdate.split('-')[1]+'/'+xhdate.split('-')[2]+'/'+ xhdate.split('-')[0]);
                knock.XH_Sold__c = xhsold;
                knock.Sales_Type__c = st;
                knock.Non_Marketable_Reason__c = nm;
                
                knock.Property_Event__c = propEvt;
                knock.Event_Name_or_Number__c = evtName;
                knock.Rejected_Reason__c = rr;
                knock.Description = comments;
                
                knock.Status = STATUS_COMPLETED;
                knock.Priority = PRIORITY_NORMAL;
                
                insert knock;
                return new TaskWrapper(true, null,knock);
            }catch(Exception ex){
                return new TaskWrapper(false, ex.getMessage().substringAfterLast(',').substringBefore('.'),null);
            }
        }

    public Class PicklistWrapper{
        @AuraEnabled
        public List<String> dpoptions;
        @AuraEnabled
        public List<String> vcoptions;
        @AuraEnabled
        public List<String> icoptions;
        @AuraEnabled
        public List<String> pcoptions;
        @AuraEnabled
        public List<String> xhoptions;
        @AuraEnabled
        public List<String> stoptions;
        @AuraEnabled
        public List<String> nmroptions;
        @AuraEnabled
        public List<String> rroptions;
        
        public PicklistWrapper(List<String> dpoptions,List<String> vcoptions,
                               List<String> icoptions,List<String> pcoptions,
                               List<String> xhoptions,List<String> stoptions,
                               List<String> nmroptions,List<String> rroptions){
              this.dpoptions  = dpoptions;
              this.vcoptions  = vcoptions;
              this.icoptions  = icoptions;
              this.pcoptions  = pcoptions;
              this.xhoptions  = xhoptions;
              this.stoptions  = stoptions;
              this.nmroptions = nmroptions;
              this.rroptions  = rroptions;
        }
    }
     
    public Class TaskWrapper {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String Error;
        @AuraEnabled
        public Task knock;
       
        public TaskWrapper(Boolean isSuccess, String Error, Task knock){            
            this.isSuccess = isSuccess;
            this.Error = Error;
            this.knock = knock;
        } 
    }
}