/*
 * @description A schedulablel wrapper around WaveUserBatch to set the User.WaveUser__c checkbox, based on PSL Assignments
 * @author Ravi Benedetti
 * @date 20170619
 */ 
global class WaveUserSchedulable implements schedulable {
    global void execute (SchedulableContext SC) {
        WaveUserBatch wuBatch = new WaveUserBatch();
        Id wuBatchId = Database.executeBatch(wuBatch);
    }
}