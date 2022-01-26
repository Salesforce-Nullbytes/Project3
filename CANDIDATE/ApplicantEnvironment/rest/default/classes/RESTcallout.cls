public class RESTcallout {
    // Test function
    public static void getGreeting(String userInput) {
        Http http = new Http();
        HttpRequest req = RESTutil.getRequest('Greeting/', userInput);

        HTTPResponse res = http.send(req);

        // DEBUG INFO
        System.debug('BODY: '+res.getBody());
        System.debug('STATUS:'+res.getStatus());
        System.debug(res);

        //TODO: Check for expired code, and reset AuthStatus

        return;
    }
    
}
    
