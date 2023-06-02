public class AWSCalloutQueueable implements Queueable, Database.AllowsCallouts {
    
    private List<Id> integrationLogIds;
    
    public AWSCalloutQueueable(List<Id> integrationLogIds){
        this.integrationLogIds = integrationLogIds;
    }
    public void execute(QueueableContext context) {
        //update records list
        List<Integration_Log__c> integrationLogsToUpdate = new List<Integration_Log__c>();
        //email records list
        List<Integration_Log__c> integrationLogsForEmail = new List<Integration_Log__c>();
        
        //get Integration Log record
        Map<Id, Integration_Log__c> allIntegrationLogRecordsMap = new Map<Id, Integration_Log__c>([SELECT Id, Request_JSON__c, Status_Code__c, Status__c, Retry__c, Type__c FROM Integration_Log__c WHERE Id IN :integrationLogIds]);
        
        //loop through the records
        for(Id thisIntegrationLogId : allIntegrationLogRecordsMap.keySet()){
            Integration_Log__c thisIntegrationLogRecord = allIntegrationLogRecordsMap.get(thisIntegrationLogId);
            //set http and send the request
            //set http request
            HttpRequest request = new HttpRequest();     
            request.setEndpoint('callout:aws_ingest/aml');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody((String)thisIntegrationLogRecord.Request_JSON__c);
            
            Http http = new Http();
            HttpResponse res = http.send(request);
            
            //check request response
            if(res.getStatusCode() == 202){
                
                //update Integration Log record to SUCCESS
                thisIntegrationLogRecord.Status__c = 'SUCCESS';
                thisIntegrationLogRecord.Status_Code__c = res.getStatusCode();
                integrationLogsToUpdate.add(thisIntegrationLogRecord);
                
            }else{   
                
                //update Integration Log record to FAILURE
                thisIntegrationLogRecord.Status__c = 'FAILURE';
                thisIntegrationLogRecord.Status_Code__c = res.getStatusCode();
                thisIntegrationLogRecord.Retry__c= thisIntegrationLogRecord.Retry__c+1;
                integrationLogsToUpdate.add(thisIntegrationLogRecord);
                
                //add integration logs that have retry = 4
                if(thisIntegrationLogRecord.Retry__c == 4){
                    integrationLogsForEmail.add(thisIntegrationLogRecord);
                }
                
            }
        }
        
        //update integration log records
        if(integrationLogsToUpdate.size() > 0){
           
            update integrationLogsToUpdate;
            
        }
        //send email
        if(integrationLogsForEmail.size() > 0){
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            String[] sendingTo = new String[]{'ramesh.odedra@trovemoney.co.nz'};
                semail.setToAddresses(sendingTo);
            semail.setSubject('Callout Results - Failed Retries');
            String plainTextBody = ' Hi there, ' + ' &nbsp; ';
            plainTextBody += 'Below described is/are the failed records: ';
            
            for(Integration_Log__c thisIntegrationLog : integrationLogsForEmail){
                plainTextBody += ' &nbsp; ';
                plainTextBody += 'Request String: ' + thisIntegrationLog.Request_JSON__c;
                plainTextBody += ' &nbsp; ';
                plainTextBody += 'Response Status: ' + thisIntegrationLog.Status__c;
                plainTextBody += ' &nbsp; ';
                plainTextBody += 'Request Status Code: ' + thisIntegrationLog.Status_Code__c;
                plainTextBody += ' &nbsp; ';
                plainTextBody += 'Number of tries: ' + (Integer)thisIntegrationLog.Retry__c;
            }
            
            plainTextBody += ' &nbsp; ';
            plainTextBody += ' Thank you! Regards, ';
            plainTextBody += ' &nbsp; ';
            plainTextBody += 'Automated Process';
            semail.setPlainTextBody(plainTextBody);
            if(!Test.isRunningTest()){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
            }
        }
    }
}