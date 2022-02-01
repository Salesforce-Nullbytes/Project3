@IsTest
public class RESTQuestionSetTest {
    @TestSetup
    static void makeData(){
        User c = TESTutilCommunityUser.makeCustomerAndUser('mockTestUser1');
    }

    @IsTest
    public static void TN_HelperQuestionUnderInvalidId() {
        Test.startTest();
        String actualValue = RESTquestionset.getFullQuestionSet('invalidId');
        String expectedValue = 'Invalid query';
        Test.stopTest();

        System.assertEquals(expectedValue, actualValue, actualValue);
    }

    @IsTest
    public static void TN_HelperQuestionSetNoQuestions() {
        Test.startTest();
        QuestionSet__c mock = new QuestionSet__c(name = 'TestSet');
        insert mock;
    
        String actualValue = RESTquestionset.getFullQuestionSet(mock.id);
        String expectedValue = 'No questions to query';
        Test.stopTest();

        System.assertEquals(expectedValue, actualValue, actualValue);
    }

    @IsTest
    public static void TP_HelperGetQuestionsUnderList() {
        Test.startTest();
        QuestionSet__c mock = new QuestionSet__c(name = 'TestSet');
        insert mock;

        Question__c[] questions = new List<Question__c>();
        for (Integer i = 0; i < 2; i++) {
            Question__c q = new Question__c();
            q.name = 'some name';
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
        +'[{\"topic\":\"SOQL\",\"testFile\":\"Some test class\",\"prompt\":\"prompt\",\"placeholder\":\"placeholder\",\"name\":\"some name\",\"identifier\":\"' + questions[0].id + '\"},'
        +'{\"topic\":\"SOQL\",\"testFile\":\"Some test class\",\"prompt\":\"prompt\",\"placeholder\":\"placeholder\",\"name\":\"some name\",\"identifier\":\"' + questions[1].id + '\"}],'
        +'\"name\":\"TestSet\"}';
        
        Test.stopTest();
        System.assertEquals(expectedValue, actualValue, actualValue);
    }

    @IsTest
    public static void TP_HelperMakeQuestionSetList() {
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
    @isTest
    static void TP_getQuestionsGoodParam(){
        Test.startTest();
        // Same process as testing helper method...
        QuestionSet__c mock = new QuestionSet__c(name = 'TestSet');
        insert mock;

        Question__c[] questions = new List<Question__c>();
        for (Integer i = 0; i < 2; i++) {
            Question__c q = new Question__c();
            q.name = 'some name';
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

        ID qSetID = mock.id;

        // Create GET request
        RestRequest request = new RestRequest();
        request.requestUri = getRESTurl() + 'questionset/' + qSetID; // only the specified test...
        request.httpMethod = 'GET';
        RestContext.request = request;

        // Same basic test structure as when testing helper method
        String response = RESTquestionset.getList(); // makes call with specified questionset
        
        String expectedValue = '{\"url\":\"' + mock.id + '\",\"questions\":'
        +'[{\"topic\":\"SOQL\",\"testFile\":\"Some test class\",\"prompt\":\"prompt\",\"placeholder\":\"placeholder\",\"name\":\"some name\",\"identifier\":\"' + questions[0].id + '\"},'
        +'{\"topic\":\"SOQL\",\"testFile\":\"Some test class\",\"prompt\":\"prompt\",\"placeholder\":\"placeholder\",\"name\":\"some name\",\"identifier\":\"' + questions[1].id + '\"}],'
        +'\"name\":\"TestSet\"}';
        
        Test.stopTest();
        System.assertEquals(expectedValue, response);
    }
    @isTest
    static void TN_getQuestionsBadParam(){
        Test.startTest();
        // Create GET request
        RestRequest request = new RestRequest();
        request.requestUri = getRESTurl() + 'questionset/' + 'fakeid'; // ID does not exist
        request.httpMethod = 'GET';
        RestContext.request = request;

        // Same basic test structure as when testing helper method
        String response = RESTquestionset.getList(); // makes call with specified questionset
        
        String expectedValue = 'NO_RESOURCE';
        
        Test.stopTest();
        System.assertEquals(expectedValue, response);
    }
    @isTest
    static void TN_getQuestionsNoQuestionsUnderSet(){
        Test.startTest();
        QuestionSet__c mock = new QuestionSet__c(name = 'TestSet');
        insert mock; // No related questions!

        // Create GET request
        RestRequest request = new RestRequest();
        request.requestUri = getRESTurl() + 'questionset/' + mock.id; // No questions to query
        request.httpMethod = 'GET';
        RestContext.request = request;

        // Same basic test structure as when testing helper method
        String response = RESTquestionset.getList(); // makes call with specified questionset
        
        String expectedValue = 'NO_RESOURCE';
        
        Test.stopTest();
        System.assertEquals(expectedValue, response);
    }

    @isTest
    static void TP_postSubmissionValid(){
        Test.startTest();
        User c = [
            SELECT ContactID, Name FROM USER 
            WHERE Profile.Name = 'CodeAssessCandidate' AND Name = 'mockTestUser1'
            LIMIT 1
        ];
        
        // Question Set for candidate response
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

        // Build response body in JSON
        String q1m1 = '{"name":"q1m1","outcome":"PASS"}';
        String q1m2 = '{"name":"q1m2","outcome":"PASS"}';
        String q2m1 = '{"name":"q2m1","outcome":"FAIL"}';
        String q2m2 = '{"name":"q2m2","outcome":"PASS"}';
        String q1 = '{"url":"'+questions[0].id+'","startTime":"2020-01-11 05:00:00","endTime":"2020-01-11 05:30:00","methods":['+q1m1+','+q1m2+']}';
        String q2 = '{"url":"'+questions[1].id+'","startTime":"2020-01-11 05:30:00","endTime":"2020-01-11 06:00:00","methods":['+q2m1+','+q2m2+']}';
        String sub = '{"url":"'+mock.id+'","startTime":"2020-01-11 05:00:00","endTime":"2020-01-11 06:00:00","questions":['+q1+','+q2+']}';

        // Make response body:
        String body = sub;
        
        System.runAs(c) {
            // Create POST request
            RestRequest request = new RestRequest();
            request.requestUri = getRESTurl() + 'questionset/';
            request.httpMethod = 'POST';
            request.headers.put('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf(body);
            RestContext.request = request;

            // Ensure successful post
            String response = RESTquestionset.submitTest();
            String expectedValue = 'SUCCESS';
            System.assertEquals(expectedValue, response);
        }

        //Check that result records uploaded to db

        CandidateResult__c[] cResults = [SELECT id FROM CandidateResult__c WHERE Contact__c = :c.ContactId];
        System.assertEquals(1, cResults.size());

        CandidateQuestionResult__c[] cQuestions = [SELECT id FROM CandidateQuestionResult__c WHERE CandidateResult__c = :cResults[0].id];
        System.assertEquals(2, cQuestions.size());

        Set<ID> qResultIDs = new Set<ID>();
        for (CandidateQuestionResult__c q : cQuestions) {
            qResultIDs.add(q.id);
        }
        CandidateMethodResult__c[] cMethods = [SELECT id FROM CandidateMethodResult__c WHERE CandidateQuestionResult__c IN :qResultIDs];
        System.assertEquals(4, cMethods.size());
        
        Test.stopTest();
    }

    @isTest
    static void TN_postSubmissionBadBody(){
        Test.startTest();
        User c = [
            SELECT ContactID, Name FROM USER 
            WHERE Profile.Name = 'CodeAssessCandidate' AND Name = 'mockTestUser1'
            LIMIT 1
        ];
        
        // Question Set for candidate response
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

        // Make response body:
        String body = '{"key":"value","doesnt match":"required format"}';
        
        System.runAs(c) {
            // Create POST request
            RestRequest request = new RestRequest();
            request.requestUri = getRESTurl() + 'questionset/';
            request.httpMethod = 'POST';
            request.headers.put('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf(body);
            RestContext.request = request;

            // Ensure successful post
            String response = RESTquestionset.submitTest();
            String expectedValue = 'FAILED';
            System.assertEquals(expectedValue, response);
        }

        // Check that result records uploaded to db

        CandidateResult__c[] cResults = [SELECT id FROM CandidateResult__c WHERE Contact__c = :c.ContactId];
        System.assertEquals(0, cResults.size());

        // No CandidateQuestionResult__c or CandidateMethodResult__c if no parent CandidateResult__c
        
        Test.stopTest();
    }

    // HELPER TO GET ENDPOINT URL
    private static String getRESTurl() {
        //Network net = [SELECT Name, UrlPathPrefix FROM Network WHERE Name = 'Code Assess Experience'];
        return URL.getSalesforceBaseUrl().toExternalForm() + 'main/services/apexrest/';
    }
}
