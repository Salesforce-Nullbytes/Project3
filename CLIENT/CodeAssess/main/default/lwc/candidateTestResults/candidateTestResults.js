import {LightningElement, api} from 'lwc';
import getCandidateTestResults from '@salesforce/apex/candidateInformationController.getCandidateTestResults';

export default class candidateTestResults extends LightningElement {
    @api recordId;

    candidateInfo = [];
    componentRendered = false;

    loadSummary() {
        getCandidateTestResults({record : this.recordId})
        .then((result) => {

            this.candidateInfo = result;

            for (let i = 0; i < result.length; i++) {
                this.candidateInfo[i].index = i + 1;
                this.candidateInfo[i].percentage = Math.round((result[i].MethodsPassed__c / result[i].TotalMethods__c * 100) * 100) / 100;
            }         
        })
        .catch((error) => {
            console.log("Failure3");
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