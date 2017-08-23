/**
* This is mock class used in MDU_DeleteContractPageCtrlTest to cover MDU_DeleteContractPageCtrl class.
* Created: 21-May-2015
* Author : Ashish Sonawane
*/

@isTest
                        
global class MockHttpResponseForDeleteContract implements HttpCalloutMock{
    
    public boolean flag;
    //use to generate fail response in mock call out base on request which want to fail  
    public Integer methodNumber;
    
    global MockHttpResponseForDeleteContract(boolean flag) {
        this.flag = flag;
    }
    
    global MockHttpResponseForDeleteContract(boolean flag, Integer methodNumber) {
        this.flag = flag;
        this.methodNumber = methodNumber;
    }

    global HTTPResponse respond(HTTPRequest req) {
       
        MDU_MockResponseUtility responseUtil = new MDU_MockResponseUtility();
        HttpResponse httpResponse = new HttpResponse();      
      
             
        httpResponse.setHeader('Content-Type', 'application/xml');
        if(req.getBody().contains('<username>')){            
            if(!flag && methodNumber == 1){
                httpResponse.setBody(MDU_MockDeleteContractResponse.deleteContractErrHandleResp);
                httpResponse.setStatusCode(400);  
            }else{
                httpResponse.setBody(MDU_MockDeleteContractResponse.deleteContractResp1);
                httpResponse.setStatusCode(200);  
            }
        }
        else if(req.getBody().contains('</id>')){           
            if(!flag && methodNumber == 2){
                httpResponse.setBody(MDU_MockDeleteContractResponse.deleteContractErrHandleResp);
                httpResponse.setStatusCode(400);  
            }else{
                httpResponse.setBody(MDU_MockDeleteContractResponse.deleteContractResp2);
                httpResponse.setStatusCode(200);
            }
        }
        else if(req.getBody().contains('</uuid>')){           
            if(!flag && methodNumber == 3){
                httpResponse.setBody(MDU_MockDeleteContractResponse.deleteContractErrHandleResp);
                httpResponse.setStatusCode(400);  
            }else{
                httpResponse.setBody(MDU_MockDeleteContractResponse.deleteContractResp3);
                httpResponse.setStatusCode(200); 
            }
        }
        return httpResponse;
                    
    }
}