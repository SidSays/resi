public without sharing class SubmitCaseController {
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
    //public Attachment myAttachment{get;set;}
    Transient public string fileName1{get;set;} 
    Transient public Blob fileBody1{get;set;}
    Transient public string fileName2{get;set;} 
    Transient public Blob fileBody2{get;set;}
    Transient public string fileName3{get;set;} 
    Transient public Blob fileBody3{get;set;}
   // private String success = 'Your Service Request has been Submitted Successfully, you can attach files using the "Attach Files" button. Thank You.';
    private String success = 'Your Service Request has been Submitted Successfully. Thank You.';
    private static final string TICKET_CATEGORY_REPORTING = 'Reporting';

   
    public Boolean submitted {get;set;}
     private static Id parentId {get;set;}
    public SubmitCaseController() {
        if(ApexPages.currentPage().getParameters().get('CaseId')!=null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Attachments Successfully Added.');
            ApexPages.addMessage(myMsg);
            newcase=[Select Id, Requested_For__r.FirstName, Requested_For__r.LastName,AccountNumber__c,OrderID__c,Region__c, Preferred_Email__c, Preferred_Phone__c, Channel__c, Request_Type__c, Ticket_Category__c, Ticket_Category_II__c, Description, Session_ID__c From Case Where Id=:ApexPages.currentPage().getParameters().get('CaseId')];
            firstName=newCase.Requested_For__r.FirstName;
            lastName=newCase.Requested_For__r.LastName;
            attachmentsAdded=true;
            submitted = false;
            }else{
                newcase = new Case();
                if(ApexPages.CurrentPage().getParameters().get('RecordType') != null){
                    newCase.recordTypeId = ApexPages.CurrentPage().getParameters().get('RecordType');
                } else{
                    newCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SalesSpace Direct Sales').getRecordTypeId();
                }
                //newcase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SR/Ticket Management').getRecordTypeId();
                submitted = false;
                if(ApexPages.CurrentPage().getParameters().get('FirstName')!=null){
                    firstName=ApexPages.CurrentPage().getParameters().get('FirstName');
                }
                if(ApexPages.CurrentPage().getParameters().get('LastName')!=null){
                    lastName=ApexPages.CurrentPage().getParameters().get('LastName');
                }
                if(ApexPages.CurrentPage().getParameters().get('Region')!=null){
                    newcase.Region__c=ApexPages.CurrentPage().getParameters().get('Region');
                }
                if(ApexPages.CurrentPage().getParameters().get('Email')!=null){
                    newcase.Preferred_Email__c=ApexPages.CurrentPage().getParameters().get('Email');
                }
                if(ApexPages.CurrentPage().getParameters().get('Phone')!=null){
                    newcase.Preferred_Phone__c=ApexPages.CurrentPage().getParameters().get('Phone');
                }
            }
    }

    public PageReference SubmitCase(){
        
        isError = false;

        if(firstName == null || firstName == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'First Name cannot be empty.');
            ApexPages.addMessage(myMsg);
            isError =true;
        }
        if(lastName == null || lastName == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Last Name cannot be empty.');
            ApexPages.addMessage(myMsg);
            isError =true;
        }
        
        if(newcase.Region__c == null || newcase.Region__c == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Region cannot be empty.');
            ApexPages.addMessage(myMsg);
            isError =true;
        } 
        if(newcase.Preferred_Email__c == null || newcase.Preferred_Email__c == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.SubmitCaseControllerErrorMessage8);
            ApexPages.addMessage(myMsg);
            isError =true;
        }
        //Commenting below code as part of US625884
        /*else
        {
            if(!newcase.Preferred_Email__c.contains('@cable.comcast.com'))
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Comcast Email must be your Comcast email address.');
                ApexPages.addMessage(myMsg);
                isError =true;
            }
        }*/
        if(newcase.Preferred_Phone__c == null || newcase.Preferred_Phone__c == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Preferred Phone cannot be empty.');
            ApexPages.addMessage(myMsg);
            isError =true;
        }
        if(newcase.Channel__c == null || newcase.Channel__c == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Channel cannot be empty.');
            ApexPages.addMessage(myMsg);
            isError =true;
        }
        if(newcase.Request_Type__c == null || newcase.Request_Type__c == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Product cannot be empty.');
            ApexPages.addMessage(myMsg);
            isError =true;
        }
        
        if(newcase.Ticket_Category__c == null || newcase.Ticket_Category__c == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Ticket Category cannot be empty.');
            ApexPages.addMessage(myMsg);
            isError =true;
        }
      
        if(newcase.Description == null || newcase.Description == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Description cannot be empty.');
            ApexPages.addMessage(myMsg);
            isError =true;
        }
        
        if(newcase.Ticket_Category__c !=null && newcase.Ticket_Category__c.equalsIgnoreCase(TICKET_CATEGORY_REPORTING)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.ReportingCaseErrorMsg);
            ApexPages.addMessage(myMsg);
            isError =true;
        }
        
        if(isError ){
            return null;
        }
       
        submit();
        return null;
    }   

    public void submit(){    
        try{
            List<User> caseUsers=[Select Id From User Where (email=:newcase.Preferred_Email__c OR username=:newcase.Preferred_Email__c) AND IsActive=true];
            if(caseUsers.isEmpty()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There is no user in Salesforce with this email address or username. Please enter your Comcast email address.'));
                }else{
                Group rsaTicketQueue=[Select Id From Group Where Name='RSA Ticket Queue'];
                newcase.OwnerId=rsaTicketQueue.Id;
                newcase.Requested_For__c=caseUsers.get(0).Id;
                insert newcase;
                submitted = true;
                attachmentsAdded=false;
                attachfiles();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, success));
            }
            
        }catch(DMLException dex){
            if(newcase.Channel__c == 'Order Lab/Sales Portal') {        
              if((newcase.AccountNumber__c == NULL) || (newcase.OrderID__c == NULL)|| (newcase.Ticket_Category__c == 'NULL') || (newcase.Ticket_Category_II__c == 'NULL')){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'For "Order Lab/Sales Portal" channel following fields are required : Account Number, Order Number, Ticket Category, Ticket Category ||.');
                ApexPages.addMessage(myMsg);
                isError =true;
              }
           }
        }finally {
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