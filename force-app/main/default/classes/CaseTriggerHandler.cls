public without sharing class CaseTriggerHandler {
    
    public static void assignDefaultTeamsAfterUpdate(List<Case> casesToAssignTeams){
        //get case team templates - used to compare case teams to assign
        Map<Id, CaseTeamTemplate> caseTeamTemplates = new Map<Id, CaseTeamTemplate>([SELECT Id, Name FROM CaseTeamTemplate]);
        //get Case Team Template Records - used to delete case team assignment
        Map<Id, CaseTeamTemplateRecord> caseTeamTemplateRecords = new Map<Id, CaseTeamTemplateRecord>([select Id, ParentId, TeamTemplate.Name from CaseTeamTemplateRecord]);
        //CaseTeams to assign
        List<CaseTeamTemplateRecord> caseTeamsToCreate = new List<CaseTeamTemplateRecord>();
        //CaseTeams to remove
        List<CaseTeamTemplateRecord> caseTeamsToRemove = new List<CaseTeamTemplateRecord>();
        //Case Assignment to remove
        List<Id> caseTeamsAssignmentToRemove = new List<Id>();
        //CaseTeams to NOT send email to
        List<String> caseTeamsToNOTSendEmailTO = new List<String>();
        //Case  Ids
        List<Id> casesToSendEmailTo = new List<Id>();
        //loop through all the cases
        for(Case thisCase : casesToAssignTeams){
            if(Trigger.oldMap.get(thisCase.Id) != null){
                //get old case record
                Case oldCase = (Case)Trigger.oldMap.get(thisCase.Id);
                String oldCaseTeam = oldCase.Team_Assignment__c;
                String newCaseTeam = thisCase.Team_Assignment__c;
                
                //get old lists to remove
                if(String.isNotEmpty(oldCaseTeam)){
                    List<String> oldCaseTeamSplit = new List<String>();
                    if(oldCaseTeam.contains(';')){
                        oldCaseTeamSplit = oldCaseTeam.split(';');
                    }else{
                        oldCaseTeamSplit.add(oldCaseTeam);
                    }
                    
                    //check if the old list team still in new list
                    //else add it to remove list
                    for(String thisOldTeam : oldCaseTeamSplit){
                        if(String.isNotEmpty(newCaseTeam)){
                            if(newCaseTeam.contains(thisOldTeam)){
                                caseTeamsToNOTSendEmailTO.add(thisOldTeam);
                                continue;
                            }else{
                                for(Id caseTeamTemplateRecord : caseTeamTemplateRecords.keySet()){
                                    if(caseTeamTemplateRecords.get(caseTeamTemplateRecord).ParentId == thisCase.Id && caseTeamTemplateRecords.get(caseTeamTemplateRecord).TeamTemplate.Name == thisOldTeam){
                                        caseTeamsToRemove.add(caseTeamTemplateRecords.get(caseTeamTemplateRecord));
                                        caseTeamsAssignmentToRemove.add(thisCase.Id);
                                    }
                                }
                            }  
                        }
                        
                    }
                }
                
                //check if the field is not blank or null
                if(String.isNotEmpty(thisCase.Team_Assignment__c)){
                    if(oldCase.Team_Assignment__c == thisCase.Team_Assignment__c){
                        continue;     
                    }else{
                        //check if multiple values are inserted
                        //manipulate values accordingly
                        String caseTeams = thisCase.Team_Assignment__c;
                        List<String> caseTeamNames = new List<String>();
                        if(caseTeams.contains(';')){
                            caseTeamNames = caseTeams.split(';');   
                        }else{
                            caseTeamNames.add(caseTeams);
                        }
                        //loop through the caseTeams
                        for(String thisCaseTeam : caseTeamNames){
                            
                            if(String.isNotEmpty(oldCaseTeam)){
                                if(oldCaseTeam.contains(thisCaseTeam) && newCaseTeam.contains(thisCaseTeam)){
                                    continue;
                                }else{
                                    //add case team
                                    CaseTeamTemplateRecord returnedTemplateRecord = addCaseTeamAssignment(caseTeamTemplates, thisCase.Id, thisCaseTeam);
                                    caseTeamsToCreate.add(returnedTemplateRecord);
                                    casesToSendEmailTo.add(thisCase.Id);
                                }    
                            }else{
                                //add case team
                                CaseTeamTemplateRecord returnedTemplateRecord = addCaseTeamAssignment(caseTeamTemplates, thisCase.Id, thisCaseTeam);
                                caseTeamsToCreate.add(returnedTemplateRecord);
                                casesToSendEmailTo.add(thisCase.Id);
                            }     
                        }  
                    }
                }else{
                    //remove all case team assignment
                    caseTeamsToRemove = removeCaseTeamAssignment(caseTeamTemplateRecords, thisCase.Id);
                    caseTeamsAssignmentToRemove.add(thisCase.Id);
                }
            }
        }
        if(caseTeamsToCreate.size() > 0){
           //bulk insert
            insert caseTeamsToCreate;
            accountAndContactAccess(caseTeamsToCreate, 'Edit');
        }
        if(caseTeamsToRemove.size() > 0){
            //bulk delete
            delete caseTeamsToRemove;
            accountAndContactAccess(caseTeamsToRemove, 'Read');

        }
        if(casesToSendEmailTo.size() > 0){
            sendEmailAlertToCaseTeams(casesToSendEmailTo, caseTeamsToNOTSendEmailTO, caseTeamTemplates);
         }
    }
    //assignes case teams
    public static void assignDefaultTeamsAfterInsert(List<Case> casesToAssignTeams){
        //get case team templates - used to compare case teams to assign
        Map<Id, CaseTeamTemplate> caseTeamTemplates = new Map<Id, CaseTeamTemplate>([SELECT Id, Name FROM CaseTeamTemplate]);
        //get Case Team Template Records - used to delete case team assignment
        Map<Id, CaseTeamTemplateRecord> caseTeamTemplateRecords = new Map<Id, CaseTeamTemplateRecord>([select Id, ParentId, TeamTemplate.Name from CaseTeamTemplateRecord]);
        //CaseTeams to assign
        List<CaseTeamTemplateRecord> caseTeamsToCreate = new List<CaseTeamTemplateRecord>();
        //CaseTeams to remove
        List<CaseTeamTemplateRecord> caseTeamsToRemove = new List<CaseTeamTemplateRecord>();
        //Case  Ids
        List<Id> casesToSendEmailTo = new List<Id>();
        //loop through all the cases
        for(Case thisCase : casesToAssignTeams){
            if(String.isNotEmpty(thisCase.Team_Assignment__c)){
                //check if multiple values are inserted
                //manipulate values accordingly
                String caseTeams = thisCase.Team_Assignment__c;
                List<String> caseTeamNames = new List<String>();
                if(caseTeams.contains(';')){
                    caseTeamNames = caseTeams.split(';');   
                }else{
                    caseTeamNames.add(caseTeams);
                }
                //loop through the caseTeams
                for(String caseTeam : caseTeamNames){
                    //add case team
                    CaseTeamTemplateRecord returnedTemplateRecord = addCaseTeamAssignment(caseTeamTemplates, thisCase.Id, caseTeam);
                    caseTeamsToCreate.add(returnedTemplateRecord);
                    //mail config
                    casesToSendEmailTo.add(thisCase.Id);
                }       
            }
        }
        try{
            //bulk insert
            insert caseTeamsToCreate;
            accountAndContactAccess(caseTeamsToCreate, 'Edit');
            if(casesToSendEmailTo.size() > 0){
                sendEmailAlertToCaseTeams(casesToSendEmailTo, new List<String>(), new Map<Id, CaseTeamTemplate>());
            }
        }catch(DMLException e){
            System.debug('DML Error occured ' + e.getMessage());
        }
    }
    
    //add case team assignment
    public static CaseTeamTemplateRecord addCaseTeamAssignment(Map<Id, CaseTeamTemplate> caseTeamTemplates, Id caseId, String thisCaseTeam){
        System.debug('Case Team: ' + thisCaseTeam);
        //create a CaseTeamTemplateRecord
        CaseTeamTemplateRecord thisTemplateRecord = new CaseTeamTemplateRecord();
        //Loop through all the caseTeamTemplate
        for(Id caseTeamTemplate : caseTeamTemplates.keySet()){
            if(caseTeamTemplates.get(caseTeamTemplate).Name == thisCaseTeam){
                System.debug('Case Template Name: ' + caseTeamTemplates.get(caseTeamTemplate).Name);
                //assign case ID
                thisTemplateRecord.ParentId = caseId;
                //assign Case Team ID
                thisTemplateRecord.TeamTemplateId = caseTeamTemplate;
            }
        }
        return thisTemplateRecord;
    }
    
    //remove all case team assignment
    public static List<CaseTeamTemplateRecord> removeCaseTeamAssignment(Map<Id, CaseTeamTemplateRecord> caseTeamTemplateRecords, Id caseId){
        List<CaseTeamTemplateRecord> returnTemplate = new List<CaseTeamTemplateRecord>();
        for(Id caseTeamTemplateRecord : caseTeamTemplateRecords.keySet()){
            if(caseTeamTemplateRecords.get(caseTeamTemplateRecord).ParentId == caseId){
                returnTemplate.add(caseTeamTemplateRecords.get(caseTeamTemplateRecord));
            }
        }
        return returnTemplate;
    }
    
    //Give access to Accounts and Contacts
    public static void accountAndContactAccess(List<CaseTeamTemplateRecord> caseTeamTemplateRecords, String shareAccess){
        //Get FB compliance Id
        Id fbComplianceId = [SELECT Id FROM CaseTeamTemplate WHERE Name = 'FB Compliance'].Id;
        //list of ids
        List<Id> caseIds = new List<Id>();
        List<Id> teamTemplateIds = new List<Id>();
        for(CaseTeamTemplateRecord thisTeamTemplate : caseTeamTemplateRecords){
            if(thisTeamTemplate.TeamTemplateId == fbComplianceId){
                caseIds.add(thisTeamTemplate.ParentId);
            }
        }
        System.debug('Account share case IDS: ' + caseIds);
        System.debug('Account share team templates: ' + caseTeamTemplateRecords);
        System.debug('Account share access: ' + shareAccess);
        //Get Account and Contacts of cases
        List<Case> allCasesWithAccAndContacts = [SELECT Id, AccountId, ContactId FROM Case WHERE Id IN :caseIds];
        System.debug('Account share case with acc and contacts: ' + allCasesWithAccAndContacts);
        //Get all the case team templates based on access
        List<AccountShare> allAccountSharesToInsert = new List<AccountShare>();
        if(shareAccess == 'Edit'){
            List<CaseTeamMember> allTeamMembers = [SELECT Id, MemberId, TeamTemplateId, TeamTemplate.Name, Member.Email, ParentId FROM CaseTeamMember where TeamTemplateId = :fbComplianceId AND ParentId IN :caseIds];
            System.debug('Account share team members: ' + allTeamMembers);
            
            for(Case thisCase : allCasesWithAccAndContacts){
                System.debug('1');
                for(CaseTeamMember thisTeamMember : allTeamMembers){
                    System.debug('2');
                    if(thisTeamMember.ParentId == thisCase.Id){
                        System.debug('3');
                        allAccountSharesToInsert.add(shareAccount(thisCase.AccountId, thisTeamMember.MemberId, shareAccess));
                    }               
                }
            }
        }else if(shareAccess == 'Read'){
            List<CaseTeamTemplateMember> allTeamTemplateMembers = [SELECT Id, MemberId FROM CaseTeamTemplateMember WHERE TeamTemplateId = :fbComplianceId];
            System.debug('Account share team members: ' + allTeamTemplateMembers);
            
            for(Case thisCase : allCasesWithAccAndContacts){
                System.debug('1');
                for(CaseTeamTemplateMember thisTeamMember : allTeamTemplateMembers){
                    System.debug('2');
                    allAccountSharesToInsert.add(shareAccount(thisCase.AccountId, thisTeamMember.MemberId, shareAccess));               
                }
            }
        }
        
        
        System.debug('Account shares: ' +  allAccountSharesToInsert);
        if(allAccountSharesToInsert.size() > 0){
            insert allAccountSharesToInsert;
        } 
    }
    
    public static AccountShare shareAccount(String accountId, String memberId, String shareAccess){
        //Account share
        AccountShare thisAccountShare = new AccountShare();
        thisAccountShare.AccountId = accountId;
        thisAccountShare.AccountAccessLevel = shareAccess;
        thisAccountShare.OpportunityAccessLevel = 'Read';
        thisAccountShare.UserOrGroupId = memberId;
        System.debug('AccShare: ' + thisAccountShare);
        return thisAccountShare;
    }
    
    //send email template
    public static void sendEmailAlertToCaseTeams(List<Id> caseIds, List<String> caseTeamsToNOTSendEmailTO, Map<Id, CaseTeamTemplate> caseTeamTemplates){
        List<User> usersInOrg =[SELECT Id, ContactId FROM User];
        Map<Id,User> userMap = new Map<Id,User>(usersInOrg);
        // Get User profile name (This code commented because we changed plann)****
                //Id profileId = userinfo.getProfileId();****
                //String profileName = [Select Id, Name from Profile where Id=:profileId].Name;****
        //get email template
        Map<Id, EmailTemplate> caseAssignmentEmailTemplates = new Map<Id, EmailTemplate>([SELECT Id, Body, Subject, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Case_Assignment_Notification' OR DeveloperName = 'Case_Assignment_Template_for_Trove_community_Users']);
        //Get all the case team templates
        List<CaseTeamMember> allTeamMembers = [SELECT Id, MemberId, TeamTemplateId, TeamTemplate.Name, Member.Email, ParentId FROM CaseTeamMember where ParentId IN :caseIds];
        //list of mail
        List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();
        System.debug('NOT send emails to: ' + caseTeamsToNOTSendEmailTO);
        
        for(Id thisCaseId : caseIds){
            for(CaseTeamMember thisTeamMember : allTeamMembers){
                if(thisTeamMember.ParentId == thisCaseId){
                    String templateId = '';
                    String targetObjectId = '';
                    // Changes for profile name:(&& profileName != 'API User')****
                    if(thisTeamMember.TeamTemplate.Name == 'Compliance Manager' || thisTeamMember.TeamTemplate.Name == 'FB Compliance') {
                        for(EmailTemplate thisEmailTemplate : caseAssignmentEmailTemplates.values()){
                            if(thisEmailTemplate.DeveloperName == 'Case_Assignment_Notification'){
                                templateId = thisEmailTemplate.Id;
                            }
                        }
                    }else{
                        for(EmailTemplate thisEmailTemplate : caseAssignmentEmailTemplates.values()){
                            if(thisEmailTemplate.DeveloperName == 'Case_Assignment_Template_for_Trove_community_Users'){
                                templateId = thisEmailTemplate.Id;
                            }
                        }
                    }
               		//set targetObjectId
                    if(String.isNotEmpty(userMap.get(thisTeamMember.MemberId).ContactId)){
                        targetObjectId = userMap.get(thisTeamMember.MemberId).ContactId;// get contact id
                    }else{
                        targetObjectId = userMap.get(thisTeamMember.MemberId).Id;// get the user id
                    }
                    //get the as text and load in the mail
                    Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, targetObjectId, thisCaseId);
                    mail.setToAddresses(new list<string>{thisTeamMember.Member.Email});
                    mail.setSaveAsActivity(false);
                    if(caseTeamsToNOTSendEmailTO.size() > 0){
                        System.debug('Tempalte name before: ' + caseTeamTemplates.get(thisTeamMember.TeamTemplateId).Name);
                        if(!caseTeamsToNOTSendEmailTO.contains(caseTeamTemplates.get(thisTeamMember.TeamTemplateId).Name)){
                            System.debug('Tempalte name: ' + caseTeamTemplates.get(thisTeamMember.TeamTemplateId).Name);
                            allEmails.add(mail);
                        }
                    }else{
                        System.debug('JUST send email');
                        allEmails.add(mail);
                    }
                }
            }
        }
        
        if (!Test.IsRunningTest()) {
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(allEmails);
            for(Messaging.SendEmailResult thisEmailResult : resultMail){
                if (thisEmailResult.success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: '
                          + thisEmailResult.errors[0].message);
                }
            }
        }
    }
}