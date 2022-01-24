public with sharing class testQuestionCreatorController {
    @AuraEnabled
    public static List<String> topicPicklistValues() {
        //implement this once cateogry field has been added to erd
        return new List<String>();
    }

    @AuraEnabled
    public static void insertQuestion(String prompt, String placeHolder, /* String topic, */ String recordId) {

    }

    @AuraEnabled
    public static Boolean checkNameCollision(String name) {
        Set<String> checkSet = new Set<String>();
        List<ContentVersion> rawCheckList = [SELECT Title FROM ContentVersion];
        return false;
    }
}
