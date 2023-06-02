@isTest
public class ContentVersionTriggerTestClass {
    @isTest static void createAndUpdateContentVersion(){
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        
        Case thisNewCase = new Case(Subject = '1234', Description = 'This is a description', RecordTypeId = recordTypeId, Status = 'New', Priority = 'High', Origin = 'Email', Type = 'Technical Support', Sub_Category__c = 'App Password Issue');
        insert thisNewCase;
        
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.ShareType= 'C';
        contentlink.LinkedEntityId = thisNewCase.Id; 
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        ContentVersion thisCv = [SELECT Id, Title FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        thisCv.Title = 'ABCD';
        update thisCv;
        
        //new Content Version for REST API payload
        //person account
        String recordTypeId2  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        Account acc= new Account(
          RecordTypeID=recordTypeId2 ,
          Name = 'Account 1234',
          Customer_ID__c = '1234'
        );
        
        Account acc2 = new Account(
          RecordTypeID=recordTypeId2 ,
          Name = 'Account 1234'
        );
        
        List<Account> accsToinsert = new List<Account>();
        accsToinsert.add(acc);
        accsToinsert.add(acc2);
        
        insert accsToinsert;

        ContentVersion cv1 = new ContentVersion();
        cv1.Title='ABC';
        cv1.PathOnClient='test';
        cv1.VersionData=EncodingUtil.base64Decode('Unit test attachment body');
        cv1.Id__c = '1234';
        
        ContentVersion cv2 = new ContentVersion();
        cv2.Title='ABC2';
        cv2.PathOnClient='test2';
        cv2.VersionData=EncodingUtil.base64Decode('Unit test attachment body2');
        cv2.Id__c = '1334';
        
        List<ContentVersion> cvToInsert = new List<ContentVersion>();
        cvToInsert.add(cv1);
        cvToInsert.add(cv2);
        insert cvToInsert;
        
    }
}