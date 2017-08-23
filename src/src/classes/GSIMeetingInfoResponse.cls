/**
 * Name		: GSIMeetingInfoResponse
 * Usage	: Responder class for GSI Application to return response
 *			  if teh call was completed. Use as wrapper
 *	
 * Created By	   : Igor Androsov
 * Modified By     : Igor Androsov
 * Modified Date   : June 18, 2013
 */
global class GSIMeetingInfoResponse {
	global String Id {get; set;}
	global String message {get; set;}
}