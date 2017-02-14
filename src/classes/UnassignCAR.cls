/**
* Class Name: UnassignCAR 
* Author: Lalit Singh, Accenture
* Date: 11-17-2015 
* Requirement #US : US590019
* Description: Unassign a CAR from Property.
* Last Modified :11/26/2015
*/
public with sharing class UnassignCAR {
    //variable declaration
    public String messages{ get; set;}
    public String selectedCAR { get; set; }
    private ApexPages.StandardController stdController;
    public String redirectUrl {public get; private set;}
    public List<SelectOption> CARsUnderManager { get; set; }
    Private String valuestring;
    public List<MDU_Property__c> propertyList{get;set;}
    public Boolean shouldRedirect {public get; private set;}
    String rsaString = 'Regional System Admin (RSA)';
    String carString = 'Xfinity CAR Manager';
    string carstr = 'Xfinity CAR';
    String value1 = '--None--';
    String value2 = '--None--';
    
    //Constructor
    public UnassignCAR(ApexPages.StandardController stdcontroller){
         try{
                this.stdcontroller = stdcontroller;
                CARsUnderManager=new List<SelectOption>();
                CARsUnderManager.add(new SelectOption(value1,value2));
                User carUSer= [select ID, REGION__c,PROFILE.NAME from user where Id=:UserInfo.getUserId() LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                if(carUSer.Profile.Name.equalsIgnoreCase(rsaString)){
                    for(User usr :[select ID, NAME from USER where PROFILE.NAME =: carstr AND REGION__C=:carUSer.Region__c LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){  
                        CARsUnderManager.add(new SelectOption(usr.id,usr.name));
                        }
                    }else if(carUSer.Profile.Name.equalsIgnoreCase(carString)){
                    for(User usr :[select ID, NAME from USER where PROFILE.NAME=:carstr AND ManagerId=:UserInfo.getUserId() LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){  
                        CARsUnderManager.add(new SelectOption(usr.id,usr.name));
                    }
                }else{}
                valuestring = ApexPages.currentPage().getParameters().get('id');
                propertyList=[Select id,Assigned_CAR__c from MDU_Property__c where id =:valuestring];
                shouldRedirect = false;
            }
                catch(exception ex){}
    }
    
    //Cancel Method
   public PageReference cancel() {
         shouldRedirect = true;
         redirectUrl = stdController.view().getUrl();
         return null;
      }
    
    //unassign method to unassign a car from a property
    public PageReference unassign() {
                for(MDU_Property__c property: propertyList ){
                        property.Assigned_CAR__c= null;
                        }
                 try{
                     if(Schema.sObjectType.MDU_Property__c.isUpdateable()){
                            database.update(propertyList);
                        }
                    }catch(Exception e){ 
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error has occured. '+e.getMessage()));   
                    }
        shouldRedirect = true;
        redirectUrl = stdController.view().getUrl();
        return null;
    }
}