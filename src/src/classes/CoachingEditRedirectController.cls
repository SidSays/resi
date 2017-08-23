/******************************************************************************************************************
 * Author     : Malay Desai
 * Date       : 4/4/2017
 * Description: Controller Extension for two VF pages - CoachingEdit & CoachingEditRedirect
 * @Last Modified By: Malay Desai
 * @User Story: US1061632(Coach for CAR/Direct: Default values for Create Coaching)
 * @Last Modified Date: 4/6/2017  
 ********************************************************************************************************************/
public class CoachingEditRedirectController{
    public PageReference pgRef;
    public Profile pName;
    public User coach{get;set;}
    public User personCoached{get;set;}
    private static final String COACHING_EDIT_URL = '/0WD/e';
    private static final String COACHING_LIST_URL = '/0WD/o';
    private static final String RET_URL = 'retURL';
    private static final String NO_OVERRIDE = 'nooverride';
    private static final String ONE = '1';
    
    //Constructor
    public CoachingEditRedirectController(ApexPages.StandardController controller) {
        pName=[SELECT Name FROM Profile WHERE id=:UserInfo.getProfileId() LIMIT 1];
        personCoached = [SELECT Id,Name,ManagerId,Manager.Name FROM User WHERE id =: UserInfo.getUserId() LIMIT 1];
        
        if(personCoached != null){
        	if(personCoached.ManagerId != null){
        		coach = [SELECT Id, Name, IsActive FROM User WHERE id =:personCoached.ManagerId LIMIT 1];
        	}
        }
    }
    
    //page load action method from  CoachingEditRedirect
    public PageReference redirectBasedOnProfile(){
	     if(pName.Name == Label.DSRProfileName || pName.Name == Label.Goal_Xfinity_CAR){
	        pgRef = page.CoachingEdit;            
	     } else {
			pgRef= new PageReference(COACHING_EDIT_URL);
	
	        pgRef.getParameters().put(RET_URL, new PageReference(COACHING_LIST_URL).getURL());  
	        pgRef.getParameters().put(NO_OVERRIDE, ONE); 
	        pgRef.setRedirect(true);
         }
        return pgRef;
    }
    
    //called when save button is called from CoachingEdit
    public PageReference saveRecord(){
    	PageReference pgRef = ApexPages.currentPage();
    	WorkCoaching coaching;
    	try{
    		if(this.coach.isActive){
    			coaching = new WorkCoaching(CoachId=this.coach.Id, CoachedId=this.personCoached.Id);
	    		Database.saveResult sr = database.insert(coaching);
	    		if(sr.isSuccess()){
	    			pgRef = new ApexPages.StandardController(coaching).view();
	    		}
    		} else{
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Manager_Inactive));    		
    		}
    	}catch(Exception ex){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,(ex.getMessage()).substringBetween(',', '.')));
		}        
    	return pgRef;
    }
}