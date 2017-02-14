@isTest
    public class StoreDeletedChatterTest
    {
      public static testMethod void createFeedData1()
        {    
          List<FeedItem> feedList = new List<FeedItem>();
          List<FeedComment> ComList = new List<FeedComment> ();
          Test.StartTest();
          //Feed item Insertion
          FeedItem item = new FeedItem();
          item.Body = 'test post';
          item.ParentId = UserInfo.getUserId();
          feedList.add(item);
          //Feed Comment insertion
          FeedComment fc = new FeedComment();
          fc.CommentBody = 'test comment';
          fc.FeedItemId = item.id;
          ComList.add(fc);
          StoreDeletedChatter.storeDeletedFeeds(feedList);
          StoreDeletedChatter.storeDeletedComments(ComList);
          Test.StopTest();
          System.assertEquals ('test comment', fc.commentbody);
        }
    }