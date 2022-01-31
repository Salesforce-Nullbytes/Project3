@IsTest
public class RESTQuestionSetTest {

    @IsTest
    public static void testGetFullQuestionSetInvalidId() {
        Test.startTest();
        String actualValue = RESTquestionset.getFullQuestionSet('invalidId');
        String expectedValue = 'Invalid query';
        Test.stopTest();

        System.assertEquals(expectedValue, actualValue, actualValue);
    }

    @IsTest
    public static void testGetFullQuestionSetNoQuestions() {
        Test.startTest();
        QuestionSet__c mock = new QuestionSet__c(name = 'TestSet');
        insert mock;
    
        String actualValue = RESTquestionset.getFullQuestionSet(mock.id);
        String expectedValue = 'No questions to query';
        Test.stopTest();

        System.assertEquals(expectedValue, actualValue, actualValue);
    }

    @IsTest
    public static void testGetFullQuestionSetGetQuestions() {
        Test.startTest();
        QuestionSet__c mock = new QuestionSet__c(name = 'TestSet');
        insert mock;

        Question__c[] questions = new List<Question__c>();
        for (Integer i = 0; i < 2; i++) {
            Question__c q = new Question__c();
            q.PlaceHolder__c = 'placeholder';
            q.Prompt__c = 'prompt';
            q.QuestionTopic__c = 'SOQL';
            q.TestClassText__c = 'Some test class';
            questions.add(q);
        }
        Insert questions;
        for (Question__c q : questions) {
            QuestionSetEntry__c entry = new QuestionSetEntry__c();
            entry.Question__c = q.id;
            entry.QuestionSet__c = mock.id;
            Insert entry;
        }
    
        String actualValue = RESTquestionset.getFullQuestionSet(mock.id);
        String expectedValue = '{\"url\":\"' + mock.id + '\",\"questions\":'
        +'[{\"topic\":\"SOQL\",\"testFile\":\"Some test class\",\"prompt\":\"prompt\",\"placeholder\":\"placeholder\",\"identifier\":\"' + questions[0].id + '\"},'
        +'{\"topic\":\"SOQL\",\"testFile\":\"Some test class\",\"prompt\":\"prompt\",\"placeholder\":\"placeholder\",\"identifier\":\"' + questions[1].id + '\"}],'
        +'\"name\":\"TestSet\"}';
        
        Test.stopTest();
        System.assertEquals(expectedValue, actualValue, actualValue);
    }

    @IsTest
    public static void TestMakeQuestionSetList() {
        Test.startTest();
        delete [SELECT ID FROM QuestionSet__c];
        QuestionSet__c mock1 = new QuestionSet__c(name = 'TestSet1');
        insert mock1;
        QuestionSet__c mock2 = new QuestionSet__c(name = 'TestSet2');
        insert mock2;

        String actualValue = RESTquestionset.makeQuestionSetList();
        Boolean match = false;

        if (actualValue == '{\"entries\":[{\"url\":\"' + mock1.id + '\",\"questions\":[],\"name\":\"' + mock1.name + '\"},{\"url\":\"' + mock2.id + '\",\"questions\":[],\"name\":\"' + mock2.name + '\"}]}') {
            match = true;
        }
        if (actualValue == '{\"entries\":[{\"url\":\"' + mock2.id + '\",\"questions\":[],\"name\":\"' + mock2.name + '\"},{\"url\":\"' + mock1.id + '\",\"questions\":[],\"name\":\"' + mock1.name + '\"}]}') {
            match = true;
        }
        
        System.assert(match);
        Test.stopTest();
    }
    @isTest
    static void TP_getQuestionSetList(){
        Test.startTest();
        QuestionSet__c mock1 = new QuestionSet__c(name = 'TestSet1');
        insert mock1;
        QuestionSet__c mock2 = new QuestionSet__c(name = 'TestSet2');
        insert mock2;

        QuestionSet__c[] allTests = [SELECT id, name FROM QuestionSet__c];
        System.assert(allTests.size() > 0);

        // Create GET request
        RestRequest request = new RestRequest();
        request.requestUri = getRESTurl() + 'questionset/'; // no param returns list of questionsets
        request.httpMethod = 'GET';
        RestContext.request = request;

        // Same basic test structure as when testing helper method
        String response = RESTquestionset.getList();
        
        Boolean match = false;
        if (response == '{\"entries\":[{\"url\":\"' + mock1.id + '\",\"questions\":[],\"name\":\"' + mock1.name + '\"},{\"url\":\"' + mock2.id + '\",\"questions\":[],\"name\":\"' + mock2.name + '\"}]}') {
            match = true;
        }
        if (response == '{\"entries\":[{\"url\":\"' + mock2.id + '\",\"questions\":[],\"name\":\"' + mock2.name + '\"},{\"url\":\"' + mock1.id + '\",\"questions\":[],\"name\":\"' + mock1.name + '\"}]}') {
            match = true;
        }
        
        System.assert(match);
        
        Test.stopTest();
    }

    // HELPER TO GET ENDPOINT URL
    private static String getRESTurl() {
        //Network net = [SELECT Name, UrlPathPrefix FROM Network WHERE Name = 'Code Assess Experience'];
        return URL.getSalesforceBaseUrl().toExternalForm() + 'main/services/apexrest/';
    }
}
