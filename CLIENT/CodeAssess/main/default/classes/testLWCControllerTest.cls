@isTest
public class testLWCControllerTest {
    @TestSetup
    static void makeData(){
        User c = TESTutilCommunityUser.makeCustomerAndUser('mockTestUser1');
    }

    @isTest
    public static void TP_getsStatusPicklistVals (){
        Test.startTest();
        List<String> returnedVals = testLWCController.getStatusOptions(); 
        List<Schema.PicklistEntry> actualList = CandidateResult__c.Status__c.getDescribe().getPicklistValues();

        Boolean missingEntry = false;
        for (Schema.PicklistEntry ple : actualList) {
            if (!returnedVals.contains(ple.getLabel())) {
                missingEntry = true;    
            }
        }
        System.assertEquals(false, missingEntry);
        Test.stopTest();
    }
    @isTest
    public static void TP_searchReturnsExpected (){
        Test.startTest();
        User c = [
            SELECT ContactID, Name FROM USER 
            WHERE Profile.Name = 'CodeAssessCandidate' AND Name = 'mockTestUser1'
            LIMIT 1
        ];
        
        // Question Set for candidate response
        QuestionSet__c mock = new QuestionSet__c(name = 'TestSet');
        insert mock;
        Question__c[] questions = new List<Question__c>();
        for (Integer i = 0; i < 2; i++) {
            Question__c q = new Question__c();
            q.PlaceHolder__c = 'placeholder';
            q.Prompt__c = 'prompt';
            q.QuestionTopic__c = 'SOQL';
            q.TestClassText__c = 'Some test class';
            questions.add(q);
        }
        Insert questions;
        for (Question__c q : questions) {
            QuestionSetEntry__c entry = new QuestionSetEntry__c();
            entry.Question__c = q.id;
            entry.QuestionSet__c = mock.id;
            Insert entry;
        }

        // Build response body in JSON
        String q1m1 = '{"name":"q1m1","outcome":"PASS"}';
        String q1m2 = '{"name":"q1m2","outcome":"PASS"}';
        String q2m1 = '{"name":"q2m1","outcome":"FAIL"}';
        String q2m2 = '{"name":"q2m2","outcome":"PASS"}';
        String q1 = '{"url":"'+questions[0].id+'","startTime":"2020-01-11 05:00:00","endTime":"2020-01-11 05:30:00","methods":['+q1m1+','+q1m2+']}';
        String q2 = '{"url":"'+questions[1].id+'","startTime":"2020-01-11 05:30:00","endTime":"2020-01-11 06:00:00","methods":['+q2m1+','+q2m2+']}';
        String sub = '{"url":"'+mock.id+'","startTime":"2020-01-11 05:00:00","endTime":"2020-01-11 06:00:00","questions":['+q1+','+q2+']}';

        // Make response body:
        String body = sub;
        
        System.runAs(c) {
            // Create POST request
            RestRequest request = new RestRequest();
            request.requestUri = getRESTurl() + 'questionset/';
            request.httpMethod = 'POST';
            request.headers.put('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf(body);
            RestContext.request = request;

            // Ensure successful post
            String response = RESTquestionset.submitTest();
            String expectedValue = 'SUCCESS';
            System.assertEquals(expectedValue, response);
        }

        //Check that result records uploaded to db
        CandidateResult__c[] cResults = [SELECT id FROM CandidateResult__c WHERE Contact__c = :c.ContactId];
        System.assertEquals(1, cResults.size());
        cResults[0].Status__c = 'Active';
        Update cResults[0]; // Set to ACTIVE
        CandidateQuestionResult__c[] cQuestions = [SELECT id FROM CandidateQuestionResult__c WHERE CandidateResult__c = :cResults[0].id];
        System.assertEquals(2, cQuestions.size());
        Set<ID> qResultIDs = new Set<ID>();
        for (CandidateQuestionResult__c q : cQuestions) {
            qResultIDs.add(q.id);
        }
        CandidateMethodResult__c[] cMethods = [SELECT id FROM CandidateMethodResult__c WHERE CandidateQuestionResult__c IN :qResultIDs];
        System.assertEquals(4, cMethods.size());
        Test.stopTest();

        List<CandidateResult__c> returned = testLWCController.searchForRecords('mock', '0', 'Active');
        System.assertEquals(1, returned.size(), returned);
        
    }

    // HELPER TO GET ENDPOINT URL
    private static String getRESTurl() {
        //Network net = [SELECT Name, UrlPathPrefix FROM Network WHERE Name = 'Code Assess Experience'];
        return URL.getSalesforceBaseUrl().toExternalForm() + 'main/services/apexrest/';
    }
}
