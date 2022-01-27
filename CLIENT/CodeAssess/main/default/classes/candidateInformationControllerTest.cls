@isTest
public class candidateInformationControllerTest {
    
    @isTest
    public static void runGetCandidiateInfo() {
        //Setup
        Candidate__c newCandidate = new Candidate__c();
        newCandidate.Name = 'Test';
        newCandidate.Email__c = 'Test@gmail.com';
        newCandidate.PhoneNumber__c = '1231231234';
        insert newCandidate;

        candidateResult__c newCandidateResult = new candidateResult__c();
        newCandidateResult.Candidate__c = newCandidate.id;
        insert newCandidateResult;

        ID resultId = newCandidateResult.id;

        //Run Method
        candidateResult__c testCandidateResult = candidateInformationController.getCandidateInfo(resultId);

        System.assertEquals('Test', testCandidateResult.Candidate__r.Name);
        System.assertEquals('test@gmail.com', testCandidateResult.Candidate__r.Email__c);
        System.assertEquals('1231231234', testCandidateResult.Candidate__r.PhoneNumber__c);
    }

    @isTest
    public static void runGetCandidateSummary() {
        //Setup
        Candidate__c newCandidate = new Candidate__c();
        newCandidate.Name = 'Test';
        insert newCandidate;

        candidateResult__c newCandidateResult = new candidateResult__c();
        newCandidateResult.Candidate__c = newCandidate.id;
        insert newCandidateResult;

        ID resultId = newCandidateResult.id;

        Question__c newQuestion = new Question__c();
        newQuestion.QuestionTopic__c = 'LWC';
        insert newQuestion;

        candidateQuestionResult__c newCandidateQuestionResult = new candidateQuestionResult__c();
        newCandidateQuestionResult.Result__c = 'Pass';
        newCandidateQuestionResult.CandidateResult__c = newCandidateResult.id;
        newCandidateQuestionResult.Question__c = newQuestion.id;
        insert newCandidateQuestionResult;

        //Run Method
        List <CandidateQuestionResult__c> testCandidateQuestionResult = candidateInformationController.getCandidateSummary(resultId);
        System.assertEquals('Pass', testCandidateQuestionResult[0].Result__c);
    }

    @isTest
    public static void runCandidateTestResults() {
        //Setup
        Candidate__c newCandidate = new Candidate__c();
        newCandidate.Name = 'Test';
        insert newCandidate;

        candidateResult__c newCandidateResult = new candidateResult__c();
        newCandidateResult.Candidate__c = newCandidate.id;
        insert newCandidateResult;

        ID resultId = newCandidateResult.id;

        Question__c newQuestion = new Question__c();
        newQuestion.QuestionTopic__c = 'LWC';
        insert newQuestion;

        candidateQuestionResult__c newCandidateQuestionResult = new candidateQuestionResult__c();
        newCandidateQuestionResult.Result__c = 'Pass';
        newCandidateQuestionResult.CandidateResult__c = newCandidateResult.id;
        newCandidateQuestionResult.Question__c = newQuestion.id;
        insert newCandidateQuestionResult;

        //Run Method
        List <CandidateQuestionResult__c> testCandidateQuestionResult = candidateInformationController.getCandidateTestResults(resultId);
        System.assertEquals('Pass', testCandidateQuestionResult[0].Result__c);
        System.assertEquals('LWC', testCandidateQuestionResult[0].Question__r.QuestionTopic__c);
    }
}
