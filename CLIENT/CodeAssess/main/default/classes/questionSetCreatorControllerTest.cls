@isTest
public class questionSetCreatorControllerTest {
    @isTest
    public static void TP_findQuestion() {
        Test.startTest();
        Question__c q1 = new Question__c();
        q1.name = 'Search Term 1';
        q1.PlaceHolder__c = 'placeholder';
        q1.Prompt__c = 'prompt';
        q1.QuestionTopic__c = 'SOQL';
        q1.TestClassText__c = 'Some test class';
        Insert q1;
        Question__c q2 = new Question__c();
        q2.name = 'Search Term 2';
        q2.PlaceHolder__c = 'placeholder';
        q2.Prompt__c = 'prompt';
        q2.QuestionTopic__c = 'SOQL';
        q2.TestClassText__c = 'Some test class';
        Insert q2;
        Question__c q3 = new Question__c();
        q3.name = 'Search Else 2';
        q3.PlaceHolder__c = 'placeholder';
        q3.Prompt__c = 'prompt';
        q3.QuestionTopic__c = 'SOQL';
        q3.TestClassText__c = 'Some test class';
        Insert q3;

        List<Question__c> returned2 = questionSetCreatorController.fetchQuestionList('Term');
        System.assertEquals(2, returned2.size());

        List<Question__c> returned3 = questionSetCreatorController.fetchQuestionList('');
        System.assertEquals(3, returned3.size());
        Test.stopTest();
    }
    @isTest
    public static void TP_DupFound() {
        Test.startTest();
        QuestionSet__c set1 = new QuestionSet__c(name = 'First');
        Insert set1;

        Boolean foundExisting = questionSetCreatorController.checkDuplicate('First');
        System.assertEquals(true, foundExisting);

        Boolean foundNew = questionSetCreatorController.checkDuplicate('Second');
        System.assertEquals(false, foundNew);

        Test.stopTest();
    }
    @isTest
    public static void TP_InsertedQuestionSet() {
        Test.startTest();
        String qSetName = 'qSetName 1';
        String qName1 = 'hello 1';
        String qName2 = 'hello 2';
        String qName3 = 'hello 3';

        Question__c q1 = new Question__c();
        q1.name = qName1;
        q1.PlaceHolder__c = 'placeholder';
        q1.Prompt__c = 'prompt';
        q1.QuestionTopic__c = 'SOQL';
        q1.TestClassText__c = 'Some test class';
        Insert q1;
        Question__c q2 = new Question__c();
        q2.name = qName2;
        q2.PlaceHolder__c = 'placeholder';
        q2.Prompt__c = 'prompt';
        q2.QuestionTopic__c = 'SOQL';
        q2.TestClassText__c = 'Some test class';
        Insert q2;
        Question__c q3 = new Question__c();
        q3.name = qName3;
        q3.PlaceHolder__c = 'placeholder';
        q3.Prompt__c = 'prompt';
        q3.QuestionTopic__c = 'SOQL';
        q3.TestClassText__c = 'Some test class';
        Insert q3;

        Boolean insertedNew = questionSetCreatorController.insertQuestionSet(qSetName, new String[]{qName1, qName2});
        Boolean insertedRepeat = questionSetCreatorController.insertQuestionSet(qSetName, new String[]{qName3});

        System.assertEquals(true, insertedNew);
        System.assertEquals(false, insertedRepeat);
        Test.stopTest();
    }
}
