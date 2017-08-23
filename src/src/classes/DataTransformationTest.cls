@isTest
private class DataTransformationTest {
  

    private static testMethod void testdata1(){
    
        List<account>lstacc = new List<account>();

        Test.startTest();
            
           Account acc = new Account();
           acc.name = 'Test';
           acc.Last_Install_Date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
           acc.type ='customer';
           
           insert acc;
           lstacc.add(acc);
           
           for(Account a : lstacc){
               a.Last_Install_Date__c = datetime.newInstance(2013, 9, 15, 12, 30, 0);
           }
               
             update lstacc;
             
                DataTransformation.dataTransform(lstacc);
                Test.stopTest();       
     }
     
      private static testMethod void testdata2(){
    
        List<account>lstacc = new List<account>();

        Test.startTest();
            
           Account acc = new Account();
           acc.name = 'Test';
           acc.Last_Install_Date__c = datetime.newInstance(1961, 9, 15, 12, 30, 0);
           acc.type ='customer';
           
           insert acc;
           lstacc.add(acc);
           
           for(Account a : lstacc){
               a.Last_Install_Date__c = datetime.newInstance(1962, 9, 15, 12, 30, 0);
           }
               
             update lstacc;
             
                DataTransformation.dataTransform(lstacc);
                Test.stopTest();       
     }
   }