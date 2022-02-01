Integer numResults = 10;

Contact jeff = new Contact();
jeff.FirstName = 'Jeff';
jeff.LastName = 'AlsoJeff';
INSERT jeff;

List<CandidateResult__c> crList = new List<CandidateResult__c>();

for (Integer index = 0; index < numResults; index++) {
    CandidateResult__c newCR = new CandidateResult__c();
    
    Double rand = Math.random();
    if (rand > .95) {
        newCR.Status__c = 'Active';
    } else if (rand > .85) {
        newCR.Status__c = 'Abandoned';
    } else {
        newCR.Status__c = 'Completed';
    }

    newCR.Contact__c = jeff.Id;

    crList.add(newCR);
}

INSERT crList;

List<Question__c> qList = new List<Question__c>();
for (Integer index = 0; index < (numResults * 5); index++) {
    Question__c newQ = new Question__c();
    newQ.Prompt__c = 'yay funny prompt';
    newQ.Placeholder__c = 'wooo placeholder';
    newQ.TestClassText__c = 'fun dummy data';
    List<String> topics = new List<String>{'Apex Fundamentals', 'Apex Triggers', 'Aura Components', 'Events', 'SOQL', 'SOSL'};
    newQ.QuestionTopic__c = topics[Integer.valueOf(Math.random() * 5)];
    qList.add(newQ);
}
INSERT qList;

List<CandidateQuestionResult__c> cqrList = new List<CandidateQuestionResult__c>();

for (Integer index = 0; index < (numResults * 5); index++) {
    CandidateQuestionResult__c newCQR = new CandidateQuestionResult__c();
    newCQR.CandidateResult__c = crList[index/5].Id;
    newCQR.Question__c = qList[index].Id;
    cqrList.add(newCQR);
}

INSERT cqrList;

List<CandidateMethodResult__c> cmrList = new List<CandidateMethodResult__c>();

for (Integer index = 0; index < (numResults * 25); index++) {
    CandidateMethodResult__c newCMR = new CandidateMethodResult__c();
    newCMR.MethodName__c = 'Test Method: ' + (index + 1);
    if (Math.random() > .97) {
        newCMR.Outcome__c = 'Fail';
    } else {
        newCMR.Outcome__c = 'Pass';
    }
    newCMR.CandidateQuestionResult__c = cqrList[index/5].Id;
    cmrList.add(newCMR);
}

INSERT cmrList;