public class RESTutil {
    public enum RequestType {AUTHORIZE, REFRESH, GET}
    public enum ResponseCategory {
        GOOD, 
        BAD_AUTH_CODE, 
        INVALID_CLIENT, 
        EXPIRED_TOKEN, 
        EXPIRED_AUTH_CODE, 
        ALREADY_VALID,
        AUTHORIZATION_USED,
        UNRECOGNIZED
    }
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

    // HttpRequest Generators:
    public static HttpRequest getRequest(String resource, String param) {
        ServerInfo__mdt server = getServerInfo();
        String locator = server.ServerUrl__c + 'main/services/apexrest/';

        String token = AuthUtil.getAccessToken();
        System.debug(token);
        if (token == null) {
            System.debug('ERROR: No Access Token for GET request!');
            return null;
        }
        if (token == 'EXPIRED_TOKEN') {
            return null;
        }

        String fullResource = locator + resource + param;
        HttpRequest req = new HttpRequest(); 
        req.setMethod('GET');
        req.setEndpoint(fullResource);
        req.setHeader('Authorization', 'OAuth ' + token);

        return req;
    }
    public static HttpRequest authRequest(RequestType type, String code) {
        Boolean authorize = false;
        Boolean refresh = false;

        String grantType = '';
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

    // All types of contingencies on REST connection result
    public static ResponseCategory checkError(String response) {
        JSONParser parser = JSON.createParser(response);

        String accessToken;
        String refreshToken;
        
        String error;
        String errorDescription;
        String message;
        String errorCode;
        while (parser.NextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                switch on parser.getText() {
                    when 'error' {
                        parser.NextValue();
                        error = parser.getText();
                    }
                    when 'error_description' {
                        parser.NextValue();
                        errorDescription = parser.getText();
                    }
                    when 'message' {
                        parser.NextValue();
                        message = parser.getText();
                    }
                    when 'errorCode' {
                        parser.NextValue();
                        errorCode = parser.getText();
                    }
                }
            }
        }

        if (error != null) {
            switch on error {
                when 'invalid_client_id' {
                    System.debug('Check Metadata: client ID mismatch!');
                    return ResponseCategory.INVALID_CLIENT;
                }
                when 'invalid_grant' {
                    System.debug(errorDescription);
                    if (errorDescription == 'invalid authorization code') {
                        System.debug('Re-check Authorization code');
                        return ResponseCategory.BAD_AUTH_CODE;
                    }
                    if (errorDescription == 'expired authorization code') {
                        if (AuthUtil.tokenValid()) {
                            System.debug('already Authorized');
                            return ResponseCategory.AUTHORIZATION_USED;
                        }
                        System.debug('authorization code is already expired');
                        return ResponseCategory.EXPIRED_AUTH_CODE;
                    }
                }
            }
            System.debug('Unrecognized response error: ' + error);
            return ResponseCategory.UNRECOGNIZED;
        }
        if (message != null) {
            if (message == 'Session expired or invalid') {
                if (AuthUtil.tokenValid()) {
                    System.debug('Expired session, updating status');
                    // Cannot send a new HttpRequest in same transaction after DML
                    // Must indicate to user that the transaction must be retried.
                    AuthUtil.expireToken();
                    return ResponseCategory.EXPIRED_TOKEN;
                }
                // If refresh token fails, the Server admin deleted the connection.
                System.debug('Please get a new authentication code. Session was killed.');
                return ResponseCategory.EXPIRED_AUTH_CODE;
            }
            System.debug('Unrecognized response error: ' + error);
            return ResponseCategory.UNRECOGNIZED;
        }
        return ResponseCategory.GOOD;
    }
}