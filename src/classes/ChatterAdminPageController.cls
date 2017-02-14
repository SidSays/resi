/*************************************************************************************************************************************
Name: ChatterAdminPageController
Description: Controller for VF page ChatterAdminPage
Author: Animesh Datta && Malay Desai
Date:  08 Feb 2016
*************************************************************************************************************************************/

public class ChatterAdminPageController {
    public string searchGrpString{get;set;}
    public List<CollaborationGroup> grpList {get;set;}
    public string selectedGroup {get;set;}
    public User user{get;set;}
    //public CollaborationGroupMember SelectedUser{get;set;}
    public List<UserWrapper> userLst {get; set;}
    //public Integer noOfRecords{get; set;}
    //public Integer size{get;set;}
    public Id userId{get;set;}
    private ApexPages.StandardController stdCtrl;  
    //Pagination Variables
    private static final Integer PAGE_SIZE = 50;
    private static final Integer PAGE_SIZE_1 = 1;
    //pagination information
    public Integer page{get;set;}
    public Integer totalRecords{get;set;}
    public Integer totalPages{get;set;}
    public Integer startIdx{get;set;}
    public Integer endIdx{get;set;}
    
    //Constructor to get User Id from Page and initialize pagination page number
    
    public ChatterAdminPageController (ApexPages.StandardController stdController){
        stdCtrl = stdController;
        this.user = (User)stdController.getRecord();
        userId = user.id;
        this.userLst = new List<UserWrapper>();      
        //set initial page
        this.page = PAGE_SIZE_1;
    }
    
    //Get list of matching groups based text entered in search box
    
    public void searchGroup(){
    grpList = new List<CollaborationGroup>();
    //grpList.clear();
        try{
            String queryStr='%' + searchGrpString + '%';
            if(!String.isBlank(searchGrpString) && searchGrpString.length()>=4){
                grpList = [SELECT Id, Name,OwnerId FROM CollaborationGroup WHERE Name LIKE :queryStr];
                if(grpList.isEmpty()){
                    userlst.clear();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ChatterAdminPageControllerMsg1));
                }
            }
            if(searchGrpString.length()<4 && searchGrpString.length()!=0){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ChatterAdminPageControllerMsg2));
                    userlst.clear();
                    grpList.clear();
                }
            if(searchGrpString.length()==0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ChatterAdminPageControllerMsg3));
                userlst.clear();
                grpList.clear();
            }
        }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ChatterAdminPageControllerMsg7)); }
    }

    public List<SelectOption> getGroupList(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        if(grpList != null && !grpList.IsEmpty()){           
            for(CollaborationGroup grp: grpList){
                options.add(new SelectOption(grp.Id,grp.Name));
            }
        }        
        return options;
    }
    
    //Add selected user to the selected Group

    public void addToGroup() {
        try{
            User usrRec = (User)stdCtrl.getRecord();
            userId = usrRec.User_Lookup__c;
            List<ID> userIDList = new List<ID>();
            for(User user: [SELECT Id FROM USER WHERE ID =:userId]){
                userIDList.add(user.Id);
            }
            if(selectedGroup!=null && userId!=null){
                List<CollaborationGroupMember> addedMember = [SELECT Id, CollaborationGroupId, MemberId FROM CollaborationGroupMember WHERE CollaborationGroupId =: selectedGroup and MemberId =: userId];
                if(addedMember.size()>0){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ChatterAdminPageControllerMsg4));
                }
                else{
                    addUsersToGroup(selectedGroup,userIDList,userId);
                }
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ChatterAdminPageControllerMsg5));
            }
        }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ChatterAdminPageControllerMsg7));}
    }
    
    //Add selected user to the selected group; this method is being called from method: addToGroup

    public void addUsersToGroup(String groupId, List<Id> userIDList, Id userId){
        boolean insertSuccess = false;
        boolean insertFail = false;
        List<Database.SaveResult> insertGroupMember;
        try{
            List<CollaborationGroupMember> gmList = new List<CollaborationGroupMember>();
            if(groupId!=null && !userIDList.isEmpty()){
                CollaborationGroupMember gm = new CollaborationGroupMember();
                for(ID id: userIDList){
                    gm.CollaborationGroupId = groupId;
                    gm.MemberId = userId;
                    gmList.add(gm);
                } 
                if(gmList.size()>0){  
                    insertGroupMember = Database.Insert(gmList,false);
                }
            }
            for (Database.SaveResult dsr : insertGroupMember ) {
                if (dsr.isSuccess()) insertSuccess = true;   
                if(!dsr.isSuccess()) insertFail = true;
            }
            if(insertSuccess) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,Label.ChatterAdminPageControllerMsg6));
            if(insertFail) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ChatterAdminPageControllerMsg7));

        }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ChatterAdminPageControllerMsg7));}
    }   
    
    //Remove selected user(s) from selected Group
    
    public void removeUsersFromGroup(){
        try{
            List<CollaborationGroupMember> removeGrpMem = new List<CollaborationGroupMember>();
            Set<Id> userId = new Set<Id>();
            List<User> delUserLst = new List<User>();
            List<UserWrapper> delUserWrap = new List<UserWrapper>();
            for(UserWrapper wrap: userLst){
                if(wrap.selected){
                    delUserLst.add(wrap.usr);
                }
            }
            if(delUserLst.size()>0){
                for(User ur: delUserLst){
                    userId.add(ur.id);
                }
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ChatterAdminPageControllerMsg11));
            }
            List<Database.DeleteResult> dbDrs;
            boolean success = false;
            boolean fail = false;          
            if(selectedGroup!=null && userId!=null ){
                for(CollaborationGroupMember delGrpMem: [SELECT Id, CollaborationGroupId, MemberId FROM CollaborationGroupMember WHERE CollaborationGroupId =: selectedGroup and MemberId =: userId]){                   
                        removeGrpMem.add(delGrpMem);
                }
                if(removeGrpMem.size()>0){
                    dbDrs = Database.Delete(removeGrpMem, false);
                }             
            }
           
            for (Database.DeleteResult drs : dbDrs) {
                if (drs.isSuccess()) {success = true;}   
                else {fail = true;}
            }
            if(success) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,Label.ChatterAdminPageControllerMsg10));
            if(fail) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ChatterAdminPageControllerMsg9));

        }catch(Exception e){}
    }
    
    //Wrapper class for input checkbox and User record
    
    public class UserWrapper {
        public User usr {get;set;}
        public Boolean selected {get;set;}
        public UserWrapper(User us) {
            usr = us;
            selected = false;            
        }
    }   
    
    //get users present in the selected group; this method get called on change of group selection, on click Add User to Group button, Remove Users from Group button
    
    public void getUsers() {
        try{       
            this.startIdx = (this.page-1)*PAGE_SIZE;
            this.endIdx = this.page*PAGE_SIZE;
            this.totalRecords = 0;
            //userLst = new List<UserWrapper>();
            this.userLst.clear();
            Set<Id> userIDs =new Set<Id>();
            String userType = Schema.SObjectType.User.getKeyPrefix();
            for (CollaborationGroupMember m : [Select Id, CollaborationGroupId, MemberId From CollaborationGroupMember Where CollaborationGroupId = :selectedGroup]){
                if (((String)m.MemberId).startsWith(userType)){
                    userIDs.add(m.MemberId);
                }
            }
            for(User u: [SELECT Id, FirstName, LastName, Email, ManagerId,Manager.Name,isActive, Profile.Name FROM USER WHERE ID =: userIDs ORDER BY FirstName ASC]) {
                if(this.totalRecords>=this.startIdx && this.totalRecords<this.endIdx){   

                    this.userLst.add( new UserWrapper(u) );
                }
                    this.totalRecords++;
            }
            Decimal pages = Decimal.valueOf(this.totalRecords);
            pages = pages.divide(Decimal.valueOf(PAGE_SIZE), 2);
            this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);       
            this.startIdx++;       
            //adjust end index
            if(this.endIdx>this.totalRecords){
                this.endIdx = this.totalRecords;
            }                
            if(userLst.isEmpty() && selectedGroup!=null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.ChatterAdminPageControllerMsg8));
            }                
        }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ChatterAdminPageControllerMsg7));}
    }
    
    
    //Pagination: call on click of command link Next
    
    public void doNext(){

        if(getHasNext()){
            this.page++;
            getUsers();
        }
    }

    /*
    *   advance to previous page
    */
    
    public void doPrevious(){
        if(getHasPrevious()){
            this.page--;
            getUsers();
        }
    }
    
     //Pagination: call on click of command link First: return to First page
    
    public void doFirst(){
        if(getHasPrevious()){
            this.page = PAGE_SIZE_1;
            getUsers();
        }
    }
    
     //Pagination: call on click of command link Last: Reach to Last page
    
    public void doLast(){

        if(getHasNext()){
            this.page= totalPages;
            getUsers();
        }
    }

    /*
    *   returns whether the previous page exists
    */
    public Boolean getHasPrevious(){
        if(this.page>1){
            return true;
        }
        else{
            return false;
        }
    }

    /*
    *   returns whether the next page exists
    */
    public Boolean getHasNext(){
        if(this.page<this.totalPages){
            return true;
        }
        else{
            return false;
        }
    }  
}