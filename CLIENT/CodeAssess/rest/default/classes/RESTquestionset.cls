@RestResource(urlMapping='/questionset/*')
global without sharing class RESTquestionset {
    private static ID getContactId() {
        return [SELECT ContactId FROM User WHERE id = :UserInfo.getUserId() LIMIT 1]?.ContactId;
    }

    @HttpPost
    global static String submitTest() {
        String requestBody = RestContext.request.requestBody.toString();
        try {
            parseJSONtoSubmission(requestBody);
        } catch (Exception e) {
            System.debug('ERROR PARSING SUBMISSION: ' + e.getMessage());
            return 'FAILED';
        }
        return 'SUCCESS';
    }

    public static void parseJSONtoSubmission(String requestBody) {
        //String body = '{"url":"a051F00000AvWODQA3","startTime":"2017-07-25 00:00:00","endTime":"2017-07-25 00:00:00","questions":[{"url":"a061F0000064vKRQAY","startTime":"2017-07-25 00:00:00","endTime":"2017-07-25 00:00:00","methods":[{"name":"method name","outcome":"PASS"},{"name":"method name","outcome":"PASS"}]},{"url":"a061F0000064vKSQAY","startTime":"2017-07-25 00:00:00","endTime":"2017-07-25 00:00:00","methods":[{"name":"method name","outcome":"FAIL"},{"name":"method name","outcome":"PASS"}]}]}';
        Submission parsed = (Submission)JSON.deserializeStrict(requestBody, submission.class);
        // System.debug('url: ' + parsed.url);
        // System.debug('startTime: ' + parsed.startTime);
        // System.debug('endTime: ' + parsed.endTime);
        // System.debug('questions:');

        CandidateResult__c result = new CandidateResult__c();
        result.Contact__c = getContactId();
        result.Question_Set__c = parsed.url;
        result.StartTime__c = Datetime.valueOf(parsed.startTime);
        result.SubmitTime__c = Datetime.valueOf(parsed.endTime);
        Insert result;

        CandidateQuestionResult__c[] questions = new CandidateQuestionResult__c[]{};
        for (QuestionResult q : parsed.questions) {
            // System.debug('.  url: ' + q.url);
            // System.debug('.  startTime: ' + q.startTime);
            // System.debug('.  endTime: ' + q.endTime);
            // System.debug('.  methods:');

            CandidateQuestionResult__c qResult = new CandidateQuestionResult__c();
            qResult.CandidateResult__c = result.id;
            qResult.Question__c = q.url;
            qResult.StartTime__c = Datetime.valueOf(q.startTime);
            qResult.SubmitTime__c = Datetime.valueOf(q.endTime);
            questions.add(qResult);

            // for (MethodResult m : q.methods) {
            //     System.debug('.     name: ' + m.name);
            //     System.debug('.     outcome: ' + m.outcome);
            // }
        }
        Insert questions;

        // Map Question ID (from submission) to associated CandidateQuestionResult parent ID
        Map<String, ID> mapQuestionToResultID = new Map<String, ID>();
        for (CandidateQuestionResult__c qResult : questions) {
            mapQuestionToResultID.put(qResult.Question__c, qResult.id);
        }

        CandidateMethodResult__c[] methods = new CandidateMethodResult__c[]{};
        for (QuestionResult q : parsed.questions) {
            for (MethodResult m : q.methods) {
                CandidateMethodResult__c mResult = new CandidateMethodResult__c();
                mResult.CandidateQuestionResult__c = mapQuestionToResultID.get(q.url);
                mResult.MethodName__c = m.name;
                mResult.Outcome__c = m.outcome;

                methods.add(mResult);
            }
        }
        Insert methods;
    }
    @httpGet
    global static String getList() {
        RestRequest req = RestContext.request;
        RestResponse response = RestContext.response;

        String context = req.requestURI;
        String urlInput = context.substring(context.lastIndexOf('/')+1);

        if (urlInput == '') {
            return makeQuestionSetList();
        } else {
            String body = getFullQuestionSet(urlInput);
            if (body == 'Invalid query' || body == 'No questions to query' ) {
                return 'NO_RESOURCE';
            }
            return body;
        }
    }
    public static String getFullQuestionSet(String identifier) {
        // Find item
        List<QuestionSet__c> entries = [
            SELECT id, name  FROM QuestionSet__c WHERE Id =: identifier
        ];

        // Validate Question Entries
        if (entries.size() == 0) {
            return 'Invalid query';
        }
        List<QuestionSetEntry__c> questionLinks = [
            SELECT Question__c  FROM QuestionSetEntry__c WHERE QuestionSet__r.id = :identifier
        ];
        if (questionLinks.size() == 0) {
            return 'No questions to query';
        }

        // Generate list of Question IDs to include
        Set<ID> qIDs = new Set<ID>();
        for (QuestionSetEntry__c link : questionLinks) {
            qIDs.add(link.Question__c);
        }
        List<Question__c> questions = [
            SELECT id, PlaceHolder__c, Prompt__c, QuestionTopic__c, TestClassText__c FROM Question__c WHERE id IN :qIDs
        ];

        QuestionSet result = new QuestionSet(entries[0].id, entries[0].name);
        for (Question__c question : questions) {
            Question temp = new Question(
                question.id, 
                question.Placeholder__c, 
                question.Prompt__c, 
                question.QuestionTopic__c, 
                question.TestClassText__c
            );
            result.questions.add(temp);
        }

        String output = JSON.serialize(result);
        System.debug(output);
        return output;
    }
    public static string makeQuestionSetList() {
        List<QuestionSet__c> entries = [
            SELECT id, name  FROM QuestionSet__c
        ];

        QuestionSetList qlist = new QuestionSetList();
        for (QuestionSet__c entry : entries) {
            qList.entries.add(new QuestionSet(entry.id, entry.name));
        }

        String output = JSON.serialize(qList);
        System.debug(output);
        return output;
    }

    // Helpers for JSON serialization
    private class QuestionSetList{
        public List<QuestionSet> entries; 
        QuestionSetList() {
            entries = new List<QuestionSet>();
        }
    }
    private class QuestionSet{
        String url;
        String name;
        public List<Question> questions;
        QuestionSet(String myUrl, String myName) {
            url = myUrl;
            name = myName;
            questions = new List<Question>();
        }
    }
    private class Question{
        ID identifier;
        String placeholder;
        String prompt;
        String topic;
        String testFile;
        Question(ID myIdentifier, String myPlaceholder, String myPrompt, String myTopic, String myTestFile) {
            identifier = myIdentifier;
            placeholder = myplaceholder;
            prompt = myprompt;
            topic = mytopic;
            testFile = myTestFile;
        }
    }
    
    // Helpers for JSON deserialization
    private class Submission {
        String url;
        String startTime;
        String endTime;
        public List<QuestionResult> questions;
    }
    private class QuestionResult {
        String url;
        String startTime;
        String endTime;
        public List<MethodResult> methods;
    }
    private class MethodResult {
        String name;
        String outcome;
    }
}
