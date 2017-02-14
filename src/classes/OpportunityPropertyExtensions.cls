/**********************************************************
    * Class Name: MduPropertyExtensionsController
    * Author: Sagar Gurav, Accenture
    * Date: 02-Jan-2015 
    * Requirement # Request Id : 
    * Description: This extension class for OpportunityPropertyPage.
    * Last Modified by:
    ***********************************************************/
    public with sharing class OpportunityPropertyExtensions{

        public Opportunity_Property__c oppProperty{get;set;}
        public List<Opportunity> oppName{get;set;}
        private ApexPages.StandardController controller = null;
        private static final String OPPID = 'oppId';
        private static final String SLASH = '/';
        private static final String CONTACT_ADMIN_ERROR = 'Error occoured, please contact your system administrator.';
        private String opportunityId = apexpages.currentpage().getparameters().get(OPPID);
        
        /*
         * Constructor is used to track opportunity name on opportunity lookup in opporutnityPropertyPage.
         */
        public OpportunityPropertyExtensions(ApexPages.StandardController controller) {        
            this.controller = controller;  
            oppProperty = new Opportunity_Property__c();           
            oppName = [Select id, Name,StageName from Opportunity 
                       where id=: opportunityId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            if(oppName!=null && !oppName.isEmpty()){
                oppProperty.Opportunity__c = oppName[0].id;
            }
        }   
        
        /*
         * page reference to save opportunity property
         */
        public PageReference doSave(){
             
            try {
                database.insert(oppProperty, true);  
                PageReference page = controller.save();
                page = new PageReference(SLASH+oppName[0].id);
                page.setredirect(true);
                return page ;
            }
            catch(Exception e){
                system.debug('>>>>>' + e.getMessage());
                if(!e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){ 
                    Apexpages.AddMessage(new ApexPages.Message(Apexpages.Severity.Error,CONTACT_ADMIN_ERROR, '')); 
                }
                return null;
            }
        }
      
        /*
        * Perform Cancel operation on cancel button click
        */
        public PageReference doCancel()
        {
            PageReference page = controller.cancel();
            page = new PageReference(SLASH+oppName[0].id);
            page.setredirect(true);
            return page;
        }
        
    }