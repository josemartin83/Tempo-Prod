trigger CaseTrigger on Case (after insert, after update) {
    
    if(Trigger.isUpdate && Trigger.isAfter){
        //handle case team assignment
        CaseTriggerHandler.assignDefaultTeamsAfterUpdate(Trigger.new);
    }else if(Trigger.isInsert && Trigger.isAfter){
        //handle case team assignment
        CaseTriggerHandler.assignDefaultTeamsAfterInsert(Trigger.new);
    }
}