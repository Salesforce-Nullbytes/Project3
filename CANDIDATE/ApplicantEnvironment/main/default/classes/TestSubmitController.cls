public with sharing class TestSubmitController {
    
    @AuraEnabled
    public static String submitResponse(String response, String testClass, Boolean isTrigger){
        try {
            
            soapSforceCom200608Apex.Apex apex;
            soapSforceCom200608Apex.CompileAndTestResult result;
            soapSforceCom200608Apex.CompileAndTestRequest request;
            String testClassName;

            apex = new soapSforceCom200608Apex.Apex();
            apex.endpoint_x = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/s/53.0';
            apex.SessionHeader = new soapSforceCom200608Apex.SessionHeader_element();
            apex.SessionHeader.sessionId = fetchUserSessionId();

            request = new soapSforceCom200608Apex.CompileAndTestRequest();

            if(isTrigger){
                request.triggers = new String[]{response};
                request.classes = new String[]{testClass};
            }
            else{
                request.classes = new String[]{response,testClass};
            }

            request.checkOnly= true;

            testClassName = parseOutTestClassName(testClass);
            request.runTestsRequest = new soapSforceCom200608Apex.RunTestsRequest();
            request.runTestsRequest.classes = new String[]{testClassName};
            request.runTestsRequest.allTests = false;
            request.runTestsRequest.maxFailedTests = -1;
            request.runTestsRequest.skipCodeCoverage = true;
            request.runTestsRequest.tests = null;

            result = apex.compileAndTest(request);

            return JSON.serializePretty(result);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String compileClass(String response, Boolean isTrigger){
        try {
            soapSforceCom200608Apex.Apex apex;
            soapSforceCom200608Apex.CompileAndTestRequest request;
            soapSforceCom200608Apex.CompileAndTestResult result;

            apex = new soapSforceCom200608Apex.Apex();
            apex.endpoint_x = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/s/53.0';
            apex.SessionHeader = new soapSforceCom200608Apex.SessionHeader_element();
            apex.SessionHeader.sessionId = fetchUserSessionId();

            request = new soapSforceCom200608Apex.CompileAndTestRequest();

            if(isTrigger){
                request.triggers = new String[]{response};
            }
            else{
                request.classes = new String[]{response};
            }
            
            request.checkOnly = true;

            result = apex.compileAndTest(request);

            if(isTrigger) return JSON.serializePretty(result.triggers);

            return JSON.serializePretty(result.classes);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

   
        
    @TestVisible
    private static String fetchUserSessionId(){
        String sessionId = '';
        PageReference reportPage = Page.sessionIdVfPage;
        try {
            String vfContent = reportPage.getContent().toString();
            System.debug('vfContent '+vfContent);
            Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            endP = vfContent.indexOf('End_Of_Session_Id');
            sessionId = vfContent.substring(startP, endP);
        } catch (Exception e) {
            sessionId = '123456';

        }
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
