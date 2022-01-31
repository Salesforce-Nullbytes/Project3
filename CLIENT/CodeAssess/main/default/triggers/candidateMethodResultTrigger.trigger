trigger candidateMethodResultTrigger on CandidateMethodResult__c (after insert, after update) {
    switch on trigger.operationType {
        when AFTER_INSERT {
            candidateMethodResultTriggerHelper.onAfterInsert(trigger.new);
        }

        when AFTER_UPDATE {
            candidateMethodResultTriggerHelper.onAfterUpdate(trigger.new);
        }
    }
}