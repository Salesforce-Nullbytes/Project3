import { LightningElement, wire } from 'lwc';
import getQuestionSet from '@salesforce/apex/RESTcallout.getQuestionSet';

export default class QuestionExplorer extends LightningElement {
    
    questionSet =[
        {
            url : "aaaaa",
            name : "Test Suite 1",
            questions : [
                {
                    name : "Warmup 1",
                    topic: "Apex",
                    testFile : " ",
                    prompt : "Create a class that contains a public string named \'myString\'",
                    placeholder : "public class warmup{\n\t//Write code here\n}",
                    identifier : "bbbb"
                },
                {
                    name : "Warmup 2",
                    topic: "Apex",
                    testFile : " ",
                    prompt : "Create a class that contains a public string named \'myString\'",
                    placeholder : "public class warmup{\n\t//Write code here\n}",
                    identifier : "bbbb"
                },
                {
                    name : "Warmup 3",
                    topic: "Apex",
                    testFile : " ",
                    prompt : "Create a class that contains a public string named \'myString\'",
                    placeholder : "public class warmup{\n\t//Write code here\n}",
                    identifier : "bbbb"
                }
            ]
        },
        {
            url : "aaaaa",
            name : "Test Suite 2",
            questions : [
                {
                    name : "Warmup 1",
                    topic: "Apex",
                    testFile : " ",
                    prompt : "Create a class that contains a public string named \'myString\'",
                    placeholder : "public class warmup{\n\t//Write code here\n}",
                    identifier : "bbbb"
                },
                {
                    name : "Warmup 2",
                    topic: "Apex",
                    testFile : " ",
                    prompt : "Create a class that contains a public string named \'myString\'",
                    placeholder : "public class warmup{\n\t//Write code here\n}",
                    identifier : "bbbb"
                },
                {
                    name : "Warmup 3",
                    topic: "Apex",
                    testFile : " ",
                    prompt : "Create a class that contains a public string named \'myString\'",
                    placeholder : "public class warmup{\n\t//Write code here\n}",
                    identifier : "bbbb"
                }
            ]
        },
        {
            url : "aaaaa",
            name : "Test Suite 3",
            questions : [
                {
                    name : "Warmup 1",
                    topic: "Apex",
                    testFile : " ",
                    prompt : "Create a class that contains a public string named \'myString\'",
                    placeholder : "public class warmup{\n\t//Write code here\n}",
                    identifier : "bbbb"
                },
                {
                    name : "Warmup 2",
                    topic: "Apex",
                    testFile : " ",
                    prompt : "Create a class that contains a public string named \'myString\'",
                    placeholder : "public class warmup{\n\t//Write code here\n}",
                    identifier : "bbbb"
                },
                {
                    name : "Warmup 3",
                    topic: "Apex",
                    testFile : " ",
                    prompt : "Create a class that contains a public string named \'myString\'",
                    placeholder : "public class warmup{\n\t//Write code here\n}",
                    identifier : "bbbb"
                }
            ]
        },
    ] 

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
