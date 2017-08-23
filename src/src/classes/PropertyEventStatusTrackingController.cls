/**************************************************************
* Class Name : PropertyEventStatusTrackingController
* Author : Shalaka Kadwade and Amit Kumar Pradhan, Accenture
* Date : 3-July-2017
* Description : This class is Controller extension of "PropertyEventStatusTracking" visualforce page.
* User Story : US1117685(XC Property Event - Status Tracking)
**************************************************************/
public class PropertyEventStatusTrackingController{
    //Initialization of constant variable
    private static final String BLANK_STRING = '';
    private static final String EVENT_ID = 'EventId';
    private static final String EVENT_RELATION_ID = 'RelationId';
    private static final String STATUS_NEW = 'New';
    private static final String STATUS_ACCEPTED = 'Accepted';
    private static final String STATUS_DECLINED = 'Declined';
    
    //Class Variable
    public String eventId = BLANK_STRING;
    public String relationId = BLANK_STRING;
    public List<EventRelation> eventRelationList = null;
    
    //Getter Setter variable
    public String acceptORDecline {get;set;}
    public Boolean isAccepted {get;set;}
    public Boolean isDeclined {get;set;}
    public String eventName {get;set;}
    public String organizerName {get;set;}
    public String comments {get;set;}
    public Boolean isNewStatus {get;set;}
    public String response {get;set;}
    
    /*********************************************    
    * @Description : Constructor for AddTeamMemberController
                    1.Initialization of variable.
                    2.Fetching eventId and relationId value from parameter.
    * @Author : Shalaka Kadwade and Amit Kumar Pradhan, Accenture    
    * @Date : 3-July-2017 
    * @User Story : US1117685(XC Property Event - Status Tracking)
    *********************************************/
    public PropertyEventStatusTrackingController(){
        try{
            //Fetching eventId and relationId value from parameter
            eventId = ApexPages.currentPage().getParameters().get(EVENT_ID);
            relationId = ApexPages.currentPage().getParameters().get(EVENT_RELATION_ID);     
            isNewStatus = true;
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PESomeThingWentWrong));
        }   
    }
    
    /*********************************************    
    * @Description : Initialization of variable at the time of page loading
                    1.Fetching the event detail against event id.
                    2.Fetching event relationship record.
                    3.Seting response if event is already accept/decline.
    * @Author : Shalaka Kadwade and Amit Kumar Pradhan, Accenture    
    * @Date : 3-July-2017 
    * @User Story : US1117685(XC Property Event - Status Tracking)
    *********************************************/
    public void initializeData(){
        try{
            //Fetching the event detail against event id.
            List<Event> eventDetail = [SELECT Id, Subject, Owner.Name, StartDateTime, EndDateTime FROM
                                            Event WHERE Id =:eventId Limit 1];
            if(!eventDetail.isEmpty()){
                eventName = eventDetail[0].Subject;//initaialization of event Name
                organizerName = eventDetail[0].Owner.Name;//initaialization of organizer Name 
            }
            //Fetching event relationship record.
            eventRelationList = [SELECT Id, EventId, RelationId, Response, Status 
                                                    FROM EventRelation WHERE EventId =: eventId 
                                                    AND RelationId =: relationId Limit 1];
            if(!eventRelationList.isEmpty()){
                //initialize response if event is already accepted or declined
                if(eventRelationList[0].Status != STATUS_NEW){
                    isNewStatus = false;
                    response = eventRelationList[0].Status;
                }
            }                                                                                           
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PESomeThingWentWrong));
        } 
    }
    
    /*********************************************    
    * @Description : Updating event relationship status to accept/decline
                    and setting the accept/decline flag
    * @Author : Shalaka Kadwade and Amit Kumar Pradhan, Accenture    
    * @Date : 3-July-2017 
    * @User Story : US1117685(XC Property Event - Status Tracking)
    *********************************************/
    public PageReference submitAcceptORDecline(){
        try{
            if(!eventRelationList.isEmpty()){
                //update the event relationship status
                if(acceptORDecline == STATUS_ACCEPTED){
                    eventRelationList[0].Status = STATUS_ACCEPTED;
                    isAccepted = true;//set accepted flag to true
                }else{
                    eventRelationList[0].Status = STATUS_DECLINED;
                    isDeclined = true;//set declined flag to true
                }
                //updating response of event relation
                eventRelationList[0].Response = comments;
                //Updating event relationship record
                Database.update(eventRelationList[0]);
            }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PESomeThingWentWrong));
        } 
        return null;
    }     
}