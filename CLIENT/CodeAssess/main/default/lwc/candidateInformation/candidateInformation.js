import {LightningElement, api} from 'lwc';
import getCandidateInfo from '@salesforce/apex/individualResultsController.getCandidateInfo';

export default class candidateInformation extends LightningElement {
    @api recordId;

    candidateName = 'Candidate Name';
    candidateEmail = 'Candidate Email';
    candidatePhoneNumber = 'Candidate Phone Number';

    componentRendered = false;

    loadInfo() {
        getCandidateInfo({record : this.recordId})
        .then((result) => {
            console.log("Success");

            this.candidateName = result.Candidate__r.Name;
            //this.candidateEmail = Candidate__c.Email__c;
            //this.candidatePhoneNumber = Candidate__c.Phone_Number__c;
        })
        .catch((error) => {
            console.log("Failure");
        });
    }


    renderedCallback() {
        if (this.componentRendered) {
            return;
        } 

        this.loadInfo();

        this.componentRendered = true;
    }
}