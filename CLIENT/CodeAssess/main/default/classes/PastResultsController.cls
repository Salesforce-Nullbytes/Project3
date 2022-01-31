public with sharing class PastResultsController {

    private static ID contactId() {
        ID currentUserId = UserInfo.getUserId();
        return [SELECT ContactId FROM User WHERE id = :currentUserId LIMIT 1]?.ContactId;
    }

    
    @AuraEnabled
    public static List <CandidateResult__c> getCandidateResults() {

        ID currentContactID = contactId();
        return [SELECT ID, PassPercentage__c, StartTime__c, SubmitTime__c FROM CandidateResult__c WHERE Status__c = 'Completed' AND Contact__r.id = :currentContactID];
    }
}
