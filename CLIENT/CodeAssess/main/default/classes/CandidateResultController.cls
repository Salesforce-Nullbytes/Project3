public with sharing class CandidateResultController {
    @AuraEnabled
    public static List <CandidateResult__c> getCandidateResults() {
        return [SELECT Id, name, Phone, Email, PassRatio FROM CandidateResult__c ORDER BY createdDate ASC];
    }    
    @AuraEnabled
    public static List<CandidateResult__c> findByName(String searchKey) {
        String name =  + searchKey + '%';
        return [SELECT id, name, phone, email, passratio FROM CandidateResult__c WHERE name LIKE :name ORDER BY createdDate ASC];
    }
}