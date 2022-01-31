@IsTest
public class RESTQuestionSetTest {
    @IsTest
    public static void testGetFullQuestionSetInvalidId() {
    //Positive Test run for the method 

    Test.startTest();
    //Test.setMock(HttpCalloutMock.class, new RESTQuestionSetCalloutMock());

    //Call the method to test. It's a public class so @testvisible doesn't matter since it's only used for private classes
    //This will cause the fake response to be set from the class that implements HttpCalloutMock.
    //HttpResponse res = RESTquestionset.getFullQuestionSet('identifier')
    String actualValue = RESTquestionset.getFullQuestionSet('invalidId');
    String expectedValue = 'Invalid query';
    
    //Finally, neeed to verify the response recieved contains the fake values 
    //String contentType = res.getHeader('Content-Type');
    //System.assert(contentType == 'application/json');

    //String actualValue = res.getBody();
    //String expectedValue = '{"entries":['+
    //'{"url":"a04J000000lJstiIAC","questions":[],"name":"Master Questions"},' +
    //'{"url":"a04J000000lJstdIAC","questions":[],"name":"Trigger"}]}';
    Test.stopTest();

    System.assertEquals(expectedValue, actualValue, actualValue);
    //System.assertEquals(200, res.getStatusCode());
    }

    @IsTest
    public static void testGetFullQuestionSetNoQuestions() {
    //Positive Test run for the method 

    Test.startTest();
    QuestionSet__c mock = new QuestionSet__c(name = 'TestSet');
    insert mock;
   
    String actualValue = RESTquestionset.getFullQuestionSet(mock.id);
    String expectedValue = 'No questions to query';
    
    
    Test.stopTest();

    System.assertEquals(expectedValue, actualValue, actualValue);
    
    }

    @IsTest
    public static void testGetFullQuestionSetGetQuestions() {
    //Positive Test run for the method 

    Test.startTest();
    QuestionSet__c mock = new QuestionSet__c(name = 'TestSet');
    insert mock;

    Question__c[] questions = new List<Question__c>();
    for (Integer i = 0; i < 2; i++) {
        Question__c q = new Question__c();
        q.PlaceHolder__c = 'placeholder';
        q.Prompt__c = 'prompt';
        q.QuestionTopic__c = 'SOQL';
        questions.add(q);
    }
    Insert questions;
    for (Question__c q : questions) {
        QuestionSetEntry__c entry = new QuestionSetEntry__c();
        entry.Question__c = q.id;
        entry.QuestionSet__c = mock.id;
        Insert entry;
    }
   
    String actualValue = RESTquestionset.getFullQuestionSet(mock.id);
    String expectedValue = '{\"url\":\"' + mock.id + '\",\"questions\":'
    +'[{\"topic\":\"SOQL\",\"prompt\":\"prompt\",\"placeholder\":\"placeholder\",\"identifier\":\"' + questions[0].id + '\"},'
    +'{\"topic\":\"SOQL\",\"prompt\":\"prompt\",\"placeholder\":\"placeholder\",\"identifier\":\"' + questions[1].id + '\"}],'
    +'\"name\":\"TestSet\"}';
    
    
    Test.stopTest();

    System.assertEquals(expectedValue, actualValue, actualValue);
    
    }

    @IsTest
    public static void TestMakeQuestionSetList() {
        delete [SELECT ID FROM QuestionSet__c];
        QuestionSet__c mock1 = new QuestionSet__c(name = 'TestSet1');
        insert mock1;
        QuestionSet__c mock2 = new QuestionSet__c(name = 'TestSet2');
        insert mock2;

        String actualValue = RESTquestionset.makeQuestionSetList();
        Boolean match = false;

        if (actualValue == '{\"entries\":[{\"url\":\"' + mock1.id + '\",\"questions\":[],\"name\":\"' + mock1.name + '\"},{\"url\":\"' + mock2.id + '\",\"questions\":[],\"name\":\"' + mock2.name + '\"}]}') {
            match = true;
        }
        if (actualValue == '{\"entries\":[{\"url\":\"' + mock2.id + '\",\"questions\":[],\"name\":\"' + mock2.name + '\"},{\"url\":\"' + mock1.id + '\",\"questions\":[],\"name\":\"' + mock1.name + '\"}]}') {
            match = true;
        }
        
        System.assert(match);
    }
}
