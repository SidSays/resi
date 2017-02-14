/**
 *This class is to Schedule the RGUOrderBatch 
 * @author Gafoor
 * @date 24/05/2016
 */
global class RGUOrderBatchSchedulable  implements Schedulable {
    Integer batchSize = Integer.valueOf(System.Label.RGUOrderBatchSize);   
 global void execute(SchedulableContext sc) {
    RGUOrderBatch rguBatch = new RGUOrderBatch();
    Database.executeBatch(rguBatch,batchSize);
 }
}