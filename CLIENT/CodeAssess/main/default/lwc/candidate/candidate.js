// wireGetRecordCandidate.js
import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Candidate.Name',
    'Candidate.Phone',
    'Candidate.Email',
];

export default class Candidate extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    candidate;

    get name() {
        return this.candidate.data.fields.Name.value;
    }

    get phone() {
        return this.candidate.data.fields.Phone.value;
    }

    get email() {
        return this.candidate.data.fields.Email.value;
    }
}