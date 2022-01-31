@isTest
public class RESTutilTest {
    private final static String restPath = 'main/services/apexrest/';
    @isTest
    public static void TN_getRequestUnauthenticated() {
        String mockResource = 'resource/';
        String mockParam = 'param';
        String mockStatus = 'Unauthenticated';
        Test.startTest();
        AuthenticationInfo__c authInfo = mockAuthInfo(mockStatus);

        RESTutil.RequestWrap req = RESTutil.getRequest(mockResource, mockParam);
        Test.stopTest();

        System.assertEquals(null, req.request);
        System.assertEquals(RESTutil.ResponseCategory.UNAUTHENTICATED, req.category);
    }
    @isTest
    public static void TP_authRequestCorrectFormatAuthorizeValid() {
        RESTutil.RequestType type = RESTutil.RequestType.AUTHORIZE;
        String mockCode = 'mockauthcode';
        Test.startTest();
        // Method Tested
        RESTutil.RequestWrap req = RESTutil.authRequest(type, mockCode);

        String reqMethod = req.request.getMethod();
        String reqEndpoint = req.request.getEndpoint();
        String reqBody = req.request.getBody();

        String expectedMethod = 'POST';
        String expectedEndpoint = serverInfo().LoginUrl__c + 'services/oauth2/token';
        
        ServerInfo__mdt server = serverInfo();
        String expectedBody = 'grant_type=authorization_code';        
        expectedBody += ('&client_id=' + server.Key__c);
        expectedBody += ('&client_secret=' + server.Secret__c);
        expectedBody += ('&code=' + EncodingUtil.urlEncode(mockCode, 'UTF-8'));
        expectedBody += ('&redirect_uri=' + server.ServerUrl__c + 'main/s/authorization');
        
        Test.stopTest();
        System.assertEquals(RESTutil.ResponseCategory.UNSENT, req.category);
        System.assertEquals(expectedMethod, reqMethod);
        System.assertEquals(expectedEndpoint, reqEndpoint);
        System.assertEquals(expectedBody, reqBody);
    }
    @isTest
    public static void TP_authRequestCorrectFormatRefreshValid() {
        RESTutil.RequestType type = RESTutil.RequestType.REFRESH;
        String mockCode = 'refresh_token';
        Test.startTest();
        // Method Tested
        RESTutil.RequestWrap req = RESTutil.authRequest(type, mockCode);

        String reqMethod = req.request.getMethod();
        String reqEndpoint = req.request.getEndpoint();
        String reqBody = req.request.getBody();

        String expectedMethod = 'POST';
        String expectedEndpoint = serverInfo().LoginUrl__c + 'services/oauth2/token';
        
        ServerInfo__mdt server = serverInfo();
        String expectedBody = 'grant_type=refresh_token';        
        expectedBody += ('&client_id=' + server.Key__c);
        expectedBody += ('&client_secret=' + server.Secret__c);
        expectedBody += ('&refresh_token=' + EncodingUtil.urlEncode(mockCode, 'UTF-8'));
        
        Test.stopTest();
        System.assertEquals(RESTutil.ResponseCategory.UNSENT, req.category);
        System.assertEquals(expectedMethod, reqMethod);
        System.assertEquals(expectedEndpoint, reqEndpoint);
        System.assertEquals(expectedBody, reqBody);
    }
    @isTest
    public static void TN_authRequestInvalid() {
        RESTutil.RequestType type = RESTutil.RequestType.GET;
        String mockCode = 'refresh_token';
        Test.startTest();
        // Method Tested
        RESTutil.RequestWrap req = RESTutil.authRequest(type, mockCode);

        Test.stopTest();
        System.assertEquals(RESTutil.ResponseCategory.BAD_GRANT_TYPE, req.category);
        System.assertEquals(null, req.request);
    }
    @isTest
    public static void TP_getRequestCorrectFormat() {
        String mockResource = 'resource/';
        String mockParam = 'param';
        String mockStatus = 'Valid';
        Test.startTest();
        AuthenticationInfo__c authInfo = mockAuthInfo(mockStatus);
        // Method Tested
        HttpRequest req = RESTutil.getRequest(mockResource, mockParam).request;

        String reqMethod = req.getMethod();
        String reqEndpoint = req.getEndpoint();
        String reqAuthorization = req.getHeader('Authorization');

        String expectedMethod = 'GET';
        String expectedEndpoint = serverInfo().ServerUrl__c + restPath + mockResource + mockParam;
        String expectedAuthorization = 'OAuth ' + authInfo.AccessToken__c;
        
        Test.stopTest();
        System.assertEquals(expectedMethod, reqMethod);
        System.assertEquals(expectedEndpoint, reqEndpoint);
        System.assertEquals(expectedAuthorization, reqAuthorization);
    }
    @isTest
    public static void TP_getRequestCorrectFormatBlankParam() {
        String mockResource = 'resource/';
        String mockParam = '';
        String mockStatus = 'Valid';
        Test.startTest();
        AuthenticationInfo__c authInfo = mockAuthInfo(mockStatus);
        // Method Tested
        HttpRequest req = RESTutil.getRequest(mockResource, mockParam).request;

        String reqMethod = req.getMethod();
        String reqEndpoint = req.getEndpoint();
        String reqAuthorization = req.getHeader('Authorization');

        String expectedMethod = 'GET';
        String expectedEndpoint = serverInfo().ServerUrl__c + restPath + mockResource + mockParam;
        String expectedAuthorization = 'OAuth ' + authInfo.AccessToken__c;
        
        Test.stopTest();
        System.assertEquals(expectedMethod, reqMethod);
        System.assertEquals(expectedEndpoint, reqEndpoint);
        System.assertEquals(expectedAuthorization, reqAuthorization);
    }
    @isTest
    public static void TN_getRequestExpired() {
        String mockResource = 'resource/';
        String mockParam = 'param';
        String mockStatus = 'Expired';
        Test.startTest();
        // Refresh callout occurs behind scenes when status is 'Expired'
        Test.setMock(HttpCalloutMock.class, new MockHttpCallouts(MockHttpCallouts.MockType.REFRESH));

        AuthenticationInfo__c authInfo = mockAuthInfo(mockStatus);
        System.assertEquals('mocktoken1', authInfo.AccessToken__c);

        // DML setup occurs prior to running test (set to expired)
        // Async needed if DML occurs prior to callout in same transaction
        // HttpRequest would be null (since it isnt sent this transaction)
        asyncExpiredHelper(mockResource, mockParam);
        Test.stopTest();

        AuthenticationInfo__c newInfo = [
            SELECT AccessToken__c, Status__c FROM AuthenticationInfo__c WHERE id = :authInfo.id LIMIT 1
        ];
        System.assertEquals('refreshedtoken', newInfo.AccessToken__c); // Parameter passed from MockHttpCallouts class
        System.assertEquals('Valid', newInfo.Status__c);
    }
    @future(callout=true)
    public static void asyncExpiredHelper(String mockResource, String mockParam) {
        // Method Tested w. expired token
        RESTutil.getRequest(mockResource, mockParam);
        // Expetcing callout to be made to set new access token
    }

    // Helper for setting authentication info of current user (whoever is running the test)
    private static AuthenticationInfo__c mockAuthInfo(String status) {
        ID userId = UserInfo.getUserId();

        AuthenticationInfo__c[] authInfo = [
            SELECT id, AccessToken__c, RefreshToken__c, Status__c, User__c 
            FROM AuthenticationInfo__c
            WHERE User__c = :userId
        ];

        if (authInfo.size() != 0) {
            authInfo[0].Status__c = status;
            Update authInfo[0];
            return authInfo[0];
        }

        AuthenticationInfo__c newAuthInfo = new AuthenticationInfo__c();
        newAuthInfo.AccessToken__c = 'mocktoken1';
        newAuthInfo.RefreshToken__c = 'mocktoken2';
        newAuthInfo.Status__c = status;
        newAuthInfo.User__c = userId;
        Insert newAuthInfo;
        return newAuthInfo;
    }
    // Helper for retrieving server url from custom metadata type
    private static ServerInfo__mdt serverInfo() {
        ServerInfo__mdt server = [
            SELECT ServerUrl__c, LoginUrl__c, Key__c, Secret__c
            FROM ServerInfo__mdt
            WHERE MasterLabel = 'Server' 
            LIMIT 1];
        return server;
    }
}
