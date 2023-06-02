trigger New_Post_all_with_access on FeedItem (before insert) 
  {   
      for(FeedItem feed:Trigger.new)
      {
          feed.Visibility='AllUsers';
      }
  }