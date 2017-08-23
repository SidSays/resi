public with sharing class displayAccountHistory {
    
    //Declaration
    public static string queryStringAddressId{get;set;}
    //public static string billingHouseKey{get;set;}
    //public static string billingSystem{get;set;}
    public static List<AccountWrapp> accountTempList{get;set;}
    public static List<ContactWrapp> contactTempList = new List<ContactWrapp>();
    public static List<AccountWrapp> AccountWrappList = new List<AccountWrapp>();
    
    //getting the Store type Account Id
    Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Store').getRecordTypeId();
    //class constructor 
    public  displayAccountHistory(ApexPages.StandardController controller){
        queryStringAddressId = apexpages.currentpage().getparameters().get('Id');
        //billingHouseKey = apexpages.currentpage().getparameters().get('bhk');
        //billingSystem = apexpages.currentpage().getparameters().get('bs');
        
        List<ESPAccountContactHistory> wrapObjTemp = getBillingArrangement.getBillingArrangementRequest(queryStringAddressId);
        AccountWrapp tempAccountWrapp;
        list <ContactWrapp> contactWrapplist;
        ContactWrapp contactWrappObj;
        List<String> tempshow = new list<String>();
        if(wrapObjTemp!=null){
          for(ESPAccountContactHistory ObjTemp :wrapObjTemp ){
             tempAccountWrapp = new AccountWrapp();
              contactWrappObj = new  ContactWrapp();
              contactWrapplist= new list<ContactWrapp>();
              tempAccountWrapp.BillingAccountNumber = ObjTemp.billingAccountNumber;
              tempAccountWrapp.accountName = ObjTemp.LastName+ 'HOME';
              tempAccountWrapp.CustomerStatus= ObjTemp.customerStatus;
              //system.debug('In VF Page ObjTemp.lastInstallDate' +ObjTemp.lastInstallDate);
              String [] dateParts= ObjTemp.lastInstallDate.split('/');
              String lastInstallDate;
              //system.debug('VF Iam in dateParts.size()'+dateParts.size());
               if(dateParts.size()==3){
              // system.debug('VF Iam in DATEPART'+dateParts.size());
                String [] timeParts= dateParts[2].split(':');
                   lastInstallDate=dateParts[0]+'/'+dateParts[1]+'/'+dateParts[2]+' ';
                  // integer hrs=integer.valueOf(timeParts[0]);
                  /* if(hrs>12)
                   {
                       lastInstallDate+=(hrs-12)+':'+timeParts[1]+' PM';
                   }else
                       lastInstallDate+=hrs+':'+timeParts[1]+' AM';*/
                       
               }else {
               //system.debug('VF Iam in else Part');
               lastInstallDate='';
               }
               //system.debug('In VF Page lastInstallDate' +lastInstallDate);
              tempAccountWrapp.LastInstallDate = lastInstallDate;
              tempAccountWrapp.PastDueBalance = ObjTemp.balance;
              tempAccountWrapp.TotalMonthlyRate = ObjTemp.monthlyRateTotal;
              tempAccountWrapp.InstallationStatus = ObjTemp.installationStatus;
              String [] datedisconnected= ObjTemp.disconnectedDate.split('/');
              String DisconnectedDate;
               if(datedisconnected.size()==3){
                String [] timeParts1= datedisconnected[2].split(':');
                   DisconnectedDate=datedisconnected[0]+'/'+datedisconnected[1]+'/'+datedisconnected[2]+' ';
                  /* integer hrs1=integer.valueOf(timeParts1[0]);
                   if(hrs1>12)
                   {
                       DisconnectedDate+=(hrs1-12)+':'+timeParts1[1]+' PM';
                   }else
                       DisconnectedDate+=hrs1+':'+timeParts1[1]+' AM';*/
                       
               }else DisconnectedDate='';
              tempAccountWrapp.LastDisconnectedDate = DisconnectedDate;
              tempAccountWrapp.WriteOffAmount = ObjTemp.writeOffAmount;
              contactWrappObj.FirstName = ObjTemp.FirstName;
              contactWrappObj.LastName = ObjTemp.LastName;
           // contactWrappObj.ContactPhone = ObjTemp.phone;
              String emailString='';
              for(ESPAccountContactHistory.Email wrapTemp: ObjTemp.Email){
                  emailString=emailString+wrapTemp.email+',';
              }
              emailString=emailString.substringBeforeLast(',');
              contactWrappObj.Email = emailString;
              
              String phoneString='';
              string areacodeString='';
              String extenString='';
              for(ESPAccountContactHistory.Phone wrapPhoneTemp: ObjTemp.Phone){
                  for(ESPAccountContactHistory.Telephone telephonetemp :wrapPhoneTemp.telephoneNumber ){
                      
                      phoneString=phoneString+telephonetemp.phoneNumber+',';
                      areacodeString=areacodeString+telephonetemp.areaCode;
                      extenString=extenString+telephonetemp.extension;
                  }
              }
              phoneString=phoneString.substringBeforeLast(',');
              // areacodeString=areacodeString.substringBeforeLast(',');
              // extenString=extenString.substringBeforeLast(',');
              contactWrappObj.Phone = phoneString;
               contactWrappObj.areaCode = areacodeString;
               contactWrappObj.extension = extenString;
              contactWrapplist.add(contactWrappObj);
              tempAccountWrapp.contactlst=contactWrapplist;
              AccountWrappList.add(tempAccountWrapp);
           }
           // accountTempList = AccountWrappList;
        }
       // else {
        //   system.debug('**accountTempList **'+accountTempList); 
       // }
        accountTempList = AccountWrappList;
        //system.debug('**accountTempList **'+accountTempList);
    }
    
    /*
    * Wrapper class holding Account Data.
    */
    public class AccountWrapp{
        public string accountName{get;set;}
        public string AccountNumber{get;set;}
        public string CustomerStatus{get;set;}
        public string Type{get;set;}
        public string LastInstallDate{get;set;}
        public string BillingAccountNumber{get;set;} 
        public string AccountSource{get;set;}
        public String PastDueBalance{get;set;}
        public String InstallationStatus{get;set;}
        public String TotalMonthlyRate{get;set;}
        public String LastDisconnectedDate{get;set;}
        public String WriteOffAmount{get;set;}
        public List<ContactWrapp> contactlst{get;set;}
        
       
    }
     /*
    * Wrapper class holding Contact Data.
    */
    public class ContactWrapp{
        //public string contactName{get;set;}
        public String Phone{get;set;}
        public String Email{get;set;}
        public string FirstName{get;set;}
        public string LastName{get;set;}
        public String areaCode{get;set;}
        public String extension{get;set;}
    }
    
}