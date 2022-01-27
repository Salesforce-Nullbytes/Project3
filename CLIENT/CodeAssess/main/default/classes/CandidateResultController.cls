
public  class CandidateResultController {
    @AuraEnabled
    public static List <CandidateResult__c> getCandidateResults() {
        return [SELECT Id, Candidate__c, Candidate__r.Name, Name, PassRatio__c FROM CandidateResult__c ORDER BY createdDate ASC];
    }    
    @AuraEnabled
    public static List<CandidateResult__c> findByName(String searchKey) {
        String name =   searchKey + '%';
        return [SELECT id, Candidate__c, Candidate__r.Name,Name, passratio__c FROM CandidateResult__c  WHERE Name LIKE  :searchKey OR Candidate__r.Name LIKE :searchKey ORDER BY createdDate ASC ];
    }
}