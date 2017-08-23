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
        public List<Opportunity_Property__c> oppPropList{get;set;}
        public List<Opportunity> oppName{get;set;}
        public list<MDU_Property__c> props{get;set;}
        public boolean render {get; set;}
        private ApexPages.StandardController controller = null;
        public string SelectedPropId { get; set; }
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
            oppPropList = new list<Opportunity_Property__c>();           
            oppName = [Select id, Name,StageName, Sales_Portfolio_Name__c from Opportunity 
                       where id=: opportunityId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            if(oppName!=null && !oppName.isEmpty()){
                //oppProperty.Opportunity__c = oppName[0].id;
                oppProperty.Opportunity__c = opportunityId;
            }
        }
         
        /*
         * page reference to save opportunity property
         */
        public PageReference doSave(){
            if(props == null || props.IsEmpty()){
             Apexpages.AddMessage(new ApexPages.Message(Apexpages.Severity.Error,'No properties were selected.', ''));
             return null; 
            }
            else if (props.size()>1 && oppName[0].Sales_Portfolio_Name__c == null){
             Apexpages.AddMessage(new ApexPages.Message(Apexpages.Severity.Error,'Portfolio Name required when adding multiple Properties.', ''));
             return null; 
            }
             else{           
             for(MDU_Property__c propName: props){
              Opportunity_Property__c temp = new Opportunity_Property__c();             
              temp.Property__c = propName.Id;
              temp.Opportunity__c = oppProperty.Opportunity__c;
              oppPropList.add(temp);
              }         
              try{
                database.insert(oppPropList, true);
                PageReference page = controller.save();
                page = new PageReference(SLASH+oppName[0].id);
                page.setredirect(true);
                return page;                               
              }
                catch(Exception e){
                system.debug('>>>>>' + e.getMessage());
                if(!e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){ 
                    Apexpages.AddMessage(new ApexPages.Message(Apexpages.Severity.Error,CONTACT_ADMIN_ERROR, '')); 
                }
              }    
              return null;           
           }      
        }
      
        /*
        * Perform Cancel operation on cancel button click
        */
        public PageReference doCancel(){
            PageReference page = controller.cancel();
            page = new PageReference(SLASH+oppName[0].id);
            page.setredirect(true);
            return page;
        }
        
        public void showProps(){
          if(OppProperty.Id_List__c != null){  
            set<MDU_Property__c>propSet = new set<MDU_Property__c>();
            props = new list<MDU_Property__c>();
            string text = OppProperty.Id_List__c;
            list<string> t = text.split(';');
            propSet = new set<MDU_Property__c>([select id, name, Property_type__c, industry_type__c from MDU_Property__c where id IN: t ]);
            if(!propSet.IsEmpty()){
             render = true;
             props.addAll(propSet);            
            }
          }                        
        }
        
      public void RemoveProp(){ 
      if (SelectedPropId == null) {   
         return;
      }          
      Integer j = 0;
      while (j < props.size()){
       if(props.get(j).Id == SelectedPropId){
        props.remove(j);        
       }
       else{
        j++;
       }
      }
     }   
 }