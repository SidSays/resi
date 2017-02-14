/**
 * Name     : GSIMeetingInfoService_Test
 * Usage    : Test Class for GSIMeetingInfoService.
 *  
 * Created By      : Virendra
 * Modified By     : Virendra
 * Modified Date   : July 2, 2013
 */
@isTest
private class GSIMeetingInfoService_Test {


      
   // This test method should give 100% coverage 
    static testmethod void testGSIMeetingInfoParser() {
        // List<GSI_Node__c> nodeList = GSI_TestDataUtility.getGSINodeList(15);
        //insert nodeList;
        TriggerSettings__c taskTrigger = new TriggerSettings__c();
		taskTrigger.Name = 'TaskTrigger';
		taskTrigger.isActive__c = True;
		insert taskTrigger; 
        amp_Content_Detail__c contentDetail = GSI_TestDataUtility.getContentDetails();
               
        String json = '[{'+
        '        \"ClientName\" : \"Tomas Hunt\",'+
        '        \"SendEmail\"  : \"YES\",'+
        '        \"MeetingDate\": \"'+system.today()+'\",'+ 
        '        \"SelectedContents\" : ['+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Construction\\/Construction 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Construction\",'+
        '            \"fileName\" : \"Construction 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Construction\\/Construction 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Construction\",'+
        '            \"fileName\" : \"Construction 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Energy\\/Energy 3.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Energy\",'+
        '            \"fileName\" : \"Energy 3.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Marine\\/Marine 5.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Marine\",'+
        '            \"fileName\" : \"Marine 5.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Marine\\/Marine 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Marine\",'+
        '            \"fileName\" : \"Marine 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Construction\\/Construction 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Construction\",'+
        '            \"fileName\" : \"Construction 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Energy\\/Energy 2.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Energy\",'+
        '            \"fileName\" : \"Energy 2.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Marine\\/Marine 6.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Marine\",'+
        '            \"fileName\" : \"Marine 6.pdf\"'+
        '          }'+
        '        ],'+
        '        \"FollowDate\" : \"\",'+
        '        \"Company\" : \"ABS\",'+
        '        \"FirstName\" : \"Tomas\",'+
        '        \"Phone\" : \"415 321 4554\",'+
        '        \"LastName\" : \"Hunt\",'+
        '        \"Email\" : \"thunt1@abc.com\",'+
        '        \"Notes\" : \"\"'+ 
        '  },{'+
        '        \"ClientName\" : \"Tomas Hunt Second\",'+
        '        \"MeetingDate\": \"'+system.today()+'\",'+ 
        '        \"SelectedContents\" : ['+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Construction\\/Construction 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Construction\",'+
        '            \"fileName\" : \"Construction 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Construction\\/Construction 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Construction\",'+
        '            \"fileName\" : \"Construction 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Energy\\/Energy 3.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Energy\",'+
        '            \"fileName\" : \"Energy 3.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Marine\\/Marine 5.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Marine\",'+
        '            \"fileName\" : \"Marine 5.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Marine\\/Marine 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Marine\",'+
        '            \"fileName\" : \"Marine 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Construction\\/Construction 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Construction\",'+
        '            \"fileName\" : \"Construction 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Energy\\/Energy 2.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Energy\",'+
        '            \"fileName\" : \"Energy 2.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Marine\\/Marine 6.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Marine\",'+
        '            \"fileName\" : \"Marine 6.pdf\"'+
        '          }'+
        '        ],'+
        '        \"FollowDate\" : \"\",'+ 
        '        \"Company\" : \"ABS\",'+
        '        \"FirstName\" : \"Tomas\",'+
        '        \"Phone\" : \"415 321 4554\",'+
        '        \"LastName\" : \"Hunt\",'+
        '        \"Email\" : \"thunt@abc.com\",'+
        '        \"Notes\" : \"\"'+
        '  }]';
        
        /*public static List<GSIMeetingInfo> parse(String json) {
        return new GSIMeetingInfo.getFullGSIMeetingInfo(System.JSON.createParser(json));
        }*/
        
        
      
        List<GSIMeetingInfo> meetingInfos = GSIMeetingInfo.getFullGSIMeetingInfo(System.JSON.createParser(json));
        System.assert(meetingInfos != null);
        for(GSIMeetingInfo meetingInfo:meetingInfos){
            System.assert(meetingInfo != null);
            System.assert(meetingInfo.ClientName != null);
            System.assert(meetingInfo.SelectedContents != null);
        }
        
        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        List<GSIMeetingInfo> objRoots = GSIMeetingInfo.getFullGSIMeetingInfo(System.JSON.createParser(json));
        for(GSIMeetingInfo objRoot:objRoots){
            System.assert(objRoot != null);
            System.assert(objRoot.ClientName == null);
            System.assert(objRoot.SelectedContents == null);
            System.assert(objRoot.FollowDate == null);
            System.assert(objRoot.Company == null);
            System.assert(objRoot.FirstName == null);
            System.assert(objRoot.Phone == null);
            System.assert(objRoot.LastName == null);
            System.assert(objRoot.Email == null);
            System.assert(objRoot.Notes == null);
        }
    }
    
    
     static testmethod void testCreatGSIMeetingInfoService() {
        test.startTest();
        TriggerSettings__c taskTrigger = new TriggerSettings__c();
            taskTrigger.Name = 'TaskTrigger';
            taskTrigger.isActive__c = True;
            insert taskTrigger; 
        // List<GSI_Node__c> nodeList = GSI_TestDataUtility.getGSINodeList(15);
        //insert nodeList;
        
        amp_Content_Detail__c contentDetail = GSI_TestDataUtility.getContentDetails();
        
          RestRequest req = new RestRequest(); 
          RestResponse res = new RestResponse();
          String baseUrl = String.valueof(URL.getSalesforceBaseUrl().toExternalForm());
          boolean  refrshFlag = true;
          req = new RestRequest(); 
          res = new RestResponse();
          
          String gsiJsonMeetingInfo = '[{'+
        '        \"ClientName\" : \"Tomas Hunt\",'+
        '        \"SendEmail\"  : \"YES\",'+
        '        \"MeetingDate\": \"'+system.today()+'\",'+ 
        '        \"SelectedContents\" : ['+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Construction\\/Construction 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Construction\",'+
        '            \"fileName\" : \"Construction 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Construction\\/Construction 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Construction\",'+
        '            \"fileName\" : \"Construction 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Energy\\/Energy 3.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Energy\",'+
        '            \"fileName\" : \"Energy 3.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Marine\\/Marine 5.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Marine\",'+
        '            \"fileName\" : \"Marine 5.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Marine\\/Marine 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Marine\",'+
        '            \"fileName\" : \"Marine 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Construction\\/Construction 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Construction\",'+
        '            \"fileName\" : \"ContentTitle.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Energy\\/Energy 2.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Energy\",'+
        '            \"fileName\" : \"Energy 2.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Marine\\/Marine 6.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Marine\",'+
        '            \"fileName\" : \"Marine 6.pdf\"'+
        '          }'+
        '        ],'+
        '        \"FollowDate\" : \"\",'+
        '        \"Company\" : \"ABS\",'+
        '        \"FirstName\" : \"Tomas\",'+
        '        \"Phone\" : \"415 321 4554\",'+
        '        \"LastName\" : \"Hunt\",'+
        '        \"Email\" : \"thunt1@abc.com\",'+
        '        \"Notes\" : \"\"'+ 
        '  },{'+
        '        \"ClientName\" : \"Virendra Singh\",'+
        '        \"SendEmail\"  : \"YES\",'+
        '        \"MeetingDate\": \"'+system.today()+'\",'+ 
        '        \"SelectedContents\" : ['+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Construction\\/Construction 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Construction\",'+
        '            \"fileName\" : \"Construction 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Construction\\/Construction 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Construction\",'+
        '            \"fileName\" : \"Construction 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Energy\\/Energy 3.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Energy\",'+
        '            \"fileName\" : \"Energy 3.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Marine\\/Marine 5.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Marine\",'+
        '            \"fileName\" : \"Marine 5.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Marine\\/Marine 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Marine\",'+
        '            \"fileName\" : \"Marine 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Construction\\/Construction 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Construction\",'+
        '            \"fileName\" : \"ContentTitle.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Energy\\/Energy 2.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Energy\",'+
        '            \"fileName\" : \"Energy 2.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Marine\\/Marine 6.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Marine\",'+
        '            \"fileName\" : \"Marine 6.pdf\"'+
        '          }'+
        '        ],'+
        '        \"FollowDate\" : \"\",'+ 
        '        \"Company\" : \"ABS\",'+
        '        \"FirstName\" : \"Tomas\",'+
        '        \"Phone\" : \"415 321 4554\",'+
        '        \"LastName\" : \"Hunt\",'+
        '        \"Email\" : \"thunt@abc.com\",'+
        '        \"Notes\" : \"\"'+
         '  },{'+
        '        \"ClientName\" : \"Virendra Singh\",'+
        '        \"SendEmail\"  : \"YES\",'+
        '        \"MeetingDate\": \"'+system.today()+'\",'+ 
        '        \"SelectedContents\" : ['+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Construction\\/Construction 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Construction\",'+
        '            \"fileName\" : \"Construction 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Construction\\/Construction 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Construction\",'+
        '            \"fileName\" : \"Construction 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Energy\\/Energy 3.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Energy\",'+
        '            \"fileName\" : \"Energy 3.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Marine\\/Marine 5.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Marine\",'+
        '            \"fileName\" : \"Marine 5.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Marine\\/Marine 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Marine\",'+
        '            \"fileName\" : \"Marine 1.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Construction\\/Construction 1.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Construction\",'+
        '            \"fileName\" : \"ContentTitle.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Energy\\/Energy 2.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Energy\",'+
        '            \"fileName\" : \"Energy 2.pdf\"'+
        '          },'+
        '          {'+
        '            \"filePath\" : \"\\/Users\\/iandrosov\\/Library\\/Application Support\\/iPhone Simulator\\/6.1\\/Applications\\/F66D7F8D-4BF3-4242-9A7D-AE69399540A9\\/Documents\\/Marine\\/Marine 6.pdf\",'+
        '            \"fileType\" : \"pdf\",'+
        '            \"categoryName\" : \"Marine\",'+
        '            \"fileName\" : \"Marine 6.pdf\"'+
        '          }'+
        '        ],'+
        '        \"FollowDate\" : \"\",'+
        '        \"Company\" : \"ABS\",'+
        '        \"FirstName\" : \"Tomas\",'+
        '        \"Phone\" : \"415 321 4554\",'+
        '        \"LastName\" : \"Hunt\",'+
        '        \"Email\" : \"thunt2@abc.com\",'+
        '        \"Notes\" : \"\"'+
        '  }'+
        ']';
              
              
           Account testAccount = new Account();
            testAccount.Name = 'UCLA Medical Center';
            testAccount.ShippingStreet = '1250 16th Street';
            testAccount.ShippingCity = 'Santa Monica';
            testAccount.ShippingState = 'CA';
            testAccount.ShippingPostalCode = '90404';
            testAccount.ShippingCountry = 'USA';
            testAccount.BillingStreet = '1250 16th Street';
            testAccount.BillingCity = 'Santa Monica';
            testAccount.BillingState = 'CA';
            testAccount.BillingPostalCode = '90404';
            testAccount.Phone = '(310) 319-4000';
            insert testAccount;
        
            List<Contact> contacts = new List<Contact>();
            Contact rbmContact = new Contact();
            rbmContact.FirstName = 'John';
            rbmContact.LastName = 'Doe';
            rbmContact.AccountId = testAccount.Id;
            rbmContact.MailingCity = 'Santa Monica';
            rbmContact.MailingCountry = 'USA';
            rbmContact.MailingPostalCode = '90404';
            rbmContact.MailingState = 'CA';
            rbmContact.MailingStreet = '1250 16th Street';
            rbmContact.Email = 'thunt@abc.com';
            rbmContact.OwnerId = UserInfo.getUserId();
           
            Contact rbmContact1 = new Contact();
            rbmContact1.FirstName = 'John1';
            rbmContact1.LastName = 'Doe1';
            rbmContact1.AccountId = testAccount.Id;
            rbmContact1.MailingCity = 'Santa Monica1';
            rbmContact1.MailingCountry = 'USA';
            rbmContact1.MailingPostalCode = '90404';
            rbmContact1.MailingState = 'CA';
            rbmContact1.MailingStreet = '1250 16th Street';
            rbmContact1.Email = 'thunt@abc.com';
            rbmContact1.OwnerId = UserInfo.getUserId();
            
            contacts.add(rbmContact);
            contacts.add(rbmContact1);
            insert contacts;
            
            //Contact tst_cnt = GSIMeetingInfoSendEmail.priorityContact(contacts);
            
            List<Lead> leads = new List<Lead>();
            //Id bsdRecordTypeId = returnRecordTypeId('BSD Lead Record Type');
            //Id gbsRecordTypeId = returnRecordTypeId('GBS Lead Record Type');
           
		    /* Additional code added by RESI AD Team
			 * Insert a record for LeadTrigger on TriggerSetting__c for lead trigger to run 	
			 */
			
            TriggerSettings__c leadTrigger = new TriggerSettings__c();
            leadTrigger.Name = 'LeadTrigger';
            leadTrigger.isActive__c = True;
            insert leadTrigger; 
			
			
            Lead testLead = new Lead(Company='Test Lead1', OwnerId = UserInfo.getUserId(),Email = 'thunt1@abc.com',FirstName='John1',LastName='Doe1',Status='Open',Phone='(555) 555-5555' );
            Lead testLead1 = new Lead(Company='Test Lead2', OwnerId = UserInfo.getUserId(),Email = 'thunt1@abc.com',FirstName='John2',LastName='Doe2',Status='Open',Phone='(555) 555-5555' );
            
            
            leads.add(testLead);
            leads.add(testLead1);
            insert leads;
            
            
          GSI_TestDataUtility.getContentDetails();    
          Blob reqBody = Blob.valueOf(gsiJsonMeetingInfo);
          req.requestBody = reqBody; 
          req.addHeader('Content-Type', 'application/json');
          req.httpMethod = 'POST';
          req.requestURI = baseUrl+'/services/apexrest/gsimeetinginfo/'+refrshFlag;  
          RestContext.request = req;
          RestContext.response = res;
          List<GSIMeetingInfoResponse>  lstGSIMeetingInfoResponse = GSIMeetingInfoService.doPost(gsiJsonMeetingInfo);
         
         //Total Meeting should be created  
          system.assertEquals(lstGSIMeetingInfoResponse.size(),3);
           
          Id meetingInfoId = lstGSIMeetingInfoResponse.get(0).id;

          
          for(GSI_Meeting_Info__c meetingInfo :[Select g.Status__c, g.Name, g.First_Name__c, g.Email__c, g.Company__c,
                                                 (Select Name, Content_Detail__c, Content_Name__c, Content_Type__c From GSI_Selected_Content__r)         
                                                  From GSI_Meeting_Info__c g where g.id =:meetingInfoId]){
             
             //Company Name is 'GSI Corp.'
             //system.assertEquals(meetingInfo.Company__c, 'Company0');

             List<GSI_Selected_Content__c> lstSelected_Contents = meetingInfo.GSI_Selected_Content__r; 
             system.assertEquals(lstSelected_Contents.size(), 8);
             
          } 
        test.stopTest();
        
    }
    
     private static string returnRecordTypeId(String recordTypeName) {
         String recordTypeId ;
         Schema.DescribeSObjectResult tskResult = Schema.SObjectType.Lead;
         Map<String,Schema.RecordTypeInfo> rtMapByName = tskResult.getRecordTypeInfosByName();
         if(rtMapByName.containsKey(recordTypeName))
         recordTypeId = rtMapByName.get(recordTypeName).getRecordTypeId(); 
         return recordTypeId;
    }
}