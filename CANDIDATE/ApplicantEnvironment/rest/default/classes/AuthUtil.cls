public class AuthUtil {
    // public static void Authenticate(String authCode)
    // public static void expireToken()
    // public static Boolean tokenValid()
    // public static Boolean isAuthenticated()
    // public static String getAccessToken()

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
        if (enumStatus(authInfo.Status__c) != AuthStatus.UNAUTHENTICATED) {
            return false;
        }
        return true;
    }
    public static String getAccessToken() {
        AuthenticationInfo__c authInfo = getAuthInfo();
        if (authInfo == null || enumStatus(authInfo.Status__c) == AuthStatus.UNAUTHENTICATED) {
            System.debug('ERROR: Cannot retrieve access token when unauthenticated!');
            return null;
        }
        if (enumStatus(authInfo.Status__c) == AuthStatus.EXPIRED) {
            System.debug('Access Token Expired! Resetting...');
            if (refreshAccessToken(authInfo.RefreshToken__c) == RESTutil.ResponseCategory.GOOD) {
                System.debug('Successful refresh. Try callout again in a new transaction.');
                return RESTutil.ResponseCategory.EXPIRED_TOKEN.name();
            }
            System.debug('Refresh unsuccessful. Try callout again in a new transaction.');
            return RESTutil.ResponseCategory.UNRECOGNIZED.name();
        }
        // Valid.
        return authInfo.AccessToken__c;
    }

    // Helper Methods
    private static RESTutil.ResponseCategory refreshAccessToken(String refreshCode) {
        return serverAuthentication(RESTutil.RequestType.REFRESH, refreshCode);
    }
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
    private static RESTutil.ResponseCategory setInfoFromJSON(String jsonAuthResponse) {
        RESTutil.ResponseCategory result = RESTutil.checkError(jsonAuthResponse);
        AuthenticationInfo__c authInfo = getAuthInfo();
        if (authInfo == null) {
            authInfo = makeAuthInfo();
        }

        if (AuthStatus.VALID == enumStatus(getAuthInfo().Status__c)) {
            return result;
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
    private static AuthenticationInfo__c makeAuthInfo() {
        ID currUser = UserInfo.getUserId();
        AuthenticationInfo__c auth = new AuthenticationInfo__c();
        auth.Status__c = 'Unauthenticated';
        auth.User__c = currUser;
        Insert auth;
        return auth;
    }

    // Handler for validating with server
    private static RESTutil.ResponseCategory serverAuthentication(RESTutil.RequestType type, String authCode) {
        if (type != RESTutil.RequestType.AUTHORIZE && type != RESTutil.RequestType.REFRESH) {
            System.debug('ERROR: can not authenticate through ' + type);
            return null;
        }
        Http http = new Http();
        HttpRequest req = RESTutil.authRequest(type, authCode);
        HTTPResponse res = http.send(req);

        return setInfoFromJSON(res.getBody());
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
