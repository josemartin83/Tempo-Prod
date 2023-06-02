@isTest
public class CaseTriggerHandlerTestClass {
    //insert case without Team Assigment
	@isTest static void ValidateSingleCaseWithoutCaseTeamInsert() {
        Case thisCase;
        List<CaseTeamTemplateRecord> assignedCaseTeamRecords;
        TestFactoryClass.getSingleCase('Phone', false, false);
        Test.startTest();
        thisCase = [SELECT Id FROM Case];
        assignedCaseTeamRecords = [select Id, ParentId, TeamTemplate.Name from CaseTeamTemplateRecord where ParentId = :thisCase.Id];
        Test.stopTest();
        System.assertEquals(0, assignedCaseTeamRecords.size(), 'Was expecting to find no cases assigned');
     }
    
    //insert case with Team Assigment
	@isTest static void ValidateSingleCaseWithCaseTeamInsert() {
        Case thisCase;
        List<CaseTeamTemplateRecord> assignedCaseTeamRecords;
        TestFactoryClass.getSingleCase('Phone', true, false);
        Test.startTest();
        thisCase = [SELECT Id FROM Case];
        assignedCaseTeamRecords = [select Id, ParentId, TeamTemplate.Name from CaseTeamTemplateRecord where ParentId = :thisCase.Id];
        Test.stopTest();
        System.assertEquals(2, assignedCaseTeamRecords.size(), 'Was expecting to find 2 cases assigned');
     }
    
    //update case with multiple case Team Assigment
	@isTest static void ValidateSingleCaseWithCaseTeamsUpdate() {
        Case thisCase;
        List<CaseTeamTemplateRecord> assignedCaseTeamRecords;
        TestFactoryClass.getSingleCase('Phone', false, false);
        Test.startTest();
        thisCase = [SELECT Id FROM Case];
        thisCase.Team_Assignment__c = 'Data;Customer Support;CRM';
        update thisCase;
        assignedCaseTeamRecords = [select Id, ParentId, TeamTemplate.Name from CaseTeamTemplateRecord where ParentId = :thisCase.Id];
        Test.stopTest();
        System.assertEquals(3, assignedCaseTeamRecords.size(), 'Was expecting to find 3 cases assigned');
     }
    
    //update case with single Team Assigment
	@isTest static void ValidateSingleCaseWithCaseTeamUpdate() {
        Case thisCase;
        List<CaseTeamTemplateRecord> assignedCaseTeamRecords;
        TestFactoryClass.getSingleCase('Phone', false, false);
        Test.startTest();
        thisCase = [SELECT Id FROM Case];
        thisCase.Team_Assignment__c = 'Data';
        update thisCase;
        assignedCaseTeamRecords = [select Id, ParentId, TeamTemplate.Name from CaseTeamTemplateRecord where ParentId = :thisCase.Id];
        Test.stopTest();
        System.assertEquals(1, assignedCaseTeamRecords.size(), 'Was expecting to find 1 cases assigned');
     }
    
    //update case with different Team Assigment
	@isTest static void ValidateSingleCaseWithDifferentCaseTeamUpdate() {
        Case thisCase;
        List<CaseTeamTemplateRecord> assignedCaseTeamRecords;
        TestFactoryClass.getSingleCase('Phone', true, false);
        Test.startTest();
        thisCase = [SELECT Id FROM Case];
        thisCase.Team_Assignment__c = 'Customer Support';
        update thisCase;
        assignedCaseTeamRecords = [select Id, ParentId, TeamTemplate.Name from CaseTeamTemplateRecord where ParentId = :thisCase.Id];
        Test.stopTest();
        System.assertEquals(1, assignedCaseTeamRecords.size(), 'Was expecting to find 1 cases assigned');
     }
    
    //update case with extra Team Assigment
	@isTest static void ValidateSingleCaseWithExtraCaseTeamUpdate() {
        Case thisCase;
        List<CaseTeamTemplateRecord> assignedCaseTeamRecords;
        TestFactoryClass.getSingleCase('Phone', false, false);
        Test.startTest();
        thisCase = [SELECT Id FROM Case];
        thisCase.Team_Assignment__c = 'CRM;Data;Customer Support';
        update thisCase;
        assignedCaseTeamRecords = [select Id, ParentId, TeamTemplate.Name from CaseTeamTemplateRecord where ParentId = :thisCase.Id];
        Test.stopTest();
        System.assertEquals(3, assignedCaseTeamRecords.size(), 'Was expecting to find 3 cases assigned');
     }
    
    //update case with some removed Team Assigment
	@isTest static void ValidateSingleCaseWithSomeRemovedCaseTeamUpdate() {
        Case thisCase;
        List<CaseTeamTemplateRecord> assignedCaseTeamRecords;
        TestFactoryClass.getSingleCase('Phone', true, false);
        Test.startTest();
        thisCase = [SELECT Id FROM Case];
        thisCase.Team_Assignment__c = 'CRM';
        update thisCase;
        assignedCaseTeamRecords = [select Id, ParentId, TeamTemplate.Name from CaseTeamTemplateRecord where ParentId = :thisCase.Id];
        Test.stopTest();
        System.assertEquals(1, assignedCaseTeamRecords.size(), 'Was expecting to find 1 cases assigned');
     }
    
    //update case with Single Team Assigment
	@isTest static void ValidateSingleCaseWithSingleCaseTeamUpdate() {
        Case thisCase;
        List<CaseTeamTemplateRecord> assignedCaseTeamRecords;
        TestFactoryClass.getSingleCase('Phone', false, true);
        Test.startTest();
        thisCase = [SELECT Id FROM Case];
        thisCase.Team_Assignment__c = 'Customer Support';
        update thisCase;
        assignedCaseTeamRecords = [select Id, ParentId, TeamTemplate.Name from CaseTeamTemplateRecord where ParentId = :thisCase.Id];
        Test.stopTest();
        System.assertEquals(1, assignedCaseTeamRecords.size(), 'Was expecting to find 1 cases assigned');
     }
    
    //update case with no team Assigment
	@isTest static void ValidateSingleCaseWithNoCaseTeamUpdate() {
        Case thisCase;
        List<CaseTeamTemplateRecord> assignedCaseTeamRecords;
        TestFactoryClass.getSingleCase('Phone', false, true);
        Test.startTest();
        thisCase = [SELECT Id FROM Case];
        thisCase.Team_Assignment__c = '';
        update thisCase;
        assignedCaseTeamRecords = [select Id, ParentId, TeamTemplate.Name from CaseTeamTemplateRecord where ParentId = :thisCase.Id];
        Test.stopTest();
        System.assertEquals(0, assignedCaseTeamRecords.size(), 'Was expecting to find 0 cases assigned');
     }
    
    //Case with team member
    @isTest static void ValidateCaseWithTeamMember(){
        Case returnedCase = TestFactoryClass.getSingleCase('Phone', false, true);
        User usersContact = [SELECT Id, ContactId FROM User WHERE Name = 'UserFirstName UserLastName'];
        Map<Id, CaseTeamTemplate> caseTeamTemplates = new Map<Id, CaseTeamTemplate>([SELECT Id, Name FROM CaseTeamTemplate]);
        
        List<String> otherTeams = new List<String>();
        otherTeams.add('FB Compliance');
        otherTeams.add('Data');
       	
        Test.startTest();
        List<User> usersInOrg =[SELECT Id, ContactId FROM User];
     	Map<Id,User> userMap = new Map<Id,User>(usersInOrg);
    	List<Id> caseIds = new List<Id>();
        caseIds.add(returnedCase.Id);
        CaseTeamRole role = [select Id from CaseTeamRole where Name = 'CRM' limit 1];
        insert new CaseTeamMember(ParentId = returnedCase.Id, MemberId = usersContact.Id, TeamRoleId = role.Id);
        CaseTriggerHandler.sendEmailAlertToCaseTeams(caseIds, new List<String>(), new Map<Id, CaseTeamTemplate>());
        Test.stopTest();
    
        List<CaseTeamMember> oldUserCtms = [SELECT Id, MemberId, ParentId FROM CaseTeamMember WHERE MemberId = :usersContact.Id AND ParentId = :returnedCase.Id];
        System.assertEquals(1, oldUserCtms.size(), 'New user should have 1 CaseTeamMember.');
    }
    
    
    
    //Bulk insert case with Team Assigment
	@isTest static void ValidateSingleCaseWithCaseTeamBulkInsert() {
        List<Case> thisCases;
        List<Id> caseIds = new List<Id>();
        List<CaseTeamTemplateRecord> assignedCaseTeamRecords;
        TestFactoryClass.getBulkCases(10, 'Phone', true);
        Test.startTest();
        thisCases = [SELECT Id, Team_Assignment__c FROM Case];
        for(Case thisCase : thisCases){
            caseIds.add(thisCase.Id);
        }
        assignedCaseTeamRecords = [select Id, ParentId, TeamTemplate.Name from CaseTeamTemplateRecord where ParentId = :caseIds];
        CaseTriggerHandler.assignDefaultTeamsAfterInsert(thisCases);
        CaseTriggerHandler.sendEmailAlertToCaseTeams(caseIds, new List<String>(), new Map<Id, CaseTeamTemplate>());
        Test.stopTest();
        System.assertEquals(10, thisCases.size(), 'Was expecting to find 10 cases inserted');
        System.assertEquals(20, assignedCaseTeamRecords.size(), 'Was expecting to find 20 cases assigned');
     }
    
    /*//Bulk update case with Team Assigment
	@isTest static void ValidateSingleCaseWithCaseTeamBulkUpdate() {
        List<Case> thisCases;
        List<Case> casesToUpdate = new List<Case>();
        List<Id> caseIds = new List<Id>();
        List<CaseTeamTemplateRecord> assignedCaseTeamRecords;
        TestFactoryClass.getBulkCases(10, 'Phone', false);
        Test.startTest();
        thisCases = [SELECT Id, Team_Assignment__c FROM Case];
        for(Case thisCase : thisCases){
            thisCase.Team_Assignment__c = 'Data;CRM';
            casesToUpdate.add(thisCase);
            caseIds.add(thisCase.Id);
        }
        if(casesToUpdate.size() > 0){
            update casesToUpdate;
        }
        assignedCaseTeamRecords = [select Id, ParentId, TeamTemplate.Name from CaseTeamTemplateRecord where ParentId = :caseIds];
        CaseTriggerHandler.assignDefaultTeamsAfterUpdate(casesToUpdate);
        CaseTriggerHandler.sendEmailAlertToCaseTeams(caseIds);
        Test.stopTest();
        System.assertEquals(10, thisCases.size(), 'Was expecting to find 10 cases inserted');
        System.assertEquals(20, assignedCaseTeamRecords.size(), 'Was expecting to find 20 cases assigned');
     }*/
}