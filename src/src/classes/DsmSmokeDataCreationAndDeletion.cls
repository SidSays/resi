global class DsmSmokeDataCreationAndDeletion {
    
    //This method is used for creating users
    global static void createTestUser(Integer value, String strVal, Boolean flag) {
        
        
        try{
            UserRole XSPRole = [SELECT Id FROM UserRole WHERE DeveloperName='DSR' LIMIT 1]; 
            UserRole RSAUserRole = [SELECT Id FROM UserRole WHERE DeveloperName='Regional_Manager' LIMIT 1]; 
            UserRole SDMRole = [SELECT Id FROM UserRole WHERE DeveloperName='DS_Supervisor' LIMIT 1]; 
            UserRole BPXSPRole = [SELECT Id FROM UserRole WHERE DeveloperName='Contractor_CORE' LIMIT 1]; 
            UserRole BPSDMRole = [SELECT Id FROM UserRole WHERE DeveloperName='Contractor_CORE' LIMIT 1]; 
            
            Profile strXSP = [SELECT Id,Name FROM Profile WHERE Name=:Label.DSRProfileName LIMIT 1];
            Profile strRSA = [SELECT Id,Name FROM Profile WHERE Name=:Label.RSA_Profile_Name LIMIT 1];
            Profile strSDM= [SELECT Id,Name FROM Profile WHERE Name=:Label.DS_Supervisor LIMIT 1];
            Profile strBPXSP = [SELECT Id,Name FROM Profile WHERE Name=:Label.Contractor_Direct_Sales_Representative LIMIT 1];
            Profile strBPSDM = [SELECT Id,Name FROM Profile WHERE Name=:Label.Contractor_Direct_Sales_Supervisor LIMIT 1];
            Division objDiv = [SELECT Id FROM Division WHERE Name='Global' LIMIT 1];
            List<User>lstUser = new List<User> ();
            Set<Id> MySetVal = new Set<Id> ();
            for(Integer i=1;i<=value;i++) {
                User objUser = new User ();
                if(i==1) {
                    objUser.FirstName = 'Smoke';
                    objUser.LastName = 'Test XSP';
                    objUser.Alias = 'SMXSP1';               
                    objUser.ProfileId = strXSP.Id;    
                    objUser.PERNR__c='10254424';              
                }
                else if(i==2) {
                    objUser.FirstName = 'Smoke';
                    objUser.LastName = 'Test SDM';
                    objUser.Alias = 'SMSDM2';
                    objUser.ProfileId = strSDM.Id; 
                }
                else if(i==3) {
                    objUser.FirstName = 'Smoke';
                    objUser.LastName = 'Test RSA';
                    objUser.Alias = 'SMRSA3';
                    objUser.ProfileId = strRSA.Id; 
                }
                else if(i==4) {
                    objUser.FirstName = 'Smoke';
                    objUser.LastName = 'Test BPSDM';
                    objUser.Alias = 'SMBPSDM4';
                    objUser.ProfileId = strBPSDM.Id; 
                    objUser.Business_Partner__c = 'CORE';
                    objUser.Sales_Rep_Type__c = 'Contractor';
                }
                else if(i==5) {
                    objUser.FirstName = 'Smoke';
                    objUser.LastName = 'Test BPXSP';
                    objUser.Alias = 'SMBPXSP5'; 
                    objUser.ProfileId = strBPXSP.Id;             
                    objUser.Business_Partner__c = 'CORE';
                    objUser.Sales_Rep_Type__c = 'Contractor';                
                }
                    objUser.SmokeTestDSMEmail__c = 'SmokeTestDataInValidEmailId@emailInval.com';
                    objUser.Email = UserInfo.getUserEmail();
                    objUser.Region__c = 'Prod Test Region';
                    objUser.Username = objUser.Email + '.' + objUser.Alias + Label.EnvironmentName;
                    objUser.FederationIdentifier = objUser.Username;                             
                    objUser.CommunityNickname = UserInfo.getLastName() + i + UserInfo.getFirstName() + i;  
                    objUser.EmailEncodingKey = 'ISO-8859-1';
                    objUser.LocaleSidKey = 'en_US';
                    objUser.LanguageLocaleKey  = 'en_US'; 
                    objUser.DefaultDivision = objDiv.Id;
                    objUser.TimeZoneSidKey = 'America/New_York';
                    objUser.Terms_and_Conditions_Accepted__c = system.today();  
                    
                    lstUser.add(objUser);  
            }
            if(!lstUser.isEmpty()) {
                Database.UpsertResult[] svr = Database.Upsert(lstUser,false);               
            }
            
            
            List<User>lsthirerachy = new List<User> ();
            //For Creating user hierarchies
            String strSMXSP = UserInfo.getUserEmail() + '.SMXSP1' + Label.EnvironmentName;
            String strSMSDM = UserInfo.getUserEmail()+ '.SMSDM2' + Label.EnvironmentName;
            String strSMRSA = UserInfo.getUserEmail() + '.SMRSA3' + Label.EnvironmentName;
            String strSMBPSDM = UserInfo.getUserEmail() + '.SMBPSDM4' + Label.EnvironmentName;
            String strSMBPXSP = UserInfo.getUserEmail() + '.SMBPXSP5' + Label.EnvironmentName;
            User itrSMRSA = [SELECT Id, UserRoleId FROM User WHERE UserName=:strSMRSA LIMIT 1];
            itrSMRSA.UserRoleId = RSAUserRole.Id; 
             
            lsthirerachy.add(itrSMRSA);      
            //Updating SDM manager to RSA
            User itrSMSDM = [SELECT Id,UserRoleId FROM User WHERE UserName=:strSMSDM LIMIT 1];
            itrSMSDM.ManagerId = itrSMRSA.Id;
            itrSMSDM.UserRoleId = SDMRole.Id;
            lsthirerachy.add(itrSMSDM);
            
            //Updating XSP manager to SDM
            User itrUserSMXSP = [SELECT Id,ManagerId,UserRoleId FROM User WHERE UserName=:strSMXSP LIMIT 1];
            itrUserSMXSP.ManagerId = itrSMSDM.Id;
            itrUserSMXSP.UserRoleId = XSPRole.Id;
            lsthirerachy.add(itrUserSMXSP);
            
            //Updating BPSDM manager to RSA
            User itrSMBPSDM = [SELECT Id,ManagerId,UserRoleId FROM User WHERE UserName=:strSMBPSDM LIMIT 1];
            itrSMBPSDM.ManagerId = itrSMRSA.Id;
            itrSMBPSDM.UserRoleId = BPSDMRole.Id;
            lsthirerachy.add(itrSMBPSDM);
            
            //Updating BPXSP manager to BPSDM
            User itrUserSMBPXSP = [SELECT Id,ManagerId,UserRoleId FROM User WHERE UserName=:strSMBPXSP LIMIT 1];
            itrUserSMBPXSP.ManagerId = itrSMBPSDM.Id;
            itrUserSMBPXSP.UserRoleId = BPXSPRole.Id;
            lsthirerachy.add(itrUserSMBPXSP);
                    
            Database.update (lsthirerachy,false); 
                       
            
            Group objGrp = [SELECT Id FROM Group WHERE DeveloperName='Prod_Test_Region' LIMIT 1];
            List<GroupMember>listGroupMember =new List<GroupMember>();  
            List<User>lstUsrActDct =new List<User>();  
            for(User itrUser : [SELECT Id,isActive,ManagerId FROM User WHERE Name like : strVal + '%' AND Email = :UserInfo.getUserEmail() LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                itrUser.isActive = flag;
                lstUsrActDct.add(itrUser);
                GroupMember gm= new GroupMember(); 
                gm.GroupId= objGrp.Id;
                gm.UserOrGroupId = itrUser.Id;
                listGroupMember.add(gm);         
            } 
            if(!lstUsrActDct.isEmpty()) { 
                Database.update(lstUsrActDct,false);
            }
            if(!listGroupMember.isEmpty()) { 
                Database.insert(listGroupMember,false);
            }
        }catch(Exception e){
            System.debug('Error******'+e);
        }
    }
    //This method is used for creating Account,Address, Turf Plan
    global static void createTestAccAddr(Integer value) {
        
        try{        
            String strUserName = UserInfo.getName();
            String strSMXSP = UserInfo.getUserEmail() + '.SMXSP1' + Label.EnvironmentName;
            String strSMRSA =  UserInfo.getUserEmail() + '.SMRSA3' + Label.EnvironmentName;
            User itrUserSMXSP = [SELECT Id FROM User WHERE UserName=:strSMXSP LIMIT 1];
            User itrSMRSA = [SELECT Id FROM User WHERE UserName=:strSMRSA LIMIT 1];
            Plan__c objPlan = new Plan__c ();
            objPlan.Name = strUserName +'Smoke Test Plan';
            objPlan.Plan_Level__c = 'Turf';
            objPlan.User__c = itrUserSMXSP.Id;
            objPlan.OwnerId=itrSMRSA.Id;
            objPlan.Assigned_Date__c = System.Today();
            objPlan.Expiration_Date__c = System.Today() + 15;
            objPlan.Plan_Status__c = 'Assigned';
            Database.Insert(objPlan,false);           
            
            
            List<Customer_Address__c>lstAddress = new List<Customer_Address__c> ();
            List<Account>lstAcc = new List<Account> ();
            for(integer i=1;i<=value;i++) {
                Account objAcc = new Account ();
                objAcc.Name = strUserName + 'SmokeTestAccount' + ' '+ i;
                objAcc.Region__c = 'Prod Test Region';
                objAcc.Billing_Account_Number__c = '123456789654321' + i;
                lstAcc.add(objAcc);
            }
            Database.insert(lstAcc,false);          
            
            Map<String, Customer_Address__c> accIdAddMap = new Map<String, Customer_Address__c>();
            Integer i=1;
            for(Account itrAcc : lstAcc) {
                 Customer_Address__c objAddress = new Customer_Address__c ();  
                 objAddress.Name = strUserName + 'SmokeTestAddress' + ' ' + i;
                 objAddress.Account__c = itrAcc.Id;
                 objAddress.Plan__c = objPlan.Id;
                 objAddress.Region__c = 'Prod Test Region';
                 
                 objAddress.PostalCode__c = '12345';
                 objAddress.Node__c = 'N0VD';
                 objAddress.Address__c = 'RR 09';
                 objAddress.Address_2__c = 'BOX 224';
                 objAddress.PostalCode_4__c = '32303-3000';
                 objAddress.City__c = 'TALLAHASSEE';
                 objAddress.State__c = 'FL';
                 objAddress.Latitude__c = 30.5366;
                 objAddress.Longitude__c = -84.3649;
                 objAddress.ownerId = itrUserSMXSP.Id;
                 
                 i++;
                 accIdAddMap.put(itrAcc.Id,objAddress);
                 lstAddress.add(objAddress);   
            }
            Database.insert(lstAddress,false); 
            
            List<Account> lstAccToUpdate = new List<Account>();
            for(Account itrAcc : lstAcc){
                if(!accIdAddMap.isEmpty() && accIdAddMap.containsKey(itrAcc.Id)){
                    itrAcc.Service_Address__c = accIdAddMap.get(itrAcc.Id).Id;
                    lstAccToUpdate.add(itrAcc);
                }
            }

            Database.update(lstAccToUpdate,false); 
            
            
            
            Integer noAddress = 0;
            List<Plan__c>lstPlanAddUp = new List<Plan__c> ();
            for(Plan__c itrPlan : [SELECT True_count_of_Addresses__c,Number_of_Addresses_Currently_on_Plan__c,(SELECT Id FROM Customer_Addresses__r where Id=:lstAddress) 
                                  FROM Plan__c WHERE Id=:objPlan.Id]) {                      
                for(Customer_Address__c itrAdd : itrPlan.Customer_Addresses__r) {
                    noAddress++;    
                }
                itrPlan.True_count_of_Addresses__c = noAddress; 
                itrPlan.Number_of_Addresses_Currently_on_Plan__c = noAddress;
                lstPlanAddUp.add(itrPlan);   
            }
            Database.update(lstPlanAddUp);    
        }catch(Exception e){
            System.debug('Error******'+e);
        }   
    }
    
    global static void createBPAccAddr(Integer value) {
        
        try{
            String strUserName = UserInfo.getName();
            String strSMRSA = UserInfo.getUserEmail() + '.SMRSA3' + Label.EnvironmentName;
            String strSMBPSDM = UserInfo.getUserEmail() + '.SMBPSDM4' + Label.EnvironmentName;
            String strSMBPXSP = UserInfo.getUserEmail() + '.SMBPXSP5' + Label.EnvironmentName;
            String strSMXSP = UserInfo.getUserEmail() + '.SMXSP1' + Label.EnvironmentName;
            User itrSMRSA = [SELECT Id FROM User WHERE UserName=:strSMRSA LIMIT 1];
            User itrSMBPSDM = [SELECT Id FROM User WHERE UserName=:strSMBPSDM LIMIT 1];
            User itrSMBPXSP = [SELECT Id FROM User WHERE UserName=:strSMBPXSP LIMIT 1];
            List<Plan__c>lstPlan = new List<Plan__c> ();
            //Smoke test Bulk Plan
            Plan__c objPlan = new Plan__c ();
            objPlan.Name = strUserName + 'Smoke Test Bulk Plan';
            objPlan.Plan_Level__c = 'Bulk';
            objPlan.Assigned_Date__c = Date.valueOf(system.now());
            objPlan.Expiration_Date__c = System.Today() + 15;
            objPlan.User__c = itrSMBPSDM.Id;
            objPlan.Plan_Status__c = 'Assigned';
            objPlan.OwnerId=itrSMRSA.Id;
            objPlan.BulkPlanStatus__c = 'Completed';
            Database.Insert(objPlan,false);
           
           
            //Smoke test turf plan for SMBPSDM & SMXSP        
            Plan__c objPlan1 = new Plan__c ();
            objPlan1.Name = strUserName + 'Smoke Test Turf Plan';
            objPlan1.Plan_Level__c = 'Turf';
            objPlan1.User__c = itrSMBPXSP.Id;
            objPlan1.OwnerId= itrSMBPSDM.Id;
            objPlan1.Parent_Plan__c = objPlan.Id;
            objPlan1.Assigned_Date__c = Date.valueOf(system.now());
            objPlan1.Expiration_Date__c = System.Today() + 15;
            objPlan1.Plan_Status__c = 'Assigned';
            Database.Insert(objPlan1,false);  
            
            List<Customer_Address__c>lstAddress = new List<Customer_Address__c> ();
            List<Account>lstAcc = new List<Account> ();
            
            for(integer i=1;i<=value;i++) {
                Account objAcc = new Account ();
                objAcc.Name = strUserName + 'SmokeTestBulkAccount' + ' '+ i;
                objAcc.Region__c = 'Prod Test Region';
                objAcc.Billing_Account_Number__c = '123456789123456' + i;
                
                
                lstAcc.add(objAcc);
            }
            Database.insert(lstAcc,false);
            
            Map<String, Customer_Address__c> accIdAddMap = new Map<String, Customer_Address__c>();
            Integer i=1;
            for(Account itrAcc : lstAcc) {
                 Customer_Address__c objAddress = new Customer_Address__c ();  
                 objAddress.Name = strUserName + 'SmokeTestBulkAddress' + ' ' + i;  
                 objAddress.Account__c = itrAcc.Id; 
                 
                 if(Math.mod(i,2) == 0){
                    objAddress.Plan__c = objPlan.Id;
                    objAddress.ownerId = itrSMBPSDM.Id;
                 }else{
                    objAddress.Plan__c = objPlan1.Id;
                    objAddress.ownerId = itrSMBPXSP.Id;
                 }
                 objAddress.Region__c = 'Prod Test Region';
                 objAddress.PostalCode__c = '12345';
                 objAddress.Node__c = 'N0VD';
                 objAddress.Address__c = 'RR 09';
                 objAddress.Address_2__c = 'BOX 224';
                 objAddress.PostalCode_4__c = '32303-3000';
                 objAddress.City__c = 'TALLAHASSEE';
                 objAddress.State__c = 'FL';
                 objAddress.Latitude__c = 30.5366;
                 objAddress.Longitude__c = -84.3649;
                 i++;
                 accIdAddMap.put(itrAcc.Id,objAddress);
                 lstAddress.add(objAddress); 
                
            }
            Database.insert(lstAddress,false); 
            
            List<Account> lstAccToUpdate = new List<Account>();
            for(Account itrAcc : lstAcc){
                if(!accIdAddMap.isEmpty() && accIdAddMap.containsKey(itrAcc.Id)){
                    itrAcc.Service_Address__c = accIdAddMap.get(itrAcc.Id).Id;
                    lstAccToUpdate.add(itrAcc);
                }
            }
            
            Database.update(lstAccToUpdate,false); 
            
            
            List<Plan__c>lstPlanAddUp = new List<Plan__c> ();
            for(Plan__c itrPlan : [SELECT True_count_of_Addresses__c,Number_of_Addresses_Currently_on_Plan__c,(SELECT Id FROM Customer_Addresses__r where Id=:lstAddress) 
                                  FROM Plan__c WHERE (Id=:objPlan.Id OR Id=:objPlan1.Id)]) { 
                Integer noAddress = 0;            
                for(Customer_Address__c itrAdd : itrPlan.Customer_Addresses__r) {
                    noAddress++;    
                }
                itrPlan.True_count_of_Addresses__c = noAddress; 
                itrPlan.Number_of_Addresses_Currently_on_Plan__c = noAddress;
                lstPlanAddUp.add(itrPlan);   
            }
            Database.update(lstPlanAddUp);
        }catch(Exception e){
            System.debug('Error******'+e);
        }
        
    }
    
    //This method for delete Account & Addresses
    global static void DelAccAddIsActUser(String strVal) {
        
        try{
            List<Account>lstAccDel = new List<Account> ();
            List<Plan__c>lstPlanDel = new List<Plan__c> ();
            List<Plan__c>lstPlanUp = new List<Plan__c> ();
            List<Customer_Address__c>lstAddDel = new List<Customer_Address__c> ();
            List<DSM_Filter__c> lstFilterDel = new List<DSM_Filter__c> ();
            List<Task> lstTaskDel = new List<Task>();
            List<Event> lstEventDel = new List<Event>();
            List<Contact> lstContactDel = new List<Contact>();
            List<Case> lstCaseDel = new List<Case>();
            List<Note> lstNoteDel = new List<Note>();
            List<Attachment> lstAttachmentsDel = new List<Attachment>();
            List<NoteAndAttachment> lstNoteAndAttachmentDel = new List<NoteAndAttachment>();
            List<User>lstUsrUpd = new List<User> ();
            Set<String> addIdSet = new Set<String>();
            
            for(Account itrAcc : [SELECT Id FROM Account WHERE Name like : strVal + '%' AND CreatedBy.Email =: UserInfo.getUserEmail()]) {
                lstAccDel.add(itrAcc);    
            }

            
            for(Task taskObj : [SELECT Id FROM Task WHERE CreatedBy.SmokeTestDSMEmail__c = 'SmokeTestDataInValidEmailId@emailInval.com']){
                lstTaskDel.add(taskObj);
            }
            
            for(Event evntObj : [SELECT Id FROM Event WHERE CreatedBy.SmokeTestDSMEmail__c = 'SmokeTestDataInValidEmailId@emailInval.com']){
                lstEventDel.add(evntObj);
            }
            
            /*for(Contact contentObj : [SELECT Id FROM Contact WHERE CreatedBy.SmokeTestDSMEmail__c = 'SmokeTestDataInValidEmailId@emailInval.com']){
                lstContactDel.add(contentObj);
            }*/
            
            for(Case caseObj : [SELECT Id FROM Case WHERE CreatedBy.SmokeTestDSMEmail__c = 'SmokeTestDataInValidEmailId@emailInval.com']){
                lstCaseDel.add(caseObj);
            }
            
            for(Note noteObj : [SELECT Id FROM Note WHERE CreatedBy.SmokeTestDSMEmail__c = 'SmokeTestDataInValidEmailId@emailInval.com']){
                lstNoteDel.add(noteObj);
            }
            
          
            for(DSM_Filter__c dsmFilterObj : [SELECT Id FROM DSM_Filter__c WHERE CreatedBy.SmokeTestDSMEmail__c = 'SmokeTestDataInValidEmailId@emailInval.com']){
                lstFilterDel.add(dsmFilterObj);
            }
           
            for(Customer_Address__c itrAdd : [SELECT Id FROM Customer_Address__c WHERE Name like : strVal + '%' AND CreatedBy.Email =: UserInfo.getUserEmail() LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                lstAddDel.add(itrAdd); 
                addIdSet.add(itrAdd.Id);
            } 
            for(Plan__c itrPlan : [SELECT Id,Plan_Level__c,Parent_Plan__c FROM Plan__c WHERE Name like : strVal + '%' AND CreatedBy.Email =: UserInfo.getUserEmail() LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                if(itrPlan.Plan_Level__c.equals('Bulk')) {
                   itrPlan.Plan_Level__c = 'Test';
                   itrPlan.Parent_Plan__c = null;
                   lstPlanUp.add(itrPlan); 
                }
                lstPlanDel.add(itrPlan);        
            }
            
            for(Attachment attachmentObj : [SELECT Id FROM Attachment WHERE ParentId IN: addIdSet]){
                lstAttachmentsDel.add(attachmentObj);
            }
            

            if(!lstAccDel.isEmpty()) {
                Database.Delete(lstAccDel);
            }
            if(!lstAddDel.isEmpty()) {
                Database.Delete(lstAddDel);
            }
            if(!lstPlanUp.isEmpty()) {
                Database.update(lstPlanUp);
            }
            if(!lstPlanDel.isEmpty()) {
                Database.Delete(lstPlanDel);
            }
            
            
            
            if(!lstTaskDel.isEmpty()){
                Database.Delete(lstTaskDel,false);
            }
            
            /*if(!lstContactDel.isEmpty()){
                Database.Delete(lstContactDel,false);
            }*/
            
            if(!lstCaseDel.isEmpty()){
                Database.Delete(lstCaseDel,false);
            }
            
            if(!lstNoteDel.isEmpty()){
                Database.Delete(lstNoteDel,false);
            }
            
            if(!lstAttachmentsDel.isEmpty()){
                Database.Delete(lstAttachmentsDel,false);
            }
     
            if(!lstFilterDel.isEmpty()){
                Database.Delete(lstFilterDel,false);
            }
        }catch(Exception e){
            System.debug('Error******'+e);
        }   
    }
  
}