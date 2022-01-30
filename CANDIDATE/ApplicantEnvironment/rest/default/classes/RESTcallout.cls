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
        RESTutil.RequestWrap req = RESTutil.getRequest(locator, param);
        if (req.category != RESTutil.ResponseCategory.UNSENT) {
            //   if RESTutil.ResponseCategory.EXPIRED_TOKEN -> Session has been reset behind the scenes. Try again.
            //   if RESTutil.ResponseCategory.UNAUTHENTICATED -> Session was invalid. Please re-authenticate.
            return req.category.name();
        }
        HTTPResponse res = http.send(req.request);
        RESTutil.ResponseCategory outcome = RESTutil.checkError(res.getBody());
        if (outcome != RESTutil.ResponseCategory.GOOD) {
            return outcome.name();
        }
        return res.getBody();
    }
}
    
