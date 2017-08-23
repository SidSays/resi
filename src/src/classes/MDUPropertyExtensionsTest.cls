/**************************************************************************************************
Name : MDUPropertyExtensionsTest
Date : 4 March 2015
User Story :
Description : This class use to test Mdu Property Extension Class Created for Property Object
Author : Jui Desai
***************************************************************************************************/
@isTest
Private Class MDUPropertyExtensionsTest
{
    private static testMethod void MDUPropertyExtensionsTest(){ 
        SetupTestData.createCustomSettingRecords(); 
        
        Test.startTest();    
                    
        List<Franchise__c> franchiseList =  TestDataUtility.createFranchiseList();
        Insert franchiseList;
        
        List<Franchise__c> franchise = [Select Id , State_Name__c FROM Franchise__c ];
        
        System.debug('Franchise List >> ' + franchiseList);
        System.debug('Franchise State >> ' + franchise[0].State_Name__c);
        System.debug('Franchise State >> ' + franchise[1].State_Name__c);
        /*  Create Account And Contact Records that we use on Porperty */                 
        List<Contact> contactList = new List<Contact>();
        for(integer i = 0 ; i<3 ; i++){           
             List<Contact> contact = TestDataUtility.createContactRecord(1);  
             Database.insert(contact, false);  
        }        
        Map<string,string> accountContactIdMap = new Map<string,string>();
        for( Contact contactTemp : [select id , contact.account.id from contact]){
            accountContactIdMap.put(contactTemp.account.id,contactTemp.id);
        }       
        List<string> accountIdList = new List<string>();
        for(id accountId : accountContactIdMap.keySet() ){
            accountIdList.add(accountId);
        }
        
                             
        /* Create Property Object that have all LOB of 'Bulk' and Then we set Account and Contact for Property Object and use for update Property */        
        MDU_Property__c propertyObject = TestDataUtility.createProperty();
        propertyObject.Owner_Account__c = accountIdList.get(0);
        propertyObject.Contact_Owner__c = accountContactIdMap.get(accountIdList.get(0));
        
        propertyObject.Management_Company__c = accountIdList.get(1);
        propertyObject.Contact_Management_Company__c = accountContactIdMap.get(accountIdList.get(1));
        
        propertyObject.Developer__c = accountIdList.get(2);
        propertyObject.Contact_Developer__c = accountContactIdMap.get(accountIdList.get(2));                            
        Database.insert(propertyObject, false);
        /* Create Franchise Record */
        Franchise__c franchiseObject = TestDataUtility.createFranchise();        
        Database.insert(franchiseObject, false);
       
        PageReference pageRef = Page.MDUPropertyPage;
        Test.setCurrentPage(pageRef); 
        
        /* Call Constructor that will use to Create New Property */
        MduPropertyExtensions propertyExtensionNew = new MduPropertyExtensions(null);
        
        pageRef.getparameters().put('id',propertyObject.id);   
        ApexPages.StandardController standardController =  new ApexPages.StandardController(propertyObject)  ; 
        
        /* Initialise MduPropertyExtensions to Update Created Property */  
        MduPropertyExtensions propertyExtension = new MduPropertyExtensions(standardController);   
             
        propertyExtension.getMDUStates();   
        propertyExtension.getCounties();
        propertyExtension.getFranchisies();        
        propertyExtension.MDUState = 'Alabama';   
        propertyExtension.BindCountyPick();   
               
        propertyExtension.county = 'Harford County';
        propertyExtension.BindFranchisePick(); 
        propertyExtension.getFranchisies(); 
          
                
     
        
        propertyExtension.property.Video_Billing_Type__c = 'Retail';
        propertyExtension.property.Owner_Account__c = accountIdList.get(1);
        propertyExtension.property.Contact_Owner__c = accountContactIdMap.get(accountIdList.get(1));
        propertyExtension.readOwner();
        
        propertyExtension.property.Management_Company__c = accountIdList.get(2);
        propertyExtension.property.Contact_Management_Company__c = accountContactIdMap.get(accountIdList.get(2));
        propertyExtension.readManagComp();
        
        propertyExtension.property.Developer__c = accountIdList.get(0);
        propertyExtension.property.Contact_Developer__c = accountContactIdMap.get(accountIdList.get(0));  
        propertyExtension.readDeveloper();
        propertyExtension.Save();
        
        /* Create Property Without Account */
        
        MDU_Property__c propertyObjectWithoutAccount = TestDataUtility.createProperty();
        Database.insert(propertyObjectWithoutAccount, false);       
        ApexPages.StandardController standardController2 =  new ApexPages.StandardController(propertyObjectWithoutAccount)  ; 
        
        /* Initialise MduPropertyExtensions to Update Created Property */  
        MduPropertyExtensions propertyExtensionWihoutAccount = new MduPropertyExtensions(standardController2); 
        propertyExtensionWihoutAccount.property.Owner_Account__c = null;
        propertyExtensionWihoutAccount.readOwner();
        propertyExtensionWihoutAccount.property.Management_Company__c= null;
        propertyExtensionWihoutAccount.readManagComp();
        propertyExtensionWihoutAccount.property.Developer__c = null;
        propertyExtensionWihoutAccount.readDeveloper();
        propertyExtensionWihoutAccount.Save();
              
        /* Create Property With Developer Account */
        MDU_Property__c propertyObjectWithDevAccount = TestDataUtility.createProperty();       
        Database.insert(propertyObjectWithDevAccount, false);   
        ApexPages.StandardController standardController3 =  new ApexPages.StandardController(propertyObjectWithDevAccount )  ; 
        
        /* Initialise MduPropertyExtensions to Update Created Property */  
        MduPropertyExtensions propertyExtensionWihDevAccount = new MduPropertyExtensions(standardController3); 
        propertyExtensionWihDevAccount.property.Developer__c = accountIdList.get(0);
        propertyExtensionWihDevAccount.readDeveloper();
        propertyExtensionWihDevAccount.property.Owner_Account__c = null;
        propertyExtensionWihDevAccount.readOwner();
        propertyExtensionWihDevAccount.property.Management_Company__c= null;
        propertyExtensionWihDevAccount.readManagComp();
        propertyExtensionWihDevAccount.Save();
        
        
          /* Create Property With Developer And Management Account */
        MDU_Property__c propertyObjectWithManDevAccount = TestDataUtility.createProperty();
        insert propertyObjectWithManDevAccount ;
        
        ApexPages.StandardController standardController4 =  new ApexPages.StandardController(propertyObjectWithManDevAccount )  ; 
        
        /* Initialise MduPropertyExtensions to Update Created Property */  
        MduPropertyExtensions propertyExtensionWihDevManAccount = new MduPropertyExtensions(standardController4); 
        propertyExtensionWihDevManAccount.property.Developer__c = accountIdList.get(0);
        propertyExtensionWihDevManAccount.readDeveloper();
        propertyExtensionWihDevManAccount.property.Owner_Account__c = null;
        propertyExtensionWihDevManAccount.readOwner();
        propertyExtensionWihDevManAccount.property.Management_Company__c= accountIdList.get(1);
        propertyExtensionWihDevManAccount.readManagComp();
        propertyExtensionWihDevManAccount.Save();
        
         
          /* Create Property With Developer And Owner Account */
        MDU_Property__c propertyObjectWithDevOwnerAccount = TestDataUtility.createProperty();
        insert propertyObjectWithDevOwnerAccount ;
        
        ApexPages.StandardController standardController5 =  new ApexPages.StandardController(propertyObjectWithDevOwnerAccount)  ; 
        
        /* Initialise MduPropertyExtensions to Update Created Property */  
        MduPropertyExtensions propertyExtensionWihDevOwnAccount = new MduPropertyExtensions(standardController5); 
        propertyExtensionWihDevOwnAccount.property.Developer__c = accountIdList.get(0);
        propertyExtensionWihDevOwnAccount.readDeveloper();
        propertyExtensionWihDevOwnAccount.property.Owner_Account__c = accountIdList.get(1);
        propertyExtensionWihDevOwnAccount.readOwner();
        propertyExtensionWihDevOwnAccount.property.Management_Company__c= null;
        propertyExtensionWihDevOwnAccount.readManagComp();
        propertyExtensionWihDevOwnAccount.Save();
        
       
        
        Test.stopTest(); 
    }

}