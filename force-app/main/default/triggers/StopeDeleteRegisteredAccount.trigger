trigger StopeDeleteRegisteredAccount on Account (before delete) {
    
     Id userProfileId = userinfo.getProfileId();
     String userProfileName = [SELECT ID, Name from Profile Where Id = : userProfileId].Name;
     //String PermissionSetAssignment = [ SELECT Id, PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()];
     Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Registered').getRecordTypeId();
     Id recordTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Beneficiary').getRecordTypeId();
    
    
    for(Account  a : Trigger.Old) {
        
        if( userProfileName != 'System Administrator' && (a.recordTypeId == recordTypeId || a.recordTypeId == recordTypeId2 )){
    
         a.addError('You only can delete potential customer, Not registered and beneficiary!!!'); 
       }
    }

}