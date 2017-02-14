@isTest
public class IndirectOtherVisitsTest {
    private static testMethod void otherVisitsTest(){
        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;
        Decimal lat = 32.4645;
        Decimal longi = 65.25363;
        String notes = 'Test Note for Other Visits';
        User usr = [SELECT Id,ManagerId,Email FROM User WHERE Id = :userInfo.getUserid()];
        Store_Visit__c otherVisit = new Store_Visit__c();
        otherVisit.Start_Date_Time__c = system.today();
        otherVisit.End_Date_Time__c = system.today()+2;
        otherVisit.Notes__c = 'test note'; 
        otherVisit.Visit_Type__c = 'Training';
        otherVisit.Start_Location__Latitude__s = lat;
        otherVisit.Start_Location__Longitude__s = longi;
        otherVisit.Stop_Location__Latitude__s = lat;
        otherVisit.Stop_Location__Longitude__s = longi;
        insert otherVisit;
        
        Store_Visit__c eventVisit = new Store_Visit__c();
        eventVisit.Start_Date_Time__c = System.now();
        eventVisit.Visit_Type__c = 'Event';
        eventVisit.Title__c = 'Test Title';
        eventVisit.Start_Location__Latitude__s = lat;
        eventVisit.Start_Location__Longitude__s = longi;
        insert eventVisit;
       
        IndirectOtherVisitsController.StoreOtherVisitWrapper sow = new IndirectOtherVisitsController.StoreOtherVisitWrapper();
        sow.check = false;
        sow.stv = otherVisit;
        
        Test.startTest();
        
        IndirectOtherVisitsController.getVisitTypeValue();
        IndirectOtherVisitsController.getVisitStatus(usr);
        IndirectOtherVisitsController.createEventVisit(lat, longi);
        IndirectOtherVisitsController.saveOtherVisitAndSendEmail(otherVisit.Start_Date_Time__c, otherVisit.End_Date_Time__c, notes, lat, longi, 'Office Visit', usr);
        eventVisit.End_Date_Time__c = System.now();
        eventVisit.Stop_Location__Latitude__s = lat;
        eventVisit.Stop_Location__Longitude__s = longi;
        update eventVisit;
        IndirectOtherVisitsController.saveEventVisitAndSendEmail(eventVisit.Id, notes,eventVisit.title__c, lat, longi, usr);
        IndirectOtherVisitsController.isAutoCompletedANDEmailSummary(eventVisit.Id,usr);
        
        
        IndirectOtherVisitsController.getOtherVisitHistory('',userInfo.getUserid());
        
        delete eventVisit;
        IndirectOtherVisitsController.createEventVisit(lat, longi);
        
        
        Store_Visit__c officeVisit = new Store_Visit__c();
        officeVisit.Start_Date_Time__c = System.now();
        officeVisit.Visit_Type__c = 'Office Visit';
        officeVisit.Start_Location__Latitude__s = lat;
        officeVisit.Start_Location__Longitude__s = longi;
        officeVisit.notes__c = 'Office Notes';
        insert officeVisit;
        
       System.runAs(usr){
            IndirectOtherVisitsController.getOtherVisitHistory(officeVisit.Visit_Type__c,usr.Id);
            IndirectOtherVisitsController.getVisitStatus(usr);
        }
        Test.stopTest();
    }
}