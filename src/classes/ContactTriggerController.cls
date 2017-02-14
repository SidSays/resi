/***************************************************************************************************************************************
    * Author     : Gaurav Aggarwal
    * Date       : 03-Oct-2013
    * Description: Contains Supporting actions for Contact Triggers
    * Requirement:
    * History
    Version             : 1.0
    Author Last Updated : Gaurav Aggarwal
    PROJECT             : Direct Sales
    ***************************************************************************************************************************************/
    public class ContactTriggerController{
    /*
    //Data Member//
    Start of commenting - As Contact Trigger is Inactive and this class is calling from contact trigger that is why commenting the class to improve the code coverage
    private static final string OBJECT_TYPE = 'Contact';    
    private static final string CONSTANT_HOME = 'HOME';
    private static final string LABEL_NAME_SPLIT = ';';
    end of comment
    */
    /**
    * @Description: This method populates Contact name on Account.
    * @Author: Gaurav Aggarwal, Accenture
    * @Date: 03-Oct-2013
    * @Param: Trigger.New
    * @Return: void.
    * @Modified: Abhishek Mathur, Accenture 
    * @Description: Modified to check the Record type and update the logic to exclude MDU record type
    */
    /*  Start of commenting - As Contact Trigger is Inactive and this class is calling from contact trigger that is why commenting the class to improve the code coverage
    
    public static void populateContactOnAccount(){
    
    //Record Type check for MDU
    String labelName = System.Label.XfinityContactRecordType;  
    Set<String> recordTypeSet = new Set<String>();
    if(!string.IsBlank(labelName)){
    for(String str : labelName.split(LABEL_NAME_SPLIT)){
        recordTypeSet.add(Schema.SObjectType.Contact.getRecordTypeInfosByName().get(str).getRecordTypeId());
    }
    } 
    Map<Id,Account> accMap = new Map<Id, Account>();
    for (Contact con: (List<Contact>)Trigger.new){
    //Updating the flow to exclude MDU Record Type 
    if(recordTypeSet.isEmpty() || !recordTypeSet.contains(con.RecordTypeId)){
        Account acc = new Account (Id = con.AccountId,Customer__c = con.Id);
        accMap.put(acc.Id,acc);
    }
    }
    update accMap.values();
    } End of comment
    */
    
    /**
    * @Description: This method updates Account name when a related Contact name is updated.
    * @Author: Gaurav Aggarwal, Accenture
    * @Date: 03-Oct-2013
    * @Param: Trigger.New
    * @Return: void.
    * @Modified: Abhishek Mathur, Accenture 
    * @Description: Modified to check the Record type and update the logic to exclude MDU record type
    */
    /*Start of commenting - As Contact Trigger is Inactive and this class is calling from contact trigger that is why commenting the class to improve the code coverage
    public static void updateAccountName(){
    //Record Type check for MDU
    String labelName = System.Label.XfinityContactRecordType;  
    Set<String> recordTypeSet = new Set<String>();
    if(!string.IsBlank(labelName)){
    for(String str : labelName.split(LABEL_NAME_SPLIT)){
        recordTypeSet.add(Schema.SObjectType.Contact.getRecordTypeInfosByName().get(str).getRecordTypeId());
    }
    } 
    
    Map<Id,Account> acctMap = new Map<Id, Account>();
    for (Contact con: (List<Contact>)Trigger.new){
    //Updating the flow to exclude MDU Record Type 
    if(recordTypeSet.isEmpty() || !recordTypeSet.contains(con.RecordTypeId)){
        if(Trigger.isUpdate && (con.LastName != ((Map<Id,Contact>)Trigger.oldMap).get(con.Id).LastName)){
            Account acct = new Account(Id= con.AccountId, Name = con.LastName+' '+CONSTANT_HOME);
            acctMap.put(acct.Id,acct);
        }
    }           
    }
    update acctMap.values();
    } End of comment
    
    /**
    * @Description: Trigger on standard Contact Object to display validation message for primary contact on account.
    * @Author: Ashish Sonawane, Accenture
    * @Date:   11-December-2014  
    * @Param: Trigger.New
    * @Return: void.
    */
    /*Start of commenting - As Contact Trigger is Inactive and this class is calling from contact trigger that is why commenting the class to improve the code coverage
    public static void primaryContactValidationOperation(){
    ContactTriggerOperation.showValidationOnContactBeforeInsertUpdate();
    }End of comment */
    
    public static void updateBirthdate(List<Contact> contacts){
    for(Contact con : contacts){    
        if(con.Birthdate__c != null){
            List<String> birthday = con.Birthdate__c.split('/');
            String bday = birthday[0];
            String mday = birthday[1];
            if(bday.length() == 1){
                bday = '0' + bday;
              }
            
            if(mday.length() == 1){
                mday = '0' + mday;
                }
                con.Birthdate__c = bday + '/' + mday;
            }
        }    
    }  
}