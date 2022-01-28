public class RESTcallout {
    // Test function
    public static String getGreeting(String url) {
        return getResource('Greeting/', url);
    }

    public static String getQuestionSet(String url) {
        return getResource('questionset/', url);
    }

    private static String getResource(String locator, String param) {
        Http http = new Http();
        HttpRequest req = RESTutil.getRequest('questionset/', param);
        if (req == null) {
            System.debug('Session was invalid. Please try again.');
            return 'TRY_AGAIN';
        }
        HTTPResponse res = http.send(req);
        return res.getBody();
    }
}
    
