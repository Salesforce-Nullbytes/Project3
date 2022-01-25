import { LightningElement,api } from 'lwc';

export default class TestEnvironment extends LightningElement {

    @api question;

    addSubmission(event){
        console.log("Submitted");
    }
}