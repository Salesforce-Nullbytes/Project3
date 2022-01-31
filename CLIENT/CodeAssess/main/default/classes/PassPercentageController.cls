public class PassPercentageController {
   
    @AuraEnabled
    public static List<CandidateResult__c> findByPercent(Decimal searchPercent) {
        //Filter searches by PASS/FAIL or Candidate Name and order by created date ASC order
        Decimal percent =  searchPercent + '%';
    return [SELECT Candidate__r.Name, PassPercentage__c FROM CandidateResult__c WHERE PassPercentage__c >= 80];
}
}