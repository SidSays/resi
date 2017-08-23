/**
 * Name		: GSIContent
 * Usage	: Class for GSI Content data objects used by REST service to return data
 *			  that define a document information for mobile iPad appliation
 *			  This object serve to decouple GSI application from any Object or contenet field changes
 *			  all required content data fields passed with this record.
 *	
 * Created By	   : Igor Androsov
 * Modified By     : Igor Androsov
 * Modified Date   : June 25, 2013
 */
global class GSIContent {
	
	global Integer contentSize {get; set;}
	global String fileType {get; set;}
	global String documentId {get; set;}
	global String version {get; set;}
	global String url {get; set;}
	global Boolean isLatest {get; set;}
	global String infoText {get; set;} 
	global String title {get; set;}
	global String fileName {get; set;}
    global String categoryId {get; set;}
    global String categoryName {get; set;}
}