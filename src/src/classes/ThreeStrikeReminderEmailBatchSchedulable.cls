global with sharing class ThreeStrikeReminderEmailBatchSchedulable implements Schedulable {
    
    public Integer batchSize {get;set;}
    
    /**
     * @description - Constructor, initialises the batch size.
     */
    global ThreeStrikeReminderEmailBatchSchedulable() {
        batchSize = 50;
    }
    
    /**
     * @description - Calls batch process with configured batch size.
     * @param SchedulableContext schContext 
     */
    global void execute(SchedulableContext schContext) {
        ID batchProcessId;
        ThreeStrikeReminderEmailBatch batch = new ThreeStrikeReminderEmailBatch();
        batchProcessId = Database.executeBatch(batch, batchSize);
    }
}