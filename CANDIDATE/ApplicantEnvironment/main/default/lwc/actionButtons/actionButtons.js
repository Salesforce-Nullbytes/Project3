import { LightningElement } from 'lwc';

export default class ActionButtons extends LightningElement {

    runCode(){
        this.dispatchEvent(new CustomEvent('runcode'));
    }

    handleSubmit(){
        this.dispatchEvent(new CustomEvent('submitresponse'));
    }
}