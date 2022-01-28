import { LightningElement, api } from 'lwc';

export default class TestCenter extends LightningElement {


    @api
    questionList = [
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
    ];

    handleSelect(event){
        this.questionList = event.detail;
    }

    handleSetFinish(){
        this.questionList = null;
    }

}