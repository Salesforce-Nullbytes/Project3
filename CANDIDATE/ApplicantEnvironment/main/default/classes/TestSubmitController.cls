
/* CONTROLLER CLASS FOR HANDLING CODE RUNS / SUBMISSIONS:
    - Sends Data passed from UI to SOAP api for compiling/testing
    - Sends results via 'RESTcallout' methods to the client
    - Aura Methods are called from the 'answerContainer' LWC
    - soapSforceCom200608Apex is generated from Salesforce Apex WSDL for Apex API
*/
public with sharing class TestSubmitController {
    
    /* Submit = Compile amd Test code and send results to client, results also returned to UI */
    @AuraEnabled
    public static String submitResponse(String response, String testClass){
        try {
            soapSforceCom200608Apex.Apex apex;
            soapSforceCom200608Apex.CompileAndTestResult result;
            soapSforceCom200608Apex.CompileAndTestRequest request;
            String testClassName;

            // 'apex' holds request headers/session data for api
            apex = new soapSforceCom200608Apex.Apex();
            apex.endpoint_x = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/s/53.0';
            apex.SessionHeader = new soapSforceCom200608Apex.SessionHeader_element();
            apex.SessionHeader.sessionId = fetchUserSessionId();

            request = new soapSforceCom200608Apex.CompileAndTestRequest();
            request.classes = new String[]{response,testClass};
            request.checkOnly= true;

            testClassName = parseOutTestClassName(testClass);
            request.runTestsRequest = new soapSforceCom200608Apex.RunTestsRequest();
            request.runTestsRequest.classes = new String[]{testClassName};
            request.runTestsRequest.allTests = false;
            request.runTestsRequest.maxFailedTests = -1;
            request.runTestsRequest.skipCodeCoverage = true;
            request.runTestsRequest.tests = null;

            result = apex.compileAndTest(request);

            AsyncSendSubmissions.enqueueSubmission(result);

            return JSON.serializePretty(result);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* Compile class only returns to UI for testing code for CompileTime errors */
    @AuraEnabled
    public static String compileClass(String response){
        try {
            soapSforceCom200608Apex.Apex apex;
            soapSforceCom200608Apex.CompileAndTestRequest request;
            soapSforceCom200608Apex.CompileAndTestResult result;

            apex = new soapSforceCom200608Apex.Apex();
            apex.endpoint_x = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/s/53.0';
            apex.SessionHeader = new soapSforceCom200608Apex.SessionHeader_element();
            apex.SessionHeader.sessionId = fetchUserSessionId();

            request = new soapSforceCom200608Apex.CompileAndTestRequest();
            request.classes = new String[]{response};
            request.checkOnly = true;

            result = apex.compileAndTest(request);

            return JSON.serializePretty(result.classes);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    

    /*  Valid user session could not be retrieved using UserInfo.getSessionId()
        This workaround parses the Global variable for sessionID from a VF page 
            - possibly because of context of AuraEnabled Method ? 
    */
    private static String fetchUserSessionId(){
        String sessionId = '';
        // Refer to the Page
        PageReference reportPage = Page.sessionIdVfPage;
        // Get the content of the VF page
        String vfContent = reportPage.getContent().toString();
        System.debug('vfContent '+vfContent);
        // Find the position of Start_Of_Session_Id and End_Of_Session_Id
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
        endP = vfContent.indexOf('End_Of_Session_Id');
        // Get the Session Id
        sessionId = vfContent.substring(startP, endP);
        System.debug('sessionId '+sessionId);
        // Return Session Id
        return sessionId;
    }

    private static String parseOutTestClassName(String testClass){
        Integer openBraceIndex = testClass.indexOf('{');
        String classDeclaration = testClass.substring(0,openBraceIndex);
        List<String> classDecTokens = classDeclaration.split(' ');
        Integer classTokenIndex = classDecTokens.indexOf('class');
    
        return classDecTokens[classTokenIndex + 1];
    }

}
