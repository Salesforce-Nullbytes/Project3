public with sharing class individualResultsController {
    
    @AuraEnabled
    public static CandidateResult__c getCandidateInfo(id record) {
        return [SELECT Candidate__r.Name FROM  CandidateResult__c WHERE Id = :record LIMIT 1];
    }
}
