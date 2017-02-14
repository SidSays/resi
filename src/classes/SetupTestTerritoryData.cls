public with sharing class SetupTestTerritoryData {
    public static User rsaUser;
    private static Profile p1 = [Select UserType, UserLicenseId, Name From Profile where Name like 'XFINITY Sales Professional'];
    private static UserRole r1 = [Select Id, Name from UserRole where Name = 'DSR'];
    private static Profile rsaProfile = [SELECT Id FROM Profile WHERE Name = 'Regional System Admin (RSA)' Limit 1];
    private static UserRole rsaRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Regional_Manager'];


    public static List<Territory__c> createTerritoryRecords(Integer count) {
        
        //Take in the count arg and then create that many Territory__c records
        List<Territory__c> territoriesToInsert = new List<Territory__c>();
        List<CensusTract__c> censusTractsToInsert = new List<CensusTract__c>();
        for(Integer i=0; i<count; i++) {
            Territory__c terr = new Territory__c();
            terr.Name = 'Territory'+i;
            terr.Territory_Code__c = 'Territory'+i;
            terr.Status__c='Draft';
            territoriesToInsert.add(terr);
        }
        insert territoriesToInsert;
        Integer censusTractCnt=0;
        for(Territory__c territory:territoriesToInsert){
            censusTractsToInsert.add(new CensusTract__c(Name='AA00356230'+censusTractCnt,
                                                        CensusTractNumber__c='AA00356230'+censusTractCnt,
                                                        Territory__c=territory.Id));
            censusTractCnt++;
        }
        insert censusTractsToInsert;

        return territoriesToInsert;
    }
    public static List<Plan__c> createPlanRecords(Integer count) {
        
        //Take in the count arg and then create that many Plan__c records
        List<Plan__c> plansToInsert = new List<Plan__c>();
        for(Integer i=0; i<count; i++) {
            Plan__c plan = new Plan__c();
            plan.Name = 'Plan'+i;
            plansToInsert.add(plan);
        }
        insert plansToInsert;
        return plansToInsert;
    }
    public static List<Customer_Address__c> createNonTargetedAddressRecords(Integer count, Id ownerId, Id territoryId) {
        return createAddressRecords(count,ownerId,territoryId,false);
    }

    public static List<Customer_Address__c> createTargetedAddressRecords(Integer count, Id ownerId, Id territoryId) {
        
        return createAddressRecords(count,ownerId,territoryId,true);
    }


    public static List<Customer_Address__c> createAddressRecords(Integer count, Id ownerId, Id territoryId,Boolean targeted) {
        
        Territory__c territory = [select Name from Territory__c where Id=:territoryId];
        
        /*Add a Id planId argument to this method if you want to populate the addr.Plan__c field below*/

        //Take in the count arg and then create that many Customer_Address__c records
        List<Customer_Address__c> addrsToInsert = new List<Customer_Address__c>();
        for(Integer i=0; i<count; i++) {
            Customer_Address__c addr = new Customer_Address__c();
            addr.Name = 'Address'+i;
            addr.OwnerId = ownerId;
            addr.Territory__c = territoryId;
            addr.Census_Block__c ='AA003562300';
            addr.Targeted__c=targeted;
            //addr.Plan__c = planId;
            addrsToInsert.add(addr);
        }
        insert addrsToInsert;
        return addrsToInsert;
    }
    public static List<Customer_Address__c> createAddressRecordsWithoutTerritory(Integer count, Id ownerId) {
        
        /*Add a Id planId argument to this method if you want to populate the addr.Plan__c field below*/

        //Take in the count arg and then create that many Customer_Address__c records
        List<Customer_Address__c> addrsToInsert = new List<Customer_Address__c>();
        Integer censusTractCnt=0;
        for(Integer i=0; i<count; i++) {
            Customer_Address__c addr = new Customer_Address__c();
            addr.Name = 'Address'+i;
            addr.OwnerId = ownerId;
            addr.Census_Block__c ='AA00356230'+(censusTractCnt++);
            addrsToInsert.add(addr);
        }
        insert addrsToInsert;
        return addrsToInsert;
    }

    public static List<Customer_Address__c> createAddressRecordsWithoutTerritoryNoCensusBlocks(Integer count, Id ownerId) {
        
        /*Add a Id planId argument to this method if you want to populate the addr.Plan__c field below*/

        //Take in the count arg and then create that many Customer_Address__c records
        List<Customer_Address__c> addrsToInsert = new List<Customer_Address__c>();
        Integer censusTractCnt=0;
        for(Integer i=0; i<count; i++) {
            Customer_Address__c addr = new Customer_Address__c();
            addr.Name = 'Address'+i;
            addr.OwnerId = ownerId;
            addrsToInsert.add(addr);
        }
        insert addrsToInsert;
        return addrsToInsert;
    }
}