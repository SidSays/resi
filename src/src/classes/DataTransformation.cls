/**
    * Name: DataTransformation
    * Description: To perform data transformation in salesforce for incoming data via API or data loads from externals.
    * return: Updated Records
    **/
    
public class DataTransformation{
    // Method to transform last install date for accounts that are having it prior to 1963 (Comcast Foundation Day)
    public static void dataTransform(List<Account> accounts){
    // Declarations 
       List <Account> accountlist = new List<Account>();
       List <Account> updateList = new List <Account>();
       accountlist = [select id, Last_Install_Date__c, Type from account where id IN: accounts];
       //system.debug('*****'+accountlist);
        try{
            if(!accountlist.IsEmpty()){ 
                for(Account acc : accountlist){
                        if((acc.Last_Install_Date__c.year() < Integer.valueof(System.Label.Comcast_Foundation_Date))&& (acc.Type!= System.Label.Account_Type))
                        {                            
                            acc.Last_Install_Date__c = null;
                            updateList.add(acc);
                        }                                              
                }                              
              }
           //system.debug('*****'+updateList);
             database.update(updateList) ;
           }
            catch(exception ex){
            system.debug('EXCEPTION Occurred'+ex.getmessage());
        }
    }   
}