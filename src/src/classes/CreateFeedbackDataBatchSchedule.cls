global class CreateFeedbackDataBatchSchedule implements Schedulable{    
    String obsForm = '';
    global CreateFeedbackDataBatchSchedule(String obsForm){
        this.obsForm = obsForm;
    }
    
    global void execute(SchedulableContext schedulableContext){
        Integer batchSize=1;
        if(!Test.isRunningTest()){
            CreateFeedbackDataBatch inst= new CreateFeedbackDataBatch(obsForm); 
            database.executebatch(inst, batchSize);
        }
    }
}