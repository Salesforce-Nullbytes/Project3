import {LightningElement, api} from 'lwc';
import getCandidateTestResults from '@salesforce/apex/candidateInformationController.getCandidateTestResults';

export default class candidateTestResults extends LightningElement {
    @api recordId;

    testOnePercentage = '100%';
    testTwoPercentage = '100%';
    testThreePercentage = '100%';
    testFourPercentage = '100%';
    testFivePercentage = '100%';

    testOnePassFail = 'Pass';
    testTwoPassFail = 'Pass';
    testThreePassFail = 'Pass';
    testFourPassFail = 'Pass';
    testFivePassFail = 'Pass';

    testOneTopic = 'None';
    testTwoTopic = 'None';
    testThreeTopic = 'None';
    testFourTopic = 'None';
    testFiveTopic = 'None';

    componentRendered = false;

    loadSummary() {
        getCandidateTestResults({record : this.recordId})
        .then((result) => {

            this.testOneTopic = result[0].Question__r.QuestionTopic__c;
            this.testOnePercentage = result[0].MethodsPassed__c / result[0].TotalMethods__c;
            this.testOnePassFail = result[0].Result__c;

            this.testTwoTopic = result[1].Question__r.QuestionTopic__c;
            this.testTwoPercentage = result[1].MethodsPassed__c / result[1].TotalMethods__c;
            this.testTwoPassFail = result[1].Result__c;

            this.testThreeTopic = result[2].Question__r.QuestionTopic__c;
            this.testThreePercentage = result[2].MethodsPassed__c / result[2].TotalMethods__c;
            this.testThreePassFail = result[2].Result__c;

            this.testFourTopic = result[3].Question__r.QuestionTopic__c;
            this.testFourPercentage = result[3].MethodsPassed__c / result[3].TotalMethods__c;
            this.testFourPassFail = result[3].Result__c;

            this.testFiveTopic = result[4].Question__r.QuestionTopic__c;
            this.testFivePercentage = result[4].MethodsPassed__c / result[4].TotalMethods__c;
            this.testFivePassFail = result[4].Result__c;          
        })
        .catch((error) => {
            console.log("Failure");
        });
    }


    renderedCallback() {
        if (this.componentRendered) {
            return;
        } 

        this.loadSummary();

        this.componentRendered = true;
    }
}