/********************************************** 
* @Class Name : ICalendarTemplate 
* @Description : This template is used to create Ical file content String to add to email attachments as a Ical object
* @Author : Sagarika Somasundaram
* @Date Created : 27-June-2017 
* @User Story : US1117736(XC Property Event - Delete Events)
**********************************************/
public with sharing class ICalendarTemplate {
	
	//Attributes which can be set depending on the requirement
	public String method {get;set;}
	public String status {get;set;}

	public String organizer {get;set;}
	public String mailTo {get;set;}
	public String uid {get;set;}

	public String summary {get;set;}
	public String description {get;set;}
	
	public String startDt {get;set;}
	public String endDt {get;set;}
	public String dateStamp {get;set;}
	public String created {get;set;}
	public String lastModified {get;set;}	
	public String sequence {get;set;}	

	//Placeholder string values which are replaced to generate the Ical file content string
	private final static String METHOD_INPUT = 'METHOD_INPUT';
	private final static String STATUS_INPUT = 'STATUS_INPUT';
	
	private final static String ORGANIZER_INPUT = 'ORGANIZER_INPUT';
	private final static String TO_EMAIL_INPUT = 'TO_EMAIL_INPUT';
	private final static String UID_INPUT = 'UID_INPUT';
	
	private final static String SUMMARY_INPUT = 'SUMMARY_INPUT';
	private final static String DESCRIPTION_INPUT = 'DESCRIPTION_INPUT';
	
	private final static String START_DT_INPUT = 'START_DT_INPUT';
	private final static String END_DT_INPUT = 'END_DT_INPUT';
	private final static String DT_STAMP_INPUT = 'DT_STAMP_INPUT';
	private final static String CREATED_INPUT = 'CREATED_INPUT';
	private final static String LAST_MODIFIED_INPUT = 'LAST_MODIFIED_INPUT';
	private final static String SEQUENCE_INPUT = 'SEQUENCE_INPUT';
	
	private final static String BLANK = '';
	private final static String SEQUENCE_ZERO = '0';
	
	//Ical file content string with placeholders  to replace based on requirement
	private final static String vCal = 'BEGIN:VCALENDAR\n' + 'PRODID:-//Force.com Labs//iCalendar Export//EN' + '\n' +
                                'VERSION:2.0' + '\n' + 'METHOD:' + METHOD_INPUT + '\n'+ 'CALSCALE:GREGORIAN' + '\n' + 'X-WR-RELCALID:' + UID_INPUT + '\n' + 'BEGIN:VEVENT'+ '\n' +
                                'DTSTART:'+START_DT_INPUT+ '\n' + 'DTEND:'+END_DT_INPUT+ '\n' + 'DTSTAMP:'+DT_STAMP_INPUT+ '\n' +
                                'ORGANIZER;CN=:mailto:'+ TO_EMAIL_INPUT + '\n' + 'UID:'+ UID_INPUT + '\n' +
                                'CREATED:'+START_DT_INPUT+ '\n' + 'DESCRIPTION:' + DESCRIPTION_INPUT + '\n' + 'LAST-MODIFIED:'+ LAST_MODIFIED_INPUT + '\n' +
                                'SEQUENCE:' + SEQUENCE_INPUT + '\n' + 'STATUS:' + STATUS_INPUT + '\n' + 'SUMMARY:' + SUMMARY_INPUT + '\n' + 'TRANSP:OPAQUE' + '\n' +
                                'END:VEVENT'+ '\n' + 'END:VCALENDAR';
	
    /*
    * @Description : This method will generate the Ical File content string based on the input supplied
    * @Author : Sagarika Somasundaram
    * @Date : 27-June-2017 
    * @Return : String
    * @Param : N/A    
	* @User Story : US1117736(XC Property Event - Delete Events)
    */								
	public String generateVcalString()
	{
		String vCalString = vCal;
		try{
		vCalString = vCalString.replaceAll(METHOD_INPUT, !String.isBlank(method)  ? method : BLANK);
		vCalString = vCalString.replaceAll(STATUS_INPUT, !String.isBlank(status)  ? status : BLANK);
		vCalString = vCalString.replaceAll(ORGANIZER_INPUT, !String.isBlank(organizer)  ? organizer : BLANK);
		vCalString = vCalString.replaceAll(TO_EMAIL_INPUT, !String.isBlank(mailTo)  ? mailTo : BLANK);
		vCalString = vCalString.replaceAll(UID_INPUT, !String.isBlank(uid)  ? uid : BLANK);
		vCalString = vCalString.replaceAll(SUMMARY_INPUT, !String.isBlank(summary)  ? summary : BLANK);
		vCalString = vCalString.replaceAll(DESCRIPTION_INPUT, !String.isBlank(description)  ? description : BLANK);
		vCalString = vCalString.replaceAll(START_DT_INPUT, !String.isBlank(startDt)  ? startDt : BLANK);
		vCalString = vCalString.replaceAll(END_DT_INPUT, !String.isBlank(endDt)  ? endDt : BLANK);
		vCalString = vCalString.replaceAll(DT_STAMP_INPUT, !String.isBlank(dateStamp)  ? dateStamp : BLANK);
		vCalString = vCalString.replaceAll(CREATED_INPUT, !String.isBlank(created)  ? created : BLANK);
		vCalString = vCalString.replaceAll(LAST_MODIFIED_INPUT, !String.isBlank(lastModified)  ? lastModified : BLANK);
		vCalString = vCalString.replaceAll(SEQUENCE_INPUT, !String.isBlank(sequence)  ? sequence : SEQUENCE_ZERO);
		}
		catch(Exception e)
		{
			ApplicationLogUtil.insertApplogforexceptions(e, ConstantHandler.STR_CLASS, ICalendarTemplate.class.getName(),  ICalendarTemplate.class.getName(), false, null, ConstantHandler.nonintegrationRTypeId);
		}
		return vCalString;
	}
}