global class rallyScheduler implements Schedulable{

    public static String sched = '0 00 9 * * ?'; 

    global static String scheduleMethod() {
        rallyScheduler SC = new rallyScheduler(); 
        return System.schedule('Rally Batch Job ID', sched, SC);
    }

    global void execute(SchedulableContext sc) {

        batchCaseRallyUpdate batchapex = new batchCaseRallyUpdate();
        id batchprocessid = Database.executebatch(batchapex,5);
    }
}