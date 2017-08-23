public class IndirectAddContactWrapper {
    
    @AuraEnabled
    public boolean checked{get; set;}
    @AuraEnabled
    public Contact contactObj{get; set;}
     
    
    @AuraEnabled
    public static List<IndirectAddContactWrapper> getContacts(String storeId, String storeVisitId){
        
        boolean contactFound = false;
        List<IndirectAddContactWrapper> listOfWrapper = new List<IndirectAddContactWrapper>();
        
        List<Contact> AccountContacts = [Select Id, Name, FirstName, LastName, Email, Phone from Contact where AccountId =:storeId order by CreatedDate DESC];
        List<Visit_Contacts__c> visitContactList = [Select Id,Contact__c from Visit_Contacts__c where Store_Visit__c = :storeVisitId order by CreatedDate DESC];
        
        if(visitContactList != null && AccountContacts != null){
            for(Contact c : AccountContacts){
            contactFound = false;
            for(Visit_Contacts__c vc : visitContactList)
            {
                if(c.Id == vc.Contact__c)
                {
                    IndirectAddContactWrapper obj = new IndirectAddContactWrapper();
                obj.checked = true;
                obj.contactObj = c;
                listOfWrapper.add(obj);
                    contactFound = true;
                    break;
                }
            }
            if(contactFound == false)
            {
                IndirectAddContactWrapper obj = new IndirectAddContactWrapper();
                obj.checked = false;
                obj.contactObj = c;
                listOfWrapper.add(obj);
               // contactFound = false;
            }
       } 
        }

        return listOfWrapper;
    }
    
    @AuraEnabled
    public static void saveContacts(List<Contact> ListOfContact, String storeVisit )
    {
        List<Visit_Contacts__c> newVisitContact = new List<Visit_Contacts__c>();
        for(Contact c : ListOfContact)
        {
            Visit_Contacts__c vc = new Visit_Contacts__c(Store_Visit__c = storeVisit, Contact__c = c.Id, Status__c = 'Existing');
            newVisitContact.add(vc);
        }
        insert newVisitContact;
    }
    
    @AuraEnabled
    public static void deleteContacts(List<Contact> ListOfContact, String storeVisit )
    {
     List<Visit_Contacts__c> delContacts = [Select Id,Contact__c from Visit_Contacts__c where Store_Visit__c = :storeVisit 
                                            AND Contact__c  IN :ListOfContact];
        delete delContacts;
    }
    
    /*@AuraEnabled
    public static Contact AddContact(String fName, String lName, String email, String Salut, String storeId, String storeVisitId)
    {
        System.debug('in addcontact');
        Contact cObj = new Contact(AccountId = storeId, Salutation = Salut, FirstName = fName, LastName = lName, Email = email);
        insert cObj;
        system.debug('cObj'+cObj);
        Visit_Contacts__c vc = new Visit_Contacts__c(Store_Visit__c = storeVisitId, Contact__c = cObj.Id, Status__c = 'New');
        insert vc;
        
            return cObj;
              
    }*/
	
	
	@AuraEnabled
    public static void AddContacttoVisitContact(Account store, Store_Visit__c storeVisit)
    {
        System.debug('in addcontact'); 
		
		Contact cObj = [Select Id from Contact where AccountId = :store.Id Order By LastModifiedDate DESC Limit 1];
		
        system.debug('cObj'+cObj);
        Visit_Contacts__c vc = new Visit_Contacts__c(Store_Visit__c = storeVisit.Id, Contact__c = cObj.Id, Status__c = 'New');
        insert vc;
    }
   
    
    @AuraEnabled
    public static String getRecordType()
    {
        String RecordTypeName = System.Label.Retail_Contact;
    System.debug('RecordTypeName'+RecordTypeName);       
        RecordType RecordType = [Select Id From RecordType where Name= :RecordTypeName LIMIT 1];
        return RecordType.Id;
    }

}