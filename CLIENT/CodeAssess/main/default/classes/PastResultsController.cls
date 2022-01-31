public with sharing class PastResultsController {
    @AuraEnabled
    public static List <CandidateResult__c> getCandidateResults() {
        ID currentUserId = UserInfo.getUserId();
        //For testing purposes
        //return [SELECT ID, PassPercentage__c, StartTime__c, SubmitTime__c FROM CandidateResult__c WHERE Status__c = 'Completed' AND Candidate__r.User__r.id = '0056300000BTUqeAAH'];

         return [SELECT ID, PassPercentage__c, StartTime__c, SubmitTime__c FROM CandidateResult__c WHERE Status__c = 'Completed' AND Candidate__r.User__r.id = :currentUserId];
    }
}
