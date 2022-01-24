public with sharing class candidateSummaryController {
    @AuraEnabled
    public static List<CandidateQuestionResult__c> getCandidateSummary(id record) {
        return [SELECT Result__c, CodeCoverage__c, CandidateResult__r.id FROM CandidateQuestionResult__c WHERE CandidateResult__r.id = :record];
    }
}
