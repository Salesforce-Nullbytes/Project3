public with sharing class questionSetCreatorController {
    @AuraEnabled
    public static List<Question__c> fetchQuestionList(){
        try {
            return [SELECT Name, QuestionTopic__c, Prompt__c FROM Question__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean checkDuplicate(String qsName){
        try {
            List<QuestionSet__c> qList = [SELECT Name FROM QuestionSet__c];
            Set<String> nameSet = new Set<String>();
            for (QuestionSet__c questionSet : qList) {
                nameSet.add(questionSet.Name);
            }
            Integer prevSize = nameSet.size();
            nameSet.add(qsName);
            if (nameSet.size() == prevSize) {
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean insertQuestionSet(String sName, List<String> nameList){
        try {
            try {
                QuestionSet__c qs = [SELECT Id FROM QuestionSet__c WHERE Name = :sName];
                return false;
            } catch (Exception e) {
                List<Question__c> qList = [SELECT Id FROM Question__c WHERE Name IN :nameList];

                QuestionSet__c qSet = new QuestionSet__c();
                qSet.Name = sName;
                INSERT qSet;

                List<QuestionSetEntry__c> insertList = new List<QuestionSetEntry__c>();
                for (Question__c question : qList) {
                    QuestionSetEntry__c qSetEntry = new QuestionSetEntry__c();
                    qSetEntry.QuestionSet__c = qSet.Id;
                    qSetEntry.Question__c = question.Id;
                    insertList.add(qSetEntry);
                }

                INSERT insertList;

                return true;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}