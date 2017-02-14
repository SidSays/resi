/**
* Class Name: PlanAssignmentController
* Author: Amitkumar Bangad, Accenture
* Date: 10-May-2013 
* Requirement # Request Id: 138  
* Description: This class contains controller action for PlanAssignment VF page (Team).
* Last Modified :
*/
public class PlanAssignmentController {
       
    public String searchString { get; set; }
    public String userRegion { get; set; }
    public String userId { get; set; }
    public list<User> userResults {get; set;}
    public list<Team__c> otherTeamResults {get; set;}
    public list<Team__c> myTeamResults {get; set;}
    
    /**
    * @description: Constructor
    * @return: none
    * 
    */
    public PlanAssignmentController (){
        searchString = System.currentPageReference().getParameters().get('lksrch');  
        user currentUser = [Select id,DefaultDivision from User where id =: UserInfo.getUserId()];
        if(currentUser!=null){
            Division div = [Select Id, Name from Division where Id=: currentUser.DefaultDivision];
            userRegion = div.Name;
            userId = UserInfo.getUserId();
        }
        myTeamResults = runMyTeamSearch(searchString,userId);
    }
    
    /**
    * @description: action on Search button on VF page
    * @return: null
    * 
    */
    public PageReference Search() {
        myTeamResults = runMyTeamSearch(searchString,userId);
        if(searchString != null && searchString != ''){
            otherTeamResults = runOtherTeamSearch(searchString,userId);
        }
        return null;
    }
    
    /**
    * @description: search Logged in Users Team 
    * @return: Team List
    * 
    */
    private List<Team__c> runMyTeamSearch(String searchText, String userId) {
    // TODO prepare query string for complex serarches & prevent injections
        String teamSoql = ' Select id, name,Supervisor__c, Region__c from Team__c';
        String teamWhereClause = '';
        teamWhereClause =  ' where Supervisor__c = \'' + userId + '\'';
        if(searchString != null && searchString != ''){
            searchString = searchString.replaceAll('\\*','%');
            teamWhereClause = teamWhereClause +  ' and name LIKE \'' + '%' + String.escapeSingleQuotes(searchString) +'%\'';
        }
        teamSoql = teamSoql + teamWhereClause + ' limit 40';
        return database.query(teamSoql); 
    }
    
    /**
    * @description: search Other than Logged in Users Team 
    * @return: Team List
    * 
    */
    private List<Team__c> runOtherTeamSearch(String searchText, String userId) {
        //prepare query string for complex serarches & prevent injections
        String teamSoql = ' Select id, name,Supervisor__c, Region__c from Team__c';
        String teamWhereClause = '';
        teamWhereClause =  ' where Supervisor__c != \'' + userId + '\'';
        teamWhereClause = teamWhereClause + ' and Region__c =\''+userRegion+'\'';
        if(searchString != null && searchString != ''){
            searchString = searchString.replaceAll('\\*','%');
            teamWhereClause = teamWhereClause +  ' and name LIKE \'' + '%' + String.escapeSingleQuotes(searchString) +'%\'';
        }
        teamSoql = teamSoql + teamWhereClause + ' limit 40';
        return database.query(teamSoql); 
    }
    
    /**
    * @description: used by the visualforce page to send the link to the right dom element
    * @return: String returns url lkfm(form) paramter value
    * 
    */
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('lkfm');
    }

    /**
    * @description: used by the visualforce page to send the link to the right dom element for the text box
    * @return: String returns url lknm paramter value
    * 
    */
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('lknm');
    }
    
    /**
    * @description return flag is Search Result Empty or not
    * @return: boolean True if list is empty
    * 
    */
    public Boolean getIsTeamResultEmpty(){
        Boolean returnBoolean = false;
        if(myTeamResults ==null || myTeamResults.size()<1){
            returnBoolean=true;
        }
        return returnBoolean;
            
    }
  
    /**
    * @description return flag is Search Result Empty or not
    * @return: boolean True if list is empty
    * 
    */
    public Boolean getIsOtherTeamResultEmpty(){
        Boolean returnBoolean = false;
        if(otherTeamResults ==null || otherTeamResults.size()<1){
            returnBoolean=true;
        }
        return returnBoolean;
            
    }
}