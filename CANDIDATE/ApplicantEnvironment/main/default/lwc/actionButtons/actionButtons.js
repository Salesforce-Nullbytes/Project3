import { LightningElement } from 'lwc';

export default class ActionButtons extends LightningElement {

    runCode(){
        this.dispatchEvent(new CustomEvent('runcode'));
        console.log('Code fired!');
    }

    handleSubmit(){
        this.dispatchEvent(new CustomEvent('submitresponse'));
        console.log('Submit fired!');
    }
}