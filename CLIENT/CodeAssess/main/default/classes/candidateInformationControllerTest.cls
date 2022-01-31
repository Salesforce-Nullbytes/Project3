@isTest
public class candidateInformationControllerTest {
    
    @isTest
    public static void runGetCandidiateInfo() {
        Test.startTest();
        //Setup
        Contact newCandidate = new Contact();
        newCandidate.LastName = 'Test';
        newCandidate.Email = 'Test@gmail.com';
        newCandidate.Phone = '1231231234';
        insert newCandidate;

        candidateResult__c newCandidateResult = new candidateResult__c();
        newCandidateResult.Contact__c = newCandidate.id;
        insert newCandidateResult;

        ID resultId = newCandidateResult.id;

        //Run Method
        candidateResult__c testCandidateResult = candidateInformationController.getCandidateInfo(resultId);

        System.assertEquals('Test', testCandidateResult.Contact__r.Name);
        System.assertEquals('test@gmail.com', testCandidateResult.Contact__r.Email);
        System.assertEquals('1231231234', testCandidateResult.Contact__r.Phone);
        Test.stopTest();
    }

    @isTest
    public static void runGetCandidateSummary() {
        Test.startTest();
        //Setup
        candidateResult__c newCandidateResult = new candidateResult__c();
        insert newCandidateResult;

        ID resultId = newCandidateResult.id;

        Question__c newQuestion = new Question__c();
        newQuestion.QuestionTopic__c = 'SOQL';
        insert newQuestion;

        candidateQuestionResult__c newCandidateQuestionResult = new candidateQuestionResult__c();
        newCandidateQuestionResult.Result__c = 'Pass';
        newCandidateQuestionResult.CandidateResult__c = newCandidateResult.id;
        newCandidateQuestionResult.Question__c = newQuestion.id;
        insert newCandidateQuestionResult;

        //Run Method
        List <CandidateQuestionResult__c> testCandidateQuestionResult = candidateInformationController.getCandidateSummary(resultId);
        System.assertEquals('Pass', testCandidateQuestionResult[0].Result__c);
        Test.stopTest();
    }

    @isTest
    public static void runCandidateTestResults() {
        Test.startTest();
        //Setup
        candidateResult__c newCandidateResult = new candidateResult__c();
        insert newCandidateResult;

        ID resultId = newCandidateResult.id;

        Question__c newQuestion = new Question__c();
        newQuestion.QuestionTopic__c = 'SOQL';
        insert newQuestion;

        candidateQuestionResult__c newCandidateQuestionResult = new candidateQuestionResult__c();
        newCandidateQuestionResult.Result__c = 'Pass';
        newCandidateQuestionResult.CandidateResult__c = newCandidateResult.id;
        newCandidateQuestionResult.Question__c = newQuestion.id;
        insert newCandidateQuestionResult;

        //Run Method
        List <CandidateQuestionResult__c> testCandidateQuestionResult = candidateInformationController.getCandidateTestResults(resultId);
        System.assertEquals('Pass', testCandidateQuestionResult[0].Result__c);
        System.assertEquals('SOQL', testCandidateQuestionResult[0].Question__r.QuestionTopic__c);
        Test.stopTest();
    }
}
