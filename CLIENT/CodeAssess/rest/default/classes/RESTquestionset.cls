@RestResource(urlMapping='/questionset/*')
global class RESTquestionset {

    //@HttpPost
    global static String submitTest(String requestBody) {
        //String requestBody = RestContext.request.requestBody.toString();
        submission parsed = (submission)JSON.deserializeStrict(requestBody, submission.class);
        System.debug(parsed.start);
        System.debug(parsed.endTime);
        for (MethodResult result : parsed.methods) {
            System.debug('  ' + result.name);
            System.debug('  ' + result.outcome);
        }
        return 'hi';
    }

    public static void testPost() {
        // CREATE REQUEST
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setEndpoint('junk');

        // SET REQUEST BODY
        String body = '{"start":"(datetime)","endTime":"(datetime)","methods":[{"name":"name 1","outcome":"PASS"},{"name":"name 2","outcome":"FAIL"},{"name":"name 3","outcome":"PASS"}]}';        
        req.setBody(body);

        System.debug(body);
        System.debug(req);

        submitTest(body);

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
        String start;
        String endTime;
        public List<MethodResult> methods;
    }
    
    private class MethodResult {
        String name;
        String outcome;
    }
}
