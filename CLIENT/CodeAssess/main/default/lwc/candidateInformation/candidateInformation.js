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

            this.candidateName = result.Contact__r.Name;
            this.candidateEmail = result.Contact__r.Email;
            this.candidatePhoneNumber = result.Contact__r.Phone;
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