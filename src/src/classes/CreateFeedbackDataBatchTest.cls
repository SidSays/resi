@isTest
public class CreateFeedbackDataBatchTest {
    static testmethod void testChatterProfilePictureUpdateBatch (){
       String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
        String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
        string BATCH_JOB_NAME = 'ChatterProfilePictureUpdateBatch';
        string GOAL_STATUS_COMPLETE = 'Completed';
        string JOB_STATUS = 'Draft';
        string NEW_LINE = '\n';
        string SYSTEM_EXCEPTION = 'System Exception - ';    
        string RECORD_TYPE_SEPERATION = ';';
        string JOB_COMMENT = ' ';
        string JOB_NAME_SPACE =  ' - ';
        //List<FeedbackData__c> feedbackDataList = new List<FeedbackData__c>();
        
        FeedbackData__c XSPWalkalongObs = new FeedbackData__c();
        XSPWalkalongObs.Name = 'XSP Ridealong';
        XSPWalkalongObs.Form_Name__c = 'XSP Ridealong';
        XSPWalkalongObs.No_of_Weeks__c = 1;
        XSPWalkalongObs.Start_Date__c = system.today();
        XSPWalkalongObs.Static_Resource_Name__c = 'WalkalongObs';
        insert XSPWalkalongObs;
      
         test.startTest();
           CreateFeedbackDataBatch cPPB = new CreateFeedbackDataBatch('XSP Ridealong');
           database.executebatch(cPPB );
         Test.stopTest(); 
         System.schedule('Scheduled Job 1', '0 0 * * * ?', new CreateFeedbackDataBatchSchedule('XSP Ridealong'));
    }
 
   static testmethod void testSuperCoach (){
      //List<FeedbackData__c> feedbackDataList1 = new List<FeedbackData__c>(); 
      
       FeedbackData__c superCAR1_1 = new FeedbackData__c();
        superCAR1_1.Name = 'CAR Manager 1:1 Observation';
        superCAR1_1.Form_Name__c = 'CAR Manager 1:1 Observation';
        superCAR1_1.No_of_Weeks__c = 1;
        superCAR1_1.Start_Date__c = system.today();
        superCAR1_1.Static_Resource_Name__c = 'CARSupercoach';
        insert superCAR1_1;
        
         
         test.startTest();
           CreateFeedbackDataBatch cPPB = new CreateFeedbackDataBatch('CAR Manager 1:1 Observation');
           database.executebatch(cPPB );
         Test.stopTest(); 
         System.schedule('Scheduled Job 1', '0 0 * * * ?', new CreateFeedbackDataBatchSchedule('CAR Manager 1:1 Observation'));
        
      
    }

    static testmethod void testCAREvent (){
         FeedbackData__c CAREvent = new FeedbackData__c();
            CAREvent.Name = 'CAR Event';
            CAREvent.Form_Name__c = 'CAR Event';
            CAREvent.No_of_Weeks__c = 1;
            CAREvent.Start_Date__c = system.today();
            CAREvent.Static_Resource_Name__c = 'CAREventObs';
            insert CAREvent;
            
              test.startTest();
               CreateFeedbackDataBatch cPPB = new CreateFeedbackDataBatch('CAR Event');
               database.executebatch(cPPB );
             Test.stopTest(); 
             System.schedule('Scheduled Job 1', '0 0 * * * ?', new CreateFeedbackDataBatchSchedule('CAR Event'));
    }

    static testmethod void testpropertyVisit (){
          FeedbackData__c propertyVisit = new FeedbackData__c();
            propertyVisit.Name = 'Property Visit';
            propertyVisit.Form_Name__c = 'Property Visit';
            propertyVisit.No_of_Weeks__c = 1;
            propertyVisit.Start_Date__c = system.today();
            propertyVisit.Static_Resource_Name__c = 'PropertyVisitObservation';
            insert propertyVisit;
              test.startTest();
               CreateFeedbackDataBatch cPPB = new CreateFeedbackDataBatch('Property Visit');
               database.executebatch(cPPB );
             Test.stopTest(); 
             System.schedule('Scheduled Job 1', '0 0 * * * ?', new CreateFeedbackDataBatchSchedule('Property Visit'));
    }

    static testmethod void testindirectObservation (){
          FeedbackData__c indirectObservation = new FeedbackData__c();
            indirectObservation.Name = 'Indirect Observation';
            indirectObservation.Form_Name__c = 'Indirect Observation';
            indirectObservation.No_of_Weeks__c = 1;
            indirectObservation.Start_Date__c = system.today();
            indirectObservation.Static_Resource_Name__c = 'indirectObservation';
            insert indirectObservation;
              test.startTest();
               CreateFeedbackDataBatch cPPB = new CreateFeedbackDataBatch('Indirect Observation');
               database.executebatch(cPPB );
             Test.stopTest(); 
             System.schedule('Scheduled Job 1', '0 0 * * * ?', new CreateFeedbackDataBatchSchedule('Indirect Observation'));
    }
    static testmethod void testCARManagerHuddle (){
            FeedbackData__c CARManagerHuddle = new FeedbackData__c();
            CARManagerHuddle.Name = 'CAR Manager Huddle Observation';
            CARManagerHuddle.Form_Name__c = 'CAR Manager Huddle Observation';
            CARManagerHuddle.No_of_Weeks__c = 1;
            CARManagerHuddle.Start_Date__c = system.today();
            CARManagerHuddle.Static_Resource_Name__c = 'CARManagerHuddle';
            insert CARManagerHuddle;
            
            
              test.startTest();
               CreateFeedbackDataBatch cPPB = new CreateFeedbackDataBatch('CAR Manager Huddle Observation');
               database.executebatch(cPPB );
             Test.stopTest(); 
             System.schedule('Scheduled Job 1', '0 0 * * * ?', new CreateFeedbackDataBatchSchedule('CAR Manager Huddle Observation'));
    }
    static testmethod void testCARManagerFieldObservation(){
        FeedbackData__c carManagerFieldObservation = new FeedbackData__c();
        carManagerFieldObservation.Name = 'Field Observation';
        carManagerFieldObservation.Form_Name__c = 'Field Observation';
        carManagerFieldObservation.No_of_Weeks__c = 1;
        carManagerFieldObservation.Start_Date__c = system.today();
        carManagerFieldObservation.Static_Resource_Name__c = 'FieldObservationCAR';
        insert carManagerFieldObservation;

        test.startTest();
            CreateFeedbackDataBatch createFeedbackDataObj = new CreateFeedbackDataBatch('Field Observation');
            database.executebatch(createFeedbackDataObj );
        test.stopTest(); 
        System.schedule('Scheduled Job 1', '0 0 * * * ?', new CreateFeedbackDataBatchSchedule('Field Observation'));
    }
}