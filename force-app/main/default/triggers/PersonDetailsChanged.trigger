trigger PersonDetailsChanged on Account (After update) {
    private Id profileId = userinfo.getProfileId();
    Private String profileName = [SELECT Name FROM Profile WHERE Id = :profileId].Name;
    
    if(Trigger.isAfter){
        if(Trigger.isUpdate &&  profileName != ('API User')){
            System.debug('Person Account INIT');
            PersonAccountTriggerHandler.personAccountDetailsChanged(Trigger.new, Trigger.oldMap);
        }
    }
}