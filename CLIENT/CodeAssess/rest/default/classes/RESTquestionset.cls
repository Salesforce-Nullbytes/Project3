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
        QuestionSet(String myUrl, String myName) {
            url = myUrl;
            name = myName;
        }
    }

   // private class Question{

    //}
    
}