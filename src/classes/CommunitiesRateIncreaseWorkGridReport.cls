global with sharing  class CommunitiesRateIncreaseWorkGridReport {
    public MDU_Property__c prop { get; set;}
    

    @RemoteAction
    global static List<Bulk_Service__c> getAccount(String fromDate,String toDate, integer implement,string corporate,string division,string region,string area,string system1) {
      String [] dateParts= fromDate.split('/');
                String fromD;
           if(dateParts.size()==3){
     			String month  = dateParts[0];
       			String day  = dateParts[1];
       			String year = dateParts[2];
            	 fromD = dateParts[2]+'-'+dateParts[0]+'-'+dateParts[1];
           }
        String [] dateParts1= toDate.split('/');
           String toD;
           if(dateParts1.size()==3){
     			String month  = dateParts1[0];
       			String day  = dateParts1[1];
       			String year = dateParts1[2];
            	 toD = dateParts1[2]+'-'+dateParts1[0]+'-'+dateParts1[1];
           }
        String Query= 'SELECT Id,Units__c ,Current_Rate__c,Service_Total__c ,Increase_Amount_Units__c,New_Rate__c,Increase_Amount__c,Increase_Date__c,Notice_Due_Date__c,Bulk_Service__c,Implemented__c,Bulk_Rate_Increase__r.Property__r.Id, Bulk_Rate_Increase__r.Bulk_Account_Numbers__c,Bulk_Rate_Increase__r.Property__r.name,Bulk_Rate_Increase__r.Property__r.Address__c,Bulk_Rate_Increase__r.Property__r.City__c,Bulk_Rate_Increase__r.Property__r.Complex_Code__c,Bulk_Rate_Increase__r.Property__r.House_Misc_Code__c FROM Bulk_Service__c where (Increase_Date__c >'+fromD+' and Increase_Date__c <'+toD+') and Bulk_Rate_Increase__r.Property__r.Corporate__c=\''+corporate+'\' ';
        if(implement==1)
            Query = Query+'and Implemented__c=true ';
        if(implement==0)
            Query = Query+'and Implemented__c=false ';
        if(division ==''){}else{
                 Query = Query+'and Bulk_Rate_Increase__r.Property__r.Property_Division__c=\''+division+'\'';
                    if(region==''){}else{
                       Query = Query+'and Bulk_Rate_Increase__r.Property__r.Property_Region__c=\''+region+'\'';
                        if(area== ''){}else{
                            Query = Query+'and Bulk_Rate_Increase__r.Property__r.Property_Area__c=\''+area+'\'';
                            if(system1== ''){}else{
                               Query = Query+'and Bulk_Rate_Increase__r.Property__r.System__c=\''+system1+'\'';
                               } 
                        } 
                    } 
        }
       query=query+'ORDER BY Increase_Date__c desc limit 1000' ;
        
  	List<Bulk_Service__c> result=database.query(query);
    return result;
            }
 
    @RemoteAction
    global static List<Contract__c> getContract(Id propId) {
        List<Contract__c> resultContract = [Select Id,Property__r.Id,Video_Increase_Period__c,Increase_Amount__c,Video_Increase_Notice__c,Data_Billing_Type__c,Video_Billing_Type__c,Voice_Billing_Type__c,Contract_Status__c,Sub_Status__c,Initial_Effective_Date__c from Contract__c where Property__c =: propId and (Video_Billing_Type__c = 'Bulk' OR Voice_Billing_Type__c = 'Bulk' OR Data_Billing_Type__c = 'Bulk') and Archived__c=false ORDER BY Initial_Effective_Date__c DESC Limit 1];
        return resultContract;
    }
    
    @RemoteAction
   global static void updatebulkServices(List<updateBSData> bsData){
              List<Bulk_Service__c> bsUpdate = new  List<Bulk_Service__c>();
              List<Id> bsid1 =new  List<Id>();
       
       for(updateBSData bulkServiceData:bsData){
         	String [] dateParts= bulkServiceData.increaseDate.split('/');
           date myDate;
           if(dateParts.size()==3){
     			String month  = dateParts[0];
       			String day  = dateParts[1];
       			String year = dateParts[2];
            	 myDate = date.newInstance(Integer.valueof(year), Integer.valueof(month), Integer.valueof(day));
           }else{
                myDate=null;
               
           }
           String [] dateParts1= bulkServiceData.noticeDueDate.split('/');
           date myDate1;
           if(dateParts1.size()==3){
           String month1  = dateParts1[0];
       			String day1  = dateParts1[1];
       			String year1 = dateParts1[2];
            	 myDate1 = date.newInstance(Integer.valueof(year1), Integer.valueof(month1), Integer.valueof(day1));
           }else{
                myDate1=null;
               
           }
               bsUpdate.add(
               new Bulk_Service__c(
                     Id = bulkServiceData.bsId,
       				 Bulk_Service__c =(bulkServiceData.bSName).trim(),
        			 Units__c = Decimal.valueof(bulkServiceData.units),
                     Current_Rate__c= Decimal.valueof(bulkServiceData.currentRate),
       				 Increase_Amount_Units__c= bulkServiceData.increaseAmountUnit,
       				 Increase_Date__c= myDate,
       				 Increase_Amount__c = Decimal.valueof(bulkServiceData.increaseAmount),
        		     Notice_Due_Date__c =myDate1,
        			 Implemented__c = bulkServiceData.implement
                   
                   )
               );
              }
          update bsUpdate;
             }
    
        global class updateBSData{
            
        public Id bsId { get;set;}
        public boolean implement { get;set;}
        public String bSName {get; set;}
        public String units {get; set;}
        public String currentRate {get; set;}
        public String increaseAmount {get; set;}
        public String increaseAmountUnit {get; set;}
        public String increaseDate {get; set;}
        public String noticeDueDate {get; set;}
        
        
            
    }
}