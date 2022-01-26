@RestResource(urlMapping='/questionset/*')
global class RESTquestionset {
    @httpGet
    global static String getList() { //don't worry about testing this class 

        RestRequest req = RestContext.request;
        RestResponse response = RestContext.response;

        String context = req.requestURI;
        String urlInput = context.substring(context.lastIndexOf('/')+1);

        if (urlInput == null) {
            return makeQuestionSetList();
        }
        return 'Hello from server! (' + urlInput + ')';
    }
    public static String getFullQuestionSet(String identifier) {
        List<QuestionSet__c> entries = [
            SELECT id, name  FROM QuestionSet__c
        ];
        if (entries.size() == 0) {
            System.debug('Invalid query');
            return '';
        }
        List<QuestionSetEntry__c> questionLinks = [
            SELECT Question__c  FROM QuestionSetEntry__c WHERE QuestionSet__r.id = :identifier
        ];
        if (questionLinks.size() == 0) {
            System.debug('No questions to query');
            return '';
        }
        Set<ID> qIDs = new Set<ID>();
        for (QuestionSetEntry__c link : questionLinks) {
            qIDs.add(link.Question__c);
        }
        List<Question__c> questions = [
            SELECT id, PlaceHolder__c, Prompt__c, QuestionTopic__c FROM Question__c WHERE id IN :qIDs
        ];

        QuestionSet result = new QuestionSet(entries[0].id, entries[0].name);
        for (Question__c question : questions) {
            Question temp = new Question(question.id, question.Placeholder__c, question.Prompt__c, question.QuestionTopic__c);
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

    private class QuestionSetList{ //Question set name and Id
        public List<QuestionSet> entries; 
        QuestionSetList() {
            entries = new List<QuestionSet>();
        }
    }

    private class QuestionSet{
        //Need ID
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
        Question(ID myIdentifier, String myPlaceholder, String myPrompt, String myTopic) {
            identifier = myIdentifier;
            placeholder = myplaceholder;
            prompt = myprompt;
            topic = mytopic;
        }
    }
    
}