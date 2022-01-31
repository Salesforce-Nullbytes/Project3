@isTest
public class candidateInformationControllerTest {
    
    @isTest
    public static void runGetCandidiateInfo() {
        //Setup
        Contact newCandidate = new Contact();
        newCandidate.FirstName = 'Test';
        newCandidate.Email = 'Test@gmail.com';
        newCandidate.Phone = '1231231234';
        insert newCandidate;

        candidateResult__c newCandidateResult = new candidateResult__c();
        newCandidateResult.Contact__c = newCandidate.id;
        insert newCandidateResult;

        ID resultId = newCandidateResult.id;

        //Run Method
        candidateResult__c testCandidateResult = candidateInformationController.getCandidateInfo(resultId);

        System.assertEquals('Test', testCandidateResult.Contact__r.FirstName);
        System.assertEquals('test@gmail.com', testCandidateResult.Contact__r.Email);
        System.assertEquals('1231231234', testCandidateResult.Contact__r.Phone);
    }

    @isTest
    public static void runGetCandidateSummary() {
        //Setup
        Contact newCandidate = new Contact();
        newCandidate.FirstName = 'Test';
        insert newCandidate;

        candidateResult__c newCandidateResult = new candidateResult__c();
        newCandidateResult.Contact__c = newCandidate.id;
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
        Contact newCandidate = new Contact();
        newCandidate.FirstName = 'Test';
        insert newCandidate;

        candidateResult__c newCandidateResult = new candidateResult__c();
        newCandidateResult.Contact__c = newCandidate.id;
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
