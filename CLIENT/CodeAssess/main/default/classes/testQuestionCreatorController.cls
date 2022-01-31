public with sharing class testQuestionCreatorController {
    @AuraEnabled
    public static List<String> topicPicklistValues() {
        List<Schema.PicklistEntry> valuesList = Question__c.QuestionTopic__c.getDescribe().getPicklistValues();

        List<String> returnList = new List<String>();
        for (Schema.PicklistEntry ple : valuesList) {
            returnList.add(ple.getLabel());
        }

        return returnList;
    }

    @AuraEnabled
    public static String insertQuestion(String qName, String topic, String placeholder, String prompt, String rawText) {

        Question__c insertQ = new Question__c();
        insertQ.Name = qName;
        insertQ.QuestionTopic__c = topic;
        insertQ.PlaceHolder__c = placeholder;
        insertQ.Prompt__c = prompt;
        insertQ.TestClassText__c = EncodingUtil.base64Decode(rawText).toString();

        INSERT insertQ;

        return insertQ.Id;
    }

    @AuraEnabled
    public static String linkFile(String base64, String filename, String recordId){
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;

        try {
            INSERT cv;
        } catch(DmlException e) {
            return e.getMessage();
        }

        ContentDocumentLink cdLink = new ContentDocumentLink();
        cdLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        cdLink.LinkedEntityId = recordId;
        cdLink.ShareType = 'V';

        try {
            INSERT cdLink;
        } catch(DmlException e) {
            return e.getMessage();
        }

        return 'success';
    }

    //checks if theres a naming collision with passed file name and files names already in org as well as question name
    @AuraEnabled
    public static Boolean checkNameCollision(String name, String qName) {
        //check for file naming collision
        Set<String> checkSet = new Set<String>();
        
        for (ContentVersion cv : [SELECT Title FROM ContentVersion]) {
            checkSet.add(cv.Title);
        }

        Integer prevSize = checkSet.size();
        checkSet.add(name);

        if (checkSet.size() == prevSize) return true;
        
        //check for question naming collision
        Set<String> qCheckSet = new Set<String>();

        for (Question__c question: [SELECT Name FROM Question__c]) {
            qCheckSet.add(question.Name);
        }

        prevSize = qCheckSet.size();
        qCheckSet.add(qName);

        if (qCheckSet.size() == prevSize) return true;

        return false;
    }
}
