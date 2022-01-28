import { LightningElement, api } from 'lwc';

export default class TestCenter extends LightningElement {


    @api
    questionList;

    question;

    handleSelect(event){
        this.question = event.detail;
    }
}