/**    
* @Description: Controller for quick action 'Check In' for CAR user
* @Modified By: Sagarika
* @Modified Date: 6/16/2017
* @Last Modified By: Shalaka kadwade: US1137741 (XC DT - Mark visit completed)
*/ 
global with sharing class PropertyVisitController{
    private static final string VISIT_STATUS = 'In Progress';//Added By Shalaka(part of US1137741)
    private final sObject mysObject;
    public PropertyVisitController(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();                
    }
    
    /**    
    * @Description: Return property visits for the day which are owned by Logged-in user
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    * @Param: propId
    * @Return: List of property visits for the day which are owner by Logged-in user
    */ 
    @RemoteAction
    global static List<Property_Visit__c> getPropertyVisit(Id propId) {
        // Added checks as part of US1137741
        List<Property_Visit__c> result = [SELECT Id, Start_Date_Time__c, Property__c, Property__r.Name, Checked_In__c FROM Property_Visit__c 
                                            WHERE CreatedById =: UserInfo.getUserId() AND End_Date_Time__c = null AND Start_Date_Time__c = TODAY 
                                            AND Property__c =:propId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
         return result;
    }    
              
    /**    
    * @Description: Check out the property visit
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    * @Param: visitId
    * @Return: void
    */    
    @RemoteAction
    global static void checkOut(Id visitId){
        Property_Visit__c propertyVisit=new Property_Visit__c();
        propertyVisit.Id=visitId;
        propertyVisit.End_Date_Time__c=datetime.now();
        update propertyVisit;
    }
        
    /**    
    * @Description: Check In for property. Updates Property Visit Record
    * @Modified By: Sagarika
    * @Modified Date: 6/16/2017
    * @Param: propId, latitude, longitude
    * @Return: Property Visit with updated data
    */      
    @RemoteAction
    global static Property_Visit__c checkIn(Id propId, Decimal latitude,  Decimal longitude) {
        
        if(latitude!=0 && latitude!=null)
        {
            MDU_Property__c prop = [SELECT Id, Property_Location__c, Property_Location__Latitude__s, Property_Location__Longitude__s, Exact_Match__c,
                                        Location_Captured_From_Visit__c FROM MDU_Property__c WHERE Id=:propId Limit 1]; // Added Limit as part of US1137741
            if(prop.Exact_Match__c==false || prop.Property_Location__Latitude__s==null || prop.Property_Location__Longitude__s==null) {
                prop.Property_Location__Latitude__s = latitude;
                prop.Property_Location__Longitude__s = longitude;
                prop.Exact_Match__c = true;
                prop.Location_Captured_From_Visit__c = true;
                Database.update(prop,false);
            }   
        }
        //insert propertyVisit;
        Property_Visit__c propertyVisit = null;
        List<Property_Visit__c> result = [SELECT Id, Start_Date_Time__c, Property__c, Property__r.Name, Checked_In__c, Visit_Location__Latitude__s, 
                                            Visit_Location__Longitude__s, Status__c FROM Property_Visit__c WHERE Property__c =: propId AND 
                                            CreatedById=: UserInfo.getUserId() AND End_Date_Time__c=null AND Start_Date_Time__c = TODAY limit 1]; // Added Limit as part of US1137741
        if(!result.isEmpty())
        {
            propertyVisit = result[0];
            propertyVisit.Checked_In__c = true;
            propertyVisit.Start_Date_Time__c = datetime.now();
            propertyVisit.Visit_Location__Latitude__s = latitude;
            propertyVisit.Visit_Location__Longitude__s = longitude;
            // US1137741 Start
            propertyVisit.Status__c = VISIT_STATUS;
            propertyVisit.Check_In_Time__c = System.Now();
            // US1137741 End
            Database.update(propertyVisit,false);
        }else{
            propertyVisit=new Property_Visit__c();
            propertyVisit.Start_Date_Time__c = datetime.now();
            propertyVisit.Property__c = propId;
            propertyVisit.Visit_Location__Latitude__s = latitude;
            propertyVisit.Visit_Location__Longitude__s = longitude;
            propertyVisit.Checked_In__c = true;
            // US1137741 Start
            propertyVisit.Status__c = VISIT_STATUS;
            propertyVisit.Check_In_Time__c = System.Now();
            // US1137741 End
            Database.insert (propertyVisit,false);
         }
        return propertyVisit;
       }
}