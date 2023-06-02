public class ContentDocumentLinkFromPayload {
    public static void createContentDocumentLink(Map<String, ContentVersion> contentVersionsToLink){
        Map<String, String> accountAndContentVersionMap = new Map<String, String>();
        //get all the accounts
        List<Account> allAccounts = [SELECT Id, Customer_ID__c FROM Account WHERE (Customer_ID__c IN :contentVersionsToLink.keySet())];
        //loop through all the account and create a map with content version
        for(Account thisAccount : allAccounts){
            if(String.isNotEmpty(thisAccount.Customer_ID__c) && contentVersionsToLink.containsKey(thisAccount.Customer_ID__c)){
                ContentVersion thisContentVersion = contentVersionsToLink.get(thisAccount.Customer_ID__c);
                accountAndContentVersionMap.put(thisAccount.Id, thisContentVersion.ContentDocumentId);
            }
        }
        //loop through map and create ContentDocumentLink
        List<ContentDocumentLink> cdlToCreate = new List<ContentDocumentLink>();
        for(String thisAccountId : accountAndContentVersionMap.keySet()){
            ContentDocumentLink thisContentDocumentLink = new ContentDocumentLink();
            thisContentDocumentLink.LinkedEntityId = thisAccountId;
            thisContentDocumentLink.ContentDocumentId = accountAndContentVersionMap.get(thisAccountId);
            thisContentDocumentLink.Visibility = 'AllUsers';
            cdlToCreate.add(thisContentDocumentLink);
        }
        if(cdlToCreate.size() > 0){
            insert cdlToCreate;
        }
    }
}