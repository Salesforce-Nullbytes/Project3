import {LightningElement, api} from 'lwc';
import getCandidateSummary from '@salesforce/apex/candidateInformationController.getCandidateSummary';

export default class candidateSummary extends LightningElement {
    @api recordId;

    score = 0;
    averageScore = 0;
    maxScore = 0;
    minScore = 100;
    summaryPassFail = 'Fail';

    sum = 0;

    componentRendered = false;

    loadSummary() {
        getCandidateSummary({record : this.recordId})
        .then((result) => {

            for (let i = 0; i < result.length; i++) {

                this.score = result[i].MethodsPassed__c / result[i].TotalMethods__c * 100;
                this.sum +=  this.score;

                if (this.score > this.maxScore) {
                    this.maxScore = this.score;
                }

                if (this.score < this.minScore) {
                   this.minScore = this.score;
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