public without sharing class candidateMethodResultTriggerHelper {
    public static void onAfterUpdate(List<CandidateMethodResult__c> cmrList) {
        Set<Id> cqrIdSet = new Set<Id>();
        for (CandidateMethodResult__c cmr : cmrList) {
            cqrIdSet.add(cmr.CandidateQuestionResult__c);
        }

        List<CandidateQuestionResult__c> cqrList = [SELECT MethodsPassed__c, TotalMethods__c, Result__c FROM CandidateQuestionResult__c WHERE Id IN :cqrIdSet];

        for (CandidateQuestionResult__c cqr : cqrList) {
            if (cqr.TotalMethods__c == cqr.MethodsPassed__c) {
                cqr.Result__c = 'Pass';
            } else {
                cqr.Result__c = 'Fail';
            }
        }

        UPDATE cqrList;
    }
    public static void onAfterInsert(List<CandidateMethodResult__c> cmrList) {
        onAfterUpdate(cmrList);
    }
}
