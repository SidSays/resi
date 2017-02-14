global class WalkAlongController {

    


    global class Xsp{
        public String name {get; set;}
        public Id id {get; set;} 
        public Xsp(String name,Id id){
            this.name=name;
            this.id=id;
        }       
    }

    global class WalkAlongData{
        public String requestId {get; set;}
        public String overallNotes {get; set;}
        public String overallNotesQnId {get; set;}
        public String knocks {get; set;}
        public String knocksQnId {get; set;}
        public String contacts {get; set;}
        public String contactsQnId {get; set;}
        public String starts {get; set;}
        public String startsQnId {get; set;}
        public String areaOfFocus {get; set;}
        public String areaOfFocusQnId {get; set;}
        public String areaOfFocusNotes {get; set;}
        public String areaOfFocusQnNotesId {get; set;}
        public String selectedXSP {get; set;}
        public List<Category> categories {get; set;}
        public Boolean walkAlongStarted {get; set;}
        public Boolean walkAlongStopped {get; set;}
        public String startTime {get; set;}
        public String endTime {get; set;}
        public Boolean showNotes {get; set;}
        public String lastSavedDate {get; set;}
        public Double score {get; set;}
        public Integer scorePct {get; set;}
        public String overallRating {get; set;}
        public void addCategory(Category catg){
            if(this.categories==null){
                this.categories=new List<Category>();
            }
            this.categories.add(catg);
        }

    }

    global class Category{
        public String category {get; set;}
        public String text {get; set;}
        public String rating {get; set;}
        public List<Question> questions {get; set;}
        public Boolean showNotes {get; set;}
        public String categoryQnId {get; set;}
        public void addQuestion(Question qn){
            if(this.questions==null){
                this.questions=new List<Question>();
            }
            this.questions.add(qn);
        }
    }

    global class Question{
        public String name {get; set;}
        public String text {get; set;}
        public String rating {get; set;}
        public String notes {get; set;}
        public Boolean showNotes {get; set;}
        public Boolean showHelpText {get; set;}
        public String qnId {get; set;}
        public String qnNotesId {get; set;}
     
     }
    
    @RemoteAction
    global static List<Xsp> getXSPList() {
        List<Xsp> xspList = new List<Xsp>();
        for(User usr:[select Id,Name from User where (ManagerId=:UserInfo.getUserId() or Manager.ManagerId=:UserInfo.getUserId()) and IsActive=true and UserPermissionsWorkDotComUserFeature = true and Profile.Name =: Label.DSRProfileName]) // Updated the query for US609427- WalkAlong Form Enhancements
        {
            xspList.add(new Xsp(usr.Name,usr.Id));
        }
        return xspList;
    }

    @RemoteAction
    global static WalkAlongData saveData(WalkAlongData walkAlongData) {
        System.debug(walkAlongData);
        return WalkalongUtils.saveSubmitFeedback(walkAlongData,false);  
    }

    @RemoteAction
    global static WalkAlongData submitWalkAlong(WalkAlongData walkAlongData) {
        System.debug(walkAlongData);
        return WalkalongUtils.saveSubmitFeedback(walkAlongData,true);  
    }

    @RemoteAction
    global static WalkAlongData getFeedbackForXsp(String xspId) {
        return WalkalongUtils.getFeedbackForXsp(xspId);  
    }

    


}