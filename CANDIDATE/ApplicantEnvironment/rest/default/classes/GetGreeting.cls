public class GetGreeting {

    public static void GetGreeting(String authCode, String userInput) {
        // Code Assess Server Info
        ServerInfo__mdt server = [
            SELECT ServerUrl__c
            FROM ServerInfo__mdt 
            WHERE MasterLabel = 'Server'
            LIMIT 1
        ];

        String uri = server.ServerUrl__c + 'main/services/apexrest/Greeting/' + userInput;
        System.debug(uri);

        // CHECK FOR EXISTING ACCESS TOKEN OR REFRESH TOKEN FIRST
        String accessToken = getAccessToken(authCode);

        // Send REST request
        HttpRequest req = new HttpRequest(); 
        req.setMethod('GET');
        req.setEndpoint(uri);
        req.setHeader('Authorization', 'OAuth '+accessToken);

        // Get REST Response
        Http http = new Http();
        HTTPResponse res = http.send(req);

        // DEBUG INFO
        System.debug('BODY: '+res.getBody());
        System.debug('STATUS:'+res.getStatus());
        System.debug(res);

        return;
    }

    // CONSIDER PUTTING INTO A UTILITY CLASS
    // Sets/retrieves the access token and refresh token
    private static String getAccessToken(String code) {

        // IF TOKEN EXISTS, USE!
        // IF EXPRIED, USE REFRESH!
        // Otherwise....

        // Code Assess Server Info
        ServerInfo__mdt server = [
            SELECT ServerUrl__c, LoginUrl__c, Key__c, Secret__c
            FROM ServerInfo__mdt 
            WHERE MasterLabel = 'Server'
            LIMIT 1
        ];

        String loginUri = server.LoginUrl__c + 'services/oauth2/token'; // 'https://test.salesforce.com';
        String redirect = server.ServerUrl__c + 'main/s/authorization'; // looking for sandbox project codeassess

        // Request authentication, returns access code
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setEndpoint(loginUri);
        req.setBody('grant_type=authorization_code' +
            '&code=' + EncodingUtil.urlEncode(code, 'UTF-8') +    
            '&client_id=' + server.Key__c +
            '&client_secret=' + server.Secret__c +
            '&redirect_uri=' + redirect);
    
        Http http = new Http();
        HTTPResponse res = http.send(req);

        // DEBUG INFO
        System.debug('BODY: '+res.getBody());
        System.debug('STATUS:'+res.getStatus());

        return parseToken(res.getBody()); // parse access token from repsonse body
    }
    // Helper parser
    private static String parseToken(String response) {
        JSONParser parser = JSON.createParser(response);
        
        while (parser.NextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                switch on parser.getText() {
                    when 'access_token' {
                        parser.NextValue();
                        return parser.getText();
                    }
                }
            }
        }

        System.debug('ACCESS TOKEN NOT FOUND!');
        return '';
    }
}
    
