/**
 * Test class for GeoDistanceCalculator
 *
 * @Author Ryan Sayles
 * @Email rsayles@acumensolutions.com
 * @Date 9/12/14
 */

@isTest
private class GeoDistanceCalculatorTest {
	
	static testMethod void distanceInFeet() {
		GeoDistanceCalculator distCalc = new GeoDistanceCalculator(GeoDistanceCalculator.DistanceUnit.FEET);

		Double distance;
		Double latA = 40.689226;
		Double longA = -74.044522;
		Double latB = 40.689226;
		Double longB = -74.044522;
		Geolocation locationA = new Geolocation(latA, longA);
		Geolocation locationB = new Geolocation(latB, longB);
 
		Test.startTest();
    		distance = distCalc.getDistance(locationA, locationB);
		Test.stopTest();
		System.assertEquals(0, distance, 'Locations are the same, distance should be 0');
	}

	static testMethod void distanceInYards() {
		GeoDistanceCalculator distCalc = new GeoDistanceCalculator(GeoDistanceCalculator.DistanceUnit.YARDS);

		Double distance;
		Double latA = 40.689226;
		Double longA = -74.044522;
		Double latB = 40.689799;
		Double longB = -74.045671;
		Geolocation locationA = new Geolocation(latA, longA);
		Geolocation locationB = new Geolocation(latB, longB);
 
		Test.startTest();
    		distance = distCalc.getDistance(locationA, locationB);
		Test.stopTest();
		System.assertEquals(127, Math.round(distance), 'Distance in yards should be approximately 127 ');
	}

	static testMethod void distanceInMiles() {
		GeoDistanceCalculator distCalc = new GeoDistanceCalculator(GeoDistanceCalculator.DistanceUnit.MILES);

		Double distance;
		Double latA = 40.689226;
		Double longA = -74.044522;
		Double latB = 40.711493; 
		Double longB = -74.013483;
		Geolocation locationA = new Geolocation(latA, longA);
		Geolocation locationB = new Geolocation(latB, longB);
 
		Test.startTest();
    		distance = distCalc.getDistance(locationA, locationB);
		Test.stopTest();
		System.assertEquals(2, Math.round(distance), 'Distance in miles should be approximately 2 ');
	}

	static testMethod void distanceInMeters() {
		GeoDistanceCalculator distCalc = new GeoDistanceCalculator(GeoDistanceCalculator.DistanceUnit.METERS);

		Double distance;
		Double latA = 40.689226;
		Double longA = -74.044522;
		Double latB = 40.711493; 
		Double longB = -74.013483;
 		Geolocation locationA = new Geolocation(latA, longA);
		Geolocation locationB = new Geolocation(latB, longB);

		Test.startTest();
    		distance = distCalc.getDistance(locationA, locationB);
		Test.stopTest();
		System.assertEquals(3602, Math.round(distance), 'Distance in meters should be approximately 3602 ');
	}

	static testMethod void distanceInKiloMeters() {
		GeoDistanceCalculator distCalc = new GeoDistanceCalculator(GeoDistanceCalculator.DistanceUnit.KILOMETERS);

		Double distance;
		Double latA = 40.689226;
		Double longA = -74.044522;
		Double latB = 40.711493; 
		Double longB = -74.013483;
		Geolocation locationA = new Geolocation(latA, longA);
		Geolocation locationB = new Geolocation(latB, longB);

		Test.startTest();
    		distance = distCalc.getDistance(locationA, locationB);
		Test.stopTest();
		System.assertEquals(4, Math.round(distance), 'Distance in kilometers should be approximately 4 ');
	}

}