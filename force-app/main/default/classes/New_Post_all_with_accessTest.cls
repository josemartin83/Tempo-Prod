@isTest
public class New_Post_all_with_accessTest
 {
    static testMethod void unitTestInsert() 
    {
        
        Test.startTest();
        
        Case cse = new case 
        (
               STATUS = 'New', 
               ORIGIN = 'Web', 
               TYPE='Support',  
               SUBJECT = 'Feed Item Visibality', 
               DESCRIPTION= 'Test chatter posts visibility (internal or all with access)'
        );
        Insert cse;       
        
        FeedItem feed = new FeedItem
         (
            parentid = cse.id,
            type = 'ContentPost',
            Body = 'Hello'
        );
        insert feed;    
        Test.stopTest();      
    }
 }