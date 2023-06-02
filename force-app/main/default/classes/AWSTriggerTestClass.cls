@isTest
public class AWSTriggerTestClass {
    @isTest static void testEvent(){
        //init platform event
        AcctUnlocked__e amlEvent = new AcctUnlocked__e(Customer_ID__c = '12345',Transaction_Id__c='12345',Passed_AML__c = true, Locked__c = true, cloudcheck_pass__c = true, NoID_Email_Sent__c = true);
        
        //Test
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.Class, new AWSCalloutMock()); 
        Database.SaveResult sr = EventBus.publish(amlEvent);            
        Test.stopTest();
                
        // Perform validations here
        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());
    }
    
    @isTest static void testPersonDetailChangeEvent(){
        //init platform event
        Person_Detail_Change__e personDetailChange = new Person_Detail_Change__e();
        personDetailChange.Customer_ID__c = '12345';
        personDetailChange.First_Name__c = 'First Name change';
        personDetailChange.Last_Name__c = 'Last Name change';
        //personDetailChange.Salutation__c = 'Salutation Name change';
        //personDetailChange.Email__c = 'Email address change';
        personDetailChange.IRD_Number__c = '111';
        personDetailChange.City__c = 'Wellington';
        personDetailChange.Country__c = 'New Zealand';
        personDetailChange.Mobile_Number__c = '12345689'; 
        personDetailChange.PIR__c = '345';
        personDetailChange.Postal_Code__c = 1234;
        //personDetailChange.Salary__c = 1243;
        personDetailChange.Suburb__c = 'Wellington';
        personDetailChange.Street__c = 'Te Aro'; 
        
        
        //Test
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.Class, new AWSCalloutMock()); 
        Database.SaveResult sr = EventBus.publish(personDetailChange);            
        Test.stopTest();
                
        // Perform validations here
        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());
    }
    
    /*@isTest static void testInvalidEvent(){
        //init platform event
        AcctUnlocked__e amlEvent = new AcctUnlocked__e(Customer_ID__c = '12345');
        
        //Test
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.Class, new AWSCalloutMock()); 
        Database.SaveResult sr = EventBus.publish(amlEvent);            
        Test.stopTest();
                
        // Perform validations here
        // Verify SaveResult value
        System.assertEquals(false, sr.isSuccess());
    }*/
}