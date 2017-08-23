@isTest 
public with sharing class ScheduleAddressStatsCalculationTest{

     private static testMethod void testSearchServicesREST(){
         ConfigurableParameters__c parameter = new ConfigurableParameters__c();
         parameter.Name = 'AddressStatsBatchSize';
         parameter.NumberValue__c = 10;
         insert parameter;
         
         Test.StartTest();
           
            
        ScheduleAddressStatsCalculation sh1 = new ScheduleAddressStatsCalculation();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Check', sch, sh1); 
        Test.stopTest(); 
     
     }
}