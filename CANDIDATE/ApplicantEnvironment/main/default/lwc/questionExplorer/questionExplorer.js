import { LightningElement, wire, track } from 'lwc';
import getQuestionSet from '@salesforce/apex/RESTcallout.getQuestionSet';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class QuestionExplorer extends LightningElement {
    
    @track questionSet = [];

    constructor(){
        super();
        if(this.questionSet.length == 0){
            getQuestionSet({url:""}).then((result) =>{
                if(result){
                    result = JSON.parse(JSON.parse(result));
                    result.entries.forEach(element => {
                        getQuestionSet({url:element.url}).then((questions) =>{
                            if(questions){
                                questions = JSON.parse(JSON.parse(questions));
                                this.questionSet.push(questions);
                            }
                        });
                    });
                }
            });
        }
    }

    retryGetList() {
        getQuestionSet().then(result => {
            this.questionSet = result;
        })
        .catch(error => {this.showErrorToast(error)});
    }
    /*
    @wire(getQuestionSet,{url: ''})
    getQuestionList({error, data}) {
        
        console.log(data);
        
        if(data) {
            data = JSON.parse(data);
            if(data=='TRY_AGAIN') {
                this.retryGetList();
            }
            this.questionSet = JSON.parse(data);
            console.log(data);
        }
        else if(error) {
            this.retryGetList();
        }
    }
    */
    handleSelect(event) {
        let selectevent = new CustomEvent('questionselect',{
            detail: event.detail
        });
        this.dispatchEvent(selectevent);
        console.log(event.detail);
    }

    showErrorToast(error){
        const event = new ShowToastEvent({
            title: 'ERROR',
            variant: 'error',
            message: error
        });
        this.dispatchEvent(event);
    }
}
