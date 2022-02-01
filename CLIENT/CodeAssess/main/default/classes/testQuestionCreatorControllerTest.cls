@isTest
public  class testQuestionCreatorControllerTest {
    @isTest
    public static void TP_topicPicklistVals (){
        Test.startTest();
        List<String> returnedVals = testQuestionCreatorController.topicPicklistValues(); 
        List<Schema.PicklistEntry> actualList = Question__c.QuestionTopic__c.getDescribe().getPicklistValues();

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
    public static void TP_makeQuestion() {
        Blob testblob = Blob.valueOf('@isTest public class mockTest {}');
        String testClass = EncodingUtil.base64Encode(testBlob);
        ID created = testQuestionCreatorController.insertQuestion('mock question', 'SOQL', 'placeholder', 'dothis', testClass); 
        Question__c[] q = [SELECT id FROM Question__c WHERE id = :created];
        System.assertEquals(1, q.size());
    }
    
}
