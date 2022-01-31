public class AuthUtil {
    // public static void Authenticate(String authCode)
    // public static void expireToken()
    // public static Boolean tokenValid()
    // public static Boolean isAuthenticated()
    // public static String getAccessToken()
    // public static RESTutil.ResponseCategory refreshSession()
    // public static RESTutil.ResponseCategory deauthenticate()

    // Utility items
    private enum AuthStatus {UNAUTHENTICATED, EXPIRED, VALID}
    private class TokenSet {
        String access;
        String refresh;
        TokenSet(String accessToken, String refreshToken) {
            access = accessToken;
            refresh = refreshToken;
        }
    }

    // PUBLIC METHODS
    public static string Authenticate(String authCode) {
        return serverAuthentication(RESTutil.RequestType.AUTHORIZE, authCode).name();
    }
    public static Boolean tokenValid() {
        AuthenticationInfo__c authInfo = getAuthInfo();
        return (AuthStatus.VALID == enumStatus(authInfo.Status__c));
    }
    public static void expireToken() {
        AuthenticationInfo__c authInfo = getAuthInfo();
        authInfo.Status__c = 'Expired';        
        Update authInfo;
    }
    public static Boolean isAuthenticated() {
        AuthenticationInfo__c authInfo = getAuthInfo();
        if (authInfo == null) authInfo = makeAuthInfo();
        if (enumStatus(authInfo.Status__c) == AuthStatus.UNAUTHENTICATED) {
            return false;
        }
        return true;
    }
    public static RESTutil.ResponseCategory refreshSession() {
        AuthenticationInfo__c authInfo = getAuthInfo();
        return serverAuthentication(RESTutil.RequestType.REFRESH, authInfo.RefreshToken__c);
    }
    public static String getAccessToken() {
        AuthenticationInfo__c authInfo = getAuthInfo();
        if (authInfo == null || enumStatus(authInfo.Status__c) == AuthStatus.UNAUTHENTICATED) {
            System.debug('ERROR: Cannot retrieve access token when unauthenticated!');
            return RESTutil.ResponseCategory.UNAUTHENTICATED.name();
        }
        if (enumStatus(authInfo.Status__c) == AuthStatus.EXPIRED) {
            System.debug('Access Token Expired! Resetting...');
            if (refreshSession() == RESTutil.ResponseCategory.GOOD) {
                System.debug('Successful refresh. Try callout again in a new transaction.');
                return RESTutil.ResponseCategory.EXPIRED_TOKEN.name();
            }
            System.debug('Refresh unsuccessful. Try re-authenticating.');
            return deauthenticate().name();
        }
        // Valid.
        return authInfo.AccessToken__c;
    }
    public static RESTutil.ResponseCategory deauthenticate() {
        AuthenticationInfo__c authInfo = getAuthInfo();
        authInfo.Status__c = 'Unauthenticated';
        Update authInfo;
        return RESTutil.ResponseCategory.UNAUTHENTICATED;
    }

    // Helper Methods
    private static AuthenticationInfo__c getAuthInfo() {
        ID currUser = UserInfo.getUserId();
        AuthenticationInfo__c[] auths = [
            SELECT AccessToken__c, RefreshToken__c, Status__c
            FROM AuthenticationInfo__c 
            WHERE User__c = :currUser
        ];
        if (auths.size() > 0) {
            return auths[0];
        }
        return null;
    }
    private static AuthenticationInfo__c makeAuthInfo() {
        ID currUser = UserInfo.getUserId();
        AuthenticationInfo__c auth = new AuthenticationInfo__c();
        auth.Status__c = 'Unauthenticated';
        auth.User__c = currUser;
        Insert auth;
        return auth;
    }
    
    // Handler for validating with server
    @testVisible
    private static RESTutil.ResponseCategory serverAuthentication(RESTutil.RequestType type, String authCode) {
        if (type != RESTutil.RequestType.AUTHORIZE && type != RESTutil.RequestType.REFRESH) {
            System.debug('ERROR: can not authenticate through ' + type);
            return null;
        }
        Http http = new Http();
        HttpRequest req = RESTutil.authRequest(type, authCode).request;
        HTTPResponse res = http.send(req);

        Boolean ifForceRefresh = (type == RESTutil.RequestType.REFRESH);
        return setInfoFromJSON(res.getBody(), ifForceRefresh);
    }
    @testVisible
    private static RESTutil.ResponseCategory setInfoFromJSON(String jsonAuthResponse, Boolean forceRefresh) {
        RESTutil.ResponseCategory result = RESTutil.checkError(jsonAuthResponse);
        AuthenticationInfo__c authInfo = getAuthInfo();
        if (authInfo == null) {
            authInfo = makeAuthInfo();
        }

        // Need to shortcut if refreshing session
        Boolean alreadyValid = (AuthStatus.VALID == enumStatus(getAuthInfo().Status__c));
        if (!forceRefresh && alreadyValid) {
            return RESTutil.ResponseCategory.ALREADY_VALID;
        }
        if (result != RESTutil.ResponseCategory.GOOD) {
            return result;
        }

        TokenSet tokens = parseTokens(jsonAuthResponse);
        updateDatabase(authInfo, tokens);
        return result;
    }
    private static void updateDatabase(AuthenticationInfo__c authInfo, TokenSet tokens) {
        if (tokens == null) {
            System.debug('ACCESS TOKEN NOT FOUND!');
            return; // Prevent by handling with RESTutil.checkError();
        }

        if (tokens.refresh != null) {
            authInfo.RefreshToken__c = tokens.refresh;
        }
        authInfo.AccessToken__c = tokens.access;
        authInfo.Status__c = strStatus(AuthStatus.VALID);

        Update authInfo;
    }

    // Parser Utility: get body response with token(s)
    //   Returns null if no tokens received in body.
    //   Returns only access token if only refreshing.
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
        // if refreshing, only accessToken provided (so refreshToken is null)
        return new TokenSet(accessToken, refreshToken);
    }

    // CONVERTER HELPERS
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
}
