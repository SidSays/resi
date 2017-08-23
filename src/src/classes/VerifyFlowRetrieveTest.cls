@isTest
private class VerifyFlowRetrieveTest{
  public static Profile getDSRepProfile(){
        return [Select Id, Name From Profile where Name = 'XFINITY Sales Professional' limit 1];
    }
    
static testmethod void method() {
 Profile p = getDSRepProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
      User DSRepUser = new User(Alias = 'DSR_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom',                                    
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today());
    
   /* User userDetail = new User();
   
    userDetail.terms_and_conditions_accepted__c= null;
    //userDetail.userrole.name = 'XFINITY Sales Professional';
    insert userDetail;*/
    VerifyFlowRetrieve.getTC();
    
  }
}