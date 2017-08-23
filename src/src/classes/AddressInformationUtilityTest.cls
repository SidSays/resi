/***************************************************************************************************************************************
 * Author     : Amitkumar Bangad, Accenture
 * Date       : 26-July-2013
 * Description: This is Test class for "AddressInformationUtility" class.
 * History
     Version             : 1.0
     Author Last Updated : Amitkumar Bangad, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class AddressInformationUtilityTest{

    private static testMethod void testAddressInformationUtility() {
        AddressInformationUtility.AccountInfo accInfo = new AddressInformationUtility.AccountInfo();
        accInfo.connectStatus = new AddressInformationUtility.connectStatus();
        accInfo.badDebt = new AddressInformationUtility.badDebt();
        accInfo.badDebt.delinquent = new AddressInformationUtility.ArrayOfDelinquent();
        AddressInformationUtility.delinquent del = new AddressInformationUtility.delinquent();
        accInfo.badDebt.delinquent.delinquent = new List<AddressInformationUtility.delinquent>();
        accInfo.badDebt.unreturnedEquipment = new AddressInformationUtility.ArrayOfUnreturnedEquipment();
        AddressInformationUtility.unreturnedEquipment unEquip = new AddressInformationUtility.unreturnedEquipment();
        accInfo.badDebt.unreturnedEquipment.unreturnedEquipment = new List<AddressInformationUtility.unreturnedEquipment>();
        accInfo.badDebt.writtenOff = new AddressInformationUtility.WrittenOff();
        
        AddressInformationUtility.CustomerInfo custInfo = new AddressInformationUtility.CustomerInfo();
        custInfo.customerPremisesEquipment = new AddressInformationUtility.ArrayOfCustomerPremisesEquipment();  
        AddressInformationUtility.customerPremisesEquipment cEqip = new AddressInformationUtility.customerPremisesEquipment();
        custInfo.customerPremisesEquipment.customerPremisesEquipment = new List<AddressInformationUtility.customerPremisesEquipment>();
        
        AddressInformationUtility.LocationInfo loc = new AddressInformationUtility.LocationInfo();
        
        AddressInformationUtility.SubscriptionInfo subInfo = new AddressInformationUtility.SubscriptionInfo();
        subInfo.serviceLineItem = new AddressInformationUtility.ArrayOfServiceLineItem(); 
        AddressInformationUtility.serviceLineItem lineItem = new AddressInformationUtility.serviceLineItem();
        subInfo.serviceLineItem.serviceLineItem = new List<AddressInformationUtility.serviceLineItem>();         
    }
}