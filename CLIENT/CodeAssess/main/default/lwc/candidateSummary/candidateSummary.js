import {LightningElement, api} from 'lwc';
import getCandidateSummary from '@salesforce/apex/candidateInformationController.getCandidateSummary';

export default class candidateSummary extends LightningElement {
    @api recordId;

    score = 0;
    averageScore = 0;
    maxScore = 0;
    minScore = 100;
    summaryPassFail = 'Fail';

    startTime = 'NA';
    submitTime = 'NA';

    sum = 0;

    componentRendered = false;

    loadSummary() {
        getCandidateSummary({record : this.recordId})
        .then((result) => {

            for (let i = 0; i < result.length; i++) {

                this.score = result[i].MethodsPassed__c / result[i].TotalMethods__c * 100;
                this.sum +=  this.score;

                if (this.score > this.maxScore) {
                    this.maxScore = Math.round(this.score * 100) / 100;
                }

                if (this.score < this.minScore) {
                   this.minScore = Math.round(this.score * 100) / 100;
                }
            }
            
            this.startTime = new Date(result[0].CandidateResult__r.StartTime__c);
            this.submitTime = new Date(result[0].CandidateResult__r.SubmitTime__c);
 
            this.averageScore = Math.round(((this.sum / result.length) * 100) / 100);

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