public with sharing class candidateInformationController {
    
    @AuraEnabled
    public static CandidateResult__c getCandidateInfo(id record) {
        return [SELECT Candidate__r.Name, Candidate__r.Email__c, Candidate__r.PhoneNumber__c FROM  CandidateResult__c WHERE Id = :record LIMIT 1];
    }
}
