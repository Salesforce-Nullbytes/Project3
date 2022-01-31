import {LightningElement, api} from 'lwc';
import getCandidateInfo from '@salesforce/apex/candidateInformationController.getCandidateInfo';

export default class candidateInformation extends LightningElement {
    @api recordId;

    candidateName = 'Candidate Name';
    candidateEmail = 'Candidate Email';
    candidatePhoneNumber = 'Candidate Phone Number';

    componentRendered = false;

    loadInfo() {
        getCandidateInfo({record : this.recordId})
        .then((result) => {

            this.candidateName = result.Candidate__r.Name;
            this.candidateEmail = result.Candidate__r.Email__c;
            this.candidatePhoneNumber = result.Candidate__r.PhoneNumber__c;
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