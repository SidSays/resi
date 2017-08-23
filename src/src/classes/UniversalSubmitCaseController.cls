/*
 * Controller supporting the UniversalSubmitCase page that allows
   a user from any channel to submit the case.
 * generated list.
 *
 * @author  Amit Kumar, Accenture
 */
public with sharing class UniversalSubmitCaseController {

   public Case newcase {get;set;}
    public String errorMessages {get;set;}
    public Boolean isError {get;set;}
    public String firstName {get;set;}
    public String lastName {get;set;}
    public Boolean attachmentsAdded {get;set;}
    public String channelName{get;set;}
    public Boolean reporting {get;set;}
    public Boolean orderlabcases {get;set;}
    Transient public String contentType1 {get;set;}
    Transient public String contentType2 {get;set;}
    Transient public String contentType3 {get;set;}
    public List<Attachment> AttachmentList = new List<Attachment>();
    //public Attachment myAttachment{get;set;}
    Transient public string fileName1{get;set;} 
    Transient public Blob fileBody1{get;set;}
    Transient public string fileName2{get;set;} 
    Transient public Blob fileBody2{get;set;}
    Transient public string fileName3{get;set;} 
    Transient public Blob fileBody3{get;set;}
    private String success = system.label.SubmitCaseControllerInfoMessage2;
    private String error = system.label.SubmitCaseControllerInfoMessage3;
    private static final string TICKET_CATEGORY_REPORTING = 'Reporting';
    private static final string DML_ERROR = 'Error Occured';
    private static final string PRODUCT = 'Order Lab/Sales Portal';
    private static final string ERR_MSG = 'All the fields on this form are mandatory to be filled up.';
    private static final string ERR_REPORTING = 'Report Name is mandatory if Ticket Category is selected as Reporting';
    private static final string orderlabrecordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SalesSpace Order Lab/Sales Portal').getRecordTypeId();
   
    public Boolean submitted {get;set;}
     private static Id parentId {get;set;}
    public UniversalSubmitCaseController () {
        if(ApexPages.currentPage().getParameters().get('CaseId')!=null){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,system.label.SubmitCaseControllerInfoMessage1);
            ApexPages.addMessage(myMsg);
            newcase=[Select Id, Customer_Name__c,AccountNumber__c,Division__c,
                     OrderID__c,Region__c, Preferred_Email__c, Preferred_Phone__c, Channel__c, Request_Type__c, 
                     Ticket_Category__c, Ticket_Category_II__c, Report_Name__c, Description, Session_ID__c FROM Case 
                     WHERE Id=:ApexPages.currentPage().getParameters().get('CaseId')];
                attachmentsAdded=true;
                submitted = false;
                reporting = false;
            
        }else{
                //Initiate to create a new case in salesforce having selected record type, but do not save the record yet.
                newcase = new Case();
                if(ApexPages.CurrentPage().getParameters().get('RecordType') != null){
                    newCase.recordTypeId = ApexPages.CurrentPage().getParameters().get('RecordType');
                } else{
                    newCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SalesSpace Direct Sales').getRecordTypeId();
                }
                submitted = false;
            	if(orderlabrecordtypeid.equals(newCase.recordTypeId)){
                	orderlabcases = true;
            	}        
            }
        
    }

    public PageReference SubmitCase(){
        
        isError = false;

        if(isError ){
            return null;
        }
       
        submit();
        return null;
    }   

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

    public PageReference attachFiles(){
       //parentId=Id.valueOf(ApexPages.currentPage().getParameters().get('CaseId'));
        parentId = newcase.Id;        
        if(fileName1!=null && fileBody1!=null){
            Attachment attach1= new Attachment();
            attach1.Body = fileBody1;
            attach1.Name = fileName1;
            attach1.ParentId=parentId;
            AttachmentList.add(attach1);
            //insert attach1;
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
        insert AttachmentList;
        if(URL.getSalesforceBaseUrl().toExternalForm().contains('onecomcast--')){
            return new PageReference('/apex/SubmitCase?CaseId='+parentId);
        }else{
            return new PageReference('/SubmitCase/SubmitCase?CaseId='+parentId);
        }
    }
}