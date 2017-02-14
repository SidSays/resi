// Author : Joognu Rao
// Date   : 25-January-2017
// Purpose: To prevent deletion of Property Events if there are Property Event Items associated.

public class PropertyEventValidation{
    
    // Declarations
        public map<id,list<Property_Event_Item__c>> PropertyEventToItemsmap = new map<id, list<Property_Event_Item__c>>();
        List <Property_Event_Item__c> Itemslist;
    
    
    // method to prevent deletion of Property Events if there are Property Event Items associated
    public void doNotDeleteWithItems(List<Property_Events__c> oldList){
    
        
    
        Itemslist = new List<Property_Event_Item__c>();
        Itemslist = [select id, Property_Event__c from Property_Event_Item__c where Property_Event__c IN: oldList];
        
        try{
            if(!Itemslist.IsEmpty()){ 
                for(Property_Event_Item__c items : Itemslist){
                    
                        if(PropertyEventToItemsmap.ContainsKey(items.Property_Event__c))
                        {
                            PropertyEventToItemsmap.get(items.Property_Event__c).add(items);
                        }else{
                            PropertyEventToItemsmap.put(items.Property_Event__c, new List<Property_Event_Item__c>{items});
                        }                                               
                }
                
                for(Property_Events__c  events: oldList){
                
                   if(PropertyEventToItemsmap.get(events.id).size() > 0){
                        events.adderror(System.Label.PropertyEventErrorMessage);
                   } 
                }
            }
        
        }catch(exception ex){
            system.debug('EXCEPTION Occurred'+ex.getmessage());
        }
        
    }
    
      /*
     * @Description: This method is to create a calender event when user creats property event.
     * @Return: void
     * @Date: 2-Feb-2017 
     * @Author: Shalaka Kadwade, Accenture
     * US911767- XC Property Events: Salesforce Event
     */
    public static void createCalenderEvent(List<Property_Events__c> newPropEventList){
        final String SUBJECT = 'Property Event';
        final String EVENT_STATUS = 'Not Started';
        
        try{
             List<Event> eventList;
             Event eventObj;
             
            if(!newPropEventList.isEmpty()){
                eventList = new List<Event>();
                for(Property_Events__c propEvent: newPropEventList){
                 eventObj = new Event();
                 eventObj.StartDateTime = propEvent.Start_Time__c;
                 eventObj.EndDateTime = propEvent.End_Time__c;
                 eventObj.Subject = SUBJECT;
                 eventObj.Ownerid = propEvent.Ownerid;
                 eventObj.Whatid = propEvent.Id;
                 eventObj.Event_Status__c = EVENT_STATUS;
                 
                 eventList.add(eventObj); 
                }
            
                if(!eventList.isEmpty()) {
                        Database.Insert(eventList,false);
                }
            }
        }catch(Exception ex){
               system.debug('Following error occurred'+ ex.getMessage());
        }   
    }
}