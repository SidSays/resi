global class PropertyVisitController {
    private final sObject mysObject;
 public PropertyVisitController(ApexPages.StandardController stdController) {
 this.mysObject = (sObject)stdController.getRecord();                
 }
    
    @RemoteAction
    global static List<Property_Visit__c> getPropertyVisit(Id propId) {
        
      	List<Property_Visit__c> result=database.query('SELECT Id,Start_Date_Time__c, Property__c, Property__r.Name FROM Property_Visit__c where CreatedById=\''+UserInfo.getUserId()+'\' and End_Date_Time__c=null limit 1');
        return result;
       }
      @RemoteAction
    global static void checkOut(Id visitId) {
        Property_Visit__c propertyVisit=new Property_Visit__c();
        propertyVisit.Id=visitId;
        propertyVisit.End_Date_Time__c=datetime.now();
        update propertyVisit;
      	}
       @RemoteAction
    global static Property_Visit__c checkIn(Id propId, Decimal latitude,  Decimal longitude) {
        Property_Visit__c propertyVisit=new Property_Visit__c();
        propertyVisit.Start_Date_Time__c=datetime.now();
        propertyVisit.Property__c=propId;
        propertyVisit.Visit_Location__Latitude__s=latitude;
        propertyVisit.Visit_Location__Longitude__s=longitude;
        if(latitude!=0 && latitude!=null)
        {
        MDU_Property__c prop=[select Id, Property_Location__c,Property_Location__Latitude__s,Property_Location__Longitude__s, Exact_Match__c,	Location_Captured_From_Visit__c from MDU_Property__c where Id=:propId];    
            if(prop.Exact_Match__c==false || prop.Property_Location__Latitude__s==null || prop.Property_Location__Longitude__s==null) {
                prop.Property_Location__Latitude__s=latitude;
                prop.Property_Location__Longitude__s=longitude;
                prop.Exact_Match__c=true;
                prop.Location_Captured_From_Visit__c=true;
                update prop;
                
            }   
        }
        insert propertyVisit;
        return propertyVisit;
       }
}