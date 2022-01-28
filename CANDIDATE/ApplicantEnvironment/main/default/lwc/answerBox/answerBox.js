import { LightningElement, api } from 'lwc';

export default class answerBox extends LightningElement {
    @api method;

    @api
    reset(){
        let textarea = this.template.querySelector('textarea');
        textarea.value = this.method;
    }

    @api 
    getCandidateResponse(){
        return this.template.querySelector('textarea').value;
    }
}