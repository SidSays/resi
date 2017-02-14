/**************************************************************************************************
Name : MduPropertyContractExtensions
Description : This page will display the printable view for Property based on the contract IDs 
User Story : 
Date : 19 January 2015
Author : Accenture
***************************************************************************************************/
public with sharing class  MDUPropertyContractExtensions{
    
    //Properties Declaration 
    private ApexPages.StandardController controller = null;
    private static final String PROPERTY_ID = 'id';
    private static final String PROPERTY_ID_EMPTY = '';
    public MDU_Property__c property{get;set;}
    public List<Contract__c > contractListNew{get;set;}
    public String propertyID{get;set;}
        
    /*   Constructor   */ 
    public MduPropertyContractExtensions(ApexPages.StandardController controller) {
        this.controller = controller;  
        //Initialize all the properties
        property = new MDU_Property__c();
        contractListNew = new List<Contract__c >();
        propertyID = PROPERTY_ID_EMPTY;
        
        String propID = apexpages.currentpage().getparameters().get(PROPERTY_ID);  
        List<Contract__c> contractList = new List<Contract__c>();
        if(propID != null){
            propertyID = propID ;
            For(MDU_Property__c propertyTemp:[Select id, Name, (Select Id, Name, Status_Sub_Status__c
                                                ,Expiration_Date__c, Contract_Type__c from                
                                                Contracts1__r) from MDU_Property__c where ID =:  propID]){
                property = propertyTemp;
                contractList =  propertyTemp.Contracts1__r;
            }            
            contractListNew = contractList ;
        }        
    }
}