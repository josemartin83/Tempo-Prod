trigger TroveAWSCallout on AcctUnlocked__e(after insert) {
       if(Trigger.isAfter){
        if(Trigger.isInsert){
            Map<String, String> integrationLogData = new Map<String, String>();
         for (AcctUnlocked__e saws : Trigger.new)
            {
                String jsonAsString = AWSCallout.callAwsgateway(saws.Customer_ID__c,saws.Transaction_Id__c,saws.Locked__c,saws.cloudcheck_pass__c,saws.Passed_AML__c, saws.PDS_Received__c);
                //create list of Ids to pass into the Future method callout
                List<Id> integrationLogIds = new List<Id>();
                integrationLogData.put(jsonAsString, 'AML');
            }       
            if(integrationLogData.size() > 0){
                List<Id> integrationLogIds = AWSCallout.initiateIntegrationLog(integrationLogData);
                //send the request - Queueable JOB
                System.enqueueJob(new AWSCalloutQueueable(integrationLogIds));
            }
        }
    }
}