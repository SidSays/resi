/**
 * Calculates the distance between two geo-locations
 *
 * @Author Ryan Sayles
 * @Email rsayles@acumensolutions.com
 * @Date 9/12/14
 */

public with sharing class GeoDistanceCalculator {

    public enum DistanceUnit {
        FEET,
        YARDS,
        MILES,
        METERS,
        KILOMETERS
    }

    private final DistanceUnit unit;
    private static final Double FEET_PER_KILOMETER = 3280.84;
    private static final Double YARDS_PER_KILOMETER = 1093.61;
    private static final Double MILES_PER_KILOMETER = 0.621371;
    private static final Double METERS_PER_KILOMETER = 1000;

    public GeoDistanceCalculator(DistanceUnit unit) {
        this.unit = unit;
    }

    /**
     * Calculates the distance between two Geolocations.
     *
     * @param   location1   The first set of geolocation coordinates
     * @param   location2   The second set of geolocation coordinates
     */
    public Double getDistance(final Geolocation location1, final Geolocation location2) {
        Integer earthRadiusInKilometers = 6371;
        Double latitudeAInRadians = degreesToRadians(location1.Latitude);
        Double latitudeBInRadians = degreesToRadians(location2.Latitude);
        Double deltaLatitudeInRaidans = degreesToRadians(location2.Latitude - location1.Latitude);
        Double deltaLongitudeInRadians = degreesToRadians(location2.Longitude - location1.Longitude);

        Double haversine = Math.sin(deltaLatitudeInRaidans/2) * Math.sin(deltaLatitudeInRaidans/2) +
                           Math.cos(latitudeAInRadians) * Math.cos(latitudeBInRadians) *
                           Math.sin(deltaLongitudeInRadians/2) * Math.sin(deltaLongitudeInRadians/2);

        Double distFormula = 2 * Math.atan2(Math.sqrt(haversine), Math.sqrt(1-haversine));
        Double distanceInKilometers = earthRadiusInKilometers * distFormula;

        //default return value is in kilometers
        if (unit == DistanceUnit.FEET) {
            return (distanceInKilometers * FEET_PER_KILOMETER);
        }
        else if (unit == DistanceUnit.YARDS) {
            return (distanceInKilometers * YARDS_PER_KILOMETER);
        }
        else if (unit == DistanceUnit.MILES) {
            return (distanceInKilometers * MILES_PER_KILOMETER);
        }
        else if (unit == DistanceUnit.METERS) {
            return (distanceInKilometers * METERS_PER_KILOMETER);
        }
        else {
            return distanceInKilometers;
        }
     
    }

    private Double degreesToRadians(final Double deg) {
        return (deg * (2*Math.asin(1)) / 180.0);
    }

}