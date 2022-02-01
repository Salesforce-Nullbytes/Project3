@isTest
public class testQuestionCreatorControllerTest {

    @TestSetup
    static void createDataRecords(){
        
    }

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
    
}
