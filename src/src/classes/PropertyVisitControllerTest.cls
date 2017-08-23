@isTest
public class PropertyVisitControllerTest {
    static testMethod void PropertyVisitControllerTest(){
        PageReference pageRef = Page.PropertyVisit;
        Test.setCurrentPage(pageRef);
        MDU_Property__c prop = TestDataUtility.createProperty();
        database.insert(prop);
        PropertyVisitController controller = new PropertyVisitController(new ApexPages.StandardController(prop));
        Property_Visit__c pv=PropertyVisitController.checkIn(prop.Id,12,12);
        PropertyVisitController.checkOut(pv.Id);
        List<Property_Visit__c> result=PropertyVisitController.getPropertyVisit(prop.id);
               
    }
    
    public static testMethod void testCheckIn(){
        
        User carUser = TestDataUtility.createXfinityCARUser();
        system.runAs(carUser){
            MDU_Property__c prop = TestDataUtility.createProperty();
            database.insert(prop);
            
            Property_Visit__c propVisit1 = new Property_Visit__c();
            propVisit1.Name ='Test prop visit';
            propVisit1.Property__c = prop.Id;     
            propVisit1.CreatedById = carUser.Id;  
            propVisit1.Start_Date_Time__c = DateTime.now();        
            insert propVisit1;
        
            PropertyVisitController controller = new PropertyVisitController(new ApexPages.StandardController(prop));
            Property_Visit__c pv=PropertyVisitController.checkIn(prop.Id,12,12);
        }
        
    }
}