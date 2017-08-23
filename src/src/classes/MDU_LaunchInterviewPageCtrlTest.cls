@isTest  
public class MDU_LaunchInterviewPageCtrlTest{
     static testmethod void searchIntrviewProcess(){
         try{
         TestDataUtility.createCustomSettingRecords();
         Id currentProfileId = userinfo.getProfileId();             
         TestDataUtility.setApplicationLogEnableCS(currentProfileId);   
         TestDataUtility.createInterviewTemplateMapping();
         User xcUser = TestDataUtility.createXCIntegrationUser();
         MDU_Property__c prop = TestDataUtility.createProperty();
         Database.insert(prop);
         Opportunity oppo = new opportunity();
         oppo.name = 'test';
         oppo.StageName = 'Contract Document Review';
         oppo.CloseDate = System.today();
         oppo.ECM_Interview_Instance_Name__c = 'EcMtest';
         insert oppo;
         Opportunity_Property__c opptyProperty = TestDataUtility.createOppProperty(oppo.id ,prop.id);
         //opptyProperty.ECM__c = '123445';
         Database.Insert(opptyProperty); 
         ApexPages.StandardController controller = new ApexPages.StandardController(oppo);
         MDU_LaunchInterviewPageCtrl obj = new MDU_LaunchInterviewPageCtrl(controller);
         obj.launchInterviewProcessCustom();
         obj.resumeInterviewProcess();
         obj.disableLaunchButton(oppo.Id);
         obj.deleteInterview();
         obj.getOpptyPropertyDetail(oppo.Id);
         } catch(Exception e){

             Boolean expectedExceptionThrown =  e.getMessage().contains('ERROR>>>') ? true : false;

            system.assertEquals(expectedExceptionThrown,true);      

            }

        

     }
    static testmethod void disableLaunchButtonMethod(){
        
		TestDataUtility.createCustomSettingRecords();
         Id currentProfileId = userinfo.getProfileId();             
         TestDataUtility.setApplicationLogEnableCS(currentProfileId);   
         TestDataUtility.createInterviewTemplateMapping();
         User xcUser = TestDataUtility.createXCIntegrationUser();
         MDU_Property__c prop = TestDataUtility.createProperty();
         Database.insert(prop);
         Opportunity oppo = new opportunity();
         oppo.name = 'test';
         oppo.StageName = 'Contract Document Review';
         oppo.CloseDate = System.today();
         oppo.ECM_Interview_Instance_Name__c = 'EcMtest1';
         insert oppo;
         Opportunity_Property__c opptyProperty = TestDataUtility.createOppProperty(oppo.id ,prop.id);
         opptyProperty.ECM__c = '123445';
         Database.Insert(opptyProperty); 
         ApexPages.StandardController controller = new ApexPages.StandardController(oppo);
         MDU_LaunchInterviewPageCtrl obj = new MDU_LaunchInterviewPageCtrl(controller);
         obj.launchInterviewProcessCustom();
         obj.resumeInterviewProcess();
         obj.disableLaunchButton(oppo.Id);
         obj.deleteInterview();
         obj.getOpptyPropertyDetail(oppo.Id);
     }
     static testmethod void disableLaunchButtonElseMethod(){
       
         Opportunity oppo = new opportunity();
         oppo.name = 'test';
       oppo.StageName = 'Open';
         oppo.CloseDate = System.today();
   oppo.ECM_Interview_Instance_Name__c = '';
         insert oppo;
          ApexPages.StandardController controller = new ApexPages.StandardController(oppo);
         MDU_LaunchInterviewPageCtrl obj = new MDU_LaunchInterviewPageCtrl(controller);
          obj.disableLaunchButton(oppo.Id);
         obj.launchInterviewProcessCustom();
          obj.resumeInterviewProcess();
     }
    
    }