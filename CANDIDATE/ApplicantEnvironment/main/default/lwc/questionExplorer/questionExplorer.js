import { LightningElement, wire, track } from 'lwc';
import getQuestionSet from '@salesforce/apex/RESTcallout.getQuestionSet';
import setUnauth from '@salesforce/apex/AuthenticationController.deAuthenticate';
import setExpire from '@salesforce/apex/AuthenticationController.expireToken';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class QuestionExplorer extends LightningElement {
    
    @track questionSet = [];
    retryAuthentication = false;

    constructor(){
        super();
        if(this.questionSet.length == 0){
            this.getQuestionSets();
        }
    }

    getQuestionSets(){
        getQuestionSet({url:""}).then((result) =>{
            if(result == "UNAUTHENTICATED"){
                return;
            }
            if(result == "EXPIRED_TOKEN" && !this.retryAuthentication){
                this.retryAuthentication == true;
                setExpire();
                this.getQuestionSets();
            }
            else if(result){
                this.retryAuthentication = false;
                result = JSON.parse(JSON.parse(result));
                this.getQuestions(result.entries);
            }
        })
        .catch(error => {
            setUnauth();
            this.showErrorToast('Session lost; please refresh page.');
        });
    }

    getQuestions(sets){
        sets.forEach(element => {
            getQuestionSet({url:element.url}).then((questions) =>{
                if(questions){
                    questions = JSON.parse(JSON.parse(questions));
                    this.questionSet.push(questions);
                }
            });
        });
    }

    retryGetList() {
        getQuestionSet().then(result => {
            this.questionSet = result;
        })
        .catch(error => {this.showErrorToast(error)});
    }

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

    get hasQuestions() {
        return (this.questionSet.length != 0);
    }
}
