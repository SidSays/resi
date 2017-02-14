/***************************************************************************************************************************************
 * Author     : Amitkumar Bangad, Accenture
 * Date       : 26-July-2013
 * Description: This class creates sample mock for test coverage.
  * History
     Version             : 1.0
     Author Last Updated : Amitkumar Bangad, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
global class SuperAPIMock2 implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody('<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><env:Header><typ:responseHeader xmlns:typ="http://xml.comcast.com/types"><typ:timestamp>2013-07-26T08:28:22-04:00</typ:timestamp><typ:trackingId>ab248899-mn181523-yz144803</typ:trackingId></typ:responseHeader></env:Header><env:Body><m:getAddressInfoResponse xmlns:m="http://xml.comcast.com/accountmanagementcontroller/services"><m:getAddressInfoReturn><typ:accountInfo xmlns:typ="http://xml.comcast.com/accountmanagementcontroller/types"><typ:accountNumber>9992054330301</typ:accountNumber><typ:connectStatus><typ:status>ACTIVE</typ:status><typ:eventDate>2013-05-20-04:00</typ:eventDate><typ:disconnectReason>Dummy</typ:disconnectReason><typ:statusDetail>ACTIVE</typ:statusDetail></typ:connectStatus><typ:badDebt><typ:delinquent><typ:delinquent><typ:amount>50</typ:amount><typ:bucket>10</typ:bucket></typ:delinquent><typ:delinquent><typ:amount>50</typ:amount><typ:bucket>10</typ:bucket></typ:delinquent><typ:delinquent><typ:amount>50</typ:amount><typ:bucket xsi:nil="true"/></typ:delinquent></typ:delinquent><typ:unreturnedEquipment><typ:unreturnedEquipment><typ:equipmentUnreturnedCharge>0</typ:equipmentUnreturnedCharge></typ:unreturnedEquipment></typ:unreturnedEquipment><typ:writtenOff><typ:amount>0.00</typ:amount><typ:writtenOffDate>2013-05-20 11:34:00</typ:writtenOffDate></typ:writtenOff><typ:totalAccountBadDebt>150.00</typ:totalAccountBadDebt></typ:badDebt></typ:accountInfo><typ:customerInfo xmlns:typ="http://xml.comcast.com/accountmanagementcontroller/types"><typ:doNotKnock>false</typ:doNotKnock></typ:customerInfo><typ:locationInfo xmlns:typ="http://xml.comcast.com/accountmanagementcontroller/types"><typ:propertyCode>2234452</typ:propertyCode><typ:neverHouse>false</typ:neverHouse></typ:locationInfo><typ:subscriptionInfo xmlns:typ="http://xml.comcast.com/accountmanagementcontroller/types"><typ:totalMonthlyRate>100</typ:totalMonthlyRate></typ:subscriptionInfo></m:getAddressInfoReturn></m:getAddressInfoResponse></env:Body></env:Envelope>');
    res.setStatusCode(200);    
    return res;
    }
}