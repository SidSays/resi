@isTest
public class CoachingSharingHelperTest{
  static testMethod void coachingShare() {
       
        
        WorkTestDataUtility.createCustomSettingRecords();

        //  DSR - Manager
            User userObj6 = WorkTestDataUtility.createDSManagerUserForCoaching();
            insert userObj6;
            
        //  DSR - Manager
            User userObj5 = WorkTestDataUtility.createDSManagerUserForCoaching();
            userObj5.ManagerId = userObj6.id;
            insert userObj5;            

        //  DSR - Manager
            User userObj4 = WorkTestDataUtility.createDSManagerUserForCoaching();
            userObj4.ManagerId = userObj5.id;
            insert userObj4;    

        //  DSR - Manager
            User userObj3 = WorkTestDataUtility.createDSManagerUserForCoaching();
            userObj3.ManagerId = userObj4.id;
            insert userObj3;
           
            
        //  DSR - Supervisor
            User userObj2 = WorkTestDataUtility.createDSSupervisorUserForCoaching();
            userObj2.ManagerId = userObj3.id;
            insert userObj2;
           
        //  DSR REP
            User userObj1 = WorkTestDataUtility.createDSRepUserForCoaching();   

            
            userObj1.ManagerId = userObj2.id;
            insert userObj1;
           
               /* Assign PermissionSet to Coresponding Profile user */
        User currentUser = [Select ContactId, Id from User where Id =: userInfo.getUserId()];
        System.runAs(currentUser){            
            AssignPermissionSet('SalesSpace_Coach_Access_ASM',userObj3.Id);   
            AssignPermissionSet('SalesSpace_Coach_Access_SDM',userObj2.Id);
            AssignPermissionSet('SalesSpace_Coach_Access_XSP',userObj1.Id);
        }  
            
            System.runAs(userObj1) { 
                Test.StartTest();
                WorkCoaching wcRecord = new WorkCoaching();
                wcRecord.CoachId = userObj2.Id;
                wcRecord.CoachedId = userObj1.Id;
                insert wcRecord;
                Test.StopTest();
            }
            }
             /*
    *  This method set permission set to user base on permissionSetName
    */ 
    static void AssignPermissionSet(String permissionSetName, Id userId){
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa);
        
    }
   
    
  }