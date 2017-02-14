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
}