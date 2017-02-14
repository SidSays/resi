/***************************************************************************************************************************************
 * Author     :Jui Desai, Accenture
 * Date       : 24-Feb-2015
 * Description: This is Test class for "ContractTrigger" trigger
 * History
     Version             : 1.0
     Author Last Updated : Jui, Accenture 
     PROJECT             : MDu Salesforce
***************************************************************************************************************************************/

@isTest (seeAllData = false)
Public Class ContractTriggerOperationsTest
{
    
    private static final string LABEL_NAME_SPLIT = ';';
    
    /*
    Create test Property
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
        return propertyObject;
    } 
   /*
      This method written to test LOB Contract status update on Property object from contract status having highest 
      Expiration date
   */
    private static testMethod void contractTriggerOperationsTest(){    
        
        TestDataUtility.createCustomSettingRecords(); 
        Test.startTest();  
/*
        * User Story Sprint 5:US475004
        * Implement Test Class for non coterminous checkbox on property.
        */
        MDU_Property__c prop = createTestPropertyData();
        Database.insert(prop); 
        
        List<Contract__c> contractToUpdateNonCoterm = new List<Contract__c>(); 
        List<Contract__c> contractToDeleteNonCoterm = new List<Contract__c>(); 
        
        // Insert conAnyBulk 1
        Contract__c conAnyBulk1 = TestDataUtility.createContract(prop.id);       
        conAnyBulk1.Video__c='Yes';
        conAnyBulk1.Video_Billing_Type__c='Retail';
        conAnyBulk1.Data__c='Yes';
        conAnyBulk1.Data_Billing_Type__c='Retail';
        conAnyBulk1.Voice__c='Yes';
        conAnyBulk1.Voice_Billing_Type__c='Bulk';
        conAnyBulk1.Contract_Status__c='Active';
        conAnyBulk1.Effective_Date__c=date.ValueOf('2015-02-07');
        conAnyBulk1.Contract_Term__c = 2;
        conAnyBulk1.Contract_Term_Unit__c = 'Months';   
        contractToUpdateNonCoterm.add(conAnyBulk1);    
        contractToDeleteNonCoterm.add(conAnyBulk1);

        // Insert conAnyBulk 2
        Contract__c conAnyBulk2 = TestDataUtility.createContract(prop.id);       
        conAnyBulk2.Video__c='Yes';
        conAnyBulk2.Video_Billing_Type__c='Bulk';
        conAnyBulk2.Data__c='Yes';
        conAnyBulk2.Data_Billing_Type__c='Retail';
        conAnyBulk2.Voice__c='Yes';
        conAnyBulk2.Voice_Billing_Type__c='Bulk';
        conAnyBulk2.Contract_Status__c='Active';
        conAnyBulk2.Effective_Date__c=date.ValueOf('2015-02-07');
        conAnyBulk2.Contract_Term__c = 2;
        conAnyBulk2.Contract_Term_Unit__c = 'Months';   
        contractToUpdateNonCoterm.add(conAnyBulk2);             
    
        // Insert conAllRetail
        Contract__c conAllRetail = TestDataUtility.createContract(prop.id);       
        conAllRetail.Video__c='Yes';
        conAllRetail.Video_Billing_Type__c='Bulk';
        conAllRetail.Data__c='Yes';
        conAllRetail.Data_Billing_Type__c='Retail';
        conAllRetail.Voice__c='Yes';
        conAllRetail.Voice_Billing_Type__c='Bulk';     
        conAllRetail.Contract_Status__c='Active';
        conAllRetail.Effective_Date__c=date.ValueOf('2015-02-07');
        conAllRetail.Contract_Term__c = 4;
        conAllRetail.Contract_Term_Unit__c = 'Months'; 
        contractToUpdateNonCoterm.add(conAllRetail);     
                
        Database.insert(contractToUpdateNonCoterm); 
        
        Database.delete(contractToDeleteNonCoterm);
        
        // Sprint 5:US475004 ends here
         
        /*Create Property Object that have all LOB of 'Bulk' Type*/
        
        MDU_Property__c PropertyObject1 = createTestPropertyData();
        Database.insert(PropertyObject1); 
          
        List<Contract__c> contractList1 = new List<Contract__c>(); 
        
        // Insert ContractObject1 
        Contract__c ContractObject1 = TestDataUtility.createContract(PropertyObject1.id);       
        ContractObject1.Video__c='Yes';
        ContractObject1.Video_Billing_Type__c='Bulk';
        ContractObject1.Data__c='Yes';
        ContractObject1.Data_Billing_Type__c='Bulk';
        ContractObject1.Voice__c='Yes';
        ContractObject1.Voice_Billing_Type__c='Bulk';
        ContractObject1.Contract_Status__c='Active';
        ContractObject1.Effective_Date__c=date.ValueOf('2013-02-07');
        ContractObject1.Contract_Term__c = 2;
        ContractObject1.Contract_Term_Unit__c = 'Months';   
        contractList1.add(ContractObject1);             
    
        // Insert ContractObject2 
        Contract__c ContractObject2 = TestDataUtility.createContract(PropertyObject1.id);       
        ContractObject2.Video__c='Yes';
        ContractObject2.Video_Billing_Type__c='Bulk';       
        ContractObject2.Contract_Status__c='Active';
        ContractObject2.Effective_Date__c=date.ValueOf('2014-02-07');
        ContractObject2.Contract_Term__c = 2;
        ContractObject2.Contract_Term_Unit__c = 'Months'; 
        contractList1.add(ContractObject2);     
                
        Database.insert(contractList1); 

        
        //Update ContractObject2 Effective Date
        contractList1[1].Effective_Date__c=date.ValueOf('2015-02-07');
        contractList1[1].Video__c='Yes';
        contractList1[1].Video_Billing_Type__c='Bulk';
        contractList1[1].Data__c='Yes';
        contractList1[1].Data_Billing_Type__c='Bulk';
        contractList1[1].Voice__c='Yes';
        contractList1[1].Voice_Billing_Type__c='Bulk';
        contractList1[1].Contract_Term_Unit__c = 'Years';    
        contractList1[1].Video_Rate_Escalator__c = 1;
        contractList1[1].Data_Rate_Escalator__c = 1;
        contractList1[1].Voice_Rate_Escalator__c = 1;
        contractList1[1].Sub_Status__c = 'AutoRenewed';      
        Database.update(contractList1[1]);
        
        Test.stopTest();
    }   
    
    private static testMethod void contractTriggerOperationsTest1(){    
        
        TestDataUtility.createCustomSettingRecords(); 
        Test.startTest();
                
        //Create New Property and add contract for that 

        MDU_Property__c PropertyObject2 = createTestPropertyData();
        Database.insert(PropertyObject2); 
  

        List<Contract__c> contractList2 = new List<Contract__c>(); 
     
    
                Contract__c ContractObject3 = TestDataUtility.createContract(PropertyObject2.id);   
                ContractObject3.Effective_Date__c=date.ValueOf('2014-02-07');
                ContractObject3.Video__c='No';      
                ContractObject3.Data__c='No';       
                ContractObject3.Voice__c='Yes';
                ContractObject3.Voice_Billing_Type__c='Bulk';
                ContractObject3.Contract_Term__c = 1;
                ContractObject3.Contract_Term_Unit__c = 'Years'; 
                contractList2.add(ContractObject3); 

                Contract__c ContractObject4 = TestDataUtility.createContract(PropertyObject2.id);   
                ContractObject4.Effective_Date__c=date.ValueOf('2014-02-08');
                ContractObject4.Video__c='Yes'; 
                ContractObject4.Video_Billing_Type__c='Bulk';       
                ContractObject4.Data__c='No';       
                ContractObject4.Voice__c='Yes';
                ContractObject4.Voice_Billing_Type__c='Bulk';
                ContractObject4.Contract_Term__c = 2;
                ContractObject4.Contract_Term_Unit__c = 'Years';    
                contractList2.add(ContractObject4); 

        Database.insert(contractList2);        
        
        // Update Term Unit to change Expiration Date       
        contractList2[1].Contract_Term_Unit__c = 'Months';   
        Database.update(contractList2[1]);   
        
        Test.stopTest();
        /* Test For Delete Log Generated on Contract Delete*/
    }   
    private static testMethod void DeleteContract(){
        Test.startTest();
        TestDataUtility.createCustomSettingRecords();
        
        MDU_Property__c PropertyObject7 = createTestPropertyData();
        insert PropertyObject7; 
        
        List<Contract__c> contractList7 = new List<Contract__c>(); 
        for(integer i = 0 ; i < 7; i++){
            Contract__c ContractObject7 = TestDataUtility.createContract(PropertyObject7.id);
            ContractObject7.Contract_Status__c='Expired';
            ContractObject7.Effective_Date__c=date.ValueOf('2013-02-07');
            ContractObject7.Video__c='Yes';
            ContractObject7.Video_Billing_Type__c='Bulk';
            ContractObject7.Data__c='Yes';
            ContractObject7.Data_Billing_Type__c='Bulk';
            ContractObject7.Voice__c='Yes';
            ContractObject7.Voice_Billing_Type__c='Bulk';
            
            contractList7.add(ContractObject7);
        }       
        Database.insert(contractList7); 
        
        List<Contract__c> ConID = [select id from Contract__c where id IN: contractList7];
        String ContractId = ConID[0].id;
        Database.delete(contractList7);
        
        List<Deleted_Property__c> DeletePropertyTemp = [select Property_Deleted_ID__c,Property_Name__c from Deleted_Property__c];
        system.assertEquals(DeletePropertyTemp[0].Property_Deleted_ID__c,ContractId);
        
        Test.stopTest();
    }
}