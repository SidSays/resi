/*
 * Controller supporting the SubmitCaseSelectRecordType page that allows
   a DSM app user to select a Case record type from a dynamically
 * generated list.
 *
 * @author  Malay Desai, Accenture
 */
public with sharing class SubmitCaseSelectRecordTypeCont {

  public String selectedRecordTypeId{get;set;}
  
    public List<SelectOption> getRecordTypes(){
      List<RecordType> recordTypes = [SELECT id,Name FROM RecordType WHERE Name IN ('SalesSpace Direct Sales','SalesSpace Order Lab/Sales Portal','SalesSpace Chatter')];
        List<SelectOption> caseRecordTypes = new List<SelectOption>();
        
        if(recordTypes != null && recordTypes.size() > 0){
          for(RecordType rt : recordTypes){
            caseRecordTypes.add(new SelectOption(rt.Id, rt.Name));
          }
        }
        
        return caseRecordTypes;
    }
    
    /*
     * @return The custom edit page for Case (i.e. SubmitCase), with the specified
     *         record type ID
     */
    public PageReference editWithRecordType() {
        PageReference nextPage = Page.SubmitCase;
        nextPage.getParameters().clear();
        nextPage.getParameters().put('RecordType', selectedRecordTypeId);
        return nextPage;
    }
}