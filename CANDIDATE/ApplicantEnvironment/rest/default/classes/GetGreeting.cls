public class GetGreeting {
    public enum RequestType {AUTHORIZE, REFRESH, GET}
    private enum AuthStatus {UNAUTHENTICATED, EXPIRED, VALID}

    // Test function
    public static void getGreeting(String userInput) {
        Http http = new Http();
        HttpRequest req = getRequest('Greeting/', userInput);

        HTTPResponse res = http.send(req);

        // DEBUG INFO
        System.debug('BODY: '+res.getBody());
        System.debug('STATUS:'+res.getStatus());
        System.debug(res);

        //TODO: Check for expired code, and reset AuthStatus

        return;
    }
    public static void Authenticate(String authCode) {
        RequestType type = RequestType.AUTHORIZE;
        Http http = new Http();
        HttpRequest req = authRequest(type, authCode);

        HTTPResponse res = http.send(req);
        TokenSet tokens = parseTokens(res.getBody()); // parse access token from repsonse body
        setAuthInfo(tokens);

        // DEBUG INFO
        System.debug('BODY: '+res.getBody());
        System.debug('STATUS:'+res.getStatus());
        System.debug(res);

        //TODO: Check for expired code, and reset AuthStatus

        return;
    }

    // MAIN FUNCTION
    public static HttpRequest getRequest(String resource, String param) {
        ServerInfo__mdt server = getServerInfo();
        String locator = server.ServerUrl__c + 'main/services/apexrest/';

        String token = getAccessToken();
        if (token == null) {
            System.debug('ERROR: No Access Token for GET!');
            return null;
        }

        String fullResource = locator + resource + param;
        System.debug(fullResource);

        // Send REST request
        HttpRequest req = new HttpRequest(); 
        req.setMethod('GET');
        req.setEndpoint(fullResource);
        req.setHeader('Authorization', 'OAuth ' + token);

        return req;
    }
    public static HttpRequest authRequest(RequestType type, String code) {
        // code on authorize: authentication code
        // code on refresh: refresh token

        Boolean authorize = false;
        Boolean refresh = false;

        String grantType = '';
        // VALIDATIONS
        switch on type {
            when AUTHORIZE { 
                grantType = 'authorization_code';
                authorize = true;
            }
            when REFRESH {
                grantType = 'refresh_token';
                refresh = true;
            }
            when else {
                System.debug('ERROR: grant_type cannot be ' + type);
                return null;
            }
        }

        ServerInfo__mdt server = getServerInfo();
        String loginUri = server.LoginUrl__c + 'services/oauth2/token';

        // CREATE REQUEST
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setEndpoint(loginUri);

        // SET REQUEST BODY
        String body = 'grant_type=' + grantType;        
        body += ('&client_id=' + server.Key__c);
        body += ('&client_secret=' + server.Secret__c);
        if (authorize) {
            String redirect = server.ServerUrl__c + 'main/s/authorization';
            body += ('&code=' + EncodingUtil.urlEncode(code, 'UTF-8'));
            body += ('&redirect_uri=' + redirect);
        }
        if (refresh) {
            body += ('&refresh_token=' + code);
        }
        req.setBody(body);
        
        return req;
    }

    // TOKEN UTILTIY
    private static String getAccessToken() {
        AuthenticationInfo__c authInfo = getAuthInfo();
        switch on enumStatus(authInfo.Status__c) {
            when VALID {
                return authInfo.AccessToken__c;
            }
            when EXPIRED {
                return setAccessToken(RequestType.REFRESH, authInfo.RefreshToken__c);
            }
        }
        System.debug('ERROR: Cannot retrieve access token when unauthenticated!');
        return null;
    }
    private static String setAccessToken(RequestType type, String code) {
        Http http = new Http();
        HttpRequest req = authRequest(type, code);

        HTTPResponse res = http.send(req);
        TokenSet tokens = parseTokens(res.getBody()); // parse access token from repsonse body
        setAuthInfo(tokens);

        // DEBUG INFO
        System.debug(type);
        System.debug('BODY: '+res.getBody());
        System.debug('STATUS:'+res.getStatus());
        System.debug('TOKEN:'+tokens);

        // TODO: verify contents, and handle exceptions on invalid token grant

        return tokens.access;
    }
    private static void setAuthInfo(TokenSet tokens) {
        // Save updated token
        AuthenticationInfo__c authInfo = getAuthInfo();
        authInfo.AccessToken__c = tokens.access;
        authInfo.RefreshToken__c = tokens.refresh;
        authInfo.Status__c = strStatus(AuthStatus.VALID);
        Update authInfo;
    }

    // Parser Utility
    private static TokenSet parseTokens(String response) {
        JSONParser parser = JSON.createParser(response);

        String accessToken;
        String refreshToken;
        
        while (parser.NextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                switch on parser.getText() {
                    when 'access_token' {
                        parser.NextValue();
                        accessToken = parser.getText();
                    }
                    when 'refresh_token' {
                        parser.NextValue();
                        refreshToken = parser.getText();
                    }
                }
            }
        }

        if (accessToken == null) {
            System.debug('ACCESS TOKEN NOT FOUND!');
            return null;
        }
        return new TokenSet(accessToken, refreshToken);
    }
    private class TokenSet {
        String access;
        String refresh;
        TokenSet(String accessToken, String refreshToken) {
            access = accessToken;
            refresh = refreshToken;
        }
    }

    // AuthStatus Utility
    private static String strStatus(AuthStatus status) {
        String result = null;
        switch on status {
            when UNAUTHENTICATED { result = 'Unauthenticated'; }
            when EXPIRED { result = 'Expired'; }
            when VALID { result = 'Valid'; }
        }
        return result;
    }
    private static AuthStatus enumStatus(String status) {
        AuthStatus result = null;
        switch on status {
            when 'Unauthenticated' { result = AuthStatus.UNAUTHENTICATED; }
            when 'Expired' { result = AuthStatus.EXPIRED; }
            when 'Valid' { result = AuthStatus.VALID; }
        }
        return result;
    }

    // RETRIEVERS
    private static ServerInfo__mdt getServerInfo() {
        // Code Assess Server Info
        ServerInfo__mdt server = [
            SELECT ServerUrl__c, LoginUrl__c, Key__c, Secret__c
            FROM ServerInfo__mdt 
            WHERE MasterLabel = 'Server'
            LIMIT 1
        ];
        return server;
    }
    private static AuthenticationInfo__c getAuthInfo() {
        ID currUser = UserInfo.getUserId();
        //System.debug(currUser);

        AuthenticationInfo__c[] auths = [
            SELECT AccessToken__c, RefreshToken__c, Status__c
            FROM AuthenticationInfo__c 
            WHERE User__c = :currUser
        ];

        // VALIDATE AUTORIZATION INFO
        if (auths.size() == 1) {
            return auths[0];
        }
        if (auths.size() == 0) {
            // Set to null by default
            AuthenticationInfo__c auth = new AuthenticationInfo__c();
            auth.User__c = currUser;
            Insert auth;
            return auth;
        }

        System.debug('ERROR: Each user must have only 1 authentication info record!');
        return null; // Consider throwing exception. Trigger should disallow.
    }
}
    
