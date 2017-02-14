/*
  **Author : Shivani Gautam -- Accenture
  **Description : This class contains two functions. 1.For storing the deleted feeds and the comments associated with the feeds. 
                                                     2.For storing the deleted comments.
*/

public class StoreDeletedChatter {
    
      private static final string PostType = 'Post';
      private static final string CommentType = 'Comments';
      private static final string paragraph ='<p>';
      private static final string paragraphEnd ='</p>';
      
       //This method stores the deleted feeds and associated comments. 
      public static void storeDeletedFeeds(List<Feeditem> feedList){
            String Description; 
            String target;
            String replacement;
            String str;
            String target1;
            String endString;
        
            List <Deleted_Feeds__c> delFeedList = new List <Deleted_Feeds__c>();
            List <Deleted_Feeds__c> delCommentList = new List <Deleted_Feeds__c>();
            List<FeedComment> commentList = [SELECT id,InsertedById,CommentBody,FeedItemId FROM FeedComment where FeedItemId IN:feedList];
            system.debug('*Commentlist*'+commentList);
            List<Feeditem> FeedItemLst = new List<Feeditem>();
            Deleted_Feeds__c delFeed = new Deleted_Feeds__c();
            
       try{
        for(Feeditem feeds : feedList)
        { 
            
            system.debug('*feeds.CreatedById*'+feeds.CreatedById);
            delFeed.Owner_of_Deleted_Feed__c= feeds.CreatedById;
           
           if(!String.isblank(feeds.Body)){
                Description = feeds.Body;
                target= paragraph;
                replacement = '';
                str =Description.replace(target, replacement);
                target1 = paragraphEnd;
                endString =str.replace(target1, replacement);
                delFeed.Description__c = endString;
            }
            
            delFeed.Post_Id__c=feeds.id;
            delFeed.Type__c= PostType; 
            delFeed.Deleted_By__c =UserInfo.getUserId();
            delFeed.Deleted_On__c= System.now();
            delFeedList.add(delFeed);
            FeedItemLst.add(feeds);
        }
           
            system.debug('*delFeedList*'+delFeedList);
          //  if(!delFeedList.isEmpty()){
         //   insert delFeedList;   
       // }

        for(FeedComment fc :commentList){
            //Deleted_Feeds__c delFeed = new Deleted_Feeds__c();
            Deleted_Feeds__c delFeedComment = new Deleted_Feeds__c();
            // delFeed.name = 'comment';
            delFeedComment.Description__c = fc.CommentBody;
            delFeedComment.Post_Id__c=fc.FeedItemId;
            delFeedComment.Comment_Id__c = fc.id;
            delFeedComment.Type__c= CommentType; 
            delFeedComment.Deleted_By__c =UserInfo.getUserId();
            delFeedComment.Deleted_On__c= System.now();
            delFeedComment.Owner_of_Deleted_Feed__c= fc.InsertedById;
            delFeedList.add(delFeedComment);
            //system.debug('**CdelFeedList1**' +delFeedList);  
            }
            if(!delFeedList.isEmpty()){
            insert delFeedList;
        }
       }
       catch(exception ex)
       {
         System.debug('An exception occurred: ' + ex.getMessage());

       }
    }


      //This method stores the deleted comments associated with the feed. 
    public static void storeDeletedComments(List<FeedComment> commentList){
            List <Deleted_Feeds__c> delFeedList1 = new List <Deleted_Feeds__c>();
            for(FeedComment fc :commentList){
                Deleted_Feeds__c delFeedCom = new Deleted_Feeds__c();
                delFeedCom.Owner_of_Deleted_Feed__c= fc.InsertedById;
                delFeedCom.Description__c = fc.CommentBody;
                delFeedCom.Comment_Id__c =fc.id;
                delFeedCom.Post_id__c =fc.FeedItemId;
                delFeedCom.Type__c= 'Comments'; 
                delFeedCom.Deleted_By__c =UserInfo.getUserId();
                delFeedCom.Deleted_On__c= System.now();
                delFeedList1.add(delFeedCom);
                system.debug('**CdelFeedList1**' +delFeedList1);

        }
            if(!delFeedList1.isEmpty()){
            Database.insert(delFeedList1,false);   
        }
    }
}