/************************************* MODIFICATION LOG ********************************************************************************
*
* DESCRIPTION : Test class for Chatter Post and Comment Triggers 
*
*---------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                     DATE                  REASON
*---------------------------------------------------------------------------------------------------------------------------------------
* Erin McGee               10/16/2013         - Original Version
*
* Erin McGee               01/14/2014         - Addition of tests for Mentions                                            
*/
@isTest(SeeAllData=true)
private class PreventChatterPostsAndCommentsTest {

    private static Profile p_delivery = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
    private static UserRole role=[Select Id From UserRole WHERE Name='Comcast: Residential'];

    @isTest static void PreventChatterPostsTest() {
        //SetupTestData.createCustomSettingRecords();
        Chatter_Group_Restriction__c cgr = new Chatter_Group_Restriction__c(Name = 'Prevent Posting Test Group', Restriction_Type__c = 'Cannot Post', Restriction_Message__c = 'You cannot post to the Chatter group.');
        insert cgr;
        CollaborationGroup cg = new CollaborationGroup(Name = 'Prevent Posting Test Group', CollaborationType = 'Public');
        insert cg;
        User currentUser=[Select Id From User WHERE Id=:UserInfo.getUserId()];
        currentUser.Terms_and_Conditions_Accepted__c = system.today();
        currentUser.FederationIdentifier = 'FedId29';
        update currentUser;
        system.runAs(currentUser){ 
        User u1 = new User(
            FirstName = 'Consultant',
            LastName = 'Test',
            Email = 'test@test.com',
            Username = 'pm.test@' + UserInfo.getOrganizationId() + 'test.com',
            Alias = 'pmtest',
            ProfileId = p_delivery.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            UserRoleId=role.Id,
            LanguageLocaleKey = 'en_US',
            FederationIdentifier = 'FedId2',
            Terms_and_Conditions_Accepted__c=Date.Today());
        insert u1;
        CollaborationGroupMember cgm = new CollaborationGroupMember(collaborationGroupId = cg.Id, MemberId = u1.Id, CollaborationRole = 'Standard');
        insert cgm;
        Test.startTest();
        system.runAs(u1) {
            try {
                // Create Chatter Post
                FeedItem testFeed1 = new FeedItem(Body = 'Test Feed 1 Post', ParentId = cg.Id, Type = 'TextPost');
                system.debug('Add Post');
                insert testFeed1;
            } catch (Exception ex) {
              System.debug(ex.getMessage());
                System.assertEquals(ex.getMessage(), 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, You cannot post to the Chatter group.: []');
            }
        }
    }
        // Create Chatter Post
        FeedItem testFeed2 = new FeedItem(Body = 'Test Feed 2 Post', ParentId = cg.Id, Type = 'TextPost');
        insert testFeed2;
        Test.stopTest();
    }

        @isTest static void PreventChatterPostsMentionsTest() {
        //SetupTestData.createCustomSettingRecords();
        Chatter_Group_Restriction__c cgr = new Chatter_Group_Restriction__c(Name = 'Prevent Posting Test Group', Restriction_Type__c = 'Cannot Post', Restriction_Message__c = 'You cannot post to the Chatter group.', Mention_Restriction_Message__c = 'You cannot post to [group].');
        insert cgr;
        CollaborationGroup cg = new CollaborationGroup(Name = 'Prevent Posting Test Group', CollaborationType = 'Public');
        insert cg;
        User currentUser=[Select Id From User WHERE Id=:UserInfo.getUserId()];
        system.runAs(currentUser){ 
        User u1 = new User(
            FirstName = 'Consultant',
            LastName = 'Test',
            Email = 'test@test.com',
            Username = 'pm.test@' + UserInfo.getOrganizationId() + 'test.com',
            Alias = 'pmtest',
            ProfileId = p_delivery.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            UserRoleId=role.Id,
            LanguageLocaleKey = 'en_US',
            FederationIdentifier = 'FedId8',
            Terms_and_Conditions_Accepted__c=Date.Today());
        insert u1;
        CollaborationGroupMember cgm = new CollaborationGroupMember(collaborationGroupId = cg.Id, MemberId = u1.Id, CollaborationRole = 'Standard');
        insert cgm;
        Test.startTest();
        system.runAs(u1) {
            try {
                // Create Chatter Post
                FeedItem testFeed1 = new FeedItem(Body = '@Prevent Posting Test Group Test Feed 1 Post', ParentId = u1.Id, Type = 'TextPost');
                system.debug('Add Post');
                insert testFeed1;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
                System.assertEquals(ex.getMessage(), 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, You cannot post to Prevent Posting Test Group.: []');
            }
        }
    }
        Test.stopTest();
    }

    @isTest static void PreventChatterCommentsTest() {
        //SetupTestData.createCustomSettingRecords();
        Chatter_Group_Restriction__c cgr = new Chatter_Group_Restriction__c(Name = 'Prevent Posting or Commenting Test Group', Restriction_Type__c = 'Cannot Post or Comment', Restriction_Message__c = 'You cannot post or comment to the Chatter group.', Mention_Restriction_Message__c = 'You cannot post to [group].');
        insert cgr;
        CollaborationGroup cg = new CollaborationGroup(Name = 'Prevent Posting or Commenting Test Group', CollaborationType = 'Public');
        insert cg;
User currentUser=[Select Id From User WHERE Id=:UserInfo.getUserId()];
currentUser.Terms_and_Conditions_Accepted__c = system.today();
currentUser.FederationIdentifier = 'FedId55';
update currentUser;
        system.runAs(currentUser){ 
        User u1 = new User(
            FirstName = 'Consultant',
            LastName = 'Test',
            Email = 'test@test.com',
            Username = 'pm.test@' + UserInfo.getOrganizationId() + 'test.com',
            Alias = 'pmtest',
            ProfileId = p_delivery.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            UserRoleId=role.Id,
            LanguageLocaleKey = 'en_US',
            FederationIdentifier = 'FedId5',
            Terms_and_Conditions_Accepted__c=Date.Today());
        insert u1;
        CollaborationGroupMember cgm = new CollaborationGroupMember(collaborationGroupId = cg.Id, MemberId = u1.Id, CollaborationRole = 'Standard');
        insert cgm;
        // Create Chatter Post
        FeedItem testFeed1;
        Test.startTest();
        system.runAs(u1) {
            try {
                testFeed1 = new FeedItem(Body = 'Test Feed 1 Post', ParentId = cg.Id, Type = 'TextPost');
                insert testFeed1;
            } catch (Exception ex) {
              System.debug(ex.getMessage());
                System.assertEquals(ex.getMessage(), 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, You cannot post or comment to the Chatter group.: []');
            }
        }
        system.runAs(currentUser) {

            testFeed1 = new FeedItem(Body = 'Test Feed 1 Post', ParentId = cg.Id, Type = 'TextPost');
            insert testFeed1;

            // Create Chatter Comment
            FeedComment testFeed2Comment = new FeedComment(CommentBody = '#answer Test Feed 2 Comment', FeedItemId = testFeed1.Id, CommentType = 'TextComment');
            insert testFeed2Comment;
        }

        system.runAs(u1) {

            try {
                // Create Chatter Comment
                FeedComment testFeed1Comment = new FeedComment(CommentBody = 'Test Feed 1 Comment', FeedItemId = testFeed1.Id, CommentType = 'TextComment');
                insert testFeed1Comment;
            } catch (Exception ex) {
              System.debug(ex.getMessage());
                System.assertEquals(ex.getMessage(), 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, You cannot post or comment to the Chatter group.: []');
            }
        }
    }
        Test.stopTest();
    }

        @isTest static void PreventChatterMentionCommentsTest() {
        //SetupTestData.createCustomSettingRecords();
        Chatter_Group_Restriction__c cgr = new Chatter_Group_Restriction__c(Name = 'Prevent Posting or Commenting Test Group', Restriction_Type__c = 'Cannot Post or Comment', Restriction_Message__c = 'You cannot post or comment to the Chatter group.', Mention_Restriction_Message__c = 'You cannot post to [group].');
        insert cgr;
        CollaborationGroup cg = new CollaborationGroup(Name = 'Prevent Posting or Commenting Test Group', CollaborationType = 'Public');
        insert cg;
User currentUser=[Select Id From User WHERE Id=:UserInfo.getUserId()];
currentUser.Terms_and_Conditions_Accepted__c = system.today();
currentUser.FederationIdentifier = 'FedId59';
update currentUser;
        system.runAs(currentUser){ 
        User u1 = new User(
            FirstName = 'Consultant',
            LastName = 'Test',
            Email = 'test@test.com',
            Username = 'pm.test@' + UserInfo.getOrganizationId() + 'test.com',
            Alias = 'pmtest',
            ProfileId = p_delivery.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            UserRoleId=role.Id,
            LanguageLocaleKey = 'en_US',
            FederationIdentifier = 'FedId23',
            Terms_and_Conditions_Accepted__c=Date.Today());
        insert u1;
        CollaborationGroupMember cgm = new CollaborationGroupMember(collaborationGroupId = cg.Id, MemberId = u1.Id, CollaborationRole = 'Standard');
        insert cgm;
        // Create Chatter Post
        FeedItem testFeed1;
        Test.startTest();
        system.runAs(u1) {
            try {
                testFeed1 = new FeedItem(Body = 'Test Feed 1 Post', ParentId = cg.Id, Type = 'TextPost');
                insert testFeed1;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
                System.assertEquals(ex.getMessage(), 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, You cannot post or comment to the Chatter group.: []');
            }
        }

        system.runAs(currentUser) {

            testFeed1 = new FeedItem(Body = 'Test Feed 1 Post', ParentId = cg.Id, Type = 'TextPost');
            insert testFeed1;

            // Create Chatter Comment
            FeedComment testFeed2Comment = new FeedComment(CommentBody = '#answer Test Feed 2 Comment', FeedItemId = testFeed1.Id, CommentType = 'TextComment');
            insert testFeed2Comment;
        }

        system.runAs(u1) {

            try {
                            testFeed1 = new FeedItem(Body = 'Test Feed 1 Post', ParentId = currentUser.Id, Type = 'TextPost');
            insert testFeed1;
                // Create Chatter Comment
                FeedComment testFeed1Comment = new FeedComment(CommentBody = '@Prevent Posting or Commenting Test Group Test Feed 1 Comment', FeedItemId = testFeed1.Id, CommentType = 'TextComment');
                insert testFeed1Comment;
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }
    }
        Test.stopTest();
    }

}