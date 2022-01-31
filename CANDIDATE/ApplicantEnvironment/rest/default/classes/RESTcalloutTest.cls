@isTest
public class RESTcalloutTest {
    @TestSetup
    static void makeData(){
        ID userId = UserInfo.getUserId();
        Delete [
            SELECT id, AccessToken__c, RefreshToken__c, Status__c, User__c 
            FROM AuthenticationInfo__c
            WHERE User__c = :userId
        ];
        AuthenticationInfo__c newAuthInfo = new AuthenticationInfo__c();
        newAuthInfo.AccessToken__c = 'mocktoken1';
        newAuthInfo.RefreshToken__c = 'mocktoken2';
        newAuthInfo.Status__c = 'Valid';
        newAuthInfo.User__c = userId;
        Insert newAuthInfo;
    }
    @isTest
    public static void TP_getQuestionSetBlankGood() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCallouts(MockHttpCallouts.MockType.GET));
        String result = RESTcallout.getQuestionSet('');
        Test.stopTest();
        System.assertEquals('{"content":"some json response..."}', result);
    }
    @isTest
    public static void TN_getBadClient() {
        String mockParam = 'param';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCallouts(MockHttpCallouts.MockType.WRONG_CLIENT));
        String result = RESTcallout.getGreeting(mockParam);
        Test.stopTest();
        System.assertEquals('INVALID_CLIENT', result);
    }
    @isTest
    public static void TN_getNeedRefresh() {
        String mockParam = 'param';
        Test.startTest();
        AuthenticationInfo__c oldInfo = [
            SELECT id, AccessToken__c, RefreshToken__c, Status__c, User__c 
            FROM AuthenticationInfo__c
            WHERE User__c = :UserInfo.getUserId()
        ];
        System.assertEquals('mocktoken1', oldInfo.AccessToken__c);
        System.assertEquals('mocktoken2', oldInfo.RefreshToken__c);
        System.assertEquals('Valid', oldInfo.Status__c); // Believes they are valid, but will receive session expired message

        Test.setMock(HttpCalloutMock.class, new MockHttpCallouts(MockHttpCallouts.MockType.SESSION_REFRESH));
        String result = RESTcallout.getQuestionSet(mockParam);
        System.assertEquals('EXPIRED_TOKEN', result); // MESSAGE RECEIVED TO CALLER

        // Behind the scenes, the token is refreshed....
        AuthenticationInfo__c newInfo = [
            SELECT id, AccessToken__c, RefreshToken__c, Status__c, User__c 
            FROM AuthenticationInfo__c
            WHERE User__c = :UserInfo.getUserId()
        ];
        System.assertEquals('refreshedtoken', newInfo.AccessToken__c); // updated
        System.assertEquals('mocktoken2', newInfo.RefreshToken__c); // unchanged
        System.assertEquals('Valid', newInfo.Status__c); // Updated back to valid
        // Cannot update until next try

        Test.stopTest();
    }
    @isTest
    public static void TN_getWhenExpired() {
        String mockParam = 'param';
        Test.startTest();
        AuthUtil.expireToken(); // Sets to 'Expired'
        AuthenticationInfo__c oldInfo = [
            SELECT id, AccessToken__c, RefreshToken__c, Status__c, User__c 
            FROM AuthenticationInfo__c
            WHERE User__c = :UserInfo.getUserId()
        ];

        System.assertEquals('mocktoken1', oldInfo.AccessToken__c);
        System.assertEquals('mocktoken2', oldInfo.RefreshToken__c);
        System.assertEquals('Expired', oldInfo.Status__c);

        Test.setMock(HttpCalloutMock.class, new MockHttpCallouts(MockHttpCallouts.MockType.SESSION_REFRESH));
        asyncCalloutExpired(mockParam);
        Test.stopTest();

        // Behind the scenes, the token is refreshed....
        AuthenticationInfo__c newInfo = [
            SELECT id, AccessToken__c, RefreshToken__c, Status__c, User__c 
            FROM AuthenticationInfo__c
            WHERE User__c = :UserInfo.getUserId()
        ];
        System.assertEquals('refreshedtoken', newInfo.AccessToken__c); // updated
        System.assertEquals('mocktoken2', newInfo.RefreshToken__c); // unchanged
        System.assertEquals('Valid', newInfo.Status__c); // Updated back to valid
        // Cannot update until next try
    }
    @future(callout=true) 
    private static void asyncCalloutExpired(String mockParam) {
        String result = RESTcallout.getQuestionSet(mockParam);
        System.assertEquals('EXPIRED_TOKEN', result); // MESSAGE RECEIVED TO CALLER
    }
    @isTest
    public static void TN_getWhenExpiredFail() {
        String mockParam = 'param';
        Test.startTest();
        AuthUtil.expireToken(); // Sets to 'Expired'
        AuthenticationInfo__c oldInfo = [
            SELECT id, AccessToken__c, RefreshToken__c, Status__c, User__c 
            FROM AuthenticationInfo__c
            WHERE User__c = :UserInfo.getUserId()
        ];

        System.assertEquals('mocktoken1', oldInfo.AccessToken__c);
        System.assertEquals('mocktoken2', oldInfo.RefreshToken__c);
        System.assertEquals('Expired', oldInfo.Status__c);

        Test.setMock(HttpCalloutMock.class, new MockHttpCallouts(MockHttpCallouts.MockType.SESSION_REFRESH_FAIL));
        asyncCalloutExpiredFail(mockParam);
        Test.stopTest();

        // Behind the scenes, the token is refreshed....
        AuthenticationInfo__c newInfo = [
            SELECT id, AccessToken__c, RefreshToken__c, Status__c, User__c 
            FROM AuthenticationInfo__c
            WHERE User__c = :UserInfo.getUserId()
        ];
        System.assertEquals('mocktoken1', newInfo.AccessToken__c); // unchanged
        System.assertEquals('mocktoken2', newInfo.RefreshToken__c); // unchanged
        System.assertEquals('Unauthenticated', newInfo.Status__c); // Reset to unauthenticated
        // Cannot update until next try
    }
    @future(callout=true) 
    private static void asyncCalloutExpiredFail(String mockParam) {
        String result = RESTcallout.getQuestionSet(mockParam);
        System.assertEquals('UNAUTHENTICATED', result); // MESSAGE RECEIVED TO CALLER
    }
    @isTest
    public static void TN_getOtherError() {
        String mockParam = 'param';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCallouts(MockHttpCallouts.MockType.OTHER_ERROR));
        String result = RESTcallout.getGreeting(mockParam);
        Test.stopTest();
        System.assertEquals('UNRECOGNIZED', result);
    }
    @isTest
    public static void TN_getOtherMessage() {
        String mockParam = 'param';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCallouts(MockHttpCallouts.MockType.OTHER_MESSAGE));
        String result = RESTcallout.getGreeting(mockParam);
        Test.stopTest();
        System.assertEquals('UNRECOGNIZED', result);
    }
}
