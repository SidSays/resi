/**
*	Hold parameters for a date range
*
*	@author	Sahil Grover	<sgrover@acumensolutions.com>
*/
public with sharing class DateRange {
	public Date FromDate {get; set;}	// >= date
	public Date ToDate {get; set;}		// <= date

	public DateRange() {
		FromDate = null;
		ToDate = null;
	}
}