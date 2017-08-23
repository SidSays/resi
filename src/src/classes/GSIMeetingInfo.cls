/**
 * Name     : GSIMeetingInfo
 * Usage    : GSIMeetingInfo is the wrapper class used to Parse the JSON recieved on 
 *			  GSIMeetingInfoService and Will deserialize the JSON to GSIMeetingInfo properties 
      
 * Created By      : Virendra
 * Modified By     : Igor Androsov
 * Modified Date   : Nov 6, 2015
 */
public with sharing class GSIMeetingInfo {
	public String sfid {get;set;} // Contact/Lead SFDC ID for this meeting, can be default Z123456789
	public String ClientName {get;set;}
	public List<SelectedContent> SelectedContents {get;set;}
	public String FollowDate {get;set;}
	public String MeetingDate {get; set;}
	public String Company {get;set;}
	public String FirstName {get;set;}
	public String Phone {get;set;}
	public String LastName {get;set;}
	public String Email {get;set;}
	public String Notes {get;set;}
	public String SendEmail {get; set;} // flag to send mail YES/NO string
	public String Country {get;set;}
	public String CountryCode {get; set;}
	public String State {get; set;}
	public String StateCode {get; set;}
		
	public class SelectedContent {
		public String filePath {get;set;}
		public String fileType {get;set;}
		public String categoryName {get;set;}
		public String fileName {get;set;}
		public String contentId {get; set;}
	}
		
	/*
	   Parse and return the JSON as  List of GSIMeetingInfo to create the multiple MeetingInfos 
	*/
	 public static List<GSIMeetingInfo> getFullGSIMeetingInfo(JSONParser parser){
    	List<GSIMeetingInfo> GSIMeetingInfos = new List<GSIMeetingInfo>();
    	while (parser.nextToken() != null) {
    	  if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
            while (parser.nextToken() != null) {
	         	if(parser.getCurrentToken() == JSONToken.START_OBJECT){
				      // Read entire invoice object, including its array of line items.
                    GSIMeetingInfo meetingInfo = (GSIMeetingInfo)parser.readValueAs(GSIMeetingInfo.class);
                    if(meetingInfo.ClientName != null && meetingInfo.Email !=null && meetingInfo.FirstName !=null){
	                    // Skip the child start array and start object markers.
	                    GSIMeetingInfos.add(meetingInfo);
	         	    }
                    parser.skipChildren();
				}
             }
    	  }
		}
		return GSIMeetingInfos;
    } 
	public GSIMeetingInfo() {
		
	}
}