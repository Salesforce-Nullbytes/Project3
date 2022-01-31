@isTest
public class AuthUtilTest {
    @isTest
    public static void TP_AuthenticateValid() {
        String mockCode = 'mockauthcode';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCallouts(MockHttpCallouts.MockType.AUTH));
        
        String result = AuthUtil.Authenticate(mockCode);
        Test.stopTest();

        ID userId = UserInfo.getUserId();
        AuthenticationInfo__c newInfo = [
            SELECT AccessToken__c, RefreshToken__c, Status__c FROM AuthenticationInfo__c WHERE User__c = :userId LIMIT 1
        ];
        System.assertEquals('newaccesstoken', newInfo.AccessToken__c); // Parameter passed from MockHttpCallouts class
        System.assertEquals('newrefreshtoken', newInfo.RefreshToken__c); // Parameter passed from MockHttpCallouts class
        System.assertEquals(RESTutil.ResponseCategory.GOOD.name(), result);
    }
    @isTest
    public static void TN_authenticateViaGet() {
        String mockCode = 'mockauthcode';
        Test.startTest();
        RESTutil.ResponseCategory result = AuthUtil.serverAuthentication(RESTutil.RequestType.GET, mockCode);
        System.assertEquals(null, result); // Abnormal condition returns null
        Test.stopTest();
    }
    @isTest
    public static void TN_AuthenticateTwice() {
        String mockCode = 'mockauthcode';
        Test.startTest();
        AuthenticationInfo__c authInfo = mockAuthInfo('Valid');
        Test.setMock(HttpCalloutMock.class, new MockHttpCallouts(MockHttpCallouts.MockType.AUTH_CODE_EXPIRED));
        
        asyncAuthenticateAlreadyValid(mockCode);
        Test.stopTest();

        AuthenticationInfo__c newInfo = [
            SELECT AccessToken__c, RefreshToken__c, Status__c FROM AuthenticationInfo__c WHERE id = :authInfo.id LIMIT 1
        ];
        System.assertEquals('mocktoken1', newInfo.AccessToken__c); // Unchanged from original helper
        System.assertEquals('mocktoken2', newInfo.RefreshToken__c); // Unchanged from original helper
    }
    @future(callout=true)
    public static void asyncAuthenticateAlreadyValid(String code) {
        String result = AuthUtil.Authenticate(code);
        System.assertEquals(RESTutil.ResponseCategory.ALREADY_VALID.name(), result);
    }
    @isTest
    public static void TN_AuthenticateCodeExpired() {
        String mockCode = 'mockauthcode';
        Test.startTest();
        AuthenticationInfo__c authInfo = mockAuthInfo('Unauthenticated');
        Test.setMock(HttpCalloutMock.class, new MockHttpCallouts(MockHttpCallouts.MockType.AUTH_CODE_EXPIRED));
        
        asyncAuthenticateExpired(mockCode);
        Test.stopTest();
    }
    @future(callout=true)
    public static void asyncAuthenticateExpired(String code) {
        String result = AuthUtil.Authenticate(code);
        System.assertEquals(RESTutil.ResponseCategory.EXPIRED_AUTH_CODE.name(), result);
    }
    @isTest
    public static void TN_AuthenticateInvalid() {
        String mockCode = 'mockauthcode';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCallouts(MockHttpCallouts.MockType.AUTH_BAD_CODE));
        
        String result = AuthUtil.Authenticate(mockCode);
        Test.stopTest();

        ID userId = UserInfo.getUserId();
        AuthenticationInfo__c newInfo = [
            SELECT AccessToken__c, RefreshToken__c, Status__c FROM AuthenticationInfo__c WHERE User__c = :userId LIMIT 1
        ];
        System.assertEquals(RESTutil.ResponseCategory.BAD_AUTH_CODE.name(), result);
    }
    @isTest
    public static void TN_SetBadTokensGoodResponse() { // @TESTVISIBLE TO REACH STRANGE CASES
        Test.startTest();
        AuthenticationInfo__c authInfo = mockAuthInfo('Expired'); // has tokens
        String json = '{"result":"without access token"}'; // Should never happen
        
        RESTutil.ResponseCategory result = AuthUtil.setInfoFromJson(json, false); // no forceRefresh
        AuthenticationInfo__c newInfo = [
            SELECT AccessToken__c, RefreshToken__c, Status__c FROM AuthenticationInfo__c WHERE id = :authInfo.id LIMIT 1
        ];
        System.assertEquals(RESTutil.ResponseCategory.GOOD, result); // Since no error in body
        System.assertEquals('mocktoken1', newInfo.AccessToken__c); // Not changed
        System.assertEquals('mocktoken2', newInfo.RefreshToken__c); // Not changed
        System.assertEquals('Expired', newInfo.Status__c); // Still Expired
        Test.stopTest();
    }
    @isTest
    public static void TP_isTokenValidWorks() {
        Test.startTest();
        // Three values provided are restricted picklist values!
        mockAuthInfo('Valid');
        System.assertEquals(true, AuthUtil.tokenValid());

        mockAuthInfo('Expired');
        System.assertNotEquals(true, AuthUtil.tokenValid());

        mockAuthInfo('Unauthenticated');
        System.assertNotEquals(true, AuthUtil.tokenValid());
        Test.stopTest();
    }
    @isTest
    public static void TP_expireTokenWorks() {
        Test.startTest();
        // Three values provided are restricted picklist values!
        AuthenticationInfo__c authInfo = mockAuthInfo('Valid');
        System.assertEquals(true, AuthUtil.tokenValid());

        AuthUtil.expireToken();
        System.assertNotEquals(true, AuthUtil.tokenValid());
        
        AuthenticationInfo__c newAuthInfo = [
            SELECT Status__c
            FROM AuthenticationInfo__c
            WHERE id = :authInfo.id
            LIMIT 1
        ];
        System.assertEquals('Expired', newAuthInfo.Status__c);
        Test.stopTest();
    }
    @isTest
    public static void TP_isAuthenticatedWorks() {
        Test.startTest();
        // Clears all information from Authentication info
        Delete [SELECT id FROM AuthenticationInfo__c];
        System.assertEquals(false, AuthUtil.isAuthenticated());
        
        AuthenticationInfo__c authInfo = [SELECT Status__c FROM AuthenticationInfo__c WHERE User__c = :UserInfo.getUserId()];
        System.assertEquals('Unauthenticated', authInfo.Status__c); // Creates base record when checking if doesnt exist

        authInfo.Status__c = 'Valid';
        Update authInfo;
        System.assertEquals(true, AuthUtil.isAuthenticated());

        authInfo.Status__c = 'Expired'; // Still authenticated, just need refresh from token
        Update authInfo;
        System.assertEquals(true, AuthUtil.isAuthenticated());

        authInfo.Status__c = 'Unauthenticated';
        Update authInfo;
        System.assertEquals(false, AuthUtil.isAuthenticated());

        Test.stopTest();
    }
    @isTest
    public static void TP_getTokenValid() {
        Test.startTest();
        AuthenticationInfo__c authInfo = mockAuthInfo('Valid');
        String token = authInfo.AccessToken__c;
        System.assertEquals('mocktoken1', token); // Defined in helper class
        
        System.assertEquals(token, AuthUtil.getAccessToken());
        Test.stopTest();
    }
    @isTest
    public static void TP_getTokenExpiredGoodRefresh() {
        Test.startTest();
        AuthenticationInfo__c authInfo = mockAuthInfo('Expired');
        String token = authInfo.AccessToken__c;
        System.assertEquals('mocktoken1', token); // Defined in helper class
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCallouts(MockHttpCallouts.MockType.REFRESH));
        asyncTokenExpiredGoodRefreshHelper();
        Test.stopTest();

        AuthenticationInfo__c newInfo = [
            SELECT AccessToken__c, Status__c FROM AuthenticationInfo__c WHERE id = :authInfo.id LIMIT 1
        ];
        System.assertEquals('refreshedtoken', newInfo.AccessToken__c); // Parameter passed from MockHttpCallouts class
        System.assertEquals('Valid', newInfo.Status__c);
        // User should no longer be Expired after call to getAccessToken()
    }
    @future(callout=true)
    public static void asyncTokenExpiredGoodRefreshHelper() {
        String result = AuthUtil.getAccessToken();
        System.assertEquals('EXPIRED_TOKEN', result);
        // New access token issued during call (requires DML)
        // Must start new transaction to make new callout since DML was used
    }
    @isTest
    public static void TP_getTokenExpireAndBadRefresh() {
        Test.startTest();
        AuthenticationInfo__c authInfo = mockAuthInfo('Expired');
        String token = authInfo.AccessToken__c;
        System.assertEquals('mocktoken1', token); // Defined in helper class
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCallouts(MockHttpCallouts.MockType.SESSION_EXPIRED));
        asyncTokenExpiredBadRefreshHelper();
        Test.stopTest();

        AuthenticationInfo__c newInfo = [
            SELECT AccessToken__c, Status__c FROM AuthenticationInfo__c WHERE id = :authInfo.id LIMIT 1
        ];
        System.assertEquals('mocktoken1', newInfo.AccessToken__c); // Not changed
        System.assertEquals('Unauthenticated', newInfo.Status__c); // But status now unauthenticated
    }
    @future(callout=true)
    public static void asyncTokenExpiredBadRefreshHelper() {
        String result = AuthUtil.getAccessToken();
        System.assertEquals('UNAUTHENTICATED', result);
        // New access token issued during call (requires DML)
        // Must start new transaction to make new callout since DML was used
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
}
