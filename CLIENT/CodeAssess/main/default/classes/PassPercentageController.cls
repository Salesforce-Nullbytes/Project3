public class PassPercentageController {
   
    @AuraEnabled
    public static List<CandidateResult__c> findByPassPercentage(Decimal searchPassPercent) {
        //Filter searches by PASS/FAIL or Candidate Name and order by created date ASC order
        Decimal percent =  searchPassPercent;
    return [SELECT Contact__r.Name, PassPercentage__c FROM CandidateResult__c WHERE PassPercentage__c >= 80];
}
}