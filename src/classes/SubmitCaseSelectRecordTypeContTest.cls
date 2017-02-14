@isTest

private class SubmitCaseSelectRecordTypeContTest {
  static testMethod void SubmitCaseRecordTypeContTest(){
    //List<RecordType> recordTypes= new List<RecordType>();
    //RecordType R = new RecordType(Name = 'SalesSpace Direct Sales');
    Case c = new Case();
    c.RecordTypeId='01216000001Ik5F';
    
    test.startTest();
    insert c;
    ApexPages.currentPage().getParameters().put('selectedRecordTypeId', c.RecordTypeId);
    SubmitCaseSelectRecordTypeCont s = new SubmitCaseSelectRecordTypeCont();
    s.editWithRecordType();
    s.getRecordTypes();
    test.stopTest();
    }
}