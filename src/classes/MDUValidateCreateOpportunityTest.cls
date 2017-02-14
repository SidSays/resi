/****************************************************************************************************************************************************
Name: MDUValidateCreateOpportunity 
Description: This class is used to test  MDUValidateCreateOpportunity class
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
22 May 2015 Comcast  
*************************************************************************************************************************************************************/
@isTest                        
private class MDUValidateCreateOpportunityTest{ 
 
    /* Test Opportunity creation for open Opportunity */
    @isTest static void testValidateCreateOpportunutty() {
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();
   
        System.runAs(xcUser){   
            Id propertyId = createCleanOpptyPropertyCommerclInd();
            boolean openOpprtunutExist = MDUValidateCreateOpportunity.validateOpenOppty(propertyId);
            System.assertEquals(true,openOpprtunutExist);
        }                           
    }
    
    @isTest static void testValidateCreateOpportunuttyFalse() {
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();
        Account accountRec = createTestAccountData();
        Database.insert(accountRec);
        System.runAs(xcUser){   
            MDU_Property__c prop1 = TestDataUtility.createProperty();
            prop1.Industry_Type__c = 'Commercial';
            prop1.Property_Type__c = 'Lobby';
            prop1.Owner_Account__c = accountRec.Id;
            prop1.MDU_State__c = 'Florida';
            prop1.County__c = 'Bay County';
            prop1.Franchise_New__c = 'Parker City';    
            Database.insert(prop1);
            boolean openOpprtunutExist = MDUValidateCreateOpportunity.validateOpenOppty(prop1.Id);
            System.assertEquals(false,openOpprtunutExist);
        }                           
    }   
        
    /* 
        Create Opportunity Property Record having property of Commercial as Industry Type 
    */
    private static Id createCleanOpptyPropertyCommerclInd(){
        
        Account accountRec = createTestAccountData();
        Database.insert(accountRec);     
        //006K000000CIwh4 opportunity Id use to create record       
        Opportunity opportunutyRec = createOpportunity(accountRec.Id);
        insert opportunutyRec;
                
        MDU_Property__c prop1 = TestDataUtility.createProperty();
        prop1.Industry_Type__c = 'Commercial';
        prop1.Property_Type__c = 'Lobby';
        prop1.Owner_Account__c = accountRec.Id;
        prop1.MDU_State__c = 'Florida';
        prop1.County__c = 'Bay County';
        prop1.Franchise_New__c = 'Parker City';         
        Database.insert(prop1);
        
        Opportunity_Property__c oppProp =  TestDataUtility.createOppProperty(opportunutyRec.id,prop1.id);
        oppProp.Primary_Property__c  = true;
        Database.insert(oppProp); 
       
        OpportunityContactRole OppContactRole = new OpportunityContactRole();
        OppContactRole = MDU_EmptorisUtility.fetchOpportunityContactRoleData(opportunutyRec.id);
        return prop1.id;
    }
    
    /* 
        Create opportunity record and return Id
    */
    private static Id createOpportunityOnly(){
        Account accountRec = createTestAccountData();
        Database.insert(accountRec);            
        Opportunity opportunutyRec = createOpportunity(accountRec.Id);             
        Database.insert(opportunutyRec);
        return opportunutyRec.Id;
    }
    
    /* 
        Create Opportunity record
    */
    private static Opportunity createOpportunity(Id accountId){
        List<Opportunity> oppList = TestDataUtility.createOpportunity(2);            
        oppList[0].Contact_Email__c = 'vsadvdsv@dfhds.fdhdsf';
        oppList[0].Contact_First_Name__c = 'sadvadv';
        oppList[0].Contact_Last_Name__c = 'vdsadsv';                  
        oppList[0].Interview_Created_Date__c = 'date';
        oppList[0].StageName = 'Contract Document Review';
        oppList[0].ContractTermUnit__c = 'months';
        oppList[0].ContractTerm__c = 1;
        oppList[0].Contract_Type__c = 'Bulk';
        oppList[0].Video_Subs__c = 12;             
        oppList[0].Video_Bulk_Current_Rate__c = 2;
        oppList[0].Video_Bulk_Proposed_Rate__c = 2;        
        oppList[0].Video_Estimated_Revenue_Share_Rate__c = 2; 
        oppList[0].Video_Retail_Rate__c = 55;        
        oppList[0].Data_Subs__c = 10;       
        oppList[0].Data_Bulk_Current_Rate__c = 2;
        oppList[0].Data_Bulk_Proposed_Rate__c = 2;
        oppList[0].Data_Retail_Rate__c = 29;        
        oppList[0].Data_Estimated_Revenue_Share__c = 2; 
        oppList[0].Voice_Subs__c = 54;        
        oppList[0].Voice_Bulk_Current_Rate__c = 2;
        oppList[0].Voice_Bulk_Proposed_Rate__c = 2;       
        oppList[0].Voice_Estimated_Revenue_Share__c = 2; 
        oppList[0].Voice_Retail_Rate__c = 29;
        oppList[0].Per_Unit_Door_Fee__c = 2;
        oppList[0].IRR__c = 393;
        oppList[0].NPV__c = 137;
        oppList[0].Total_Equipment_Cost__c = 19393;
        oppList[0].Payback_Period_Months__c = 4;
        oppList[0].Construction_Capex_Cost__c = 2;
        oppList[0].Fiber_To_The_Unit__c = 'None';
        oppList[0].AccountId = accountId;  
        return  oppList[0];
    }
    
     
    /*
        Create Account Record 
    */  
    public static Account createTestAccountData(){
        
        List<Id> recordTypeIds = new List<Id>();      
        String labelName = System.Label.XfinityAccountRecordType;  
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(';')){
                recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }    
        
        Account accountObject = TestDataUtility.createAccount() ;
        accountObject.Is_Parent_Organization__c = false;
        accountObject.RecordTypeId = recordTypeIds[0];        
        return accountObject;
    }}