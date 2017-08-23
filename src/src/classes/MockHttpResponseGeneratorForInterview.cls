/****************************************************************************************************************************************************
Name: MockHttpResponseGeneratorForInterview 
Description: This class is used to generate mock response for MDU_LaunchInterviewProcessTest class 
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
22 May 2015 Comcast  
*************************************************************************************************************************************************************/
@isTest                       
global class MockHttpResponseGeneratorForInterview implements HttpCalloutMock {
    
    // Implement this interface method
    public Boolean flag;
    public Integer methodNumber;
    
    global MockHttpResponseGeneratorForInterview (Boolean flag) {
        this.flag = flag;
    }

    global MockHttpResponseGeneratorForInterview (Boolean flag, Integer methodCall) {
        this.flag = flag;
        this.methodNumber = methodCall;
    }
   
    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse httpResponse = new httpResponse();
        httpResponse.setHeader('Content-Type', 'application/xml');
              
        if(req.getBody().contains('</email></request-data>')){                                                                    
            //For serachIndividual to create faulty response we pass methodNumber as 1 from test class
            if(!flag && methodNumber == 1){               
                httpResponse.setBody(MDU_MockLaunchInterviewProcResp.launchInterviewErrHandleResp);
                httpResponse.setStatusCode(400);  
            }else{
                httpResponse.setBody(MDU_MockLaunchInterviewProcResp.searchIndividualResp);
                httpResponse.setStatusCode(200);                
            }
            
        }//Create Individual 
        else if(req.getBody().contains('</external-system-info></request-data>')){            
            //For createIndividual to create faulty response we pass methodNumber as 2 from test class
            if(!flag && methodNumber == 2){               
                httpResponse.setBody(MDU_MockLaunchInterviewProcResp.launchInterviewErrHandleResp);
                httpResponse.setStatusCode(400);  
            }else{
                httpResponse.setBody(MDU_MockLaunchInterviewProcResp.createIndividualResp);
                httpResponse.setStatusCode(200); 
            }
                                      
        }//Create Interview
        else if(req.getBody().contains('</create-interview-instance-request>')){                                                   
             //For createInterview to create faulty response we pass methodNumber as 3 from test class
            if(!flag && methodNumber == 3){
                System.debug('Response'+MDU_MockLaunchInterviewProcResp.launchInterviewErrHandleResp);
                httpResponse.setBody(MDU_MockLaunchInterviewProcResp.launchInterviewErrHandleResp);
                httpResponse.setStatusCode(400);  
            }else{
                httpResponse.setBody(MDU_MockLaunchInterviewProcResp.createInterviewResp);
                httpResponse.setStatusCode(200);  
            }
                                     
        }//Search Interview
        else if(req.getBody().contains('</interview-instance-name>')){  
            //For searchInterview to create faulty response we pass methodNumber as 4 from test class
            if(!flag && methodNumber == 4){
                httpResponse.setBody(MDU_MockLaunchInterviewProcResp.launchInterviewErrHandleResp);
                httpResponse.setStatusCode(400);  
            }else{
                 httpResponse.setBody(MDU_MockLaunchInterviewProcResp.searchInterviewResp);
                httpResponse.setStatusCode(200);  
            }
                                     
        }//                 
        else if(req.getBody().contains('</shared-secret-credential>')){
           //For buildSSOUrlWizard to create faulty response we pass methodNumber as 5 from test class
            if(!flag && methodNumber == 5){
                httpResponse.setBody(MDU_MockLaunchInterviewProcResp.launchInterviewErrHandleResp);
                httpResponse.setStatusCode(400);  
            }else{
                httpResponse.setBody(MDU_MockLaunchInterviewProcResp.buildSSOUrlWizardResp);
                httpResponse.setStatusCode(200);  
            }
            
        }                                  
              
        return httpResponse;  
       
    }
}