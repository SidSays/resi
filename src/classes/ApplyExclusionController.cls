/**
* Class Name: ApplyExclusionController 
* Author: Amitkumar Bangad, Accenture
* Date: 07-May-2013 
* Requirement # Request Id: 203
* Description: Contains supporting actions for VF page ApplyExclusion
* Last Modified :
*/
public class ApplyExclusionController {
        
    public List<Exclusion__c> results{get;set;} // search results
    public String whereCondition = '';
    public String searchString { get; set; }
    public String userRegion;
    public String expiredStatus;
    
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
    * @Description: Constructor for ApplyExclusionController class
    * @Param: None
    */
    public ApplyExclusionController () {
        // get the current search string
        searchString = System.currentPageReference().getParameters().get('lksrch');
        expiredStatus = Label.Exclusion_Expired;     
        user currentUser = [Select id,DefaultDivision from User where id =: UserInfo.getUserId()];
        if(currentUser!=null){
            Division div = [Select Id, Name from Division where Id=: currentUser.DefaultDivision];
            userRegion = div.Name;
        }
        results = runSearch(searchString,userRegion);         
    }
    
    /**
    * @description: search for Exclusions as per the search text by user
    * @return: Search Results
    * 
    */  
    private List<Exclusion__c> runSearch(String searchText, String Region) {
        //prepare query string for complex serarches & prevent injections
        whereCondition = '';
        String soql = ' Select id, name,Status__c ,Non_Marketable_Address__c,Do_Not_Knock__c,Complex_Codes__c, Installation_Status__c, Expiration_Date__c , Past_Due_Balance__c,Nodes__c,Region__c from Exclusion__c';
        whereCondition = whereCondition + ' ' + 'Status__c !=\'' + expiredStatus+ '\'';
        if(searchString != null && searchString != ''){
            searchString = searchString.replaceAll('\\*','%');
            whereCondition = whereCondition +  'and name LIKE \'' + '%' + searchString +'%\'';
        } 
        if(userRegion != null && userRegion != ''){
            if(userRegion != Label.DivisionGlobal){
                 whereCondition = whereCondition + 'and Region__c includes  (\''+userRegion+'\')';
            }
        }
        soql = soql + ' '+  'where' +  whereCondition;
        return database.query(soql);                   
    }
    /**
    * @description: called by seach button click on Page
    * @return: null
    * 
    */
    public PageReference Search() {
        results = runSearch(searchString,userRegion);       
        return null;        
    }
    
    /**
    * @description return flag is Search Result Empty or not
    * @return: boolean True if list is empty
    * 
    */
    public Boolean getIsResultEmpty(){
        Boolean returnBoolean = false;
        if(results==null || results.size()<1){
            returnBoolean=true;
        }
        return returnBoolean;            
    }   
}