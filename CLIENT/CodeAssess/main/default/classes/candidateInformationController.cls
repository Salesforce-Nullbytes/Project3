public without sharing class candidateInformationController {
    
    @AuraEnabled
    public static CandidateResult__c getCandidateInfo(id record) {
        return [SELECT Contact__r.Name, Contact__r.Email, Contact__r.Phone FROM  CandidateResult__c WHERE Id = :record LIMIT 1];
    }

    @AuraEnabled
    public static List<CandidateQuestionResult__c> getCandidateSummary(id record) {
        return [SELECT Result__c, MethodsPassed__c, TotalMethods__c, CandidateResult__r.id, CandidateResult__r.StartTime__c, CandidateResult__r.SubmitTime__c FROM CandidateQuestionResult__c WHERE CandidateResult__r.id = :record];
    }

    @AuraEnabled
    public static List<CandidateQuestionResult__c> getCandidateTestResults(id record) {
        return [SELECT Result__c, MethodsPassed__c, TotalMethods__c, Question__r.QuestionTopic__c, CandidateResult__r.id FROM CandidateQuestionResult__c WHERE CandidateResult__r.id = :record];
    }
}
