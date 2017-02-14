/**
    * Class Name: PropertyLookupPageController
    * Author: Accenture
    * Date: 06-Feb-2015
    * Requirement: Filtered Lookup
    * Description: Controller for override lookup page to display filtered properties.
    */
    public with sharing class PropertyLookupPageController {
        
        /************Variable Declaration*************/
        public List<MDU_Property__c> property{set; get;}
        private transient List<MDU_Property__c> tempProperty = new List<MDU_Property__c>();
        public String searchText {get;set;}
        public String searchStrTemp{get;set;}
        public String opportunityId {get;set;}
        private transient list<Opportunity_Property__c> primaryOppProperty = new list<Opportunity_Property__c>();
        private transient Set<Id> propertyListToShow = new Set<Id>();
        private static final String LK_ERROR_MSG = 'Please enter at least 3 characters in search';
        private static final String OPP_CLOSED_STATUS = 'Closed Won, Closed Lost';
        private Boolean flag;
        public virtualListCollection Paging {get;set;}
        public List<WrapperProperties> wrapperList{get;set;}  
        private static final Set<String> propTypeInCCTSet = new Set<String>();
        private static final String LKSRCH = 'lksrch';
        private static final String BLANK = '';
        private static final String OPTYID = 'optyId';
        private static final String LKFM = 'lkfm';
        private static final String LKNM = 'lknm';
        private static final String PERCENT = '%';
        private static final Integer PAGE_SIZE = 15;
        private static final Integer SOQL_LIMIT = 400;
        private static final String PROPTYPE_CCT = System.Label.Prop_Lookup_PropTypeInCCT;
        private Set<String> propTypeNotInCCT = new Set<String>();
        private List<String> allPropertyTypeList = new List<String>();
        private Set<Id> propSetID = new Set<Id>();
        private Set<Id> propSetwithOpty = new Set<Id>();
        private Map<Id,Id> propertyOpenOppty = new Map<Id,Id>();         
        /*
        * PropertyLookupPageController is a constructor which is accept lksrch parameter from user
        * Initialization of virtualListCollection() is done and pagination size is set in this method.
        */
        public PropertyLookupPageController(ApexPages.StandardController controller) {
            flag = true;
            searchText = System.currentPageReference().getParameters().get(LKSRCH);
            wrapperList  = new List<WrapperProperties>();
            searchProperties();           
        } 
        
        /*
        * virtualListCollection class is used to initialize WrapperProperties list
        */
        public without sharing class virtualListCollection extends PageableUtil{
            public List<WrapperProperties> wrrprPropList {get;set;}     
            /*
             * getRecordCount() method is used to calculate records stored in wrrprPropList to display.
             */
            public override integer getRecordCount() {
                return (wrrprPropList == null? 0 : wrrprPropList.size());           
            }
        }
               
        /*
        * WrapperProperties class contains only MDU_Property__c instance to get set.
        */
        public without sharing class WrapperProperties {
            public Boolean selected{get;set;}
            public MDU_Property__c propertyWrap{get;set;}  
            /*
            * WrapperProperties for MDU_Property__c
            */
            public WrapperProperties (MDU_Property__c prop) {
                propertyWrap = prop;
                selected = false; 
            }
        }
        
        /*
        * selecting() method is used to select number of records to display.
        */
        public void selecting() {
            // No Action
        }
        
        /*
        * @description: run the search and return the records found. 
        */
        public void searchProperties() {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,LK_ERROR_MSG);
            propertyListToShow = new Set<Id>();
            primaryOppProperty = new list<Opportunity_Property__c>();
            property = new List<MDU_Property__c>();
            String searchString = searchText;
            String searchStrTemp = BLANK;        
            if(String.isBlank(searchString) && !flag){
                Apexpages.AddMessage(myMsg);
            }
            else if(!String.isBlank(searchString) && searchString.length()<3){
                Apexpages.AddMessage(myMsg);  
            }
            else if(!String.isBlank(searchString)) {
                flag = false;
                searchStrTemp = searchString;
                //searchStrTemp = String.escapeSingleQuotes(searchString); // Required only for Dynamic query
                searchStrTemp= searchStrTemp.replaceAll('%', '\\%').trim();
                searchStrTemp= searchStrTemp.replaceAll('\\*', '').trim();
            }
            opportunityId = System.currentPageReference().getParameters().get(OPTYID);
            try{        
                primaryOppProperty = [select id, Property__c,Primary_Property__c, Property__r.Property_Type__c, Property__r.Name,Property__r.Industry_Type__c, Property__r.Number_of_Units__c from Opportunity_Property__c
                                      where Opportunity__c =: opportunityId AND Primary_Property__c = true LIMIT 1]; 
                if(!primaryOppProperty.isEmpty()) {                         
                    if(primaryOppProperty[0].Property__r.Property_Type__c != null && primaryOppProperty[0].Property__r.Industry_Type__c != null ) { 
                        for(String str : PROPTYPE_CCT.split(';')){
                            propTypeInCCTSet.add(str.trim());
                        }                   
                        if(propTypeInCCTSet.contains(primaryOppProperty[0].Property__r.Property_Type__c)) {
                            tempProperty = [select Property_Type__c,Name,Industry_Type__c,Number_of_Units__c,Property_Region__c,City__c,Address__c
                                            from MDU_Property__c where Property_Type__c IN: propTypeInCCTSet AND 
                                            Industry_Type__c = :primaryOppProperty[0].Property__r.Industry_Type__c AND 
                                            Name LIKE: PERCENT+searchStrTemp +PERCENT
                                            LIMIT: SOQL_LIMIT ];                                       
                        }
                        else {
                            Schema.DescribeFieldResult fieldResult = MDU_Property__c.Property_Type__c.getDescribe();
                            List<Schema.PicklistEntry> picklistVal = fieldResult.getPicklistValues();
                            for( Schema.PicklistEntry picklist : picklistVal) {
                                allPropertyTypeList.add(picklist.getValue());   
                            }
                            for(String str: allPropertyTypeList) {
                                if(!propTypeInCCTSet.contains(str)){
                                    propTypeNotInCCT.add(str);
                                }
                            }   
                            if(!propTypeNotInCCT.isEmpty()) {
                                tempProperty = [select Property_Type__c,Name,Industry_Type__c,Number_of_Units__c,Property_Region__c,City__c,Address__c from MDU_Property__c where Property_Type__c IN: propTypeNotInCCT AND Industry_Type__c = :primaryOppProperty[0].Property__r.Industry_Type__c 
                                AND Name LIKE: PERCENT+searchStrTemp +PERCENT LIMIT: SOQL_LIMIT];                                
                            }
                        }              
                    }
                }
                else {               
                    tempProperty = [select id,Property_Type__c,Name,Industry_Type__c,Number_of_Units__c,Property_Region__c,City__c,Address__c
                                    from MDU_Property__c WHERE Name LIKE: PERCENT+searchStrTemp+PERCENT 
                                    LIMIT: SOQL_LIMIT];                   
                }
                if(!tempProperty.isEmpty()) {
                    for(MDU_Property__c prop: tempProperty) {           
                        propSetID.add(prop.id);               
                    }   
                    if(!propSetID.isEmpty()){
                        for(Opportunity_Property__c oppPropInst: [select Id,Opportunity__c,Opportunity__r.StageName,Property__c,
                                                                    Property__r.Property_Type__c from Opportunity_Property__c 
                                                                    where Property__c IN: propSetID
                                                                    LIMIT : SOQL_LIMIT]) {
                    
                            if(oppPropInst.Property__r.Property_Type__c != null || oppPropInst.Property__r.Property_Type__c != ''){
                                if(oppPropInst.Opportunity__c != null){
                                    if(!OPP_CLOSED_STATUS.containsIgnoreCase(oppPropInst.Opportunity__r.StageName)) {
                                        propertyOpenOppty.put(oppPropInst.Property__c, oppPropInst.Opportunity__c);                         
                                    }                          
                                    propSetwithOpty.add(oppPropInst.Property__c);                         
                                }
                            }
                        }   
                    }        
                    for(Id tempID : propSetID){
                        if(!propSetwithOpty.contains(tempID)){
                            propertyListToShow.add(tempID);                 
                        }
                        else{
                            if(!propertyOpenOppty.containsKey(tempID)){
                                propertyListToShow.add(tempID);
                            }
                        }
                    }       
                    if(propertyListToShow != null && !propertyListToShow.isEmpty()) {
                        wrapperList  = new List<WrapperProperties>();
                        for(MDU_Property__c prop: tempProperty ) {
                            if(propertyListToShow.contains(prop.Id)){
                                property.add(prop);
                                wrapperList.add(new WrapperProperties(prop));                      
                            }
                        }               
                    }
                }           
            }catch(System.QueryException e) {
                Apexpages.AddMessage(new ApexPages.Message(ApexPages.Severity.WARNING,e.getMessage()));
            }      
            Paging = new virtualListCollection();
            Paging.PageSize = PAGE_SIZE;
            Paging.wrrprPropList = wrapperList ;
        }

        /**
        * @description: used by the visual force page to send the link to the right Dom element
        * @return: String returns URL lkfm(form) parameter value
        */
        public String getFormTag() {
            return System.currentPageReference().getParameters().get(LKFM);       
        }

        /**
        * @description: send by the visual force page to send the link to the right Dom element for the text box
        * @return: String returns URL lknm parameter value
        */
        public String getTextBox() {
            return System.currentPageReference().getParameters().get(LKNM);       
        }
    }