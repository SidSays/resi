@IsTest
private class KnockRecordRollUpSummaryBatchTest {

    static testMethod void knockRecordRollUpTest() {
        //SetupTestData.createCustomSettingRecords();
            List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();

            TriggerSettings__c addressTrigger = new TriggerSettings__c();
            addressTrigger.Name = 'AddressTrigger';
            addressTrigger.isActive__c = false;
            triggerSettingsList.add(addressTrigger);
        
            TriggerSettings__c planTrigger = new TriggerSettings__c();
            planTrigger.Name = 'PlanTrigger';
            planTrigger.isActive__c = false;
            triggerSettingsList.add(planTrigger);
            
            TriggerSettings__c TaskTrigger = new TriggerSettings__c();
            TaskTrigger.Name = 'TaskTrigger';
            TaskTrigger.isActive__c = False;
            triggerSettingsList.add(TaskTrigger);
            
            TriggerSettings__c UserTrigger = new TriggerSettings__c();
            UserTrigger.Name = 'UserTrigger';
            UserTrigger.isActive__c = false;
            triggerSettingsList.add(UserTrigger);
            insert triggerSettingsList;
        
        user currentuser = [SELECT id from user where id =:userinfo.getuserid()];
        
        System.runAs(currentuser){
        SetupTestData.createUsers();
       }

        Id RecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId();  
        Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
        Customer_Address__c addr = new Customer_Address__c();
        Plan__c pln = new Plan__c();
        Plan__c pln1 = new Plan__c();
        List<Task> knockList = new List<Task>();
        
        
        Test.StartTest();
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
            insert addr;
            
            pln.User__c = SetupTestData.dsrUser.Id;
            extnObj1.Save();
        }
        //list to insert the knock records.
        List<Task> taskList = new List<Task>();
        DateTime dt = system.now();
        //Create and insert Knock Records. 
         
        Task task1 = WorkTestDataUtility.CreateTask();            
        task1.Disposition__c='Non-Marketable Address';
        task1.Non_Marketable_Reason__c='Vacant home';
        task1.Dwelling_Type__c='Single Family';      
        task1.Knocked_Date__c = dt.addHours(-00);
        task1.Off_Turf__c = True;
        task1.whatid = addr.id;
        taskList.add(task1);
                
        Task task2 = WorkTestDataUtility.CreateTask();               
        task2.Disposition__c='No Answer';
        task2.Dwelling_Type__c='Bulk Billed Master';      
        task2.Knocked_Date__c = dt.addHours(-01);
        task2.Off_Turf__c = True;
        task2.whatid = addr.id;
        taskList.add(task2);
       
        Task task3 = WorkTestDataUtility.CreateTask();               
        task3.Disposition__c='Door Hanger';
        task3.Dwelling_Type__c='Commercial';      
        task3.Knocked_Date__c = dt.addHours(-02); 
        task3.Off_Turf__c = True;
        task3.whatid = addr.id;
        taskList.add(task3);
        
        Task task4 = WorkTestDataUtility.CreateTask();               
        task4.Disposition__c='Contact';
        task4.Dwelling_Type__c='Bulk Billed MDU';      
        task4.Knocked_Date__c = dt.addHours(-03);
        task4.Off_Turf__c = True; 
        task4.whatid = addr.id;
        taskList.add(task4);
        
        Task task5 = WorkTestDataUtility.CreateTask();               
        task5.Disposition__c='Engage';
        task5.Dwelling_Type__c='Non Bulk Billed MDU';      
        task5.Knocked_Date__c = dt.addHours(-04);
        task5.Off_Turf__c = True;
        task5.whatid = addr.id;        
        taskList.add(task5);
        
        Task task6 = WorkTestDataUtility.CreateTask();               
        task6.Disposition__c='Discover';
        task6.Dwelling_Type__c='Unknown';      
        task6.Knocked_Date__c = dt.addHours(-05);  
        task6.Off_Turf__c = True;
        task6.whatid = addr.id;
        taskList.add(task6);
        
        Task task7 = WorkTestDataUtility.CreateTask();               
        task7.Disposition__c='Position';
        task7.Dwelling_Type__c='Single Family Unit';      
        task7.Knocked_Date__c = dt.addHours(-06);
        task7.Off_Turf__c = True;
        task7.whatid = addr.id;
        taskList.add(task7);
        
        Task task8 = WorkTestDataUtility.CreateTask();               
        task8.Disposition__c='Close';
        task8.Dwelling_Type__c='Multiple Dwelling Unit';      
        task8.Knocked_Date__c = dt.addHours(-07);
        task8.Off_Turf__c = True; 
        task8.whatid = addr.id;
        taskList.add(task8);
        
        Task task9 = WorkTestDataUtility.CreateTask();               
        task9.Disposition__c='Start';
        task9.Dwelling_Type__c='Vacant';      
        task9.Knocked_Date__c = dt.addHours(-08);  
        task9.Off_Turf__c = True;
        task9.whatid = addr.id;        
        taskList.add(task9);
        
        Task task10 = WorkTestDataUtility.CreateTask();               
        task10.Disposition__c='Non-Marketable Address';
        task10.Non_Marketable_Reason__c='Vacant home';
        task10.Dwelling_Type__c='Non Bulk Billed';     
        task10.Knocked_Date__c = dt.addHours(-09); 
        task10.Off_Turf__c = True;
        task10.whatid = addr.id;
        taskList.add(task10);
        
        Task task11 = WorkTestDataUtility.CreateTask();               
        task11.Disposition__c='contact';
        task11.Dwelling_Type__c='SFU';      
        task11.Knocked_Date__c = dt.addHours(-10); 
        task11.Off_Turf__c = True;
        task11.whatid = addr.id;
        taskList.add(task11);
        
        Task task12 = WorkTestDataUtility.CreateTask();               
        task12.Disposition__c='No Knock';
        task12.Dwelling_Type__c='MDU';      
        task12.Knocked_Date__c = dt.addHours(-11); 
        task12.Off_Turf__c = True; 
        task12.whatid = addr.id;        
        taskList.add(task12);
        
        Task task13 = WorkTestDataUtility.CreateTask();               
        task13.Disposition__c='No Knock';
        task13.Dwelling_Type__c='OTHER';      
        task13.Knocked_Date__c = dt.addHours(-12);  
        task13.Off_Turf__c = True;
        task13.whatid = addr.id;        
        taskList.add(task13);
        
        Task task14 = WorkTestDataUtility.CreateTask();               
        task14.Disposition__c='No Knock';
        task14.Dwelling_Type__c='EXCLUDE MAPPING';      
        task14.Knocked_Date__c = dt.addHours(-13);  
        task14.Off_Turf__c = True;
        task14.whatid = addr.id;        
        taskList.add(task14);
        
        Task task15 = WorkTestDataUtility.CreateTask();               
        task15.Disposition__c='No Knock';
        task15.Dwelling_Type__c='MDU';      
        task15.Knocked_Date__c = dt.addHours(-14);
        task15.Off_Turf__c = True;
        task15.whatid = addr.id;
        taskList.add(task15);
        
        Task task16 = WorkTestDataUtility.CreateTask();               
        task16.Disposition__c='No Knock';
        task16.Dwelling_Type__c='Non Bulk Billed';      
        task16.Knocked_Date__c = dt.addHours(-15); 
        task16.Off_Turf__c = True; 
        task16.whatid = addr.id;        
        taskList.add(task16);
    
        Task task17 = WorkTestDataUtility.CreateTask();               
        task17.Disposition__c='No Knock';
        task17.Dwelling_Type__c='MDU';      
        task17.Knocked_Date__c = dt.addHours(-16); 
        task17.Off_Turf__c = True;
        task17.whatid = addr.id;
        taskList.add(task17);
     
        Task task18 = WorkTestDataUtility.CreateTask();               
        task18.Disposition__c='No Knock';
        task18.Dwelling_Type__c='MDU';      
        task18.Knocked_Date__c = dt.addHours(-17); 
        task18.Off_Turf__c = True;
        task18.whatid = addr.id;
        taskList.add(task18);
        
        Task task19 = WorkTestDataUtility.CreateTask();               
        task19.Disposition__c='No Knock';
        task19.Dwelling_Type__c='MDU';      
        task19.Knocked_Date__c = dt.addHours(-18);    
        task19.Off_Turf__c = True;
        task19.whatid = addr.id;
        taskList.add(task19);
        
        Task task20 = WorkTestDataUtility.CreateTask();               
        task20.Disposition__c='No Knock';
        task20.Dwelling_Type__c='MDU';      
        task20.Knocked_Date__c = dt.addHours(-19); 
        task20.Off_Turf__c = True;
        task20.whatid = addr.id;
        taskList.add(task20);
        
        Task task21 = WorkTestDataUtility.CreateTask();               
        task21.Disposition__c='No Knock';
        task21.Dwelling_Type__c='MDU';      
        task21.Knocked_Date__c = dt.addHours(-20);  
        task21.Off_Turf__c = True; 
        task21.whatid = addr.id;
        taskList.add(task21);
        
        Task task22 = WorkTestDataUtility.CreateTask();               
        task22.Disposition__c='No Knock';
        task22.Dwelling_Type__c='MDU';      
        task22.Knocked_Date__c = dt.addHours(-21); 
        task22.Off_Turf__c = True;
        task22.whatid = addr.id;
        taskList.add(task22);
        
        Task task23 = WorkTestDataUtility.CreateTask();               
        task23.Disposition__c='No Knock';
        task23.Dwelling_Type__c='Unknown';      
        task23.Knocked_Date__c = dt.addHours(-22);  
        task23.Off_Turf__c = True; 
        task23.whatid = addr.id;
        taskList.add(task23);
        
        Task task24 = WorkTestDataUtility.CreateTask();               
        task24.Disposition__c='No Knock';
        task24.Dwelling_Type__c='Single Family';      
        task24.Knocked_Date__c = dt.addHours(-23); 
        task24.Off_Turf__c = True; 
        task24.whatid = addr.id;        
        taskList.add(task24);
        
        //inserting the knocklist.
        
        database.insert(taskList,true);        
        
        //Executing the Batch and passing query      
        
        database.executebatch(new KnockRecordRollUpSummaryBatch('SELECT Id,createdDate, WhatId,OwnerFullName__c, OwnerId,Dwelling_Type__c,Region__c,Disposition_Latitude__c,Disposition__c,Knocked_Date__c,Location_Difference__c,Off_Turf__c,Sales_Type__c FROM Task where whatid!=null limit 50'));
        Test.StopTest();
        
    }
}