import { LightningElement, wire } from 'lwc';
import getQuestionSet from '@salesforce/apex/RESTcallout.getQuestionSet';

export default class QuestionExplorer extends LightningElement {
    questionSet = [
        {
            id: '1',
            name: 'set1',
            questions: [
                {
                    prompt: "Create a class that contains a public string named \'myString\'",
                    name: "Warm-up Question",
                    method: "public class warmup{\n\t//Write code here\n}"
                },
                {
                    prompt: "Create a class that contains a public string named \'myString\'",
                    name: "Warm-up Question 2",
                    method: "public class warmup{\n\t//Write code here\n}"
                },
                {
                    prompt: "Create a class that contains a public string named \'myString\'",
                    name: "Warm-up Question 3",
                    method: "public class warmup{\n\t//Write code here\n}"
                }
            ]
        },
        {
            id: '2',
            name: 'set2',
            questions: [
                {
                    prompt: "Create a class that contains a public string named \'myString\'",
                    name: "Warm-up Question",
                    method: "public class warmup{\n\t//Write code here\n}"
                },
                {
                    prompt: "Create a class that contains a public string named \'myString\'",
                    name: "Warm-up Question 2",
                    method: "public class warmup{\n\t//Write code here\n}"
                },
                {
                    prompt: "Create a class that contains a public string named \'myString\'",
                    name: "Warm-up Question 3",
                    method: "public class warmup{\n\t//Write code here\n}"
                }
            ]
        },
        {
            id: '3',
            name: 'set3',
            questions: [
                {
                    prompt: "Create a class that contains a public string named \'myString\'",
                    name: "Warm-up Question",
                    method: "public class warmup{\n\t//Write code here\n}"
                },
                {
                    prompt: "Create a class that contains a public string named \'myString\'",
                    name: "Warm-up Question 2",
                    method: "public class warmup{\n\t//Write code here\n}"
                },
                {
                    prompt: "Create a class that contains a public string named \'myString\'",
                    name: "Warm-up Question 3",
                    method: "public class warmup{\n\t//Write code here\n}"
                }
            ]
        }];
    

    retryGetList() {
        getQuestionSet().then(result => {
            this.questionSet = result;
            console.log(result);
        })
        .catch(error => {console.log(error)});
    }
    /*
    @wire(getQuestionSet,{url: ''})
    getQuestionList({error, data}) {
        if(data) {
            if(data=='TRY_AGAIN') {
                this.retryGetList();
            }
            this.questionSet = data;
            console.log(data);
        }
        else if(error) {
            this.retryGetList();
        }
    }*/

    handleSelect(event) {
        let selectevent = new CustomEvent('questionselect',{
            detail: event.detail
        });
        this.dispatchEvent(selectevent);
        console.log(event.detail);
    }
}
