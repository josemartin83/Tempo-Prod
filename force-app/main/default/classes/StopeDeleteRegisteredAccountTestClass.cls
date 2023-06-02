@istest
public class StopeDeleteRegisteredAccountTestClass 
{
       static testmethod void Testaccount()
             {
  
        
                 Account a = new account();
                         string RecId = [SELECT id FROM RecordType WHERE SobjectType = 'Account' and Name = 'Registered'].Id;
                         a.FirstName ='FirstName';
                         a.LastName = 'LastName';
                         a.Cloudcheck_Pass__c = True;
                         a.PersonEmail = 'first.last@trovemoney.co.nz';
                         a.RecordTypeId = RecId ;
                         a.Customer_ID__c = '68y796fjdbjASDDUSBhdaiy3';
                         a.Locked__c = False;
                         
                         Profile p = [SELECT Id FROM Profile WHERE Name='Customer Service User'];
                         
                         test.startTest();
                         // Set mock callout class 
                         Test.setMock(HttpCalloutMock.Class, new AWSCalloutMock()); 
            
                         insert a;
                         try
                         {
                           delete a;
                         }
                         catch(Exception e)
                         {
                         system.assertEquals('You only can delete potential customer, Not registered!!!', e.getMessage());   
                         }
                         Test.stopTest();
               }
}