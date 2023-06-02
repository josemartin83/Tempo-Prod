@isTest
public class AWSCalloutTestClass {
    //true callout
    @isTest static void testAWSPostCallout() {
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.Class, new AWSCalloutMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        AWSCallout.callAwsgateway('12345','12345',true, true, true, false);
        //stop test
        Test.stopTest();
    }
    
    //true callout
    @isTest static void testAWSAMLAndNoIDCallout() {
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.Class, new AWSCalloutMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        AWSCallout.callAwsgateway('12345','12345',false, false, false, false);
        //stop test
        Test.stopTest();
    }
    
    //true callout
    @isTest static void testAWSCloudPassORAMLAndNoIDCallout() {
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.Class, new AWSCalloutMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        AWSCallout.callAwsgateway('12345','12345',false, true, false, false);
        //stop test
        Test.stopTest();
    }
    
    //true callout
    @isTest static void testAWSPostLockedFalseCallout() {
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.Class, new AWSCalloutMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        AWSCallout.callAwsgateway('12345','12345',false, false, false, false);
        //stop test
        Test.stopTest();
    }
    
    //false callout
    @isTest static void testAWSPostErrorCallout() {
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.Class, new AWSCalloutMockFaillure()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        AWSCallout.callAwsgateway('12345','12345',true, true, true, false);
        //stop test
        Test.stopTest();
    }

    //false callout
    @isTest static void testAWSPostPDSReceived() {
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.Class, new AWSCalloutMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        AWSCallout.callAwsgateway('12345','12345',false, false, false, true);
        //stop test
        Test.stopTest();
    }
    
    //test Batch
    @isTest static void testAWSCalloutBatch(){
        //create Few Records
        createFewIntegrationLogRecords(5);
        // after the testing stops, assert records were updated properly
        System.assertEquals(5, [SELECT COUNT() FROM Integration_Log__c WHERE (Status_Code__c = 400 OR Status_Code__c = 401) AND Retry__c < 4 AND Type__c = 'AML']);
        //start test
        Test.startTest();
        // callbatch class 
        AWSCalloutBatch awsCalloutBatch = new AWSCalloutBatch();
        Database.executeBatch(awsCalloutBatch);
        //callout mock
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.Class, new AWSCalloutMock()); 
        //stop test
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(0, [SELECT COUNT() FROM Integration_Log__c WHERE (Status_Code__c = 400 OR Status_Code__c = 401) AND Retry__c < 4 AND Type__c = 'AML']);
        
    }
    
    //test Batch
    @isTest static void testAWSCalloutBatchFailure(){
        //create Few Records
        createFewIntegrationLogRecords(5);
        // after the testing stops, assert records were updated properly
        System.assertEquals(5, [SELECT COUNT() FROM Integration_Log__c WHERE (Status_Code__c = 400 OR Status_Code__c = 401) AND Retry__c < 4 AND Type__c = 'AML']);
        //start test
        Test.startTest();
        // callbatch class 
        AWSCalloutBatch awsCalloutBatch = new AWSCalloutBatch();
        Database.executeBatch(awsCalloutBatch);
        //callout mock
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.Class, new AWSCalloutMockFaillure()); 
        //stop test
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(0, [SELECT COUNT() FROM Integration_Log__c WHERE (Status_Code__c = 400 OR Status_Code__c = 401) AND Retry__c < 4 AND Type__c = 'AML']);
        
    }
    
    @isTest static void testAWSCalloutSchedule(){
        Test.startTest();
        // Schedule the test job
        String yearThis = String.valueOf(Date.today().addYears(1).year());
        String jobId = System.schedule('ScheduledApexTest',
            '0 0 0 15 3 ? ' + yearThis, 
            new AWSCalloutSchedular());         
        // Stopping the test will run the job synchronously
        Test.stopTest();
    }
    
    
    public static void createFewIntegrationLogRecords(Integer numberOfRecords){
        List<Integration_Log__c> integrationLogsToInsert = new List<Integration_Log__c>();
        for(Integer i=0; i<numberOfRecords; i++){
            //request body JSON
            JSONGenerator gen = JSON.createGenerator(true);    
            gen.writeStartObject();
            gen.writeStringField('Customer_ID__c', '123' + i);
            gen.writeStringField('On_Boarding_ID__c', '123' + i);
            gen.writeStringField('Transaction_Id__c', '123' + i);
            gen.writeBooleanField('Locked__c', false);
            gen.writeBooleanField('Passed_AML__c', true);
            Integration_Log__c thisIntegrationLog = new Integration_Log__c();
            thisIntegrationLog.Request_JSON__c = gen.getAsString();
            thisIntegrationLog.Retry__c = 3;
            thisIntegrationLog.Status_Code__c = 401;
            thisIntegrationLog.Status__c = 'FAILURE';
            thisIntegrationLog.Type__c = 'AML';
            integrationLogsToInsert.add(thisIntegrationLog);
        }
        
        if(integrationLogsToInsert.size() > 0){
            insert integrationLogsToInsert;
        }
    }
}