trigger ContentDocumentLinkTrigger on ContentDocumentLink (before update, after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        List<FeedItem> listOfFeedFile = new List<Feeditem>();
        Set<Id> contentDocumentIds = new Set<Id>();
        
        for(ContentDocumentLink thisContentLink : trigger.new){
            if(thisContentLink.ContentDocumentId != null)
            {
                contentDocumentIds.add(thisContentLink.ContentDocumentId);
            } 
        }
        
        Map<Id, ContentDocument> allContentDocuments = new Map<Id, ContentDocument>([SELECT Id, Title, FileExtension FROM ContentDocument WHERE Id IN :contentDocumentIds]);
        for (ContentDocumentLink attachment : trigger.new ) {
            
            ContentDocument thisDoc = allContentDocuments.get(attachment.ContentDocumentId);
            Id caseId = attachment.LinkedEntityId;
            FeedItem post = new FeedItem();
            post.ParentId = caseId; 
            post.Body = '\'' + thisDoc.Title + '\' Attachment added of type: .' + thisDoc.FileExtension;
            post.type = 'LinkPost';
            listOfFeedFile.add(post); 
        }
        
        if(listOfFeedFile.size() > 0){
            system.debug('List of file: ' + listOfFeedFile);
            try{
                insert listOfFeedFile;
            }catch(DMLException e){
                System.debug('DML Error occured while creating case feed: ' + e.getMessage());
            }
        }
    }else if(Trigger.isBefore && Trigger.isUpdate){
            system.debug('Version Updated link');
    }
}