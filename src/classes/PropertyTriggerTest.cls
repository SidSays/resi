/***************************************************************************************************************************************
 * Author     : Abhishek, Accenture
 * Date       : 2-February-2015
 * Description: This is Test class for "PropertyTrigger" trigger
 * History
     Version             : 1.0
     Author Last Updated : Abhishek, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
/***************************************************************************************************************************************
 * Author     : Abhishek, Accenture
 * Date       : 2-February-2015
 * Description: This is Test class for "PropertyTrigger" trigger
 * History
     Version             : 1.0
     Author Last Updated : Abhishek, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class PropertyTriggerTest {
    private static final string LABEL_NAME_SPLIT = ';';
    /*
    * Call to create test data
    */
    public static MDU_Property__c createTestPropertyData(){
        TestDataUtility.createCustomSettingRecords();
        String labelName = System.Label.XfinityPropertyRecordType;  
        List<String> recordTypeSet = new List<String>();
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(LABEL_NAME_SPLIT)){
                recordTypeSet.add(Schema.SObjectType.MDU_Property__c.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }    
        MDU_Property__c  testProperty = TestDataUtility.createProperty();
        testProperty.recordTypeId = recordTypeSet[0];
        return testProperty;
    }

    /*
    * Call to test Status Update
    */
    private static testMethod void testStatusUpdate(){
        MDU_Property__c testProperty = createTestPropertyData();
        Database.insert(testProperty);
        
        string labelName = System.Label.XfinityContractRecordType; 
        List<String> recordTypeIds = new List<String>();              
        if(!string.isBlank(labelName)){
            for(String str: labelName.split(LABEL_NAME_SPLIT)){
                recordTypeIds.add(Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get(str).getRecordTypeId());                
            }
        }  
    
        Contract__c  testContract = TestDataUtility.createContract(testProperty.Id);
        testContract.recordTypeId = recordTypeIds[0];
        testContract.Data__c = 'Yes';
        testContract.Voice__c = 'Yes';
        testContract.Video__c = 'Yes';
        testContract.Data_Billing_Type__c = 'Retail';
        testContract.Voice_Billing_Type__c = 'Retail';
        testContract.Video_Billing_Type__c = 'Retail';
        testProperty.Number_of_Units__c = 5;
        Database.insert(testContract);
        
        List<Contract__c> initContract = [Select Id, Data_Units__c, Voice_Units__c, Property__c, Video_Units__c from Contract__c where Property__c=:testProperty.Id];
        
        Test.startTest();
            testProperty.Number_of_Units__c = 10;
            Database.update(testProperty);
            List<Contract__c> updatedContract = [Select Id, Data_Units__c, Voice_Units__c, Property__c, Video_Units__c from Contract__c where Property__c=:testProperty.Id];

            system.assertEquals(10,updatedContract[0].Data_Units__c);
            system.assertEquals(10,updatedContract[0].Voice_Units__c);
            system.assertEquals(10,updatedContract[0].Video_Units__c);
        Test.stopTest();   
               
    }
    
    /*
    * Call for DeleteNegativeCheck
    */
    private static testMethod void testDeleteNegativeCheck(){
         
         TestDataUtility.createCustomSettingRecords();
         User u = TestDataUtility.createXCIntegrationUser();
         
         System.runAs(u){
          
            
            MDU_Property__c testProperty = createTestPropertyData();
            Database.insert(testProperty);
            
            List<Id> recordTypeIdSet = new List<Id>();
            String labelName = System.Label.XfinityOpportunityRecordType; //Get DMDU Record Type
            if(!string.IsBlank(labelName)){
                for(String str: labelName.split(LABEL_NAME_SPLIT)){
                    recordTypeIdSet.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(str).getRecordTypeId());
                }
            }else{}   
            
            List<Opportunity> testOpportunity = TestDataUtility.createOpportunity(1);
            testOpportunity[0].recordTypeId = recordTypeIdSet[0];
            Database.insert(testOpportunity[0]);
            
            
            Opportunity_Property__c oppProp = new Opportunity_Property__c();
            oppProp.Property__c = testProperty.Id;
            oppProp.Opportunity__c = testOpportunity[0].Id;
            Database.insert(oppProp);
            
            
            New_Build__c  testBuild = TestDataUtility.createNewBuild();
            testBuild.Property__c = testProperty.Id;
            testBuild.Status__c = 'Active';
            Database.insert(testBuild);
            
            Test.startTest();
            try{
                delete testProperty;
            }catch(Exception e){
                Boolean exp =  e.getMessage().contains('Property cannot be deleted because-Delete Reason is not selected.Open Opportunity exists.Active New Build exists.') ? true : false;
                system.assertEquals(exp,true);
            }
            Test.stopTest();
         }
           
    }
    
         
    /*
    * Call for Delete Positive Check
    */
    private static testMethod void testDeletePositiveCheck(){
       
        
        MDU_Property__c testProperty = createTestPropertyData();   
        if(!Mdu_Property__c.Complex_ID__c.getDescribe().isAutoNumber()){
                testProperty.put('Complex_ID__c', '12111250044');
        }
        Database.insert(testProperty);            
        //set Property complex Id
        MDU_Property__c[] propetyList =(List<MDU_Property__c>) [Select Id, Complex_ID__c FROM MDU_Property__c where Id=:testProperty.Id];            
        String propetyComplexId = propetyList[0].Complex_ID__c;                      
            
        New_Build__c  testBuild = TestDataUtility.createNewBuild();
        testBuild.Property__c = testProperty.Id;
        testBuild.Status__c = 'Complete';
        Database.insert(testBuild);
        
        testProperty.Delete_Reason__c = 'Reason for Delete';
        Database.update (testProperty);
        
        Test.startTest();
        
        database.delete (testProperty);       
        List<Deleted_Property__c> delPropLog =[Select Property_Deleted_ID__c,Delete_Reason__c from Deleted_Property__c where Property_Deleted_ID__c=: propetyComplexId];
        system.assertEquals('Reason for Delete',delPropLog[0].Delete_Reason__c);       
        
        Test.stopTest();
       
    }
    
    /*
     * Description: Profile completeness calculation logic test method.
     */
    static testMethod void profileCompleteness() {  
        TestDataUtility.createCustomSettingRecords();

        MDU_Property__c prop = new MDU_Property__c();
       
        GoalTemplateDates__c  gt = new GoalTemplateDates__c();
        gt.Name = 'Default';
        gt.Current_Period_Due_Date__c = Date.newinstance(2016, 4, 21);
        gt.Current_Period_Start_Date__c = Date.newinstance(2016, 3, 22);
        insert gt;

        string labelName = System.Label.XfinityPropertyRecordType; 
        List<String> recordTypeIds = new List<String>();              
        if(!string.isBlank(labelName)){
            for(String str: labelName.split(LABEL_NAME_SPLIT)){
                recordTypeIds.add(Schema.SObjectType.MDU_Property__c.getRecordTypeInfosByName().get(str).getRecordTypeId());                
            }
        }  
        //Marketing
        prop.recordTypeId = recordTypeIds[0];
        
        prop.Full_Property_Name__c='Test';
        prop.Property_Management_Contact_name__c='Test';
        prop.Website__c ='www.test.com';
        prop.Main_property_phone_number__c ='1234567890';
        prop.Is_there_an_onsite_daily_contact_for_the__c= 'Yes'; 
        prop.How_does_the_property_communicate__c = 'Email'; 
        prop.How_are_residents_billed_for_rent__c = 'Electronic'; 
        prop.Marketing_Wiring_Rights_Violation__c = 'Yes';
        prop.Select_the_type_of_violation__c = 'Wiring';
        prop.If_electronic_do_they_have_to_login__c= 'Yes'; 
        prop.Is_online_execution_of_lease_supported__c='Yes';
        prop.of_residents_executing_leases_online__c='0-10%';
        prop.Property_allow_sponsored_resident_event__c= 'Yes'; 
        prop.What_type_of_event__c= 'Movie Night'; 
        prop.Other_Event_Types__c= 'Test Event'; 
        prop.Can_you_door_knock_at_this_property__c= 'Anytime'; 
        prop.Estimated_International_Resident__c = 34; 
        prop.If_above_25_what_is_origin_country__c= 'Brazil'; 
        prop.Language_spoken_most_often_by_tenants__c= 'Spanish'; 
        prop.Need_interest_in_International__c= 'Yes'; 
        prop.do_they_watch_on_traditional_TV_or_onlin__c= 'Online'; 
        prop.What_is_average_age_of_tenants__c= '18 to 28'; 
        prop.Lifestyle_alternative_for_the_property__c = 'Affordable Housing';
        prop.What_of_residents_are_students__c= 44; 
        prop.What_of_residents_have_small_children__c= 33; 
        prop.Does_property_have_coffee_vendor_onsite__c= 'Yes'; 
        prop.Rewards_Incentive_Programs_enrolled__c= 'Verizon Rewards';
        prop.Other_Reward_Description__c= 'Test Description'; 
        prop.Other_Communication__c = 'ttt';
        prop.Other_Event_Types__c = 'event';

        
        // Merchandising
        prop.Are_there_TV_s_in_public_view__c='Yes';
        prop.Does_property_have_ability_to_display_Xf__c='Yes';
        prop.Nbr_of_Large_Standees__c='1';
        prop.Nbr_of_Counter_Standees__c='2';
        prop.Nbr_of_Posters__c='1';
        prop.Nbr_of_Brochures_Sales_Flyers__c='1';
        prop.How_many_Xfinity_Clings__c='5';
        prop.Is_competitor_merchandising_visible__c='Yes';
        prop.Who_is_the_Competitor__c='Dish';
        prop.Other_Competitor__c='Test';
        prop.what_is_competitor_merchandising__c='TV only';
        prop.Is_the_service_included_in_a_Courtesy_Ac__c='Yes';
        prop.Select_quantity_of_Televisions__c='2';

        // Product

        prop.When_was_property_built__c='1970';
        prop.What_type_of_wiring_is_run_to_the_units__c='Ehernet';
        prop.What_type_of_Ethernet__c='CAT3';
        prop.What_type_of_wiring_is_within_the_units__c='Fiber';
        prop.Select_the_quantity_of_the_home_wiring__c='2';
        prop.Is_there_conduit_available_to_each_unit__c='Yes';
        prop.Current_vacancy_rate_of_property__c='6 to 10%';
        prop.Does_property_have_common_area_WiFi__c='Yes';
        prop.Who_provides__c='Comcast';
        prop.Other_Wifi_provider__c='Test';
        prop.Buildings__c=2;
        prop.Number_of_Units__c=4;
        prop.How_many_corporate_housing_units__c=4;
        prop.How_many_floors_per_building__c=5;
        prop.Estimated_average_unit_size_sq_ft__c=700;
        prop.Does_Property_have_a_Pool__c='Yes';
        prop.Are_security_products_currently_offered__c='Yes';
        prop.If_so_by_which_providers__c='ADT';
        prop.Amenable_to_Xfinity_Home_product_sales__c='Yes';
        prop.Which_monitored_service__c='Cameras';
        prop.What_other_providers_offer_services__c='Dish';
        prop.Is_property_bulk_or_retail__c='Bulk';
        prop.If_bulk_what_LOBs__c='Video';
        prop.Which_system_does_the_property_manager__c='Yardi';
        prop.Which_system_does_the_property_manager__c='other';
        prop.Other_System__c = 'tset';
        prop.Competitor_2__c='AT&T Digital Life';
        prop.Competitor_3__c='AT&T Digital Life';
        prop.Competitor_4__c='Other';
        prop.Billing_Method1__c='Bulk Billed';
        prop.Billing_Method2__c='Bulk Billed';
        prop.Billing_Method3__c='Individual Billed';
        prop.Billing_Method4__c='Individual Billed';
        prop.Are_other_telecom_services_provided__c='Yes';
        prop.Is_the_competitor_bulk_or_retail1__c='Bulk';
        prop.What_line_of_business_is_bulk1__c='Video only';
        prop.Provider_2__c='AT&T';
        prop.Is_the_competitor_bulk_or_retail2__c='Bulk';
        prop.What_line_of_business_is_bulk2__c='Video & Internet';
        prop.Provider_3__c='Other';
        prop.Is_the_competitor_bulk_or_retail3__c='Retail';
        prop.Free_Text3__c='microsoft';
        prop.Provider_4__c='Other';
        prop.Is_the_competitor_bulk_or_retail4__c='Retail';
        prop.Free_Text4__c='microsoft';
        prop.MDU_State__c = 'Pune';
        prop.System__c = 'Test';
        database.insert(prop,true);
        
     
        prop.How_does_the_property_communicate__c = 'Other';
        prop.Other_Communication__c = 'ABCD';
        prop.How_are_residents_billed_for_rent__c = 'Paper';
        prop.Other_Reward_Description__c = '';
        prop.Other_Event_Types__c= 'abcd'; 
        prop.Estimated_International_Resident__c = 20;
        prop.Is_property_bulk_or_retail__c = 'Retail';
        prop.What_type_of_event__c = 'Other';
        prop.Which_system_does_the_property_manager__c='Other';
        prop.Other_System__c='abcd';
        prop.Who_provides__c='Other';
        prop.Other_Wifi_provider__c = 'abcd';
        database.update(prop,true); 
        
        //Create Goals and Metrics
        
        List<Goal> goalList = new List<Goal>();
        List<Metric> metricList= new List<Metric>();
        
        TestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.createCustomSettingRecords();
        
        String goalPropertyLabRecordType = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(System.Label.PL_MonthlyGoalCreationBatchGolTempType).getRecordTypeId();   
       
        GoalTemplateDates__c templateDates = new GoalTemplateDates__c();
        templateDates.Current_Period_Start_Date__c = System.today().adddays(-3);
        templateDates.Current_Period_Due_Date__c = System.today().adddays(3);
        templateDates.Name = 'Property Lab CAR';
        Database.insert(templateDates,false);
        
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        
        User carUser = TestDataUtility.createXfinityCARUser();
        User carMgr = TestDataUtility.createXfinityCARManagerUser();
    
        
        System.runAs(user){       
            AssignPermissionSet('Coach_Goal_Metric_Edit',carUser.Id);
            AssignPermissionSet('Coach_Goal_Metric_Edit',carMgr.Id);
            
            carMgr.UserPermissionsWorkDotComUserFeature = true;
            carMgr.Terms_and_Conditions_Accepted__c = System.today();
            update carMgr;
      
            carUser.UserPermissionsWorkDotComUserFeature = true;
            carUser.Terms_and_Conditions_Accepted__c = System.today();
            carUser.ManagerId = carMgr.Id;
            update carUser ;
            
            MDU_Property__Share propShare = new MDU_Property__Share();
            propShare.AccessLevel = 'Edit';
            propShare.UserOrGroupId = carUser.Id;
            propShare.RowCause = 'Manual';
            propShare.ParentId = prop.Id;
           
            //Goal for CAR
            Goal carGoal = new Goal(); 
            carGoal.Name='CAR TEST GOAL';
            carGoal.StartDate = System.today().adddays(-3);
            carGoal.DueDate = System.today().adddays(3);
            carGoal.Status = 'Published';
            carGoal.Template_Type__c = 'Property Lab';       
            carGoal.OwnerId = carUser.Id;        
            carGoal.RecordTypeId = goalPropertyLabRecordType;
            goalList.add(carGoal);
            //Goal for CAR Manager
            Goal carMgrGoal = new Goal(); 
            carMgrGoal.Name ='CAR Mgr TEST GOAL';
            carMgrGoal.StartDate = System.today().adddays(-3);
            carMgrGoal.DueDate = System.today().adddays(3);
            carMgrGoal.Status = 'Published';
            carMgrGoal.Template_Type__c = 'Property Lab';       
            carMgrGoal.OwnerId = carMgr.Id;        
            carMgrGoal.RecordTypeId = goalPropertyLabRecordType;
            goalList.add(carMgrGoal);
            
            insert goalList;
            
            //"Profile completion%" metric For CAR
            Metric carMetric = New Metric();        
            carMetric.Name = 'Profile completion%';
            carMetric.OwnerId = carUser.Id ;
            carMetric.Status = 'NotStarted';                  
            carMetric.TargetValue = 80;
            carMetric.goalId = carGoal.Id;
            metricList.add(carMetric);
            
            
            //"Profile completion%" metric For CAR Manager
            Metric carMgrMetric = New Metric();        
            carMgrMetric.Name = 'Profile completion%';
            carMgrMetric.OwnerId = carMgr.Id ;
            carMgrMetric.Status = 'NotStarted';                  
            carMgrMetric.TargetValue = 80;
            carMgrMetric.goalId = carMgrGoal.Id;
            metricList.add(carMgrMetric);
           
            Test.starttest();
            insert metricList;          
            
        }
        
        
            prop.Assigned_CAR__c = carUser.Id;          
            database.update(prop,true);     
            Test.stoptest();
        
    }
    
    /*
     *  This method set permission set to user base on permissionSetName
     */ 
       public static void AssignPermissionSet(String permissionSetName, Id userId){
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa);
        
       }
}