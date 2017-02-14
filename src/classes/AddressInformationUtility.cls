/**
* Class Name: AddressInformationUtility
* Author: Amitkumar Bangad, Accenture
* Date: 27-june-2013 
* Requirement # CR Super API Mapping
* Description: This Utility class created contains declaration of inner classes that will be used for mapping
* Last Modified :
*/
public class AddressInformationUtility {
    // Account Info
    public class AccountInfo {
        public String accountNumber;
        public ConnectStatus connectStatus;
        public BadDebt badDebt;
    }
    public class ConnectStatus {
        public String status;
        public Date eventDate;
        public String disconnectReason;
        public String statusDetail;
    }   
    public class BadDebt {
        public ArrayOfDelinquent delinquent;
        public ArrayOfUnreturnedEquipment unreturnedEquipment;
        public WrittenOff writtenOff;
        public Decimal totalAccountBadDebt;
    }
    public class ArrayOfDelinquent {
        public Delinquent[] delinquent;
    }
    public class Delinquent {
        public Decimal amount;
        public Integer bucket; 
    }
    public class ArrayOfUnreturnedEquipment {
        public UnreturnedEquipment[] unreturnedEquipment;
    }
    public class UnreturnedEquipment {
        public Decimal equipmentUnreturnedCharge;
    }
     public class WrittenOff {
        public Decimal amount;
        public DateTime writtenOffDate;
    }
    
    // Subscription Info
    public class SubscriptionInfo {
        public Decimal totalMonthlyRate;
        public ArrayOfServiceLineItem serviceLineItem;
    }
    public class ArrayOfServiceLineItem {
        public ServiceLineItem[] serviceLineItem;
    }
    public class ServiceLineItem {
        public String serviceType;
        public String tier;
        public Date activatedDate;
        public Decimal rate;
    }
    
    // Location info
     public class LocationInfo {
        public String propertyCode;
        public Boolean neverHouse;
    }
    
    // Customer Info
    public class CustomerInfo {
        public Boolean doNotKnock;
        public ArrayOfCustomerPremisesEquipment customerPremisesEquipment;
    }
    public class ArrayOfCustomerPremisesEquipment {
        public CustomerPremisesEquipment[] customerPremisesEquipment;
    }
     public class CustomerPremisesEquipment {
        public String type_x;
        public String make;
        public String model;
        public String serialNumber;
        public Boolean active;
    }
}