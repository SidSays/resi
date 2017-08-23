/***************************************************************************************************************************************
 * Author     : Ashish Sonawane, Accenture
 * Date       : 22-Feb-2015
 * Description: This is Test class for "BulkServiceTrigger" trigger
 * History
     Version             : 1.0
     Author Last Updated : Ashish, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class BulkServiceTriggerOperationTest{
   
    private static final string LABEL_NAME_SPLIT = ';';
   
   /*
    Create Property Object that will use in overall Test class
   */
    public static MDU_Property__c createTestPropertyData(){               
        String labelName = System.Label.XfinityPropertyRecordType;  
        List<String> recordTypeSet = new List<String>();
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(LABEL_NAME_SPLIT)){
                recordTypeSet.add(Schema.SObjectType.MDU_Property__c.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }                
                         
        MDU_Property__c propertyObject = TestDataUtility.createProperty() ;
        propertyObject.RecordTypeId = recordTypeSet[0]; 
        propertyObject.PostalCode__c = '10509';  
        propertyObject.Bulk_Status__c = 'Not Serviced';       
        propertyObject.Industry_Type__c = 'Multi Family';         
        propertyObject.Name = 'Test Property';  
        return propertyObject;
    }
   
   /*
      This method written to add new Bulk Service if we update/insert Bulk Service which should be implemented
   */
    static testmethod void testAddNewBulkServiceForImplementedBulkService(){ 
                       
        Test.startTest();
        
        /*     Create PropertyObject        */
        TestDataUtility.createCustomSettingRecords(); 
        MDU_Property__c propertyObject = createTestPropertyData();
        insert propertyObject;        
        
        /*   Create Contract For PropertyObject   */
        Contract__c contractObject = TestDataUtility.createContract(propertyObject.id);
        contractObject.Contract_Status__c = 'Active';
        contractObject.Sub_Status__c = 'New';
        contractObject.Effective_Date__c = date.newInstance(2013, 1, 28);
        contractObject.Contract_Term__c = 1;
        contractObject.Contract_Term_Unit__c = 'Months';
        contractObject.Video__c = 'Yes';
        contractObject.Video_Billing_Type__c = 'Bulk';        
        contractObject.Video_Increase_Period__c = 'Monthly';
        contractObject.Video_Increase_Notice__c = 1;
        insert contractObject;
             
        
        List<Bulk_Service__c> bulkServiceList = new List<Bulk_Service__c>();
        
        for(integer i = 0; i<8 ; i++){
            
            /* Update propertyObject with Notice Period As '1' And Increase Period As 'Monthly' */
            propertyObject.Contract_Video_Notice_Period__c = 1;
            propertyObject.Increase_Period__c = 'Monthly';
            update propertyObject;
                      
            /*  Create Bulk Rate Increase Object */
            Bulk_Rate_Increase__c bulkRateIncreaseObject = TestDataUtility.createBulkRateIncrease(propertyObject.id);
            insert bulkRateIncreaseObject;
            
            /*  Create Bulk Service Object Which Will Be Implemented */
            Bulk_Service__c bulkServiceObject = TestDataUtility.createBulkService(bulkRateIncreaseObject.id);
            bulkServiceObject.Units__c = 12;            
            bulkServiceObject.Increase_Amount__c = 12;
            bulkServiceObject.Increase_Amount_Units__c = '$';
            bulkServiceObject.Current_Rate__c =  12;
            bulkServiceObject.Implemented__c = true;
            if(i == 0){
                bulkServiceObject.Bulk_Service__c = 'TEST';
                bulkServiceObject.Increase_Date__c = date.newInstance(2014, 2, 28);
                bulkServiceObject.Notice_Due_Date__c = date.newInstance(2014, 1, 2);
            }else if(i == 1){                
                MDU_Property__c propertyObject3 = createTestPropertyData();               
                propertyObject3.Contract_Video_Notice_Period__c = 1;
                propertyObject3.Increase_Period__c = 'Semi-Annually';
                insert propertyObject3;
                      
                /* Create Bulk Rate Increase Object */
                Bulk_Rate_Increase__c bulkRateIncreaseObject3 = TestDataUtility.createBulkRateIncrease(propertyObject3.id);
                insert bulkRateIncreaseObject3 ;
            
                /* Create Bulk Service Object Which Will Be Implemented */
                Bulk_Service__c bulkServiceObjectWithSemiAnnuallyPeriod = TestDataUtility.createBulkService(bulkRateIncreaseObject3.id);                                
                bulkServiceObjectWithSemiAnnuallyPeriod.Increase_Date__c = date.newInstance(2015, 2, 28);
                bulkServiceObjectWithSemiAnnuallyPeriod.Notice_Due_Date__c = date.newInstance(2015, 1, 2);
                bulkServiceList.add(bulkServiceObjectWithSemiAnnuallyPeriod);
            }else if(i == 2){
                
                MDU_Property__c propertyObject4 = createTestPropertyData();               
                propertyObject4.Contract_Video_Notice_Period__c = 1;
                propertyObject4.Increase_Period__c = 'Annually';
                insert propertyObject4;
                      
                /* Create Bulk Rate Increase Object */
                Bulk_Rate_Increase__c bulkRateIncreaseObject4 = TestDataUtility.createBulkRateIncrease(propertyObject4.id);
                insert bulkRateIncreaseObject4 ;
            
                /* Create Bulk Service Object Which Will Be Implemented */
                Bulk_Service__c bulkServiceObjectWithAnnuallyPeriod = TestDataUtility.createBulkService(bulkRateIncreaseObject4.id);                                
                bulkServiceObjectWithAnnuallyPeriod.Increase_Date__c = date.newInstance(2015, 2, 28);
                bulkServiceObjectWithAnnuallyPeriod.Notice_Due_Date__c = date.newInstance(2015, 1, 2);
                bulkServiceList.add(bulkServiceObjectWithAnnuallyPeriod);
                               
            }else if(i == 3){           
                
                /*  Update propertyObject with Notice Period As '1' And Increase Period As 'Monthly'  */              
                MDU_Property__c propertyObject2 = createTestPropertyData();               
                propertyObject2.Contract_Video_Notice_Period__c = 1;
                propertyObject2.Increase_Period__c = 'Quarterly';
                insert propertyObject2;
                      
                /*  Create Bulk Rate Increase Object */
                Bulk_Rate_Increase__c bulkRateIncreaseObject2 = TestDataUtility.createBulkRateIncrease(propertyObject2.id);
                insert bulkRateIncreaseObject2;
            
                /*  Create Bulk Service Object Which Will Be Implemented */
                Bulk_Service__c bulkServiceObjectWithQuarterlyPeriod = TestDataUtility.createBulkService(bulkRateIncreaseObject2.id);
                bulkServiceObjectWithQuarterlyPeriod.Units__c = 12;            
                bulkServiceObjectWithQuarterlyPeriod.Increase_Amount__c = 12;
                bulkServiceObjectWithQuarterlyPeriod.Increase_Amount_Units__c = '$';
                bulkServiceObjectWithQuarterlyPeriod.Current_Rate__c =  12;
                bulkServiceObjectWithQuarterlyPeriod.Implemented__c = true;                               
                bulkServiceObjectWithQuarterlyPeriod .Increase_Date__c = date.newInstance(2014, 12, 28);
                bulkServiceObjectWithQuarterlyPeriod .Notice_Due_Date__c = date.newInstance(2011, 12, 2);
                bulkServiceList.add(bulkServiceObjectWithQuarterlyPeriod);
            }else if(i == 4){                           
                
                /*  Update propertyObject with Notice Period As '1' And Increase Period As 'Monthly' */                 
                MDU_Property__c propertyObject1 = createTestPropertyData();               
                propertyObject1.Contract_Video_Notice_Period__c = null;
                propertyObject1.Increase_Period__c = null;
                insert propertyObject1;
                      
                /* Create Bulk Rate Increase Object */
                Bulk_Rate_Increase__c bulkRateIncreaseObject1 = TestDataUtility.createBulkRateIncrease(propertyObject1.id);
                insert bulkRateIncreaseObject1;
            
                /*  Create Bulk Service Object Which Will Be Implemented */
                Bulk_Service__c bulkServiceObjectWithNull = TestDataUtility.createBulkService(bulkRateIncreaseObject1.id);
                bulkServiceObjectWithNull.Units__c = 12;            
                bulkServiceObjectWithNull.Increase_Amount__c = 12;
                bulkServiceObjectWithNull.Increase_Amount_Units__c = '$';
                bulkServiceObjectWithNull.Current_Rate__c =  12;
                bulkServiceObjectWithNull.Implemented__c = true;
                bulkServiceObjectWithNull.Increase_Date__c = date.newInstance(2014, 12, 28);
                bulkServiceObjectWithNull.Notice_Due_Date__c = date.newInstance(2011, 12, 2);
                bulkServiceList.add(bulkServiceObjectWithNull);
            }
            else{
                bulkServiceObject.Increase_Date__c = null;
                bulkServiceObject.Notice_Due_Date__c = null;
            }
            bulkServiceList.add(bulkServiceObject);
        }
        
        insert bulkServiceList;
        List<Bulk_Service__c> bulkService = [select Increase_Date__c ,Notice_Due_Date__c , Units__c,Bulk_Service__c , Increase_Amount__c, Increase_Amount_Units__c, 
                                             Current_Rate__c ,New_Rate__c from Bulk_Service__c where Bulk_Service__c = 'TEST'  ];   //This is tested only for Bulk Service = 'TEST'             
                  
        System.assertEquals(bulkService[0].Units__c.format(),bulkService[1].Units__c.format());
        System.assertEquals(bulkService[0].Increase_Amount__c.format(),bulkService[1].Increase_Amount__c.format());  
        System.assertEquals(bulkService[0].Increase_Amount_Units__c,bulkService[1].Increase_Amount_Units__c);
        System.assertEquals(bulkService[0].New_Rate__c.format() ,bulkService[1].Current_Rate__c.format() );
        System.assertEquals(bulkService[0].Bulk_Service__c ,bulkService[1].Bulk_Service__c);    
        System.assertEquals('3/28/2014',bulkService[1].Increase_Date__c.format()); // Date Increase By 1 Month 
        System.assertEquals('3/27/2014',bulkService[1].Notice_Due_Date__c.format());   //Date decrease By 1 Day of Increase Date             
                                                    
        /*  Update Bulk Service Record  */            
        List<Bulk_Service__c> bulkServiceUpdateList = new List<Bulk_Service__c>();
        for(Bulk_Service__c bulkServiceTemp : [select id,Units__c, Implemented__c, Notice_Due_Date__c From Bulk_Service__c]){
            bulkServiceTemp.Implemented__c = false;
            bulkServiceUpdateList.add(bulkServiceTemp);
        }
        update bulkServiceUpdateList;
        
        bulkServiceUpdateList.clear();
        for(Bulk_Service__c bulkServiceTemp : [select id,Units__c, Implemented__c, Notice_Due_Date__c From Bulk_Service__c]){
           bulkServiceTemp.Implemented__c = true;
           bulkServiceUpdateList.add(bulkServiceTemp);
        }
        update bulkServiceUpdateList;
     
       
        Test.stopTest();                                                
    }
}