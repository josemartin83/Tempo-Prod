@isTest
public class PersonDetailChangeTestClass {

    @isTest static void testPersonDetailChangeTrigger(){
        //init platform event
        Person_Detail_Change__e personDetailChange = new Person_Detail_Change__e();
        personDetailChange.Customer_ID__c = '12345';
        personDetailChange.First_Name__c = 'First Name change';
        personDetailChange.Last_Name__c = 'Last Name change';
        personDetailChange.IRD_Number__c = '111-222-333';
        personDetailChange.City__c = 'Wellington';
        personDetailChange.Country__c = 'New Zealand';
        personDetailChange.Mobile_Number__c = '12345689'; 
        personDetailChange.PIR__c = '345';
        personDetailChange.Postal_Code__c = 1234;
        personDetailChange.Suburb__c = 'Wellington';
        personDetailChange.Street__c = 'Te Aro'; 
        personDetailChange.Bank_Name__c = 'Bank Name'; 
        personDetailChange.Bank_Number__c = '234323'; 
        personDetailChange.Bank_Status__c = 'pass';
        personDetailChange.Account_Nickname__c = 'Malde';
        personDetailChange.Close_Request__c = 'true';
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
    
    @isTest static void testAccountImpactOnPersonDetailChange(){
        Id devRecordTypeId = [SELECT Id FROM RecordType WHERE IsPersonType = TRUE AND SObjectType='Account' LIMIT 1].Id;
        Account thisAccount = new Account();
        thisAccount.Customer_ID__c = '12345';
        thisAccount.FirstName = 'First Name of new Account';
        thisAccount.LastName = 'Last Name of new Account';
        thisAccount.PersonMobilePhone = '1234566';
        thisAccount.IRD_Number__c = '324-235-111';
        thisAccount.PIR__c = '123PIR';
        thisAccount.Bank_Provided_Name_Akahu__c = 'Person Bank Name';
        thisAccount.Bank_Account_Number_Akahu__c = '112233';
        thisAccount.Account_Nickname__c = 'Malde';
        //thisAccount.Akahu_Status__c = 'Malde';
        thisAccount.Mailing_Street__c = 'Te Aro';
        thisAccount.Mailing_Suburb__c = 'Wellington';
        thisAccount.Mailing_City__c = 'Wellington';
        thisAccount.Mailing_Country__c = 'NZ';
        thisAccount.Mailing_Post_Zip__c = '1234';
        thisAccount.RecordTypeId = devRecordTypeId;
       
        insert thisAccount;
     
        Account accountToUpdate = [SELECT Id, Customer_ID__c, FirstName, LastName, Phone, IRD_Number__c, PIR__c, BillingStreet, BillingState, BillingCity, BillingCountry, BillingPostalCode, Income__c FROM Account WHERE Id = :thisAccount.Id];
        accountToUpdate.FirstName = 'Updated firstName.';
        accountToUpdate.LastName = 'Upadated LastName';
        accountToUpdate.PersonMobilePhone = '123456678';
        accountToUpdate.IRD_Number__c = '322-987-435';
        accountToUpdate.PIR__c = '123PWR';
        accountToUpdate.Mailing_Street__c = 'Te Aro Auck';
        accountToUpdate.Mailing_City__c  = 'Auckland';
        accountToUpdate.Mailing_Country__c = 'New Zealand';
        accountToUpdate.Mailing_Post_Zip__c = '12344';
        accountToUpdate.Mailing_Suburb__c = '12344';
        Test.startTest();
        Test.setMock(HttpCalloutMock.Class, new AWSCalloutMock());
        update accountToUpdate;
        Test.stopTest();
    }

    // @isTest static void testCreateJSONExtraValues(){
    //     Person_Detail_Change__e personDetailChange = new Person_Detail_Change__e();
    //     personDetailChange.Customer_ID__c = '12345';
    //     personDetailChange.First_Name__c = 'First Name change';
    //     personDetailChange.Last_Name__c = 'Last Name change';
    //     personDetailChange.IRD_Number__c = '111-222-333';
    //     personDetailChange.Mobile_Number__c = '12345689'; 
    //     personDetailChange.PIR__c = '345';
     
    //     Test.startTest();

    //     String json = AWSCallout.personDetailsChangeCallout(personDetailChange);
    //     Test.stopTest();
    //       String expectedJSON = '{"Customer_ID__c":"12345","First_Name__c":"First Name change","Last_Name__c":"Last Name change","IRD_Number__c":"111-222-333","Mobile_Number__c":"12345689","PIR__c":"345"}';

    //     System.assert(json.contains(personDetailChange.Customer_ID__c));
    //     System.assert(json.contains(personDetailChange.First_Name__c));
    //     System.assert(json.contains(personDetailChange.Last_Name__c));
    //     System.assert(json.contains(personDetailChange.IRD_Number__c));
    //     System.assert(json.contains(personDetailChange.Mobile_Number__c));
    //     System.assert(json.contains(personDetailChange.PIR__c));
    // }

    @isTest static void testPopulatingChangedIdDriverLicenceFields(){
        Id devRecordTypeId = [SELECT Id FROM RecordType WHERE IsPersonType = TRUE AND SObjectType='Account' LIMIT 1].Id;
        Account oldAccount = new Account();
        oldAccount.Customer_ID__c = '12345';
        oldAccount.Id_First_Name__c = 'First Name of new Account';
        oldAccount.Id_Middle_Name__c = 'Middle Name of new Account';
        oldAccount.Id_Last_Name__c = 'Last Name of new Account';
        oldAccount.LastName = 'Last Name of new Account';
        oldAccount.PersonMobilePhone = '1234566';
        oldAccount.IRD_Number__c = '324-235-111';
        oldAccount.PIR__c = '123PIR';
        oldAccount.Bank_Provided_Name_Akahu__c = 'Person Bank Name';
        oldAccount.Bank_Account_Number_Akahu__c = '112233';
        oldAccount.Account_Nickname__c = 'Malde';
        oldAccount.Mailing_Street__c = 'Te Aro';
        oldAccount.Mailing_Suburb__c = 'Wellington';
        oldAccount.Mailing_City__c = 'Wellington';
        oldAccount.Mailing_Country__c = 'NZ';
        oldAccount.Mailing_Post_Zip__c = '1234';
        oldAccount.RecordTypeId = devRecordTypeId;
        oldAccount.ID_Type__c = 'Passport';
        oldAccount.ID_Number__c = 'ABC123';
        oldAccount.ID_Expiry_Date__c = SYSTEM.today();
        oldAccount.ID_Version__c = '605';
        oldAccount.PersonBirthdate = SYSTEM.today();
       
        insert oldAccount;
        Id oldAccountId = [SELECT Id FROM Account WHERE IsPersonAccount = TRUE LIMIT 1].Id;

        Map<Id, Account> oldAccountMap = new Map<Id, Account>();
        oldAccountMap.put(oldAccountId, oldAccount);

        Account newAccount = new Account();
        newAccount.Id = oldAccountId;
        newAccount.Customer_ID__c = '12345';
        newAccount.Id_First_Name__c = 'First Name of new Account';
        newAccount.Id_Middle_Name__c = 'Middle Name of new Account';
        newAccount.Id_Last_Name__c = 'Last Name of new Account';
        newAccount.LastName = 'Last Name of new Account';
        newAccount.PersonMobilePhone = '1234566';
        newAccount.IRD_Number__c = '324-235-111';
        newAccount.PIR__c = '123PIR';
        newAccount.Bank_Provided_Name_Akahu__c = 'Person Bank Name';
        newAccount.Bank_Account_Number_Akahu__c = '112233';
        newAccount.Account_Nickname__c = 'Malde';
        newAccount.Mailing_Street__c = 'Te Aro';
        newAccount.Mailing_Suburb__c = 'Wellington';
        newAccount.Mailing_City__c = 'Wellington';
        newAccount.Mailing_Country__c = 'NZ';
        newAccount.Mailing_Post_Zip__c = '1234';
        newAccount.RecordTypeId = devRecordTypeId;
        // only ID Type has been changed
        newAccount.ID_Type__c = 'Driver Licence';
        newAccount.ID_Number__c = 'ABC123';
        newAccount.ID_Expiry_Date__c = SYSTEM.today();
        newAccount.ID_Version__c = '605';
        newAccount.PersonBirthdate = SYSTEM.today();

        List<Account> listOfChangedAccounts = new List<Account>{newAccount};

        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.Class, new AWSCalloutMock()); 
        List<Person_Detail_Change__e> pdeList =  PersonAccountTriggerHandler.generatePlatformEvent(listOfChangedAccounts, oldAccountMap);

        Test.stopTest();
        System.assertEquals(1,pdeList.size());
        System.assertEquals(newAccount.Customer_ID__c, pdeList[0].Customer_ID__c);
        System.assertEquals(newAccount.Mailing_City__c, pdeList[0].City__c);
        System.assertEquals(newAccount.Mailing_Country__c, pdeList[0].Country__c);
        System.assertEquals(newAccount.Mailing_Post_Zip__c, String.valueOf(pdeList[0].Postal_Code__c));
        System.assertEquals(newAccount.Mailing_Suburb__c, pdeList[0].Suburb__c);
        System.assertEquals(newAccount.Mailing_Street__c, pdeList[0].Street__c);
        System.assertEquals(newAccount.ID_Type__c, pdeList[0].ID_Type__c);
        System.assertEquals(newAccount.ID_Number__c, pdeList[0].ID_Number__c);
        System.assertEquals(newAccount.ID_Version__c, pdeList[0].ID_Version__c);
        System.assertEquals(newAccount.PersonBirthdate, pdeList[0].Birthdate__c);

        // Drivers License Type does not pass the expiry date
        System.assert(String.isBlank(String.valueOf(pdeList[0].ID_Expiry_Date__c)));
    }

    @isTest static void testPopulatingChangedIdPassportFields(){
        Id devRecordTypeId = [SELECT Id FROM RecordType WHERE IsPersonType = TRUE AND SObjectType='Account' LIMIT 1].Id;
        Account oldAccount = new Account();
        oldAccount.Customer_ID__c = '12345';
        oldAccount.Id_First_Name__c = 'First Name of new Account';
        oldAccount.Id_Middle_Name__c = 'Middle Name of new Account';
        oldAccount.Id_Last_Name__c = 'Last Name of new Account';
        oldAccount.LastName = 'Last Name of new Account';
        oldAccount.PersonMobilePhone = '1234566';
        oldAccount.IRD_Number__c = '324-235-111';
        oldAccount.PIR__c = '123PIR';
        oldAccount.Bank_Provided_Name_Akahu__c = 'Person Bank Name';
        oldAccount.Bank_Account_Number_Akahu__c = '112233';
        oldAccount.Account_Nickname__c = 'Malde';
        oldAccount.Mailing_Street__c = 'Te Aro';
        oldAccount.Mailing_Suburb__c = 'Wellington';
        oldAccount.Mailing_City__c = 'Wellington';
        oldAccount.Mailing_Country__c = 'NZ';
        oldAccount.Mailing_Post_Zip__c = '1234';
        oldAccount.RecordTypeId = devRecordTypeId;
        oldAccount.ID_Type__c = 'Driver Licence';
        oldAccount.ID_Number__c = 'ABC123';
        oldAccount.ID_Expiry_Date__c = SYSTEM.today();
        oldAccount.ID_Version__c = '605';
        oldAccount.PersonBirthdate = SYSTEM.today();
       
        insert oldAccount;
        Id oldAccountId = [SELECT Id FROM Account WHERE IsPersonAccount = TRUE LIMIT 1].Id;

        Map<Id, Account> oldAccountMap = new Map<Id, Account>();
        oldAccountMap.put(oldAccountId, oldAccount);

        Account newAccount = new Account();
        newAccount.Id = oldAccountId;
        newAccount.Customer_ID__c = '12345';
        newAccount.Id_First_Name__c = 'First Name of new Account';
        newAccount.Id_Middle_Name__c = 'Middle Name of new Account';
        newAccount.Id_Last_Name__c = 'Last Name of new Account';
        newAccount.LastName = 'Last Name of new Account';
        newAccount.PersonMobilePhone = '1234566';
        newAccount.IRD_Number__c = '324-235-111';
        newAccount.PIR__c = '123PIR';
        newAccount.Bank_Provided_Name_Akahu__c = 'Person Bank Name';
        newAccount.Bank_Account_Number_Akahu__c = '112233';
        newAccount.Account_Nickname__c = 'Malde';
        newAccount.Mailing_Street__c = 'Te Aro';
        newAccount.Mailing_Suburb__c = 'Wellington';
        newAccount.Mailing_City__c = 'Wellington';
        newAccount.Mailing_Country__c = 'NZ';
        newAccount.Mailing_Post_Zip__c = '1234';
        newAccount.RecordTypeId = devRecordTypeId;
        // only ID Type has been changed
        newAccount.ID_Type__c = 'Passport';
        newAccount.ID_Number__c = 'ABC123';
        newAccount.ID_Expiry_Date__c = SYSTEM.today();
        newAccount.ID_Version__c = '605';
        newAccount.PersonBirthdate = SYSTEM.today();

        List<Account> listOfChangedAccounts = new List<Account>{newAccount};

        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.Class, new AWSCalloutMock()); 

        List<Person_Detail_Change__e> pdeList =  PersonAccountTriggerHandler.generatePlatformEvent(listOfChangedAccounts, oldAccountMap);

        Test.stopTest();
        System.assertEquals(1,pdeList.size());
        System.assertEquals(newAccount.Customer_ID__c, pdeList[0].Customer_ID__c);
        System.assertEquals(newAccount.Mailing_City__c, pdeList[0].City__c);
        System.assertEquals(newAccount.Mailing_Country__c, pdeList[0].Country__c);
        System.assertEquals(newAccount.Mailing_Post_Zip__c, String.valueOf(pdeList[0].Postal_Code__c));
        System.assertEquals(newAccount.Mailing_Suburb__c, pdeList[0].Suburb__c);
        System.assertEquals(newAccount.Mailing_Street__c, pdeList[0].Street__c);
        System.assertEquals(newAccount.ID_Type__c, pdeList[0].ID_Type__c);
        System.assertEquals(newAccount.ID_Number__c, pdeList[0].ID_Number__c);
        System.assertEquals(newAccount.ID_Expiry_Date__c, pdeList[0].ID_Expiry_Date__c);
        System.assertEquals(newAccount.PersonBirthdate, pdeList[0].Birthdate__c);

        // Passport Type does not pass the version number
        System.assert(String.isBlank(pdeList[0].ID_Version__c));
    }
}