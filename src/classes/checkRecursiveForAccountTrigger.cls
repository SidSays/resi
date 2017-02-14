public Class checkRecursiveForAccountTrigger{
    private static boolean fisrtRun = true;
    public static boolean doNotRunTwice(){
        if(fisrtRun){
            fisrtRun=false;
            return true;
        }else{
            return fisrtRun;
        }
    }
}