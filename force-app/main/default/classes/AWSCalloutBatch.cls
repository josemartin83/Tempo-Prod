global class AWSCalloutBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator(
            'SELECT Id, Request_JSON__c, Status_Code__c, Status__c, Retry__c, Type__c FROM Integration_Log__c WHERE (Status_Code__c = 400 OR Status_Code__c = 401) AND Retry__c < 4 AND Type__c = \'AML\''
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Integration_Log__c> scope){
        //create list of Ids to pass into the Future method callout
        List<Id> integrationLogIds = new List<Id>();
        
        // process each batch of records
        for(Integration_Log__c thisIntegrationLog : scope){
            System.debug('Callout from Batch');
            integrationLogIds.add(thisIntegrationLog.Id);
        }
        
        //check list size and call the Future method callout
        if(integrationLogIds.size() > 0){
            //send the request - Queueable JOB
        	System.enqueueJob(new AWSCalloutQueueable(integrationLogIds));
        }
    } 
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}