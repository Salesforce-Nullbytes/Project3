import { LightningElement } from 'lwc';
import getCandidateResults from '@salesforce/apex/PastResultsController.getCandidateResults';

export default class pastResults extends LightningElement {

    componentRendered = false;
    candidateResults = [];
    

    loadSummary() {
        getCandidateResults()
        .then((result) => {
            this.candidateResults = result; 
            
            for (let i = 0; i < result.length; i++) {
                
                this.candidateResults[i].attempt = i + 1; 

                let startDate = new Date(this.candidateResults[i].StartTime__c);
                let submitDate = new Date(this.candidateResults[i].SubmitTime__c);

                this.candidateResults[i].Start = startDate;
                this.candidateResults[i].Submit = submitDate;

                if (this.candidateResults[i].PassPercentage__c >= 70) {
                    this.candidateResults[i].PassFail = 'Pass';
                } else {
                    this.candidateResults[i].PassFail = 'Fail';
                }
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