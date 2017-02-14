/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal, Accenture
 * Date       : 17-May-2013
 * Description: This is Test class for "KnockTriggerController" class.
 * History
     Version             : 1.0
     Author Last Updated : Vivek Patel, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/

@isTest
public class KnockTriggerControllerTest{
    
    public static testMethod void testKnockTriggerController(){
       SetupTestData.createCustomSettingRecords();
        Datetime dt1= system.today(); 
        Datetime dt2=system.today().adddays(1);
        KnockTriggerController.getSecondsBetween(dt1,dt2);
        
        user currentuser = [SELECT id from user where id =:userinfo.getuserid()];
        
        System.runAs(currentuser){
        SetupTestData.createUsers();
        }
        
        Id RecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId();  
        Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
        Customer_Address__c addr = new Customer_Address__c();
        Customer_Address__c addr1 = new Customer_Address__c();
        Customer_Address__c addr2 = new Customer_Address__c();
        List<Customer_Address__c> addressList =new List<Customer_Address__c>();
        Plan__c pln = new Plan__c();
        Plan__c pln1 = new Plan__c();
        List<Task> knockList = new List<Task>();
        test.startTest();
        System.runAs(SetupTestData.supervisorUser){
            pln.Name = 'TestPlan';
            pln.Plan_Level__c = 'Turf';
            pln.Plan_Status__c = 'Draft';
            pln.No_of_No_Knock__c = 1;
            pln.No_of_No_Answer__c = 1;
            pln.No_of_Knock__c = 2;
            ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
            
            extnObj1.quickSave();
            pln1.Name = 'TestPlan1';
            pln1.Plan_Level__c = 'Turf';
            pln1.Plan_Status__c = 'Draft';
            pln1.No_of_No_Knock__c = 1;
            pln1.No_of_Knock__c = 2;
            ApexPages.StandardController controller2 = new ApexPages.StandardController(pln1);
            PlanEditExtn extnObj2 = new PlanEditExtn(controller2);
            
            extnObj2.quickSave();
            Team__c team = new Team__c();
            team.Name = 'Test Team';
            team.Region__c = 'Freedom';
            team.Supervisor__c = SetupTestData.supervisorUser.Id;
            team.All_Team_Members__c = 'New';
            insert team;
            
            List<Team_Member__c> teamMemberList=new List<Team_Member__c>();
            Team_Member__c teamMember = new Team_Member__c();
            teamMember.Team__c = team.Id;
            teamMember.User_Name__c = SetupTestData.dsrUser.Id;
            teamMemberList.add(teamMember);
            if(teamMemberList.size()>0)
            {
            insert teamMemberList;
            }
            DateTime dt = system.now();
            addr.Address__c = 'Test Address';
            addr.State__c = 'Test State';
            addr.City__c = 'Test City';
            addr.Country__c = 'Test Country';
            addr.PostalCode__c = '12345';
            addr.Node__c = '1111';
            addr.Corp__c = '11111111';
            addr.Route_Code__c = '1111111111';
            addr.Region__c = 'Freedom Market';
            addr.Division = freedomRegion.Id;
            addr.plan__c = pln.Id;
            addr.Latitude__c=41.405556;
            addr.Longitude__c=-81.664167; 
            addr.Last_Knock_Date__c =dt.addHours(-01);          
            addressList.add(addr);
           
            addr1.Address__c = 'Test Address1';
            addr1.State__c = 'Test State';
            addr1.City__c = 'Test City';
            addr1.Country__c = 'Test Country';
            addr1.PostalCode__c = '12345';
            addr1.Node__c = '1111';
            addr1.Corp__c = '11111111';
            addr1.Route_Code__c = '1111111111';
            addr1.Region__c = 'Freedom Market';
            addr1.Division = freedomRegion.Id;
            addr1.Latitude__c=41.375556;
            addr1.Longitude__c=-81.680833;
            addr1.plan__c = pln.Id;         
            
            addressList.add(addr1);
            
          /*  addr2.Address__c = 'Test Address2';
            addr2.State__c = 'Test State';
            addr2.City__c = 'Test City';
            addr2.Country__c = 'Test Country';
            addr2.PostalCode__c = '12346';
            addr2.Node__c = '1111';
            addr2.Corp__c = '11111111';
            addr2.Route_Code__c = '1111111111';
            addr2.Region__c = 'Freedom Market';
            addr2.Division = freedomRegion.Id;
            addr2.Latitude__c=42.375556;
            addr2.Longitude__c=-81.680833;
            addr2.plan__c = pln.Id;         
            
           insert addr2;*/
            
            Database.insert(addressList,true);
            pln.User__c = SetupTestData.dsrUser.Id;
            pln1.User__c = SetupTestData.dsrUser.Id;         
            extnObj1.Save();
            extnObj2.Save();
            
           
           
           }
         System.runAs(SetupTestData.dsrUser){
            // Create & insert 6 Knocks 
            
            Task knock = new Task();
            knock.RecordTypeId = RecTypeId;
            knock.WhatId = addr1.Id;
            knock.Disposition__c = 'Contact';
            knock.Knocked_Date__c = system.Now();
            knock.status = 'Completed';
            knockList.add(knock);
            
            Task knock1 = new Task();
            knock1.RecordTypeId = RecTypeId;
            knock1.WhatId = addr1.Id;
            knock1.Disposition__c = 'No Knock';
            knock1.Knocked_Date__c = system.Now();
            knock1.status = 'Completed';
            knockList.add(knock1);
            
            Task knock2 = new Task();
            knock2.RecordTypeId = RecTypeId;
            knock2.WhatId = addr1.Id;
            knock2.Disposition__c = 'Door Hanger';            
            knock2.Knocked_Date__c = system.Now();
            knock2.status = 'Completed';
            knockList.add(knock2);
            
            //Address 1 knock
            Task knock10 = new Task();
            knock10.RecordTypeId = RecTypeId;
            knock10.WhatId = addr.Id;
            knock10.Disposition__c = 'No Answer';
            knock10.Knocked_Date__c = system.Now();
            knock10.status = 'Completed';
            knockList.add(knock10);         
            
            Task knock11 = new Task();
            knock11.RecordTypeId = RecTypeId;
            knock11.WhatId = addr.Id;
            knock11.Disposition__c = 'No Knock';
            knock11.Knocked_Date__c = system.Now();
            knock11.status = 'Completed';
            knockList.add(knock11);
            
            Task knock12 = new Task();
            knock12.RecordTypeId = RecTypeId;
            knock12.WhatId = addr.Id;
            knock12.Disposition__c = 'Door Hanger';
            knock12.Knocked_Date__c = system.Now();
            knock12.status = 'Completed';
            knockList.add(knock12);
            
            Task knock14 = new Task();
            knock14.RecordTypeId = RecTypeId;
            knock14.WhatId = addr.Id;
            knock14.Disposition__c = 'Discover';
            knock14.Knocked_Date__c = system.Now();
            knock14.status = 'Completed';
            knockList.add(knock14);
            
            Task knock15 = new Task();
            knock15.RecordTypeId = RecTypeId;
            knock15.WhatId = addr.Id;
            knock15.Disposition__c = 'Position';
            knock15.Knocked_Date__c = system.Now();
            knock15.status = 'Completed';
            knockList.add(knock15);
            
            Task knock16 = new Task();
            knock16.RecordTypeId = RecTypeId;
            knock16.WhatId = addr.Id;
            knock16.Disposition__c = 'Start';
            knock16.Knocked_Date__c = system.Now();
            knock16.status = 'Completed';
            knock16.Priority='Normal';
            knock16.Dwelling_Type__c ='Vacant';
            knock16.Off_Turf__c = True;
            knock16.Sales_Type__c= 'Winback';
            knockList.add(knock16);
          
            Task knock4 = new Task();
            knock4.RecordTypeId = RecTypeId;
            knock4.WhatId = addr1.Id;
            knock4.Disposition__c = 'Discover';
            knock4.Knocked_Date__c = system.Now();
            knock4.status = 'Completed';
            knockList.add(knock4);
            
            Task knock5 = new Task();
            knock5.RecordTypeId = RecTypeId;
            knock5.WhatId = addr1.Id;
            knock5.Disposition__c = 'Position';
            knock5.Knocked_Date__c = system.Now();
            knock5.status = 'Completed';
            knock5.Off_Turf__c = True;
            knockList.add(knock5);
            
            Task knock6 = new Task();
            knock6.RecordTypeId = RecTypeId;
            knock6.WhatId = addr1.Id;
            knock6.Disposition__c = 'Start';
            knock6.Knocked_Date__c = system.Now();
            knock6.status = 'Completed';
            knock6.Priority='Normal';
            knock6.Dwelling_Type__c ='Vacant';
            knock6.Off_Turf__c = True;
            knock6.Sales_Type__c= 'Winback';
            knockList.add(knock6);
            
           
            database.insert(knockList,true);
           
       //     List<iKnock__c> iKnockList = [Select id from iKnock__c]; 
      
            }
        test.stopTest();
    }
     public static testMethod void testKnockTriggerControllerMethod3(){
        SetupTestData.createCustomSettingRecords();
        Datetime dt1= system.today(); 
        Datetime dt2=system.today().adddays(1);
        KnockTriggerController.getSecondsBetween(dt1,dt2);
        
        user currentuser = [SELECT id from user where id =:userinfo.getuserid()];
        
        System.runAs(currentuser){
        SetupTestData.createUsers();
        SetupTestData.supervisorUser.Region__c = 'Freedom Market';
        update SetupTestData.supervisorUser;
        }
        
        Id RecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId();  
        Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
        Customer_Address__c addr = new Customer_Address__c();
        Customer_Address__c addr1 = new Customer_Address__c();
        Customer_Address__c addr2 = new Customer_Address__c();
        List<Customer_Address__c> addressList =new List<Customer_Address__c>();
        Plan__c pln = new Plan__c();
        Plan__c pln1 = new Plan__c();
        Plan__c pln2 = new Plan__c();
        List<Task> knockList = new List<Task>();
        test.startTest();
        
        System.runAs(SetupTestData.supervisorUser){
            pln.Name = 'TestPlan';
            pln.Plan_Level__c = 'Turf';
            pln.Plan_Status__c = 'Draft';
            pln.No_of_No_Knock__c = null;
            pln.No_of_No_Answer__c = null;
            pln.No_of_Knock__c = null;
            ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
            
            extnObj1.quickSave();
            pln1.Name = 'TestPlan1';
            pln1.Plan_Level__c = 'Turf';
            pln1.Plan_Status__c = 'Draft';
            pln1.No_of_No_Knock__c = null;
            pln1.No_of_No_Answer__c = null;
            pln1.No_of_Knock__c = null;
            ApexPages.StandardController controller2 = new ApexPages.StandardController(pln1);
            PlanEditExtn extnObj2 = new PlanEditExtn(controller2);
            
            extnObj2.quickSave();
           
            
            List<iKnock__c> iKnockList = [Select id from iKnock__c]; 
           
            
           
            Team__c team = new Team__c();
            team.Name = 'Test Team';
            team.Region__c = 'Freedom Market';
            team.Supervisor__c = SetupTestData.supervisorUser.Id;
            team.All_Team_Members__c = 'New';
            insert team;
            List<Team_Member__c> teamMemberList=new List<Team_Member__c>();
            Team_Member__c teamMember = new Team_Member__c();
            teamMember.Team__c = team.Id;
            teamMember.User_Name__c = SetupTestData.dsrUser.Id;
            teamMemberList.add(teamMember);
            if(teamMemberList.size()>0)
            {
            insert teamMemberList;
            }
            DateTime dt = system.now();
            addr.Address__c = 'Test Address';
            addr.State__c = 'Test State';
            addr.City__c = 'Test City';
            addr.Country__c = 'Test Country';
            addr.PostalCode__c = '12345';
            addr.Node__c = '1111';
            addr.Corp__c = '11111111';
            addr.Route_Code__c = '1111111111';
            addr.Region__c = 'Freedom Market';
            addr.Division = freedomRegion.Id;
            addr.plan__c = pln.Id;
            addr.Latitude__c=41.405556;
            addr.Longitude__c=-81.664167;           
            addr.Last_Knock_Date__c =dt.addHours(-01);   
            addr.Rejected_Reason__c = 'test';
            addressList.add(addr);
           
            addr1.Address__c = 'Test Address1';
            addr1.State__c = 'Test State';
            addr1.City__c = 'Test City';
            addr1.Country__c = 'Test Country';
            addr1.PostalCode__c = '12345';
            addr1.Node__c = '1111';
            addr1.Corp__c = '11111111';
            addr1.Route_Code__c = '1111111111';
            addr1.Region__c = 'Freedom Market';
            addr1.Division = freedomRegion.Id;
            addr1.Latitude__c=41.375556;
            addr1.Longitude__c=-81.680833;
            addr1.plan__c = pln.Id;         
            
            addressList.add(addr1);
            
            Database.insert(addressList,true);
            pln.User__c = SetupTestData.dsrUser.Id;
            pln1.User__c = SetupTestData.dsrUser.Id;         
            extnObj1.Save();
            extnObj2.Save();
            
             pln2.Name = 'TestPlan2';
            pln2.Plan_Level__c = 'Playlist';
            pln2.Plan_Status__c = 'Assigned';
            pln2.No_of_No_Knock__c = 1;
            pln2.No_of_Knock__c = 2;
            pln2.No_of_Close__c = null;
            pln2.No_of_Contact__c = null;
            pln2.No_of_Discover__c = null;
            pln2.No_of_Door_Hanger__c = null;
            pln2.No_of_Engage__c = null;
            pln2.No_of_Knock__c = null;
            pln2.No_of_Start__c = null;
            pln2.No_of_Position__c = null;
            pln2.No_of_No_Answer__c = null;
            pln2.No_of_No_Knock__c = null;
            pln2.Parent_Plan__c = pln1.id;
            
             insert pln2;
           }
           
           MDU_Property__c property;
           Property_Events__c propertyEvent;
           Property_Event_Team_Member__c propertyEventTeamMember;
           
           system.runAs(new User(Id = UserInfo.getUserId())){
                property = new MDU_Property__c();
                property.Name = 'Test';
                property.Address__c = 'Test';
                property.Corporate__c = 'Comcast Cable';
                property.Property_Division__c = 'Northeast';
                property.City__c = 'Test';
                property.MDU_State__c = 'Kansas';
                property.Property_Region__c = 'Beltway Market';
                property.Coffee_Vendor_on_Site__c = 'N/A';
                property.Industry_Type__c = 'Commercial';
                property.Property_Type__c = 'Commercial';
                property.Number_of_Units__c = 3;
                property.Comcast_Video_Serviced__c = 'No';
                property.Comcast_Voice_Serviced__c = 'No';
                property.Comcast_Data_Serviced__c = 'No';
                property.Property_Area__c =     'DC Metro';
                property.System__c = 'DC';
                
                insert property;
                
                propertyEvent = new Property_Events__c();
                propertyEvent.Name = 'Test';
                propertyEvent.Start_Time__c = system.now();
                propertyEvent.Property__c = property.id;
                propertyEvent.End_Time__c = system.now();
                insert propertyEvent;
                
                propertyEventTeamMember = new Property_Event_Team_Member__c();
                propertyEventTeamMember.Name = 'First Last Name';
                propertyEventTeamMember.Team_Member__c = SetupTestData.dsrUser.id;
                propertyEventTeamMember.Property_Event__c = propertyEvent.id;
                insert propertyEventTeamMember;
            }
            
            
           
         System.runAs(SetupTestData.dsrUser){
     
            Task knock = new Task();
            knock.RecordTypeId = RecTypeId;
            knock.WhatId = addr1.Id;
            knock.Disposition__c = 'Close';
            knock.Knocked_Date__c = system.Now();
            knock.status = 'Completed';
            knock.Playlist_Id__c= pln2.id;
            knock.Disposition__c = 'Start';
            knock.XH_Sold__c = true;
            knock.Property_Event__c = propertyEvent.id;
            knockList.add(knock);
            
            database.insert(knockList,true);
            System.assertEquals(knockList[2].Playlist_Id__c,pln2.id);
            }
        test.stopTest();
    }
}