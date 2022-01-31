public class RESTcallout {
    // Test function
    public static String getGreeting(String url) {
        return getResource('Greeting/', url);
    }

    // CORE METHODS
    @AuraEnabled(cacheable = true)
    public static String getQuestionSet(String url) {
        return getResource('questionset/', url);
    }
    @AuraEnabled
    public static String postSubmission(String jsonBody) {
        return postResource('questionset/', jsonBody); // Simply returns 'SUCCESS' if successful. No validation necessary
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
    private static String postResource(String locator, String jsonBody) {
        // // Escape doublequotes
        // String regExp = '[//"]';
        // String replacement = '"';
        // String scrubbed = jsonBody.replaceAll(regExp, replacement);
        // System.debug(scrubbed);

        Http http = new Http();
        RESTutil.RequestWrap req = RESTutil.postRequest(locator, jsonBody);
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
    
