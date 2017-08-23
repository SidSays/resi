public class AssignCAR {
  
    List<String> propertyIds = new List<String>();
    public String selectedCAR { get; set; }
    public String redirectUrl {public get; private set;}
    public List<MDU_Property__c> propertiesO{get;set;}
    private ApexPages.StandardController stdController;
    public List<SelectOption> CARsUnderManager { get; set; }
    public String valuestring;
    public Boolean shouldRedirect {public get; private set;}
    
    public AssignCAR(ApexPages.StandardController stdcontroller) {
        this.stdcontroller = stdcontroller;
        CARsUnderManager=new List<SelectOption>();
        CARsUnderManager.add(new SelectOption('--None--','--None--')); 
        User carUSer= [select ID, REGION__c,PROFILE.NAME from user where Id=:UserInfo.getUserId()];
         if(carUSer.Profile.Name=='Regional System Admin (RSA)'){
            for(User usr :[select ID, NAME from USER where PROFILE.NAME='Xfinity CAR' AND REGION__C=:carUSer.Region__c]){  
                CARsUnderManager.add(new SelectOption(usr.id,usr.name));
            }
        }else if(carUSer.Profile.Name=='Xfinity CAR Manager'){
            for(User usr :[select ID, NAME from USER where PROFILE.NAME='Xfinity CAR'AND ManagerId=:UserInfo.getUserId()]){  
                CARsUnderManager.add(new SelectOption(usr.id,usr.name));
            }
        }
            valuestring = ApexPages.currentPage().getParameters().get('id');
            propertiesO=[Select id from MDU_Property__c where id =:valuestring];
            shouldRedirect = false;
    }
   public PageReference cancel() {
         shouldRedirect = true;
         redirectUrl = stdController.view().getUrl();
         return null;
      }
   public PageReference assign() {
         if(selectedCAR=='--None--'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select at-least one CAR for assignment.'));
            }else{
              if(propertiesO.size()>0){            
                for(MDU_Property__c property: propertiesO ){
                    property.Assigned_CAR__c= selectedCAR;
                 }
                 try{
                     if(Schema.sObjectType.MDU_Property__c.isUpdateable()){
                        update propertiesO;
                     }
                  }catch(Exception e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error has occured. '+e.getMessage()));   
                  }
              }
        }
        shouldRedirect = true;
        redirectUrl = stdController.view().getUrl();
        return null;
    }
 }