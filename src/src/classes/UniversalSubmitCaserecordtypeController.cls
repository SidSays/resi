public with sharing class UniversalSubmitCaserecordtypeController {
    public String selectedRecordTypeId {get;set;}
    
    
    public List<SelectOption> getRecordTypes()
    {
        List<RecordType> recordTypes = [SELECT id,Name FROM RecordType WHERE Name IN 
                                      ('SalesSpace Chatter','SalesSpace Communities','SalesSpace Direct Sales',
                                       'SalesSpace Indirect (Retail)','SalesSpace NSO','SalesSpace Property Lab',
                                       'Wave Only User','SalesSpace Order Lab/Sales Portal','Retail Store') ORDER BY NAME ASC];
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
        PageReference nextPage = Page.UniversalSubmitCase;
        nextPage.getParameters().clear();
        nextPage.getParameters().put('RecordType', selectedRecordTypeId);
        return nextPage;
    }
    
}