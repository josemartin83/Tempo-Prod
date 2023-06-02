trigger ContentDocumentTrigger on ContentDocument (before update, before delete) {
    if(Trigger.isBefore){
        //get contentDocument Ids
        Map<Id,ContentDocument> toBeDeletedContentDocs = new Map<Id,ContentDocument>(Trigger.Old);
        //----------- BEFORE UPDATE -------------------------------------
        Map<Id,ContentVersion> allContentVersions = new Map<Id,ContentVersion>([SELECT Id, ContentUrl, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :toBeDeletedContentDocs.keySet()]);
        Map<Id,ContentVersion> contentDocIdWithVersion = new Map<Id,ContentVersion>();
        for(ContentVersion thisContentVersion : allContentVersions.values()){
            contentDocIdWithVersion.put(thisContentVersion.ContentDocumentId, thisContentVersion);
        }
        //----------- END BEFORE UPDATE ---------------------------------
        
        //get ContentDocumentLinks wtih this Id
        List<ContentDocumentLink> allRelatedDocumentLinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :toBeDeletedContentDocs.keySet()];
        
        //get link entity Ids
        List<Id> caseIds = new List<Id>();
        for(ContentDocumentLink thisDocLink : allRelatedDocumentLinks){
            caseIds.add(thisDocLink.LinkedEntityId);
        }
        
        //get cases
        Map<Id, Case> allRelatedCases = new Map<Id, Case>([Select Id  FROM Case WHERE Id IN :caseIds]);
        
        List<FeedItem> listOfFeedFile = new List<FeedItem>();
        if(allRelatedCases.size() > 0){
            for(ContentDocument thisContentDocument : toBeDeletedContentDocs.values()){
                String postBody = '';
                ContentVersion thisVersion = contentDocIdWithVersion.get(thisContentDocument.Id);
                for(Case thisCase : allRelatedCases.values()){
                    FeedItem post = new FeedItem();
                    post.ParentId = thisCase.Id;
                    if(Trigger.isUpdate){
                        post.Body = ' A new version for file \'' + thisContentDocument.Title + '\' has been uploaded.';
                    }else if(Trigger.isDelete){
                        post.Body = '\'' + thisContentDocument.Title + '\' Attachment got deleted of type: .' + thisContentDocument.FileType; 
                    }
                    post.type = 'LinkPost';
                    listOfFeedFile.add(post); 
                }
            }
        }
        
        if(listOfFeedFile.size() > 0){
            system.debug('List of delete file: ' + listOfFeedFile);
            insert listOfFeedFile;
        }
    }
}