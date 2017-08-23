/*
     * Author     : Radhika Bansal
     * Date       : 26-Jul-2017
     * Description: This method is used to fetch all the dashboard from Coaching App meta data.
     * User Story : US1149780
    */
public with sharing class CoachingApp {

    /*
     * Author     : Radhika Bansal
     * Date       : 26-Jul-2017
     * Description: This method is used to fetch all the dashboard from Coaching App meta data.
     * User Story : US1149780
    */
    @AuraEnabled
    public static List<CoachingApp__mdt> getCoachingCustomMetaData() {
        List<CoachingApp__mdt> retVal;
        
        List<CoachingApp__mdt> lstDashboardIds = [SELECT MasterLabel, Value__c, DeveloperName  FROM CoachingApp__mdt
                              LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        if(!lstDashboardIds.isEmpty()) {
            retVal = lstDashboardIds;
        }  
        
        return retVal;
        
        
    }
   }