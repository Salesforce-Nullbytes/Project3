public with sharing class testQuestionCreatorController {
    public List<String> topicPicklistValues() {
        //implement this once cateogry field has been added to erd
    }

    public void insertQuestion(String prompt, String placeHolder, /* String topic, */ String recordId) {

    }

    public Boolean checkNameCollision(String name) {
        Set<String> checkSet = new Set<String>();
        List<ContentVersion> rawCheckList = [SELECT Title FROM ContentVersion];
    }
}
