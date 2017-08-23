/**
* This is mock class used in MDU_ContractWriteBackBatchTest to cover MDU_ContractWriteBackBatch class.
* Created: 31-March-2015
* Date : 31 March 2015
* Author : Ashish Sonawane
*/

@isTest
                        
global class MockHttpResponseForContractWriteBack implements HttpCalloutMock{
    
    //Bulk</ns216:string-value>
    public boolean flag;
    public String propertyComplexId;    
    public String methodNoRespFail;
    
    global MockHttpResponseForContractWriteBack(boolean flag, String propertyComplexId, String methodRespFail) {
        this.flag = flag;
        this.propertyComplexId = propertyComplexId;        
        this.methodNoRespFail = methodRespFail;       
    }
    
    global HTTPResponse respond(HTTPRequest req) {
       
       MDU_MockResponseUtility responseUtil = new MDU_MockResponseUtility();
       HttpResponse httpResponse = new HttpResponse();      
      
       /*
       * searchExecuted Response
       */        
        
        if(req.getBody().contains('<contract-status>Executed</contract-status>')){
            if(!flag && methodNoRespFail == '1'){
                httpResponse.setHeader('Content-Type', 'application/xml');
                httpResponse.setBody(MDU_MockResponseUtility.emptErrHandleResp);
                httpResponse.setStatusCode(400);
            }else{
                httpResponse.setHeader('Content-Type', 'application/xml');
                httpResponse.setBody(responseUtil.searchExecutedContractResponse);
                httpResponse.setStatusCode(200); 
            }
        }//searchActive Response
        else if(req.getBody().contains('<contract-status>Active</contract-status>')){
            if(!flag && methodNoRespFail == '2'){
                httpResponse.setHeader('Content-Type', 'application/xml');
                httpResponse.setBody(MDU_MockResponseUtility.emptErrHandleResp);
                httpResponse.setStatusCode(400);
            }else{
                httpResponse.setHeader('Content-Type', 'application/xml');
                httpResponse.setBody(responseUtil.searchActiveContractResponse);
                httpResponse.setStatusCode(200);  
            }
        }//contractDetails Response
        else if(req.getBody().contains('</get-request>')){
            if(!flag && methodNoRespFail == '3'){
                httpResponse.setHeader('Content-Type', 'application/xml');
                httpResponse.setBody(MDU_MockResponseUtility.emptErrHandleResp);
                httpResponse.setStatusCode(400);
            }else{
                  //Replace Property Complex Id in response with propertyComplexId
                String updatedResponse = '';
                String contractDetailsResp = responseUtil.getContractResponse;
                List<String> responseSplit = contractDetailsResp.split('121250044');
                updatedResponse = responseSplit[0]+ propertyComplexId + responseSplit[1];                                           
                httpResponse.setHeader('Content-Type', 'application/xml');
                httpResponse.setBody(updatedResponse);
                httpResponse.setStatusCode(200);    
            }
        }
        
        //Contract Attachment Response
        else if(req.getBody().contains('</get-language-request>')){
            if(!flag && methodNoRespFail == '4'){
                httpResponse.setHeader('Content-Type', 'application/xml');
                httpResponse.setBody(MDU_MockResponseUtility.emptErrHandleResp);
                httpResponse.setStatusCode(400);
            }else{
                httpResponse.setHeader('Content-Type', 'application/xml');
                httpResponse.setBody(responseUtil.searchActiveContractAttachmentResp);
                httpResponse.setStatusCode(200);  
            }
        }
        
        //Update contract subStatus Response
        else if(req.getBody().contains('</update-substatus-request>')){
            if(!flag && methodNoRespFail == '5'){
                httpResponse.setHeader('Content-Type', 'application/xml');
                httpResponse.setBody(MDU_MockResponseUtility.emptErrHandleResp);
                httpResponse.setStatusCode(400);
            }else{
                httpResponse.setHeader('Content-Type', 'application/xml');
                httpResponse.setBody(responseUtil.contractSubStatusUpdateResp);
                httpResponse.setStatusCode(200);  
            }
        }//Update contract term Response        
        else if(req.getBody().contains('</update-term-request>')){
            if(!flag && methodNoRespFail == '6'){
                httpResponse.setHeader('Content-Type', 'application/xml');
                httpResponse.setBody(MDU_MockResponseUtility.emptErrHandleResp);
                httpResponse.setStatusCode(400);
            }else{
                httpResponse.setHeader('Content-Type', 'application/xml');
                httpResponse.setBody(responseUtil.contractTermUpdateResp);
                httpResponse.setStatusCode(200);        
            }
        }//Update custom property Response
        else if(req.getBody().contains('</update-custom-property-request>')){
            if(!flag && methodNoRespFail == '7'){
                httpResponse.setHeader('Content-Type', 'application/xml');
                httpResponse.setBody(MDU_MockResponseUtility.emptErrHandleResp);
                httpResponse.setStatusCode(400);
            }else{
                httpResponse.setHeader('Content-Type', 'application/xml');
                httpResponse.setBody(responseUtil.contractCustomPropUpdateResp);
                httpResponse.setStatusCode(200); 
            }
        }
        else if(req.getBody().contains('</get-request>')){
            if(!flag && methodNoRespFail == '8'){
                httpResponse.setHeader('Content-Type', 'application/xml');
                httpResponse.setBody(MDU_MockResponseUtility.emptErrHandleResp);
                httpResponse.setStatusCode(400);
            }else{
                  //Replace Property Complex Id in response with propertyComplexId
                String updatedResponse = '';
                String contractDetailsResp = responseUtil.getContractResponsefailed;
                List<String> responseSplit = contractDetailsResp.split('121250044');
                updatedResponse = responseSplit[0]+ propertyComplexId + responseSplit[1];                                           
                httpResponse.setHeader('Content-Type', 'application/xml');
                httpResponse.setBody(updatedResponse);
                httpResponse.setStatusCode(200);    
            }
        }  
        return httpResponse;       
    }
}