@isTest
public  class MockHttpCallouts implements HttpCalloutMock {
    public enum MockType {
        GET, POST, AUTH, 
        REFRESH, AUTH_BAD_CODE, AUTH_CODE_EXPIRED, SESSION_REFRESH, SESSION_REFRESH_FAIL,
        SESSION_EXPIRED, WRONG_CLIENT, OTHER_ERROR, OTHER_MESSAGE
    }
    private final String REFRESHED_TOKEN_NAME = 'refreshedtoken';
    private final String ACCESS_TOKEN_NAME = 'newaccesstoken';
    private final String REFRESH_TOKEN_NAME = 'newrefreshtoken';
    private MockType type;

    public MockHttpCallouts(MockType responseType) {
        type = responseType;
    }
    public HTTPResponse respond(HTTPRequest req) {
        switch on type {
            when GET {
                return getResponseQuestionSetBlank(req);
            }
            when REFRESH {
                return refreshResponse(req);
            }
            when AUTH {
                return authResponseValid(req);
            }
            when AUTH_BAD_CODE {
                return authResponseBadCode(req);
            }
            when AUTH_CODE_EXPIRED {
                return responseCodeExpired(req);
            }
            when SESSION_EXPIRED {
                return responseSessionExpired(req);
            }
            when WRONG_CLIENT {
                return responseWrongClient(req);
            }
            when OTHER_ERROR {
                return responseOtherError(req);
            }
            when OTHER_MESSAGE {
                return responseOtherMessage(req);
            }
            when SESSION_REFRESH {
                if (req.getMethod() == 'GET') return responseSessionExpired(req);
                return refreshResponse(req);
            }
            when SESSION_REFRESH_FAIL {
                if (req.getMethod() == 'GET') return responseSessionExpired(req);
                return responseSessionExpired(req);
            }
        }
        return null;
    }

    public HTTPResponse getResponseQuestionSetBlank(HTTPRequest req) {
        System.assertEquals('GET', req.getMethod());

        // Mocked Response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        String body = '{"content":"some json response..."}';
        
        res.setBody(body);
        return res;
    }
    public HTTPResponse refreshResponse(HTTPRequest req) {
        System.assertEquals('POST', req.getMethod());
        System.assertEquals('application/x-www-form-urlencoded', req.getHeader('Content-Type'));
        System.assertEquals(serverInfo().LoginUrl__c + 'services/oauth2/token', req.getEndpoint());

        // Mocked Response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        String body = '{"access_token":"'+REFRESHED_TOKEN_NAME+'"}';
        
        res.setBody(body);
        return res;
    }
    public HTTPResponse authResponseValid(HTTPRequest req) {
        System.assertEquals('POST', req.getMethod());
        System.assertEquals('application/x-www-form-urlencoded', req.getHeader('Content-Type'));
        System.assertEquals(serverInfo().LoginUrl__c + 'services/oauth2/token', req.getEndpoint());

        // Mocked Response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        String body = '{"access_token":"'+ACCESS_TOKEN_NAME+'","refresh_token":"'+REFRESH_TOKEN_NAME+'"}';
        
        res.setBody(body);
        return res;
    }
    public HTTPResponse authResponseBadCode(HTTPRequest req) {
        System.assertEquals('POST', req.getMethod());
        System.assertEquals('application/x-www-form-urlencoded', req.getHeader('Content-Type'));
        System.assertEquals(serverInfo().LoginUrl__c + 'services/oauth2/token', req.getEndpoint());

        // Mocked Response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        String body = '{"error":"invalid_grant","error_description":"invalid authorization code"}';
        
        res.setBody(body);
        return res;
    }
    public HTTPResponse responseCodeExpired(HTTPRequest req) {
        // Mocked Response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        String body = '{"error":"invalid_grant","error_description":"expired authorization code"}';
        
        res.setBody(body);
        return res;
    }
    public HTTPResponse responseSessionExpired(HTTPRequest req) {
        // Mocked Response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        String body = '{"message":"Session expired or invalid","errorCode":"INVALID_SESSION_ID"}';
        
        res.setBody(body);
        return res;
    }
    public HTTPResponse responseWrongClient(HTTPRequest req) {
        // Mocked Response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        String body = '{"error":"invalid_client_id"}';
        
        res.setBody(body);
        return res;
    }
    public HTTPResponse responseOtherError(HTTPRequest req) {
        // Mocked Response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        String body = '{"error":"mock other"}';
        
        res.setBody(body);
        return res;
    }
    public HTTPResponse responseOtherMessage(HTTPRequest req) {
        // Mocked Response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        String body = '{"message":"mock other"}';
        
        res.setBody(body);
        return res;
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