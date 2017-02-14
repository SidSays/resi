/**
* Class Name: AssignPropertiesToCARsExtension
* Author: Anil Singh, Accenture
* Date: 10-22-2015 
* Requirement #US : US572044
* Description: Assign the properties to the car's under their manager and same for the RSA's.
* Last Modified :
*/
public with sharing class AssignPropertiesToCARsExtension {
    //Properties
    List<string> propertyIds = new List<string>();
    public List<MDU_Property__c> propertiesO{get;set;}
    public Boolean isError{get;set;}
    public String selectedCAR{get;set;}
    public List<SelectOption> CARsUnderManager{get;set;}
    private ApexPages.StandardSetController standardController;
    //Constructor
    public AssignPropertiesToCARsExtension() {
        //this.standardController = standardController;
        //system.debug('##standardController##'+standardController);
        CARsUnderManager=new List<SelectOption>();
        CARsUnderManager.add(new SelectOption('--None--','--None--'));
        User lUser=[select ID, REGION__c,PROFILE.NAME from user where Id=:UserInfo.getUserId()];
        System.debug('**********LSER***************'+luser.Profile.Name);
        
        if(lUser.Profile.Name=='Regional System Admin (RSA)'){
            for(User usr :[select ID, NAME from USER where PROFILE.NAME='Xfinity CAR' AND REGION__C=:lUser.Region__c]){  
                CARsUnderManager.add(new SelectOption(usr.id,usr.name));
            }
        }else if(lUser.Profile.Name=='Xfinity CAR Manager'){
            for(User usr :[select ID, NAME from USER where PROFILE.NAME='Xfinity CAR'AND ManagerId=:UserInfo.getUserId()]){  
                CARsUnderManager.add(new SelectOption(usr.id,usr.name));
            }
        }
              
        CARsUnderManager.sort();
        isError=false;
        system.debug('##CARsUnderManager##'+CARsUnderManager.size());
        if(CARsUnderManager.size()<2){
            system.debug('inside teh if condition');
            isError=true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Based on reporting structure (hierarchy) no CARS are available to be assigned.')); 
        }        
        system.debug('###getRecords### '+ApexPages.currentPage().getParameters().get('records'));
        propertyIds = ApexPages.currentPage().getParameters().get('records').split(',',-2);
        system.debug('###propertyIds### '+propertyIds);
        propertiesO=[Select id, Name, City__c, Property_Name_Address__c,Address__c from MDU_Property__c where id in:propertyIds];
        system.debug('##propertiesO##'+propertiesO);
    }
    
    // Property Assignment
    public PageReference doAssignment() {
     
        if(selectedCAR=='--None--'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select at-least one CAR for assignment.'));
        }else{ 
                system.debug('##propertiesO.size()##'+propertiesO.size());
                if(propertiesO.size()>0){
                 for(MDU_Property__c property: propertiesO ){
                     property.Assigned_CAR__c= selectedCAR;                  
                 }
                 try{
                    System.debug('Schema.sObjectType.MDU_Property__c.isUpdateable()'+Schema.sObjectType.MDU_Property__c.isUpdateable()); 
                    if(Schema.sObjectType.MDU_Property__c.isUpdateable()){
                          System.debug('Inside Loop');
                          update propertiesO ;
                          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Assignment has been completed.'));
                                 return cancelAssignment();  
                    }else{ 
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: You don\'t have access to update the Property.', ''));
                        return null;
                    }   
                }catch(Exception e){
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error has occured. '+e.getMessage()));     
                        }
                }else{
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'There is no Property for assignment.'));
                     }
             }            
        return null;
    }
    //Cancel
    public Pagereference cancelAssignment(){
         return new Pagereference('/'+MDU_Property__c.getSObjectType().getDescribe().getKeyPrefix()+'?fcf='+ApexPages.currentPage().getParameters().get('retUrl'));
    }
    
    public Integer rowToRemove {get;set;}   
    //Remove
    public void removeRowFromPropertyList(){
        if(!Test.isrunningTest()){
        propertiesO.remove(rowToRemove);        
       }
    }

}