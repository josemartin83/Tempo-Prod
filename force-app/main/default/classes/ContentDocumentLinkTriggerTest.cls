@isTest
public class ContentDocumentLinkTriggerTest {
    
    @isTest static void ContentDocumentLinkTriggerTest() {
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Compliance').getRecordTypeId();
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Registered').getRecordTypeId();
        
        // Create an account with an account
        Account thisAccount = new Account(
      RecordTypeId = accRecordTypeId,
      FirstName= 'Test FName',
      LastName='Test LName',
      PersonMailingStreet='test@yahoo.com',
    
      PersonMailingPostalCode='12345',
    
      PersonMailingCity='SFO',
    
      PersonEmail='test@yahoo.com',
    
      PersonHomePhone='1234567',
    
      PersonMobilePhone='12345678' 
    
    );
        
        Case c = new Case();
        c.AccountId = thisAccount.Id;
        c.Type = 'Cloudcheck';
        c.Sub_category__c = 'PEP Match';
        c.Status = 'New';
        c.RecordTypeId = recordTypeId;
        insert c;
        
        // Create a ContentVersion
        ContentVersion ContentVer = new ContentVersion();
        ContentVer.Title = 'My Doc';
        ContentVer.ContentUrl= 'test.com';
        Insert ContentVer;
        
        // Create a ContentDocumentLink
        ContentDocumentLink ContentDL = new ContentDocumentLink();
        ContentDL.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: ContentVer.Id].ContentDocumentId;
        ContentDL.LinkedEntityId=c.id;
        ContentDL.ShareType='V';
        Insert ContentDL;
        
        // Retrieve ? 
        ContentDL = [SELECT Id,ShareType FROM ContentDocumentLink WHERE Id =:ContentDL.Id];
        System.debug('Troll ' + ContentDL.ShareType);
        
        
        // Verify the share type is = i
        System.assertEquals('I',ContentDL.ShareType);   
    }
}