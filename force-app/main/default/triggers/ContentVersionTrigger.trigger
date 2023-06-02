trigger ContentVersionTrigger on ContentVersion (After insert, before update) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        //Contents with id variable
        Map<String, ContentVersion> thisContentVersionsToLink = new Map<String, ContentVersion>();
        //get the id
        for(ContentVersion thisContentVersion : Trigger.new){
            if(String.isNotEmpty(thisContentVersion.Id__c)){
                thisContentVersionsToLink.put(thisContentVersion.Id__c, thisContentVersion);
            }
        }
        //check size and create contentDocumentLinks
        if(thisContentVersionsToLink.size() > 0){
            ContentDocumentLinkFromPayload.createContentDocumentLink(thisContentVersionsToLink);
        }
        
    }else if(Trigger.isBefore && Trigger.isUpdate){
    	Map<Id, ContentVersion> oldMap = new Map<Id, ContentVersion>(Trigger.old);
    
        List<Id> contentDocIds = new List<Id>();
        for(ContentVersion thisContentVersion : Trigger.New){
            contentDocIds.add(thisContentVersion.ContentDocumentId);
        }
        
        //get ContentDocumentLinks wtih this Id
        List<ContentDocumentLink> allRelatedDocumentLinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocIds];
        
        System.debug('All related doc links: ' + allRelatedDocumentLinks);
        //get link entity Ids
        List<Id> caseIds = new List<Id>();
        for(ContentDocumentLink thisDocLink : allRelatedDocumentLinks){
            caseIds.add(thisDocLink.LinkedEntityId);
        }
        
        //get cases
        Map<Id, Case> allRelatedCases = new Map<Id, Case>([Select Id  FROM Case WHERE Id IN :caseIds]);
        System.debug('Related Cases: ' + allRelatedCases);
        
        List<FeedItem> listOfFeedFile = new List<FeedItem>();
        if(allRelatedCases.size() > 0){
            for(ContentVersion thisVersion : Trigger.New){
                //old content verison
                ContentVersion oldContentVersion = oldMap.get(thisVersion.Id);
                
                String postBody = '';
                //check new and old contentVersion values
                if(thisVersion.Title != oldContentVersion.Title){
                    postBody = '\'' + oldContentVersion.Title + '\' file name got changed to \'' + thisVersion.Title + '\'. ';
                }
                if(thisVersion.Description != oldContentVersion.Description){
                    postBody += '\nThe description for file \'' + thisVersion.Title + '\'';
                    if(String.isNotEmpty(oldContentVersion.Description)){
                        postBody += ' got changed from \'' + oldContentVersion.Description + '\' to \'' + thisVersion.Description + '\'. ';
                    }else{
                        postBody += ' got changed to \'' + thisVersion.Description + '\'. ';
                    }
                }
                //loop through cases
                for(Case thisCase : allRelatedCases.values()){
                    if(String.isNotEmpty(postBody)){
                        FeedItem post = new FeedItem();
                        post.ParentId = thisCase.Id;
                        post.Body = postBody;
                        post.type = 'LinkPost';
                        listOfFeedFile.add(post);  
                    }
                    
                }
            }
        }
        if(listOfFeedFile.size() > 0){
            system.debug('List of feed file for updated content verison: ' + listOfFeedFile);
            insert listOfFeedFile;
        } 
    }
    
}