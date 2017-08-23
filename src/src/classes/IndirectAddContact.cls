public class IndirectAddContact {
    
    @AuraEnabled
    public static List<Contact> displayContacts(String storeId)
    {
        System.debug('in fetch contact method');
      List<Contact> cntList = [Select Id, firstName, LastName, Email, Phone from Contact where AccountId = : storeId order by CreatedDate DESC];
        return cntList;
        
    }

}