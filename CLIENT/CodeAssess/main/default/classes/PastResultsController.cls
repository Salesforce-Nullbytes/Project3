public without sharing class PastResultsController {

    private static ID contactId() {
        ID currentUserId = UserInfo.getUserId();
        return [SELECT ContactId FROM User WHERE id = :currentUserId LIMIT 1]?.ContactId;
    }

    
    @AuraEnabled
    public static List <CandidateResult__c> getCandidateResults() {
        return [SELECT ID, PassPercentage__c, StartTime__c, SubmitTime__c FROM CandidateResult__c WHERE Contact__c =: contactId()];
    }
}
