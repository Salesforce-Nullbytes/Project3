@RestResource(urlMapping='/questionset/*')
global class RESTquestionset {
    @httpGet
    global static String getResponse() {

        RestRequest req = RestContext.request;
        RestResponse response = RestContext.response;

        String context = req.requestURI;
        String urlInput = context.substring(context.lastIndexOf('/')+1);

        String output = '';

        return output;
    }
    private class QuestionSet {
        Boolean success;
        List<Question> items;

        QuestionSet() {
            
        }
        public String serialize() {
            return JSON.serialize(this);
        }
    }
    private class Question {
        Boolean success;
        
        Question() {
            
        }
    }
    public String serialize() {
        return JSON.serialize(this);
    }
}
