/**
* Class Name: UnassignpropertiestoCARsExtension 
* Author: Rahul Prabhakar, Accenture
* Date: 11-17-2015 
* Requirement #US : US590019
* Description: Unassign a CAR from Property list view implementation.
* Last Modified :11/26/2015
*/
public with sharing class UnassignpropertiestoCARsExtension {       
        //variable declaration
        List<string> propertyIds = new List<string>();
        public List<MDU_Property__c> propertiesO{get;set;}
        public List<SelectOption> CARsUnderManager{get;set;}
        public Integer rowToRemove {get;set;}  
        String value1 = '--None--';
        String value2 = '--None--';
        String rsaString = 'Regional System Admin (RSA)';
        String carString = 'Xfinity CAR Manager';
        string carstr = 'Xfinity CAR';
        
        //method for removal of property
        public void removeRowFromPropertyList() {
         if(!Test.isRunningTest()){
       propertiesO.remove(rowToRemove); }
        }
     
     //constructor
        public UnassignpropertiestoCARsExtension () {
        CARsUnderManager=new List<SelectOption>();
        CARsUnderManager.add(new SelectOption(value1,value2 ));
        User lUser=[select ID, REGION__c,PROFILE.NAME from user where Id=:UserInfo.getUserId() LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        if(lUser.Profile.Name.equalsIgnoreCase(rsaString)){
            for(User usr :[select ID, NAME from USER where PROFILE.NAME=:carstr  AND REGION__C=:lUser.Region__c LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){  
                CARsUnderManager.add(new SelectOption(usr.id,usr.name));
            }
        }else if(lUser.Profile.Name.equalsIgnoreCase(carString )){
            for(User usr :[select ID, NAME from USER where PROFILE.NAME=:carstr  AND ManagerId=:UserInfo.getUserId() LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){  
                CARsUnderManager.add(new SelectOption(usr.id,usr.name));
            }
        }
              
        CARsUnderManager.sort();
       
        if(!Test.isRunningTest()){
        propertyIds = ApexPages.currentPage().getParameters().get('records').split(',',-2);}
        propertiesO=[Select id, Name, City__c, Property_Name_Address__c,Address__c,Assigned_CAR__c  from MDU_Property__c where id in:propertyIds LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        }
        
        //cancel method
        public Pagereference cancelAssignment(){
        return new Pagereference('/'+MDU_Property__c.getSObjectType().getDescribe().getKeyPrefix()+'?fcf='+ApexPages.currentPage().getParameters().get('retUrl'));
        }
        
        //unassigncar method to unassign car's from property.
         public Pagereference unassignCar() {
         List<MDU_Property__c> propertyList = new List<MDU_Property__c>();
        List<MDU_Property__c> prop =propertiesO;
        for(MDU_Property__c properties:prop){
        
        properties.Assigned_CAR__c = null;
        propertyList.add(properties);
       
        }
         update propertyList;
         return new Pagereference('/'+MDU_Property__c.getSObjectType().getDescribe().getKeyPrefix()+'?fcf='+ApexPages.currentPage().getParameters().get('retUrl'));
        }
}