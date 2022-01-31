import { LightningElement, api } from 'lwc';

export default class TestCenter extends LightningElement {


    @api
    questionList; 
    
    handleSelect(event){
        this.questionList = event.detail;
    }

    handleSetFinish(){
        this.questionList = null;
    }

}