/*
Created Date : 02-June-2017
US number    : US1112140
Description  : NSO - Web-to-Case for OL Cases - New VF Home Page and Controller for Order Lab Case creation
Author       : Siddharth Sinha
Last modified: Mohan Pudi (US1128342- NSO - Web to Case (force.com site) for Order Lab cases - Reporting field)
*/
    public without sharing class SubmitOrderLabCaseController {
    public Case newcase {get;set;}
    public String errorMessages {get;set;}
    public Boolean isError {get;set;}
    public String firstName {get;set;}
    public String lastName {get;set;}
    public Boolean attachmentsAdded {get;set;}
    public String channelName{get;set;}
    Transient public String contentType1 {get;set;}
    Transient public String contentType2 {get;set;}
    Transient public String contentType3 {get;set;}
    public List<Attachment> AttachmentList = new List<Attachment>();
    Transient public string fileName1{get;set;} 
    Transient public Blob fileBody1{get;set;}
    Transient public string fileName2{get;set;} 
    Transient public Blob fileBody2{get;set;}
    Transient public string fileName3{get;set;} 
    Transient public Blob fileBody3{get;set;}
    public Boolean submitted {get;set;}
    public Boolean reporting {get;set;}
    private static Id parentId {get;set;}
    private String success = system.label.SubmitCaseControllerInfoMessage2;
    private String error = system.label.SubmitCaseControllerInfoMessage3;
    private static final string DML_ERROR = 'Error Occured';
    private static final string TICKET_CATEGORY_REPORTING = 'Reporting';
    private static final string PRODUCT = 'Order Lab/Sales Portal';
    private static final string ERR_MSG = 'All the fields on this form are mandatory to be filled up.';
    private static final string ERR_REPORTING = 'Report Name is mandatory if Ticket Category is selected as Reporting';
    /**
    * @Description: Intitiating the constructor  - gets invoked when a new case is created using this class.
    * @Author: Siddharth Sinha
    * @Date: 02-June-2017
    * @Param: VF page variables
    * @Return: void
    * @LastUpdatedBy : Mohan Pudi(US1128342- Dynamic Reporting field)
    */      
    //Intitiating the constructor  - gets invoked when a new case is created using this class.
    public SubmitOrderLabCaseController() {
        if(ApexPages.currentPage().getParameters().get('CaseId')!=null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,system.label.SubmitCaseControllerInfoMessage1);
            ApexPages.addMessage(myMsg);
            newcase=[Select Id, Requested_For__r.FirstName, Requested_For__r.LastName,AccountNumber__c,
                     OrderID__c,Region__c, Preferred_Email__c, Preferred_Phone__c, Channel__c, Request_Type__c, 
                     Ticket_Category__c, Ticket_Category_II__c, Report_Name__c, Description, Session_ID__c FROM Case 
                     WHERE Id=:ApexPages.currentPage().getParameters().get('CaseId')];
                firstName=newCase.Requested_For__r.FirstName;
                lastName=newCase.Requested_For__r.LastName;
                attachmentsAdded=true;
                submitted = false;
                reporting = false;
            
        }else{
                //Initiate to create a new case in salesforce having Order Lab record type, but do not save the record yet.
                newcase = new Case();
                newcase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SalesSpace Order Lab/Sales Portal').getRecordTypeId();
                submitted = false;
                Map<String, String> paramMap = ApexPages.CurrentPage().getParameters();
                if(paramMap.get('FirstName')!=null){
                    firstName=paramMap.get('FirstName');
                }
                if(paramMap.get('LastName')!=null){
                    lastName=paramMap.get('LastName');
                }
                if(paramMap.get('Region')!=null){
                    newcase.Region__c=paramMap.get('Region');
                }
                if(paramMap.get('Email')!=null){
                    newcase.Preferred_Email__c=paramMap.get('Email');
                }
                if(paramMap.get('Phone')!=null){
                    newcase.Preferred_Phone__c=paramMap.get('Phone');
                }        
            }
    }
    /**
    * @Description: Perform validations and then invoke the sumbit function
    * @Author: Siddharth Sinha
    * @Date: 02-June-2017
    * @Param: VF page variables
    * @Return: null
    * @LastUpdatedBy : Mohan Pudi(US1128342- Dynamic Reporting field)
    */
        public PageReference SubmitCase(){
        isError = false; // setting the default value to false so that it is not NULL.
        //Check if all the fields on the form are filled up or left as null
         if (String.isBlank(firstName) || String.isBlank(lastName) || String.isBlank(newcase.Region__c) || 
            String.isBlank(newcase.Preferred_Email__c) || String.isBlank(newcase.Preferred_Phone__c) ||
            String.isBlank(newcase.Channel__c) || String.isBlank(newcase.Request_Type__c) || 
            String.isBlank(newcase.Ticket_Category__c) || String.isBlank(newcase.Description) || 
            String.isBlank(newcase.AccountNumber__c) || String.isBlank(newcase.OrderID__c) || 
            String.isBlank(newcase.Ticket_Category_II__c)) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ERR_MSG);
                ApexPages.addMessage(myMsg);
                isError =true;
         }
        // Check for the Report Name criteria
        if(!String.isBlank(newcase.Ticket_Category__c) && newcase.Ticket_Category__c.equalsIgnoreCase(TICKET_CATEGORY_REPORTING) && String.isBlank(newcase.Report_Name__c)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ERR_REPORTING);
            ApexPages.addMessage(myMsg);
            isError =true;
        }                                        
        //Set Error and return back to page - do nothing
        if(isError){
            return null;
        }       
       //If everything is fine, invoke the submit method to create a new case
        submit();
        return null;
    }
    /**
    * @Description: Creates a new case and then invokes the attach files function to tie attachments on this case
    * @Author: Siddharth Sinha
    * @Date: 02-June-2017
    * @Param: VF page variables
    * @Return: void
    * @LastUpdatedBy : Siddharth Sinha
    */
    public void submit(){    
        try{
            List<User> caseUsers = [select id from User where Alias='sproj' AND IsActive=true limit 1]; 
            if(!caseUsers.isEmpty()){
                newcase.OwnerId=caseUsers.get(0).Id;
                newcase.Requested_For__c=caseUsers.get(0).Id;
                insert newcase;
                submitted = true;
                attachmentsAdded=false;
                // Call the attach files function so that the attachments can be added to the newly created case.
                attachfiles();
                //Display success message
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, success));
                }else{
                //Display error message     
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                 }
            //Catch the exception and log this in for troubleshooting.
            }catch(DMLException dex){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,DML_ERROR)); isError =true;}finally {
            //create an attachment list that will be used for attachfiles() function
            AttachmentList = new List<Attachment>();
            }
    }
    /**
    * @Description: To Attach files in the case created using its id.
    * @Author: Siddharth Sinha
    * @Date: 02-June-2017
    * @Param: VF page variables
    * @Return: void
    * @LastUpdatedBy : Siddharth Sinha
    */
    public PageReference attachFiles(){
        //Get the id of the case created before, so that these attachments can be associated.
        parentId = newcase.Id;   
        System.debug('## parentId: '+ parentId );
        if(fileName1!=null && fileBody1!=null){
            Attachment attach1= new Attachment();
            attach1.Body = fileBody1;
            attach1.Name = fileName1;
            attach1.ParentId=parentId;
            AttachmentList.add(attach1);
        }
        if(fileName2!=null && fileBody2!=null){
            Attachment attach2= new Attachment();
            attach2.Body = fileBody2;
            attach2.Name = fileName2;
            attach2.ParentId=parentId;
            AttachmentList.add(attach2);
        }
        if(fileName3!=null && fileBody3!=null){
            Attachment attach3= new Attachment();
            attach3.Body = fileBody3;
            attach3.Name = fileName3;
            attach3.ParentId=parentId;
            AttachmentList.add(attach3);
        }
        // Inserts the attachments.
        insert AttachmentList; 
        //Check the URL which the user is using and navigate him to view the details of the submitted case.
        if(URL.getSalesforceBaseUrl().toExternalForm().contains('onecomcast')){
            return new PageReference('/apex/SubmitOrderLabCase?CaseId='+parentId);
        }else{
            return new PageReference('/SubmitCase/SubmitOrderLabCase?CaseId='+parentId);
        }
    }
        
}