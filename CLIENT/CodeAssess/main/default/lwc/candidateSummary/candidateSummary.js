import {LightningElement, api} from 'lwc';
import getCandidateSummary from '@salesforce/apex/candidateInformationController.getCandidateSummary';

export default class candidateSummary extends LightningElement {
    @api recordId;

    averageScore = 0;
    maxScore = 0;
    minScore = 100;
    summaryPassFail = 'Fail';

    sum = 0;

    totalTime = 0;
    averageTime = 0;

    componentRendered = false;

    loadSummary() {
        getCandidateSummary({record : this.recordId})
        .then((result) => {

            for (let i = 0; i < result.length; i++) {
 
                this.sum += result[i].CodeCoverage__c;

                if (result[i].CodeCoverage__c > this.maxScore) {
                    this.maxScore = result[i].CodeCoverage__c;
                }

                if (result[i].CodeCoverage__c < this.minScore) {
                   this.minScore = result[i].CodeCoverage__c;
                }

            }
 
            this.averageScore = (this.sum / result.length);

            if (this.averageScore > 70) {
                this.summaryPassFail = 'Pass';
            }

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