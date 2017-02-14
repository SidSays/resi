/*
  Author     : Ashish Sonawane
  Date       : 2 March Jan 2015
  Description: This test class created to test the Printable view of Property and associated contract 
*/

@IsTest
Private class MDUPropertyPrintViewExtensionsTest{            
    
    private static final string LABEL_NAME_SPLIT = ';';
    /*
       test method to test PrintSummary functionality 
    */
    private static testMethod void propertyContractPrintSummaryTest(){    
    
        SetupTestData.createCustomSettingRecords(); 
        
        String sDeveloperName = System.Label.XfinityPropertyFeeRecordType; //Get Developer Name Of Record Type And Fetch Record Only For Selected Record Type
        Set<String> recordTypeSet = new Set<String>();
        if(!string.IsBlank(sDeveloperName)){
            for(String str : sDeveloperName.split(LABEL_NAME_SPLIT)){
                recordTypeSet.add(Schema.SObjectType.Property_Fees__c.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }    
        
        List<id> recordTypeList = new List<id>();
        for(RecordType recordType : [select id from RecordType where id IN: recordTypeSet])
        {
            recordTypeList.add(recordType.id);           
        }
                
        List<Contact> contactList = new List<Contact>();
        for(integer i = 0 ; i<3 ; i++){           
            List<Contact> contact = TestDataUtility.createContactRecord(1);               
            contactList.addAll(contact);        
        }  
        Database.Insert(contactList, false);
        
        List<Property_Fees__c> propertyFeeList = new List<Property_Fees__c>();
        List<Contract__c> contractList = new List<Contract__c>();
        Map<string,string> accountContactIdMap = new Map<string,string>();
        for( Contact contactTemp : [select id , contact.account.id from contact]){
            accountContactIdMap.put(contactTemp.account.id,contactTemp.id);
        }       
        List<string> accountIdList = new List<string>();
        for(id accountId : accountContactIdMap.keySet() ){
            accountIdList.add(accountId);
        }
        
        // Create Property Object that have all LOB of 'Bulk' Type with account and contact /        
        MDU_Property__c propertyObject = TestDataUtility.createProperty();
        propertyObject.Owner_Account__c = accountIdList.get(0);
        propertyObject.Contact_Owner__c = accountContactIdMap.get(accountIdList.get(0));
        
        propertyObject.Management_Company__c = accountIdList.get(1);
        propertyObject.Contact_Management_Company__c = accountContactIdMap.get(accountIdList.get(1));
        
        propertyObject.Developer__c = accountIdList.get(2);
        propertyObject.Contact_Developer__c = accountContactIdMap.get(accountIdList.get(2));                      
       
        Database.Insert(propertyObject, false);
               
        List<Contract__c> contractList1 = new List<Contract__c>(); 
        for(integer i = 0 ; i < 10; i++){
            Contract__c ContractObject1 = TestDataUtility.createContract(propertyObject.id);
            ContractObject1.Video__c='Yes';
            ContractObject1.Video_Billing_Type__c='Bulk';
            ContractObject1.Data__c='Yes';
            ContractObject1.Data_Billing_Type__c='Bulk';
            ContractObject1.Voice__c='Yes';
            ContractObject1.Voice_Billing_Type__c='Bulk';
            if(i == 0){
                ContractObject1.Contract_Status__c='Expired';
                ContractObject1.Sub_Status__c = 'Auto-Renewed';
                ContractObject1.Effective_Date__c=date.ValueOf('2012-02-07');
            }
            else if(i == 1){
                ContractObject1.Contract_Status__c='Active';
                ContractObject1.Sub_Status__c = 'Renewed';
                ContractObject1.Effective_Date__c=date.ValueOf('2013-02-07');
            }
            else if(i == 2){
                ContractObject1.Contract_Status__c='Active';
                ContractObject1.Sub_Status__c = 'New';
                ContractObject1.Effective_Date__c=date.ValueOf('2014-02-07');
            }
            else if(i == 3){
                ContractObject1.Contract_Status__c='Expired';
                ContractObject1.Sub_Status__c = 'Auto-Renewed';
                ContractObject1.Effective_Date__c=date.ValueOf('2015-02-07');
            }
            else if(i == 4){             
                Contract__c ContractObject1WithContractedBulkService = TestDataUtility.createContract(propertyObject.id);
                ContractObject1WithContractedBulkService.Video__c='Yes';
                ContractObject1WithContractedBulkService.Video_Billing_Type__c='Bulk';
                ContractObject1WithContractedBulkService.Data__c='Yes';
                ContractObject1WithContractedBulkService.Data_Billing_Type__c='Bulk';
                ContractObject1WithContractedBulkService.Voice__c='Yes';
                ContractObject1WithContractedBulkService.Voice_Billing_Type__c='Bulk';
                ContractObject1WithContractedBulkService.Contract_Status__c='Active';
                ContractObject1WithContractedBulkService.Sub_Status__c = 'New';
                ContractObject1WithContractedBulkService.Effective_Date__c=date.ValueOf('2017-02-10');  
                    
                contractList.add(ContractObject1WithContractedBulkService);
                //Database.Insert(ContractObject1WithContractedBulkService, false);
                
                /*Contracted_Bulk_Service__c contrctedBlkService = new  Contracted_Bulk_Service__c();
                contrctedBlkService.Contract__c = ContractObject1WithContractedBulkService.id;                
                Database.Insert(contrctedBlkService, false);*/
                
                Property_Fees__c propertyFee = new Property_Fees__c();
                //propertyFee.Contract__c = ContractObject1WithContractedBulkService.id;
                propertyFee.RecordTypeId = recordTypeList[0];   
                propertyFeeList.add(propertyFee);               
                //Database.Insert(propertyFee, false);
            }
            else if(i == 5){
                ContractObject1.Contract_Status__c='Franchise';
                ContractObject1.Sub_Status__c = 'Renewed';
                ContractObject1.Effective_Date__c=date.ValueOf('2013-02-17');
            }
            else if(i == 6){
                ContractObject1.Contract_Status__c='Active';
                ContractObject1.Sub_Status__c = 'Auto-Renewed';
                ContractObject1.Effective_Date__c=date.ValueOf('2011-05-07');
            }
            else if(i == 7){
                ContractObject1.Contract_Status__c='Franchise';
                ContractObject1.Sub_Status__c = 'New';
                ContractObject1.Effective_Date__c=date.ValueOf('2015-12-07');
            } else if(i == 8){
                Contract__c ContractObject1WithRecuringFee = TestDataUtility.createContract(propertyObject.id);
                ContractObject1WithRecuringFee.Video__c='Yes';
                ContractObject1WithRecuringFee.Video_Billing_Type__c='Bulk';
                ContractObject1WithRecuringFee.Data__c='Yes';
                ContractObject1WithRecuringFee.Data_Billing_Type__c='Bulk';
                ContractObject1WithRecuringFee.Voice__c='Yes';
                ContractObject1WithRecuringFee.Voice_Billing_Type__c='Bulk';
                ContractObject1WithRecuringFee.Contract_Status__c='Active';
                ContractObject1WithRecuringFee.Sub_Status__c = 'New';
                ContractObject1WithRecuringFee.Effective_Date__c=date.ValueOf('2017-02-10');   
                contractList.add(ContractObject1WithRecuringFee);
                //Database.Insert(ContractObject1WithRecuringFee, false);             
                
                Property_Fees__c recuringFee = new Property_Fees__c();
                //recuringFee.Contract__c = ContractObject1WithRecuringFee.id;
                recuringFee.RecordTypeId = recordTypeList[1]; 
                propertyFeeList.add(recuringFee);
                //Database.Insert(recuringFee, false);         
            
            }else if(i == 9){
                Contract__c ContractObject1WithIncentiveFee = TestDataUtility.createContract(propertyObject.id);
                ContractObject1WithIncentiveFee.Video__c='Yes';
                ContractObject1WithIncentiveFee.Video_Billing_Type__c='Bulk';
                ContractObject1WithIncentiveFee.Data__c='Yes';
                ContractObject1WithIncentiveFee.Data_Billing_Type__c='Bulk';
                ContractObject1WithIncentiveFee.Voice__c='Yes';
                ContractObject1WithIncentiveFee.Voice_Billing_Type__c='Bulk';
                ContractObject1WithIncentiveFee.Contract_Status__c='Active';
                ContractObject1WithIncentiveFee.Sub_Status__c = 'New';
                ContractObject1WithIncentiveFee.Effective_Date__c=date.ValueOf('2017-02-10');                
                contractList.add(ContractObject1WithIncentiveFee);
                //Database.Insert(ContractObject1WithIncentiveFee, false);             
                
                Property_Fees__c incentiveFee = new Property_Fees__c();
                //incentiveFee.Contract__c = ContractObject1WithIncentiveFee.id;
                incentiveFee.RecordTypeId = recordTypeList[2];
                propertyFeeList.add(incentiveFee);
                //Database.Insert(incentiveFee, false);                
            
            }
            else{
                   /*Account accountTemp = new Account();
                   accountTemp.Name = 'Management Comp';
                   accountTemp.Description = 'test ';   
                   Database.Insert(accountTemp, false);                        
                
                   Contact contactTemp = new Contact();                  
                   contactTemp.lastname = 'Test';  
                   contactTemp.firstname = 'first Test'; 
                   contactTemp.AccountId = accountTemp.Id;  
                   contactTemp.Primary_Contact__c = true;     
                   Database.Insert(contactTemp, false);                        
                   
                   MDU_Property__c propertyManagementCompObject = TestDataUtility.createProperty();
                   propertyManagementCompObject.Management_Company__c = accountTemp.id;
                   propertyManagementCompObject.Contact_Management_Company__c = contactTemp.id;
                   Database.Insert(propertyManagementCompObject, false);        
                                   
                   Contract__c ContractObject1WithContractedBulkService = TestDataUtility.createContract(propertyManagementCompObject.id);
                   ContractObject1WithContractedBulkService.Video__c='Yes';
                   ContractObject1WithContractedBulkService.Video_Billing_Type__c='Bulk';
                   ContractObject1WithContractedBulkService.Data__c='Yes';
                   ContractObject1WithContractedBulkService.Data_Billing_Type__c='Bulk';
                   ContractObject1WithContractedBulkService.Voice__c='Yes';
                   ContractObject1WithContractedBulkService.Voice_Billing_Type__c='Bulk';
                   ContractObject1WithContractedBulkService.Contract_Status__c='Active';
                   ContractObject1WithContractedBulkService.Sub_Status__c = 'New';
                   ContractObject1WithContractedBulkService.Effective_Date__c=date.ValueOf('2017-02-10');
                   contractList.add(ContractObject1WithContractedBulkService);
                   //Database.Insert(ContractObject1WithContractedBulkService, false);   */                       
            }
            contractList1.add(ContractObject1);
        }
        
        contractList.addAll(contractList1);
        Database.Insert(contractList, false);  
        Contracted_Bulk_Service__c contrctedBlkService = new  Contracted_Bulk_Service__c();
        contrctedBlkService.Contract__c = contractList[0].id; 
            
        Database.Insert(contrctedBlkService, false);
        propertyFeeList[0].Contract__c = contractList[0].Id;
        propertyFeeList[1].Contract__c = contractList[1].Id;
        propertyFeeList[2].Contract__c = contractList[2].Id;
        Database.Insert(propertyFeeList, false); 
        //Database.Insert(contractList1, false);          
        
        // Initialise MduPropertyPrintViewExtensions / 
        Test.startTest();       
        PageReference pageRef = Page.MDUPropertyPrintableView;
        Test.setCurrentPage(pageRef);    
                        
        // test for all contract selected for property to show in PrintSummary /
       
        pageRef.getParameters().put('id', propertyObject.id);
        pageRef.getParameters().put('contractID', '');
        MduPropertyPrintViewExtensions propertyContractPrintSummary = new MduPropertyPrintViewExtensions(null);
                              
        // test for first contract selected for property to show in PrintSummary /
        pageRef.getParameters().put('id', propertyObject.id);
        pageRef.getParameters().put('contractID', contractList1[0].id);
        MduPropertyPrintViewExtensions propertyContractPrintSummaryforSingleContract = new MduPropertyPrintViewExtensions(null);         
        Test.stopTest();    
    }
    
}