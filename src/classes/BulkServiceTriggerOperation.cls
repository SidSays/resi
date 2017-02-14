/** **********************************************************************
* Name: BulkServiceTriggerOperation
* Author: Ashish Sonawane
* User Story : 087 
* Description: This class use to new bulk service record if bulk service implemented check box check.
    Date                 PRJ/DFCT/ENHC#            Summary of Changes 
  -------------         -----------------       ------------------------------
  23-January-2015        Comcast Resi(MDU)              Initial Release 
  
**************************************************************************/
public class BulkServiceTriggerOperation{  
    
    /* Data Member */
    private static final string ANNUALY_INCREASE_PERIOD = 'Annually';
    private static final string MONTHLY_INCREASE_PERIOD = 'Monthly';
    private static final string QUARTERLY_INCREASE_PERIOD = 'Quarterly';
    private static final string SEMIANNUALLY_INCREASE_PERIOD = 'Semi-Annually';
    private static final integer ANNUAL_MONTH = 12;
    private static final integer ONE_MONTH = 1;
    private static final integer QUARTER_MONTH = 3;
    private static final integer SEMIANNUAL_MONTH = 6;
    private static final integer DEFAULT_DAYS_CONSTANT = 30;
    
    /**
    * @Description: Create new record of Bulk Service when we insert bulk service with implemented as check
    * @Author: Ashish G. Sonawane, Accenture
    * @Date: 23-January-2015 
    * @Param: none   
    * @Return: void.
    */
    public static void afterInsertNewBulkservice(){          
        Set<id> bulkServiceIdset = new Set<id>();
        Map<id,Bulk_Service__c> bulkServiceListOldMap = new  Map<id,Bulk_Service__c>();
        List<Bulk_Service__c> bulkServiceListInsertList = new List<Bulk_Service__c>();
        List<Bulk_Service__c> bulkServiceList = (List<Bulk_Service__c>) Trigger.New;   
        if(Trigger.IsUpdate){
            bulkServiceListOldMap =  (Map<id,Bulk_Service__c>)Trigger.OldMap;
        }else{
            //future code
        }        
        for(Bulk_Service__c tempBulkService : bulkServiceList){
            bulkServiceIdset.add(tempBulkService.id);
        }        
        
        for(Bulk_Service__c tempBulkService : bulkServiceList){              
            // Insert new empty Bulk Service record if implemented bulk service inserted           
            if(Trigger.IsInsert && tempBulkService.Implemented__c){                
                Bulk_Service__c objBulkService = BulkServiceTriggerOperation.creaetBulkServiceObject(tempBulkService);                
                bulkServiceListInsertList.add(objBulkService);   
                                 
            }   
            // Insert new empty Bulk Service record if bulk service updated(that should be implemented) 
            else if(Trigger.IsUpdate && tempBulkService.Implemented__c && !bulkServiceListOldMap.get(tempBulkService.id).Implemented__c){                 
                Bulk_Service__c objBulkService = BulkServiceTriggerOperation.creaetBulkServiceObject(tempBulkService);
                bulkServiceListInsertList.add(objBulkService);                                                                              
            }else{
            //future code
            } 
        }                                                      
        //Insert DML Operation        
        if(!bulkServiceListInsertList.IsEmpty()){                           
            Database.SaveResult[] saveresultInsert = Database.insert(bulkServiceListInsertList, false);
        }else{
            //future code
        }                                                                                                                        
    }
   
   
    /**
    * @description: Method to generate Bulk Service object with updated fields on it
    * @return: updated Bulk_Service__c(object) 
    * @Param: Bulk_Service__c(object) to be updated
    **/
    private static  Bulk_Service__c creaetBulkServiceObject(Bulk_Service__c tempBulkService){
        Bulk_Service__c objBulkService = new Bulk_Service__c();
        objBulkService.Bulk_Rate_Increase__c= tempBulkService.Bulk_Rate_Increase__c; //Chnange for Property LookUp        
        if(tempBulkService.Video_Increase_Period__c != null && tempBulkService.Increase_Date__c != null){                        
            if(ANNUALY_INCREASE_PERIOD.equalsIgnoreCase(tempBulkService.Video_Increase_Period__c.Trim())){                             
                objBulkService.Increase_Date__c = tempBulkService.Increase_Date__c.addMonths(ANNUAL_MONTH);
            }else if(MONTHLY_INCREASE_PERIOD.equalsIgnoreCase(tempBulkService.Video_Increase_Period__c.Trim())){
                objBulkService.Increase_Date__c = tempBulkService.Increase_Date__c.addMonths(ONE_MONTH);
            }else if(QUARTERLY_INCREASE_PERIOD.equalsIgnoreCase(tempBulkService.Video_Increase_Period__c.Trim())){
                objBulkService.Increase_Date__c = tempBulkService.Increase_Date__c.addMonths(QUARTER_MONTH);
            }else if(SEMIANNUALLY_INCREASE_PERIOD.equalsIgnoreCase(tempBulkService.Video_Increase_Period__c.Trim())){
                objBulkService.Increase_Date__c = tempBulkService.Increase_Date__c.addMonths(SEMIANNUAL_MONTH);
            }else{
            //future code
            }                         
        }//if Video Increase Period Set To Null
        else if(tempBulkService.Video_Increase_Period__c == null && tempBulkService.Increase_Date__c != null){ 
            objBulkService.Increase_Date__c = tempBulkService.Increase_Date__c.addMonths(ANNUAL_MONTH);
        }else{
            //future code
        }
        //if Video Increase Notice Set To Null               
        if(tempBulkService.Video_Increase_Notice__c != null && objBulkService.Increase_Date__c != null){                   
            objBulkService.Notice_Due_Date__c = objBulkService.Increase_Date__c.addDays(-Integer.ValueOf(tempBulkService.Video_Increase_Notice__c));                                                                                       
        }
        else if(tempBulkService.Video_Increase_Notice__c == null && objBulkService.Increase_Date__c != null){                       
            objBulkService.Notice_Due_Date__c = objBulkService.Increase_Date__c.addDays(-DEFAULT_DAYS_CONSTANT);
        }else{
            //future code
        } 
        objBulkService.Units__c = tempBulkService.Units__c;
        objBulkService.Bulk_Service__c = tempBulkService.Bulk_Service__c;         
        objBulkService.Increase_Amount__c = tempBulkService.Increase_Amount__c;
        objBulkService.Increase_Amount_Units__c = tempBulkService.Increase_Amount_Units__c;
        objBulkService.Current_Rate__c =  tempBulkService.New_Rate__c;                       
        return objBulkService;  
    }
}