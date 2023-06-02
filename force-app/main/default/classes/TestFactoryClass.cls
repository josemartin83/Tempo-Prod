@isTest
public class TestFactoryClass {
    public static User generateUserWithContact(){
        //create profile
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        //create user
        User u = new User(Alias = 'newuser', Email = 'newUser@myorg.com', 
          EmailEncodingKey='UTF-8',FirstName='UserFirstName', LastName='UserLastName', LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = p.Id, 
          TimeZoneSidKey='America/New_York', UserName='newuser@trovemoney.co.nz');
        insert u;  

        //Insert Contact
        Contact con = new Contact();
        con.lastname = 'test';
        con.OwnerId = u.Id;
        insert con;
        //return user
        return u;
    }
    //get single case
    public static Case getSingleCase(String caseOrigin, Boolean assignCaseTeams, Boolean singleCaseTeamAssignment){
        //create user and contact method
        User u = generateUserWithContact();
        Id usersContactId = u.ContactId;
        //create and return case
        Case thisCase = new Case();
        thisCase.Subject = 'Subject';
        thisCase.Description = 'Description';
        thisCase.Priority = 'Low';
        thisCase.Origin = caseOrigin;
        thisCase.Type = 'Technical Support';
        thisCase.Status = 'New';
        thisCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Compliance').getRecordTypeId();
        System.debug('Record tpye Id:' + thisCase.RecordTypeId);
        if(assignCaseTeams){
            thisCase.Team_Assignment__c = 'CRM;Data';
        }else if(singleCaseTeamAssignment){
            thisCase.Team_Assignment__c = 'CRM';
        }
        thisCase.ContactId = usersContactId;
        thisCase.OwnerId = u.Id;
        insert thisCase;
        return thisCase;
    }
    
    //get bulk cases
    public static List<Case> getBulkCases(Integer numberOfCases, String caseOrigin, Boolean assignCaseTeams){
        List<Case> casesToInsert = new List<Case>();
        Id complianceRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Compliance').getRecordTypeId();
        //create user and contact method
        User u = generateUserWithContact();
        Id usersContactId = u.ContactId;
        for(Integer i=0; i<numberOfCases; i++){
           //create cases
            Case thisCase = new Case();
            thisCase.Subject = 'Subject';
            thisCase.Description = 'Description';
            thisCase.Priority = 'Low';
            thisCase.Origin = caseOrigin;
            thisCase.Type = 'Technical Support';
            thisCase.Status = 'New';
            thisCase.RecordTypeId = complianceRecordTypeId;
            System.debug('Record tpye Id:' + thisCase.RecordTypeId);
            if(assignCaseTeams){
                thisCase.Team_Assignment__c = 'CRM;Data;';
            }
            thisCase.ContactId = usersContactId;
            thisCase.OwnerId = u.Id;
            casesToInsert.add(thisCase);
         }
        insert casesToInsert;
        return casesToInsert;
    }
}