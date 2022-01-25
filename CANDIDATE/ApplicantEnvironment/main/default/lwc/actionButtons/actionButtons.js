import { LightningElement } from 'lwc';

export default class ActionButtons extends LightningElement {

    onrunCode(){
        this.dispatchEvent(new CustomEvent('handlecoderun'));
        console.log('Code ran!');
    }

    onhandleSubmit(){
        this.dispatchEvent(new CustomEvent('handlesubmission'));
        console.log('Submit fired!');
    }
}