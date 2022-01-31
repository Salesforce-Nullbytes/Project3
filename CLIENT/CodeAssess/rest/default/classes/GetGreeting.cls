@RestResource(urlMapping='/Greeting/*')
global class GetGreeting {
    @httpGet
    global static String getGreeting() {

        RestRequest req = RestContext.request;
        RestResponse response = RestContext.response;

        String context = req.requestURI;
        String urlInput = context.substring(context.lastIndexOf('/')+1);
        return 'Hello from server! (' + urlInput + ')';
    }
}