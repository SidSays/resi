public class IntegrationTestingController {
    
    public String country {get;set;}
    public String unitType {get;set;}
    public String city {get;set;}
    public String state {get;set;}
    public String unitNumber {get;set;}
    public String zipCode {get;set;}
    public String zip4Code {get;set;}
    public String streetAddress1 {get;set;}
    public String streetAddress2 {get;set;}
    public String locationId {get;set;}
    public String billingHouseKey {get;set;}
    public String status {get;set;}
    
    public String accInfo1 {get;set;}
    public String custInfo1 {get;set;}
    public String subInfo1 {get;set;}
    public String locInfo1 {get;set;}
    public String serverResponse {get;set;}
    public String serverRequest {get;set;}
    public String responseBody {get;set;}
    
    public IntegrationTestingController() {
        country= '';
        unitType= '';
        city= '';
        state= '';
        unitNumber= '';
        zipCode= '';
        zip4Code= '';
        streetAddress1= '';
        streetAddress2= '';
        locationId= '';
        billingHouseKey= ''; 
        status = ''; 
        accInfo1 = '';
        custInfo1 = '';
        subInfo1 = '';
        locInfo1 = '';  
    }
    public PageReference test (){
        status = ''; 
        accInfo1 = '';
        custInfo1 = '';
        subInfo1 = '';
        locInfo1 = ''; 
        UpdateInformationInSalesforce.cAddress address = new UpdateInformationInSalesforce.cAddress();
        
        address.country = country;
        address.UnitType = unitType;
        address.city = city;
        address.state = state;
        address.unitNumber = unitNumber;
        address.zipCode= zipCode;
        address.zip4Code= zip4Code;
        address.streetAddress1= streetAddress1;
        address.streetAddress2= streetAddress2;
        address.locationId= locationId;
        address.billingHouseKey= billingHouseKey;
        status = UpdateInformationInSalesforce.getUpdateStatus(address);
        serverRequest = UpdateInformationInSalesforce.SOAPRequest;
        serverResponse = UpdateInformationInSalesforce.SOAPResponse;
        responseBody = UpdateInformationInSalesforce.SOAPResponseBody;
        if(UpdateInformationInSalesforce.accInfo != null){
            accInfo1 = UpdateInformationInSalesforce.accInfo.toString();
        }
        if(UpdateInformationInSalesforce.custInfo!= null){
            custInfo1 = UpdateInformationInSalesforce.custInfo.toString();
        }
        if(UpdateInformationInSalesforce.locInfo!= null){
            locInfo1 = UpdateInformationInSalesforce.locInfo.toString();
        }
        if(UpdateInformationInSalesforce.subInfo!= null){
            subInfo1 = UpdateInformationInSalesforce.subInfo.toString();
        }
        return null;
    }
    
}