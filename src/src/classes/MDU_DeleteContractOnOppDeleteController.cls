/**************************************************************
* Class Name : MDU_DeleteContractOnOppDeleteController
* Author : Deepika Jain Naresh, Accenture
* Date : 29-June-2017
* Description : This class is Controller extension of "MDU_DeleteContractOnOppDelete" visualforce page.
* User Story : US1107249(XC MCAT - Delete contract in MCAT)
***************************************************************/
global with sharing class MDU_DeleteContractOnOppDeleteController {
   //Getter Setter variable.
   public Id oppId{get;set;}
   public static Boolean isContractExists{get;set;}
   private static final String Xfinity_Opportunity_Record_Type = 'Xfinity Opportunity Record Type';
   private static final String URLForHome='/home/home.jsp';
   /*********************************************    
    * @Description : Constructor for MDU_DeleteContractOnOppDeleteController
                     1.Fetching Opportunity id of the current opportunity.
    * @Author : Deepika Jain Naresh, Accenture    
    * @Date : 29-June-2017 
    * @User Story : US1107249(XC MCAT - Delete contract in MCAT)
    * @Param : ApexPages.StandardController    
    **********************************************/ 
   public MDU_DeleteContractOnOppDeleteController(ApexPages.StandardController stdController){
        //Getting Opportunity Id from controller.
        oppId = stdController.getRecord().id;
    } 
    
    /*********************************************    
    * @Description : RemoteAction method to fetch the Opportunity Property Id for the particular Opportunity and call the future methods for deleting contracts and also the opportunity. 
    * @Author : Deepika Jain Naresh, Accenture    
    * @Date : 29-June-2017 
    * @User Story : US1107249(XC MCAT - Delete contract in MCAT)
    * @Param : Opportunity Id  
    * @Return : void  
    **********************************************/ 
    @RemoteAction
    public static void deleteContractOnOppDel(Id oppId){
    
        Set<Id> setOppPropertyId = new Set<Id>();
        for(Opportunity_Property__c objOppProperty:[SELECT Id FROM Opportunity_Property__c WHERE Opportunity__c =: oppId 
                                                                                   AND ECM__c!= null]){
                   setOppPropertyId.add(objOppProperty.id);
        }
                if(!setOppPropertyId.isEmpty()){
                    if (setOppPropertyId.size() < 40){
                        for(Id oppPropid : setOppPropertyId){
                            deletecontract(oppPropid);
                     }
                     isContractExists = true;
                    }else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Label.DeleteContractOnOppDelete));
                        
                    }
                }else{
                        deleteOpp(oppId);
                        isContractExists = false;
                }
     }   
    
    /*********************************************    
    * @Description : RemoteAction method to call the webservice to delete contract in MCAT. 
    * @Author : Deepika Jain Naresh, Accenture    
    * @Date : 29-June-2017 
    * @User Story : US1107249(XC MCAT - Delete contract in MCAT)
    * @Param : Opportunity property Id  
    * @Return : void  
    **********************************************/ 
    @future(callout = true)
    public static void deletecontract(Id oppPropId){
         MDU_ContractServices.deleteContractProcess(oppPropId,false);
    }
    
    /*********************************************    
    * @Description : RemoteAction method to delete the opportunity. 
    * @Author : Deepika Jain Naresh, Accenture    
    * @Date : 29-June-2017 
    * @User Story : US1107249(XC MCAT - Delete contract in MCAT)
    * @Param : Opportunity property Id  
    * @Return : void  
    **********************************************/ 
    
    public static void deleteOpp(Id oppId){
        try{
            List<Opportunity> oppToDelete=[SELECT id from Opportunity where id=:oppId LIMIT 1];
            Database.delete(oppToDelete,false);
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PESomeThingWentWrong));
        } 
    }
    
    /*********************************************    
    * @Description : Method to redirect to home page after deletion of opportunity. 
    * @Author : Deepika Jain Naresh, Accenture    
    * @Date : 29-June-2017 
    * @User Story : US1107249(XC MCAT - Delete contract in MCAT)
    * @Param : None  
    * @Return : PageReference
    **********************************************/ 
   public pageReference openPage() 
    {
        pageReference pg = new pageReference(URLForHome);
        pg.setRedirect(true);
        return pg;
    }    
}