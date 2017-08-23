public with sharing class BatchUtils {
    
     /**
    * @Description: This method sends an email to the user who created batch job if batch job has any errors.
    * @Author: Pavan Jasthi, Acumen Solutions
    * @Date: 4/7/2104
    * @Param: Database.BatchableContext, job name
    * @Return: void.
    */
   /* public static void batchEmailSuccess(Database.BatchableContext apexJob, string apexJobName){
        string messageBody;
        string messageSubject;
        messageSubject = 'Apex Batch Job '+ apexJobName + ' is Complete';
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                                    TotalJobItems, CreatedBy.Email
                                    from AsyncApexJob where Id =:apexJob.getJobId()];
        if (a.NumberOfErrors>0){ 
            messageBody ='<html><body><h2>The batch apex job '+ apexJobName +' processed successfully.</h2><br/><br/>';
            messageBody = messageBody + 'No of Errors:- '+ a.NumberOfErrors +'<br/>';
            messageBody = messageBody + 'Job Items Processed:- '+ a.JobItemsProcessed + '<br/>';
            messageBody = messageBody + 'Total Job Items:- '+ a.TotalJobItems + '<br/></body></html>';
                  
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject(messageSubject);
            mail.setHtmlBody(messageBody);
            try{
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});  
            }
            catch(Exception e){
                System.debug('****Error sending an email : '+e.getMessage());
            }
        }
    }*/
}