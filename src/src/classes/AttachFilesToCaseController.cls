public without sharing class AttachFilesToCaseController {

    public Transient Blob fileBody1 {get;set;}
    public Transient String fileName1 {get;set;}
    public Transient Blob fileBody2 {get;set;}
    public Transient String fileName2 {get;set;}
    public Transient Blob fileBody3 {get;set;}
    public Transient String fileName3 {get;set;}
    public String attachCaseDate {get;set;}
    private static Id parentId {get;set;}

    public AttachFilesToCaseController() {
        parentId=Id.valueOf(ApexPages.currentPage().getParameters().get('CaseId'));
        Case attachCase=[Select CreatedDate From Case Where Id=:parentId];
        attachCaseDate=attachCase.CreatedDate.format('MM/dd/yyyy');
    }

    public PageReference attachFiles(){
        parentId=Id.valueOf(ApexPages.currentPage().getParameters().get('CaseId'));
        if(fileName1!=null && fileBody1!=null){
            Attachment attach1= new Attachment();
            attach1.Body = fileBody1;
            attach1.Name = fileName1;
            attach1.ParentId=parentId;
            insert attach1;
        }
        if(fileName2!=null && fileBody2!=null){
            Attachment attach2= new Attachment();
            attach2.Body = fileBody2;
            attach2.Name = fileName2;
            attach2.ParentId=parentId;
            insert attach2;
        }
        if(fileName3!=null && fileBody3!=null){
            Attachment attach3= new Attachment();
            attach3.Body = fileBody3;
            attach3.Name = fileName3;
            attach3.ParentId=parentId;
            insert attach3;
        }
        if(URL.getSalesforceBaseUrl().toExternalForm().contains('onecomcast--')){
            return new PageReference('/apex/SubmitCase?CaseId='+parentId);
        }else{
            return new PageReference('/SubmitCase/SubmitCase?CaseId='+parentId);
        }
    }
}