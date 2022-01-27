@isTest
public class candidateInformationControllerTest {
    
    @isTest
    public static void runGetCandidiateInfo() {
        Candidate__r newCandidate = new Candidate__r();
        newCandidate.Name = 'Test';
        newCandidate.Email__c = 'Test@gmail.com';
        newCandidate.PhoneNumber__c = '1231231234';

        insert newCandidate;
    }
    
}
