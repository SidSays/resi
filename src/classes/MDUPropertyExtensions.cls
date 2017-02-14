/**********************************************************
* Class Name: MDUPropertyExtensions
* Author: Ashish Sonawane, Accenture
* Date: 02-Jan-2015 
* Requirement # Request Id : 
* Description: This extension class use save and edit mdu property records on MDUPropertyPage page.
* Last Modified by:
***********************************************************/
public with sharing class MDUPropertyExtensions{
  
    /* Properties */
    public String MDUState{get;set;}
    public String ownerAccountState{get;set;}
    public String manageCompAccountState{get;set;}
    public String developerAccountState{get;set;}
    public String county {get;set;}
    public String Franchise{get;set;}
    public MDU_Property__c property{get;set;}
    public String francTitleNew{get;set;} 
    public Map<id, string> countyMap{get;set;}
    public Account propertyOwner {get; set;}
    public Account propertyManageComp {get; set;}
    public Account propertyDeveloper {get; set;}
    public Boolean ownerEdit {get; set;}
    public Boolean manageCompanyEdit {get; set;}
    public Boolean developerEdit {get; set;}
    public Boolean profileReadOnlyAccess {get; set;}
    private static final string LABEL_NAME_SPLIT = ';';
    public boolean fieldException = false;
    /* Data Member */
    private static final string OBJECT_NAME = 'MDU_Property__c';
    private static final string EDIT_TRUE = 'true';
    private static final string EDIT_FALSE = 'false';
    //private static final string PROPERTY_OWNER_ACCOUNT = 'Property Owner';
    //private static final string PROPERTY_MANAGEMENT_COMP_ACCOUNT = 'Property Management Company';
    //private static final string PROPERTY_DEVELOPER_ACCOUNT = 'Developer';
    private static final string ACCOUNT_OBJECT_NAME = 'Account';
    private static final string QUERY_STRING_PROPERTY_ID_KEY = 'id';
    private static final string DEFAULT_PICKLIST_LABEL = 'None';
    private static final string DEFAULT_PICKLIST_VALUE = '--- None ---';
    private static final string BACK_SLASH_FOR_URL = '/';
    private static final string FRANCHISE_LEGALENTITY_SEPARATE = '-';
    private static final string FIELD_EXCEPTION_MESSAGE = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
    private boolean bindPicklist;
    private boolean refreshCountyPick; 
    private boolean refreshFranchisePick; 

    private String editMode;
    private Map<String, String> franchiseIDTitle = new Map<String, String>();
    private ApexPages.StandardController controller = null;
    MduPropertyExtensionsController instantMduPropertyExtensionsController = new MduPropertyExtensionsController();
    
    /* Constructor to initialise controller object */
    public MduPropertyExtensions(ApexPages.StandardController controller) {        
        this.controller = controller;   
        /*
        * Author: Sagar Gurav.
        * Description: Car edit access disabled as part of US516870
        */
        profileReadOnlyAccess =  false;     
        if(CAR_Profile_Redirect__c.getValues(UserInfo.getProfileId()) != null) {
            if(CAR_Profile_Redirect__c.getValues(UserInfo.getProfileId()).Disable_Edit_Access__c) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,system.label.CAR_PropertyEdit_Err));
                profileReadOnlyAccess =  true;
            }       
        }
        // US516870 ends here..
        String propertyID = apexpages.currentpage().getparameters().get(QUERY_STRING_PROPERTY_ID_KEY);
        countyMap = new Map<id, string>();
       if(propertyID != null){
           editMode = EDIT_TRUE;
       } else{
           editMode = EDIT_FALSE;
       }
       if(EDIT_TRUE.equalsIgnoreCase(editMode)) {
           //Select query at edit mode to retrieve all fields associated with record id           
           property = [ select  Address__c, Property_Alias__c, Property_Division__c, Franchise_New__c, Franchise_Legal_ID__c,
                        Name , Property_Region__c, Address_2__c, Property_Area__c , City__c , System__c,PostalCode__c,
                        Node__c, MDU_State__c, Franchise_Tax_No__c , County__c, Contract_Status__c, Development__c,
                        Active_Contract_Sub_Status__c, Account_Manager__c, Segmentation__c,Agent__c, Public_Easement__c,
                        Industry_Type__c, Bulk_Upgradeable__c, Risk_Status__c, Billing_Corp__c,
                        Property_Grade__c, Complex_Code__c, Structure_Type__c , House_Misc_Code__c, Buildings__c,Prin__c,
                        Number_of_Units__c, Wiring_Comments__c,sys__c, Owner_Account__c, Management_Company__c, Developer__c,                      
                        Comcast_Video_Serviced__c, Video_Billing_Type__c, Video_Contract_Status__c, Comcast_Voice_Serviced__c,
                        Voice_Billing_Type__c, Voice_Contract_Status__c, Comcast_Data_Serviced__c, Data_Billing_Type__c,Data_Contract_Status__c,
                        Disconnect_Date__c, MDU_Disconnect_Reason__c, Competitor__c, ROE_or_Bulk__c, Property_Rating__c, Effective_Date__c,
                        Competitor_Comments__c, Expiration_Date__c, Property_Type__c, Property_Comments__c, Corporate__c, Bulk_Status__c ,Delete_Reason__c,
                        Assigned_CAR__c, Assigned_DSR__c, Contact_Owner__c, Contact_Management_Company__c,Coffee_Vendor_Name__c,Coffee_Vendor_on_Site__c, Contact_Developer__c, Contact_Name__c, Contact_Phone__c, Contact_Email__c, Contact_Title__c, Contact_Fax__c, Module__c from MDU_Property__c where id =: propertyID 
                      ] ;           
           MDUState = property.MDU_State__c;
           
                              
            refreshCountyPick = false;       
            refreshFranchisePick = false;  
            propertyOwner = new Account();
            propertyManageComp = new Account();
            propertyDeveloper = new Account();
            //get account Information 
            Set<Id> accountIds = new Set<Id>();
            if(property.Owner_Account__c!=null){
                accountIds.add(property.Owner_Account__c);
            }
            if(property.Management_Company__c!=null){
                accountIds.add(property.Management_Company__c);
            }
            if(property.Developer__c!=null){
                accountIds.add(property.Developer__c);
            }
            ownerEdit = true;
            manageCompanyEdit = true;
            developerEdit = true;
           
           List<Account> accountList = [ Select Id, Name, Phone__c, Street__c, City__c, MDU_State__c
                                                 , Zip_Code__c, Country__c, Name__c,ParentId From Account Where Id In: accountIds LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ];
            for(Account accountTemp : accountList){
                if(property.Owner_Account__c == accountTemp.Id){
                    propertyOwner = accountTemp;
                    propertyOwner.Name__c = propertyOwner.Name;
                    ownerAccountState = accountTemp.MDU_State__c;
                    ownerEdit = false;
                }else{//future code
                }

                if(property.Management_Company__c == accountTemp.Id){
                    propertyManageComp = accountTemp;
                    propertyManageComp.Name__c = propertyManageComp.Name;
                    manageCompAccountState = accountTemp.MDU_State__c;
                    manageCompanyEdit = false;
                }else{//future code
                }

                if(property.Developer__c == accountTemp.Id){
                    propertyDeveloper = accountTemp;
                    propertyDeveloper.Name__c = propertyDeveloper.Name;
                    developerAccountState = accountTemp.MDU_State__c;
                    developerEdit = false;
                }else{//future code
                }
            }
       }
       else {
            property = new MDU_Property__c();
            propertyOwner = new Account();          
            propertyManageComp = new Account();
            propertyDeveloper = new Account();   
            String developerID = apexpages.currentpage().getparameters().get('developerId');
            String managmentID = apexpages.currentpage().getparameters().get('managmentId');
            String ownerID = apexpages.currentpage().getparameters().get('ownerId');
            if(!string.isBlank(ownerID)){
                property.Owner_Account__c = ownerID;
                readOwner();
            }
            if(!string.isBlank(developerID)){
                property.Developer__c = developerID;
                readDeveloper();
            }
            if(!string.isBlank(managmentID)){
                property.Management_Company__c = managmentID;
                readManagComp();
            }                       
            ownerEdit = true;
            manageCompanyEdit = true;
            developerEdit = true;         
        }    
        
        //Create List of Mdu Property Record Type List
        String labelName = System.Label.XfinityPropertyRecordType;  
        List<String> recordTypeSet = new List<String>();
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(LABEL_NAME_SPLIT)){
                recordTypeSet.add(Schema.SObjectType.MDU_Property__c.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }  
        
        property.recordTypeID =  recordTypeSet[0] ;    
        bindPicklist = editMode == EDIT_TRUE ? true:false;
    }     
  
    /*
    * @Description: Action method to perform action associated with action support component for state pick list
    * @Author: Ashish Sonawane, Accenture
    * @Date: 02-Jan-2015
    * @Param:  none
    * @Return:void
    */           
    public void BindCountyPick() {   
        try{  
            MDUState = property.MDU_State__c;
            bindPicklist = true;                 
            if(EDIT_TRUE.equalsIgnoreCase(editMode)){
                refreshCountyPick = true;
                refreshFranchisePick = false;                
            }else{
               //future code
            }
            refreshFranchisePick = false; 
        } catch(Exception e){
           system.debug('>>>>> Following Errors Occured :'+e.getMessage());            
        }                 
    }
  
    /*
    * @Description: Action method written to perform action associated with action support component for county picklist
    * @Author: Ashish Sonawanae, Accenture
    * @Date: 02-Jan-2015
    * @Param:  none
    * @Return:void
    */     
    public void BindFranchisePick() {     
        try{
            if(EDIT_TRUE.equalsIgnoreCase(editMode)){
                refreshFranchisePick = false; 
            }  
            property.County__c = county;             
        } catch(Exception e){
           system.debug('>>>>> Following Errors Occured :'+e.getMessage());            
        }     
    }        
     
    /*
    * @Description: Return List of States to bind custom state pick list
    * @Author: Ashish Sonawane, Accenture
    * @Date: 02-Jan-2015
    * @Param:  none
    * @Return: List<SelectOption> for States
    */        
    public List<SelectOption> getMDUStates() {    
       try{       
            List<SelectOption> options =  new List<SelectOption>();    
            options.add(new selectOption(DEFAULT_PICKLIST_LABEL , DEFAULT_PICKLIST_VALUE));            
            Schema.DescribeFieldResult fieldResult = MDU_Property__c.MDU_State__c.getDescribe();    
            List<Schema.picklistEntry> statePickList = fieldResult.getPicklistValues();    
            for(Schema.picklistEntry pickListFieldAndValue : statePickList){                
                options.add(new selectOption(pickListFieldAndValue.getLabel(),pickListFieldAndValue.getValue()));         
            }    
            return Options;
        } catch(Exception e){
            system.debug('>>>>> Following Errors Occured :'+e.getMessage());
            return null;
        }           
    }   
    
    /*
    * @Description: Return List of Counties to bind custom counties pick list
    * @Author: Ashish Sonawane, Accenture
    * @Date: 02-Jan-2015
    * @Param:  none
    * @Return: List<SelectOption> for counties
    */    
    public List<SelectOption> getCounties() {        
        try{    
            List<SelectOption> options =  new List<SelectOption>();              
            options.add(new selectOption(DEFAULT_PICKLIST_LABEL, DEFAULT_PICKLIST_VALUE));            
            if(MDUState!= NULL && bindPicklist){           
                if(EDIT_TRUE.equalsIgnoreCase(editMode)  && !refreshCountyPick){                               
                    county = property.County__c;                                        
                }else{//future code
                }                         
                List<string> listOfCounties = instantMduPropertyExtensionsController.getCountyBaseOnState(MDUState);           
                for(string countyString : listOfCounties){                
                    options.add(new selectOption(countyString,countyString));                    
                }
            }
                    
            return options;
        } catch(Exception e){        
            system.debug('>>>>> Following Errors Occured :'+e.getMessage());
            return null;
        }      
    }
     
    /*
    * @Description: Return List of Franchises to bind custom franchise pick list
    * @Author: Ashish Sonawane, Accenture
    * @Date: 02-Jan-2015
    * @Param:  none
    * @Return: List<SelectOption> for Franchise
    */  
    public List<SelectOption> getFranchisies() {
        try {              
            if(!fieldException){
                Franchise = DEFAULT_PICKLIST_LABEL;  
            }            
            franchiseIDTitle = new Map<String, String>();           
            List<SelectOption> options =  new List<SelectOption>();    
            options.add(new selectOption(DEFAULT_PICKLIST_LABEL,DEFAULT_PICKLIST_VALUE));         
            if(bindPicklist){   
                
                if(EDIT_TRUE.equalsIgnoreCase(editMode) && !refreshFranchisePick && !fieldException){                                                  
                    franchiseIDTitle.put(property.Franchise_New__c, property.Franchise_Legal_ID__c);    
                    Franchise = property.Franchise_New__c;                  
                }else{//future code
                }   
                List<Franchise__c> franchiseList = new List<Franchise__c>();                                                          
                if(!refreshFranchisePick){                          
                    franchiseList = instantMduPropertyExtensionsController.getFranchiseBaseOnStateAndCounty(MDUState,county);
                }else{                                 
                    Franchise = DEFAULT_PICKLIST_LABEL;
                    franchiseIDTitle = new Map<String, String>();
                }
                for(Franchise__c franchiseTemp : franchiseList){
                    options.add(new selectOption(franchiseTemp.Franchise_Title__c,franchiseTemp.Franchise_Title__c));
                    franchiseIDTitle.put(franchiseTemp.Franchise_Title__c, franchiseTemp.ID + FRANCHISE_LEGALENTITY_SEPARATE + franchiseTemp.Legal_Entity__c );
                }                           
            }else{//future code
            }                   
            return options;
        } catch(Exception e){
           system.debug('>>>>> Following Errors Occured :'+e.getMessage());
           return null;
        }       
    }
   /*
    public PageReference EditErrMsgAccess(){
          if(CAR_Profile_Redirect__c.getValues(UserInfo.getProfileId()) != null) {
                if(CAR_Profile_Redirect__c.getValues(UserInfo.getProfileId()).Disable_Edit_Access__c) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,system.label.CAR_PropertyEdit_Err));
                }
                system.debug('#page#'+page);
            }
        Pagereference page = new PageReference(BACK_SLASH_FOR_URL+property.id);  
    }
   */
    /*
    * @Description: Method execute save action for save button and perform insert/update operation then return detail page for MDU Property record
    * @Author: Ashish Sonawane, Accenture
    * @Date: 02-Jan-2015
    * @Param:  none
    * @Return: PageReference
    * @Updated : to save account Information if not already Created
    */     
    public PageReference save(){
        
        Map<String, Id> accIdAccTypeMap = new Map<String, Id>();
        // Create a save-point while Account Exception throw
        Savepoint sp = Database.setSavepoint();
        try { 
                                 
            ///Get account Record Type XfinityAccountRecordType
            List<String> recordTypeIds = new List<String>();      
            String labelName = System.Label.XfinityAccountRecordType;  
            if(!string.IsBlank(labelName)){
                for(String str : labelName.split(LABEL_NAME_SPLIT)){
                    recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId());
                }
            }
             
            if(propertyOwner != null && !string.isBlank(propertyOwner.Name__c)){
                propertyOwner.Name = propertyOwner.Name__c;              
                propertyOwner.RecordTypeId = recordTypeIds[0];
                propertyOwner.MDU_State__c = ownerAccountState=='None'?null:ownerAccountState;

                upsert propertyOwner; 
                property.Owner_Account__c = propertyOwner.Id;
            }
            
            if(propertyManageComp != null && !string.isBlank(propertyManageComp.Name__c)){
                propertyManageComp.Name = propertyManageComp.Name__c;                
                propertyManageComp.RecordTypeId = recordTypeIds[0];
                propertyManageComp.MDU_State__c = manageCompAccountState;
              
                upsert propertyManageComp;

                property.Management_Company__c= propertyManageComp.Id;
            }
            
            if(propertyDeveloper != null && !string.isBlank(propertyDeveloper.Name__c)){
                propertyDeveloper.Name = propertyDeveloper.Name__c;               
                propertyDeveloper.RecordTypeId = recordTypeIds[0];
                propertyDeveloper.MDU_State__c = developerAccountState;
                
                upsert propertyDeveloper; 
                property.Developer__c = propertyDeveloper.Id;
            }
            
            property.MDU_State__c = MDUState;
            property.County__c = county=='None'?'':county;          
            property.Franchise_New__c = Franchise=='None'?'':Franchise;                
            property.Franchise_Legal_ID__c = franchiseIDTitle.get(Franchise);
            Database.upsert(property);    
            PageReference page = new PageReference(BACK_SLASH_FOR_URL+property.id);              
            system.debug('#page outside#'+page);
            return page ;
        }
        catch(Exception e) {         
            ApexPages.addMessages(e);
            system.debug('>>>>> Following Errors Occured :'+e.getMessage());
            String excMessage = e.getMessage();
            if(!String.isBlank(excMessage) && excMessage.contains(FIELD_EXCEPTION_MESSAGE)){ 
                fieldException = true;            
            }
            Database.rollback(sp);
            return null;    
        }
    }
    
    
    
    /*
    * @Description: To get the Owner Account Information on change
    * @Author: Abhishek Mathur, Accenture
    * @Date: 12-Feb-2015
    * @Param:  none
    * @Return: Void
    */  
    public void readOwner() {
        try{
           if(property.Owner_Account__c != null){
                propertyOwner = [ Select Id, Name, Phone__c, Street__c, City__c, MDU_State__c,
                                         Zip_Code__c, Country__c, Name__c,ParentId From Account 
                                        Where Id = : property.Owner_Account__c LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                propertyOwner.Name__c = propertyOwner.Name;
                ownerAccountState = propertyOwner.MDU_State__c;                 
                ownerEdit = false;           
            } else{
                propertyOwner = new Account();     
                ownerAccountState = null;                 
                ownerEdit = false;                   
            }
        } catch(Exception e) {         
            system.debug('>>>>> Following Errors Occured :'+e.getMessage());
        } 
    }

    /*
    * @Description: To get the Management Company Account Information on change
    * @Author: Abhishek Mathur, Accenture
    * @Date: 12-Feb-2015
    * @Param:  none
    * @Return: Void
    */  
    public void readManagComp(){
        try{
            if(property.Management_Company__c != null){
              propertyManageComp = [ Select Id, Name, Phone__c, Street__c, City__c, MDU_State__c,
                                          Zip_Code__c, Country__c, Name__c,ParentId From Account 
                                          Where Id = : property.Management_Company__c LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
              propertyManageComp.Name__c = propertyManageComp.Name;
              manageCompAccountState = propertyManageComp.MDU_State__c;
              manageCompanyEdit = false;           
            } else{
              propertyManageComp = new Account();
              manageCompAccountState = null;
              manageCompanyEdit = false;  
            }
        }catch(Exception e){         
                system.debug('>>>>> Following Errors Occured :'+e.getMessage());
        }       
    }
    
    /*
    * @Description: To get the Developer Account Information on change
    * @Author: Abhishek Mathur, Accenture
    * @Date: 12-Feb-2015
    * @Param:  none
    * @Return: Void
    */  
    public void readDeveloper() {
        try{
            if(property.Developer__c != null){
                propertyDeveloper = [ Select Id, Name, Phone__c, Street__c, City__c, MDU_State__c, Zip_Code__c, 
                                             Country__c, Name__c,ParentId From Account Where Id = : property.Developer__c
                                             LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ];
                propertyDeveloper.Name__c = propertyDeveloper.Name;
                developerAccountState = propertyDeveloper.MDU_State__c;
                developerEdit = false;
                system.debug('>>>>2' + propertyDeveloper);
            } else{
                propertyDeveloper = new Account();
                developerAccountState = null;
                developerEdit = false;
            }
        } catch(Exception e){         
            system.debug('>>>>> Following Errors Occured :'+e.getMessage());
        }  
    }   
}