/**
 * Batch/Schedule class to count the number of RGU_Orders and activations for an Account during 
 * the fiscal month
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 11/19/14
 */

global class RGUOrderBatch implements Database.Batchable<sObject>, Database.Stateful {

  private FiscalYearSettings thisFiscalYear;  
  Job_Status__c jobStatus = new Job_Status__c();  
    
  global Database.QueryLocator start(Database.BatchableContext BC) {
     RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :StoreVisitUtility.RECORD_TYPE_DEV_NAME];
     
     jobStatus.Name = 'JobStatus-' + Datetime.now();
     jobStatus.Status__c = 'New';
     jobStatus.Total_Records_Processed__c = 0;
     jobStatus.Total_RGU_Activations_Processed__c = 0;
     jobStatus.Total_RGU_Orders_Processed__c = 0;
     jobStatus.Total_RGU_ORders_Upserted_Today__c = 0;
     jobStatus.Batch_Start_Time__c = Datetime.now();
     jobStatus.Batch_End_Time__c = Datetime.now();
     jobStatus.Comments__c = ' ';
     jobStatus.Number_Of_Fallouts__c = 0;

     insert jobStatus;

    return Database.getQueryLocator([
      SELECT Id, RGU_Orders_This_Fiscal_Month__c, RGU_Activations_This_Fiscal_Month__c, AccountNumber
      FROM Account
      WHERE RecordTypeId = :recordType.Id
      ]);
  }

     global void execute(Database.BatchableContext BC, List<Account> scope) {
       Job_Status__c jobStatus = getJobStatus();      
       this.thisFiscalYear = [SELECT StartDate, EndDate FROM FiscalYearSettings WHERE StartDate <= TODAY AND EndDate >= TODAY];
       Set<String> accountIds = StoreVisitUtility.getFieldSet(scope, 'Id');
       List<Account> accountsToUpdate = new List<Account>();
       
    Map<String, List<RGU_Order__c>> ordersMap = getRGUOrdersForStore(accountIds);
    for (Account account : scope) {
      Decimal totalRGUOrders = 0; 
      Decimal totalRGUActivations = 0;
      if (ordersMap.containsKey(account.Id)) {
        List<RGU_Order__c> ordersForAccount = ordersMap.get(account.Id);
        for (RGU_Order__c order : ordersForAccount) {
          if (isDateInFiscalMonth(order.Order_Date__c)) {
            totalRGUOrders ++;
            jobStatus.Total_Records_Processed__c ++;
            jobStatus.Total_RGU_Orders_Processed__c ++;
          }
          if (order.Activity_Status__c == 'Activated' && isDateInFiscalMonth(order.Activation_Date__c)) {
            totalRGUActivations ++;
            jobStatus.Total_RGU_Activations_Processed__c ++;
            jobStatus.Total_Records_Processed__c ++;
          }
        }
      }
      account.RGU_Orders_This_Fiscal_Month__c = totalRGUOrders;
      account.RGU_Activations_This_Fiscal_Month__c = totalRGUActivations;
      accountsToUpdate.add(account);
    }

    List<Database.SaveResult> results = Database.update(accountsToUpdate, false);
    for (Database.SaveResult result : results) {
      List<Database.Error> errors = result.getErrors();
      for (Database.Error error : errors) {
        jobStatus.Number_Of_Fallouts__c ++;
        if(jobStatus.Comments__c==null){
          jobStatus.Comments__c = error.getMessage() + '\n';
          }else{
          jobStatus.Comments__c += error.getMessage() + '\n';
        }  
      }
    }

    update jobStatus;
  }
  
  public Map<String, List<RGU_Order__c>> getRGUOrdersForStore(Set<String> storeIds) {
    List<RGU_Order__c> rGUOrders = [
      Select Id, Store__c, Activity_Status__c, Activation_Date__c, Order_Date__c
      FROM RGU_Order__c
      WHERE Store__c IN :storeIds];

    return StoreVisitUtility.buildFieldSetMap(rGUOrders, 'Store__c');
  } 

  public Job_Status__c getJobStatus() {
    return [
      SELECT id,Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
        Batch_Start_Time__c, Batch_End_Time__c, Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c,
        Total_RGU_ORders_Upserted_Today__c
      FROM Job_Status__c
      WHERE Status__c = 'New' AND CreatedDate=TODAY AND ID =: jobStatus.id ];
  }

  public Boolean isDateInFiscalMonth(Date rGUOrderDate) {
    Date yearStart = this.thisFiscalYear.StartDate;
    Date today = Date.today();
    Date monthStart;
    List<Date> datesList = new List<Date>();
    for (Integer i = 0; i < 12; i++) {
      datesList.add(yearStart.addMonths(i));
    }
    for (Date startDate : datesList) {
      if (today >= startDate && today < startDate.addMonths(1)) {
        monthStart = startDate; 
      }
    }
    if (rGUOrderDate >= monthStart && rGUOrderDate < monthStart.addMonths(1)) {
      return true;
    }
    else {
      return false;
    }
  }

  global void finish(Database.BatchableContext BC) {
    Job_Status__c jobStatus = getJobStatus();
    jobStatus.Batch_End_Time__c = Datetime.now();
    if (String.isBlank(jobStatus.Comments__c)) {
      jobStatus.Status__c = 'Completed Without Errors';
    }
    else {
      jobStatus.Status__c = 'Completed With Errors';
    }
    for (RGU_Order__c order : getFalloutOrders()) {
      if (isDateInFiscalMonth(order.Order_Date__c) 
        || isDateInFiscalMonth(order.Activation_Date__c)){
        jobStatus.Number_Of_Fallouts__c ++;
      }
    }

    update jobStatus;
  }

  public List<RGU_Order__c> getFalloutOrders() {
    Period currentFiscalMonth=[SELECT StartDate 
    FROM Period
    WHERE Type = 'Month' AND StartDate<=:Date.today() AND EndDate>=:Date.today()];
    return new List<RGU_Order__c>([
      SELECT Id, Activation_Date__c, Order_Date__c
      FROM RGU_Order__c
      WHERE Store__c = null AND (Order_Date__c>=:currentFiscalMonth.StartDate OR Activation_Date__c>=:currentFiscalMonth.StartDate)]);
  }
  
}