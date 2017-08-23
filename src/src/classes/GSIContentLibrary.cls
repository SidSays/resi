/**
 * Name		: GSIContentLibrary
 * Usage	: Class for GSI Content Library list objects used by REST service to return data
 *			  that define a library and document information for mobile iPad appliation
 *			  This object serve to decouple GSI application from any Object or contenet field changes
 *			  all required content data fields passed with this record.
 *	
 * Created By	   : Igor Androsov
 * Modified By     : Igor Androsov
 * Modified Date   : June 25, 2013
 */
global class GSIContentLibrary {

	global String Id {get; set;}
	global String libraryName {get; set;}
	global String description {get; set;}
	global String refreshDate {get; set;}
	global List<GSIContent> content {get; set;}
	
}