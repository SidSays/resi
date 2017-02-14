/**
* This is mock class used in MDU_ViewContractPageCtrlTest to cover MDU_ViewContractPageCtrl class.
* Created: 31-March-2015
* Date : 31 March 2015
* Author : Sagar Gurav
*/

@isTest
                        
global class MockHttpResponseForViewContract implements HttpCalloutMock{
    
    public boolean flag;
     //use to generate fail response in mock call out base on request which want to fail 
    public Integer methodNumber;
    
    global MockHttpResponseForViewContract(boolean flag) {
        this.flag = flag;
    }
    
    global MockHttpResponseForViewContract(boolean flag, Integer methodNumber) {
        this.flag = flag;
        this.methodNumber = methodNumber;
    }
    

    global HTTPResponse respond(HTTPRequest req) {
       
        MDU_MockResponseUtility responseUtil = new MDU_MockResponseUtility();
        HttpResponse httpResponse = new HttpResponse();      
      
        //Create Success/Fail MockResponse    
        httpResponse.setHeader('Content-Type', 'application/xml');
        if(req.getBody().contains('</get-request>')){            
            //Set methodNumber to 1 to create fail response to read contract data from Test class     
            if(!flag && methodNumber == 1){
                httpResponse.setBody(MDU_MockViewContractResponse.viewContractErrHandleResp);
                httpResponse.setStatusCode(400);  
            }else{
                httpResponse.setBody(MDU_MockViewContractResponse.readContractDataResponse);
                httpResponse.setStatusCode(200); 
            }
        }
        else if(req.getBody().contains('</get-url-request>')){           
            //Set methodNumber to 2 to create fail response to create URL use to display contract data from Test class 
            if(!flag && methodNumber == 2){
                httpResponse.setBody(MDU_MockViewContractResponse.viewContractErrHandleResp);
                httpResponse.setStatusCode(400);  
            }else{
                httpResponse.setBody(MDU_MockViewContractResponse.readContractURLResponse);
                httpResponse.setStatusCode(200);  
            }
        }
        return httpResponse;
                    
    }
}