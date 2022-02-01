@isTest
public class GetGreetingTest {
    @isTest
    public static void TP_getGreetingGoodParam() {
        String param = 'urlencoded';
        // Create GET request
        RestRequest request = new RestRequest();
        request.requestUri = getRESTurl() + 'Greeting/' + param;
        request.httpMethod = 'GET';
        RestContext.request = request;

        String response = GetGreeting.getGreeting();
        String expected = 'Hello from server! (' + param + ')';
        System.assertEquals(expected, response);
    }

    private static String getRESTurl() {
        //Network net = [SELECT Name, UrlPathPrefix FROM Network WHERE Name = 'Code Assess Experience'];
        return URL.getSalesforceBaseUrl().toExternalForm() + 'main/services/apexrest/';
    }
}
