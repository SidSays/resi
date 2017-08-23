/**********************************************************
* Class Name: MDUPropertyExtensionsController
* Author: Ashish Sonawane, Accenture
* Date: 02-Jan-2015 
* Requirement # Request Id : 
* Description: This controller class use to get county and franchise list from existing object to bind custom picklist.
* Last Modified by:
***********************************************************/

public with sharing class MDUPropertyExtensionsController
{
  
  //*******************Data Member*******************
  private List<string> countyList = new  List<string>();
  private List<string> franchiseList = new  List<string>();
  private static final string NONE_CONTANT = 'None';
  private static final string COUNTY_APPEND = '%';
  
   /**
    * @Description: This method return list of county base on state.
    * @Author: Ashish Sonawanae, Accenture
    * @Date: 02-Jan-2015
    * @Param:  state(string)
    * @Return: List<string> of county in state.
    */
  public List<string> getCountyBaseOnState(string state){  
        countyList = new  List<string>();
        Set<string> setOfCounty = new  Set<string>();           
        try{                               
                for(Franchise__c tempFranchise : [ SELECT County__c from Franchise__c 
                                                   WHERE State_Name__c  =: State and (County__c != NULL OR County__c != '')  ORDER BY County__c
                                                   LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ]){
                    setOfCounty.add(tempFranchise.County__c);
                }
                if(!setOfCounty.IsEmpty() || setOfCounty != null){                           
                    countyList = new List<String>(setOfCounty);
                    countyList.sort();             
                }else{
                    //future code
                }                                                  
                return countyList;                                           
        }
        catch (Exception e) 
        { 
            return null; 
        }            
    }
   
    /*
    * @Description: This method return list of Franchise base on state and county.
    * @Author: Ashish Sonawanae, Accenture
    * @Date: 02-Jan-2015
    * @Param:  state(string)
    * @Return: List<string> of Franchise.
    */
  public List<Franchise__c> getFranchiseBaseOnStateAndCounty(string State,string county){
        try{                
                franchiseList = new  List<string>();
                List<Franchise__c> listFranchiseTemp = new List<Franchise__c>();                  
                String countyName =  county+COUNTY_APPEND;            
                if(county != null &&  !NONE_CONTANT.equalsIgnoreCase(county)){
                    listFranchiseTemp = [   SELECT Franchise_Title__c, id, Legal_Entity__c from Franchise__c 
                                            WHERE State_Name__c  =: State and   County__c like : countyName ORDER BY Franchise_Title__c 
                                            LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];                                                
                }else{
                    //future code
                } 
                return listFranchiseTemp;
        }
        catch (Exception e) 
        {                
            return null; 
        } 
       
    }

}