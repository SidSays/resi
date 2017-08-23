public Class CheckRecursive{
    private static boolean run = true;
    private static boolean runValidation = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    
    public static boolean runOnceForClosedWonValidation(){
        if(runValidation){
            runValidation = false;
            return true;
        }else{
            return runValidation;
        }
    }
}