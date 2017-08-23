@isTest
public class SFPS_GNC_GetNextCaseTest
{
    //Basic GNC Test w/o priority test, as case priority will likely be adjusted by workflow rules
    static testMethod void SFPS_GNC_GetNextCaseTest()
    {
        //Setup g1 queue group
        Group g1 = new Group();
        g1.type = 'Queue';
        g1.name = 'Test group 1';
        insert g1;

        //Setup g2 queue group
        Group g2 = new Group();
        g2.type = 'Queue';
        g2.name = 'Test group 2';
        insert g2;

        //Setup g3 public group
        Group g3 = new Group();
        g3.type = 'Regular';
        g3.name = 'Test group 3';
        insert g3;

        //Setup user as member of g1 queue
        Groupmember gm1 = new GroupMember();
        gm1.userorgroupid = userinfo.getUserId();
        gm1.groupid = g1.id;
        insert gm1;

        //Setup g3 group as member of g2 queue
        Groupmember gm2 = new GroupMember();
        gm2.userorgroupid = g3.Id;
        gm2.groupid = g2.id;
        insert gm2;

        //Setup user as member of g3 group, which is a member of g2 queue
        Groupmember gm3 = new GroupMember();
        gm3.userorgroupid = userinfo.getUserId();
        gm3.groupid = g3.id;
        insert gm3;

        //Setup g1 queue 
        QueueSobject q1 = new QueueSobject();
        q1.queue = g1;
        q1.queueId  = g1.id;
        q1.sobjectType = 'Case';
        insert q1;

        //Setup g2 queue 
        QueueSobject q2 = new QueueSobject();
        q2.queue = g2;
        q2.queueId  = g2.id;
        q2.sobjectType = 'Case';
        insert q2;

        User usr = [Select id from User where Id = :UserInfo.getUserId()];

        System.RunAs(usr)
        {
            //GNC is designed to allow cusotm case prioritization via workflow rules
            //Validate only when test data is created as specfied (case owner and priority possibly altered by workflow rules)
            Boolean bTestDataAsConfigured = true;

            //Create case with GNC priority date order in c1, c3, c2
            Case c1 = new Case();
            c1.ownerid = g1.Id;
            c1.Region__c = 'Freedom Market';
            c1.subject = 'c1';
            insert c1;

            Case c1i = [Select Id, Ownerid, SFPS_GNC_PriorityLevel__c, SFPS_GNC_PriorityDate__c, IsClosed from Case Where id = :c1.Id];            
            if ((c1.Ownerid != c1i.Ownerid)
              || (c1i.IsClosed))
              bTestDataAsConfigured = false; 

            Case c2 = new Case();
            c2.ownerid = g1.Id;
            c2.Region__c = 'Freedom Market';
            c2.subject = 'c2';
            insert c2;

            Case c2i = [Select Id, Ownerid, SFPS_GNC_PriorityLevel__c, SFPS_GNC_PriorityDate__c, IsClosed from Case Where id = :c2.Id];            
            if ((c2.Ownerid != c2i.Ownerid)
              || (c1i.IsClosed))
              bTestDataAsConfigured = false;

            Case c3 = new Case();
            c3.ownerid = g2.Id;
            c3.Region__c = 'Freedom Market';
            c3.subject = 'c3';            
            insert c3;

            Case c3i = [Select Id, Ownerid, SFPS_GNC_PriorityLevel__c, SFPS_GNC_PriorityDate__c, IsClosed from Case Where id = :c3.Id];            
            if ((c3.Ownerid != c3i.Ownerid)
              || (c1i.IsClosed))
              bTestDataAsConfigured = false;

            System.debug('SFPS_GNC TEST - bTestDataAsConfigured: ' + bTestDataAsConfigured);  

            Test.startTest();

            SFPS_GNC_GetNextCase gnc;

            //Verify the first case pulled back is c1
            //from g1 queue, where user is a direct member of
            gnc = new SFPS_GNC_GetNextCase();   
            gnc.AssignNextRecord();

            gnc = new SFPS_GNC_GetNextCase();       
            gnc.AssignNextRecord();

            gnc = new SFPS_GNC_GetNextCase();       
            gnc.AssignNextRecord();

            if (bTestDataAsConfigured) 
            {
                //Verify the c1,c2,c3 can all be pulled back from multiple queues
                //from g2 queue where user is only a member of a public group, which is a member of the g2 queue
                Case c1x = [Select Id, Ownerid, SFPS_GNC_LastAssigned__c from Case Where id = :c1.Id];            
                system.assertEquals(usr.Id, c1x.OwnerId);
                Case c2x = [Select Id, Ownerid, SFPS_GNC_LastAssigned__c from Case Where id = :c2.Id];
                system.assertEquals(usr.Id,c2x.OwnerId);
                Case c3x = [Select Id, Ownerid, SFPS_GNC_LastAssigned__c from Case Where id = :c3.Id];
                system.assertEquals(usr.Id,c3x.OwnerId);     
                
                //Verify SFPS_GNC_LastAssigned__c is populated
                system.assertNotEquals(null, c1x.SFPS_GNC_LastAssigned__c);
                system.assertNotEquals(null, c2x.SFPS_GNC_LastAssigned__c);
                system.assertNotEquals(null, c3x.SFPS_GNC_LastAssigned__c);                
            }
            Test.stopTest();
        }
    }

    //GNC Test with Priorities
    static testMethod void SFPS_GNC_GetNextCaseTest_PriorityLevelAndDate()
    {
        //Setup g1 queue group
        Group g1 = new Group();
        g1.type = 'Queue';
        g1.name = 'Test group 1';
        insert g1;

        //Setup user as member of g1 queue
        Groupmember gm1 = new GroupMember();
        gm1.userorgroupid = userinfo.getUserId();
        gm1.groupid = g1.id;
        insert gm1;

        //Setup g1 queue 
        QueueSobject q1 = new QueueSobject();
        q1.queue = g1;
        q1.queueId  = g1.id;
        q1.sobjectType = 'Case';
        insert q1;

        User usr = [Select id from User where Id = :UserInfo.getUserId()];

        System.RunAs(usr)
        {
            //GNC is designed to allow cusotm case prioritization via workflow rules
            //Validate only when test data is created as specfied (case owner and priority possibly altered by workflow rules)
            Boolean bTestDataAsConfigured = true;

            //Create case with GNC priority date order in c1, c3, c2
            Case c1 = new Case();
            c1.ownerid = g1.Id;
            c1.Region__c = 'Freedom Market';
            c1.subject = 'c1';
            c1.SFPS_GNC_PriorityDate__c = DateTime.parse('1/7/2015 12:00 AM');
            insert c1;

            Case c1i = [Select Id, Ownerid, SFPS_GNC_PriorityLevel__c, SFPS_GNC_PriorityDate__c from Case Where id = :c1.Id];            
            if ((c1.Ownerid != c1i.Ownerid)
              || (c1.SFPS_GNC_PriorityLevel__c != c1i.SFPS_GNC_PriorityLevel__c)
              || (c1.SFPS_GNC_PriorityDate__c != c1i.SFPS_GNC_PriorityDate__c))
              bTestDataAsConfigured = false;

            Case c2 = new Case();
            c2.ownerid = g1.Id;
            c2.Region__c = 'Freedom Market';
            c2.subject = 'c2';
            c2.SFPS_GNC_PriorityDate__c = DateTime.parse('2/7/2015 12:00 AM');
            insert c2;

            Case c2i = [Select Id, Ownerid, SFPS_GNC_PriorityLevel__c, SFPS_GNC_PriorityDate__c from Case Where id = :c2.Id];            
            if ((c2.Ownerid != c2i.Ownerid)
              || (c2.SFPS_GNC_PriorityLevel__c != c2i.SFPS_GNC_PriorityLevel__c)
              || (c2.SFPS_GNC_PriorityDate__c != c2i.SFPS_GNC_PriorityDate__c))
              bTestDataAsConfigured = false;

            Case c3 = new Case();
            c3.ownerid = g1.Id;
            c3.subject = 'c3';  
            c3.Region__c = 'Freedom Market';
            c3.SFPS_GNC_PriorityLevel__c = 2;
            c3.SFPS_GNC_PriorityDate__c = DateTime.parse('3/7/2015 12:00 AM');
            insert c3;

            Case c3i = [Select Id, Ownerid, SFPS_GNC_PriorityLevel__c, SFPS_GNC_PriorityDate__c from Case Where id = :c3.Id];            
            if ((c3.Ownerid != c3i.Ownerid)
              || (c3.SFPS_GNC_PriorityLevel__c != c3i.SFPS_GNC_PriorityLevel__c)
              || (c3.SFPS_GNC_PriorityDate__c != c3i.SFPS_GNC_PriorityDate__c))
              bTestDataAsConfigured = false;

            Case c4 = new Case();
            c4.ownerid = g1.Id;
            c4.subject = 'c4';  
            c4.Region__c = 'Freedom Market';
            c4.SFPS_GNC_PriorityLevel__c = 1;
            c4.SFPS_GNC_PriorityDate__c = DateTime.parse('4/7/2015 12:00 AM');
            insert c4;

            Case c4i = [Select Id, Ownerid, SFPS_GNC_PriorityLevel__c, SFPS_GNC_PriorityDate__c from Case Where id = :c4.Id];            
            if ((c4.Ownerid != c4i.Ownerid)
              || (c4.SFPS_GNC_PriorityLevel__c != c4i.SFPS_GNC_PriorityLevel__c)
              || (c4.SFPS_GNC_PriorityDate__c != c4i.SFPS_GNC_PriorityDate__c))
              bTestDataAsConfigured = false;

            Test.startTest();

            SFPS_GNC_GetNextCase gnc;

            //Verify the first case pulled back is c4 based on priority level = 1
            gnc = new SFPS_GNC_GetNextCase();   
            gnc.AssignNextRecord();
            Case c4x = [Select Id, Ownerid from Case Where id = :c4.Id];            
            if (bTestDataAsConfigured) system.assertEquals(usr.Id, c4x.OwnerId);

            //Verify the second case pulled back is c3 based on priority level = 2
            gnc = new SFPS_GNC_GetNextCase();       
            gnc.AssignNextRecord();
            Case c3x = [Select Id, Ownerid from Case Where id = :c3.Id];
            if (bTestDataAsConfigured) system.assertEquals(usr.Id,c3x.OwnerId);     

            //Verify the third case pulled back is c1, which has null (lowest priority) but before c2 based on GNC priority date
            gnc = new SFPS_GNC_GetNextCase();            
            gnc.AssignNextRecord();
            Case c1x = [Select Id, Ownerid from Case Where id = :c1.Id];
            if (bTestDataAsConfigured) system.assertEquals(usr.Id,c1x.OwnerId);

            //Verify the third case pulled back is c2, which has null (lowest priority) but after c1 based on GNC priority date
            gnc = new SFPS_GNC_GetNextCase();            
            gnc.AssignNextRecord();
            Case c2x = [Select Id, Ownerid from Case Where id = :c2.Id];
            if (bTestDataAsConfigured) system.assertEquals(usr.Id,c2x.OwnerId);
            
            Test.stopTest();
        }
    }

    static testMethod void SFPS_GNC_GetNextCaseTest_3_Level_Groups() 
    {
        // define the SaveResult
        Database.SaveResult sr = null;

        //Setup g1 as queue group
        Group g1 = new Group();
        g1.type = 'Queue';
        g1.name = 'Test Queue group';
        // insert the record
        Database.SaveResult sr1 = Database.insert(g1, true);
        // ensure the record has an Id
        system.assert(sr1.isSuccess(), 'DML Statement Failed! Id: [' + sr1.getId() + '], Errors: ' + sr1.getErrors());

        //Setup g2 as parent group
        Group g2 = new Group();
        g2.type = 'Regular';
        g2.name = 'Test Parent Group';
        // insert the record
        Database.SaveResult sr2 = Database.insert(g2, true);
        // ensure the record has an Id
        system.assert(sr2.isSuccess(), 'DML Statement Failed! Id: [' + sr2.getId() + '], Errors: ' + sr2.getErrors());

        //Setup g3 as sub group
        Group g3 = new Group();
        g3.type = 'Regular';
        g3.name = 'Test Sub Group';
        // insert the record
        Database.SaveResult sr3 = Database.insert(g3, true);
        // ensure the record has an Id
        system.assert(sr3.isSuccess(), 'DML Statement Failed! Id: [' + sr3.getId() + '], Errors: ' + sr3.getErrors());

        //Setup g2 group as member of g1 queue
        Groupmember gm1 = new GroupMember();
        gm1.userorgroupid = sr2.getId();
        gm1.groupid = sr1.getId();
        // insert the record
        sr = Database.insert(gm1, true);
        // ensure the record has an Id
        system.assert(sr.isSuccess(), 'DML Statement Failed! Id: [' + sr.getId() + '], Errors: ' + sr.getErrors());

        //Setup g3 as member of g3 group, which is a member of g1 queue
        Groupmember gm2 = new GroupMember();
        gm2.userorgroupid = sr3.getId();
        gm2.groupid = sr2.getId();
        sr = Database.insert(gm2, true);
        // ensure the record has an Id
        system.assert(sr.isSuccess(), 'DML Statement Failed! Id: [' + sr.getId() + '], Errors: ' + sr.getErrors());

        //Setup user as member of g3 group, which is a member of g2 group, which is a member of g1 queue
        Groupmember gm3 = new GroupMember();
        gm3.userorgroupid = userinfo.getUserId();
        gm3.groupid = sr3.getId();
        sr = Database.insert(gm3, true);
        // ensure the record has an Id
        system.assert(sr.isSuccess(), 'DML Statement Failed! Id: [' + sr.getId() + '], Errors: ' + sr.getErrors());

        //Setup g1 queue 
        QueueSobject q1 = new QueueSobject();
        q1.queue = g1;
        q1.queueId  = sr1.getId();
        q1.sobjectType = 'Case';
        // insert the record
        sr = Database.insert(q1, true);
        // ensure the record has an Id
        system.assert(sr.isSuccess(), 'DML Statement Failed! Id: [' + sr.getId() + '], Errors: ' + sr.getErrors());

        User usr = [Select Id from User where Id = :UserInfo.getUserId()];

        system.RunAs(usr)
        {
            //GNC is designed to allow cusotm case prioritization via workflow rules
            //Validate only when test data is created as specfied (case owner and priority possibly altered by workflow rules)
            Boolean bTestDataAsConfigured = true;

            //Create case
            Case c1 = new Case();
            c1.OwnerId = sr1.getId();
            c1.Region__c = 'Freedom Market';
            c1.Subject = 'c1';
            c1.SFPS_GNC_PriorityDate__c = DateTime.parse('09/21/2015 12:00 AM');
            
            // insert the record
            sr = Database.insert(c1, true);
            // ensure the record has an Id
            system.assert(sr.isSuccess(), 'DML Statement Failed! Id: [' + sr.getId() + '], Errors: ' + sr.getErrors());

            Case c1i = [Select Id, Ownerid from Case Where id = :c1.Id];            
            if (c1.Ownerid != c1i.Ownerid)
                bTestDataAsConfigured = false;

            Test.startTest();

            //Verify the the case pulled back is c1
            SFPS_GNC_GetNextCase gnc = new SFPS_GNC_GetNextCase();   
            gnc.AssignNextRecord();
            Case c1x = [Select Id, OwnerId from Case Where Id = :c1.Id];            
            if (bTestDataAsConfigured) system.assertEquals(usr.Id, c1x.OwnerId);

            Test.stopTest();
        }
    }

    static testMethod void SFPS_GNC_GetNextCaseTest_UserRole() 
    {
        if (UserInfo.getUserRoleId() != null)
        {
            // define the SaveResult
            Database.SaveResult sr = null;

            //Setup g1 as queue group
            Group g1 = new Group();
            g1.Type = 'Queue';
            g1.Name = 'Test Queue group';
            // insert the record
            Database.SaveResult sr1 = Database.insert(g1, true);
            // ensure the record has an Id
            system.assert(sr1.isSuccess(), 'DML Statement Failed! Id: [' + sr1.getId() + '], Errors: ' + sr1.getErrors());
            
            // get the group associated with User Role
            Group roleGroup = [Select Id, RelatedId From Group Where RelatedId = :UserInfo.getUserRoleId() Limit 1];
            system.assertNotEquals(null, roleGroup.Id);

            //Setup g2 group as member of g1 queue
            Groupmember gm1 = new GroupMember();
            gm1.userorgroupid = roleGroup.Id;
            gm1.groupid = sr1.getId();
            // insert the record
            sr = Database.insert(gm1, true);
            // ensure the record has an Id
            system.assert(sr.isSuccess(), 'DML Statement Failed! Id: [' + sr.getId() + '], Errors: ' + sr.getErrors());

            //Setup g1 queue 
            QueueSobject q1 = new QueueSobject();
            q1.queue = g1;
            q1.queueId  = sr1.getId();
            q1.sobjectType = 'Case';
            // insert the record
            sr = Database.insert(q1, true);
            // ensure the record has an Id
            system.assert(sr.isSuccess(), 'DML Statement Failed! Id: [' + sr.getId() + '], Errors: ' + sr.getErrors());

            User usr = [Select Id from User where Id = :UserInfo.getUserId()];

            system.RunAs(usr)
            {
                //GNC is designed to allow cusotm case prioritization via workflow rules
                //Validate only when test data is created as specfied (case owner and priority possibly altered by workflow rules)
                Boolean bTestDataAsConfigured = true;

                //Create case
                Case c1 = new Case();
                c1.OwnerId = sr1.getId();
                c1.Region__c = 'Freedom Market';
                c1.Subject = 'c1';
                c1.SFPS_GNC_PriorityDate__c = DateTime.parse('09/21/2015 12:00 AM');
                
                // insert the record
                sr = Database.insert(c1, true);
                // ensure the record has an Id
                system.assert(sr.isSuccess(), 'DML Statement Failed! Id: [' + sr.getId() + '], Errors: ' + sr.getErrors());

                Case c1i = [Select Id, Ownerid from Case Where id = :c1.Id];     
                if (c1.Ownerid != c1i.Ownerid)
                    bTestDataAsConfigured = false;
                
                Test.startTest();

                //Verify the the case pulled back is c1
                SFPS_GNC_GetNextCase gnc = new SFPS_GNC_GetNextCase();   
                gnc.AssignNextRecord();
                Case c1x = [Select Id, OwnerId from Case Where Id = :c1.Id];            
                if (bTestDataAsConfigured) system.assertEquals(usr.Id, c1x.OwnerId);

                Test.stopTest();
            }
        }
    }

    //Basic GNC Test w/o priority test, as case priority will likely be adjusted by workflow rules
    static testMethod void SFPS_GNC_GetNextCaseTest_SkillBasedRouting()
    {
        //Setup g1 queue group
        Group g1 = new Group();
        g1.type = 'Queue';
        g1.name = 'Test group 1';
        insert g1;

        //Setup user as member of g1 queue
        Groupmember gm1 = new GroupMember();
        gm1.userorgroupid = userinfo.getUserId();
        gm1.groupid = g1.id;
        insert gm1;

        //Setup g1 queue 
        QueueSobject q1 = new QueueSobject();
        q1.queue = g1;
        q1.queueId  = g1.id;
        q1.sobjectType = 'Case';
        insert q1;

        User usr = [Select id from User where Id = :UserInfo.getUserId()];

        System.RunAs(usr)
        {
            //Insert GNC Skill Settings
            SFPS_GNC_Settings__c co = new SFPS_GNC_Settings__c();
            co.SBR_Enabled__c = true;
            co.SBR_Include_Unspecified__c = true;
            co.SBR_Skill_Object__c = 'ProfileSkill';
            insert co;

            ProfileSkill ps1 = new ProfileSkill();
            ps1.Name = 'Skill1';
            insert ps1;

            ProfileSkill ps2 = new ProfileSkill();
            ps2.Name = 'Skill2';
            insert ps2;

            ProfileSkillUser psu1 = new ProfileSkillUser();
            psu1.UserId = usr.Id;
            psu1.ProfileSkillId = ps1.Id;
            insert psu1;


            //GNC is designed to allow cusotm case prioritization via workflow rules
            //Validate only when test data is created as specfied (case owner and priority possibly altered by workflow rules)
            Boolean bTestMySkill = true;
            Boolean bTestNotMySkill = true;
            Boolean bTestUnspecifiedSkill = true;

            //Create case with GNC priority date order in c1, c3, c2
            Case c1 = new Case();
            c1.ownerid = g1.Id;
            c1.Region__c = 'Freedom Market';
            c1.subject = 'c1';
            c1.SFPS_GNC_SkillName__c = 'Skill1';
            insert c1;
            //Update skill name again, typically if the related skill lookup field is empty
            // workflow rule will set the skill field upon initial case creation
            c1.SFPS_GNC_SkillName__c = 'Skill1';
            update c1;

            Case c1i = [Select Id, Ownerid, SFPS_GNC_SkillName__c, IsClosed from Case Where id = :c1.Id];            
            if ((c1.Ownerid != c1i.Ownerid)
              || (c1.SFPS_GNC_SkillName__c != c1i.SFPS_GNC_SkillName__c)
              || (c1i.IsClosed))
              bTestMySkill = false; 

            Case c2 = new Case();
            c2.ownerid = g1.Id;
            c2.subject = 'c2';
            c2.Region__c = 'Freedom Market';
            c1.SFPS_GNC_SkillName__c = 'Skill2';
            insert c2;
            //Update skill name again, typically if the related skill lookup field is empty
            // workflow rule will set the skill field upon initial case creation
            c2.SFPS_GNC_SkillName__c = 'Skill2';
            update c2;

            Case c2i = [Select Id, Ownerid, SFPS_GNC_SkillName__c, IsClosed from Case Where id = :c2.Id];            
            if ((c2.Ownerid != c2i.Ownerid)
              || (c2.SFPS_GNC_SkillName__c != c2i.SFPS_GNC_SkillName__c)
              || (c1i.IsClosed))
              bTestNotMySkill = false;

            Case c3 = new Case();
            c3.ownerid = g1.Id;
            c3.subject = 'c3';     
            c3.Region__c = 'Freedom Market';
            c1.SFPS_GNC_SkillName__c = 'Unspecified';   
            insert c3;

            Case c3i = [Select Id, Ownerid, SFPS_GNC_SkillName__c, IsClosed from Case Where id = :c3.Id];            
            if ((c3.Ownerid != c3i.Ownerid)
              || (c1.SFPS_GNC_SkillName__c != c1i.SFPS_GNC_SkillName__c)
              || (c1i.IsClosed))
              bTestUnspecifiedSkill = false;

            System.debug('SFPS_GNC TEST - bTestMySkill: ' + bTestMySkill);  
            System.debug('SFPS_GNC TEST - bTestNotMySkill: ' + bTestNotMySkill);  
            System.debug('SFPS_GNC TEST - bTestUnspecifiedSkill: ' + bTestUnspecifiedSkill);  

            Test.startTest();

            SFPS_GNC_GetNextCase gnc;

            //Verify the first case pulled back is c1
            //from g1 queue, where user is a direct member of
            gnc = new SFPS_GNC_GetNextCase();   
            gnc.AssignNextRecord();

            gnc = new SFPS_GNC_GetNextCase();       
            gnc.AssignNextRecord();

            gnc = new SFPS_GNC_GetNextCase();       
            gnc.AssignNextRecord();

            //My skill, I can pull this case
            if (bTestMySkill) 
            {
                Case c1x = [Select Id, Ownerid, SFPS_GNC_LastAssigned__c from Case Where id = :c1.Id];            
                system.assertEquals(usr.Id, c1x.OwnerId);    
                            
            }

            //Not my skill, I cannot pull this case
            if (bTestNotMySkill) 
            {
                Case c2x = [Select Id, Ownerid, SFPS_GNC_LastAssigned__c from Case Where id = :c2.Id];
                system.assertNotEquals(usr.Id,c2x.OwnerId);       
            }

            //Unspecified skill, I can pull this case
            if (bTestUnspecifiedSkill) 
            {
                Case c3x = [Select Id, Ownerid, SFPS_GNC_LastAssigned__c from Case Where id = :c3.Id];
                system.assertEquals(usr.Id,c3x.OwnerId);     
            }
            Test.stopTest();
        }
    }

}