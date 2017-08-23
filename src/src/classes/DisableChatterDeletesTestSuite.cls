/**
 * Test Suite for testing Chatter Disable Delete app
 * 
 * Author: Marcus Ericsson - mericsson@salesforce.com
 */
@isTest
private class DisableChatterDeletesTestSuite {

    private static UserRole role=[Select Id From UserRole WHERE Name='Comcast: Residential'];
     
    static void deleteAllCustomSettings() {
       
        //SetupTestData.createCustomSettingRecords();
        system.runAs(new User(id=userinfo.getuserid()))
        {
            
            List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
            TriggerSettings__c feedCommentTrigger = new TriggerSettings__c();
            feedCommentTrigger.Name = 'FeedCommentTrigger';
            feedCommentTrigger.isActive__c = True;
            triggerSettingsList.add(feedCommentTrigger);

            TriggerSettings__c feedItemTrigger = new TriggerSettings__c();
            feedItemTrigger.Name = 'FeedItemTrigger';
            feedItemTrigger.isActive__c = True;
            triggerSettingsList.add(feedItemTrigger);

            TriggerSettings__c termsAndConditionsTrigger = new TriggerSettings__c();
            termsAndConditionsTrigger.Name = 'TermsAndConditionsTrigger';
            termsAndconditionsTrigger.isActive__c = True;
            triggerSettingsList.add(termsAndConditionsTrigger);

            TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = True;
            triggerSettingsList.add(userTrigger);
            insert triggerSettingsList;

            Chatter_Delete_Settings__c[] settings = [select id from Chatter_Delete_Settings__c];
            delete(settings);
        }
  
    
    }   
    static Id insertDummyContact() {
     
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        Database.SaveResult sr;
        // lets do User instead because some orgs don't have Feeds enabled on Contacts.
        Profile prof = [select id from profile where name = 'System Administrator'];
                User currentUser=[Select Id From User WHERE Id=:UserInfo.getUserId()];
        system.runAs(currentUser){
        User u = new User(alias = 'standt', email = 'testFeedItemDeleteDummy@testorg.com', UserRoleId=role.Id, emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedItemDeleteDummy@testorg.com', FederationIdentifier = 'FedId1'+randomstr, Terms_and_Conditions_Accepted__c=Date.Today());
        sr = Database.Insert(u);
        }

                System.assert(sr.isSuccess());
        return sr.getId();
    }

    static testMethod void testFeedItemDeleteSysAdmin() {
        deleteAllCustomSettings();
          String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        Profile prof = [select id from profile where name = 'System Administrator'];
        User u = new User(alias = 'standt', email = 'testFeedItemDelete@testorg.com', UserRoleId=role.Id, emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedItemDelete@testorg.com', FederationIdentifier = 'FedId1'+randomstr, Terms_and_Conditions_Accepted__c=Date.Today());
      
        Database.insert(u);       
        //insert a dummy contact we can post on
        Id cid = insertDummyContact();

        System.runAs(u) {

           test.startTest();
            // test single item delete
            FeedItem p = new FeedItem();
            p.parentId = cid;
            p.Body = 'force.com labs is great!';
            insert(p);
            delete(p);
            test.stopTest();
        }
    }
    
    static testMethod void testFeedItemDeleteSysAdminFrench() {
        deleteAllCustomSettings();
        
          String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        Profile prof = [select id from profile where name = 'System Administrator'];
        User u = new User(alias = 'standt', email = 'testFeedItemDelete@testorg.com', UserRoleId=role.Id, emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'fr', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedItemDelete@testorg.com', FederationIdentifier = 'FedId1'+randomstr, Terms_and_Conditions_Accepted__c=Date.Today());
        Database.insert(u);       
        System.runAs(u) {
            test.startTest();
            // test single item delete
            FeedItem p = new FeedItem();
            p.parentId = u.id;
            p.Body = 'force.com labs is great!';
            insert(p);
            delete(p);
            test.stopTest();
        }
    }

    static testMethod void testFeedCommentDeleteSysAdmin() {
        deleteAllCustomSettings();

        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        Profile prof = [select id from profile where name = 'System Administrator'];
        User u = new User(alias = 'standt', email = 'testFeedItemDelete@testorg.com', UserRoleId=role.Id, emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedItemDelete@testorg.com', FederationIdentifier = 'FedId1'+randomstr, Terms_and_Conditions_Accepted__c=Date.Today());
        Id cid = insertDummyContact();
         Database.insert(u);       
        System.runAs(u) {  
            
             test.startTest();          
    
            // test single item delete
            FeedItem p = new FeedItem();
            p.parentId = cid;
            p.Body = 'force.com labs is great!';
    
            Database.SaveResult sr = Database.Insert(p);
            System.assert(sr.isSuccess());
            Id pId = sr.getId();
    
            FeedComment c = new FeedComment();
            c.feedItemId = pid;
            c.CommentBody = 'this is a comment';
            insert(c);

            delete(c);
             test.stopTest();
        }
    }

    static testMethod void testFeedItemDelete() {
        deleteAllCustomSettings();
        
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        Profile prof = [select id from profile where name = 'Standard User'];
        User u = new User(alias = 'standt', email = 'testFeedItemDelete@testorg.com', UserRoleId=role.Id, emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedItemDelete@testorg.com', FederationIdentifier = 'FedId1'+randomstr, Terms_and_Conditions_Accepted__c=Date.Today());
        //insert a dummy contact we can post on
        Id cid = insertDummyContact();
         Database.insert(u);       
        System.runAs(u) {
            
             test.startTest();
            // The following code runs as user 'u'   

            FeedItem p = new FeedItem();
            p.parentId = cid;
            p.Body = 'force.com labs is great!';
            insert(p);
            p.Body = 'force.com labs is awesome!';
            
             // test single item Edit
            try {
                update(p);
            } catch (System.DmlException e) {
                System.assert(e.getMessage().contains('disabled'));
            }
             // test single item delete           
            try {
                delete(p);
            } catch (System.DmlException e) {
                System.assert(e.getMessage().contains('disabled'));
            }


            // now test bulk delete
            FeedItem[] ps = new FeedItem[150];
            for (Integer i = 0; i < 150; i++) {
                ps[i] = new FeedItem();
                ps[i].parentId = cid;
                ps[i].body = 'force.com labs is great!';
            }
            insert(ps);
            try {
                delete(ps);
            } catch (System.DmlException e) {
                System.assert(e.getMessage().contains('disabled'));
            }
            test.stopTest();
        }
    }
    
    static testMethod void testFeedItemDeleteFrench() {
        deleteAllCustomSettings();
        
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        Profile prof = [select id from profile where name = 'Standard User'];
        User u = new User(alias = 'standt', email = 'testFeedItemDelete@testorg.com', UserRoleId=role.Id, emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'fr', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedItemDelete@testorg.com',FederationIdentifier = 'FedId1'+randomstr,  Terms_and_Conditions_Accepted__c=Date.Today());
         Database.insert(u);       

        System.runAs(u) {
            test.startTest();
           
            FeedItem p = new FeedItem();
            p.parentId = u.id;
            p.Body = 'force.com labs is great!';
            insert(p);
            
            p.Body = 'force.com labs is awesome!';
            
             // test single item Edit
            try {
                update(p);
            } catch (System.DmlException e) {
                System.assert(e.getMessage().contains('disabled'));
            }
             // test single item delete
            try {
                delete(p);
            } catch (System.DmlException e) {
                System.assert(e.getMessage().contains('disabled'));
            }
            test.stopTest();
        }
    }

    static testMethod void testFeedCommentDelete() {
        
        deleteAllCustomSettings();        
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        Profile prof = [select id from profile where name = 'Standard User'];
        User u = new User(alias = 'standt', email = 'testFeedCommentDelete@testorg.com', UserRoleId=role.Id, emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedCommentDelete@testorg.com', FederationIdentifier = 'FedId1'+randomstr,Terms_and_Conditions_Accepted__c=Date.Today());
        Database.insert(u);       

       //insert a dummy contact we can post on
        Id cid = insertDummyContact();

        System.runAs(u) {
            test.startTest();
            // The following code runs as user 'u'   

            // test single item delete
            FeedItem p = new FeedItem();
            p.parentId = cid;
            p.Body = 'force.com labs is great!';

            Database.SaveResult sr = Database.Insert(p);
            System.assert(sr.isSuccess());
            Id pId = sr.getId();

            FeedComment c = new FeedComment();
            c.feedItemId = pid;
            c.CommentBody = 'this is a comment';
            insert(c);
            
            c.CommentBody = 'this is a modified comment';
            
            try {
                update(c);
            } catch (System.DmlException e) {
                System.assert(e.getMessage().contains('disabled'));
            }


            try {
                delete(c);
            } catch (System.DmlException e) {
                System.assert(e.getMessage().contains('disabled'));
            }


            // now test bulk delete
            FeedComment[] cs = new FeedComment[150];
            for (Integer i = 0; i < 150; i++) {
                cs[i] = new FeedComment();
                cs[i].feeditemid = pid;
                cs[i].CommentBody = 'force.com labs is great!';
            }
            insert(cs);
            try {
                delete(cs);
                //System.assert(false);
            } catch (System.DmlException e) {
                System.assert(e.getMessage().contains('disabled'));
            }
            test.stopTest();
        }
    }

    static testMethod void testFeedItemDeleteCustomSetting() {
        deleteAllCustomSettings();

        
         User currentUser=[Select Id From User WHERE Id=:UserInfo.getUserId()];
        system.runAs(currentUser)
        {
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        Profile prof = [select id from profile where name = 'Standard User'];
        User u = new User(alias = 'standt', email = 'testFeedItemDelete@testorg.com', UserRoleId=role.Id, emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedItemDelete@testorg.com', FederationIdentifier = 'FedId1'+randomstr,Terms_and_Conditions_Accepted__c=Date.Today());
        Database.insert(u);       
        Chatter_Delete_Settings__c settings = new Chatter_Delete_Settings__c();
        settings.Allow_Feed_Post_And_Comment_deletes__c = true;
        settings.SetupOwnerId = prof.id;
        upsert(settings);
        
        //insert a dummy contact we can post on
        Id cid = insertDummyContact();
        try {
            System.runAs(u) {
                test.startTest();
                
                
                // The following code runs as user 'u'   

               
                FeedItem p = new FeedItem();
                p.parentId = cid;
                p.Body = 'force.com labs is great!';
                insert(p);
                
                //test single item edit
                p.Body = 'force.com labs is awesom!';
                update (p);
                
                // test single item delete
                delete(p);

                // now test bulk delete
                FeedItem[] ps = new FeedItem[150];
                for (Integer i = 0; i < 150; i++) {
                    ps[i] = new FeedItem();
                    ps[i].parentId = cid;
                    ps[i].body = 'force.com labs is great!';
                }
                insert(ps);
                
                delete(ps);
               test.stopTest();
                }
            
        } finally {
            settings.Allow_Feed_Post_And_Comment_deletes__c = false;
            update(settings);
        }
    }
    }

   /* static testMethod void testFeedCommentDeleteCustomSetting() {
        deleteAllCustomSettings();
    system.runAs(new User(id=userinfo.getuserid()))
        {   
         String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        Profile prof = [select id from profile where name = 'Standard User'];
        User u = new User(alias = 'standt', email = 'testFeedCommentDelete@testorg.com', UserRoleId=role.Id, emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedCommentDelete@testorg.com', FederationIdentifier = 'FedId1'+randomstr,Terms_and_Conditions_Accepted__c=Date.Today());
        Database.insert(u);
            
         Chatter_Delete_Settings__c settings = new Chatter_Delete_Settings__c();
        settings.Allow_Feed_Post_And_Comment_deletes__c = true;
        settings.SetupOwnerId = prof.id;
        upsert(settings);
        }
        
        User currentUser=[Select Id From User WHERE Id=:UserInfo.getUserId()];
        system.runAs(currentUser)
        {        
        //insert a dummy contact we can post on
        Id cid = insertDummyContact();

         
        try {


            System.runAs(u) {
                test.startTest();
                // The following code runs as user 'u'   

                // test single item delete
                FeedItem p = new FeedItem();
                p.parentId = cid;
                p.Body = 'force.com labs is great!';

                Database.SaveResult sr = Database.Insert(p);
                System.assert(sr.isSuccess());
                Id pId = sr.getId();

                FeedComment c = new FeedComment();
                c.feedItemId = pid;
                c.CommentBody = 'this is a comment';
                insert(c);


                delete(c);

                // now test bulk delete
               
                FeedComment[] cs = new FeedComment[150];
                for (Integer i = 0; i < 150; i++) {
                    cs[i] = new FeedComment();
                    cs[i].feeditemid = pid;
                    cs[i].CommentBody = 'force.com labs is great!';
                }
                insert(cs);
                delete(cs);
                test.stopTest();
            }
        } finally {
            settings.Allow_Feed_Post_And_Comment_deletes__c = false;
            update(settings);
        }
        

       /}

    }*/

}