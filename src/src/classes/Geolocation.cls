/**
 * Class to represent a geolocation
 *
 * @Author Ryan Sayles
 * @Date 9/15/14
 */
public with sharing class Geolocation {

	public Double Latitude {get; set;}
	public Double Longitude  {get; set;}

	public Geolocation() {}

	public Geolocation(Double latitude, Double longitude) {
		this();
		this.Latitude = latitude;
		this.Longitude = longitude;		
	}
}