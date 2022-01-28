// wireGetRecordCandidate.js
import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Candidate__c.Name',
    'Candidate__c.PhoneNumber__c',
    'Candidate__c.Email__c',
];

export default class Candidate extends LightningElement {
    //@api recordId;

//     @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
//     candidate__c;

//     get name() {
//         return this.candidate__c.data.fields.Name.value;
//     }

//     get phonenumber() {
//         return this.candidate__c.data.fields.PhoneNumber__C.value;
//     }

//     get email() {
//         return this.candidate__c.data.fields.Email__c.value;
//     }
 }