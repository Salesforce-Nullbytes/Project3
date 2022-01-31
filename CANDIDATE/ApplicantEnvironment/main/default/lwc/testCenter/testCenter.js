import { LightningElement, track } from 'lwc';

export default class TestCenter extends LightningElement {


    @track
    questionList; 
    
    handleSelect(event){
        this.questionList = event.detail;
        console.log(event.detail);
    }

    handleSetFinish(){
        this.questionList = null;
    }

}