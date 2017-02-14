@RestResource(urlMapping='/RetrieveAccountHistoryRESTService/*')
/*************************************************************************************************************************************
Name: RetrieveAccountHistoryRESTService
Description: This class calls getBillingArrangementRequest and return Account History depending billing system(DDP/CSG)
Author: Animesh Datta
Date: 18 Jan 2016
*************************************************************************************************************************************/
global class RetrieveAccountHistoryRESTService
{ //This class calls getBillingArrangementRequest and return Account History
    @HttpGet
    global static ResponseHandler getAccountHistory(){ //calls getBillingArrangementRequest and return Account History depending billing system(DDP/CSG)
        ResponseHandler resp=new ResponseHandler();
        try{  
        String id = RestContext.request.params.get('id');
          resp.accountDetails=new List <ESPAccountContactHistory>();
          resp.accountDetails= getBillingArrangement.getBillingArrangementRequest(id);
           if(resp.accountDetails==null)
            resp.error = Label.RetrieveAccountHistoryRESTServiceMessage;
            if(resp.accountDetails.size()<1)
            resp.error = Label.RetrieveAccountHistoryRESTServiceMessage2;
        return resp;
           }
        catch(Exception e){
        resp.error = Label.RetrieveAccountHistoryRESTServiceMessage;
        return resp;}
    }
    
    global class ResponseHandler{ //To handle error and response
        public List <ESPAccountContactHistory> accountDetails;
        public String error;
        
    }
}