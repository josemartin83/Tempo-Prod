trigger PersonDetailsPlatformEventTrigger on Person_Detail_Change__e (after insert) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            AWSCallout.personDetailsChangeCallout(Trigger.new);
            
        }
    }
}